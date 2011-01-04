-------------------------------------------------
-- file: WbSlave-Rtl-ea.vhdl
-- author: Rainer Kastl
--
-- Generic implementation of a wishbone slave.
-- Wishbone specification revision B.3
-- Supports synchronous cycle termination.
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.Global.all;
use work.wishbone.all;

entity WbSlave is
	generic (
		gPortSize           : natural := 8; -- in bits, only 8, 16, 32 and 64 are valid
		gPortGranularity    : natural := 8; -- in bits, only 8, 16, 32 and 64 are valid
		gMaximumOperandSize : natural := 8; -- in bits, only 8, 16, 32 and 64 are valid
		gAddressWidth       : natural := 8; -- in bits, see also
											-- gPortGranularity and iAdr
		gEndian             : aEndian := little -- if the port size equals the granularity
									-- this setting does not make a difference
	);
	port (
		iClk     : in std_ulogic; -- Clock, rising clock edge
		iRstSync : in std_ulogic; -- Reset, active high, synchronous

		iWbSlave : in aWbSlaveCtrlInput; -- All control signals for a wishbone slave
		oWbSlave : out aWbSlaveCtrlOutput; -- All output signals for a wishbone slave

		-- Data signals
		iSel : in  std_ulogic_vector(gPortSize/gPortGranularity - 1 downto 0);
		-- Selects which parts of iDat are valid
		iAdr : in std_ulogic_vector(gAddressWidth-1 downto integer(log2(
		real(gPortGranularity) )) - 1); -- Address
		iDat : in std_ulogic_vector(gPortSize-1 downto 0); -- Input data, see iSel

		oDat : out std_ulogic_vector(gPortSize-1 downto 0) -- Output data, see iSel
	);

	begin

		-- check valid config with assertions
		assert (gPortSize = 8 or gPortSize = 16 or gPortSize = 32 or gPortSize =
		64) report "gPortSize is invalid, valid values are 8,16,32 and 64." severity failure;

		assert (gPortGranularity = 8 or gPortGranularity = 16 or
		gPortGranularity = 32 or gPortGranularity = 64) report
		"gPortGranularity is invalid, valid values are 8,16,32 and 64." severity failure;

		assert (gMaximumOperandSize = 8 or gMaximumOperandSize = 16 or
		gMaximumOperandSize = 32 or gMaximumOperandSize = 64) report
		"gMaximumOperandSize is invalid, valid values are 8,16,32 and 64." severity failure;

		assert (gPortGranularity <= gPortSize) report
		"gPortGranularity is bigger than gPortSize" severity failure;
		
end entity;

architecture Rtl of WbSlave is

	type aWbState is (idle, ClassicRead, ClassicWrite);

	signal State, NextState : aWbState := idle;

	constant cValid : std_ulogic_vector(gPortSize - 1 downto 0) := (others =>
		'1');

begin
 
	WbStateReg  : process (iClk, iRstSync)
	begin
		if (iClk'event and iClk = cActivated) then
			if (iRstSync = cActivated) then -- sync. reset
				State <= idle;
			else
				State <= NextState;
			end if;
		end if;
	end process WbStateReg ;

	WbNextStateAndOutputs : process (iWbSlave, iSel, iDat, iAdr)
	begin
		-- Default Assignments
		oDat <= (others => cInactivated);
		oWbSlave <= cDefaultWbSlaveCtrlOutput;
		NextState <= State;

		-- Determine next state
		case State is
			when idle =>
				if iWbSlave.Cyc = cActivated and iWbSlave.Stb = cActivated then
				
					case iWbSlave.Cti is
						when cCtiClassicCycle => 
			
							if (iWbSlave.We = cInactivated) then
								NextState <= ClassicRead;
							elsif (iWbSlave.We = cActivated) then
								NextState <= ClassicWrite;
							end if;
			
						when others => null;
					end case;
				
				end if;

			when ClassicRead =>
				assert (iWbSlave.Cyc = cActivated) report
				"Cyc deactivated mid cyclus" severity warning;

				oWbSlave.Ack <= cActivated;	
				oDat <= cValid; -- TODO: Read real data, use Sel
				NextState <= idle;

			when ClassicWrite =>
				assert (iWbSlave.Cyc = cActivated) report
				"Cyc deactivated mid cyclus" severity warning;

				oWbSlave.Ack <= cActivated;	
				-- TODO: Save data, use Sel
				NextState <= idle;

			when others => null;
		end case;

	end process WbNextStateAndOutputs;
end architecture Rtl;

