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
-- File        : tbTimeoutGenerator-Bhv-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Testbench
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;

entity tbTimeoutGenerator is

	end entity tbTimeoutGenerator;

architecture Bhv of tbTimeoutGenerator is

	constant cClkFrequency : natural     := 25E6;
	constant cClkPeriod    : time        := 1 sec / cClkFrequency;
	constant cResetTime    : time        := 4 * cClkPeriod;
	constant cTimeoutTime  : time        := 10 us;
	signal Clk             : std_ulogic  := '1';
	signal nResetAsync     : std_ulogic  := cnActivated;
	signal Done            : std_ulogic  := cInactivated;
	signal Timeout         : std_ulogic;
	signal Enable          : std_ulogic  := cInactivated;

begin

	Clk         <= not Clk after (cClkPeriod / 2) when Done = cInactivated else '0';
	nResetAsync <= cnInactivated after cResetTime;

	DUT : entity work.TimeoutGenerator
	generic map (
		gClkFrequency => cClkFrequency,
		gTimeoutTime  => cTimeoutTime
	)
	port map (
		iClk         => Clk,
		inResetAsync => nResetAsync,
		iDisable     => cInactivated,
		iEnable      => Enable,
		oTimeout     => Timeout
	);

	Stimuli : process
	begin
		wait for cResetTime;

		wait for cTimeoutTime;
		Enable <= cActivated,
				  cInactivated after 2 * cClkPeriod;

		wait for 2*cTimeoutTime;
		Enable <= cActivated;

		wait;
	end process Stimuli;

	Checker : process (Timeout)
	begin
		if (Timeout = cActivated or Timeout = cInactivated) then -- first 'U'
			if (now = cResetTime + 2 * cTimeoutTime or
			now = cResetTime + 4 * cTimeoutTime) then
				assert (Timeout = cActivated)
				report "Timeout was not activated at the right time"
				severity error;
			elsif (now = cResetTime + 5 * cTimeoutTime) then
				assert (Timeout = cActivated)
				report "Timeout was not activated at the right time"
				severity error;
				Done <= cActivated;
			else 
				assert (Timeout = cInactivated)
				report "Timeout was activated at a wrong time"
				severity error;
			end if;
		end if;
	end process Checker;

end architecture Bhv;	

