`ifndef SDCORETRANSACTIONBFM_SV
`define SDCORETRANSACTIONBFM_SV

`include "SdCoreTransaction.sv";
`include "WbTransaction.sv";
`include "WbTransactionReadSingleBlock.sv";
`include "WbTransactionWriteSingleBlock.sv";

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
						assert (tmp.randomize()) else Log.error("Randomizing WbTransactionSequence seq failed.");
						seq = tmp;

						foreach(seq.transactions[i]) begin
							WbTransaction tr;
							int j = 0;

							WbTransOutMb.put(seq.transactions[i]);
							WbTransInMb.get(tr);

							if (tr.Kind == WbTransaction::Read && tr.Addr == cReadDataAddr) begin
								trans.data[j++] = tr.Data[7:0];
								trans.data[j++] = tr.Data[15:8];
								trans.data[j++] = tr.Data[23:16];
								trans.data[j++] = tr.Data[31:24];
							end
						end
						
						SdTransOutMb.put(trans);
					end

				SdCoreTransaction::writeSingleBlock:
					begin
						WbTransactionSequenceWriteSingleBlock tmp = new(trans.startAddr, trans.endAddr, trans.data[0]);
						assert (tmp.randomize()) else Log.error("Randomizing WbTransactionSequence seq failed.");
						seq = tmp;

						foreach(seq.transactions[i]) begin
							WbTransaction tr;
							WbTransOutMb.put(seq.transactions[i]);
							WbTransInMb.get(tr);
						end
						
						SdTransOutMb.put(trans);
					end
				default:
					begin
						string msg;
						$swrite(msg, "Transaction kind %s not handled.", trans.kind.name());
						Log.error(msg);
					end
			endcase
	

			if (StopAfter > 0) StopAfter--;
		end
	endtask

endclass

`endif
