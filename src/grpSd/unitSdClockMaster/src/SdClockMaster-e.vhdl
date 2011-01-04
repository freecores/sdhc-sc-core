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
		iClk       : in std_ulogic; -- Clock active high
		iRstSync   : in std_ulogic; -- Synchronous reset active high

		iHighSpeed : in std_ulogic; -- Switches between High-Speed (50 MHz) and default mode (25 MHz)
		iDisable   : in std_ulogic; -- Disables the clock output

		oSdStrobe  : out std_ulogic; -- strobe signal to enable SdCmd and SdData
		oSdInStrobe : out std_ulogic; -- strobe signal to capture the input cmd and data
		oSdCardClk : out std_ulogic -- clock output to SD card
	);

	begin

		assert (gClkFrequency = 100E6)
		report "SdCore needs a SdClk with 100 MHz"
		severity failure;

end entity SdClockMaster;

