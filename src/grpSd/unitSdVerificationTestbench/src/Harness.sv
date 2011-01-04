// SDHC-SC-Core
// Secure Digital High Capacity Self Configuring Core
// 
// (C) Copyright 2010 Rainer Kastl
// 
// This file is part of SDHC-SC-Core.
// 
// SDHC-SC-Core is free software: you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
// 
// SDHC-SC-Core is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with SDHC-SC-Core. If not, see http://www.gnu.org/licenses/.
// 
// File        : Harness.sv
// Owner       : Rainer Kastl
// Description : Verification harness for SDHC-SC-Core
// Links       : 
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
	Card.ram.RamActionOutMb = new(1);
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
	Checker.RamActionInMb = Card.ram.RamActionOutMb;
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
 
