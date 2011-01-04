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

