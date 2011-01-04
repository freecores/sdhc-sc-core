--
-- Title: Architecure of SdData
-- File: SdData-Rtl-a.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description:  
--

architecture Rtl of SdData is

	type aState is (idle, send, receive);
	type aRegion is (startbit, data, crc, endbit);
	subtype aDataOutput is std_ulogic_vector(3 downto 0);

	subtype aBlockCounter is unsigned(LogDualis(16)-1 downto 0);
	subtype aWordCounter is unsigned(LogDualis(4)-1 downto 0);
	subtype aByteCounter is unsigned(LogDualis(8)-1 downto 0);

	type aReg is record
		State        : aState;
		Region       : aRegion;
		BlockCounter : aBlockCounter;
		ByteCounter  : aByteCounter;
		WordCounter  : aWordCounter;
		FirstSend    : std_ulogic;
		Data         : aDataOutput;
		Enable       : std_ulogic;
		Controller   : aSdDataToController;
		Ram          : aSdDataToRam;
		Mode         : aSdDataBusMode;
	end record aReg;

	constant cDefaultReg : aReg := (
	State        => idle,
	Region       => startbit,
	BlockCounter => to_unsigned(0, aBlockCounter'length),
	WordCounter  => to_unsigned(0, aWordCounter'length),
	ByteCounter  => to_unsigned(7, aByteCounter'length),
	FirstSend  	 => cInactivated,
	Data         => "0000",
	Enable       => cInactivated,
	Controller   => cDefaultSdDataToController,
	Ram          => cDefaultSdDataToRam,
	Mode         => standard);

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

	constant cSdStartBits : std_ulogic_vector(3 downto 0) := (others => cSdStartBit);
	constant cSdEndBits   : std_ulogic_vector(3 downto 0) := (others => cSdEndBit);

begin

	ioData <= "ZZZZ" when R.Enable = cInactivated else 
			  std_logic_vector(R.Data) when R.Mode = wide else
			  "ZZZ" & R.Data(0);

	CrcDataIn <= (others => CrcOut.DataIn) when R.Mode = wide else
				 "000" & CrcOut.DataIn;

	oSdDataToController <= R.Controller;
	oSdDataToRam		<= R.Ram;

	Regs : process (iClk, inResetAsync)
	begin
		if (inResetAsync = cnActivated) then
			R <= cDefaultReg;
		elsif (iClk'event and iClk = cActivated) then
			R <= NextR;
		end if;
	end process Regs;

	Comb : process (ioData, iSdDataFromController, CrcIn, iStrobe, R)

		-- variables for state transition (only when iStrobe is active)
		variable NextState        : aState;
		variable NextRegion       : aRegion;
		variable NextBlockCounter : aBlockCounter;
		variable NextByteCounter  : aByteCounter;
		variable NextWordCounter  : aWordCounter;
		variable NextRamAddr      : aAddr;

		procedure ShiftIntoCrc (constant data : in std_ulogic_vector(3 downto 0)) is
		begin
			CrcOut.Data   <= data;
			CrcOut.DataIn <= cActivated;
		end procedure ShiftIntoCrc;

		procedure SendBitAndShiftIntoCrc (constant data : in std_ulogic_vector(3 downto 0)) is
		begin
			ShiftIntoCrc(data);
			NextR.Data <= data;
		end procedure SendBitAndShiftIntoCrc;

		function CalcBitAddrInWord (constant word : aWordCounter; constant byte : aByteCounter) return integer is
		begin
			return (to_integer(word) * 8) + to_integer(byte);
		end function CalcBitAddrInWord;

		procedure NextCounterAndSaveToRam(constant byteend : natural; constant bytedec : natural) is
		begin
			if (R.ByteCounter = byteend) then
				NextByteCounter := to_unsigned(7, aByteCounter'length);

				if (R.WordCounter = 0) then
					NextWordCounter := to_unsigned(3, aWordCounter'length);
					NextR.FirstSend <= cInactivated;

					-- save word to ram
					NextR.Ram.We <= cActivated;
					NextR.Ram.En <= cActivated;

					if (R.BlockCounter = 0) then
						NextRegion := crc;
					else 
						NextBlockCounter := R.BlockCounter - 1;
					end if;
				else
					if (R.WordCounter = 3 and R.FirstSend = cInactivated) then
						NextRamAddr  := R.Ram.Addr + 1;
					end if;

					NextWordCounter := R.WordCounter - 1;
				end if;
			else
				NextByteCounter := R.ByteCounter - bytedec;
			end if;
	end procedure NextCounterAndSaveToRam;

		variable temp : std_ulogic_vector(3 downto 0);

	begin
		NextR            <= R;
		NextR.Enable     <= cInactivated;
		NextR.Controller <= cDefaultSdDataToController;
		NextR.Ram.We     <= cInactivated;
		NextR.Ram.En     <= cInactivated;
		CrcOut           <= cDefaultCrcOut;
		NextState        := R.State;
		NextRegion       := R.Region;
		NextBlockCounter := R.BlockCounter;
		NextByteCounter  := R.ByteCounter;
		NextWordCounter  := R.WordCounter;
		NextRamAddr      := R.Ram.Addr;

		case R.State is
			when idle => 
				if (iSdDataFromController.CheckBusy = cActivated and ioData(0) = cInactivated) then
					NextR.Controller.Busy <= cActivated;

				elsif (R.Mode = wide and ioData = std_logic_vector(cSdStartBits)) or
				(R.Mode = standard and ioData(0) = cSdStartBit) then
					NextRegion      := data;
					NextState       := receive;
					NextByteCounter := to_unsigned(7,aByteCounter'length);
					NextWordCounter := to_unsigned(3,aWordCounter'length);
					NextRamAddr     := iSdDataFromController.StartAddr;
					NextR.FirstSend <= cActivated;

					if (iSdDataFromController.DataMode = widewidth) then
						if (iSdDataFromController.ExpectBits = ScrBits) then
							NextBlockCounter := to_unsigned(1, aBlockCounter'length);
						elsif (iSdDataFromController.ExpectBits = SwitchFunctionBits) then 
							NextBlockCounter := to_unsigned(15, aBlockCounter'length);
						end if;
					else
						NextBlockCounter := to_unsigned(15, aBlockCounter'length);
					end if;

			elsif (iSdDataFromController.Valid = cActivated) then
				NextState  := send;
				NextRegion := startbit;
			else 
				NextR.Mode <= iSdDataFromController.Mode; 
			end if;

		when send =>
			report "sending not implemented" severity error;
--			NextR.Enable  <= cActivated;
--
--			case R.Region is
--				when startbit => 
--					SendBitAndShiftIntoCrc(cSdStartBits);
--					NextRegion := data;
--
--				when data => 
--					case R.Mode is
--						when wide => 
--							for idx in 3 downto 0 loop
--								temp(idx) := iSdDataFromController.DataBlock(to_integer(R.BlockCounter * 8 + R.ByteCounter) - idx);
--							end loop;
--
--							SendBitAndShiftIntoCrc(temp);
--
--							if (R.ByteCounter = 3) then
--								NextByteCounter := to_unsigned(7, aByteCounter'length);
--
--								if (R.BlockCounter = 511) then
--									NextBlockCounter := to_unsigned(0, aBlockCounter'length);
--									NextRegion      := crc;
--
--								else
--									NextBlockCounter := R.BlockCounter + 1;
--								end if;
--
--							else
--								NextByteCounter := R.ByteCounter - 4;
--							end if;
--
--						when standard => 
--							temp := "000" & iSdDataFromController.DataBlock(to_integer(R.BlockCounter * 8 + R.ByteCounter));
--							SendBitAndShiftIntoCrc(temp);
--
--							if (R.ByteCounter = 0) then
--								NextByteCounter := to_unsigned(7, aByteCounter'length);
--
--								if (R.BlockCounter = 511) then
--									NextBlockCounter := to_unsigned(0, aBlockCounter'length);
--									NextRegion := crc;
--
--								else 
--									NextBlockCounter := R.BlockCounter + 1;
--								end if;
--
--							else
--								NextByteCounter := R.ByteCounter - 1;
--							end if;
--
--						when others => 
--							report "Invalid SdData mode!" severity error;
--					end case;
--
--				when crc => 
--					NextR.data <= CrcIn.Serial;
--
--					if (R.BlockCounter = 15) then
--						NextBlockCounter := to_unsigned(0, aBlockCounter'length);
--						NextRegion      := endbit;
--
--					else
--						NextBlockCounter := R.BlockCounter + 1;
--					end if;
--
--				when endbit => 
--					NextR.Controller.Ack <= cActivated;
--					NextR.Data           <= cSdEndBits;
--					NextState            := idle;
--
--				when others => 
--					report "Region not handled" severity error;
--			end case;	
--
		when receive => 
			case R.Region is
				when data => 
					case iSdDataFromController.DataMode is
						when usual => 
							report "usual mode is not implemented" severity error;

						when widewidth => 
							case R.Mode is
								when standard => 
									NextR.Ram.Data(CalcBitAddrInWord(R.WordCounter, R.ByteCounter)) <= ioData(0);
									ShiftIntoCrc("000" & ioData(0));
									NextCounterAndSaveToRam(0, 1);

								when wide => 
									for idx in 0 to 3 loop
										NextR.Ram.Data(CalcBitAddrInWord(R.WordCounter, R.ByteCounter - idx)) <= ioData(3 - idx);
									end loop;
									ShiftIntoCrc(std_ulogic_vector(ioData));
									NextCounterAndSaveToRam(3, 4);

								when others => 
									report "Unhandled mode" severity error;
							end case;

						when others => 
							report "Unhandled DataMode" severity error;
					end case;

				when crc =>
					case R.Mode is
						when standard => 
							ShiftIntoCrc("000" & ioData(0));

						when wide => 
							ShiftIntoCrc(std_ulogic_vector(ioData));

						when others => 
							report "Unhandled mode" severity error;
					end case;


					if (R.BlockCounter = 15) then
						NextRegion := endbit;
					else
						NextBlockCounter := R.BlockCounter + 1;
					end if;

				when endbit => 
					if (CrcIn.Correct = "1111" and R.Mode = wide) or
					(CrcIn.Correct(0) = cActivated and R.Mode = standard) then
						NextR.Controller.Valid <= cActivated;

					else
						NextR.Controller.Err <= cActivated;

					end if;

					NextBlockCounter := to_unsigned(0, aBlockCounter'length);
					NextRegion      := startbit;
					NextState       := idle;

				when others => 
					report "Region not handled" severity error;
			end case;

		when others => 
			report "State not handled" severity error;
	end case;

	if (iStrobe = cActivated) then
		NextR.State        <= NextState;
		NextR.Region       <= NextRegion;
		NextR.BlockCounter <= NextBlockCounter;
		NextR.ByteCounter  <= NextByteCounter;
		NextR.WordCounter  <= NextWordCounter;
		NextR.Ram.Addr     <= NextRamAddr;
	end if;
end process Comb;

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

