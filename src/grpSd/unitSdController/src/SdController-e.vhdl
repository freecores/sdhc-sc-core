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
-- File        : SdController-e.vhdl
-- Owner       : Rainer Kastl
-- Description : Main FSM controlling Cmd and Data FSM, communicates with Wb
-- Links       : SD Spec 2.00
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Global.all;
use work.Sd.all;
use work.SdWb.all;

entity SdController is
	generic (
		gClkFrequency   : natural := 25E6;
		gHighSpeedMode  : boolean := true;
		gStartupTimeout : time    := 1 ms;
		gReadTimeout    : time    := 100 ms
	);
	port (
		iClk         : in std_ulogic; -- rising edge
		iRstSync     : in std_ulogic;
		oHighSpeed   : out std_ulogic;

		-- SdCmd
		iSdCmd : in aSdCmdToController;
		oSdCmd : out aSdCmdFromController;

		-- SdData
		iSdData : in aSdDataToController;
		oSdData : out aSdDataFromController;

		-- SdWbSlave
		iSdWbSlave : in aSdWbSlaveToSdController;
		oSdWbSlave : out aSdControllerToSdWbSlave;

		-- Status
		oLedBank     : out aLedBank
	);
	begin
		
		assert (gStartupTimeout < gReadTimeout)
		report "gStartupTimeout has to be smaller than the read timeout"
		severity error;

		assert ((gHighSpeedMode = true and gClkFrequency >= 50E6) or gHighSpeedMode = false)
		report "High speed Mode needs at least 50 MHz clock"
		severity error;

end entity SdController;
