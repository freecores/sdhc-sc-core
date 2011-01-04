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
-- File        : SimpleDualPortedRam-Rtl-a.vhdl
-- Owner       : Rainer Kastl
-- Description : 
-- Links       : 
-- 

architecture Rtl of SimpleDualPortedRam is

	signal tempq          : std_logic_vector(31 downto 0);
	signal rdaddr, wraddr : unsigned(6 downto 0);

begin

	Ram_inst: ENTITY work.CycSimpleDualPortedRam
	PORT map
	(
		clock     => iClk,
		data      => std_logic_vector(iDataRw),
		rdaddress => std_logic_vector(rdaddr),
		wraddress => std_logic_vector(wraddr),
		wren      => iWeRW,
		q         => tempq
	);

	oDataR <= std_ulogic_vector(tempq);
	rdaddr <= to_unsigned(iAddrR, rdaddr'length);
	wraddr <= to_unsigned(iAddrRW, wraddr'length);
	
end architecture Rtl;

