`ifndef WBTRANSACTIONREADSINGLEBLOCK_SV
`define WBTRANSACTIONREADSINGLEBLOCK_SV

`include "WbTransaction.sv";
`include "SdWb.sv";

class WbTransactionSequenceReadSingleBlock extends WbTransactionSequence;

	WbAddr StartAddr;
	WbAddr EndAddr;

	function new(WbAddr StartAddr, WbAddr EndAddr);
		size = 1 + 1 + 1; // startaddr, endaddr, operation
		
		transactions = new[size];
		foreach(transactions[i])
			transactions[i] = new();

		this.StartAddr = StartAddr;
		this.EndAddr = EndAddr;
	endfunction

	constraint ReadSingleBlock {
		transactions[2].Addr == cOperationAddr;
		transactions[2].Data == cOperationRead;

		transactions[0].Addr == cStartAddrAddr || cEndAddrAddr;
		if (transactions[0].Addr == cStartAddrAddr) {
			transactions[1].Addr == cEndAddrAddr;
			transactions[1].Data == EndAddr;
			transactions[0].Data == StartAddr;
		} else if (transactions[0].Addr == cEndAddrAddr) {
			transactions[1].Addr == cStartAddrAddr;
			transactions[0].Data == EndAddr;
			transactions[1].Data == StartAddr;
		}

		foreach(transactions[i]) {
			if (i inside {[0:2]}) {
				transactions[i].Kind == WbTransaction::Write;
			} else {
				transactions[i].Kind == WbTransaction::Read;
			}
		}
	};

endclass


`endif
 
