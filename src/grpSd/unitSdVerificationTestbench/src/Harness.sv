//
// file: Harness.sv
// author: Rainer Kastl
//
// Verification Harness for SD-Core
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

class Harness;

	SdCoreTransactionBFM TransBfm;
	WbBFM WbBfm;
	SdBFM SdBfm;

	SdCoreTransactionSeqGen TransSeqGen;

	SdCoreTransferFunction TransFunc;

	SdCardModel Card;

	SdCoreChecker Checker;

	Logger Log;

	extern function new(virtual ISdBus SdBus, virtual IWishboneBus WbBus);
	extern task start();

endclass

function Harness::new(virtual ISdBus SdBus, virtual IWishboneBus WbBus);
	Log = new();
	
	TransSeqGen = new();
	TransBfm = new();
	WbBfm = new(WbBus);
	SdBfm = new(SdBus);

	TransFunc = new();
	Checker = new();
endfunction

task Harness::start();

	assert(Card.randomize()) else Log.error("Error randomizing card");

	// create Mailboxes
	TransSeqGen.TransOutMb[0] = new(1);
	TransSeqGen.TransOutMb[1] = new(1);
	TransBfm.WbTransOutMb = new(1);
	WbBfm.TransOutMb = new(1);
	TransBfm.SdTransOutMb = new(1);
	Card.RamActionOutMb = new(1);
	TransFunc.ExpectedResultOutMb = new(1);
	Card.SdTransOutMb = new(1);
	Card.SdTransInMb = new(1);

	// todo: remove
	Card.bfm = SdBfm;

	// connect Mailboxes
	TransFunc.TransInMb = TransSeqGen.TransOutMb[0];
	TransBfm.SdTransInMb = TransSeqGen.TransOutMb[1];
	WbBfm.TransInMb = TransBfm.WbTransOutMb;
	TransBfm.WbTransInMb = WbBfm.TransOutMb;
	Checker.SdTransInMb = TransBfm.SdTransOutMb;
	Checker.RamActionInMb = Card.RamActionOutMb;
	Checker.ExpectedResultInMb = TransFunc.ExpectedResultOutMb;
	SdBfm.SendTransMb = Card.SdTransOutMb;
	SdBfm.ReceivedTransMb = Card.SdTransInMb;

	// start threads
	TransSeqGen.start();
	TransBfm.start();
	WbBfm.start();
	SdBfm.start();
	TransFunc.start();
	Card.start();
	Checker.start();
	
endtask

`endif
 
