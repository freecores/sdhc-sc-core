//
// file: ../../unitSdVerificationTestbench/src/SdVerificationTestbench.sv
// author: Rainer Kastl
//
// SystemVerilog Testbench testing SdCmd and SdController
//

include "../../unitSdCardModel/src/SdCardModel.sv";
include "../../unitSdVerificationTestbench/src/SdCmdInterface.sv";

`define cCmdCount 1000

const logic[3:0] cSdStandardVoltage = 'b0001; // 2.7-3.6V

program Test(ISdCmd ICmd);
	initial begin
	SDCard card = new(ICmd, $root.Testbed.CmdReceived, $root.Testbed.InitDone);
	SDCommandToken recvCmd, sendCmd;
	int c = 0;

	ICmd.Clk <= 0;
	#10;
	ICmd.nResetAsync <= 0;
	#10;
	ICmd.nResetAsync <= 1;
	
	repeat (2) @ICmd.cb;

    fork
		begin // generator
		end

        begin // monitor
	    end

        begin // driver for SdCardModel
			card.init();

			/*for (int i = 0; i < `cCmdCount; i++) begin
				@$root.Testbed.CardRecv;

				$display("driver2: %0d", i);
				card.recv();
			end*/
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
	ISdCmd CmdInterface();

	TbdSd top(CmdInterface.Clk, CmdInterface.nResetAsync, CmdInterface.Cmd,
CmdInterface.SClk,CmdInterface.Data);

	always #10 CmdInterface.Clk <= ~CmdInterface.Clk;

	Test tb(CmdInterface);

	event ApplyCommand, CardRecv, CmdReceived, GenCmd, InitDone;

endmodule
