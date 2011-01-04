--
-- Title: Testbench for SdData
-- File: tbSdData-Bhv-ea.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description:  
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;
use work.Sd.all;

entity tbSdData is
	end entity tbSdData;

architecture Bhv of tbSdData is

	constant cClkFrequency : natural := 25E6;
	constant cClkPeriod    : time    := 1 sec / cClkFrequency / 2;
	constant cResetTime    : time    := 4 * cClkPeriod;

	signal Clk         : std_ulogic := cActivated;
	signal nResetAsync : std_ulogic := cnActivated;
	signal Finished    : std_ulogic := cInactivated;

	signal FromController : aSdDataFromController;
	signal ToController : aSdDataToController;

	signal Data : std_logic_vector(3 downto 0);

begin

	Clk         <= not Clk after cClkPeriod when Finished = cInactivated;
	nResetAsync <= cnInactivated after cResetTime;

	Stimuli : process
	begin
		FromController.Valid <= cInactivated;

		wait for cResetTime + 2 * cClkPeriod;

		for i in 0 to 31 loop
			FromController.DataBlock(128*i+127 downto 128 * i) <= X"FF00AA55884422110011223344556677";
		end loop;
		FromController.Valid <= cActivated;
		FromController.Mode  <= wide;

		wait until Clk = '1' and ToController.Ack = '1';

		FromController.Mode <= standard;

		wait until Clk = '1';
		wait until Clk = '1';

		wait until Clk = '1' and ToController.Ack = '1';

		FromController.DataBlock <= (others => '1');
		
		wait until Clk = '1';
		wait until Clk = '1';

		wait until Clk = '1' and ToController.Ack = '1';

		Finished <= cActivated;
		report "Finished" severity note;

		wait;	
	end process Stimuli;

	SdData_inst: entity work.SdData
	port map (
		iClk         => Clk,
		inResetAsync => nResetAsync,
		iStrobe => cActivated,
		iSdDataFromController => FromController,
		oSdDataToController   => ToController,
		ioData => Data);

end architecture Bhv;	

