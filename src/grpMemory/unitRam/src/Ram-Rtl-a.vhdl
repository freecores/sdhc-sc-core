--
-- Title: Ram
-- File: Ram-Rtl-a.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description:  
--

architecture Rtl of Ram is

	subtype aWord is std_ulogic_vector(gDataWidth - 1 downto 0);
	type aMemory is array (0 to 2**gAddrWidth - 1) of aWord;

	signal memory : aMemory := (others => (others => '0'));

begin

	SinglePort : process (iClk)
	begin
		if (iClk'event and iClk = '1') then
			if (iWe = '1') then
				memory(iAddr) <= iData;

				oData <= iData;
			else
				oData <= memory(iAddr);
			end if;
		end if;
	end process SinglePort;
	
end architecture Rtl;

