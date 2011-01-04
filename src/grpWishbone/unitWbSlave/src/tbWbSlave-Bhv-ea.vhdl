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
	subtype aAdr is std_ulogic_vector(7 downto 2);
	subtype aData is std_ulogic_vector(7 downto 0);
	
	signal Clk, RstSync : std_ulogic := cInactivated;
	signal iWbSlave : aWbSlaveCtrlInput;
	signal oWbSlave : aWbSlaveCtrlOutput;
	signal Sel : std_ulogic_vector(0 downto 0);
	signal Adr : aAdr;
	signal DataToSlave, DataFromSlave : aData;

	signal Finished : std_ulogic := cInactivated;

	constant cValid : std_ulogic_vector(7 downto 0) := (others => '1');

begin

	-- Clock generator
	Clk <= not Clk after gClkPeriod/2 when (Finished = cInactivated);
	RstSync <= cActivated after 2*gClkPeriod,
			   cInactivated after 3*gClkPeriod;

	Stimulus : process
		
		procedure readData (constant address: in aAdr; variable data : out aData) is
		begin
			iWbSlave.Cyc <= cActivated;
			iWbSlave.Stb <= cActivated;
			iWbSlave.We <= cInactivated;
			iWbSlave.Cti <= cCtiClassicCycle;
			Adr <= address;
			Sel <= "1";
			wait until Clk = cActivated;

			wait until Clk = cActivated and oWbSlave.Ack = cActivated;
			
			assert (oWbSlave.Ack = cActivated) report 
			"Read not acknowledged. Waitstate?" severity error;
			assert (DataFromSlave = cValid) report
			"Invalid data after read" severity error;

			data := DataFromSlave;

		end procedure readData;

		procedure writeData (constant address: in aAdr; constant data: in aData) is
			
		begin
			iWbSlave.Cyc <= cActivated;
			iWbSlave.Stb <= cActivated;
			iWbSlave.We <= cInactivated;
			iWbSlave.Cti <= cCtiClassicCycle;
			Adr <= address;
			Sel <= "1";
			DataToSlave <= data;
			wait until Clk = cActivated;

			wait until Clk = cActivated and oWbSlave.Ack = cActivated;
		end procedure writeData;

		variable tempData : aData;

	begin
		wait for 6*gClkPeriod;
			
		writeData("000001", X"A0");
		readData("000001", tempData);
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

