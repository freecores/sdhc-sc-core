-- SDHC-SC-Core
-- Secure Digital High Capacity Self Configuring Core
-- 
-- (C) Copyright 2010, Rainer Kastl
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--     * Neither the name of the <organization> nor the
--       names of its contributors may be used to endorse or promote products
--       derived from this software without specific prior written permission.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- File        : tbWbSlave-Bhv-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Testbench for WbSlave-Bhv-ea.vhdl
-- Links       : 
-- 

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

