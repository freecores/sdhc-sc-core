--
-- Title: SdController
-- File: SdController-Rtl-a.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: Main statemachine for a SDHC compatible SD Controller
-- Simplified Physical Layer Spec. 2.00
--

architecture Rtl of SdController is

	type aSdControllerState is (startup, init, config, idle, invalidCard);
	type aCmdRegion is (CMD0, CMD8, ACMD41, CMD2, CMD3, SelectCard, CheckBusWidth, SetBusWidth, CheckSpeed);
	type aRegion is (idle, send, response, waitstate, senddata, receivedata, checkbusy, waitstatedata);
	
	constant cDefaultToSdCmd : aSdCmdFromController := (
	(id       => (others        => '0'),
	arg       => (others        => '0')),
	Valid     => cInactivated,
	ExpectCID => cInactivated,
	CheckCrc  => cActivated);

	type aSdControllerReg is record
		State      : aSdControllerState;
		CmdRegion  : aCmdRegion;
		Region     : aRegion;
		SendCMD55  : std_ulogic;
		SentCMD55  : std_ulogic;
		HCS        : std_ulogic;
		CCS        : std_ulogic;
		RCA        : aSdRCA;
		CardStatus : aSdCardStatus;
		ToSdCmd    : aSdCmdFromController;
		ToSdData   : aSdDataFromController;
	end record aSdControllerReg;

	constant cDefaultSdControllerReg : aSdControllerReg := (
	State      => startup,
	CmdRegion  => CMD0,
	Region     => idle,
	SendCMD55  => cInactivated,
	SentCMD55  => cInactivated,
	HCS        => cActivated,
	CCS        => cInactivated,
	RCA        => cDefaultRCA,
	CardStatus => cDefaultSdCardStatus,
	ToSdCmd    => cDefaultToSdCmd,
	ToSdData   => cDefaultSdDataFromController);

	signal R, NextR       : aSdControllerReg;
	signal TimeoutEnable  : std_ulogic;
	signal TimeoutDisable : std_ulogic;
	signal Timeout        : std_ulogic;

	signal NextCmdTimeout       : std_ulogic;
	signal NextCmdTimeoutEnable : std_ulogic;

begin

	oSdRegisters.CardStatus <= R.CardStatus;
	oSdCmd                  <= R.ToSdCmd;
	oSdData                 <= R.ToSdData;

	Regs : process (iClk, inResetAsync)
	begin
		if (inResetAsync = cnActivated) then
			R <= cDefaultSdControllerReg;
		elsif (iClk'event and iClk = cActivated) then
			R <= NextR;
		end if;
	end process Regs;

	Comb : process (iSdCmd, iSdData, Timeout, NextCmdTimeout, R)
		variable ocr           : aSdRegOCR;
		variable arg           : aSdCmdArg;
		variable NextRegion    : aRegion;
		variable NextCmdRegion : aCmdRegion;
		variable NextState     : aSdControllerState;
	begin
		-- default assignments
		NextR                <= R;
		NextR.ToSdCmd        <= cDefaultToSdCmd;
		TimeoutEnable        <= cInactivated;
		TimeoutDisable       <= cInactivated;
		NextCmdTimeoutEnable <= cInactivated;
		NextRegion           := R.Region;
		NextCmdRegion        := R.CmdRegion;
		NextState            := R.State;

		-- Status
		oLedBank    <= (others => cInactivated);
		if (R.ToSdData.Mode = wide) then
			oLedBank(5) <= cActivated;
		else
			oLedBank(5) <= cInactivated;
		end if;

		case R.State is
			when startup => 
				TimeoutEnable <= cActivated;
				
				if (Timeout = cActivated) then
					TimeoutEnable <= cInactivated;
					NextR.State   <= init;
					NextR.Region  <= send;
				end if;

			when init => 
				case R.CmdRegion is
					when CMD0 => 
						case R.Region is
							when send => 
								NextR.ToSdCmd.Content.id <= cSdCmdGoIdleState;
								NextR.CardStatus         <= cDefaultSdCardStatus;
								NextRegion               := waitstate;

							when waitstate => 
								NextRegion    := send;
								NextCmdRegion := CMD8;

							when others => 
								report "SdController: Unhandled state" severity error;
						end case;

					when CMD8 => 
						case R.Region is
							when send => 
								NextR.ToSdCmd.Content.id  <= cSdCmdSendIfCond;
								NextR.ToSdCmd.Content.arg <= cSdArgVoltage;
								NextRegion                := response;

							when response => 
								if (iSdCmd.Valid = cActivated) then
									if (iSdCmd.Content.id = cSdCmdSendIfCond and iSdCmd.Content.arg = cSdArgVoltage) then
										NextR.Region <= waitstate;
										NextR.HCS    <= cActivated;

									else
										NextR.State <= invalidCard;
									end if;
								elsif (Timeout = cActivated) then
									NextR.HCS       <= cInactivated;
									NextR.CmdRegion <= ACMD41;
									NextR.Region    <= send;
									NextR.SendCMD55 <= cActivated;
								end if;

							when waitstate => 
								NextCmdRegion   := ACMD41;
								NextRegion      := send;
								NextR.SendCMD55 <= cActivated;

							when others => 
								report "SdController: Unhandled state" severity error;
						end case;

					when ACMD41 => 
						if (R.SendCMD55 = cInactivated) then
							oLedBank(2) <= cActivated;

							case R.Region is
								when send => 
									ocr.nBusy                 := '0';
									ocr.ccs                   := R.HCS;
									ocr.voltagewindow         := cVoltageWindow;
									NextR.ToSdCmd.Content.id  <= cSdCmdACMD41;
									NextR.ToSdCmd.Content.arg <= OCRToArg(ocr);
									NextRegion                := response;

								when response => 
									NextR.ToSdCmd.CheckCrc <= cInactivated;

									if (iSdCmd.Valid = cActivated) then
										NextR.CmdRegion <= CMD8;
										NextR.Region    <= waitstate;

										if (iSdCmd.Content.id = cSdR3Id) then
											ocr := ArgToOcr(iSdCmd.Content.arg);

											if (ocr.nBusy = cnInactivated) then
												if (ocr.voltagewindow /= cVoltageWindow) then
													NextR.State <= invalidCard;
												else
													NextR.CCS       <= ocr.ccs;
													NextR.CmdRegion <= ACMD41;
													NextR.Region    <= waitstate;
												end if;
											end if;
										end if;
									elsif (Timeout = cActivated) then
										NextR.State <= invalidCard;
									end if;
							
								when waitstate => 
									NextCmdRegion := CMD2;
									NextRegion    := send;


								when others => 
									report "SdController: Unhandled state" severity error;
							end case;
						end if;

					when CMD2 => 
						case R.Region is
							when send => 
								NextR.ToSdCmd.Content.id <= cSdCmdAllSendCID;
								NextR.ToSdCmd.Valid      <= cActivated;

								NextRegion := response;

							when response => 
								NextR.ToSdCmd.ExpectCID <= cActivated;

								if (iSdCmd.Valid = cActivated) then
									NextR.State <= invalidCard;

									if (iSdCmd.Content.id = cSdR2Id) then 
										NextR.State     <= init;
										NextR.Region    <= waitstate;
									end if;
								elsif (Timeout = cActivated) then
									NextR.State <= invalidCard;
								end if;
							
							when waitstate => 
								NextCmdRegion := CMD3;
								NextRegion    := send;

							when others => 
								report "SdController: Unhandled state" severity error;
						end case;

					when CMD3 => 
						case R.Region is
							when send => 
								NextR.ToSdCmd.Content.id <= cSdCmdSendRelAdr;
								NextR.ToSdCmd.Valid      <= cActivated;
								NextRegion               := response;

							when response => 
								if (iSdCmd.Valid = cActivated) then
									if (iSdCmd.Content.id = cSdCmdSendRelAdr) then
										NextR.RCA    <= iSdCmd.Content.arg(31 downto 16);
										NextR.Region <= waitstate;
									end if;
								elsif (Timeout = cActivated) then
									NextR.State <= invalidCard;
								end if;

							when waitstate => 
									NextState     := config;
									NextCmdRegion := SelectCard;
									NextRegion    := send;

							when others => 
								report "SdController: Unhandled state" severity error;
						end case;

					when others => 
						report "SdController: Unhandled state" severity error;
				end case;

			when config => 
				oLedBank(3) <= cActivated;

				case R.CmdRegion is
					when SelectCard => 
						case R.Region is
							when send => 
								NextR.ToSdCmd.Content.id  <= cSdCmdSelCard;
								NextR.ToSdCmd.Content.arg <= R.RCA & X"0000";
								NextRegion                := response;

							when response => -- Response R1b: with busy!
								if (iSdCmd.Valid = cActivated) then
									if (iSdCmd.Content.id = cSdCmdSelCard) then
										NextR.CardStatus <= iSdCmd.Content.arg;

										if (iSdCmd.Content.arg(cSdStatusReadyForDataBit) = cActivated) then
											NextR.Region <= waitstatedata;
										else
											NextR.Region <= waitstate;
										end if;

									else
										NextR.State <= invalidCard;
									end if;

								elsif (Timeout = cActivated) then
									NextR.State <= invalidCard;
								end if;

							when waitstate => 
								NextRegion := checkbusy;

							when waitstatedata => 
								NextR.SendCMD55 <= cActivated;
								NextCmdRegion   := CheckBusWidth;
								NextRegion      := send;

							when others => 
								report "Unhandled Region" severity error;
						end case;

					when CheckBusWidth => 
						if (R.SendCMD55 = cInactivated) then
							NextR.ToSdData.DataMode <= widewidth;
							NextR.ToSdData.ExpectBits <= ScrBits;

							case R.Region is
								when send => 
									NextR.ToSdCmd.Content.id  <= cSdCmdSendSCR;
									NextR.ToSdCmd.Content.arg <= (others => '0'); -- stuff bits
									NextRegion                := response;

								when response => 
									if (iSdCmd.Valid = cActivated) then
										if (iSdCmd.Content.id = cSdCmdSendSCR) then
											NextR.CardStatus <= iSdCmd.Content.arg;
											NextR.Region     <= receivedata;
											TimeoutDisable   <= cActivated;

										else
											NextR.State <= invalidCard;
										end if;
									elsif (Timeout = cActivated) then
										NextR.State <= invalidCard;
									end if;

								when receivedata => 
									if (iSdData.Err = cActivated) then
										NextR.State <= init;

									elsif (iSdData.Valid = cActivated) then
										NextR.Region <= waitstatedata;

									elsif (Timeout = cActivated) then
										NextR.State <= invalidCard;
									end if;

								when waitstatedata => 
										NextRegion := send;
										
										if (NextCmdTimeout = cActivated) then
											if (iSdData.DataBlock(cSdWideModeBit) = cActivated) then
												NextCmdRegion   := SetBusWidth;
												NextR.SendCMD55 <= cActivated;

											else 
												NextCmdRegion := CheckSpeed;
											end if;
										end if;


								when others => 
									report "Unhandled region" severity error;
							end case;
						end if;

					when SetBusWidth => 
						oLedBank(4) <= cActivated;

						if (R.SendCMD55 = cInactivated) then
							case R.Region is
								when send => 
									NextR.ToSdCmd.Content.id              <= cSdCmdSetBusWidth;
									NextR.ToSdCmd.Content.arg(1 downto 0) <= cSdWideBusWidth;
									NextRegion                            := response;

								when response => 
									if (iSdCmd.Valid = cActivated) then
										if (iSdCmd.Content.id = cSdCmdSetBusWidth) then
											NextR.CardStatus <= iSdCmd.Content.arg;
											NextR.Region <= waitstate;
											
										else
											NextR.State <= invalidCard;
										end if;
									elsif (Timeout = cActivated) then
										NextR.State <= invalidCard;
									end if;

								when waitstate => 
									NextRegion          := send;
									NextCmdRegion       := CheckSpeed;
									NextR.ToSdData.Mode <= wide;

								when others => 
									report "Unhandled region" severity error;
							end case;
						end if;

					when CheckSpeed => 
						NextR.State <= idle;

					when others => 
						report "Unhandled CmdRegion" severity error;
				end case;

			when idle => 
				oLedBank(6) <= cActivated;

			when invalidCard => 
				oLedBank(7) <= cActivated;

			when others => 
				report "SdController: Unhandled state" severity error;
		end case;

		case R.Region is
			when idle => -- do nothing
				null;

			when send => 
				NextR.ToSdCmd.Valid <= cActivated;

				if (R.SendCMD55 = cActivated) then
					NextR.ToSdCmd.Content.id  <= cSdNextIsACMD;
					NextR.ToSdCmd.Content.arg <= R.RCA & X"0000";
					NextRegion                := response;
				end if;

				if (iSdCmd.Ack = cActivated) then
					NextR.ToSdCmd.Valid <= cInactivated;
					NextR.Region        <= NextRegion;
				end if;

			when response => 
				oLedBank(0)   <= cActivated;
				TimeoutEnable <= cActivated;

				if (R.SendCMD55 = cActivated) then
					if (iSdCmd.Valid = cActivated) then
						if (iSdCmd.Content.id = cSdNextIsACMD) then
							NextR.CardStatus <= iSdCmd.Content.arg;
							NextR.Region <= waitstate;

							if (iSdCmd.Content.arg(cSdArgAppCmdPos) = cActivated) then
								NextR.SentCMD55 <= cActivated;
							end if;
						else 
							NextR.State <= invalidCard;
						end if;
					elsif (Timeout = cActivated) then
						NextR.State <= invalidCard;
					end if;
				end if;

			when waitstate => 
				NextCmdTimeoutEnable <= cActivated;

				if (NextCmdTimeout = cActivated) then
					if (R.SentCMD55 = cActivated) then
						NextR.SentCMD55 <= cInactivated;
						NextR.SendCMD55 <= cInactivated;
						NextRegion := send;
					end if;

					NextCmdTimeoutEnable <= cInactivated;
					NextR.Region         <= NextRegion;
					NextR.CmdRegion      <= NextCmdRegion;
					NextR.State			 <= NextState;
				end if;

			when checkbusy => 
				null;

			when receivedata => 
				TimeoutEnable <= cActivated;

			when waitstatedata => 
				NextCmdTimeoutEnable <= cActivated;
				
				if (NextCmdTimeout = cActivated) then
					NextCmdTimeoutEnable <= cInactivated;
					NextR.Region         <= NextRegion;
					NextR.CmdRegion      <= NextCmdRegion;
					NextR.State			 <= NextState;
				end if;

			when others => 
				report "Unhandled region" severity error;
		end case;
	end process Comb;

	TimeoutGenerator_inst: entity work.TimeoutGenerator
	generic map (
		gClkFrequency => 25E6,
		gTimeoutTime  => 100 ms
	)
	port map (
		iClk => iClk,
		inResetAsync => inResetAsync,
		iEnable => TimeoutEnable,
		iDisable => TimeoutDisable,
		oTimeout => Timeout);

	NextCmdTimeoutGenerator_inst: entity work.TimeoutGenerator
	generic map (
		gClkFrequency => 25E6,
		gTimeoutTime  => 600 us--1 sec / 25E6 * (8)
	)
	port map (
		iClk => iClk,
		inResetAsync => inResetAsync,
		iEnable => NextCmdTimeoutEnable,
		iDisable => cInactivated,
		oTimeout => NextCmdTimeout);

end architecture Rtl;

