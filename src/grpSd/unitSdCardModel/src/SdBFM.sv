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

const logic cSdStartbit = 0;
const logic cSdEndbit = 1;

typedef logic SdBusTransData[$];

virtual class SdBusTrans;
	virtual function SdBusTransData packToData();
	endfunction

	virtual function void unpackFromData(ref SdBusTransData data);
	endfunction
endclass

class SdBusTransToken extends SdBusTrans;
	
	logic transbit;
	logic[5:0] id;
	SDCommandArg arg;
	aCrc7 crc;

	function aCrc7 calcCrcOfToken();
		logic temp[$] = { >> { cSdStartbit, this.transbit, this.id, this.arg}};
		return calcCrc7(temp);
	endfunction

	virtual function SdBusTransData packToData();
		SdBusTransData data = { >> {transbit, id, arg, crc}};
		return data;
	endfunction
	
	virtual function void unpackFromData(ref SdBusTransData data);
		{ >> {transbit, id, arg, crc}} = data;	
	endfunction

endclass;

class SdBFM;

	virtual ISdCard.card ICard;
	local semaphore sem;
	local Logger log;

	function new(virtual ISdCard card);
		this.ICard = card;
		this.log = new;
		this.sem = new(1);

		// disable outputs
		ICard.cb.Cmd <= 'z;
		ICard.cb.Data <= 'z;
	endfunction 

	task send(input SdBusTrans token);
		this.sem.get(1);
		
		// startbit
		@ICard.cb;
		ICard.cb.Cmd <= cSdStartbit;

		// data
		begin
			SdBusTransData data = token.packToData();

			foreach(data[i]) begin
				@ICard.cb;
				ICard.cb.Cmd <= data[i];
			end
			data.delete();
		end

		// endbit
		@ICard.cb;
		ICard.cb.Cmd <= cSdEndbit;

		@ICard.cb;
		ICard.cb.Cmd <= 'z;

		this.sem.put(1);		
	endtask

	task receive(output SdBusTransToken token);
		this.sem.get(1);
		token = new();		

		wait(ICard.cb.Cmd == cSdStartbit);
		
		// data
		begin
			SdBusTransData data;

			for (int i = 0; i < 46; i++) begin
				@ICard.cb;
				data.push_back(ICard.cb.Cmd);
			end

			token.unpackFromData(data);
		end

		// endbit
		@ICard.cb;
		assert(ICard.cb.Cmd == cSdEndbit) else
		begin
			this.log.error("Received invalid endbit during SdBFM.receive.\n");
		end

		this.sem.put(1);
	endtask

endclass

`endif
