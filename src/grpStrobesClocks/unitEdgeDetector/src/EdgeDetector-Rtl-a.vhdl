-------------------------------------------------------------------------------
-- Title      : -
-- Project    : General IP
-------------------------------------------------------------------------------
-- $Id: EdgeDetector-Rtl-a.vhd,v 1.1 2004/05/09 19:32:20 fseebach Exp $
-------------------------------------------------------------------------------
-- Author     : Copyright 2004: Markus Pfaff, Friedrich Seebacher
-- Standard   : Using VHDL'93
-- Simulation : Model Technology Modelsim
-- Synthesis  : Exemplar Leonardo
-------------------------------------------------------------------------------
-- Description:
--       Detects an edge on the input signal. The activation is configured by the
--   generic parameter gEdgeDetection.
-------------------------------------------------------------------------------

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
         nQ <= not iLine;
      end if;
   end process FF1;

   Gen : if gOutputRegistered = true generate  -- only generate 2nd FF, if
      -- condition is true
      FF2 : process (iClk, iClearEdgeDetected, inResetAsync) is
      begin  -- process FF2
         if inResetAsync = cnActivated then
            Q <= cInactivated;
         elsif iClk'event and iClk = cActivated then  -- rising clock edge
            if iClearEdgeDetected = cActivated then
               Q <= cInactivated;
            elsif detection = cActivated then
               Q <= cActivated;
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
