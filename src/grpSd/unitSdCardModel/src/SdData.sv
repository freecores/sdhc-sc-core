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

	function new(Mode_t mode, DataMode_t datamode);
		this.mode = mode;
		this.datamode = datamode;
	endfunction

	task automatic send(virtual ISdCmd.Card ICmd, logic data[$]);
		aCrc16 crc = 0;		
		
		data.push_front(0); // startbit
		crc = calcCrc16(data);

		for (int i = 15; i >= 0; i--)
			data.push_back(crc[i]);

		data.push_back(1); // endbit
		
		foreach(data[i]) begin
			@ICmd.cb;
			ICmd.cb.Data[0] <= data[i];
		end

		data = {};
		@ICmd.cb;
		ICmd.cb.Data <= 'z; 
	endtask

endclass

