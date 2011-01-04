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
// File        : Crc.sv
// Owner       : Rainer Kastl
// Description : CRC calculations using SD CRC polynoms
// Links       : 
// 

`ifndef CRC
`define CRC

typedef logic[6:0] aCrc7;
typedef logic[15:0] aCrc16;

function automatic aCrc7 calcCrc7(logic data[$]);
	aCrc7 crc = 0;

	for(int i = 0; i < data.size(); i++) begin
		if (((crc[6] & 1)) != data[i])
			 crc = (crc << 1) ^ 'b10001001;
		else
			 crc <<= 1;	
	end
	return crc;	
endfunction

function automatic aCrc16 calcCrc16(logic data[$]);
	aCrc16 crc = 0;

	for(int i = 0; i < data.size(); i++) begin
		if (((crc[15] & 1)) != data[i])
			 crc = (crc << 1) ^ 'b10001000000100001;
		else
			 crc <<= 1;	
	end
	return crc;	

endfunction

`endif

