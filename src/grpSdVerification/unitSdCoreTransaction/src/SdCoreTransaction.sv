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
// File        : SdCoreTransaction.sv
// Owner       : Rainer Kastl
// Description : 
// Links       : 
// 

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

	local int maxAddr = 31;

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

		startAddr inside {[0:maxAddr]};
		endAddr inside {[0:maxAddr]};
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
		$swrite(s, "kind: %p, addresses: %d, %d", kind, startAddr, endAddr);
		return s;
	endfunction

	// compare kind and addresses
	// NOTE: data has to be checked with other objects
	function bit compare(input SdCoreTransaction rhs);
		if (rhs.kind == this.kind && rhs.startAddr == this.startAddr)
			return 1;
		else return 0;
	endfunction

endclass

class SdCoreTransactionSequence;

	rand SdCoreTransaction transactions[];
	local const int size = 1000;

	function new();
		transactions = new[size];
		foreach(transactions[i]) transactions[i] = new();
	endfunction

	constraint randlength {
		transactions.size() inside {[100:1000]};
		transactions.size() < size;
	}

endclass

typedef mailbox #(SdCoreTransaction) SdCoreTransSeqMb;

`endif
