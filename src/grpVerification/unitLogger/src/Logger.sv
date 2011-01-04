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
// File        : Logger.sv
// Owner       : Rainer Kastl
// Description : Logging facility for verification
// Links       : 
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
  
