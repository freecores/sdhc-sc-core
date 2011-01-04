//
// file: Wishbone-BFM.sv
// author: Copyright 2010: Rainer Kastl
//
// Description: Bus functional model for wishbone registered feedback
// Wishbone spec Revision B.3
//

class Wishbone;

	virtual WishboneInterface.Master Bus;

	function new(virtual WishboneInterface.Master Bus);
		this.Bus = Bus;
	endfunction

	task Idle();

		@(posedge this.Bus.CLK_I)
		this.Bus.cbMaster.CYC_O  <= cNegated;
		this.Bus.cbMaster.ADR_O  <= '{default: cDontCare};
		this.Bus.cbMaster.DAT_O  <= '{default: cDontCare};
		this.Bus.cbMaster.SEL_O  <= '{default: cDontCare};
		this.Bus.cbMaster.STB_O  <= cNegated;
		this.Bus.cbMaster.TGA_O  <= '{default: cDontCare};
		this.Bus.cbMaster.TGC_O  <= '{default: cDontCare};
		this.Bus.cbMaster.TGD_O  <= cDontCare;
		this.Bus.cbMaster.WE_O   <= cDontCare;
		this.Bus.cbMaster.LOCK_O <= cNegated;
		this.Bus.cbMaster.CTI_O  <= '{default: cDontCare};
		$display("%t : Bus idle.", $time);

	endtask;

	function void checkResponse();

		// Analyse slave response
		if (this.Bus.cbMaster.ERR_I == cAsserted) begin
			$display("%t : MasterWrite: ERR_I asserted; Slave encountered an error.", $time);
		end
		if (this.Bus.cbMaster.RTY_I == cAsserted) begin
			$display("%t : MasterWrite: RTY_I asserted; Retry requested.", $time);
		end

	endfunction;

	task Read(logic [`cWishboneWidth-1 : 0] Address,
			   ref logic [`cWishboneWidth-1 : 0] Data,
			   input logic [`cWishboneWidth-1 : 0] TGA = '{default: cDontCare},
			   input logic [`cWishboneWidth-1 : 0] BankSelect = '{default: 1});

		@(posedge this.Bus.CLK_I);
		this.Bus.cbMaster.ADR_O <= Address;
		this.Bus.cbMaster.TGA_O <= TGA;
		this.Bus.cbMaster.WE_O <= cNegated;
		this.Bus.cbMaster.SEL_O <= BankSelect;
		this.Bus.cbMaster.CYC_O <= cAsserted;
		this.Bus.cbMaster.TGC_O <= cAsserted;
		this.Bus.cbMaster.STB_O <= cAsserted;
		this.Bus.cbMaster.CTI_O <= ClassicCycle;

		//$display("%t : MasterRead: Waiting for slave resonse", $time);
		// Wait until slave responds
		wait ((this.Bus.cbMaster.ACK_I == cAsserted)
		||  (this.Bus.cbMaster.ERR_I == cAsserted)
		||  (this.Bus.cbMaster.RTY_I == cAsserted));

		checkResponse();

		Data = this.Bus.cbMaster.DAT_I; // latch it before the CLOCK???
		//$display("%t : Reading %h", $time, Data);

		this.Bus.cbMaster.STB_O <= cNegated;
		this.Bus.cbMaster.CYC_O <= cNegated;
		@(posedge this.Bus.CLK_I);

	endtask;

	task BlockRead(logic [`cWishboneWidth-1 : 0] Address,
					ref logic [`cWishboneWidth-1 : 0] Data[],
					input logic [`cWishboneWidth-1 : 0] TGA = '{default: cDontCare},
					input logic [`cWishboneWidth-1 : 0] BankSelect = '{default: 1});

		foreach(Data[i]) begin
			this.Bus.cbMaster.WE_O <= cNegated;
			this.Bus.cbMaster.CYC_O <= cAsserted;
			this.Bus.cbMaster.TGC_O <= cAsserted;
			this.Bus.cbMaster.STB_O <= cAsserted;
			this.Bus.cbMaster.LOCK_O <= cAsserted;
			this.Bus.cbMaster.ADR_O <= Address+i;
			this.Bus.cbMaster.TGA_O <= TGA;
			this.Bus.cbMaster.SEL_O <= BankSelect;
			this.Bus.cbMaster.CTI_O <= ClassicCycle;
			@(posedge this.Bus.CLK_I);

			//$display("%t : MasterRead: Waiting for slave response.", $time);
			// Wait until slave responds
			wait ((this.Bus.cbMaster.ACK_I == cAsserted)
			||  (this.Bus.cbMaster.ERR_I == cAsserted)
			||  (this.Bus.cbMaster.RTY_I == cAsserted));

			checkResponse();
			Data[i] = this.Bus.cbMaster.DAT_I;
			//$display("%t : Reading %h", $time, Data[i]);
		end

		this.Bus.cbMaster.STB_O <= cNegated;
		this.Bus.cbMaster.CYC_O <= cNegated;
		this.Bus.cbMaster.LOCK_O <= cNegated;
		@(posedge this.Bus.CLK_I);

	endtask;

	task Write(logic [`cWishboneWidth-1 : 0] Address,
	           logic [`cWishboneWidth-1 : 0] Data,
	           logic [`cWishboneWidth-1 : 0] TGA = '{default: cDontCare},
	           logic [`cWishboneWidth-1 : 0] TGD = cDontCare,
	           logic [`cWishboneWidth-1 : 0] BankSelect = '{default: 1});

		@(posedge this.Bus.CLK_I)
		// CLOCK EDGE 0
		this.Bus.cbMaster.ADR_O <= Address;
		this.Bus.cbMaster.TGA_O <= TGA;
		this.Bus.cbMaster.DAT_O <= Data;
		this.Bus.cbMaster.TGD_O <= TGD;
		this.Bus.cbMaster.WE_O  <= cAsserted;
		this.Bus.cbMaster.SEL_O <= BankSelect;
		this.Bus.cbMaster.CYC_O <= cAsserted;
		this.Bus.cbMaster.TGC_O <= cAsserted; // Assert all?
		this.Bus.cbMaster.STB_O <= cAsserted;
		this.Bus.cbMaster.CTI_O <= ClassicCycle;
		//$display("%t : MasterWrite: Waiting for slave response.", $time);
		// Wait until slave responds

		wait ((this.Bus.cbMaster.ACK_I == cAsserted)
			||  (this.Bus.cbMaster.ERR_I == cAsserted)
			||  (this.Bus.cbMaster.RTY_I == cAsserted));
		checkResponse();
		this.Bus.cbMaster.STB_O <= cNegated;
		this.Bus.cbMaster.CYC_O <= cNegated;

		@(posedge this.Bus.CLK_I);
		// CLOCK EDGE 1
		//$display("%t : MasterWrite completed.", $time);
	endtask;

	task BlockWrite (logic [`cWishboneWidth-1 : 0] Address,
	                 logic [`cWishboneWidth-1 : 0] Data [],
	                 logic [`cWishboneWidth-1 : 0] TGA = '{default: cDontCare},
	                 logic [`cWishboneWidth-1 : 0] TGD = cDontCare,
	                 logic [`cWishboneWidth-1 : 0] BankSelect = '{default: 1}
	);

		foreach(Data[i]) begin

			@(posedge this.Bus.CLK_I)
			// CLOCK EDGE 0
			this.Bus.cbMaster.ADR_O <= Address + i;
			this.Bus.cbMaster.TGA_O <= TGA;
			this.Bus.cbMaster.DAT_O <= Data[i];
			this.Bus.cbMaster.TGD_O <= TGD;
			this.Bus.cbMaster.WE_O  <= cAsserted;
			this.Bus.cbMaster.SEL_O <= BankSelect;
			this.Bus.cbMaster.CYC_O <= cAsserted;
			this.Bus.cbMaster.TGC_O <= cAsserted; // Assert all?
			this.Bus.cbMaster.STB_O <= cAsserted;
			this.Bus.cbMaster.LOCK_O <= cAsserted;
			this.Bus.cbMaster.CTI_O <= ClassicCycle;

			// Wait until slave responds
			wait ((this.Bus.cbMaster.ACK_I == cAsserted)
			||  (this.Bus.cbMaster.ERR_I == cAsserted)
			||  (this.Bus.cbMaster.RTY_I == cAsserted));
			checkResponse();
			//$display("%t : MasterBlockWrite phase %d completed.", $time, i);
		end

		this.Bus.cbMaster.STB_O <= cNegated;
		this.Bus.cbMaster.CYC_O <= cNegated;
		this.Bus.cbMaster.LOCK_O <= cNegated;
		@(posedge this.Bus.CLK_I);
		// CLOCK EDGE 1
		//$display("%t : MasterBlockWrite completed.", $time);
	endtask;

	task TestSingleOps (logic [`cWishboneWidth-1 : 0] Address,
					   logic [`cWishboneWidth-1 : 0] Data);

		logic [`cWishboneWidth-1 : 0] rd;

		this.Write(Address, Data);
		this.Read(Address, rd);

		$display("%t : %h (read) == %h (written)", $time, rd, Data);
		assert (rd == Data);
	endtask;

	task TestBlockOps (logic [`cWishboneWidth-1 : 0] Address,
						logic [`cWishboneWidth-1 : 0] Data []);

		logic [`cWishboneWidth-1 : 0] blockData [];

		blockData = new [Data.size()];

		this.BlockWrite(Address, Data);
		this.BlockRead(Address, blockData);

		foreach(blockData[i]) begin
			$display("%t : %h (read) == %h (written)", $time, blockData[i], Data[i]);
			assert (Data[i] == blockData[i]);
		end

		blockData.delete();

	endtask;

endclass
