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

	type aSdControllerState is (CMD0, CMD8Ws, CMD8, CMD8Response, idle);
	constant cDefaultControllerState : aSdControllerState := CMD0;
	constant cDefaultoSdCmd : aSdCmdFromController := ((id => (others => '0'),
	arg => (others => '0')), Valid => cInactivated);

	signal State, NextState : aSdControllerState;

begin

	Regs : process (iClk, inResetAsync)
	begin
		if (inResetAsync = cnActivated) then
			State <= cDefaultControllerState;
		elsif (iClk'event and iClk = cActivated) then
			State <= NextState;
		end if;
	end process Regs;

	Comb : process (iSdCmd, State)
	begin
		-- default assignments
		oSdCmd <= cDefaultoSdCmd; 

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
				null;

			when others => 
				report "SdController: State not handled" severity error;
		end case;
	end process Comb;



end architecture Rtl;

