//
// file: SdData.sv
// author: Rainer Kastl
//
// Class for sending and receiving data (SD spec 2.00)
//

`ifndef SDDATA
`define SDDATA
 
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

	task automatic recv(virtual ISdCard.card ICard, ref logic rddata[$]);
		aCrc16 crc[4];
		ICard.cb.Data <= 'bzzzz;

		if (mode == wide) begin

			// startbits
			wait(ICard.cb.Data == 'b0000);
			
			$display("Startbits: %t", $time);
			for (int j = 0; j < 512*2; j++) begin
				@ICard.cb;
				for(int i = 0; i < 4; i++) begin
					rddata.push_back(ICard.cb.Data[i]);
				end
			end

			// crc
			
			for (int j = 0; j < 16; j++) begin
				@ICard.cb;
				for(int i = 0; i < 4; i++) begin
					crc[i] = ICard.cb.Data[i];
				end
			end

			// end bits
			@ICard.cb;
			$display("Endbits: %h, %t", ICard.cb.Data, $time);
			assert(ICard.cb.Data == 'b1111);

		end

	endtask

	task automatic send(virtual ISdCard.card ICmd, logic data[$]);
		aCrc16 crc = 0;		

		this.data = data;

		if (mode == standard) begin
			data.push_front(0); // startbit
			CrcOnContainer(data);
			data.push_back(1); // endbit
			
			foreach(data[i]) begin
				@ICmd.cb;
				ICmd.cb.Data[0] <= data[i];
			end

			data = {};
			@ICmd.cb;
			ICmd.cb.Data <= 'z; 
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

			@ICmd.cb;
			ICmd.cb.Data <= 0;

			for(int i = 0; i < dat0.size(); i++) begin
				@ICmd.cb;
				ICmd.cb.Data <= (dat3[i]<<3) + (dat2[i] <<2) + (dat1[i] <<1) + dat0[i];
			end
			
			@ICmd.cb;
			ICmd.cb.Data <= 0;

			@ICmd.cb;
			ICmd.cb.Data <= 'z;			
		end
	endtask

endclass

`endif
