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
// File        : SdCardState.sv
// Owner       : Rainer Kastl
// Description : State of an SD Card model
// Links       : 
// 

`ifndef SDCARDSTATE
`define SDCARDSTATE

`include "SDCommandArg.sv"

typedef enum {
	idle = 0, ready = 1, ident = 2, stby = 3, trans = 4,
	data = 5, rcv = 6, prg = 7, dis = 8
} SdCardModelStates;

class SdCardModelState;
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

`endif

