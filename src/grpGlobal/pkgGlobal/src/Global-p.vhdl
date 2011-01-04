-------------------------------------------------
-- file: Global-p.vhdl
-- author: Rainer Kastl
--
-- Global package contains constants and functions
-- for use everywhere.
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

package Global is

    constant cActivated    :  std_ulogic := '1';
    constant cInactivated  :  std_ulogic := '0';
    constant cnActivated   :  std_ulogic := '0';
    constant cnInactivated :  std_ulogic := '1';

	subtype aLedBank is std_ulogic_vector(7 downto 0);

	function LogDualis(cNumber : natural) return natural;

end package Global;

package body Global is

	
	function LogDualis(cNumber : natural) return natural is
		variable vClimbUp : natural;
		variable vResult  : natural;
	begin
		vClimbUp := 1;
		vResult := 0;
		while vClimbUp < cNumber loop
			vClimbUp := vClimbUp * 2;
			vResult  := vResult+1;
		end loop;
		return vResult;
	end function LogDualis;

end package body Global;

