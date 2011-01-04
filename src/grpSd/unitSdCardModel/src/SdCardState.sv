//
// file: SdCardState.sv
// author: Rainer Kastl
//
// SDCardState class for use in the SdCardModel
// 

typedef enum {
	idle = 0, ready = 1, ident = 2, stby = 3, trans = 4,
	data = 5, rcv = 6, prg = 7, dis = 8
} SDCardStates;

class SDCardState;
	logic OutOfRange;
	logic AddressError;
	logic BlockLenError;
	logic ComCrcError;
	logic IllegalCommand;
	logic Error;
	logic[3:0] state;	
	logic ReadyForData;
	logic AppCmd;
	logic AkeSeqError;

	function new();
		OutOfRange = 0;
		AddressError = 0;
		BlockLenError = 0;
		ComCrcError = 0;
		IllegalCommand = 0;
		Error = 0;
		state = idle;
		ReadyForData = 0;
		AppCmd = 0;
		AkeSeqError = 0;
	endfunction	

	function void recvCMD55();
		AppCmd = 1;
	endfunction

	function automatic SDCommandArg get();
		SDCommandArg temp = 0;
		temp[31] = OutOfRange;
		temp[30] = AddressError;
		temp[29] = BlockLenError;
		temp[12:9] = state;
		temp[8] = ReadyForData;
		temp[5] = AppCmd;
		return temp;
	endfunction

endclass
