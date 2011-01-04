-- SDHC-SC-Core
-- Secure Digital High Capacity Self Configuring Core
-- 
-- (C) Copyright 2010 Rainer Kastl
-- 
-- This file is part of SDHC-SC-Core.
-- 
-- SDHC-SC-Core is free software: you can redistribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or (at
-- your option) any later version.
-- 
-- SDHC-SC-Core is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public License
-- along with SDHC-SC-Core. If not, see http://www.gnu.org/licenses/.
-- 
-- File        : Global-p.vhdl
-- Owner       : Rainer Kastl
-- Description : Global constants and functions
-- Links       : 
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

