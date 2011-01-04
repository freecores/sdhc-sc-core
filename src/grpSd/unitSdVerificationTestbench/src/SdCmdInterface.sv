//
// file: ../../unitSdVerificationTestbench/src/SdCmdInterface.sv
// author: Rainer Kastl
//
// Interface for the SdCmd entity
// 

interface ISdCmd;
	logic Clk;
	logic nResetAsync;
	wire Cmd;

	clocking cb @(posedge Clk);
		inout Cmd;
	endclocking

	modport Testbench (
		input Clk, nResetAsync, clocking cb
	);

	modport Card (
		clocking cb
	);

endinterface

