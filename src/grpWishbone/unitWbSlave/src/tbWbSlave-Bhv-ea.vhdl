-------------------------------------------------
-- file: tbWbSlave-Bhv-ea.vhdl
-- author: Rainer Kastl
--
-- Testbench for wishbone slave (WbSlave-Rtl-ea.vhdl)
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.math_real.all;
use work.Global.all;
use work.wishbone.all;

entity tbWbSlave is
	generic (gClkPeriod : time := 10 ns);
end entity;

architecture Bhv of tbWbSlave is

	signal Clk, RstSync : std_ulogic := cInactivated;
	signal iWbSlave : aWbSlaveCtrlInput;
	signal oWbSlave : aWbSlaveCtrlOutput;
	signal Sel : std_ulogic_vector(0 downto 0);
	signal Adr : std_ulogic_vector(7 downto 2);
	signal DataToSlave, DataFromSlave : std_ulogic_vector(7 downto 0);

	signal Finished : std_ulogic := cInactivated;

	constant cValid : std_ulogic_vector(7 downto 0) := (others =>
		'1');

begin

	-- Clock generator
	Clk <= not Clk after gClkPeriod/2 when (Finished = cInactivated);
	RstSync <= cActivated after 2*gClkPeriod,
			   cInactivated after 3*gClkPeriod;

	Stimulus : process
	begin
		wait for 6*gClkPeriod;
	    -- Classic Reads
		wait until Clk = cActivated;
		iWbSlave.Cyc <= cActivated;
		iWbSlave.Stb <= cActivated;
		iWbSlave.We <= cInactivated;
		iWbSlave.Cti <= cCtiClassicCycle;
		Adr <= "000001";
		Sel <= "1";

		wait until Clk = cActivated;
		wait until Clk = cActivated;
		
		assert (oWbSlave.Ack = cActivated) report 
		"Read not acknowledged. Waitstate?" severity error;
		assert (DataFromSlave = cValid) report
		"Invalid data after read" severity error;

		wait until Clk = cActivated;

		Finished <= cActivated;
		wait;	
	end process Stimulus;
	
	duv : entity work.WbSlave(Rtl)
	generic map (gPortSize => 8, 
				 gPortGranularity => 8,
				 gMaximumOperandSize => 8,
				 gAddressWidth => 8,
				 gEndian => little)
	port map(iClk => Clk,
			 iRstSync => RstSync,
			 iWbSlave => iWbSlave,
			 oWbSlave => oWbSlave,
			 iSel => Sel,
			 iAdr => Adr,
			 iDat => DataToSlave,
			 oDat => DataFromSlave);

end architecture Bhv;

