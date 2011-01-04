//
// file: SdData.sv
// author: Rainer Kastl
//
// Class for sending and receiving data (SD spec 2.00)
//
 
typedef enum {
	standard,
	wide
} Mode_t;

typedef enum {
	usual,
	widewidth
} DataMode_t;

class SdData;
	Mode_t mode;
	DataMode_t datamode;
	logic data[$];

	function new(Mode_t mode, DataMode_t datamode);
		this.mode = mode;
		this.datamode = datamode;
	endfunction

	function void CrcOnContainer(inout logic data[$]);
		aCrc16 crc = 0;
		crc = calcCrc16(data);

		for (int i = 15; i >= 0; i--)
			data.push_back(crc[i]);
	endfunction

	task automatic recv(virtual ISdCard.Card ICard, ref logic rddata[$]);
		aCrc16 crc[4];
		ICard.cbcard.Data <= 'bzzzz;

		if (mode == wide) begin

			// startbits
			wait(ICard.cbcard.Data == 'b0000);
			
			$display("Startbits: %t", $time);
			for (int j = 0; j < 512*2; j++) begin
				@ICard.cbcard;
				for(int i = 0; i < 4; i++) begin
					rddata.push_back(ICard.cbcard.Data[i]);
				end
			end

			// crc
			
			for (int j = 0; j < 16; j++) begin
				@ICard.cbcard;
				for(int i = 0; i < 4; i++) begin
					crc[i] = ICard.cbcard.Data[i];
				end
			end

			// end bits
			@ICard.cbcard;
			$display("Endbits: %h, %t", ICard.cbcard.Data, $time);
			assert(ICard.cbcard.Data == 'b1111);

			$display("%b", ICard.cbcard.Data);

		end

	endtask

	task automatic send(virtual ISdCard.Card ICmd, logic data[$]);
		aCrc16 crc = 0;		

		this.data = data;

		if (mode == standard) begin
			data.push_front(0); // startbit
			CrcOnContainer(data);
			data.push_back(1); // endbit
			
			foreach(data[i]) begin
				@ICmd.cbcard;
				ICmd.cbcard.Data[0] <= data[i];
			end

			data = {};
			@ICmd.cbcard;
			ICmd.cbcard.Data <= 'z; 
		end
		else begin
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

			@ICmd.cbcard;
			ICmd.cbcard.Data = 0;

			for(int i = 0; i < dat0.size(); i++) begin
				@ICmd.cbcard;
				ICmd.cbcard.Data <= (dat3[i]<<3) + (dat2[i] <<2) + (dat1[i] <<1) + dat0[i];
			end
			
			@ICmd.cbcard;
			ICmd.cbcard.Data = 0;

			@ICmd.cbcard;
			ICmd.cbcard.Data <= 'z;			
		end
	endtask

endclass

