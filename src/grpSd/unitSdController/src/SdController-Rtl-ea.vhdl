-------------------------------------------------
-- file: SdController-Rtl-ea.vhdl
-- author: Rainer Kastl
--
-- Main statemachine for a SDHC compatible SD Controller
-- Simplified Physical Layer Spec. 2.00
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;
use work.Sd.all;

entity SdController is
	port (
		iClk : in std_ulogic; -- rising edge
		inResetAsync : in std_ulogic;

		-- SDCmd
		iSdCmd : in aSdCmdToController;
		oSdCmd : out aSdCmdFromController;

		-- Status
		oLedBank : out aLedBank
		);
end entity SdController;

architecture Rtl of SdController is

	type aSdControllerState is (startup, init, idle, invalidCard);
	type aCmdRegion is (CMD0, CMD8, CMD55, ACMD41, CMD2, CMD3);
	type aRegion is (send, receive, waitstate);
	
	constant cDefaultoSdCmd : aSdCmdFromController := (
	(id       => (others        => '0'),
	arg       => (others        => '0')),
	Valid     => cInactivated,
	ExpectCID => cInactivated);

	type aSdControllerReg is record
		State     : aSdControllerState;
		CmdRegion : aCmdRegion;
		Region    : aRegion;
		HCS       : std_ulogic;
		CCS       : std_ulogic;
		RCA       : aSdRCA;
	end record aSdControllerReg;

	constant cDefaultSdControllerReg : aSdControllerReg := (
	State     => startup,
	CmdRegion => CMD0,
	Region    => send,
	HCS       => cActivated,
	CCS       => cInactivated,
	RCA       => cDefaultRCA);


	signal R, NextR      : aSdControllerReg;
	signal TimeoutEnable : std_ulogic;
	signal Timeout       : std_ulogic;

begin

	Regs : process (iClk, inResetAsync)
	begin
		if (inResetAsync = cnActivated) then
			R <= cDefaultSdControllerReg;
		elsif (iClk'event and iClk = cActivated) then
			R <= NextR;
		end if;
	end process Regs;

	Comb : process (iSdCmd, Timeout, R)
		variable ocr : aSdRegOCR;
		variable arg : aSdCmdArg;
	begin
		-- default assignments
		oSdCmd        <= cDefaultoSdCmd;
		NextR         <= R;
		TimeoutEnable <= cInactivated;

		-- Status
		oLedBank <= (others => cInactivated);

		case R.State is
			when startup => 
				TimeoutEnable <= cActivated;
				
				if (Timeout = cActivated) then
					NextR.State <= init;
			end if;

			when init => 
				case R.CmdRegion is
					when CMD0 => 
						case R.Region is
							when send => 
								oSdCmd.Content.id <= cSdCmdGoIdleState;
								oSdCmd.Valid      <= cActivated;

								if (iSdCmd.Ack = cActivated) then
									NextR.Region <= waitstate;
								end if;

							when waitstate => 
								TimeoutEnable <= cActivated;

								if (Timeout = cActivated) then
									NextR.Region    <= send;
									NextR.CmdRegion <= CMD8;
								end if;

							when others => 
								report "SdController: Unhandled state" severity error;
						end case;

					when CMD8 => 
						case R.Region is
							when send => 
								oSdCmd.Content.id  <= cSdCmdSendIfCond;
								oSdCmd.Content.arg <= cSdArgVoltage;
								oSdCmd.Valid       <= cActivated;

								if (iSdCmd.Ack = cActivated) then
									NextR.Region <= receive;
								end if;

							when receive => 
								oLedBank(0) <= cActivated;
								TimeoutEnable <= cActivated;

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
								TimeoutEnable <= cActivated;

								if (Timeout = cActivated) then
									NextR.CmdRegion <= CMD55;
									NextR.Region    <= send;
								end if;

							when others => 
								report "SdController: Unhandled state" severity error;
						end case;

					when CMD55 => 
						oLedBank(1) <= cActivated;

						case R.Region is
							when send => 
								oSdCmd.Content.id  <= cSdNextIsACMD;
								oSdCmd.Content.arg <= cSdACMDArg;
								oSdCmd.Valid       <= cActivated;

								if (iSdCmd.Ack = cActivated) then
									NextR.Region <= receive;
								end if;

							when receive => 
								oLedBank(0) <= cActivated;

								if (iSdCmd.Valid = cActivated) then
									if (iSdCmd.Content.id = cSdNextIsACMD) then
										NextR.CmdRegion <= CMD55;

										if (iSdCmd.Content.arg(cSdArgAppCmdPos) = cActivated) then
											NextR.Region    <= waitstate;
										end if;
									else 
										NextR.State <= invalidCard;
									end if;
								-- elsif timeout
								end if;

							when waitstate => 
								TimeoutEnable <= cActivated;

								if (Timeout = cActivated) then
									NextR.CmdRegion <= ACMD41;
									NextR.Region <= send;
								end if;

							when others => 
								report "SdController: Unhandled state" severity error;
						end case;

					when ACMD41 => 
						oLedBank(2) <= cActivated;
						
						case R.Region is
							when send => 
								ocr.nBusy         := cnActivated;
								ocr.ccs           := R.HCS;
								ocr.voltagewindow := cVoltageWindow;
								
								oSdCmd.Content.id  <= cSdCmdACMD41;
								oSdCmd.Content.arg <= OCRToArg(ocr);
								oSdCmd.Valid       <= cActivated;
								if (iSdCmd.Ack = cActivated) then
									NextR.Region <= receive;
								end if;

							when receive => 
								oLedBank(0)   <= cActivated;
								TimeoutEnable <= cActivated;

								if (iSdCmd.Valid = cActivated) then
									NextR.CmdRegion <= CMD55;
									NextR.Region    <= send;

									if (iSdCmd.Content.id = cSdR3Id) then
										ocr := ArgToOcr(iSdCmd.Content.arg);

										if (ocr.nBusy = cnInactivated) then
											if (ocr.voltagewindow /= cVoltageWindow) then
												NextR.State <= invalidCard;
											else
												NextR.CCS       <= ocr.ccs;
												NextR.CmdRegion <= CMD2;
												NextR.Region    <= send;
											end if;
										end if;
									end if;
								elsif (Timeout = cActivated) then
									NextR.CmdRegion <= CMD55;
									NextR.Region    <= send;
								end if;

							when others => 
								report "SdController: Unhandled state" severity error;
						end case;

					when CMD2 => 
						oLedBank(3) <= cActivated;

						case R.Region is
							when send => 
								oSdCmd.Content.id <= cSdCmdAllSendCID;
								oSdCmd.Valid      <= cActivated;

								if (iSdCmd.Ack = cActivated) then
									NextR.Region <= receive;
								end if;

							when receive => 
								oLedBank(0)      <= cActivated;
								oSdCmd.ExpectCID <= cActivated;

								if (iSdCmd.Valid = cActivated) then
									NextR.State <= invalidCard;

									if (iSdCmd.Content.id = cSdR2Id) then 
										NextR.State     <= init;
										NextR.CmdRegion <= CMD3;
										NextR.Region    <= send;
									end if;
								-- elsif timeout
								end if;

							when others => 
								report "SdController: Unhandled state" severity error;
						end case;

					when CMD3 => 
						oLedBank(4) <= cActivated;

						case R.Region is
							when send => 
								oSdCmd.Content.id <= cSdCmdSendRelAdr;
								oSdCmd.Valid      <= cActivated;

								if (iSdCmd.Ack = cActivated) then
									NextR.Region <= receive;
								end if;

							when receive => 
								oLedBank(0) <= cActivated;

								if (iSdCmd.Valid = cActivated) then
									if (iSdCmd.Content.id = cSdCmdSendRelAdr) then
										-- todo: check status
										NextR.RCA <= iSdCmd.Content.arg(31 downto 16);
										NextR.State <= idle;
									end if;
								--elsif timeout
								end if;

							when others => 
								report "SdController: Unhandled state" severity error;
						end case;

					when others => 
						report "SdController: Unhandled state" severity error;
				end case;

			when idle => 
				oLedBank(6) <= cActivated;

			when invalidCard => 
				oLedBank(7) <= cActivated;

			when others => 
				report "SdController: Unhandled state" severity error;
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
		oTimeout => Timeout);

end architecture Rtl;

