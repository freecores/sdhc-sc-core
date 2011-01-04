// SDHC-SC-Core
// Secure Digital High Capacity Self Configuring Core
// 
// (C) Copyright 2010 Rainer Kastl
// 
// This file is part of SDHC-SC-Core.
// 
// SDHC-SC-Core is free software: you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
// 
// SDHC-SC-Core is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with SDHC-SC-Core. If not, see http://www.gnu.org/licenses/.
// 
// File        : SDOCR.sv
// Owner       : Rainer Kastl
// Description : SD OCR Register
// Links       : 
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

