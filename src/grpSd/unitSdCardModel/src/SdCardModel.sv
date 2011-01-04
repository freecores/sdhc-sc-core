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
	 cSdCmdSendStatus = 13, // [31:16] RCA
	 cSdCmdNextIsACMD = 55 // [31:16] RCA
} SDCommandId;

typedef enum {
	cSdCmdACMD41 = 41
} SDAppCommandId;

const SDCommandArg cSdArgACMD41HCS = 'b01000000111111111000000000000000;

typedef enum {
	idle = 0, ready = 1, ident = 2, stby = 3, trans = 4,
	data = 5, rcv = 6, prg = 7, dis = 8
} SDCardStates;

class SDCardState;
	local logic OutOfRange;
	local logic AddressError;
	local logic BlockLenError;

	local logic[3:0] state;	

	local logic AppCmd;

	function new();
		OutOfRange = 0;
		AddressError = 0;
		BlockLenError = 0;
		state = idle;
		AppCmd = 0;
	endfunction	

	function void recvCMD55();
		AppCmd = 1;
	endfunction

	function automatic SDCommandArg get();
		SDCommandArg temp = 0;
		temp[31] = OutOfRange;
		temp[30] = AddressError;
		temp[29] = BlockLenError;
		temp[12:9] = state;
		temp[5] = AppCmd;
		return temp;
	endfunction

endclass

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

class SDCard;
	local virtual ISdCmd.Card ICmd;

	local SDCardState state;
	local SDCommandToken recvcmd;

	local event CmdReceived, InitDone;

	function new(virtual ISdCmd CmdInterface, event CmdReceived, event InitDone);
		ICmd = CmdInterface;
		state = new();
		this.CmdReceived = CmdReceived;
		this.InitDone = InitDone;
	endfunction

	task reset();
	endtask

	// Receive a command token and handle it
	task recv();
		recvcmd = new();
		ICmd.cb.Cmd <= 'z;

		wait(ICmd.cb.Cmd == 0);
		// Startbit
		recvcmd.startbit = ICmd.cb.Cmd;

		@ICmd.cb;
		// Transbit
		recvcmd.transbit = ICmd.cb.Cmd;

		// CmdID
		for (int i = 5; i >= 0; i--) begin
			@ICmd.cb;
			recvcmd.id[i] = ICmd.cb.Cmd;
		end

		// Arg
		for (int i = 31; i >= 0; i--) begin
			@ICmd.cb;
			recvcmd.arg[i] = ICmd.cb.Cmd;
		end

		// CRC
		for (int i = 6; i >= 0; i--) begin
			@ICmd.cb;
			recvcmd.crc7[i] = ICmd.cb.Cmd;
		end

		// Endbit
		@ICmd.cb;
		recvcmd.endbit = ICmd.cb.Cmd;

		recvcmd.checkFromHost();
		-> CmdReceived;
	endtask

	task automatic init();
		SDCommandR7 voltageresponse;
		SDCommandR1 response;
		
		// expect CMD0 so that state is clear
		recv();
		assert(recvcmd.id == cSdCmdGoIdleState);
		
		// expect CMD8: voltage and SD 2.00 compatible
		recv();
		assert(recvcmd.id == cSdCmdSendIfCond);	
		assert(recvcmd.arg[12:8] == 'b0001); // Standard voltage

		// respond with R7: we are SD 2.00 compatible and compatible to the
		// voltage
		voltageresponse = new(recvcmd.arg);
		voltageresponse.send(ICmd);

		// expect CMD55 with default RCA
		recv();
		assert(recvcmd.id == cSdCmdNextIsACMD);
		assert(recvcmd.arg == 0);
		state.recvCMD55();

		// respond with R1
		response = new(cSdCmdNextIsACMD, state);
		response.send(ICmd);	

		// expect ACMD41 with HCS = 1
		recv();
		assert(recvcmd.id == cSdCmdACMD41);
		assert(recvcmd.arg == cSdArgACMD41HCS);

		-> InitDone;

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

