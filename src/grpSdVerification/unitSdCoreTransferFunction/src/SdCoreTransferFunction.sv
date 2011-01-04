`ifndef SDCORETRANSFERFUNCTION_SV
`define SDCORETRANSFERFUNCTION_SV

`include "SdCoreTransaction.sv";
`include "ExpectedResult.sv";

class SdCoreTransferFunction;

	SdCoreTransSeqMb TransInMb;
	ExpectedResultMb ExpectedResultOutMb;

	function void start();
	endfunction

endclass

`endif
