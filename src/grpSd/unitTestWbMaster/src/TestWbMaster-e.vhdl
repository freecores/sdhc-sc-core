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
-- File        : TestWbMaster-e.vhdl
-- Owner       : Rainer Kastl
-- Description : Wishbone master for testing SDHC-SC-Core on the SbX
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TestWbMaster is
	port (
		-- Wishbone interface
		CLK_I : in std_ulogic;
		RST_I : in std_ulogic;

		-- Wishbone master
		ERR_I : in std_ulogic;
		RTY_I : in std_ulogic;
		ACK_I : in std_ulogic;
		DAT_I : in std_ulogic_vector(31 downto 0);

		CYC_O : out std_ulogic;
		STB_O : out std_ulogic;
		WE_O  : out std_ulogic;
		CTI_O : out std_ulogic_vector(2 downto 0);
		BTE_O : out std_ulogic_vector(1 downto 0);

		ADR_O : out std_ulogic_vector(6 downto 4);
		DAT_O : out std_ulogic_vector(31 downto 0);
		SEL_O : out std_ulogic_vector(0 downto 0);

		-- status signal
		LEDBANK_O : out std_ulogic_vector(7 downto 0)
	);
end entity TestWbMaster;

