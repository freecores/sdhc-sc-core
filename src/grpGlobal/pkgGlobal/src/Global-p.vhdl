-------------------------------------------------
-- file: Global-p.vhdl
-- author: Rainer Kastl
--
-- Global package contains constants and functions
-- for use everywhere.
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package Global is

	constant cActivated : std_ulogic := '1';
	constant cInactivated : std_ulogic := '0';
	constant cnActivated : std_ulogic := '0';
	constant cnInactivated : std_ulogic := '1';

end package Global;

