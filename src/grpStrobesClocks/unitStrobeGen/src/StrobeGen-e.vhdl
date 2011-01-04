-------------------------------------------------------------------------------
-- Title      : Strobe Generator
-- Project    : General IP
-------------------------------------------------------------------------------
-- $Id: StrobeGen-e.vhd,v 1.1 2003/04/08 13:51:09 pfaff Exp $
-------------------------------------------------------------------------------
-- Author     : Copyright 2003: Markus Pfaff
-- Standard   : Using VHDL'93
-- Simulation : Model Technology Modelsim
-- Synthesis  : Exemplar Leonardo
-------------------------------------------------------------------------------
-- Description:
-- Generates a strobe signal that will be '1' for one clock cycle of the iClk.
-- The strobe comes every gStrobeCycleTime. If this cycle time cannot be
-- generated exactly it will be truncated with the accuracy of one iClk cycle.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Global.all;

entity StrobeGen is
  
  generic (
    gClkFrequency    : natural := 25E6;
    gStrobeCycleTime : time    := 1 sec);

  port (
    -- Sequential logic inside this unit
    iClk         : in std_ulogic;
    inResetAsync : in std_ulogic := '1';
    iRstSync     : in std_ulogic := '0';

    -- Strobe with the above given cycle time
    oStrobe      : out std_ulogic);

begin

  assert ((1 sec / gClkFrequency) <= gStrobeCycleTime)
    report "Mp: The Clk frequency is to low to generate such a short strobe cycle."
    severity error;

end StrobeGen;
