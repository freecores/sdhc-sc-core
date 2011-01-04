-------------------------------------------------
-- author: Rainer Kastl
--
-- CRC implementation with generic polynoms.
--
-- While the data is shifted in bit by bit iDataIn
-- has to be '1'. The CRC can be shifted out by
-- setting iDataIn to '0'.
-- If the CRC should be checked it has to be shifted
-- in directly after the data. If the remainder is 0,
-- the CRC is correct.
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.CRCs.all;

entity crc is
	generic (
		gPolynom : std_ulogic_vector := crc7
	);
	port (
		iClk         : in std_ulogic;
		inResetAsync : in std_ulogic; -- Asynchronous low active reset
		iClear       : in std_ulogic; -- Synchronous reset for the registers
		iDataIn      : in std_ulogic; -- Signal that currently data is shifted in.
		                              -- Otherwise the current remainder is shifted out.
		iData     : in std_ulogic; -- Data input
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
	crc : process (iClk, inResetAsync) is
		variable input : std_ulogic;
	begin
		if (inResetAsync = '0') then
			regs <= (others => '0');
		elsif (rising_edge(iClk)) then
			if (iClear = '1') then
				regs <= (others => '0');
			elsif (iClear = '0') then
				if (iDataIn = '1') then
					-- calculate CRC
					input := iData xor regs(regs'high);

					regs(0) <= input

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
			end if;
		end if;
	end process crc;

	oParallel <= regs;
	oSerial   <= regs(regs'high);

end architecture rtl;
