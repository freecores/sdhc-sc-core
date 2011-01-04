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
-- File        : EdgeDetector-e.vhdl
-- Owner       : Rainer Kastl
-- Description : 
-- Links       : See EDS at FH Hagenberg
-- 

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
      inResetAsync       : in  std_ulogic := '1';   -- global asynchronous reset
      iRstSync           : in std_ulogic := '0'; -- global synchronous reset
      iLine              : in  std_ulogic;   -- input signal
      iClearEdgeDetected : in  std_ulogic;   -- clear edge detected output
      oEdgeDetected      : out std_ulogic);  -- edge detected output

end EdgeDetector;
