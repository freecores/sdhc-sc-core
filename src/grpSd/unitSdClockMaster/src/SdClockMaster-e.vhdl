-- SDHC-SC-Core
-- Secure Digital High Capacity Self Configuring Core
-- 
-- (C) Copyright 2010 Rainer Kastl
-- 
-- This file is part of SDHC-SC-Core.
-- 
-- SDHC-SC-Core is free software: you can redistribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or (at
-- your option) any later version.
-- 
-- SDHC-SC-Core is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public License
-- along with SDHC-SC-Core. If not, see http://www.gnu.org/licenses/.
-- 
-- File        : SdClockMaster-e.vhdl
-- Owner       : Rainer Kastl
-- Description : Generation of SDClk and internal strobes
-- Links       : 
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

