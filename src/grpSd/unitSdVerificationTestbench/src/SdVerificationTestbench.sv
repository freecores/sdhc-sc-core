//
// file: ../../unitSdVerificationTestbench/src/SdVerificationTestbench.sv
// author: Rainer Kastl
//
// SystemVerilog Testbench testing SdCmd and SdController
//

`ifndef SDVERIFICATIONTESTBENCH
`define SDVERIFICATIONTESTBENCH

`define cWishboneWidth 32
const integer cWishboneWidth = 32;
const logic   cAsserted = 1;
const logic   cNegated  = 0;
const logic   cDontCare = 'X;

typedef logic [2:0] aCTI;
const aCTI ClassicCycle = "000";

`include "Harness.sv";
`include "SdCardModel.sv";

program Test(ISdBus SdBus, IWishboneBus WbBus);
	initial begin
		SdCardModel card;
		Harness harness;
		Logger log;

		log = new();
		card = new();
		harness = new(SdBus, WbBus);
		harness.Card = card;

		harness.start();
		#20ms;

		log.terminate();
    end	
endprogram

module Testbed();
	logic Clk = 0;
	logic nResetAsync = 0;

	ISdBus CardInterface();
	IWishboneBus IWbBus();	

	SdTop top(
			IWbBus.CLK_I,
			IWbBus.RST_I,
			IWbBus.CYC_O,
			IWbBus.LOCK_O,
			IWbBus.STB_O,
			IWbBus.WE_O,
			IWbBus.CTI_O,
			IWbBus.BTE_O,
			IWbBus.SEL_O,
			IWbBus.ADR_O,
			IWbBus.DAT_O,
			IWbBus.DAT_I,
			IWbBus.ACK_I,
			IWbBus.ERR_I,
			IWbBus.RTY_I,
			Clk,
			nResetAsync,
			CardInterface.Cmd,
			CardInterface.SClk,
			CardInterface.Data);

	always #5 Clk <= ~Clk;
	always #5 IWbBus.CLK_I <= ~IWbBus.CLK_I;

	initial begin
		#10 nResetAsync <= 1;
		#10 IWbBus.RST_I <= 0;
	end

	Test tb(CardInterface, IWbBus);

endmodule

`endif
