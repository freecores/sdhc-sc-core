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
// File        : IWishboneBus.sv
// Owner       : Rainer Kastl
// Description : Wishbone bus
// Links       : Wishbone Spec R.3B
// 

`ifndef IWISHBONEBUS
`define IWISHBONEBUS

interface IWishboneBus;

		logic 						 ERR_I;
		logic 												 RTY_I;
		logic 												 CLK_I = 1;
		logic RST_I = 1;
		logic 												 ACK_I;
		logic [`cWishboneWidth-1 : 0] 						 DAT_I;

		logic 												 CYC_O;
		logic [6:4] 						 ADR_O;
		logic [`cWishboneWidth-1 : 0] 						 DAT_O;
		logic [`cWishboneWidth/`cWishboneWidth-1 : 0] SEL_O;
		logic 												 STB_O;
		logic [`cWishboneWidth-1 : 0] 						 TGA_O;
		logic [`cWishboneWidth-1 : 0]						 TGC_O;
		logic 												 TGD_O;
		logic 												 WE_O;
		logic 												 LOCK_O;
		aCTI												 CTI_O;
		logic [1 : 0] 										 BTE_O;

		// Masters view of the interface
		clocking cbMaster @(posedge CLK_I);
			input ERR_I, RTY_I, ACK_I, DAT_I;
			output CYC_O, ADR_O, DAT_O, SEL_O, STB_O, TGA_O, TGC_O, TGD_O, WE_O, LOCK_O, CTI_O, RST_I;
		endclocking
		modport Master (
			input CLK_I, clocking cbMaster
		);

		// Slaves view of the interface
		modport Slave (
			input CLK_I, RST_I, CYC_O, ADR_O, DAT_O, SEL_O, STB_O, TGA_O, TGC_O, TGD_O, WE_O, LOCK_O, CTI_O,
			output ERR_I, RTY_I, ACK_I, DAT_I
		);

endinterface;

`endif

