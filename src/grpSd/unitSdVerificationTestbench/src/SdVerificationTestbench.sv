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
// File        : SdVerificationTestbench.sv
// Owner       : Rainer Kastl
// Description : Testbench for verification of SDHC-SC-Core
// Links       : 
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
