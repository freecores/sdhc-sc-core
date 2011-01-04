--
-- Title: Testbench for SD Clock Master
-- File: tbSdClockMaster-Bhv-ea.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: Simple, non automated testbench, because the design is very simple. 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;

entity tbSdClockMaster is
	end entity tbSdClockMaster;

architecture Bhv of tbSdClockMaster is

	signal Clk             : std_ulogic := cInactivated;
	constant cClkFrequency : natural    := 100E6;
	constant cClkPeriod    : time       := (1 sec / cClkFrequency);
	signal RstSync         : std_ulogic := cActivated;
	constant cResetTime    : time       := 5 * cClkPeriod;
	signal Finished        : boolean    := false;

	-- DUT signals

	signal iHighSpeed, iDisable : std_ulogic := cInactivated;
 	signal  	oStrobe, oSdClk : std_ulogic;

begin

	-- generate clock and reset

	Clk     <= not Clk after cClkPeriod / 2 when Finished = false else cInactivated;
	RstSync <= cInactivated after cResetTime;

	-- stimuli

	stimuli : process 
	begin
		iHighSpeed <= cActivated after 1001 ns,
					  cInactivated after 1026 ns,
					  cActivated after 1306 ns;

		iDisable   <= cActivated after 2346 ns,
					  cInactivated after 3001 ns,
					  cActivated after 3423 ns;
		Finished   <= true after 5001 ns;
		wait;
	end process stimuli;

	DUT: entity work.SdClockMaster
	port map(
		iClk       => Clk,
		iRstSync   => RstSync,

		iHighSpeed => iHighSpeed,
		iDisable   => iDisable,

		oSdStrobe  => oStrobe,
		oSdCardClk => oSdClk
	);


end architecture Bhv;	

