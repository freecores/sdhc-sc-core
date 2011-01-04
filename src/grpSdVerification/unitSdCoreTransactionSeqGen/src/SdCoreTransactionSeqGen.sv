`ifndef SDCORETRANSACTIONSEQGEN_SV
`define SDCORETRANSACTIONSEQGEN_SV

`include "SdCoreTransaction.sv";
`include "Logger.sv";

class SdCoreTransactionSeqGen;

	SdCoreTransSeqMb TransOutMb[2];
	SdCoreTransactionSequence seq;
	Logger Log = new();

	local int stopAfter = 1;

	task start();
		fork
			this.run();
		join_none;
	endtask

	task run();
		while (stopAfter != 0) begin
			seq = new();
			assert(seq.randomize());

			for (int i = 0; i < seq.transactions.size(); i++) begin
				TransOutMb[0].put(seq.transactions[i]);
				TransOutMb[1].put(seq.transactions[i].copy());
			end

			if (stopAfter > 0) stopAfter--;
		end
	endtask

endclass

`endif
