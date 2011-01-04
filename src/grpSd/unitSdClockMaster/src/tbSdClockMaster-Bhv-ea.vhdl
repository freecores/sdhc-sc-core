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
-- File        : tbSdClockMaster-Bhv-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Non automated testbench
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;

entity tbSdClockMaster is
	end entity tbSdClockMaster;

architecture Bhv of tbSdClockMaster is

	signal Clk             : std_ulogic := cInactivated;
	constant cClkFrequency : natural    := 100E6;
	constant cClkPeriod    : time       := (1 sec / cClkFrequency);
	signal RstSync         : std_ulogic := cActivated;
	constant cResetTime    : time       := 5 * cClkPeriod;
	signal Finished        : boolean    := false;

	-- DUT signals

	signal iHighSpeed, iDisable : std_ulogic := cInactivated;
 	signal  	oStrobe, oSdClk : std_ulogic;

begin

	-- generate clock and reset

	Clk     <= not Clk after cClkPeriod / 2 when Finished = false else cInactivated;
	RstSync <= cInactivated after cResetTime;

	-- stimuli

	stimuli : process 
	begin
		iHighSpeed <= cActivated after 1001 ns,
					  cInactivated after 1026 ns,
					  cActivated after 1306 ns;

		iDisable   <= cActivated after 2346 ns,
					  cInactivated after 3001 ns,
					  cActivated after 3423 ns;
		Finished   <= true after 5001 ns;
		wait;
	end process stimuli;

	DUT: entity work.SdClockMaster
	port map(
		iClk       => Clk,
		iRstSync   => RstSync,

		iHighSpeed => iHighSpeed,
		iDisable   => iDisable,

		oSdStrobe  => oStrobe,
		oSdCardClk => oSdClk
	);


end architecture Bhv;	

