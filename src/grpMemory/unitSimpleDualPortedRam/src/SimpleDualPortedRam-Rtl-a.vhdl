--
-- Title: Simple dual ported ram
-- File: SimpleDualPortedRam-Rtl-a.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description:  
--

architecture Rtl of SimpleDualPortedRam is

	subtype aWord is std_ulogic_vector(gDataWidth - 1 downto 0);
	type aMemory is array (0 to 2**gAddrWidth - 1) of aWord;

	signal memory : aMemory := (others => (others => '0'));

begin

	DualPort : process (iClk)
	begin
		if (iClk'event and iClk = '1') then
			if (iWeRW = '1') then
				memory(iAddrRW) <= iDataRW;

				oDataRW <= iDataRW;
			else
				oDataRW <= memory(iAddrRW);
			end if;

			oDataR <= memory(iAddrR);
		end if;
	end process DualPort;
	
end architecture Rtl;

