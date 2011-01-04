-- SDHC-SC-Core
-- Secure Digital High Capacity Self Configuring Core
-- 
-- (C) Copyright 2010 Rainer Kastl
-- 
-- This file is part of SDHC-SC-Core.
-- 
-- SDHC-SC-Core is free software: you can redistribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or (at
-- your option) any later version.
-- 
-- SDHC-SC-Core is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public License
-- along with SDHC-SC-Core. If not, see http://www.gnu.org/licenses/.
-- 
-- File        : tbRs232Tx-Bhv-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Testbench for Rs232 Transmitter
-- Links       : Rs232Tx-Rtl-ea.vhdl
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;
use work.Rs232.all;

entity tbRs232Tx is
end entity tbRs232Tx;

architecture Bhv of tbRs232Tx is

	constant cClkFrequency : natural := 25E6;
	constant cBaudRate     : natural := 9600;
	constant cResetTime    : time    := 1 sec / cClkFrequency * 3;

	signal Clk         : std_ulogic := cActivated;
	signal nResetAsync : std_ulogic := cnActivated;
	signal iRs232Tx    : aiRs232Tx;
	signal oRs232Tx    : aoRs232Tx;
	signal Finished    : std_ulogic := cInactivated;

begin

	Clk <=  not Clk after 1 sec / cClkFrequency / 2 when Finished = cInactivated;
	nResetAsync <= cnInactivated after cResetTime;

	Stimuli : process is
	begin
		iRs232Tx.Transmit      <= cActivated;
		iRs232Tx.Data          <= (others => '-');
		iRs232Tx.DataAvailable <= cInactivated;

		wait for cResetTime;

		wait for 1 us;

		iRs232Tx.Data          <= X"5A";
		iRs232Tx.DataAvailable <= cActivated;

		wait until (Clk = cActivated and oRs232Tx.DataWasRead = cActivated);

		iRs232Tx.DataAvailable <= cInactivated;

		wait until Clk = cActivated;
		wait until Clk = cActivated;
		
		iRs232Tx.Data          <= X"7E";
		iRs232Tx.DataAvailable <= cActivated;

		wait until (Clk = cActivated and oRs232Tx.DataWasRead = cActivated);

		iRs232Tx.Data <= X"96";

		wait until Clk = cActivated;

		wait until (Clk = cActivated and oRs232Tx.DataWasRead = cActivated);

		iRs232Tx.DataAvailable <= cInactivated;

		wait for 500 us;

		iRs232Tx.Data          <= X"97";
		iRs232Tx.DataAvailable <= cActivated;

		wait until (Clk = cActivated and oRs232Tx.DataWasRead = cActivated);

		iRs232Tx.DataAvailable <= cInactivated;
		iRs232Tx.Transmit      <= cInactivated;

		wait for 5 ms;

		Finished <= cActivated;

		wait;
	end process Stimuli;

	StrobeGen_Rs232 : entity work.StrobeGen
	generic map (
		gClkFrequency    => cClkFrequency,
		gStrobeCycleTime => 1 sec / cBaudRate)
	port map (
		iClk         => Clk,
		inResetAsync => nResetAsync,
		oStrobe      => iRs232Tx.BitStrobe);

	DUT: entity work.Rs232Tx
	generic map (
		gDataBitWidth => 8
	)
	port map (
		iClk         => Clk,
		inResetAsync => nResetAsync,
		iRs232Tx     => iRs232Tx,
		oRs232Tx     => oRs232Tx
	);

end architecture Bhv;	

