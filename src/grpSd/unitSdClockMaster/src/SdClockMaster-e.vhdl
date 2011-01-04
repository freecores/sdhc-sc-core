--
-- Title:
-- File: SdClockMaster-e.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: Handles Sclk generation and strobe signal generation
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.global.all;

entity SdClockMaster is
	generic (
		gClkFrequency : natural := 100E6
	);
	port (
		iClk       : in std_ulogic;
		iRstSync   : in std_ulogic;
		iHighSpeed : in std_ulogic;
		iDisable   : in std_ulogic;
		oSdStrobe  : out std_ulogic;
		oSdCardClk : out std_ulogic
	);

	begin

		assert (gClkFrequency = 100E6)
		report "SdCore needs an SdClk with 100 MHz"
		severity failure;

end entity SdClockMaster;

