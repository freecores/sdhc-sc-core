--
-- Title: Package for Rs232
-- File: Rs232-p.vhdl
-- Author: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description:  
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Rs232 is

	constant cTxLineStartBitVal : std_ulogic := '0';
	constant cTxLineStopBitVal  : std_ulogic := '1';

	-- unfortunately this vhdl standard does not support unconstrained types
	-- in records
	constant cRs232DataWidth : natural := 8;

	type aiRs232Tx is record
		Transmit      : std_ulogic;
		DataAvailable : std_ulogic;
		BitStrobe     : std_ulogic;
		Data          : std_ulogic_vector(cRs232DataWidth - 1 downto 0);
	end record aiRs232Tx;

	type aoRs232Tx is record
		DataWasRead : std_ulogic;
		Tx          : std_ulogic;
	end record aoRs232Tx;

end package Rs232;

