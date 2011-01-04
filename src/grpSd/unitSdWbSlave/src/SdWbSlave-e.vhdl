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
-- File        : SdWbSlave-e.vhdl
-- Owner       : Rainer Kastl
-- Description : Wishbone interface of SDHC-SC-Core
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.Global.all;
use work.wishbone.all;
use work.SdWb.all;

entity SdWbSlave is
	port (
		iClk     : in std_ulogic; -- Clock, rising clock edge
		iRstSync : in std_ulogic; -- Reset, active high, synchronous

		-- wishbone
		iWbCtrl : in aWbSlaveCtrlInput; -- All control signals for a wishbone slave
		oWbCtrl : out aWbSlaveCtrlOutput; -- All output signals for a wishbone slave
		iWbDat  : in aSdWbSlaveDataInput;
		oWbDat  : out aSdWbSlaveDataOutput; 
		
		-- To sd controller
		iController : in aSdControllerToSdWbSlave;
		oController : out aSdWbSlaveToSdController;

		-- To write fifo
		oWriteFifo : out aoWriteFifo;
		iWriteFifo : in aiWriteFifo;
		
		-- To read fifo
		oReadFifo : out aoReadFifo;
		iReadFifo : in aiReadFifo
	);
end entity;

