--
-- Title: Simple dual ported ram
-- File: SimpleDualPortedRam-Rtl-a.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description:  
--

architecture Rtl of SimpleDualPortedRam is

	signal tempq : std_logic_vector(31 downto 0);
	signal rdaddr, wraddr : unsigned(6 downto 0);

begin

	Ram_inst: ENTITY work.CycSimpleDualPortedRam
	PORT map
	(
		clock => iClk,
		data => std_logic_vector(iDataRw),
		rdaddress => std_logic_vector(rdaddr),
		wraddress => std_logic_vector(wraddr),
		wren => iWeRW,
		q => tempq
	);

	oDataR <= std_ulogic_vector(tempq);
	rdaddr <= to_unsigned(iAddrR, rdaddr'length);
	wraddr <= to_unsigned(iAddrRW, wraddr'length);
	
end architecture Rtl;

