//
// file: harness.sv
// author: Rainer Kastl
//
// Verification harness for SD-Core
//

`ifndef HARNESS_SV
`define HARNESS_SV

`include "SdCardModel.sv";
`include "WishboneBFM.sv";
`include "SdBFM.sv";
`include "SdCoreTransactionBFM.sv";
`include "SdCoreTransactionSeqGen.sv";
`include "SdCoreTransferFunction.sv";
`include "SdCoreChecker.sv";

class harness;

	SdCoreTransactionBFM TransBfm;
	WbBFM WbBfm;
	SdBFM SdBfm;

	SdCoreTransactionSeqGen TransSeqGen;

	SdCoreTransferFunction TransFunc;

	SdCardModel Card;

	SdCoreChecker Checker;

	Logger Log;

	extern function new(virtual ISdBus SdBus, virtual IWishboneBus WbBus);

endclass

function harness::new(virtual ISdBus SdBus, virtual IWishboneBus WbBus);
	Log = new();
	
	TransBfm = new();
	WbBfm = new(WbBus);
	SdBfm = new(SdBus);

	TransFunc = new();
	Checker = new();

	Card.randomize();
	TransSeqGen.randomize();

	// connect Mailboxes
	TransFunc.TransInMb = TransSeqGen.TransOutMb[0];
	TransBfm.SdTransInMb = TransSeqGen.TransOutMb[1];
	WbBfm.TransInMb = TransBfm.WbTransOutMb;
	TransBfm.WbTransInMb = WbBfm.TransOutMb;
	Checker.SdTransInMb = TransBfm.SdTransOutMb;
	Checker.RamActionInMb = Card.RamActionOutMb;
	Checker.ExpectedResultInMb = TransFunc.ExpectedResultOutMb;
	
endfunction

`endif
 
