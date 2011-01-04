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
