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
-- File        : StrobeGen-Rtl-a.vhdl
-- Owner       : Rainer Kastl
-- Description : 
-- Links       : See EDS at FH Hagenberg
-- 

architecture Rtl of StrobeGen is

	constant max       : natural                           := gClkFrequency/(1 sec/ gStrobeCycleTime);
	constant cBitWidth : natural                           := LogDualis(max);  -- Bitwidth
	signal   Counter   : unsigned (cBitWidth - 1 downto 0) := (others => '0');

begin  -- architecture Rtl

	StateReg : process (iClk, inResetAsync) is
	begin  -- process StateReg
		if inResetAsync = cnActivated then  -- asynchronous reset (active low)
			Counter <= (others => '0');
			oStrobe <= cInactivated;
		elsif iClk'event and iClk = cActivated then  -- rising clock edge
			if (iRstSync = cActivated) then
				Counter <= (others => '0');
				oStrobe <= cInactivated;

			else
				Counter <= Counter + 1;
				if Counter < max - 1 then
					oStrobe <= cInactivated;
				else
					oStrobe <= cActivated;
					Counter <= TO_UNSIGNED(0, cBitWidth);
				end if;
			end if;
		end if;
	end process StateReg;
end architecture Rtl;
