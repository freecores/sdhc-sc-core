//
// file: SdCommand.sv
// author: Rainer Kastl
//
// Classes and types describing the commands of the SD spec, used in SdCardModel
// 
`define cSDArgWith 32
typedef logic[`cSDArgWith-1:0] SDCommandArg;
typedef logic[6:0] aCrc;

typedef enum {
	 cSdCmdGoIdleState = 0,
	 cSdCmdAllSendCID = 2,
	 cSdCmdSendRelAdr = 3,
	 cSdCmdSetDSR = 4, // [31:16] DSR
	 cSdCmdSelCard = 7, // [31:16] RCA
	 cSdCmdSendIfCond = 8, // [31:12] reserved, [11:8] supply voltage, [7:0] check pattern
	 cSdCmdSendCSD = 9, // [31:16] RCA
	 cSdCmdSendCID = 10, // [31:16] RCA
	 cSdCmdStopTrans = 12,
	 cSdCmdSendStatus = 13, // [31:16] RCA
	 cSdCmdNextIsACMD = 55 // [31:16] RCA
} SDCommandId;

typedef enum {
	cSdCmdACMD41 = 41
} SDAppCommandId;

const SDCommandArg cSdArgACMD41HCS = 'b01000000111111111000000000000000;

include "../../unitSdCardModel/src/SdCardState.sv";

class SDCommandToken;
	logic startbit;
	logic transbit;
	rand logic[5:0] id;
	rand SDCommandArg arg;
	aCrc crc7;
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

	function automatic aCrc calcCrcOfToken();
		logic[39:0] temp;
		aCrc crc = 0;

		temp[39] = startbit;
		temp[38] = transbit;
		temp[37:32] = id;
		temp[31:0] = arg;

		for(int i = 39; i >= 0; i--) begin
			if (((crc[6] & 1)) != temp[i])
				 crc = (crc << 1) ^ 'b10001001;
			else
				 crc <<= 1;	
		end
		return crc;
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
	protected aCrc crc;
	protected logic endbit;

	function automatic void calcCrc();
		logic[39:0] temp;
		crc = 0;

		temp[39] = startbit;
		temp[38] = transbit;
		temp[37:32] = id;
		temp[31:0] = arg;

		for(int i = 39; i >= 0; i--) begin
			if (((crc[6] & 1)) != temp[i])
				 crc = (crc << 1) ^ 'b10001001;
			else
				 crc <<= 1;	
		end
	endfunction

	
	task automatic send(virtual ISdCmd.Card ICmd);
		calcCrc();

		@ICmd.cb;
		ICmd.cb.Cmd <= startbit;

		@ICmd.cb;
		ICmd.cb.Cmd <= transbit;

		for(int i = 5; i >= 0; i--) begin
			@ICmd.cb;
			ICmd.cb.Cmd <= id[i];
		end	

		for (int i = 31; i>= 0; i--) begin
			@ICmd.cb;
			ICmd.cb.Cmd <= arg[i];
		end

		for (int i = 6; i >= 0; i--) begin
			@ICmd.cb;
			ICmd.cb.Cmd <= crc[i];
		end

		@ICmd.cb;
		ICmd.cb.Cmd <= endbit;
		
		@ICmd.cb;
		ICmd.cb.Cmd <= 'z;
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

	function new(SDCommandId id, SDCardState state);
		startbit = 0;
		transbit = 0;
		this.id = id;
		this.arg = state.get(); 
		endbit = 1;
	endfunction

endclass

