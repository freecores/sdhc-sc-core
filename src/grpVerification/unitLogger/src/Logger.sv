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

	function new();
	endfunction

	function void note(string msg);
		$write("Note at %t: ", $time);
		$display(msg);
	endfunction

	function void warning(string msg);
		$write("Warning at %t: ", $time);
		$display(msg);
	endfunction

	function void error(string msg);
		$write("Error at %t: ", $time);
		$display(msg);
	endfunction

	function void terminate();
		$display("Simulation %0sED", (errors) ? "FAIL" : "PASS" );
	endfunction

endclass

`endif
  
