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
			// init
			sendCmd = new();

			@ICmd.cb;
			sendCmd.id = cSdCmdGoIdleState;
			sendCmd.arg = 0;
			-> $root.Testbed.ApplyCommand;
			@$root.Testbed.CmdReceived;

			sendCmd.id = cSdCmdSendIfCond;
			sendCmd.arg[31:12] = 0; // Reserved
			sendCmd.arg[11:8] = cSdStandardVoltage; // 2.7 - 3.6V
			sendCmd.arg[7:0] = 'b10101010; // Check pattern, recommended value
			-> $root.Testbed.ApplyCommand;
			@$root.Testbed.CmdReceived;

			ICmd.Valid <= 0;
			@$root.Testbed.InitDone;

			for (int i = 0; i < `cCmdCount; i++) begin
				$display("generator: %0d", i);
				sendCmd = new();
				sendCmd.randomize();
				-> $root.Testbed.ApplyCommand;
				@$root.Testbed.GenCmd;
			end
		end

        begin // monitor
	    end

        begin // driver for SdCmd
			for (int i = 0; i < `cCmdCount + 2; i++) begin
				@$root.Testbed.ApplyCommand;
				
				$display("driver: %0d", i);
				ICmd.CmdId <= sendCmd.id;
				ICmd.Arg <= sendCmd.arg;
				ICmd.Valid <= 1;
				-> $root.Testbed.CardRecv;
			end
        end

        begin // driver for SdCardModel
			card.init();

			for (int i = 0; i < `cCmdCount; i++) begin
				@$root.Testbed.CardRecv;

				$display("driver2: %0d", i);
				card.recv();
			end
        end

		begin // checker
			@$root.Testbed.InitDone;

			for (int i = 0; i < `cCmdCount; i++) begin
				@$root.Testbed.CmdReceived;
				$display("checker: %0d", i);
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

	event ApplyCommand, CardRecv, CmdReceived, GenCmd, InitDone;

endmodule
