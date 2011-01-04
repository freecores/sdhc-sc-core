//
// file: unitSdCardModel/src/Crc.sv
// author: Rainer Kastl
//
// CRC7 calculation 
// 

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

