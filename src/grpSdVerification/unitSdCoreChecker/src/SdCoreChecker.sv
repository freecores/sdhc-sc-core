`ifndef SDCORECHECKER_SV
`define SDCORECHECKER_SV

`include "SdCoreTransaction.sv";
`include "RamAction.sv";
`include "ExpectedResult.sv";

class SdCoreChecker;

	SdCoreTransSeqMb SdTransInMb;
	RamActionMb RamActionInMb;
	ExpectedResultMb ExpectedResultInMb;

	function void start();
	endfunction

endclass

`endif
