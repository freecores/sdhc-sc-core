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
-- File        : SdWbSdControllerSync-Rtl-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Synchronization of ctrl and data between Wb clock domain and Sd clock domain
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.global.all;
use work.SdWb.all;

entity SdWbControllerSync is
	generic (

		-- both clocks are the same, therefore we don´t need synchronization
		gUseSameClocks : boolean := false;
		gSyncCount     : natural := 2

	);
	port (
		iRstSync             : in std_ulogic;

		-- clocked by iWbClk
		iWbClk               : in std_ulogic;
		iSdWb                : in aSdWbSlaveToSdController;
		oSdWb                : out aSdControllerToSdWbSlave;

		-- clocked by iSdClk
		iSdClk               : in std_ulogic;
		iSdController        : in aSdControllerToSdWbSlave;
		oSdController        : out aSdWbSlaveToSdController

	);
end entity SdWbControllerSync;

architecture Rtl of SdWbControllerSync is

	signal ReqOperationSync : std_ulogic;
	signal ReqOperationEdge : std_ulogic;

	signal AckOperationSync : std_ulogic;
	signal AckOperationEdge : std_ulogic;

begin

	-- synchronization, when different clocks are used
	Sync_gen : if gUseSameClocks = false generate

		Sync_ToSdWb: entity work.Synchronizer
		generic map (
			gSyncCount => gSyncCount
		)
		port map (
			iRstSync => iRstSync,
			iToClk   => iWbClk,
			iSignal  => iSdController.ReqOperation,
			oSync    => ReqOperationSync
		);

		Sync_ToSdController: entity work.Synchronizer
		generic map (
			gSyncCount => gSyncCount
		)
		port map (
			iRstSync => iRstSync,
			iToClk   => iSdClk,
			iSignal  => iSdWb.AckOperation,
			oSync    => AckOperationSync
		);

	end generate;

	-- no synchronization, when the same clocks are used
	NoSync_gen : if gUseSameClocks = true generate

		ReqOperationSync <= iSdController.ReqOperation;
		AckOperationSync <= iSdWb.AckOperation;

	end generate;

	-- detect egdes: every toggle is a new request / acknowledgement
	ReqEdge_inst : entity work.EdgeDetector
	generic map (
		gEdgeDetection     => cDetectAnyEdge,
		gOutputRegistered  => false
	)
	port map (
		iClk               => iWbClk,
		iRstSync           => iRstSync,
		iLine              => ReqOperationSync,
		iClearEdgeDetected => cInactivated,
		oEdgeDetected      => ReqOperationEdge
	);	

	AckEdge_inst : entity work.EdgeDetector
	generic map (
		gEdgeDetection     => cDetectAnyEdge,
		gOutputRegistered  => false
	)
	port map (
		iClk               => iSdClk,
		iRstSync           => iRstSync,
		iLine              => AckOperationSync,
		iClearEdgeDetected => cInactivated,
		oEdgeDetected      => AckOperationEdge
	);	

	-- outputs

	oSdWb.ReqOperation <= ReqOperationEdge;
	oSdWb.ReadData     <= iSdController.ReadData;

	oSdController.AckOperation   <= AckOperationEdge;
	oSdController.OperationBlock <= iSdWb.OperationBlock;
	oSdController.WriteData      <= iSdWb.WriteData;

end architecture Rtl;


