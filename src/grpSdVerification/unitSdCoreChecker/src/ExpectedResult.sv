`ifndef EXPECTEDRESULT_SV
`define EXPECTEDRESULT_SV

`include "RamAction.sv";

class ExpectedResult;

	RamAction RamActions[];
	SdCoreTransaction trans;

endclass

typedef mailbox #(ExpectedResult) ExpectedResultMb;

`endif
