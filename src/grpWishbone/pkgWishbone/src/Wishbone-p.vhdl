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
	type aEndian is (big, little);

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

	-- Control inputs for a wishbone slave
	-- Unfortunately unconstrained types in records are only supported in
	-- VHDL2008, therefore signals with a range dependend on generics can not be
	-- put inside the record (iSel, iAdr, iDat).
	type aWbSlaveCtrlInput is record
		-- Control signals
		iCyc  :  std_ulogic; -- Indicates a bus cycle
		iLock :  std_ulogic; -- Indicates that the current cycle is not interruptable
		iStb  :  std_ulogic; -- Indicates the selection of the slave
		iWe   :  std_ulogic; -- Write enable, indicates whether the cycle is a read or write cycle
		iCti  :  aCti; -- used for synchronous cycle termination
		iBte  :  aBte; -- Burst type extension
	end record;

	-- Control output signals of a wishbone slave
	-- See aWbSlaveCtrlInput for a explanation why oDat is not in the record.
	type aWbSlaveCtrlOutput is record
		-- Control signals
		oAck : std_ulogic; -- Indicates the end of a normal bus cycle
		oErr : std_ulogic; -- Indicates an error
		oRty : std_ulogic; -- Indicates that the request should be retried
	end record;

end package Wishbone;


