//
// file: SdCommand.sv
// author: Rainer Kastl
//
// Classes and types describing the commands of the SD spec, used in SdCardModel
// 
`define cSDArgWith 32
typedef logic[`cSDArgWith-1:0] SDCommandArg;
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
	 cSdCmdNextIsACMD = 55 // [31:16] RCA
} SDCommandId;

typedef enum {
	cSdCmdACMD41 = 41,
	cSdCmdSendSCR = 51,
	cSdCmdSetBusWidth = 6
} SDAppCommandId;

const SDCommandArg cSdArgACMD41HCS = 'b01000000111111111000000000000000;

include "../../unitSdCardModel/src/SdCardState.sv";

class SDCommandToken;
	logic startbit;
	logic transbit;
	rand logic[5:0] id;
	rand SDCommandArg arg;
	aCrc7 crc7;
	logic endbit;

	function void display();
		$display("Startbit: %b", startbit);
		$display("Transbit: %b", transbit);
		$display("ID: %b", id);
		$display("Arg: %h", arg);
		$display("CRC: %b", crc7);
		$display("Endbit: %b" , endbit);
	endfunction

	function void checkStartEnd();
		assert(startbit == 0);
		assert(endbit == 1);
	endfunction
	
	function void checkFromHost();
		checkStartEnd();	
		checkCrc();
		assert(transbit == 1);
	endfunction

	function void checkCrc();
		assert(crc7 == calcCrcOfToken());
	endfunction

	function automatic aCrc7 calcCrcOfToken();
		logic temp[$];

		temp.push_back(startbit);
		temp.push_back(transbit);
		for (int i = 5; i >= 0; i--)
			temp.push_back(id[i]);
		for (int i = 31; i >= 0; i--)
			temp.push_back(arg[i]);

		return calcCrc7(temp);
	endfunction

	function automatic bit equals(SDCommandToken rhs);
		if(id == rhs.id && arg == rhs.arg) begin
			return 1;
		end
		return 0;
	endfunction

endclass

class SDCommandResponse;
	protected logic startbit;
	protected logic transbit;
	protected logic[5:0] id;
	protected SDCommandArg arg;
	protected aCrc7 crc;
	protected logic endbit;
	protected logic data[$];

	task sendData(virtual ISdCmd.Card ICmd);
		foreach(data[i]) begin
			@ICmd.cb;
			ICmd.cb.Cmd <= data[i];
		end
		
		data = {};
		@ICmd.cb;
		ICmd.cb.Cmd <= 'z;
	endtask


	task automatic send(virtual ISdCmd.Card ICmd);
		aCrc7 crc = 0;
		
		data.push_back(startbit);
		data.push_back(transbit);
		for(int i = 5; i >= 0; i--)
			data.push_back(id[i]);

		for (int i = 31; i>= 0; i--)
			data.push_back(arg[i]);

		crc = calcCrc7(data);
		for (int i = 6; i >= 0; i--)
			data.push_back(crc[i]);

		data.push_back(endbit);
		sendData(ICmd);
	endtask
endclass

class SDCommandR7 extends SDCommandResponse;

	function new(SDCommandArg arg);
		startbit = 0;
		transbit = 0;
		id = cSdCmdSendIfCond;
		this.arg = arg; 
		endbit = 1;
	endfunction

endclass

class SDCommandR1 extends SDCommandResponse;

	function new(int id, SDCardState state);
		startbit = 0;
		transbit = 0;
		this.id = id;
		this.arg = state.get(); 
		endbit = 1;
	endfunction
	
endclass

include "../../unitSdCardModel/src/SDOCR.sv";
class SDCommandR3 extends SDCommandResponse;

	function new(SDOCR ocr);
		startbit = 0;
		transbit = 0;
		this.id = 'b111111;
		this.arg = ocr.get(); 
		endbit = 1;
	endfunction
	
	task automatic send(virtual ISdCmd.Card ICmd);
		data.push_back(startbit);
		data.push_back(transbit);
		for(int i = 5; i >= 0; i--)
			data.push_back(id[i]);

		for (int i = 31; i>= 0; i--)
			data.push_back(arg[i]);

		for (int i = 6; i >= 0; i--)
			data.push_back(1);

		data.push_back(endbit);
		sendData(ICmd);
	endtask

endclass

include "../../unitSdCardModel/src/SDCID.sv";
class SDCommandR2 extends SDCommandResponse;
	local SDCID cid;
	
	function new();
		startbit = 0;
		transbit = 0;
		this.id = 'b111111;
		this.cid = new();
		this.cid.randomize();
		endbit = 1;
	endfunction

	task automatic send(virtual ISdCmd.Card ICmd);
		cidreg_t cidreg;

		// fill queue
		data.push_back(startbit);
		data.push_back(transbit);
		for (int i = 5; i >= 0; i--)
			data.push_back(id[i]);

		cidreg = cid.get();
		for (int i = 127; i >= 1; i--)
			data.push_back(cidreg[i]);

		data.push_back(endbit);
		
		sendData(ICmd);
	endtask
	
endclass

class SDCommandR6 extends SDCommandResponse;

	function new(RCA_t rca, SDCardState state);
		startbit = 0;
		transbit = 0;
		id = cSdCmdSendRelAdr;
		this.arg[31:16] = rca; 
		this.arg[15] = state.ComCrcError;
		this.arg[14] = state.IllegalCommand;
		this.arg[13] = state.Error;
		this.arg[12:9] = state.state;
		this.arg[8] = state.ReadyForData;
		this.arg[7:6] = 0;
		this.arg[5] = state.AppCmd;
		this.arg[4] = 0;
		this.arg[3] = state.AkeSeqError;
		this.arg[2:0] = 0;
		endbit = 1;
	endfunction

endclass

