//
// file: unitSdCardModel/src/SDCID.sv
// author: Rainer Kastl
//
// Register CID
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

