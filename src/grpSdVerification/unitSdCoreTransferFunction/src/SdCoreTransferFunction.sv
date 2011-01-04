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
// File        : SdCoreTransferFunction.sv
// Owner       : Rainer Kastl
// Description : 
// Links       : 
// 

`ifndef SDCORETRANSFERFUNCTION_SV
`define SDCORETRANSFERFUNCTION_SV

`include "SdCoreTransaction.sv";
`include "ExpectedResult.sv";
`include "Logger.sv";
`include "SdCardModel.sv";

class SdCoreTransferFunction;

	SdCoreTransSeqMb TransInMb;
	ExpectedResultMb ExpectedResultOutMb;

	Logger Log = new();
	int StopAfter = -1;

	task start();
		fork
			this.run();
		join_none;
	endtask

	task run();
		while (StopAfter != 0) begin
			SdCoreTransaction transaction;
			ExpectedResult res = new();

			TransInMb.get(transaction);
			res.trans = transaction;

			case(transaction.kind)
				SdCoreTransaction::readSingleBlock:
					begin
						res.RamActions = new[1];
						res.RamActions[0] = new();
						res.RamActions[0].Kind = RamAction::Read;
						res.RamActions[0].Addr = transaction.startAddr;
					end

				SdCoreTransaction::writeSingleBlock:
					begin
						res.RamActions = new[1];
						res.RamActions[0] = new();
						res.RamActions[0].Kind = RamAction::Write;
						res.RamActions[0].Addr = transaction.startAddr;
						res.RamActions[0].Data = transaction.data[0];
					end
			default:
					begin
						string msg;
						$swrite(msg, "TF: Transaction kind %s not handled.", transaction.kind.name());
						Log.error(msg);
					end
			endcase

			ExpectedResultOutMb.put(res);

			if (StopAfter > 0) StopAfter--;
		end
	endtask

endclass

`endif
