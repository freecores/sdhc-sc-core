-------------------------------------------------------------------------------
-- Title      : Strobe Generator
-- Project    : 
-------------------------------------------------------------------------------
-- $Id: StrobeGen-Rtl-a.vhd,v 1.1 2003/04/08 13:51:09 pfaff Exp $
-------------------------------------------------------------------------------
-- Author     : Copyright 2003: Markus Pfaff
-- Standard   : Using VHDL'93
-- Simulation : Model Technology Modelsim
-- Synthesis  : Exemplar Leonardo
-------------------------------------------------------------------------------
-- Description:
-- Description for synthesis.
-------------------------------------------------------------------------------
architecture Rtl of StrobeGen is

   constant max       : natural                           := gClkFrequency/(1 sec/ gStrobeCycleTime);
   constant cBitWidth : natural                           := LogDualis(max);  -- Bitwidth
   signal   Counter   : unsigned (cBitWidth - 1 downto 0) := (others => '0');

begin  -- architecture Rtl

   StateReg : process (iClk, inResetAsync) is
   begin  -- process StateReg
      if inResetAsync = cnActivated then  -- asynchronous reset (active low)
         Counter <= (others => '0');
         oStrobe <= cInactivated;
      elsif iClk'event and iClk = cActivated then  -- rising clock edge
         Counter <= Counter + 1;
         if Counter < max - 1 then
            oStrobe <= cInactivated;
         else
            oStrobe <= cActivated;
            Counter <= TO_UNSIGNED(0, cBitWidth);
         end if;
      end if;
   end process StateReg;
end architecture Rtl;
