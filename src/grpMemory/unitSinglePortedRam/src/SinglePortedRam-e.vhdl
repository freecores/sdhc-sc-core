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
-- File        : SinglePortedRam-e.vhdl
-- Owner       : Rainer Kastl
-- Description : 
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SinglePortedRam is

	generic (
		gDataWidth : natural := 32;
		gAddrWidth : natural := 7
	);

	port (
		iClk  : std_ulogic;
		iAddr : in natural range 0 to 2**gAddrWidth - 1;
		iData : in std_ulogic_vector(gDataWidth - 1 downto 0);
		iWe   : in std_ulogic;
		oData : out std_ulogic_vector(gDataWidth - 1 downto 0)
	);
end entity SinglePortedRam;	

