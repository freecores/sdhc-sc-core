`ifndef SDCORETRANSACTIONSEQGEN_SV
`define SDCORETRANSACTIONSEQGEN_SV

`include "SdCoreTransaction.sv";

class SdCoreTransactionSeqGen;
	SdCoreTransSeqMb TransOutMb[2];

	function void start();
	endfunction

endclass

`endif
