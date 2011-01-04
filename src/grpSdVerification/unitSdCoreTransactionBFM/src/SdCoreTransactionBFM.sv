`ifndef SDCORETRANSACTIONBFM_SV
`define SDCORETRANSACTIONBFM_SV

`include "SdCoreTransaction.sv";
`include "WbTransaction.sv";

class SdCoreTransactionBFM;

	SdCoreTransSeqMb SdTransInMb;
	SdCoreTransSeqMb SdTransOutMb;
	WbTransMb WbTransOutMb;
	WbTransMb WbTransInMb;

	function void start();
	endfunction

endclass

`endif
