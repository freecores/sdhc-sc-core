--
-- Title: Synchronizer
-- File: SdWbSdControllerSync-Rtl-ea.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: Synchronizes ctrl and data lines between
-- SdWbSlave and SdController
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


