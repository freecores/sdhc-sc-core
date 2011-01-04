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
	local logic OutOfRange;
	local logic AddressError;
	local logic BlockLenError;

	local logic[3:0] state;	

	local logic AppCmd;

	function new();
		OutOfRange = 0;
		AddressError = 0;
		BlockLenError = 0;
		state = idle;
		AppCmd = 0;
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
		temp[5] = AppCmd;
		return temp;
	endfunction

endclass
