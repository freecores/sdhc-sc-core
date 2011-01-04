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
// File        : TbdSd.sv
// Owner       : Rainer Kastl
// Description : 
// Links       : 
// 

`ifndef SDVERIFICATIONTESTBENCH
`define SDVERIFICATIONTESTBENCH

`include "SdCardModel.sv";

program Test(ISdBus SdBus);
	initial begin
	SdBusTransToken token;
	SdBFM SdBfm = new(SdBus);
	SdCardModel card = new();
	assert(card.randomize());
	card.bfm = SdBfm;

    fork
		begin // generator
		end

        begin // monitor
	    end

        begin // driver for SdCardModel
			card.run();
		end

	join;

    $display("%t : Test completed.", $time);
    end	
endprogram

module Testbed();
	logic Clk = 0;
	logic nResetAsync = 0;

	ISdBus CardInterface();

	TbdSd top(
			Clk,
			nResetAsync,
			CardInterface.Cmd,
			CardInterface.SClk,
			CardInterface.Data);

	always #5 Clk <= ~Clk;

	initial begin
		#10 nResetAsync <= 1;
	end

	Test tb(CardInterface);

endmodule

`endif
