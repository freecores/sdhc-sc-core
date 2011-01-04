//
// file: SDOCR.sv
// author: Rainer Kastl
//
// Class for OCR register
// See SD Spec 2.00 page 74 (85 in pdf)
// 

`ifndef SDOCR
`define SDOCR

typedef logic[23:15] voltage_t;
const voltage_t cSdVoltageWindow = 'b111111111;
const logic cOCRBusy = 0;
const logic cOCRDone = 1;

class SDOCR;
	local logic[14:0] reserved; // 7 reserved for low voltage
	local voltage_t voltage;
	local logic[29:24] reserved2;
	local logic CCS;
	local logic busy;

	function new(logic CCS, voltage_t voltage);
		reserved = 0;
		reserved2 = 0;
		this.CCS = CCS;
		this.voltage = voltage;
		this.busy = cOCRBusy;
	endfunction

	function void setBusy(logic busy);
		this.busy = busy;
	endfunction

	function automatic SDCommandArg get();
		SDCommandArg temp = 0;
		temp[31] = busy;
		temp[30] = CCS;
		temp[29:24] = reserved2;
		temp[23:15] = voltage;
		temp[14:0] = reserved;
		return temp;
	endfunction

endclass

`endif

