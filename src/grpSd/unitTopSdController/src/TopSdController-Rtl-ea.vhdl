-------------------------------------------------
-- file: TopSdController-Rtl-ea.vhdl
-- author: Rainer Kastl
--
-- Testbed for a application with a SdController.
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TopSdController is
	-- Port names follow SD mode, description for SPI mode in comments
	port (CLK : in std_ulogic; -- SCLK
		  CMD : inout std_ulogic; -- DI, data in
		  DAT0 : inout std_ulogic; -- DO, data out
		  DAT1 : inout std_ulogic; -- IRQ
		  DAT2 : inout std_ulogic; -- none
		  DAT3 : inout std_ulogic); -- CS

end entity TopSdController;

architecture Rtl of TopSdController is
begin


end architecture Rtl;

