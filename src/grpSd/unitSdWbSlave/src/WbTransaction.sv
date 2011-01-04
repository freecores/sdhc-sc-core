
`ifndef WBTRANSACTION_SV
`define WBTRANSACTION_SV

typedef bit[3:0] WbAddr;
typedef bit[31:0] WbData;

class WbTransaction;

	typedef enum { Read, Write } kinds;
	typedef enum { Classic, Burst, End } types;

	rand types Type;
	rand kinds Kind;
	rand WbAddr Addr;
	rand WbData Data;

	function void display();
		$display("Transaction: %s, %s, %b, %b", Type.name(), Kind.name(), Addr, Data);
	endfunction
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

