//
// file: ../../unitSdVerificationTestbench/src/SdVerificationTestbench.sv
// author: Rainer Kastl
//
// SystemVerilog Testbench testing SdCmd and SdController
//

include "../../unitSdCardModel/src/SdCardModel.sv";
include "../../unitSdVerificationTestbench/src/SdCmdInterface.sv";

program Test(ISdCmd ICmd);
	initial begin
	SDCard card = new(ICmd, $root.Testbed.CmdReceived);
	SDCommandToken recvCmd, sendCmd;
	bit done = 0;

	ICmd.Clk <= 0;
	#10;
	ICmd.nResetAsync <= 0;
	#10;
	ICmd.nResetAsync <= 1;
	
	repeat (2) @ICmd.cb;

    fork
		begin // generator
			@ICmd.cb;
			sendCmd = new();
			sendCmd.randomize();
			-> $root.Testbed.ApplyCommand;
		end

        begin // monitor
	    end

        begin // driver for SdCmd
			@$root.Testbed.ApplyCommand;
			ICmd.CmdId <= sendCmd.id;
			ICmd.Arg <= sendCmd.arg;
			ICmd.Valid <= 1;
			-> $root.Testbed.CardRecv;
        end

        begin // driver for SdCardModel
			while(done == 0) begin
				card.recv();
				done = 1;
			end
        end

		begin // checker
			@$root.Testbed.CmdReceived;
			recvCmd = card.getCmd();
			recvCmd.display();
			sendCmd.display();
			recvCmd.checkFromHost();
			assert(recvCmd.equals(sendCmd) == 1);
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

	event ApplyCommand, CardRecv, CmdReceived;

endmodule
