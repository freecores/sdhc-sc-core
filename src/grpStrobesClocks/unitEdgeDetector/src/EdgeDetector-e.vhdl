-------------------------------------------------------------------------------
-- Title      : -
-- Project    : General IP
-------------------------------------------------------------------------------
-- $Id: EdgeDetector-e.vhd,v 1.2 2004/05/09 23:35:16 fseebach Exp $
-------------------------------------------------------------------------------
-- Author     : Copyright 2004: Markus Pfaff, Friedrich Seebacher
-- Standard   : Using VHDL'93
-- Simulation : Model Technology Modelsim
-- Synthesis  : Exemplar Leonardo
-------------------------------------------------------------------------------
-- Description:
--       Detects an edge on the input signal. The activation is configured by the
--   generic parameter gEdgeDetection.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.global.all;

entity EdgeDetector is

   generic (
      -- which edge should be detected
      gEdgeDetection    : in natural := cDetectRisingEdge;
      -- with or without second FF
      gOutputRegistered : in boolean := true);

   port (
      iClk               : in  std_ulogic;   -- system clock
      inResetAsync       : in  std_ulogic;   -- global asynchronous reset
      iLine              : in  std_ulogic;   -- input signal
      iClearEdgeDetected : in  std_ulogic;   -- clear edge detected output
      oEdgeDetected      : out std_ulogic);  -- edge detected output

end EdgeDetector;
