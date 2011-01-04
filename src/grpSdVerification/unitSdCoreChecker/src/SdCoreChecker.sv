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
// File        : SdCoreChecker.sv
// Owner       : Rainer Kastl
// Description : Checker for SdCoreTransactions
// Links       : 
// 

`ifndef SDCORECHECKER_SV
`define SDCORECHECKER_SV

`include "SdCoreTransaction.sv";
`include "RamAction.sv";
`include "ExpectedResult.sv";
`include "Logger.sv";

class SdCoreChecker;

	SdCoreTransSeqMb SdTransInMb;
	RamActionMb RamActionInMb;
	ExpectedResultMb ExpectedResultInMb;
	Logger Log = new();
	
	local SdCoreTransaction trans;

	covergroup SdCoreTransactions;
		coverpoint trans.kind {
			bins types[] = {SdCoreTransaction::readSingleBlock,
							SdCoreTransaction::writeSingleBlock,
							SdCoreTransaction::readMultipleBlock,
							SdCoreTransaction::writeMultipleBlocks,
							SdCoreTransaction::erase,
							SdCoreTransaction::readSdCardStatus};
			bins transitions[] = (SdCoreTransaction::readSingleBlock,
							SdCoreTransaction::writeSingleBlock,
							SdCoreTransaction::readMultipleBlock,
							SdCoreTransaction::writeMultipleBlocks,
							SdCoreTransaction::erase,
							SdCoreTransaction::readSdCardStatus => 
							SdCoreTransaction::readSingleBlock,
							SdCoreTransaction::writeSingleBlock,
							SdCoreTransaction::readMultipleBlock,
							SdCoreTransaction::writeMultipleBlocks,
							SdCoreTransaction::erase,
							SdCoreTransaction::readSdCardStatus);
		}

		singleblock: coverpoint trans.kind {
			bins types[] = {SdCoreTransaction::readSingleBlock,
							SdCoreTransaction::writeSingleBlock};
		}

		multiblock: coverpoint trans.kind {
			bins types[] = {SdCoreTransaction::readMultipleBlock,
							SdCoreTransaction::writeMultipleBlocks,
							SdCoreTransaction::erase};
		}

		startAddr: coverpoint trans.startAddr {
			bins legal = {[0:1000]};
			illegal_bins ill = default;
		}

		endAddr: coverpoint trans.endAddr {
			bins legal = {[0:1000]};
			illegal_bins ill = default;
		}

		addressrange: coverpoint (trans.endAddr - trans.startAddr) {
			bins valid = {[1:$]};
			bins zero = {0};
			bins invalid = {[$:-1]};
		}

		cross singleblock, startAddr;
		cross multiblock, startAddr, endAddr;
		cross multiblock, addressrange;
	endgroup

	int StopAfter = -1;

	function new();
		SdCoreTransactions = new();
	endfunction

	task start();
		fork
			run();
		join_none
	endtask

	function void checkRamAction(RamAction actual, RamAction expected, DataBlock block);
		if (expected.Kind == RamAction::Write) begin
			if (actual.Kind != expected.Kind ||
				actual.Addr != expected.Addr ||
				actual.Data != expected.Data) begin

				string msg;
				$swrite(msg, "RamActions differ: %s%p%s%p%s%d%s%d%s%p%s%p",
				"\nactual kind ", actual.Kind, ", expected kind ", expected.Kind,
				"\nactual addr ", actual.Addr, ", expected addr ", expected.Addr,
				"\nactual data ", actual.Data, ", expected data ", expected.Data);
				Log.error(msg);

			end
	    end	else begin
			if (actual.Kind != expected.Kind ||
				actual.Addr != expected.Addr ||
				actual.Data != block) begin

				string msg;
				$swrite(msg, "RamActions differ: %s%p%s%p%s%d%s%d%s%p%s%p",
				"\nactual kind ", actual.Kind, ", expected kind ", expected.Kind,
				"\nactual addr ", actual.Addr, ", expected addr ", expected.Addr,
				"\nactual data ", actual.Data, ", expected data ", block);
				Log.error(msg);

			end
		end
	endfunction

	task run();
		while (StopAfter != 0) begin
			ExpectedResult res;
			RamAction ram[];

			// get transactions
			ExpectedResultInMb.get(res);
			ram = new[res.RamActions.size()];
			foreach(ram[i]) RamActionInMb.get(ram[i]);
			SdTransInMb.get(trans);

			// update functional coverage
			SdCoreTransactions.sample();

			// check transaction
			if (res.trans.compare(trans) == 1) begin
				string msg;
				Log.note("Checker: Transaction successful");
				$swrite(msg, "%s", trans.toString());
				Log.note(msg);
			end
			else begin
				string msg;
				$swrite(msg, "Actual: %s, Expected: %s", trans.toString(), res.trans.toString());
				Log.error(msg);
			end

			// check data
			foreach(ram[i]) begin
				checkRamAction(ram[i], res.RamActions[i], trans.data[i]);
			end

			if (StopAfter > 0) StopAfter--;
		end

	endtask

endclass

`endif
