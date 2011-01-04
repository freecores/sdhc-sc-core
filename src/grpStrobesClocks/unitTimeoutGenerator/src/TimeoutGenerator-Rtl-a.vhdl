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
-- File        : TimeoutGenerator-Rtl-a.vhdl
-- Owner       : Rainer Kastl
-- Description : 
-- Links       : 
-- 

architecture Rtl of TimeoutGenerator is

	constant cMax      : natural := gClkFrequency / (1 sec / gTimeoutTime) - 1;
	constant cBitWidth : natural := LogDualis(cMax);

	signal Counter : unsigned (cBitWidth - 1 downto 0);
	signal Enabled : std_ulogic;

begin

	Regs : process (iClk, inResetAsync)
	begin

		if (inResetAsync = cnActivated) then
			Counter  <= (others => '0');
			Enabled  <= cInactivated;
			oTimeout <= cInactivated;

		elsif (iClk'event and iClk = cActivated) then
			oTimeout <= cInactivated; -- Default
			
			if (iDisable = cActivated) then
				Enabled <= cInactivated;
				Counter <= (others => '0');

			elsif (iEnable = cActivated or Enabled = cActivated) then
				Counter <= Counter + 1;
				Enabled <= cActivated;
				
				if (Counter >= cMax) then
					Counter  <= to_unsigned(0, cBitWidth);
					Enabled  <= cInactivated;
					oTimeout <= cActivated;
				end if;
			end if;

		end if;
	end process Regs;

end architecture Rtl;

