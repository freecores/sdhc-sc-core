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

entity SdController is
	port (
		iClk : in std_ulogic; -- rising edge
		inResetAsync : in std_ulogic;

		-- SdCmd
		iSdCmd : in aSdCmdToController;
		oSdCmd : out aSdCmdFromController;

		-- SdData
		iSdData : in aSdDataToController;
		oSdData : out aSdDataFromController;

		-- Status
		oSdRegisters : out aSdRegisters;
		oLedBank     : out aLedBank
		);
end entity SdController;
