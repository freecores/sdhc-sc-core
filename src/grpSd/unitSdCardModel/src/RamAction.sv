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
// File        : RamAction.sv
// Owner       : Rainer Kastl
// Description : Describes an action on a RAM
// Links       : 
// 

`ifndef RAMACTION_SV
`define RAMACTION_SV

`include "SdCoreTransaction.sv";

class RamAction;
	typedef enum {Read, Write} kinds;

	kinds Kind;
	int Addr;
	DataBlock Data;

	function new(kinds kind = Read, int addr = 0, DataBlock data = {});
		Kind = kind;
		Addr = addr;
		Data = data;
	endfunction
endclass

typedef mailbox #(RamAction) RamActionMb;

`endif

