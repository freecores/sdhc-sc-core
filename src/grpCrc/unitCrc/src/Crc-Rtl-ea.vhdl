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
-- File        : Crc-Rtl-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : CRC implementation with generic polynoms
-- Links       : 
-- 

-- User information:
-- While the data is shifted in bit by bit iDataIn
-- has to be '1'. The CRC can be shifted out by
-- setting iDataIn to '0'.
-- If the CRC should be checked it has to be shifted
-- in directly after the data. If the remainder is 0,
-- the CRC is correct.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.CRCs.all;

entity crc is
	generic (
		gPolynom : std_ulogic_vector := crc7
	);
	port (
		iClk         : in std_ulogic;
		iRstSync     : in std_ulogic; -- Synchronous high active reset
		iStrobe      : in std_ulogic; -- Strobe, only shift when it is activated
		iClear		 : in std_ulogic; -- Clear register
		iDataIn      : in std_ulogic; -- Signal that currently data is shifted in.
		                              -- Otherwise the current remainder is shifted out.
		iData     : in std_ulogic; -- Data input
		oIsCorrect : out std_ulogic; -- Active, if crc is currently 0
		oSerial   : out std_ulogic; -- Serial data output
		oParallel : out std_ulogic_vector(gPolynom'high - 1 downto gPolynom'low)
		-- parallel data output
	);
	begin
		-- check the used polynom
		assert gPolynom(gPolynom'high) = '1' report
		"Invalid polynom: no '1' at the highest position." severity failure;
		assert gPolynom(gPolynom'low) = '1' report
		"Invalid polynom: no '1' at the lowest position." severity failure;
	end crc;

architecture rtl of crc is

	signal regs : std_ulogic_vector(oParallel'range);

begin

	-- shift registers
	crc : process (iClk) is
		variable input : std_ulogic;
	begin
		if (rising_edge(iClk)) then
			if (iRstSync = '1') then
				regs <= (others => '0');
			else
				if (iStrobe = '1') then
					if (iDataIn = '1') then
					-- calculate CRC
						input := iData xor regs(regs'high);

						regs(0) <= input;

						for idx in 1 to regs'high loop
							if (gPolynom(idx) = '1') then
								regs(idx) <= regs(idx-1) xor input;
							else
								regs(idx) <= regs(idx-1);
							end if;
						end loop;
					else
					-- shift data out
						regs(0) <= '0';
						for idx in 1 to regs'high loop
							regs(idx) <= regs(idx-1);
						end loop;
					end if;
					
					if (iClear = '1') then
						regs <= (others => '0');
					end if;
				end if;
			end if;
		end if;
	end process crc;

	oParallel <= regs;
	oSerial   <= regs(regs'high);
	oIsCorrect <= '1' when regs = std_ulogic_vector(to_unsigned(0,
				  regs'length)) else '0';

end architecture rtl;
