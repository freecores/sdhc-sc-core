//
// file: unitSdCardModel/src/Crc.sv
// author: Rainer Kastl
//
// CRC7 calculation 
// 


function automatic aCrc calcCrc(logic data[$]);
	aCrc crc = 0;

	for(int i = 0; i < data.size(); i++) begin
		if (((crc[6] & 1)) != data[i])
			 crc = (crc << 1) ^ 'b10001001;
		else
			 crc <<= 1;	
	end
	return crc;	
endfunction

