-------------------------------------------------
-- file: SdController-Rtl-ea.vhdl
-- author: Rainer Kastl
--
-- Main statemachine for a SDHC compatible SD Controller
-- Simplified Physical Layer Spec. 2.00
-------------------------------------------------

architecture Rtl of SdController is

	type aSdControllerState is (startup, init, config, idle, invalidCard);
	type aCmdRegion is (CMD0, CMD8, CMD55, ACMD41, CMD2, CMD3, SelectCard);
	type aRegion is (idle, send, receive, waitstate);
	
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
	HCS        => cActivated,
	CCS        => cInactivated,
	RCA        => cDefaultRCA,
	CardStatus => cDefaultSdCardStatus,
	ToSdCmd    => cDefaultToSdCmd,
	ToSdData   => cDefaultSdDataFromController);

	signal R, NextR      : aSdControllerReg;
	signal TimeoutEnable : std_ulogic;
	signal Timeout       : std_ulogic;

	signal NextCmdTimeout       : std_ulogic;
	signal NextCmdTimeoutEnable : std_ulogic;

begin

	oSdRegisters.CardStatus <= R.CardStatus;
	oSdCmd <= R.ToSdCmd;
	oSdData <= R.ToSdData;

	Regs : process (iClk, inResetAsync)
	begin
		if (inResetAsync = cnActivated) then
			R <= cDefaultSdControllerReg;
		elsif (iClk'event and iClk = cActivated) then
			R <= NextR;
		end if;
	end process Regs;

	Comb : process (iSdCmd, Timeout, NextCmdTimeout, R)
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
		NextCmdTimeoutEnable <= cInactivated;

		-- variables
		NextRegion    := R.Region;
		NextCmdRegion := R.CmdRegion;
		NextState     := R.State;

		-- Status
		oLedBank <= (others => cInactivated);

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
								NextRegion                := receive;

							when receive => 
								if (iSdCmd.Valid = cActivated) then
									if (iSdCmd.Content.id = cSdCmdSendIfCond and iSdCmd.Content.arg = cSdArgVoltage) then
										NextR.Region <= waitstate;
										NextR.HCS    <= cActivated;

									else
										NextR.State <= invalidCard;
									end if;
								elsif (Timeout = cActivated) then
									NextR.HCS       <= cInactivated;
									NextR.CmdRegion <= CMD55;
									NextR.Region    <= send;
								end if;

							when waitstate => 
								NextCmdRegion      := CMD55;
								NextRegion         := send;

							when others => 
								report "SdController: Unhandled state" severity error;
						end case;

					when CMD55 => 
						oLedBank(1) <= cActivated;
						NextCmdRegion := ACMD41;

					when ACMD41 => 
						oLedBank(2) <= cActivated;
						
						case R.Region is
							when send => 
								ocr.nBusy         := '0';
								ocr.ccs           := R.HCS;
								ocr.voltagewindow := cVoltageWindow;
								
								NextR.ToSdCmd.Content.id  <= cSdCmdACMD41;
								NextR.ToSdCmd.Content.arg <= OCRToArg(ocr);
								NextRegion                := receive;

							when receive => 
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

					when CMD2 => 
						oLedBank(3) <= cActivated;

						case R.Region is
							when send => 
								NextR.ToSdCmd.Content.id <= cSdCmdAllSendCID;
								NextR.ToSdCmd.Valid      <= cActivated;

								NextRegion := receive;

							when receive => 
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
						oLedBank(4) <= cActivated;

						case R.Region is
							when send => 
								NextR.ToSdCmd.Content.id <= cSdCmdSendRelAdr;
								NextR.ToSdCmd.Valid      <= cActivated;

								NextRegion := receive;

							when receive => 
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
				oLedBank(5) <= cActivated;

				case R.CmdRegion is
					when SelectCard => 
						case R.Region is
							when send => 
								NextR.ToSdCmd.Content.id  <= cSdCmdSelCard;
								NextR.ToSdCmd.Content.arg <= R.RCA & X"0000";

								NextRegion := receive;

							when receive => -- Response R1b: with busy!
								if (iSdCmd.Valid = cActivated) then
									if (iSdCmd.Content.id = cSdCmdSelCard) then
										NextR.CardStatus <= iSdCmd.Content.arg;
										NextR.State      <= idle;
									end if;
								elsif (Timeout = cActivated) then
									NextR.State <= invalidCard;
								end if;

							when waitstate => 

							when others => 
								report "Unhandled Region" severity error;
						end case;

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

				if (R.CmdRegion = CMD55) then
					NextR.ToSdCmd.Content.id  <= cSdNextIsACMD;
					NextR.ToSdCmd.Content.arg <= cSdACMDArg;
					NextRegion                := receive;
				end if;

				if (iSdCmd.Ack = cActivated) then
					NextR.ToSdCmd.Valid <= cInactivated;
					NextR.Region        <= NextRegion;
				end if;

			when receive => 
				oLedBank(0)   <= cActivated;
				TimeoutEnable <= cActivated;

				if (R.CmdRegion = CMD55) then
					if (iSdCmd.Valid = cActivated) then
						if (iSdCmd.Content.id = cSdNextIsACMD) then
							NextR.CardStatus <= iSdCmd.Content.arg;
							NextR.CmdRegion  <= CMD55;

							if (iSdCmd.Content.arg(cSdArgAppCmdPos) = cActivated) then
								NextR.Region <= waitstate;
							else 
								NextR.Region <= send;
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

				if (R.CmdRegion = CMD55) then
					NextRegion := send;
				end if;

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
		gTimeoutTime  => 10 ms
	)
	port map (
		iClk => iClk,
		inResetAsync => inResetAsync,
		iEnable => TimeoutEnable,
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
		oTimeout => NextCmdTimeout);

end architecture Rtl;

