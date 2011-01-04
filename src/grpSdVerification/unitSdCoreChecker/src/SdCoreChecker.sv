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

	task run();
		while (StopAfter != 0) begin
			ExpectedResult res;
			RamAction ram;

			ExpectedResultInMb.get(res);
			SdTransInMb.get(trans);

			//if (res.RamActions.size() > 0) RamActionInMb.get(ram);

			Log.warning("SdCoreChecker: RamActions not handled");

			// update functional coverage
			SdCoreTransactions.sample();

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

			if (StopAfter > 0) StopAfter--;
		end

	endtask

endclass

`endif
