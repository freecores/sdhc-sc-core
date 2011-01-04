//
// file: WishboneInterface.sv
// author: Copyright 2010: Rainer Kastl
//
// Description: Wishbone interface
//

`ifndef IWISHBONEBUS
`define IWISHBONEBUS

interface IWishboneBus;

		logic 						 ERR_I;
		logic 												 RTY_I;
		logic 												 CLK_I = 1;
		logic RST_I;
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

