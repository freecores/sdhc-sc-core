`ifndef SDCORETRANSACTION_SV
`define SDCORETRANSACTION_SV

typedef bit[0:511][7:0] DataBlock;

class SdCoreTransaction;

	typedef enum { readSingleBlock, readMultipleBlock, writeSingleBlock,
		writeMultipleBlocks, erase, readSdCardStatus } kinds;

	rand kinds kind;
	rand int startAddr;
	rand int endAddr;
	rand DataBlock data[];

	constraint datablocks {
		if (kind == writeMultipleBlocks) {
			data.size() inside {[0:1000]};
		}
		else if (kind == writeSingleBlock) {
			data.size() == 1;
		}
		else {
			data.size() == 0;
		}

		kind == readSingleBlock || 
		kind == writeSingleBlock;

		startAddr inside {[0:31]};
		endAddr inside {[0:31]};
	};

	function SdCoreTransaction copy();
		SdCoreTransaction rhs = new();
		rhs.kind = this.kind;
		rhs.startAddr = this.startAddr;
		rhs.endAddr = this.endAddr;
		rhs.data = new[this.data.size()];
		rhs.data = this.data;
		return rhs;
	endfunction

	function string toString();
		string s;
		$swrite(s, "kind: %p, addresses: %d, %d, data: %p", kind, startAddr, endAddr, data);
		return s;
	endfunction

	function bit compare(input SdCoreTransaction rhs);
		if (rhs.kind == this.kind && rhs.startAddr == this.startAddr &&
			rhs.endAddr == this.endAddr && rhs.data == this.data) return 1;
		else return 0;
	endfunction

endclass

class SdCoreTransactionSequence;

	rand SdCoreTransaction transactions[];

	function new();
		transactions = new[100];
		foreach(transactions[i]) transactions[i] = new();
	endfunction

	constraint randlength {
		transactions.size() > 0;
		transactions.size() <= 100;

		foreach(transactions[i]) {
			if (i % 2 == 0) {
				transactions[i].kind == SdCoreTransaction::writeSingleBlock;
			} else {
				transactions[i].kind == SdCoreTransaction::readSingleBlock;
				transactions[i].startAddr == transactions[i-1].startAddr;
			}
		}
	}

endclass

typedef mailbox #(SdCoreTransaction) SdCoreTransSeqMb;

`endif
