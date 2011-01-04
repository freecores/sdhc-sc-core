`ifndef SDCORETRANSACTIONBFM_SV
`define SDCORETRANSACTIONBFM_SV

`include "SdCoreTransaction.sv";
`include "WbTransaction.sv";
`include "WbTransactionReadSingleBlock.sv";

class SdCoreTransactionBFM;

	SdCoreTransSeqMb SdTransInMb;
	SdCoreTransSeqMb SdTransOutMb;
	WbTransMb WbTransOutMb;
	WbTransMb WbTransInMb;
	
	Logger Log = new();
	int StopAfter = -1;

	task start();
		fork
			this.run();
		join_none;
	endtask

	task run();
		while (StopAfter != 0) begin
			SdCoreTransaction trans;
			WbTransactionSequence seq;

			SdTransInMb.get(trans);

			case (trans.kind)
				SdCoreTransaction::readSingleBlock:
					begin
						WbTransactionSequenceReadSingleBlock tmp = new(trans.startAddr, trans.endAddr);
						seq = tmp;
					end
				default:
					begin
						string msg;
						$swrite(msg, "Transaction kind %s not handled.", trans.kind.name());
						Log.error(msg);
					end
			endcase

			assert (seq.randomize()) else Log.error("Randomizing WbTransactionSequence seq failed.");
			seq.display();

			foreach(seq.transactions[i])
				WbTransOutMb.put(seq.transactions[i]);

			if (StopAfter > 0) StopAfter--;
		end
	endtask

endclass

`endif