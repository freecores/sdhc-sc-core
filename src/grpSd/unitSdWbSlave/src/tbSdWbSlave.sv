
`define cWishboneWidth 32
const integer cWishboneWidth = 32;
const logic   cAsserted = 1;
const logic   cNegated  = 0;
const logic   cDontCare = 'X;

typedef logic [2:0] aCTI;
const aCTI ClassicCycle = "000";

include "../src/WishboneInterface.sv";
include "../src/Wishbone-BFM.sv";


program Test(WishboneInterface BusInterface);
	initial begin
		logic [31:0] data[];
		Wishbone Bus = new(BusInterface.Master);

		data = new [3];
		data[0] = 'h01234567;
		data[1] = 'h89ABCDEF;
		data[2] = 'hFEDCBA98;
		
		BusInterface.RST_I <= 1;
		
		repeat (2) @BusInterface.cbMaster;
		BusInterface.RST_I <= 0;

		Bus.TestSingleOps('b001, 'h0000FFFF);
		Bus.TestBlockOps('b000, data);

		$display("%t : Test completed.", $time);
		repeat(2) @(posedge BusInterface.CLK_I);
		$finish;
	end
endprogram

module Testbed();
	  WishboneInterface Bus();
	  always #10 Bus.CLK_I <= ~Bus.CLK_I;

	  SdWbSlaveWrapper Slave(
			  Bus.CLK_I,
			  Bus.RST_I,
			  Bus.CYC_O,
			  Bus.LOCK_O,
			  Bus.STB_O,
			  Bus.WE_O,
			  Bus.CTI_O,
			  Bus.BTE_O,
			  Bus.ACK_I,
			  Bus.ERR_I,
			  Bus.RTY_I,
			  Bus.SEL_O,
			  Bus.ADR_O,
			  Bus.DAT_O,
			  Bus.DAT_I,
			  '0,
			  'h00000000
			  );

	  Test Program(Bus);
endmodule
