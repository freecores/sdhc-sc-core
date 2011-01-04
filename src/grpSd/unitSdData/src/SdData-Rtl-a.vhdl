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
		Data         : aoSdData;
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
	Data         => (Data => "0000", En => "0000"),
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

	oData <= R.Data;

	CrcDataIn <= (others => CrcOut.DataIn) when R.Mode = wide else
				 "000" & CrcOut.DataIn;

	oSdDataToController <= R.Controller;
	oSdDataToRam		<= R.Ram;

	Regs : process (iClk, inResetAsync)
	begin
		if (inResetAsync = cnActivated) then
			R <= cDefaultReg;
		elsif (iClk'event and iClk = cActivated) then
			if (iStrobe = cActivated) then
				R <= NextR;
			end if;
		end if;
	end process Regs;

	Comb : process (iData.Data, iSdDataFromController, CrcIn, iStrobe, R)

		procedure ShiftIntoCrc (constant data : in std_ulogic_vector(3 downto 0)) is
		begin
			CrcOut.Data   <= data;
			CrcOut.DataIn <= cActivated;
		end procedure ShiftIntoCrc;

		procedure SendBitAndShiftIntoCrc (constant data : in std_ulogic_vector(3 downto 0)) is
		begin
			ShiftIntoCrc(data);
			NextR.Data.Data <= data;
		end procedure SendBitAndShiftIntoCrc;

		function CalcBitAddrInWord (constant word : aWordCounter; constant byte : aByteCounter) return integer is
		begin
			return (to_integer(word) * 8) + to_integer(byte);
		end function CalcBitAddrInWord;

		procedure NextCounterAndSaveToRam(constant byteend : natural; constant bytedec : natural) is
		begin
			if (R.ByteCounter = byteend) then
				NextR.ByteCounter <= to_unsigned(7, aByteCounter'length);

				if (R.WordCounter = 0) then
					NextR.WordCounter <= to_unsigned(3, aWordCounter'length);
					NextR.FirstSend <= cInactivated;

					-- save word to ram
					NextR.Ram.We <= cActivated;
					NextR.Ram.En <= cActivated;

					if (R.BlockCounter = 0) then
						NextR.Region <= crc;
					else 
						NextR.BlockCounter <= R.BlockCounter - 1;
					end if;
				else
					if (R.WordCounter = 3 and R.FirstSend = cInactivated) then
						NextR.Ram.Addr <= R.Ram.Addr + 1;
					end if;

					NextR.WordCounter <= R.WordCounter - 1;
				end if;
			else
				NextR.ByteCounter <= R.ByteCounter - bytedec;
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

		case R.State is
			when idle => 
				if (iSdDataFromController.CheckBusy = cActivated and iData.Data(0) = cInactivated) then
					NextR.Controller.Busy <= cActivated;

				elsif (R.Mode = wide and iData.Data = cSdStartBits) or
				(R.Mode = standard and iData.Data(0) = cSdStartBit) then
					NextR.Region <= data;
					NextR.State <= receive;
					NextR.ByteCounter <= to_unsigned(7,aByteCounter'length);
					NextR.WordCounter <= to_unsigned(3,aWordCounter'length);
					NextR.Ram.Addr <= iSdDataFromController.StartAddr;
					NextR.FirstSend <= cActivated;

					if (iSdDataFromController.DataMode = widewidth) then
						if (iSdDataFromController.ExpectBits = ScrBits) then
							NextR.BlockCounter <= to_unsigned(1, aBlockCounter'length);
						elsif (iSdDataFromController.ExpectBits = SwitchFunctionBits) then 
							NextR.BlockCounter <= to_unsigned(15, aBlockCounter'length);
						end if;
					else
						NextR.BlockCounter <= to_unsigned(15, aBlockCounter'length);
					end if;

			elsif (iSdDataFromController.Valid = cActivated) then
				NextR.State <= send;
				NextR.Region <= startbit;
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
--					NextR.Region <= data;
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
--								NextR.ByteCounter <= to_unsigned(7, aByteCounter'length);
--
--								if (R.BlockCounter = 511) then
--									NextR.BlockCounter <= to_unsigned(0, aBlockCounter'length);
--									NextR.Region <= crc;
--
--								else
--									NextR.BlockCounter <= R.BlockCounter + 1;
--								end if;
--
--							else
--								NextR.ByteCounter <= R.ByteCounter - 4;
--							end if;
--
--						when standard => 
--							temp := "000" & iSdDataFromController.DataBlock(to_integer(R.BlockCounter * 8 + R.ByteCounter));
--							SendBitAndShiftIntoCrc(temp);
--
--							if (R.ByteCounter = 0) then
--								NextR.ByteCounter <= to_unsigned(7, aByteCounter'length);
--
--								if (R.BlockCounter = 511) then
--									NextR.BlockCounter <= to_unsigned(0, aBlockCounter'length);
--									NextR.Region <= crc;
--
--								else 
--									NextR.BlockCounter <= R.BlockCounter + 1;
--								end if;
--
--							else
--								NextR.ByteCounter <= R.ByteCounter - 1;
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
--						NextR.BlockCounter <= to_unsigned(0, aBlockCounter'length);
--						NextR.Region <= endbit;
--
--					else
--						NextR.BlockCounter <= R.BlockCounter + 1;
--					end if;
--
--				when endbit => 
--					NextR.Controller.Ack <= cActivated;
--					NextR.Data           <= cSdEndBits;
--					NextR.State <= idle;
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
									NextR.Ram.Data(CalcBitAddrInWord(R.WordCounter, R.ByteCounter)) <= iData.Data(0);
									ShiftIntoCrc("000" & iData.Data(0));
									NextCounterAndSaveToRam(0, 1);

								when wide => 
									for idx in 0 to 3 loop
										NextR.Ram.Data(CalcBitAddrInWord(R.WordCounter, R.ByteCounter - idx)) <= iData.Data(3 - idx);
									end loop;
									ShiftIntoCrc(std_ulogic_vector(iData.Data));
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
							ShiftIntoCrc("000" & iData.Data(0));

						when wide => 
							ShiftIntoCrc(std_ulogic_vector(iData.Data));

						when others => 
							report "Unhandled mode" severity error;
					end case;


					if (R.BlockCounter = 15) then
						NextR.Region <= endbit;
					else
						NextR.BlockCounter <= R.BlockCounter + 1;
					end if;

				when endbit => 
					if (CrcIn.Correct = "1111" and R.Mode = wide) or
					(CrcIn.Correct(0) = cActivated and R.Mode = standard) then
						NextR.Controller.Valid <= cActivated;

					else
						NextR.Controller.Err <= cActivated;

					end if;

					NextR.BlockCounter <= to_unsigned(0, aBlockCounter'length);
					NextR.Region <= startbit;
					NextR.State <= idle;

				when others => 
					report "Region not handled" severity error;
			end case;

		when others => 
			report "State not handled" severity error;
	end case;

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

