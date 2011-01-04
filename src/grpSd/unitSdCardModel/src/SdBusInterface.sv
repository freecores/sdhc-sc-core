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
// File        : SdBusInterface.sv
// Owner       : Rainer Kastl
// Description : SD Bus
// Links       : 
// 

`ifndef SDBUSINTERFACE_SV
`define SDBUSINTERFACE_SV

interface ISdBus;
	wire Cmd;
	logic SClk;
	wire[3:0] Data;

	clocking cb @(posedge SClk);
		inout Cmd;
		inout Data;
	endclocking

	modport card (clocking cb);

endinterface

`endif

