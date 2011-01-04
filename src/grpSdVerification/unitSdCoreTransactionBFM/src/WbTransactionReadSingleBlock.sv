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
// File        : WbTransactionReadSingleBlock.sv
// Owner       : Rainer Kastl
// Description : 
// Links       : 
// 

`ifndef WBTRANSACTIONREADSINGLEBLOCK_SV
`define WBTRANSACTIONREADSINGLEBLOCK_SV

`include "WbTransaction.sv";
`include "SdWb.sv";

class WbTransactionSequenceReadSingleBlock extends WbTransactionSequence;

	WbData StartAddr;
	WbData EndAddr;

	function new(WbData StartAddr, WbData EndAddr);
		size = 1 + 1 + 1 + 512*8/32; // startaddr, endaddr, operation, read data back
		
		transactions = new[size];
		foreach(transactions[i])
			transactions[i] = new();

		this.StartAddr = StartAddr;
		this.EndAddr = EndAddr;
	endfunction

	constraint ReadSingleBlock {
		transactions[2].Addr == cOperationAddr;
		transactions[2].Data == cOperationRead;

		transactions[0].Addr == cStartAddrAddr || 
		transactions[0].Addr == cEndAddrAddr;
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
				transactions[i].Addr == cReadDataAddr;
			}
		}
	};

endclass


`endif
 
