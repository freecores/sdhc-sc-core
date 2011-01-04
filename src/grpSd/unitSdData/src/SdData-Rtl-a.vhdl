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

	subtype aByteCounter is unsigned(LogDualis(512)-1 downto 0);
	subtype aBitCounter is unsigned(LogDualis(8)-1 downto 0);

	type aReg is record
		State       : aState;
		Region      : aRegion;
		ByteCounter : aByteCounter;
		BitCounter  : aBitCounter;
		Data        : aDataOutput;
		Enable      : std_ulogic;
		Controller  : aSdDataToController;
		Mode        : aSdDataBusMode;
		Crc         : std_ulogic_vector(15 downto 0);
	end record aReg;

	constant cDefaultReg : aReg := (
	State       => idle,
	Region      => startbit,
	ByteCounter => to_unsigned(0, aByteCounter'length),
	BitCounter  => to_unsigned(7, aBitCounter'length),
	Data        => "0000",
	Enable      => cInactivated,
	Controller  => cDefaultSdDataToController,
	Mode        => standard,
	Crc         => (others                              => '0'));

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

	oCrc <= R.Crc;
	
	oSdDataToController <= R.Controller;

	Regs : process (iClk, inResetAsync)
	begin
		if (inResetAsync = cnActivated) then
			R <= cDefaultReg;
		elsif (iClk'event and iClk = cActivated) then
			R <= NextR;
		end if;
	end process Regs;

	Comb : process (ioData, iSdDataFromController, CrcIn, R)

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

		variable temp : std_ulogic_vector(3 downto 0);

	begin
		NextR                      <= R;
		NextR.Enable               <= cInactivated;
		NextR.Controller.Ack       <= cInactivated;
		NextR.Controller.Receiving <= cInactivated;
		NextR.Controller.Valid     <= cInactivated;
		NextR.Controller.Busy      <= cInactivated;
		NextR.Controller.Err       <= cInactivated;
		CrcOut                     <= cDefaultCrcOut;

		case R.State is
			when idle => 
				if (iSdDataFromController.CheckBusy = cActivated and ioData(0) = cInactivated) then
					NextR.Controller.Busy <= cActivated;

				elsif (R.Mode = wide and ioData = std_logic_vector(cSdStartBits)) or
				(R.Mode = standard and ioData(0) = cSdStartBit) then
					NextR.Region     <= data;
					NextR.State      <= receive;
					NextR.BitCounter <= to_unsigned(7,aBitCounter'length);

					if (iSdDataFromController.DataMode = widewidth) then
						if (iSdDataFromController.ExpectBits = ScrBits) then
							NextR.ByteCounter <= to_unsigned(63, aByteCounter'length);
						elsif (iSdDataFromController.ExpectBits = SwitchFunctionBits) then 
							NextR.ByteCounter <= to_unsigned(511, aByteCounter'length);
						end if;
					end if;

				elsif (iSdDataFromController.Valid = cActivated) then
					NextR.State  <= send;
					NextR.Region <= startbit;
				else 
					NextR.Mode <= iSdDataFromController.Mode; 
				end if;

			when send =>
				NextR.Enable  <= cActivated;

				case R.Region is
					when startbit => 
						SendBitAndShiftIntoCrc(cSdStartBits);
						NextR.Region <= data;

					when data => 
						case R.Mode is
							when wide => 
								for idx in 3 downto 0 loop
									temp(idx) := iSdDataFromController.DataBlock(to_integer(R.ByteCounter * 8 + R.BitCounter) - idx);
								end loop;

								SendBitAndShiftIntoCrc(temp);

								if (R.BitCounter = 3) then
									NextR.BitCounter  <= to_unsigned(7, aBitCounter'length);

									if (R.ByteCounter = 511) then
										NextR.ByteCounter <= to_unsigned(0, aByteCounter'length);
										NextR.Region      <= crc;

									else
										NextR.ByteCounter <= R.ByteCounter + 1;
									end if;

								else
									NextR.BitCounter <= R.BitCounter - 4;
								end if;

							when standard => 
								temp := "000" & iSdDataFromController.DataBlock(to_integer(R.ByteCounter * 8 + R.BitCounter));
								SendBitAndShiftIntoCrc(temp);

								if (R.BitCounter = 0) then
									NextR.BitCounter <= to_unsigned(7, aBitCounter'length);

									if (R.ByteCounter = 511) then
										NextR.ByteCounter <= to_unsigned(0, aByteCounter'length);
										NextR.Region <= crc;

									else 
										NextR.ByteCounter <= R.ByteCounter + 1;
									end if;

								else
									NextR.BitCounter <= R.BitCounter - 1;
								end if;

							when others => 
								report "Invalid SdData mode!" severity error;
						end case;

					when crc => 
						NextR.data <= CrcIn.Serial;

						if (R.ByteCounter = 15) then
							NextR.ByteCounter <= to_unsigned(0, aByteCounter'length);
							NextR.Region      <= endbit;

						else
							NextR.ByteCounter <= R.ByteCounter + 1;
						end if;

					when endbit => 
						NextR.Controller.Ack <= cActivated;
						NextR.Data           <= cSdEndBits;
						NextR.State          <= idle;

					when others => 
						report "Region not handled" severity error;
				end case;	

			when receive => 
				case R.Region is
					when data => 
						case iSdDataFromController.DataMode is
							when usual => 
								report "usual mode is not implemented" severity error;

							when widewidth => 
								case R.Mode is
									when standard => 
										NextR.Controller.DataBlock(to_integer(R.ByteCounter)) <= ioData(0);
										ShiftIntoCrc("000" & ioData(0));

										if (R.ByteCounter = 0) then
											NextR.Region <= crc;
										else 
											NextR.ByteCounter <= R.ByteCounter - 1;
										end if;

									when wide => 
										for idx in 0 to 3 loop
											NextR.Controller.DataBlock(to_integer(R.ByteCounter - idx)) <= ioData(3 - idx);
										end loop;
										ShiftIntoCrc(std_ulogic_vector(ioData));

										if (R.ByteCounter = 3) then
											NextR.ByteCounter <= to_unsigned(0, aByteCounter'length);
											NextR.Region <= crc;
										else
											NextR.ByteCounter <= R.ByteCounter - 4;
										end if;

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
								NextR.Crc(to_integer(15 - R.ByteCounter)) <= ioData(0);

							when wide => 
								ShiftIntoCrc(std_ulogic_vector(ioData));

							when others => 
								report "Unhandled mode" severity error;
						end case;


						if (R.ByteCounter = 15) then
							NextR.Region <= endbit;
						else
							NextR.ByteCounter <= R.ByteCounter + 1;
						end if;

					when endbit => 
						if (CrcIn.Correct = "1111" and R.Mode = wide) or
						(CrcIn.Correct(0) = cActivated and R.Mode = standard) then
							NextR.Controller.Valid <= cActivated;

						else
							NextR.Controller.Err <= cActivated;

						end if;

						NextR.ByteCounter <= to_unsigned(0, aByteCounter'length);
						NextR.Region      <= startbit;
						NextR.State       <= idle;

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
			iClear       => CrcOut.Clear,
			iDataIn      => CrcDataIn(idx),
			iData        => CrcOut.Data(idx),
			oIsCorrect   => CrcIn.Correct(idx),
			oSerial      => CrcIn.Serial(idx)
		);

	end generate crcs;

end architecture Rtl;

