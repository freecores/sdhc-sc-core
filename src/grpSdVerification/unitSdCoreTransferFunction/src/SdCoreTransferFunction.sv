`ifndef SDCORETRANSFERFUNCTION_SV
`define SDCORETRANSFERFUNCTION_SV

`include "SdCoreTransaction.sv";
`include "ExpectedResult.sv";
`include "Logger.sv";

class SdCoreTransferFunction;

	SdCoreTransSeqMb TransInMb;
	ExpectedResultMb ExpectedResultOutMb;

	Logger Log = new();
	int StopAfter = -1;

	task start();
		fork
			this.run();
		join_none;
	endtask

	task run();
		while (StopAfter != 0) begin
			SdCoreTransaction transaction;
			ExpectedResult res = new();

			TransInMb.get(transaction);
			res.trans = transaction;

			case(transaction.kind)
				SdCoreTransaction::readSingleBlock:
					begin
						res.RamActions = new[1];
						res.RamActions[0] = new();
						res.RamActions[0].Kind = RamAction::Read;
						res.RamActions[0].Addr = transaction.startAddr;
						Log.note("TF: Handle data");
					end

				SdCoreTransaction::writeSingleBlock:
					begin
						res.RamActions = new[1];
						res.RamActions[0] = new();
						res.RamActions[0].Kind = RamAction::Read;
						res.RamActions[0].Addr = transaction.startAddr;
						res.RamActions[0].Data = transaction.data[0];
					end
			default:
					begin
						string msg;
						$swrite(msg, "TF: Transaction kind %s not handled.", transaction.kind.name());
						Log.error(msg);
					end
			endcase

			ExpectedResultOutMb.put(res);

			if (StopAfter > 0) StopAfter--;
		end
	endtask

endclass

`endif
