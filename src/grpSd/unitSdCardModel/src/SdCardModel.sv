//
// file: SdCardModel.sv
// author: Rainer Kastl
//
// Models a SdCardModel for verification
// 

`ifndef SDCARDMODEL
`define SDCARDMODEL

const logic cActivated = 1;
const logic cInactivated = 0;

`include "Crc.sv";
`include "SdCommand.sv";
`include "SdBFM.sv";
`include "Logger.sv";
`include "RamAction.sv";

class SdCardModel;
	
	RamActionMb RamActionOutMb;
	SdBfmMb SdTransOutMb;
	SdBfmMb SdTransInMb;

	local SdBFM bfm;
	local SdCardModelState state;
	local RCA_t rca;
	local logic CCS;
	local Mode_t mode;
	local DataMode_t datamode;
	local Logger log;


	local rand int datasize; // ram addresses = 2^datasize - 1; 512 byte blocks
	constraint cdatasize {datasize > 1; datasize <= 32;}

	local bit[512*8-1:0] ram[];
	
	function void post_randomize() ;
		this.ram = new[2^(datasize-1)];
	endfunction

	function new();
		//this.bfm = bfm;
		state = new();
		this.CCS = 1;
		rca = 0;
		mode = standard;
		log = new();
	endfunction

	function void start();
	endfunction

	task reset();
	endtask

	task automatic init();
		SDCommandR7 voltageresponse;
		SDCommandR1 response;
		SDCommandR3 acmd41response;
		SDCommandR2 cidresponse;
		SDOCR ocr;
		SDCommandR6 rcaresponse;
		logic data[$];
		SdBusTransToken token;

		log.note("Expecting CMD0");
		// expect CMD0 so that state is clear
		this.bfm.receive(token);
		assert(token.id == cSdCmdGoIdleState) else log.error("Received invalid token.");
		
		// expect CMD8: voltage and SD 2.00 compatible
		log.note("Expecting CMD8");
		this.bfm.receive(token);
		assert(token.id == cSdCmdSendIfCond) else log.error("Received invalid token.");	
		assert(token.arg[12:8] == 'b0001) else
		begin
			string msg;
			$swrite(msg, "Received invalid arg: %b", token.arg);
			log.error(msg); // Standard voltage
		end;

		// respond with R7: we are SD 2.00 compatible and compatible to the
		// voltage
		voltageresponse = new(token.arg);
		this.bfm.send(voltageresponse);

		recvCMD55(0);

		// expect ACMD41 with HCS = 1
		log.note("Expect ACMD41 (with HCS = 1)");
		this.bfm.receive(token);
		assert(token.id == cSdCmdACMD41) else log.error("Received invalid token.\n");
		assert(token.arg == cSdArgACMD41HCS) else begin
			string msg;
			$swrite(msg, "Received invalid arg: %b, Expected: %b", token.arg, cSdArgACMD41HCS);
			log.error(msg);
		end;
		state.AppCmd = 0;

		// respond with R3, not done
		ocr = new(CCS, cSdVoltageWindow);
		acmd41response = new(ocr);
		this.bfm.send(acmd41response);
		
		recvCMD55(0);

		// expect ACMD41 with HCS = 1
		log.note("Expect ACMD41 (with HCS = 1)");
		this.bfm.receive(token);
		assert(token.id == cSdCmdACMD41) else log.error("Received invalid token.\n");
		assert(token.arg == cSdArgACMD41HCS) else begin
			string msg;
			$swrite(msg, "Received invalid arg: %b, Expected: %b", token.arg, cSdArgACMD41HCS);
			log.error(msg);
		end;
		state.AppCmd = 0;

		// respond with R3
		ocr.setBusy(cOCRDone);
		acmd41response = new(ocr);
		this.bfm.send(acmd41response);

		// expect CMD2
		log.note("Expect CMD2");
		this.bfm.receive(token);
		assert(token.id == cSdCmdAllSendCID) else log.error("Received invalid token.\n");

		// respond with R2
		cidresponse = new();
		this.bfm.send(cidresponse);

		// expect CMD3
		log.note("Expect CMD3");
		this.bfm.receive(token);
		assert(token.id == cSdCmdSendRelAdr) else log.error("Received invalid token.\n");

		// respond with R3
		rcaresponse = new(rca, state);
		this.bfm.send(rcaresponse);

		// expect CMD7
		log.note("Expect CMD7");
		this.bfm.receive(token);
		assert(token.id == cSdCmdSelCard);
		assert(token.arg[31:16] == rca);

		// respond with R1, no busy
		state.ReadyForData = 1;
		response = new(cSdCmdSelCard, state);
		this.bfm.send(response);

		// expect ACMD51
		recvCMD55(rca);
		log.note("Expect ACMD51");
		this.bfm.receive(token);
		assert(token.id == cSdCmdSendSCR);

		// respond with R1 and dummy SCR
		response = new(cSdCmdSendSCR, state);
		response.DataBlocks = new[1];
		response.DataBlocks[0] = new();
		
		// send dummy SCR
		for (int i = 0; i < 64; i++)
			response.DataBlocks[0].data.push_back(0);
		
		response.DataBlocks[0].data[63-50] = 1;
		response.DataBlocks[0].data[63-48] = 1;

		this.bfm.send(response);

		// expect ACMD6
		recvCMD55(rca);
		log.note("Expect ACMD6");
		this.bfm.receive(token);
		assert(token.id == cSdCmdSetBusWidth);
		assert(token.arg == 'h00000002);

		response = new(cSdCmdSetBusWidth, state);
		this.bfm.send(response);

		this.bfm.Mode = wide;
		mode = wide;

		// expect CMD6
		log.note("Expect CMD6");
		this.bfm.receive(token);
		assert(token.id == cSdCmdSwitchFuntion);
		assert(token.arg == 'h00FFFFF1);

		response.DataBlocks = new[1];
		response.DataBlocks[0] = new();
		
		for (int i = 0; i < 512; i++)
			response.DataBlocks[0].data.push_back(0);

		response.DataBlocks[0].data[511-401] = 1;
		response.DataBlocks[0].data[511-376] = 1;

		this.bfm.send(response);

		// expect CMD6 with set
		log.note("Expect CMD6 with set");
		this.bfm.receive(token);
		assert(token.id == cSdCmdSwitchFuntion);
		assert(token.arg == 'h80FFFFF1);
		this.bfm.send(response);

		// switch to 50MHz
		// expect CMD13
		log.note("Expect CMD13");
		this.bfm.receive(token);
		assert(token.id == cSdCmdSendStatus);
		assert(token.arg == rca);
		response = new(cSdCmdSendStatus, state);
		this.bfm.send(response);

	endtask

	task run();
		this.init();

		forever begin
			SdBusTransToken token;
			this.bfm.receive(token);

			case (token.id)
				cSdCmdWriteSingleBlock:	this.write(token);
				cSdCmdReadSingleBlock: this.read(token);
				default: begin
						string msg;
						$swrite(msg, "Token not handled, ID: %b", token.id);
						log.error(msg);
				end
			endcase
		end
	endtask

	task read(SdBusTransToken token);
		SDCommandR1 response;
		logic[31:0] addr;

		// expect Read
		assert(token.id == cSdCmdReadSingleBlock);
		addr = token.arg[0];
		assert(addr < ram.size());
		response = new(cSdCmdReadSingleBlock, state);
		response.DataBlocks = new[1];
		response.DataBlocks[0] = new();
		
		for (int i = 0; i < 512; i++) begin
			for (int j = 7; j >= 0; j--) begin
				response.DataBlocks[0].data.push_back(ram[addr][i*8 + j]);
			end
		end

		this.bfm.send(response);
	endtask

	task write(SdBusTransToken token);
		SDCommandR1 response;
		SdDataBlock rdblock;
		logic[31:0] addr;

		// expect Write
		assert(token.id == cSdCmdWriteSingleBlock);
		addr = token.arg;
		assert(addr < ram.size());
		response = new(cSdCmdWriteSingleBlock, state);
		this.bfm.send(response);

		// recv data
		this.bfm.receiveDataBlock(rdblock);
		$display("rddata: %p", rdblock.data);

		$display("datasize: %h", datasize);
		$display("Address (token): %h", token.arg);
		$display("Address: %h", addr);

		// write into ram
		for (int i = 0; i < 512; i++) begin
			for (int j = 7; j >= 0; j--) begin
				ram[addr][i * 8 + j] = rdblock.data.pop_front();
			end
		end

		this.bfm.waitUntilReady();
		this.bfm.sendBusy();
	
		$display("Ram at write address: %h", ram[addr]);

	endtask

	task recvCMD55(RCA_t rca);
		SDCommandR1 response;
		SdBusTransToken token;
		
		// expect CMD55
		this.bfm.receive(token);
		assert(token.id == cSdCmdNextIsACMD);
		assert(token.arg[31:16] == rca);
		state.recvCMD55();

		// respond with R1
		response = new(cSdCmdNextIsACMD, state);
		this.bfm.send(response);	
	endtask
	
endclass

class NoSdCardModel extends SdCardModel;

	function new();
		super.new();
	endfunction

	task automatic init();
	endtask

endclass

`endif
