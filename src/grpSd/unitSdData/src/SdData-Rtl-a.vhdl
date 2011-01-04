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

	subtype aBlockCounter is unsigned(LogDualis(128)-1 downto 0);
	subtype aWordCounter is unsigned(LogDualis(4)-1 downto 0);
	subtype aByteCounter is unsigned(LogDualis(8)-1 downto 0);

	type aReg is record
		State         : aState;
		Region        : aRegion;
		BlockCounter  : aBlockCounter;
		ByteCounter   : aByteCounter;
		WordCounter   : aWordCounter;
		FirstSend     : std_ulogic;
		Data          : aoSdData;
		Controller    : aSdDataToController;
		ReadWriteFifo : aoReadFifo;
		WriteReadFifo : aoWriteFifo;
		Mode          : aSdDataBusMode;
		Word          : aWord;
		DisableSdClk  : std_ulogic;
	end record aReg;

	constant cDefaultReg : aReg := (
	State         => idle,
	Region        => startbit,
	BlockCounter  => to_unsigned(0, aBlockCounter'length),
	WordCounter   => to_unsigned(0, aWordCounter'length),
	ByteCounter   => to_unsigned(7, aByteCounter'length),
	FirstSend     => cInactivated,
	Data          => (Data                                 => "0000", En => "0000"),
	Controller    => cDefaultSdDataToController,
	ReadWriteFifo => cDefaultoReadFifo,
	WriteReadFifo => cDefaultoWriteFifo,
	Mode          => standard,
	Word          => (others                               => '0'),
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

	constant cSdStartBits : std_ulogic_vector(3 downto 0) := (others => cSdStartBit);
	constant cSdEndBits   : std_ulogic_vector(3 downto 0) := (others => cSdEndBit);

begin

	oData <= R.Data;

	CrcDataIn <= (others => CrcOut.DataIn) when R.Mode = wide else
				 "000" & CrcOut.DataIn;

	oSdDataToController <= R.Controller;
	oReadWriteFifo      <= R.ReadWriteFifo;
	oWriteReadFifo      <= R.WriteReadFifo;
	oDisableSdClk       <= R.DisableSdClk;

	Regs : process (iClk, inResetAsync)
	begin
		if (inResetAsync = cnActivated) then
			R <= cDefaultReg;
		elsif (iClk'event and iClk = cActivated) then
			if (iStrobe = cActivated) then
				R <= NextR;
			end if;
			R.ReadWriteFifo.rdreq <= NextR.ReadWriteFifo.rdreq and iStrobe;
			R.WriteReadFifo.wrreq <= NextR.WriteReadFifo.wrreq and iStrobe;
			R.DisableSdClk   <= NextR.DisableSdClk;
		end if;
	end process Regs;

	Comb : process (iData.Data, iSdDataFromController, CrcIn, iReadWriteFifo, iWriteReadFifo, R)

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

		procedure NextCounterAndSaveToRamWide(constant byteend : natural; constant bytedec : natural) is
		begin

			if (R.ByteCounter = byteend) then
				NextR.ByteCounter <= to_unsigned(7, aByteCounter'length);

				if (R.WordCounter = 0) then
					NextR.WordCounter <= to_unsigned(3, aWordCounter'length);

					-- save word to ram
					-- NextR.WriteReadFifo.wrreq <= cActivated;

					if (R.BlockCounter = 0) then
						NextR.Region <= crc;
					else 
						NextR.BlockCounter <= R.BlockCounter - 1;
					end if;
				else
					NextR.WordCounter <= R.WordCounter - 1;
				end if;
			else
				NextR.ByteCounter <= R.ByteCounter - bytedec;
			end if;

		end procedure NextCounterAndSaveToRamWide;

		procedure NextCounterAndSaveToRamUsual(constant byteend : natural; constant bytedec : natural) is
		begin
			if (R.WordCounter = 0 and R.ByteCounter = 7 and R.FirstSend = cInactivated) then
				-- save word to ram
				NextR.WriteReadFifo.wrreq <= cActivated;
				NextR.WriteReadFifo.data  <= R.Word;
			end if;

			if (R.ByteCounter = byteend) then
				NextR.ByteCounter <= to_unsigned(7, aByteCounter'length);

				if (R.WordCounter = 3) then
					NextR.WordCounter <= to_unsigned(0, aWordCounter'length);
					NextR.FirstSend   <= cInactivated;
					
					if (R.BlockCounter = 127) then
						NextR.BlockCounter <= to_unsigned(0, aBlockCounter'length);
						NextR.Region <= crc;
					else 
						NextR.BlockCounter <= R.BlockCounter + 1;
					end if;
				else
					NextR.WordCounter <= R.WordCounter + 1;
				end if;
			else
				NextR.ByteCounter <= R.ByteCounter - bytedec;
			end if;

		end procedure NextCounterAndSaveToRamUsual;

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
				if (iSdDataFromController.CheckBusy = cActivated and iData.Data(0) = cInactivated) then
					NextR.Controller.Busy <= cActivated;

				elsif (R.Mode = wide and iData.Data = cSdStartBits) or
				(R.Mode = standard and iData.Data(0) = cSdStartBit) then
					NextR.Region      <= data;
					NextR.State       <= receive;
					NextR.ByteCounter <= to_unsigned(7,aByteCounter'length);
					NextR.FirstSend   <= cActivated;

					if (iSdDataFromController.DataMode = widewidth) then
						NextR.WordCounter <= to_unsigned(3,aWordCounter'length);

						if (iSdDataFromController.ExpectBits = ScrBits) then
							NextR.BlockCounter <= to_unsigned(1, aBlockCounter'length);
						elsif (iSdDataFromController.ExpectBits = SwitchFunctionBits) then 
							NextR.BlockCounter <= to_unsigned(15, aBlockCounter'length);
						end if;
					else
						NextR.BlockCounter <= to_unsigned(0, aBlockCounter'length);
						NextR.WordCounter  <= to_unsigned(0,aWordCounter'length);

					end if;

			elsif (iSdDataFromController.Valid = cActivated) then
				case iReadWriteFifo.rdempty is
					when cActivated => 
						report "Fifo empty, waiting for data" severity note;
						NextR.DisableSdClk <= cActivated;

					when cInactivated => 
						NextR.State          <= send;
						NextR.Region         <= startbit;
						NextR.ReadWriteFifo.rdreq <= cActivated;
						NextR.DisableSdClk   <= cInactivated;
						NextR.WordCounter    <= to_unsigned(0, aWordCounter'length);

					when others => 
						report "rdempty invalid" severity error;
				end case;
			else 
				NextR.Mode <= iSdDataFromController.Mode; 
			end if;

		when send =>
			case R.Mode is
				when wide => 
					NextR.Data.En <= (others => cActivated);

				when standard => 
					NextR.Data.En <= "0001";

				when others => 
					report "Invalid mode" severity error;
			end case;

			case R.Region is
				when startbit => 
					SendBitAndShiftIntoCrc(cSdStartBits);
					NextR.Region <= data;

					-- save data from fifo
					NextR.Word <= iReadWriteFifo.q;

				when data => 
					case R.Mode is
						when wide => 
							for i in 0 to 3 loop
								temp(i) := R.Word(CalcBitAddrInWord(R.WordCounter, R.ByteCounter - i));
							end loop;
							SendBitAndShiftIntoCrc(temp);

							if (R.ByteCounter = 3) then
								NextR.ByteCounter <= to_unsigned(7, aByteCounter'length);

								if (R.WordCounter = 3) then
									NextR.WordCounter <= to_unsigned(0, aWordCounter'length);

									if (R.BlockCounter = 127) then
										NextR.Region       <= crc;
										NextR.BlockCounter <= to_unsigned(0, aBlockCounter'length);

									else
										NextR.BlockCounter   <= R.BlockCounter + 1;

										-- save data
										NextR.Word <= iReadWriteFifo.q;
									end if;

								else 
									NextR.WordCounter <= R.WordCounter + 1;
								end if;

							else
								NextR.ByteCounter <= R.ByteCounter - 4;
							end if;

							if ((R.ByteCounter = 7 and R.WordCounter = 3 and R.BlockCounter < 127)) then
								-- handle rdempty
								if (iReadWriteFifo.rdempty = cActivated) then
									report "No data available, fifo empty, waiting for new data" severity note;
									NextR.DisableSdClk <= cActivated;
									NextR.ByteCounter  <= R.ByteCounter;

								else
									-- request new data from fifo
									NextR.DisableSdClk <= cInactivated;
									NextR.ReadWriteFifo.rdreq <= cActivated;
								end if;
							end if;


						when standard => 
							temp := "111" & R.Word(CalcBitAddrInWord(R.WordCounter, R.ByteCounter));
							SendBitAndShiftIntoCrc(temp);

							if (R.ByteCounter = 1 and R.WordCounter = 3 and R.BlockCounter < 127) then
								-- handle rdempty
								if (iReadWriteFifo.rdempty = cActivated) then
									report "No data available, fifo empty, waiting for new data" severity note;
									NextR.DisableSdClk <= cActivated;
									NextR.ByteCounter  <= R.ByteCounter;

								else
									-- request new data from fifo
									NextR.ReadWriteFifo.rdreq <= cActivated;
								end if;
							end if;

							if (R.ByteCounter = 0) then
								NextR.ByteCounter <= to_unsigned(7, aByteCounter'length);

								if (R.WordCounter = 3) then
									NextR.WordCounter <= to_unsigned(0, aWordCounter'length);

									if (R.BlockCounter = 127) then
										NextR.Region       <= crc;
										NextR.BlockCounter <= to_unsigned(0, aBlockCounter'length);

									else
										NextR.BlockCounter   <= R.BlockCounter + 1;

										-- save data
										NextR.Word <= iReadWriteFifo.q;
									end if;

								else 
									NextR.WordCounter <= R.WordCounter + 1;
								end if;

							else
								NextR.ByteCounter <= R.ByteCounter - 1;
							end if;

						when others => 
							report "Invalid SdData mode!" severity error;
					end case;

				when crc => 
					NextR.Data.Data <= CrcIn.Serial;

					if (R.BlockCounter = 15) then
						NextR.BlockCounter   <= to_unsigned(0, aBlockCounter'length);
						NextR.Region         <= endbit;
						NextR.Controller.Ack <= cActivated;

					else
						NextR.BlockCounter <= R.BlockCounter + 1;
					end if;

				when endbit => 
					NextR.Data.Data      <= cSdEndBits;
					NextR.State <= idle;

				when others => 
					report "Region not handled" severity error;
			end case;	

		when receive => 
			case R.Region is
				when data => 
					case iSdDataFromController.DataMode is
						when usual => 
							case R.Mode is
								when standard => 
									NextR.Word(CalcBitAddrInWord(R.WordCounter, R.ByteCounter)) <= iData.Data(0);
									ShiftIntoCrc("000" & iData.Data(0));
									NextCounterAndSaveToRamUsual(0,1);

								when wide => 
									for idx in 0 to 3 loop
										NextR.Word(CalcBitAddrInWord(R.WordCounter, R.ByteCounter - idx)) <= iData.Data(3 - idx);
									end loop;

									ShiftIntoCrc(std_ulogic_vector(iData.Data));
									NextCounterAndSaveToRamUsual(3,4);

								when others => 
									report "Unhandled mode" severity error;
							end case;	

						when widewidth => 
							case R.Mode is
								when standard => 
									if (iSdDataFromController.ExpectBits = ScrBits) then
										if (R.BlockCounter = 1 and R.WordCounter = 2 and R.ByteCounter = 2) then
											NextR.Controller.WideMode <= iData.Data(0);
										end if;
									end if;

									--NextR.WriteReadFifo.data(CalcBitAddrInWord(R.WordCounter, R.ByteCounter)) <= iData.Data(0);
									ShiftIntoCrc("000" & iData.Data(0));
									NextCounterAndSaveToRamWide(0, 1);

								when wide => 
									if (iSdDataFromController.ExpectBits = SwitchFunctionBits) then
										if (R.BlockCounter = 12 and R.WordCounter = 2 and R.ByteCounter = 3) then
											NextR.Controller.SpeedBits.HighSpeedSupported <= iData.Data(1);
										elsif (R.BlockCounter = 11 and R.WordCounter = 3 and R.ByteCounter = 3) then
											NextR.Controller.SpeedBits.SwitchFunctionOK <= iData.Data;
										end if;
									end if;

								--	for idx in 0 to 3 loop
								--		NextR.WriteReadFifo.data(CalcBitAddrInWord(R.WordCounter, R.ByteCounter - idx)) <= iData.Data(3 - idx);
								--	end loop;
									ShiftIntoCrc(std_ulogic_vector(iData.Data));
									NextCounterAndSaveToRamWide(3, 4);

								when others => 
									report "Unhandled mode" severity error;
							end case;

						when others => 
							report "Unhandled DataMode" severity error;
					end case;

				when crc =>
					if iSdDataFromController.DataMode = usual then
						-- save last word to ram
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

					-- crc is 16 bit long
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

