--
-- Title: Synchronizer
-- File: Synchronizer-Rtl-ea.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: Synchronizes a signal from one clock domain to another 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.global.all;

entity Synchronizer is
	generic (
		gSyncCount : natural := 2
	);
	port (
		-- Resets
		inResetAsync : in std_ulogic := '1';
		iRstSync     : in std_ulogic := '0';

		iToClk       : in std_ulogic;
		iSignal      : in std_ulogic;

		oSync        : out std_ulogic
	);
end entity Synchronizer;

architecture Rtl of Synchronizer is

	signal Sync : std_ulogic_vector(gSyncCount - 1 downto 0);

begin

	SyncReg : process (iToClk, inResetAsync)
	begin
		-- asynchronous reset
		if (inResetAsync = cActivated) then
			Sync <= (others => '0');

		elsif (rising_edge(iToClk)) then
			-- synchronous reset
			if (iRstSync = cActivated) then
				Sync <= (others => '0');

			else
				-- synchronize
				Sync(0) <= iSignal;

				for i in 1 to gSyncCount - 1 loop

					Sync(i) <= Sync(i-1);

				end loop;

			end if;
		end if;	
	end process SyncReg;

	oSync <= Sync(gSyncCount - 1);

end architecture Rtl;

