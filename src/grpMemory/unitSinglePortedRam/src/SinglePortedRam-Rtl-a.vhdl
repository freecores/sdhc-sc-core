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
-- File        : SinglePortedRam-Rtl-a.vhdl
-- Owner       : Rainer Kastl
-- Description : 
-- Links       : 
-- 

architecture Rtl of SinglePortedRam is

	subtype aWord is std_ulogic_vector(gDataWidth - 1 downto 0);
	type aMemory is array (0 to 2**gAddrWidth - 1) of aWord;

	signal memory : aMemory := (others => (others => '0'));

begin

	SinglePort : process (iClk)
	begin
		if (iClk'event and iClk = '1') then
			if (iWe = '1') then
				memory(iAddr) <= iData;

				oData <= iData;
			else
				oData <= memory(iAddr);
			end if;
		end if;
	end process SinglePort;
	
end architecture Rtl;

