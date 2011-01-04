--
-- Title: Simple dual ported ram
-- File: SimpleDualPortedRam-e.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: one write/read port and one read only port
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SimpleDualPortedRam is

	generic (
		gDataWidth : natural := 32;
		gAddrWidth : natural := 7
	);

	port (
		iClk    : std_ulogic;
		iAddrRW : in natural range 0 to 2**gAddrWidth - 1;
		iDataRW : in std_ulogic_vector(gDataWidth - 1 downto 0);
		iWeRW   : in std_ulogic;
		oDataRW : out std_ulogic_vector(gDataWidth - 1 downto 0);
		iAddrR  : in natural range 0 to 2**gAddrWidth - 1;
		oDataR  : out std_ulogic_vector(gDataWidth - 1 downto 0)
	);
end entity SimpleDualPortedRam;	

