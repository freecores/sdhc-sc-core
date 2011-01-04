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
-- File        : Counter-Rtl-a.vhdl
-- Owner       : Rainer Kastl
-- Description : Generic counter
-- Links       : 
-- 

architecture Rtl of Counter is

type aReg is record
	Counter : unsigned(gBitWidth - 1 downto 0);
	Enabled : std_ulogic;
end record aReg;

constant cDefaultReg : aReg := (
Counter => (others => '1'),
Enabled => cInactivated);

signal R : aReg := cDefaultReg;

begin

	Regs : process (iClk)
	begin
		if (iClk'event and iClk = cActivated) then
			if (iRstSync = cActivated) then
				R <= cDefaultReg;
			else
				oStrobe <= cInactivated;

				if (iDisable = cActivated) then
					R.Enabled <= cInactivated;
					R.Counter <= to_unsigned(0, R.Counter'length);

				elsif (iEnable = cActivated or R.Enabled = cActivated) then
					R.Enabled <= cActivated;

					if (R.Counter = iMax) then
						R.Counter <= to_unsigned(0, R.Counter'length);
						oStrobe   <= cActivated;
						R.Enabled <= cInactivated;

					else 
						R.Counter <= R.Counter + 1;
					end if;

				end if;
			end if;
		end if;
	end process Regs;

end architecture Rtl;
