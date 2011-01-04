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
-- File        : Rs232-p.vhdl
-- Owner       : Rainer Kastl
-- Description : Package for Rs232
-- Links       : 
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

