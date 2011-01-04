//
// file: ../../unitSdVerificationTestbench/src/SdVerificationTestbench.sv
// author: Rainer Kastl
//
// SystemVerilog Testbench testing SdCmd and SdController
//

include "../../unitSdCardModel/src/SdCardModel.sv";
include "../../unitSdVerificationTestbench/src/SdCmdInterface.sv";

`define cCmdCount 1000

program Test(ISdCmd ICmd);
	initial begin
	SDCard card = new(ICmd, $root.Testbed.CmdReceived);
	SDCommandToken recvCmd, sendCmd;
	bit done = 0;
	int c = 0;

	ICmd.Clk <= 0;
	#10;
	ICmd.nResetAsync <= 0;
	#10;
	ICmd.nResetAsync <= 1;
	
	repeat (2) @ICmd.cb;

    fork
		begin // generator
			for (int i = 0; i < `cCmdCount; i++) begin
				@ICmd.cb;
				sendCmd = new();
				sendCmd.randomize();
				-> $root.Testbed.ApplyCommand;
				@$root.Testbed.GenCmd;
			end
		end

        begin // monitor
	    end

        begin // driver for SdCmd
			for (int i = 0; i < `cCmdCount; i++) begin
				@$root.Testbed.ApplyCommand;
				ICmd.CmdId <= sendCmd.id;
				ICmd.Arg <= sendCmd.arg;
				ICmd.Valid <= 1;
				-> $root.Testbed.CardRecv;
			end
        end

        begin // driver for SdCardModel
			for (int i = 0; i < `cCmdCount; i++) begin
				@$root.Testbed.CardRecv;
				card.recv();
			end
        end

		begin // checker
			for (int i = 0; i < `cCmdCount; i++) begin
				@$root.Testbed.CmdReceived;
				recvCmd = card.getCmd();
				//recvCmd.display();
				//sendCmd.display();
				recvCmd.checkFromHost();
				assert(recvCmd.equals(sendCmd) == 1);
				-> $root.Testbed.GenCmd;
			end
		end

    join;

    $display("%t : Test completed.", $time);
    end	
endprogram

module Testbed();
	ISdCmd CmdInterface();

	SdCmdWrapper CmdWrapper(CmdInterface.Clk, CmdInterface.nResetAsync,
		CmdInterface.CmdId, CmdInterface.Arg, CmdInterface.Valid,
		CmdInterface.Receiving, CmdInterface.Cmd);

	always #10 CmdInterface.Clk <= ~CmdInterface.Clk;

	Test tb(CmdInterface);

	event ApplyCommand, CardRecv, CmdReceived, GenCmd;

endmodule
