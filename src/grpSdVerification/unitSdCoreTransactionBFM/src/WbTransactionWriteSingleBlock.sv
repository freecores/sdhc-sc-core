`ifndef WBTRANSACTIONWRITESINGLEBLOCK_SV
`define WBTRANSACTIONWRITESINGLEBLOCK_SV

`include "WbTransaction.sv";
`include "SdWb.sv";
`include "SdCoreTransaction.sv";

class WbTransactionSequenceWriteSingleBlock extends WbTransactionSequence;

	WbAddr StartAddr;
	WbAddr EndAddr;
	WbData Data[$];

	function new(WbAddr StartAddr, WbAddr EndAddr, DataBlock Datablock);
		size = 1 + 1 + 1 + 512*8/32; // startaddr, endaddr, operation, write data
	
		transactions = new[size];
		foreach(transactions[i])
			transactions[i] = new();

		this.StartAddr = StartAddr;
		this.EndAddr = EndAddr;

		for (int i = 0; i < 512/4; i++) begin
			WbData temp = 0;
			temp = { >> {Datablock[i*4], Datablock[i*4+1], Datablock[i*4+2], Datablock[i*4+3]}};
			Data.push_back(temp);
		end
	endfunction

	constraint WriteAddrFirst {
		transactions[0].Addr == cStartAddrAddr || 
		transactions[0].Addr == cEndAddrAddr;
		transactions[2].Addr == cOperationAddr;

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
			transactions[i].Kind == WbTransaction::Write;

			if (i > 2) {
				transactions[i].Addr == cWriteDataAddr;
			}
			transactions[i].Addr == cOperationAddr -> transactions[i].Data == cOperationWrite;
		}
	};

	function void post_randomize();
		for (int i = 3; i < size; i++) begin
			transactions[i].Data = Data.pop_front();
		end
	endfunction

endclass

`endif 
