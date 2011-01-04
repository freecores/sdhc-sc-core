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
-- File        : SdData-e.vhdl
-- Owner       : Rainer Kastl
-- Description : FSM for sending and receiving data via SD bus
-- Links       : SD Spec 2.00
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;
use work.Sd.all;
use work.SdWb.all;
use work.CRCs.all;

entity SdData is
	port (
		-- clock
		iClk         : in std_ulogic;
		inResetAsync : in std_ulogic;
		
		iStrobe      : in std_ulogic;

		-- Controller
		iSdDataFromController : in aSdDataFromController;
		oSdDataToController   : out aSdDataToController;

		-- Card
		iData : in aiSdData; -- data from card
		oData : out aoSdData; -- data with enables to card
		
		-- Fifos
		iReadWriteFifo : in aiReadFifo;
		oReadWriteFifo : out aoReadFifo;
		iWriteReadFifo : in aiWriteFifo;
		oWriteReadFifo : out aoWriteFifo;

		oDisableSdClk : out std_ulogic
	);
end entity SdData;

