--
-- Title: Single ported ram
-- File: SinglePortedRam-e.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: single ported ram
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SinglePortedRam is

	generic (
		gDataWidth : natural := 32;
		gAddrWidth : natural := 7
	);

	port (
		iClk  : std_ulogic;
		iAddr : in natural range 0 to 2**gAddrWidth - 1;
		iData : in std_ulogic_vector(gDataWidth - 1 downto 0);
		iWe   : in std_ulogic;
		oData : out std_ulogic_vector(gDataWidth - 1 downto 0)
	);
end entity SinglePortedRam;	

