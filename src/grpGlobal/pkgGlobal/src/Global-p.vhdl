--
-- Title: - 
-- File: Global-p.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: Global package contains constants and functions
-- for use everywhere.
--

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


	-- Edge detector
	constant cDetectRisingEdge  : natural := 0;
	constant cDetectFallingEdge : natural := 1;
	constant cDetectAnyEdge     : natural := 2;

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

