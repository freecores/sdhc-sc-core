//
// file: SdBFM.sv
// author: Rainer Kastl
//
// Bus functional model for SD bus
//
 
`ifndef SDBFM_SV
`define SDBFM_SV

`include "SdBusInterface.sv"
`include "Crc.sv"
`include "Logger.sv"
`include "SDCommandArg.sv"
`include "SdBusTrans.sv"

typedef enum {
	standard,
	wide
} Mode_t;

class SdBFM;

	virtual ISdBus.card ICard;
	SdBfmMb ReceivedTransMb;
	SdBfmMb SendTransMb;
	Mode_t Mode;
	
	extern function new(virtual ISdBus card);

	extern task start(); // starts a thread for receiving and sending via mailboxes
	extern function void stop(int AfterCount); // stop the thread

	extern task send(input SdBusTrans token);
	extern task sendBusy();
	extern task receive(output SdBusTransToken token);
	extern task receiveDataBlock(output SdDataBlock block);
	extern task waitUntilReady();

	extern local task sendCmd(inout SdBusTransData data);
	extern local task sendAllDataBlocks(SdDataBlock blocks[]);
	extern local task sendDataBlock(SdDataBlock block);
	extern local task sendStandardDataBlock(logic data[$]);
	extern local task sendWideDataBlock(logic data[$]);
	extern local task recvDataBlock(output SdDataBlock block);
	extern local task recvStandardDataBlock(output SdDataBlock block);
	extern local task recvWideDataBlock(output SdDataBlock block);
	extern local task recv(output SdBusTransToken token);
	extern local task receiveOrSend();
	extern local task run();
	extern local function void compareCrc16(aCrc16 actual, aCrc16 expected);

	local semaphore Sem;
	local Logger Log;
	local int StopAfter = -1;
endclass

`include "SdBFM-impl.sv";
`endif
