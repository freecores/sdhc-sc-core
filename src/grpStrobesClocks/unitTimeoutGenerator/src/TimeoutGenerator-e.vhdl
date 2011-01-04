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
-- File        : TimeoutGenerator-e.vhdl
-- Owner       : Rainer Kastl
-- Description : Generates timeout strobes after the specified time
-- Links       : 
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
		iDisable     : in std_ulogic;
		oTimeout     : out std_ulogic
	);

	begin
		assert (1 sec / gClkFrequency <= gTimeoutTime)
		report "The Clk frequency is too low to generate such a short strobe cycle."
		severity error;

end entity TimeoutGenerator;

