-------------------------------------------------
-- file: Wishbone-p.vhdl
-- author: Rainer Kastl
--
-- Wishbone specific package.
-- Wishbone specification revision B.3
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package Wishbone is
	type endianness is (big, little);

	subtype aCti is std_ulogic_vector(2 downto 0);

	constant cCtiClassicCycle     : aCti := "000";
	constant cCtiConstAdrBurstCyc : aCti := "001";
	constant cCtiIncBurstCyc      : aCti := "010";
	constant cCtiEndOfBurst       : aCti := "111";

	subtype aBte is std_ulogic_vector(1 downto 0);

	constant cBteLinear      : aBte := "00";
	constant cBteFourBeat    : aBte := "01";
	constant cBteEightBeat   : aBte := "10";
	constant cBteSixteenBeat : aBte := "11";

	type aWbState is (idle);

end package Wishbone;


