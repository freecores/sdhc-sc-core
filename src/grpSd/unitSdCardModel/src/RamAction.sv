`ifndef RAMACTION_SV
`define RAMACTION_SV

`include "SdCoreTransaction.sv";

class RamAction;
	typedef enum {Read, Write} kinds;

	kinds Kind;
	int Addr;
	DataBlock Data;
endclass

typedef mailbox #(RamAction) RamActionMb;

`endif

