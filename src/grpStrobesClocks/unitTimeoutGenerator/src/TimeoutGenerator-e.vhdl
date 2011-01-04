--
-- Title: Timeout generator
-- File: TimeoutGenerator-e.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: Generates a strobe on the timeout line after
-- the specified time. Only one strobe is generated after enabling
-- the generator.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;

entity TimeoutGenerator is

	generic (
		gClkFrequency : natural := 25E6;
		gTimeoutTime  : time    := 1 sec
	);

	port (
		iClk         : in std_ulogic;
		inResetAsync : in std_ulogic;
		iEnable      : in std_ulogic;
		oTimeout     : out std_ulogic
	);

	begin
		assert (1 sec / gClkFrequency <= gTimeoutTime)
		report "The Clk frequency is too low to generate such a short strobe cycle."
		severity error;

end entity TimeoutGenerator;

