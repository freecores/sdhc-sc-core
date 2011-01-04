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


`include "SdCardModel.sv";
`include "SdCmdInterface.sv";
`include "Wishbone-BFM.sv";

`define cCmdCount 1000

const logic[3:0] cSdStandardVoltage = 'b0001; // 2.7-3.6V

program Test(ISdCard ICmd, WishboneInterface BusInterface);
	initial begin
	logic[31:0] rd;
	Wishbone Bus = new(BusInterface.Master);
	SDCard card = new(ICmd, $root.Testbed.CmdReceived, $root.Testbed.InitDone);
	SDCommandToken recvCmd, sendCmd;
	int c = 0;

	assert(card.randomize());
	ICmd.nResetAsync <= 0;
	BusInterface.RST_I <= 1;
	#10;
	ICmd.nResetAsync <= 1;
	BusInterface.RST_I <= 0;
	
	repeat (2) @ICmd.cb;

    fork
		begin // generator
		end

        begin // monitor
	    end

        begin // driver for SdCardModel
			card.init();
			card.write();
			card.read();

			/*for (int i = 0; i < `cCmdCount; i++) begin
				@$root.Testbed.CardRecv;

				$display("driver2: %0d", i);
				card.recv();
			end*/
        end

		begin // driver for wishbone interface
			@$root.Testbed.InitDone;

			Bus.Write('b100, 'h04030201);
			Bus.Write('b001, 'h00000001);
			Bus.Write('b000, 'h00000010);

			#10000;
			Bus.Write('b100, 'h02020202);
			Bus.Write('b100, 'h03030303);
			Bus.Write('b100, 'h04040404);
			Bus.Write('b100, 'h05050505);
			Bus.Write('b100, 'h06060606);
			Bus.Write('b100, 'h07070707);
			Bus.Write('b100, 'h08080808);

			for (int i = 0; i < 512; i++)
				Bus.Write('b100, 'h09090909);

			Bus.Write('b000, 'h00000001);

			for (int i = 0; i < 128; i++) begin
				Bus.Read('b011, rd);
				$display("Read: %h", rd);
			end

		end

		begin // checker
			@$root.Testbed.InitDone;
/*
			for (int i = 0; i < `cCmdCount; i++) begin
				@$root.Testbed.CmdReceived;
				$display("checker: %0d", i);
				recvCmd = card.getCmd();
				//recvCmd.display();
				//sendCmd.display();
				recvCmd.checkFromHost();
				assert(recvCmd.equals(sendCmd) == 1);
				-> $root.Testbed.GenCmd;
			end*/
		end

    join;

    $display("%t : Test completed.", $time);
    end	
endprogram

module Testbed();
	ISdCard CardInterface();
	WishboneInterface BusInterface();	

	SdTop top(
			BusInterface.CLK_I,
			BusInterface.RST_I,
			BusInterface.CYC_O,
			BusInterface.LOCK_O,
			BusInterface.STB_O,
			BusInterface.WE_O,
			BusInterface.CTI_O,
			BusInterface.BTE_O,
			BusInterface.SEL_O,
			BusInterface.ADR_O,
			BusInterface.DAT_O,
			BusInterface.DAT_I,
			BusInterface.ACK_I,
			BusInterface.ERR_I,
			BusInterface.RTY_I,
			CardInterface.Clk,
			CardInterface.nResetAsync,
			CardInterface.Cmd,
			CardInterface.SClk,
			CardInterface.Data);

	always #5 CardInterface.Clk <= ~CardInterface.Clk;
	always #5 BusInterface.CLK_I <= ~BusInterface.CLK_I;

	Test tb(CardInterface, BusInterface);

	event ApplyCommand, CardRecv, CmdReceived, GenCmd, InitDone;

endmodule

`endif
