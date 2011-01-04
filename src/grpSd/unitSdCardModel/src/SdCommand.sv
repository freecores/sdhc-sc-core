//
// file: SdCommand.sv
// author: Rainer Kastl
//
// Classes and types describing the commands of the SD spec, used in SdCardModel
// 

`ifndef SDCOMMAND
`define SDCOMMAND

`include "SDCommandArg.sv";
`include "SdCardState.sv";
`include "SDCID.sv";
`include "SDOCR.sv";
`include "SdBFM.sv";

typedef logic[15:0] RCA_t;

typedef enum {
	 cSdCmdGoIdleState = 0,
	 cSdCmdAllSendCID = 2,
	 cSdCmdSendRelAdr = 3,
	 cSdCmdSetDSR = 4, // [31:16] DSR
	 cSdCmdSwitchFuntion = 6, 
	 cSdCmdSelCard = 7, // [31:16] RCA
	 cSdCmdSendIfCond = 8, // [31:12] reserved, [11:8] supply voltage, [7:0] check pattern
	 cSdCmdSendCSD = 9, // [31:16] RCA
	 cSdCmdSendCID = 10, // [31:16] RCA
	 cSdCmdStopTrans = 12,
	 cSdCmdSendStatus = 13, // [31:16] RCA
	 cSdCmdReadSingleBlock = 17,
	 cSdCmdWriteSingleBlock = 24,
	 cSdCmdNextIsACMD = 55 // [31:16] RCA
} SDCommandId;

typedef enum {
	cSdCmdACMD41 = 41,
	cSdCmdSendSCR = 51,
	cSdCmdSetBusWidth = 6
} SDAppCommandId;

const SDCommandArg cSdArgACMD41HCS = 'b01000000111111111000000000000000;

typedef logic[5:0] SdCommandId;
const logic cSdTransbitToHost = 0;

class DefaultSdResponse extends SdBusTransToken;

	function new(SdCommandId id, SDCommandArg arg);
		this.transbit = cSdTransbitToHost;
		this.id = id;
		this.arg = arg;
		this.crc = calcCrcOfToken();
	endfunction

endclass

class SDCommandR7 extends DefaultSdResponse;

	function new(SDCommandArg arg);
		super.new(cSdCmdSendIfCond, arg);
	endfunction

endclass

class SDCommandR1 extends DefaultSdResponse;

	function new(int id, SdCardModelState state);
		super.new(id, state.get());
	endfunction
	
endclass

class SDCommandR3 extends DefaultSdResponse;

	function new(SDOCR ocr);
		super.new('b111111, ocr.get());
		this.crc = 'b111111;
	endfunction
	
endclass

class SDCommandR2 extends SdBusTrans;
	local SDCID cid;
	
	function new();
		this.cid = new();
		assert(this.cid.randomize());
	endfunction

	virtual function SdBusTransData packToData();
		SdBusTransData data;
		SdCommandId id = 'b111111;
		cidreg_t creg = cid.get();

		data = { >> {cSdTransbitToHost, id, creg}};
		return data;
	endfunction

	virtual function void unpackFromData(ref SdBusTransData data);
		Logger log = new();
		log.error("SDCommandR2::unpackFromData not implemented");
	endfunction
	
endclass

function SDCommandArg getArgFromRcaAndState(RCA_t rca, SdCardModelState state);
	SDCommandArg arg;
	arg[31:16] = rca; 
	arg[15] = state.ComCrcError;
	arg[14] = state.IllegalCommand;
	arg[13] = state.Error;
	arg[12:9] = state.state;
	arg[8] = state.ReadyForData;
	arg[7:6] = 0;
	arg[5] = state.AppCmd;
	arg[4] = 0;
	arg[3] = state.AkeSeqError;
	arg[2:0] = 0;
	return arg;
endfunction

class SDCommandR6 extends DefaultSdResponse;

	function new(RCA_t rca, SdCardModelState state);
		super.new(cSdCmdSendRelAdr, getArgFromRcaAndState(rca, state));
	endfunction

endclass

`endif
