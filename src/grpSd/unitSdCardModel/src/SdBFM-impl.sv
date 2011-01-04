`ifndef SDBFMIMPL_SV
`define SDBFMIMPL_SV

function SdBFM::new(virtual ISdBus card);
	this.ICard = card;
	this.Log = new;
	this.Sem = new(1);

	// disable outputs
	ICard.cb.Cmd <= 'z;
	ICard.cb.Data <= 'z;
endfunction 

function void SdBFM::stop(int AfterCount);
	StopAfter = AfterCount;
endfunction

task SdBFM::sendCmd(inout SdBusTransData data);
	// startbit
	@ICard.cb;
	ICard.cb.Cmd <= cSdStartbit;

	// data
	begin

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
	
	waitUntilReady();
endtask

task SdBFM::sendAllDataBlocks(SdDataBlock blocks[]);
	foreach(blocks[i]) begin
		sendDataBlock(blocks[i]);
		waitUntilReady();
	end
endtask

task SdBFM::waitUntilReady();
	repeat (8) @ICard.cb;
endtask

task SdBFM::sendDataBlock(SdDataBlock block);
	if (Mode == standard) sendStandardDataBlock(block.data);
	else sendWideDataBlock(block.data);
endtask

task SdBFM::sendStandardDataBlock(logic data[$]);
	data.push_front(0); // startbit
	CrcOnContainer(data);
	data.push_back(1); // endbit

	foreach(data[i]) begin
		@ICard.cb;
		ICard.cb.Data[0] <= data[i];
	end

	@ICard.cb;
	ICard.cb.Data <= 'z; 
endtask

task SdBFM::sendWideDataBlock(logic data[$]);
	logic dat0[$];
	logic dat1[$];
	logic dat2[$];
	logic dat3[$];

	for (int i = 0; i < data.size(); i+=4) begin
		dat3.push_back(data[i]);
		dat2.push_back(data[i+1]);
		dat1.push_back(data[i+2]);
		dat0.push_back(data[i+3]);
	end
	CrcOnContainer(dat0);
	CrcOnContainer(dat1);
	CrcOnContainer(dat2);
	CrcOnContainer(dat3);

	@ICard.cb;
	ICard.cb.Data <= 0;

	for(int i = 0; i < dat0.size(); i++) begin
		@ICard.cb;
		ICard.cb.Data <= (dat3[i]<<3) + (dat2[i] <<2) + (dat1[i] <<1) + dat0[i];
	end
	
	@ICard.cb;
	ICard.cb.Data <= 0;

	@ICard.cb;
	ICard.cb.Data <= 'z;			
endtask

task SdBFM::sendBusy();
	@ICard.cb;
		
	// 10 busy cycles
	ICard.cb.Data[0] <= 0;
	
	repeat (10) @ICard.cb;
	ICard.cb.Data[0] <= 1;

	@ICard.cb;
	ICard.cb.Data <= 'z;
endtask

task SdBFM::send(input SdBusTrans token);
	SdBusTransData data;
	
	this.Sem.get(1);
	data = token.packToData();
	
	if (data.size() > 0) sendCmd(data);
	if (token.DataBlocks.size() > 0) sendAllDataBlocks(token.DataBlocks);
	else if (token.SendBusy == 1) sendBusy();
	
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

task SdBFM::receiveDataBlock(output SdDataBlock block);
	ICard.cb.Data <= 'bzzzz;

	if (Mode == wide) wait (ICard.cb.Data == 'b0000);
	else wait (ICard.cb.Data[0] == '0);

	recvDataBlock(block);
endtask

task SdBFM::recvDataBlock(output SdDataBlock block);
	if (Mode == standard) recvStandardDataBlock(block);
	else recvWideDataBlock(block);
endtask

task SdBFM::recvStandardDataBlock(output SdDataBlock block);
	Log.error("recvStandardDataBlock not implemented");
endtask

task SdBFM::recvWideDataBlock(output SdDataBlock block);
	aCrc16 crc[4];
	block = new();

	$display("Startbits: %t", $time);
	for (int j = 0; j <= 512*2; j++) begin
		@ICard.cb;
		for(int i = 0; i < 4; i++) begin
			block.data.push_back(ICard.cb.Data[i]);
		end
	end

	// crc
	for (int j = 0; j < 16; j++) begin
		@ICard.cb;
		for(int i = 0; i < 4; i++) begin
			crc[i] = ICard.cb.Data[i];
		end
	end

	// TODO: check crc

	// end bits
	@ICard.cb;
	$display("Endbits: %h, %t", ICard.cb.Data, $time);
	assert(ICard.cb.Data == 'b1111);
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
