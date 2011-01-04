--
-- Title: SdController
-- File: SdController-e.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: Controls the Sd Card and enables
-- access from a wishbone interface.
-- Sd Spec 2.00
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Global.all;
use work.Sd.all;
use work.SdWb.all;

entity SdController is
	generic (
		gClkFrequency   : natural := 25E6;
		gHighSpeedMode  : boolean := true;
		gStartupTimeout : time    := 1 ms;
		gReadTimeout    : time    := 100 ms
	);
	port (
		iClk         : in std_ulogic; -- rising edge
		inResetAsync : in std_ulogic;
		oHighSpeed   : out std_ulogic;

		-- SdCmd
		iSdCmd : in aSdCmdToController;
		oSdCmd : out aSdCmdFromController;

		-- SdData
		iSdData : in aSdDataToController;
		oSdData : out aSdDataFromController;

		-- SdWbSlave
		iSdWbSlave : in aSdWbSlaveToSdController;
		oSdWbSlave : out aSdControllerToSdWbSlave;

		-- Status
		oLedBank     : out aLedBank
	);
	begin
		
		assert (gStartupTimeout < gReadTimeout)
		report "gStartupTimeout has to be smaller than the read timeout"
		severity error;

		assert ((gHighSpeedMode = true and gClkFrequency >= 50E6) or gHighSpeedMode = false)
		report "High speed Mode needs at least 50 MHz clock"
		severity error;

end entity SdController;
