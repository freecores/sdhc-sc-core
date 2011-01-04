--
-- Title: Wishbone master for test purpose
-- File: TestWbMaster-e.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: Writes a block on the card and reads it back 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TestWbMaster is
	port (
		-- Wishbone interface
		CLK_I : in std_ulogic;
		RST_I : in std_ulogic;

		-- Wishbone master
		ERR_I : in std_ulogic;
		RTY_I : in std_ulogic;
		ACK_I : in std_ulogic;
		DAT_I : in std_ulogic_vector(31 downto 0);

		CYC_O : out std_ulogic;
		STB_O : out std_ulogic;
		WE_O  : out std_ulogic;
		CTI_O : out std_ulogic_vector(2 downto 0);
		BTE_O : out std_ulogic_vector(1 downto 0);

		ADR_O : out std_ulogic_vector(6 downto 4);
		DAT_O : out std_ulogic_vector(31 downto 0);
		SEL_O : out std_ulogic_vector(0 downto 0);

		-- status signal
		ERR_O : out std_ulogic;
		DON_O : out std_ulogic
	);
end entity TestWbMaster;

