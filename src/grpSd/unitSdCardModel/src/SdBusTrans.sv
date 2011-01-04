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
// File        : SdBusTrans.sv
// Owner       : Rainer Kastl
// Description : Transmission classes for the SD Bus
// Links       : 
// 

`ifndef SDBUSTRANS_SV
`define SDBUSTRANS_SV

`include "SdDataBlock.sv"

const logic cSdStartbit = 0;
const logic cSdEndbit = 1;

typedef logic SdBusTransData[$];

class SdBusTrans;

	SdDataBlock DataBlocks[];
	bit SendBusy = 0;

	virtual function SdBusTransData packToData();
		return {1};
	endfunction

	virtual function void unpackFromData(ref SdBusTransData data);
	endfunction

endclass

class SdBusTransToken extends SdBusTrans;
	
	logic transbit;
	logic[5:0] id;
	SDCommandArg arg;
	aCrc7 crc;

	function aCrc7 calcCrcOfToken();
		logic temp[$] = { >> { cSdStartbit, this.transbit, this.id, this.arg}};
		return calcCrc7(temp);
	endfunction

	virtual function SdBusTransData packToData();
		SdBusTransData data = { >> {transbit, id, arg, crc}};
		return data;
	endfunction
	
	virtual function void unpackFromData(ref SdBusTransData data);
		{ >> {transbit, id, arg, crc}} = data;	
	endfunction

endclass;

typedef mailbox #(SdBusTransToken) SdBfmMb;

`endif
