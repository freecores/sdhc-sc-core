//
// file: SdCardModel.sv
// author: Rainer Kastl
//
// Models a SDCard for verification
// 

const logic cActivated = 1;
const logic cInactivated = 0;

include "../../unitSdCardModel/src/SdCommand.sv";

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
