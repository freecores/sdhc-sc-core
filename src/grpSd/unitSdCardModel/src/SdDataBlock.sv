//
// file: SdData.sv
// author: Rainer Kastl
//
// Class for sending and receiving data (SD spec 2.00)
//

`ifndef SDDATA
`define SDDATA
 
typedef enum {
	usual,
	widewidth
} DataMode_t;

function automatic void CrcOnContainer(ref logic data[$]);
	aCrc16 crc = 0;
	crc = calcCrc16(data);

	for (int i = 15; i >= 0; i--)
		data.push_back(crc[i]);
endfunction

class SdDataBlock;
	DataMode_t Mode;
	logic data[$];
endclass

`endif
