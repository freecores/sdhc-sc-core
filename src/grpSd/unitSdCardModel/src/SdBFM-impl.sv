`ifndef SDBFMIMPL_SV
`define SDBFMIMPL_SV

function SdBFM::new(virtual ISdCard card);
	this.ICard = card;
	this.Log = new;
	this.Sem = new(1);

	// disable outputs
	ICard.cb.Cmd <= 'z;
	ICard.cb.Data <= 'z;
endfunction 

function SdBFM::stop(int AfterCount);
	StopAfter = AfterCount;
endfunction

task SdBFM::send(input SdBusTrans token);
	this.Sem.get(1);
	
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

	this.Sem.put(1);		
endtask

task SdBFM::receive(output SdBusTransToken token);
	this.Sem.get(1);

	wait(ICard.cb.Cmd == cSdStartbit);
	recv(token);		
	
	this.Sem.put(1);
endtask

task SdBFM::recv(output SdBusTransToken token);
	token = new();		

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
		this.Log.error("Received invalid endbit during SdBFM.receive.\n");
	end

endtask

task SdBFM::receiveOrSend();
	if(ICard.cb.Cmd == cSdStartbit) begin
		SdBusTransToken token;
		recv(token);
		ReceivedTransMb.put(token);
	end
	else begin
		int flag;
		SdBusTransToken token;

		flag = SendTransMb.try_get(token);
		if (flag == 1) send(token);
		else if (flag == -1) Log.error("Error accessing SendTransMb.");
	end
endtask

task SdBFM::run();
	while (StopAfter != 0) begin
		receiveOrSend();

		if (StopAfter > 0) StopAfter--;
	end
endtask

task SdBFM::start();
	fork
		begin
			run();
		end
	join_any
endtask

`endif
