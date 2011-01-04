//
// file: ../../unitSdVerificationTestbench/src/SdCmdInterface.sv
// author: Rainer Kastl
//
// Interface for the SdCmd entity
// 

`ifndef SDBUSINTERFACE_SV
`define SDBUSINTERFACE_SV

interface ISdBus;
	wire Cmd;
	logic SClk;
	wire[3:0] Data;

	clocking cb @(posedge SClk);
		inout Cmd;
		inout Data;
	endclocking

	modport card (clocking cb);

endinterface

`endif

