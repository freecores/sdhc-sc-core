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
-- File        : tbStrobeGen-Bhv-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : 
-- Links       : See EDS at FH Hagenberg
-- 

library ieee;
use ieee.std_logic_1164.all;

use work.Global.all;

entity tbStrobeGen is

end entity tbStrobeGen;

architecture Bhv of tbStrobeGen is

  -- component generics
  constant cClkFrequency               : natural := 25E6;
  constant cInResetDuration            : time    := 140 ns;
  constant cStrobeCycleTime            : time    := 1 us;  


  -- component ports
  signal Clk         : std_ulogic := cInactivated;
  signal nResetAsync : std_ulogic := cnInactivated;
  signal Strobe      : std_ulogic;

begin  -- architecture Bhv

  -- component instantiation
  DUT : entity work.StrobeGen
    generic map (
      gClkFrequency    => cClkFrequency,
      gStrobeCycleTime => cStrobeCycleTime)
    port map (
      iClk         => Clk,
      inResetAsync => nResetAsync,
      oStrobe      => Strobe);

  Clk <= not Clk after (1 sec / cClkFrequency) / 2;

  nResetAsync <= cnInactivated after 0 ns,
                 cnActivated   after cInResetDuration,
                 cnInactivated after 2*cInResetDuration;


  -- Process to measure the frequency of the strobe signal and the
  -- active strobe time.
  DetermineStrobeFreq : process
    variable vHighLevel : boolean := false;
    variable vTimestamp : time := 0 sec;
  begin
    wait until (Strobe'event);
    if Strobe = '1' then
      vHighLevel := true;
      if now > vTimestamp then
        assert false
          report "Frequency Value (Strobe) = " &
                 integer'image((1 sec / (now-vTimestamp))) &
                 "Hz; Period (Strobe) = " &
                 time'image(now-vTimestamp)
          severity note;
	    end if;
      vTimestamp := now;
    elsif vHighLevel and Strobe = '0' and
          ((now-vTimestamp)<(1 sec / cClkFrequency)) then
      assert false
        report "Strobe Active Time: " & time'image(now-vTimestamp) & "; " &
               "Clock Cycle time: " & time'image((1 sec / cClkFrequency))
        severity error;
	  end if;

  end process DetermineStrobeFreq;

  -- Simulation is finished after predefined time.
  SimulationFinished : process
  begin
    wait for (10*cStrobeCycleTime);
    assert false
      report "This is not a failure: Simulation finished !!!"
      severity failure;
  end process SimulationFinished;
  
end architecture Bhv;

