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
-- File        : Synchronizer-Rtl-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Synchronization between two clock domains
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.global.all;

entity Synchronizer is
	generic (
		gSyncCount : natural := 2
	);
	port (
		-- Resets
		inResetAsync : in std_ulogic := '1';
		iRstSync     : in std_ulogic := '0';

		iToClk       : in std_ulogic;
		iSignal      : in std_ulogic;

		oSync        : out std_ulogic
	);
end entity Synchronizer;

architecture Rtl of Synchronizer is

	signal Sync : std_ulogic_vector(gSyncCount - 1 downto 0);

begin

	SyncReg : process (iToClk, inResetAsync)
	begin
		-- asynchronous reset
		if (inResetAsync = cnActivated) then
			Sync <= (others => '0');

		elsif (rising_edge(iToClk)) then
			-- synchronous reset
			if (iRstSync = cActivated) then
				Sync <= (others => '0');

			else
				-- synchronize
				Sync(0) <= iSignal;

				for i in 1 to gSyncCount - 1 loop

					Sync(i) <= Sync(i-1);

				end loop;

			end if;
		end if;	
	end process SyncReg;

	oSync <= Sync(gSyncCount - 1);

end architecture Rtl;

