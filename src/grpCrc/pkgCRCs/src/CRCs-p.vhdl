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
-- File        : CRCs-p.vhdl
-- Owner       : Rainer Kastl
-- Description : Package containing CRC polynoms
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;

package CRCs is

	constant crc7 : std_ulogic_vector(7 downto 0) := B"1000_1001";
	constant crc16 : std_ulogic_vector(16 downto 0) := (
	16 => '1',
	12 => '1',
	5 => '1',
	0 => '1',
	others => '0');


end package CRCs;
