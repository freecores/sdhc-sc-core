--
-- Title: Timeout Generator
-- File: TimeoutGenerator-Rtl-a.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: Rtl for TimeoutGenerator 
--

architecture Rtl of TimeoutGenerator is

	constant cMax      : natural := gClkFrequency / (1 sec / gTimeoutTime) - 1;
	constant cBitWidth : natural := LogDualis(cMax);

	signal Counter : unsigned (cBitWidth - 1 downto 0);
	signal Enabled : std_ulogic;

begin

	Regs : process (iClk, inResetAsync)
	begin

		if (inResetAsync = cnActivated) then
			Counter  <= (others => '0');
			Enabled  <= cInactivated;
			oTimeout <= cInactivated;

		elsif (iClk'event and iClk = cActivated) then
			oTimeout <= cInactivated; -- Default
			
			if (iDisable = cActivated) then
				Enabled <= cInactivated;
				Counter <= (others => '0');

			elsif (iEnable = cActivated or Enabled = cActivated) then
				Counter <= Counter + 1;
				Enabled <= cActivated;
				
				if (Counter >= cMax) then
					Counter  <= to_unsigned(0, cBitWidth);
					Enabled  <= cInactivated;
					oTimeout <= cActivated;
				end if;
			end if;

		end if;
	end process Regs;

end architecture Rtl;

