//
// file: SdBFM.sv
// author: Rainer Kastl
//
// Bus functional model for SD bus
//
 
`ifndef SDBFM_SV
`define SDBFM_SV

`include "SdCmdInterface.sv"
`include "Crc.sv"
`include "Logger.sv"
`include "SDCommandArg.sv"
`include "SdBusTrans.sv"

typedef mailbox #(SdBusTrans) SdBfmMb;

class SdBFM;

	virtual ISdCard.card ICard;
	SdBfmMb ReceivedTransMb;
	SdBfmMb SendTransMb;
	local semaphore Sem;
	local Logger Log;
	local int StopAfter = -1;

	extern function new(virtual ISdCard card);

	extern task start(); // starts a thread for receiving and sending via mailboxes
	extern function stop(int AfterCount); // stop the thread

	extern task send(input SdBusTrans token);
	extern task receive(output SdBusTransToken token);

	extern local task recv(output SdBusTransToken token);
	extern local task receiveOrSend();
	extern local task run();

endclass

`include "SdBFM-impl.sv";
`endif
