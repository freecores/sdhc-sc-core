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
	ICmd.Clk <= 0;
	#10;
	ICmd.nResetAsync <= 0;
	#10;
	ICmd.nResetAsync <= 1;
	
	repeat (2) @ICmd.cb;

    fork
		begin // generator
			@ICmd.cb;
			-> $root.Testbed.ApplyCommand;
		end

        begin // monitor
	    end

        begin // driver
			@$root.Testbed.ApplyCommand;
			ICmd.CmdId <= 0;
			ICmd.Arg <= 'h00000000;
			ICmd.Valid <= 1;
        end

        begin // checker (and agent)
        end

    join;

    #1000ns;
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

	event ApplyCommand;

endmodule
