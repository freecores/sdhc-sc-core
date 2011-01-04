//
// file: ../../unitSdVerificationTestbench/src/SdCmdInterface.sv
// author: Rainer Kastl
//
// Interface for the SdCmd entity
// 

`ifndef SDCMDINTERFACE
`define SDCMDINTERFACE

interface ISdCard;
	logic Clk = 0;
	logic nResetAsync;
	wire Cmd;
	logic SClk;
	wire[3:0] Data;

	clocking cb @(posedge Clk);
		inout Cmd;
		inout Data;
	endclocking

	modport Testbench (
		input Clk, nResetAsync, clocking cb
	);

	clocking cbcard @(posedge SClk);
		inout Cmd;
		inout Data;
	endclocking

	modport Card (
		clocking cbcard
	);

endinterface

`endif

