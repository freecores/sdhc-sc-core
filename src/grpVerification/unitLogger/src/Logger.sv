//
// file: Logger.sv
// author: Rainer Kastl
//
// 
//

`ifndef LOGGER_SV
`define LOGGER_SV

class Logger;

	local static int errors = 0;
	local static int warnings = 0;

	function new();
	endfunction

	function void note(string msg);
		$write("Note at %t: ", $time);
		$display(msg);
	endfunction

	function void warning(string msg);
		$write("Warning at %t: ", $time);
		$display(msg);
		warnings++;
	endfunction

	function void error(string msg);
		$write("Error at %t: ", $time);
		$display(msg);
		errors++;
	endfunction

	function void terminate();
		$display("Simulation %0sED", (errors) ? "FAIL" : "PASS");
		if (errors > 0) begin
			$display("%d errors.", errors);
		end

		if (warnings > 0) begin
			$display("%d warnings.", warnings);
		end
	endfunction

endclass

`endif
  
