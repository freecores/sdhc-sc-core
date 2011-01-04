//
// file: ../../unitSdVerificationTestbench/src/SdVerificationTestbench.sv
// author: Rainer Kastl
//
// SystemVerilog Testbench testing SdCmd and SdController
//

`ifndef SDVERIFICATIONTESTBENCH
`define SDVERIFICATIONTESTBENCH

`include "SdCardModel.sv";

program Test(ISdBus SdBus);
	initial begin
	SdBusTransToken token;
	SdBFM SdBfm = new(SdBus);
	SDCard card = new(SdBfm);
	assert(card.randomize());

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
