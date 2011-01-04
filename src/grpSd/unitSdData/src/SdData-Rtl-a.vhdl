--
-- Title: Architecure of SdData
-- File: SdData-Rtl-a.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description:  
--

architecture Rtl of SdData is

	type aState is (idle, send, receive); -- overall states
	type aRegion is (startbit, data, crc, endbit); -- regions in send and receive state

	-- types for used counters
	subtype aWordCounter is unsigned(LogDualis(128)-1 downto 0);
	subtype aByteCounter is unsigned(LogDualis(4)-1 downto 0);
	subtype aBitCCounter is unsigned(LogDualis(8)-1 downto 0);

	type aCounters is record
		Word : aWordCounter;
		Byte : aByteCounter;
		BitC : aBitCCounter;
	end record aCounters;

	constant cDefaultCounters : aCounters := (
	Word => (others => '0'),
	Byte => (others => '0'),
	BitC => (others => '0'));

	-- all registers
	type aReg is record
		-- state, region and counters
		
		State   : aState;
		Region  : aRegion;
		Counter : aCounters;

		Mode : aSdDataBusMode; -- standard or wide SD mode

		Word        : aWord; -- temporary save for data to write to the read fifo
		WordInvalid : std_ulogic; -- after starting receiving we have to wait for word to be valid before it can be written to the read fifo

		-- outputs
		Data          : aoSdData;
		Controller    : aSdDataToController;
		ReadWriteFifo : aoReadFifo;
		WriteReadFifo : aoWriteFifo;
		DisableSdClk  : std_ulogic;
	end record aReg;

	-- default value for registers
	constant cDefaultReg : aReg := (
	State         => idle,
	Region        => startbit,
	Counter       => cDefaultCounters,
	Mode          => standard,
	WordInvalid   => cInactivated,
	Word          => (others                     => '0'),
	Data          => cDefaultSdData,
	Controller    => cDefaultSdDataToController,
	ReadWriteFifo => cDefaultoReadFifo,
	WriteReadFifo => cDefaultoWriteFifo,
	DisableSdClk  => cInactivated);

	type aCrcOut is record
		Clear   : std_ulogic;
		DataIn  : std_ulogic;
		Data    : std_ulogic_vector(3 downto 0);
	end record aCrcOut;

	constant cDefaultCrcOut : aCrcOut := (
	Clear  => cInactivated,
	DataIn => cInactivated,
	Data   => (others       => '0'));

	type aCrcIn is record
		Correct : std_ulogic_vector(3 downto 0);
		Serial  : std_ulogic_vector(3 downto 0);
	end record aCrcIn;

	signal CrcIn     : aCrcIn;
	signal CrcOut    : aCrcOut;
	signal CrcDataIn : std_ulogic_vector(3 downto 0);
	signal R, NextR  : aReg;

begin

	-- registered outputs
	oData               <= R.Data;
	oSdDataToController <= R.Controller;
	oReadWriteFifo      <= R.ReadWriteFifo;
	oWriteReadFifo      <= R.WriteReadFifo;
	oDisableSdClk       <= R.DisableSdClk;


	Regs : process (iClk, inResetAsync)
	begin
		-- asynchronous reset
		if (inResetAsync = cnActivated) then
			R <= cDefaultReg;

		-- clock event
		elsif (iClk'event and iClk = cActivated) then

			-- synchronous enable
			if (iStrobe = cActivated) then
				R <= NextR;
			end if;

			-- rdreq and wrreq have to be exactly one clock cycle wide
			R.ReadWriteFifo.rdreq <= NextR.ReadWriteFifo.rdreq and iStrobe;
			R.WriteReadFifo.wrreq <= NextR.WriteReadFifo.wrreq and iStrobe;

			-- Clock has to be disabled before the next strobe is generated
			R.DisableSdClk        <= NextR.DisableSdClk;
		end if;
	end process Regs;

	-- Calculate the next state and output
	Comb : process (iData.Data, iSdDataFromController, CrcIn, iReadWriteFifo, iWriteReadFifo, R)

		--------------------------------------------------------------------------------
		-- Calculate the bit addr from the byte and bit counters
		--------------------------------------------------------------------------------
		function CalcBitAddrInWord (constant bytes : aByteCounter; constant bits : aBitCCounter) return integer is
		begin
			return (to_integer(bytes) * 8) + to_integer(bits);
		end function CalcBitAddrInWord;

		--------------------------------------------------------------------------------
		-- Set crc outputs so data is shifted in
		--------------------------------------------------------------------------------
		procedure ShiftIntoCrc (constant data : in aSdData) is
		begin
			CrcOut.Data   <= data;
			CrcOut.DataIn <= cActivated;
		end procedure ShiftIntoCrc;

		--------------------------------------------------------------------------------
		-- Send data to card and calculate crc
		--------------------------------------------------------------------------------
		procedure SendBitsAndShiftIntoCrc (constant data : in aSdData) is
		begin
			ShiftIntoCrc(data);
			NextR.Data.Data <= data;
		end procedure SendBitsAndShiftIntoCrc;

		--------------------------------------------------------------------------------
		-- Calculate the next counters and region
		-- Handles loading next data from fifo or writing data to fifo as well
		--------------------------------------------------------------------------------
		procedure CalcNextAndHandleData (constant send : boolean) is
			-- End and decrement values for standard mode
			variable BitEnd : integer := 0;
			variable BitDec : integer := 1;
		begin

			-- reset variables if wide mode is used
			if R.Mode = wide then
				BitEnd := 3;
				BitDec := 4;
			end if;
			
			if (R.Counter.BitC = BitEnd) then
				-- Byte finished
				NextR.Counter.BitC <= to_unsigned(7, aBitCCounter'length);

				if (R.Counter.Byte = 3) then
					-- Word finished
					NextR.Counter.Byte <= to_unsigned(0, aByteCounter'length);
					NextR.WordInvalid  <= cInactivated;

					if (R.Counter.Word = 127) then
						-- whole block finished, send crc next
						NextR.Region       <= crc;
						NextR.Counter.Word <= to_unsigned(0, aWordCounter'length);

					else
						NextR.Counter.Word <= R.Counter.Word + 1;

						if (send = true) then
							-- save next word from fifo
							NextR.Word <= iReadWriteFifo.q;
						end if;
					end if;
				else 
					NextR.Counter.Byte <= R.Counter.Byte + 1;
				end if;
			else
				NextR.Counter.BitC <= R.Counter.BitC - BitDec;
			end if;

			if (send = true) then
				if ((R.Counter.BitC = BitEnd + BitDec and R.Counter.Byte = 3 and R.Counter.Word < 127)) then
					-- request next word from fifo
					if (iReadWriteFifo.rdempty = cActivated) then
						-- handle rdempty: Disable SdClk until data is available
						report "No data available, fifo empty, waiting for new data" severity note;

						NextR.DisableSdClk <= cActivated;
						NextR.Counter.BitC <= R.Counter.BitC;

					else
						-- request new data from fifo
						NextR.DisableSdClk        <= cInactivated;
						NextR.ReadWriteFifo.rdreq <= cActivated;
					end if;
				end if;
			else
				if (R.Counter.Byte = 0 and R.Counter.BitC = 7 and R.WordInvalid = cInactivated) then
					-- save word to ram
					-- TODO: handle write full
					NextR.WriteReadFifo.wrreq <= cActivated;
					NextR.WriteReadFifo.data  <= R.Word;
				end if;
			end if;
		end procedure CalcNextAndHandleData;

		--------------------------------------------------------------------------------
		-- Calculate the bit address in widewidth mode
		--------------------------------------------------------------------------------
		function IsBitAddrInRangeWideWidth (constant addr : in natural; constant C : in aCounters; constant mode : aSdDataBusMode) return boolean is
			variable curHighAddr : integer;
		begin
			-- calculate current address (of the high bit in case of wide mode)
			curHighAddr := (127 - to_integer(C.Word)) * 32 + (3 - to_integer(C.Byte)) * 8 + to_integer(C.BitC);

			if (mode = standard) then
				return curHighAddr = addr;
			else
				return curHighAddr >= addr and curHighAddr - 3 <= addr;
			end if;
		end function IsBitAddrInRangeWideWidth;

		--------------------------------------------------------------------------------
		-- Get specific bit from data vector
		--------------------------------------------------------------------------------
		impure
		function GetBitFromData (constant addr : in natural) return std_ulogic is
		begin
			if (R.Mode = standard) then
				return iData.Data(0);
			else
				return iData.Data(addr mod 4);
			end if;
		end function GetBitFromData;

		variable temp : std_ulogic_vector(3 downto 0) := "0000";

	begin

		-- default assignments
		NextR                                         <= R;
		NextR.Data.En                                 <= (others => cInactivated);
		NextR.Controller                              <= cDefaultSdDataToController;
		NextR.Controller.WideMode                     <= R.Controller.WideMode;
		NextR.Controller.SpeedBits.HighSpeedSupported <= R.Controller.SpeedBits.HighSpeedSupported;
		NextR.Controller.SpeedBits.SwitchFunctionOK   <= R.Controller.SpeedBits.SwitchFunctionOK;
		NextR.ReadWriteFifo                           <= cDefaultoReadFifo;
		NextR.WriteReadFifo                           <= cDefaultoWriteFifo;
		CrcOut                                        <= cDefaultCrcOut;

		case R.State is
			when idle => 
				-- check if card signals that it is busy
				if (iSdDataFromController.CheckBusy = cActivated and iData.Data(0) = cInactivated) then
					NextR.Controller.Busy <= cActivated;

				elsif (R.Mode = wide and iData.Data = cSdStartBits) or
				(R.Mode = standard and iData.Data(0) = cSdStartBit) then

					-- start receiving

					NextR.Region       <= data;
					NextR.State        <= receive;
					NextR.Counter.BitC <= to_unsigned(7,aBitCCounter'length);
					NextR.Counter.Byte <= to_unsigned(0, aByteCounter'length);
					NextR.WordInvalid  <= cActivated;

					-- which response is expected?
					if (iSdDataFromController.DataMode = widewidth) then
						if (iSdDataFromController.ExpectBits = ScrBits) then
							NextR.Counter.Word <= to_unsigned(cScrBitsCount, aWordCounter'length);
						elsif (iSdDataFromController.ExpectBits = SwitchFunctionBits) then 
							NextR.Counter.Word <= to_unsigned(cSwitchFunctionBitsCount, aWordCounter'length);
						end if;
					else
						NextR.Counter.Word <= to_unsigned(0, aWordCounter'length);
					end if;

			elsif (iSdDataFromController.Valid = cActivated) then

				case iReadWriteFifo.rdempty is
					when cActivated => 
						report "Fifo empty, waiting for data" severity note;
						NextR.DisableSdClk <= cActivated;

					when cInactivated => 
						-- start sending
						NextR.State               <= send;
						NextR.Region              <= startbit;
						NextR.ReadWriteFifo.rdreq <= cActivated;
						NextR.DisableSdClk        <= cInactivated;
						NextR.Counter.BitC        <= to_unsigned(7, aBitCCounter'length);
						NextR.Counter.Byte        <= to_unsigned(0, aByteCounter'length);
						NextR.Counter.Word        <= to_unsigned(0, aWordCounter'length);

					when others => 
						report "rdempty invalid" severity error;
				end case;
			else
				-- switch between standard and wide mode	
				NextR.Mode <= iSdDataFromController.Mode; 
			end if;

		when send =>

			-- Handle the data enable signal
			case R.Mode is
				when wide => 
					NextR.Data.En <= (others => cActivated);

				when standard => 
					NextR.Data.En <= "0001";

				when others => 
					report "Invalid mode" severity error;
					NextR.Data.En <= (others => 'X');
			end case;

			case R.Region is
				when startbit => 
					SendBitsAndShiftIntoCrc(cSdStartBits);
					NextR.Region <= data;

					-- save data from fifo
					NextR.Word <= iReadWriteFifo.q;

				when data => 
					case R.Mode is
						when wide => 
							for i in 0 to 3 loop
								temp(i) := R.Word(CalcBitAddrInWord(R.Counter.Byte, R.Counter.BitC - i));
							end loop;
						
						when standard => 
							temp := "111" & R.Word(CalcBitAddrInWord(R.Counter.Byte, R.Counter.BitC));

						when others => 
							temp := "XXXX";
							report "Invalid SdData mode!" severity error;
					end case;
							
					SendBitsAndShiftIntoCrc(temp);
					CalcNextAndHandleData(true);							

				when crc => 
					NextR.Data.Data <= CrcIn.Serial;

					if (R.Counter.Word = 15) then
						-- all crc bits sent
						NextR.Counter.Word    <= to_unsigned(0, aWordCounter'length);
						NextR.Region         <= endbit;
						NextR.Controller.Ack <= cActivated;

					else
						NextR.Counter.Word <= R.Counter.Word + 1;
					end if;

				when endbit => 
					NextR.Data.Data <= cSdEndBits;
					NextR.State     <= idle;

				when others => 
					report "Region not handled" severity error;
			end case;	

		when receive => 
			case R.Region is
				when data => 
					-- save received data to temporary word register
					case R.Mode is
						when standard => 
							NextR.Word(CalcBitAddrInWord(R.Counter.Byte, R.Counter.BitC)) <= iData.Data(0);

						when wide => 
							for idx in 0 to 3 loop
								NextR.Word(CalcBitAddrInWord(R.Counter.Byte, R.Counter.BitC - idx)) <= iData.Data(3 - idx);
							end loop;

						when others => 
							report "Unhandled mode" severity error;
					end case;	

					ShiftIntoCrc(std_ulogic_vector(iData.Data));
					CalcNextAndHandleData(false);

					-- check responses 
					if (iSdDataFromController.DataMode = widewidth) then
						if (iSdDataFromController.ExpectBits = ScrBits) then
							if (IsBitAddrInRangeWideWidth(cWideModeBitAddr, R.Counter, R.Mode)) then
								NextR.Controller.WideMode <= GetBitFromData(cWideModeBitAddr);
							end if;
						end if;

						if (iSdDataFromController.ExpectBits = SwitchFunctionBits) then
							if (IsBitAddrInRangeWideWidth(cHighSpeedBitAddr, R.Counter, R.Mode)) then
								NextR.Controller.SpeedBits.HighSpeedSupported <= GetBitFromData(cHighSpeedBitAddr);
							elsif (IsBitAddrInRangeWideWidth(cSwitchFunctionBitLowAddr, R.Counter, R.Mode)) then
								NextR.Controller.SpeedBits.SwitchFunctionOK <= iData.Data;
							end if;
						end if;
					end if;

				when crc =>
					if iSdDataFromController.DataMode = usual then
						-- save last word to ram
						-- TODO: handle full fifo
						NextR.WriteReadFifo.wrreq <= cActivated;
						NextR.WriteReadFifo.data  <= R.Word;
					end if;

					-- shift received crc into crc
					case R.Mode is
						when standard => 
							ShiftIntoCrc("000" & iData.Data(0));

						when wide => 
							ShiftIntoCrc(std_ulogic_vector(iData.Data));

						when others => 
							report "Unhandled mode" severity error;
					end case;

					if (R.Counter.Word = 15) then
						-- all 16 crc bits received
						NextR.Region <= endbit;
					else
						NextR.Counter.Word <= R.Counter.Word + 1;
					end if;

				when endbit => 
					if (CrcIn.Correct = "1111" and R.Mode = wide) or
					(CrcIn.Correct(0) = cActivated and R.Mode = standard) then
						NextR.Controller.Valid <= cActivated;

					else
						-- CRC error
						report "CRC error occurred" severity note;
						NextR.Controller.Err <= cActivated;
					end if;

					NextR.Region <= startbit;
					NextR.State  <= idle;

				when others => 
					report "Region not handled" severity error;
			end case;

		when others => 
			report "State not handled" severity error;
	end case;

end process Comb;

CrcDataIn <= (others => CrcOut.DataIn) when R.Mode = wide else
			 "000" & CrcOut.DataIn;

crcs: for idx in 3 downto 0 generate

	CRC_inst : entity work.Crc
	generic map (
		gPolynom => crc16
	)
	port map (
		iClk         => iClk,
		inResetAsync => inResetAsync,
		iStrobe      => iStrobe,
		iClear       => CrcOut.Clear,
		iDataIn      => CrcDataIn(idx),
		iData        => CrcOut.Data(idx),
		oIsCorrect   => CrcIn.Correct(idx),
		oSerial      => CrcIn.Serial(idx)
	);

end generate crcs;

end architecture Rtl;

