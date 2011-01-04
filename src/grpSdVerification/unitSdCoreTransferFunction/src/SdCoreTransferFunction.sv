`ifndef SDCORETRANSFERFUNCTION_SV
`define SDCORETRANSFERFUNCTION_SV

`include "SdCoreTransaction.sv";
`include "ExpectedResult.sv";

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

			TransInMb.get(transaction);
			Log.note("SdCoreTransferFunction transaction received");

			if (StopAfter > 0) StopAfter--;
		end
	endtask

endclass

`endif
