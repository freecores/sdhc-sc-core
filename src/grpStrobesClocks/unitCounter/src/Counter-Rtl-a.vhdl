--
-- Title: Architecture of a generic counter
-- File: Counter-Rtl-a.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description:  
--

architecture Rtl of Counter is

type aReg is record
	Counter : unsigned(gBitWidth - 1 downto 0);
	Enabled : std_ulogic;
end record aReg;

constant cDefaultReg : aReg := (
Counter => (others => '1'),
Enabled => cInactivated);

signal R : aReg := cDefaultReg;

begin

	Regs : process (iClk, inResetAsync)
	begin
		if (inResetAsync = cnActivated) then
			R <= cDefaultReg;
		elsif (iClk'event and iClk = cActivated) then
			oStrobe <= cInactivated;

			if (iDisable = cActivated) then
				R.Enabled <= cInactivated;
				R.Counter <= to_unsigned(0, R.Counter'length);

			elsif (iEnable = cActivated or R.Enabled = cActivated) then
				R.Enabled <= cActivated;

				if (R.Counter = iMax) then
					R.Counter <= to_unsigned(0, R.Counter'length);
					oStrobe   <= cActivated;
					R.Enabled <= cInactivated;

				else 
					R.Counter <= R.Counter + 1;
				end if;

			end if;
		end if;
	end process Regs;

end architecture Rtl;
