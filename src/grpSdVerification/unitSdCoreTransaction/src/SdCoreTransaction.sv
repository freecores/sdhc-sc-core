`ifndef SDCORETRANSACTION_SV
`define SDCORETRANSACTION_SV

typedef bit[511:0] DataBlock;

class SdCoreTransaction;

	typedef enum { readSingleBlock, readMultipleBlock, writeSingleBlock,
		writeMultipleBlocks, erase, readSdCardStatus } kinds;

	rand kinds kind;
	rand int startAddr;
	rand int endAddr;
	rand DataBlock data[];

endclass

class SdCoreTransactionSequence;

	rand SdCoreTransaction transactions[];

	constraint randlength {
		transactions.size() > 0;
		transactions.size() <= 100;
	}

	function void post_randomize();
		foreach (transactions[i]) begin
			transactions[i] = new();
			assert(transactions[i].randomize());
		end
	endfunction
	
endclass

typedef mailbox #(SdCoreTransaction) SdCoreTransSeqMb;

`endif
