--
-- Title: SdCardSynchronizer
-- File: SdCardSynchronizer-Rtl-ea.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: Synchronizes the SD Card inputs 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.global.all;

entity SdCardSynchronizer is
	generic (
		gSyncCount : natural := 1
	);
	port (

		iClk      : in std_ulogic;
		iRstSync  : in std_ulogic;
		iCmd      : in std_logic;
		iData     : in std_logic_vector(3 downto 0);
		oCmdSync  : out std_ulogic;
		oDataSync : out std_ulogic_vector(3 downto 0)

	);
end entity SdCardSynchronizer;

architecture Rtl of SdCardSynchronizer is

	type aDataSync is array (0 to gSyncCount - 1) of std_ulogic_vector(3 downto 0);

	signal CmdSync  : std_ulogic_vector(gSyncCount - 1 downto 0);
	signal DataSync : aDataSync;

begin

	-- Registers 
	Reg : process (iClk, iRstSync)
	begin
		if (rising_edge(iClk)) then
			-- synchronous reset
			if (iRstSync = cActivated) then

				CmdSync  <= (others => '0');
				DataSync <= (others => (others => '0'));

			else

				-- register input data
				CmdSync(0)  <= iCmd;
				DataSync(0) <= std_ulogic_vector(iData);

				-- additional synchronization FFs
				for i in 1 to gSyncCount - 1 loop

					CmdSync(i)  <= CmdSync(i - 1);
					DataSync(i) <= DataSync(i - 1);

				end loop;
			end if;
		end if;
	end process Reg;

	-- output the last registers

	oCmdSync  <= CmdSync(gSyncCount - 1);
	oDataSync <= DataSync(gSyncCount - 1);

end architecture Rtl;

