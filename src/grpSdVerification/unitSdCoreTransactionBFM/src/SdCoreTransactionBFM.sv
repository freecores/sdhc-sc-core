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
// File        : SdCoreTransactionBFM.sv
// Owner       : Rainer Kastl
// Description : 
// Links       : 
// 

`ifndef SDCORETRANSACTIONBFM_SV
`define SDCORETRANSACTIONBFM_SV

`include "SdCoreTransaction.sv";
`include "WbTransaction.sv";
`include "WbTransactionReadSingleBlock.sv";
`include "WbTransactionWriteSingleBlock.sv";

class SdCoreTransactionBFM;

	SdCoreTransSeqMb SdTransInMb;
	SdCoreTransSeqMb SdTransOutMb;
	WbTransMb WbTransOutMb;
	WbTransMb WbTransInMb;
	
	Logger Log = new();
	int StopAfter = -1;

	task start();
		fork
			this.run();
		join_none;
	endtask

	task run();
		while (StopAfter != 0) begin
			SdCoreTransaction trans;
			WbTransactionSequence seq;

			SdTransInMb.get(trans);

			case (trans.kind)
				SdCoreTransaction::readSingleBlock:
					begin
						int j = 0;
						WbTransactionSequenceReadSingleBlock tmp = new(trans.startAddr, trans.endAddr);
						assert (tmp.randomize()) else Log.error("Randomizing WbTransactionSequence seq failed.");
						seq = tmp;

						trans.data = new[1];

						foreach(seq.transactions[i]) begin
							WbTransaction tr;

							WbTransOutMb.put(seq.transactions[i]);
							WbTransInMb.get(tr);

							// receive read data
							if (tr.Kind == WbTransaction::Read && tr.Addr == cReadDataAddr) begin
								trans.data[0][j++] = tr.Data[7:0];
								trans.data[0][j++] = tr.Data[15:8];
								trans.data[0][j++] = tr.Data[23:16];
								trans.data[0][j++] = tr.Data[31:24];
							end
						end
						
						SdTransOutMb.put(trans);
					end

				SdCoreTransaction::writeSingleBlock:
					begin
						WbTransactionSequenceWriteSingleBlock tmp = new(trans.startAddr, trans.endAddr, trans.data[0]);
						assert (tmp.randomize()) else Log.error("Randomizing WbTransactionSequence seq failed.");
						seq = tmp;

						foreach(seq.transactions[i]) begin
							WbTransaction tr;
							WbTransOutMb.put(seq.transactions[i]);
							WbTransInMb.get(tr);
						end
						
						SdTransOutMb.put(trans);
					end
				default:
					begin
						string msg;
						$swrite(msg, "Transaction kind %s not handled.", trans.kind.name());
						Log.error(msg);
					end
			endcase
	

			if (StopAfter > 0) StopAfter--;
		end
	endtask

endclass

`endif
