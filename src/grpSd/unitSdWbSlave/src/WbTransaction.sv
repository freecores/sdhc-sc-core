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
// File        : WbTransaction.sv
// Owner       : Rainer Kastl
// Description : Transaction on the wishbone bus
// Links       : 
// 

`ifndef WBTRANSACTION_SV
`define WBTRANSACTION_SV

typedef bit[2:0] WbAddr;
typedef bit[31:0] WbData;

class WbTransaction;

	typedef enum { Read, Write } kinds;
	typedef enum { Classic, Burst, End } types;

	rand types Type;
	rand kinds Kind;
	rand WbAddr Addr;
	rand WbData Data;

	function void display();
		$display(toString());
	endfunction

	function string toString();
		string s;
		$swrite(s, "Transaction: %s, %s, %b, %b", Type.name(), Kind.name(), Addr, Data);
		return s;
	endfunction

	constraint NotImplementedYet {
		Type == Classic;
	};
endclass

class WbTransactionSequence;

	rand WbTransaction transactions[];
	int size = 0;

	constraint Transactions {
		transactions.size() == size;

		foreach(transactions[i]) {
			if (i > 0) {
				if (transactions[i].Type == WbTransaction::Burst)
					transactions[i].Type == WbTransaction::Burst || WbTransaction::End;
			}
		}

		if (transactions[size - 2].Type == WbTransaction::Burst)
			transactions[size - 1].Type == WbTransaction::End;
	};

	function void display();
		foreach(transactions[i])
			transactions[i].display();
	endfunction

endclass


typedef mailbox #(WbTransaction) WbTransMb;

`endif

