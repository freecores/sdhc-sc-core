--
-- Title: Generic Counter
-- File: Counter-e.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: Counts once to iMax and generates a strobe. 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;

entity Counter is
	generic (
		gBitWidth : natural
	);
	port (
		iClk         : in std_ulogic;
		inResetAsync : in std_ulogic;
		iEnable      : in std_ulogic;
		iDisable 	 : in std_ulogic;
		iMax         : in unsigned(gBitWidth - 1 downto 0);
		oStrobe      : out std_ulogic
	);
end entity Counter;

