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
-- File        : EdgeDetector-Rtl-a.vhdl
-- Owner       : Rainer Kastl
-- Description : 
-- Links       : See EDS at FH Hagenberg
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.global.all;


architecture Rtl of EdgeDetector is
	signal nQ, detection, Q : std_ulogic;
begin  -- Rtl

	FF1 : process (iClk, inResetAsync) is
	begin  -- process FF1
		if inResetAsync = cnActivated then
			nQ <= cnInactivated;
		elsif iClk'event and iClk = cActivated then  -- rising clock edge
			if (iRstSync = cActivated) then
				nQ <= cnInactivated;
			else
				nQ <= not iLine;
			end if;
		end if;
	end process FF1;

	Gen : if gOutputRegistered = true generate  -- only generate 2nd FF, if
												-- condition is true
		FF2 : process (iClk, iClearEdgeDetected, inResetAsync) is
		begin  -- process FF2
			if inResetAsync = cnActivated then
				Q <= cInactivated;
			elsif iClk'event and iClk = cActivated then  -- rising clock edge
				if (iRstSync = cActivated) then
					Q <= cInactivated;
				else
					if iClearEdgeDetected = cActivated then
						Q <= cInactivated;
					elsif detection = cActivated then
						Q <= cActivated;
					end if;
				end if;
			end if;
		end process FF2;

		oEdgeDetected <= Q;
	end generate;

	Gen2 : if gOutputRegistered = false generate
	  -- else detection is Output
		oEdgeDetected <= detection;
	end generate;

	Detect : process (nQ, iLine) is
	begin
		case gEdgeDetection is
			when cDetectRisingEdge  => detection <= (iLine and nQ);
			when cDetectFallingEdge => detection <= (iLine nor nQ);
			when cDetectAnyEdge     => detection <= (iLine and nQ) or (iLine nor nQ);
			when others             => null;
		end case;
	end process Detect;
end Rtl;
