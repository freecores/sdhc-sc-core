-------------------------------------------------
-- file: SdController-e.vhdl
-- author: Rainer Kastl
--
-- Entity for a SDHC compatible SD Controller
-- Simplified Physical Layer Spec. 2.00
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Sd.all

entity SdController is
	port (
		iClk : in std_ulogic; -- rising edge
		inResetAsync : in std_ulogic

	);
end entity SdController;

