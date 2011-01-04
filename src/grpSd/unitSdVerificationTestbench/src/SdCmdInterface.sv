//
// file: ../../unitSdVerificationTestbench/src/SdCmdInterface.sv
// author: Rainer Kastl
//
// Interface for the SdCmd entity
// 

interface ISdCmd;
	logic Clk;
	logic nResetAsync;
	logic[5:0] CmdId;
	SDCommandArg Arg;
	logic Valid;
	logic Receiving;
	wire Cmd;

	clocking cb @(posedge Clk);
		input Receiving;
		output CmdId, Arg, Valid;
	endclocking

	modport Controller (
		input Clk, clocking cb
	);

	modport Card (
		inout Cmd
	);

	modport SdCmd (
		input Clk, nResetAsync, CmdId, Arg, Valid,
		inout Cmd,
		output Receiving
	);

endinterface

