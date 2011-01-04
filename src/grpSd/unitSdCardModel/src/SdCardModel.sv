//
// file: SdCardModel.sv
// author: Rainer Kastl
//
// Models a SDCard for verification
// 

const logic cActivated = 1;
const logic cInactivated = 0;

include "../../unitSdCardModel/src/Crc.sv";
include "../../unitSdCardModel/src/SdCommand.sv";
include "../../unitSdCardModel/src/SdData.sv";

class SDCard;
	local virtual ISdCmd.Card ICmd;

	local SDCardState state;
	local RCA_t rca;
	local SDCommandToken recvcmd;
	local logic CCS;
	local Mode_t mode;
	local DataMode_t datamode;

	local event CmdReceived, InitDone;

	function new(virtual ISdCmd CmdInterface, event CmdReceived, event InitDone);
		ICmd = CmdInterface;
		state = new();
		this.CmdReceived = CmdReceived;
		this.InitDone = InitDone;
		this.CCS = 1;
		rca = 0;
		mode = standard;
		ICmd.cbcard.Data <= 'z;
	endfunction

	task reset();
	endtask

	// Receive a command token and handle it
	task recv();
		ICmd.cbcard.Cmd <= 'z;

		repeat(8) @ICmd.cbcard;

		recvcmd = new();

		wait(ICmd.cbcard.Cmd == 0);
		// Startbit
		recvcmd.startbit = ICmd.cbcard.Cmd;

		@ICmd.cbcard;
		// Transbit
		recvcmd.transbit = ICmd.cbcard.Cmd;

		// CmdID
		for (int i = 5; i >= 0; i--) begin
			@ICmd.cbcard;
			recvcmd.id[i] = ICmd.cbcard.Cmd;
		end

		// Arg
		for (int i = 31; i >= 0; i--) begin
			@ICmd.cbcard;
			recvcmd.arg[i] = ICmd.cbcard.Cmd;
		end

		// CRC
		for (int i = 6; i >= 0; i--) begin
			@ICmd.cbcard;
			recvcmd.crc7[i] = ICmd.cbcard.Cmd;
		end

		// Endbit
		@ICmd.cbcard;
		recvcmd.endbit = ICmd.cbcard.Cmd;

		recvcmd.checkFromHost();
		-> CmdReceived;
	endtask

	task automatic init();
		SDCommandR7 voltageresponse;
		SDCommandR1 response;
		SDCommandR3 acmd41response;
		SDCommandR2 cidresponse;
		SDOCR ocr;
		SDCommandR6 rcaresponse;
		logic data[$];
		SdData sddata;
		
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

		recvCMD55(0);

		// expect ACMD41 with HCS = 1
		recv();
		assert(recvcmd.id == cSdCmdACMD41);
		assert(recvcmd.arg == cSdArgACMD41HCS);

		// respond with R3
		ocr = new(CCS, cSdVoltageWindow);
		acmd41response = new(ocr);
		acmd41response.send(ICmd);		
		
		recvCMD55(0);

		// expect ACMD41 with HCS = 1
		recv();
		assert(recvcmd.id == cSdCmdACMD41);
		assert(recvcmd.arg == cSdArgACMD41HCS);
		state.AppCmd = 0;

		// respond with R3
		ocr.setBusy(cOCRDone);
		acmd41response = new(ocr);
		acmd41response.send(ICmd);		

		// expect CMD2
		recv();
		assert(recvcmd.id == cSdCmdAllSendCID);

		// respond with R2
		cidresponse = new();
		cidresponse.send(ICmd);	

		// expect CMD3
		recv();
		assert(recvcmd.id == cSdCmdSendRelAdr);

		// respond with R3
		rcaresponse = new(rca, state);
		rcaresponse.send(ICmd);

		// expect CMD7
		recv();
		assert(recvcmd.id == cSdCmdSelCard);
		assert(recvcmd.arg[31:16] == rca);

		// respond with R1, no busy
		state.ReadyForData = 1;
		response = new(cSdCmdSelCard, state);
		response.send(ICmd);

		// expect ACMD51
		recvCMD55(rca);
		recv();
		assert(recvcmd.id == cSdCmdSendSCR);

		// respond with R1
		response = new(cSdCmdSendSCR, state);
		response.send(ICmd);

		repeat(2) @ICmd.cbcard;

		// send dummy SCR
		for (int i = 0; i < 64; i++)
			data.push_back(0);
		
		data[63-50] = 1;
		data[63-48] = 1;

		sddata = new(standard, widewidth);
		sddata.send(ICmd, data);

		// expect ACMD6
		recvCMD55(rca);
		recv();
		assert(recvcmd.id == cSdCmdSetBusWidth);
		assert(recvcmd.arg == 'h00000002);

		response = new(cSdCmdSetBusWidth, state);
		response.send(ICmd);

		sddata.mode = wide;

		// expect CMD6
		recv();
		assert(recvcmd.id == cSdCmdSwitchFuntion);
		assert(recvcmd.arg == 'h00FFFFF1);
		response.send(ICmd);

		// send status data structure
		data = {};
		
		for (int i = 0; i < 512; i++)
			data.push_back(0);

		data[511-400] = 1;
		data[511-376] = 1;
		sddata.send(ICmd, data);

		// expect CMD6 with set
		recv();
		assert(recvcmd.id == cSdCmdSwitchFuntion);
		assert(recvcmd.arg == 'h80FFFFF1);
		response.send(ICmd);

		// send status data structure
		data = {};
		
		for (int i = 0; i < 512; i++)
			data.push_back(0);

		data[511-400] = 1;
		data[511-376] = 1;
		sddata.send(ICmd, data);

		// switch to 50MHz
		// expect CMD13
		recv();
		assert(recvcmd.id == cSdCmdSendStatus);
		assert(recvcmd.arg == rca);
		response = new(cSdCmdSendStatus, state);
		response.send(ICmd);

		-> InitDone;

	endtask

	task recvCMD55(RCA_t rca);
		SDCommandR1 response;

		// expect CMD55
		recv();
		assert(recvcmd.id == cSdCmdNextIsACMD);
		assert(recvcmd.arg[31:16] == rca);
		state.recvCMD55();

		// respond with R1
		response = new(cSdCmdNextIsACMD, state);
		response.send(ICmd);	
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

class NoSDCard extends SDCard;

	function new(virtual ISdCmd CmdInterface, event CmdReceived, event InitDone);
		super.new(CmdInterface, CmdReceived, InitDone);
	endfunction

	task automatic init();
	endtask

endclass
