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
// File        : SDCID.sv
// Owner       : Rainer Kastl
// Description : SD Register CID
// Links       : 
// 

`ifndef SDCID
`define SDCID

typedef logic[7:0] manufacturer_id_t;
typedef logic[15:0] app_id_t;
typedef logic[39:0] pname_t;
typedef logic[7:0] prev_t;
typedef logic[31:0] pserialnumber_t;
typedef logic[11:0] manufacturing_date_t;
typedef logic[127:1] cidreg_t; // 1 reserved to endbit

class SDCID;
	local rand manufacturer_id_t mid;
	local rand app_id_t appid;
	local rand pname_t name;
	local rand prev_t rev;
	local rand pserialnumber_t serialnumber;
	local rand manufacturing_date_t date;

	function new();
	endfunction

	function automatic aCrc7 getCrc(cidreg_t cid);
		logic data[$];
		
		for (int i = 127; i >= 8; i--) begin
			data.push_back(cid[i]);
		end
		return calcCrc7(data);
	endfunction

	function automatic cidreg_t get();
		cidreg_t temp = 0;
		temp[127:120] = mid;
		temp[119:104] = appid;
		temp[103:64] = name;
		temp[63:56] = rev;
		temp[55:24] = serialnumber;
		temp[23:20] = 0; // reserved
		temp[19:8] = date;
		temp[7:1] = getCrc(temp); // CRC7
		return temp;
	endfunction

endclass

`endif

