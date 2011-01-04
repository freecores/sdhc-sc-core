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
		oSdCmd : out aSdCmdFromController
	);
end entity SdController;

architecture Rtl of SdController is

	type aSdControllerState is (CMD0, CMD8Ws, CMD8, CMD8Response, CMD55,
	CMD55Response, ACMD41, ACMD41Response, idle,
	invalidCard);
	constant cDefaultControllerState : aSdControllerState := CMD0;
	constant cDefaultoSdCmd : aSdCmdFromController := ((id => (others => '0'),
	arg => (others => '0')), Valid => cInactivated);

	type aSdControllerReg is record
		HCS : std_ulogic;
		CCS : std_ulogic;
	end record aSdControllerReg;
	constant cDefaultSdControllerReg : aSdControllerReg := (cActivated,
	cInactivated);

	signal Reg, NextReg : aSdControllerReg;

	signal State, NextState : aSdControllerState;

begin

	Regs : process (iClk, inResetAsync)
	begin
		if (inResetAsync = cnActivated) then
			State <= cDefaultControllerState;
			Reg <= cDefaultSdControllerReg;
		elsif (iClk'event and iClk = cActivated) then
			Reg <= NextReg;
			State <= NextState;
		end if;
	end process Regs;

	Comb : process (iSdCmd, State, Reg)
	begin
		-- default assignments
		oSdCmd <= cDefaultoSdCmd; 
		NextReg <= Reg;

		case State is
			when idle => null;

			when CMD0 => 
				oSdCmd.Content.id <= cSdCmdGoIdleState;
				oSdCmd.Valid <= cActivated;
				if (iSdCmd.Ack = cActivated) then
					NextState <= CMD8Ws;
				end if;

			when CMD8Ws => 
				if (iSdCmd.Ack = cInactivated) then
					NextState <= CMD8;
				end if;

			when CMD8 => 
				oSdCmd.Content.id <= cSdCmdSendIfCond;
				oSdCmd.Content.arg <= cSdArgVoltage;
				oSdCmd.Valid <= cActivated;
				if (iSdCmd.Ack = cActivated) then
					NextState <= CMD8Response;
				end if;

			when CMD8Response => 
				if (iSdCmd.Valid = cActivated) then
					if (iSdCmd.Content.id = cSdCmdSendIfCond and
					iSdCmd.Content.arg = cSdArgVoltage) then
						NextReg.HCS <= cActivated;
						NextState <= CMD55;
					else
						NextState <= invalidCard;
					end if;
				-- elsif timeout
				end if;

			when invalidCard => 
				null;

			when CMD55 => 
				oSdCmd.Content.id <= cSdNextIsACMD;
				oSdCmd.Content.arg <= cSdACMDArg;
				oSdCmd.Valid <= cActivated;
				if (iSdCmd.Ack = cActivated) then
					NextState <= CMD55Response;
				end if;

			when CMD55Response => 
				if (iSdCmd.Valid = cActivated) then
					NextState <= invalidCard;
					if (iSdCmd.Content.id = cSdNextIsACMD) then
						if (iSdCmd.Content.arg(cSdArgAppCmdPos) = cActivated)
						then
							NextState <= ACMD41;
						end if;
					end if;
				-- elsif timeout
				end if;

			when ACMD41 => 
				oSdCmd.Content.id <= cSdCmdACMD41;
				oSdCmd.Content.arg(31) <= '0';
				oSdCmd.Content.arg(30) <= Reg.HCS;
				oSdCmd.Content.arg(29 downto 24) <= (others => '0');
				oSdCmd.Content.arg(23 downto 0) <= cVoltageWindow;
				oSdCmd.Valid <= cActivated;
				if (iSdCmd.Ack = cActivated) then
					NextState <= ACMD41Response;
				end if;

			when ACMD41Response => 
				null; -- TODO

			when others => 
				report "SdController: State not handled" severity error;
		end case;
	end process Comb;



end architecture Rtl;

