//
// file: SdCardModel.sv
// author: Rainer Kastl
//
// Models a SDCard for verification
// 

const logic cActivated = 1;
const logic cInactivated = 0;

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
	 cSdCmdSendStatus = 13 // [31:16] RCA
} SDCommandId;

typedef enum {
	idle
} SDCardState;

class SDCommandToken;
	logic startbit;
	logic transbit;
	logic[5:0] id;
	SDCommandArg arg;
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
		assert(crc7 == calcCrc());
	endfunction

	function automatic aCrc calcCrc();
		aCrc crc = 0;
		logic[39:0] temp;
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

endclass

class SDCommandResponse;

endclass

class SDCard;
	virtual ISdCmd.Card ICmd;

	SDCardState state;
	SDCommandToken recvcmd;

	event CmdReceived;

	function new(virtual ISdCmd CmdInterface, event CmdReceived);
		ICmd = CmdInterface;	
		state = idle;
		this.CmdReceived = CmdReceived;
	endfunction

	task reset();
		state = idle;
	endtask

	task recv();
		recvcmd = new();
		ICmd.cbCard.Cmd <= 'z;

		@(ICmd.cbCard.Cmd == 0);
		// Startbit
		recvcmd.startbit = ICmd.cbCard.Cmd;

		@ICmd.cbCard;
		// Transbit
		recvcmd.transbit = ICmd.cbCard.Cmd;

		// CmdID
		for (int i = 5; i >= 0; i--) begin
			@ICmd.cbCard;
			recvcmd.id[i] = ICmd.cbCard.Cmd;
		end

		// Arg
		for (int i = 31; i >= 0; i--) begin
			@ICmd.cbCard;
			recvcmd.arg[i] = ICmd.cbCard.Cmd;
		end

		// CRC
		for (int i = 6; i >= 0; i--) begin
			@ICmd.cbCard;
			recvcmd.crc7[i] = ICmd.cbCard.Cmd;
		end

		// Endbit
		@ICmd.cbCard;
		recvcmd.endbit = ICmd.cbCard.Cmd;

		-> CmdReceived;
	endtask

	
	function automatic SDCommandToken getCmd();
		return recvcmd;
	endfunction


	task recvCmd(input SDCommandToken cmd, output SDCommandResponse response);
		case (cmd.id)
			cSdCmdGoIdleState: reset();
			default: $display("SDCard: CmdId %d not implemented", cmd.id);
		endcase
	endtask

endclass

