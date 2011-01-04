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
// File        : WbTransactionWriteSingleBlock.sv
// Owner       : Rainer Kastl
// Description : 
// Links       : 
// 

`ifndef WBTRANSACTIONWRITESINGLEBLOCK_SV
`define WBTRANSACTIONWRITESINGLEBLOCK_SV

`include "WbTransaction.sv";
`include "SdWb.sv";
`include "SdCoreTransaction.sv";

class WbTransactionSequenceWriteSingleBlock extends WbTransactionSequence;

	WbData StartAddr;
	WbData EndAddr;
	WbData Data[$];

	function new(WbData StartAddr, WbData EndAddr, DataBlock Datablock);
		size = 1 + 1 + 1 + 512*8/32; // startaddr, endaddr, operation, write data
	
		transactions = new[size];
		foreach(transactions[i])
			transactions[i] = new();

		this.StartAddr = StartAddr;
		this.EndAddr = EndAddr;

		for (int i = 0; i < 512/4; i++) begin
			WbData temp = 0;
			temp = { >> {Datablock[i*4+3], Datablock[i*4+2], Datablock[i*4+1], Datablock[i*4+0]}};
			Data.push_back(temp);
		end
	endfunction

	constraint WriteAddrFirst {
		transactions[2].Addr == cOperationAddr;
		transactions[1].Addr == cEndAddrAddr;
		transactions[1].Data == EndAddr;
		transactions[0].Addr == cStartAddrAddr;
		transactions[0].Data == StartAddr;

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
