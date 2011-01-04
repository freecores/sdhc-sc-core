--
-- Title: SdWbSlave
-- File: SdWbSlave-Rtl-ea.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: Wishbone interface for the SD-Core 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.Global.all;
use work.wishbone.all;
use work.SdWb.all;

entity SdWbSlave is
	port (
		iClk     : in std_ulogic; -- Clock, rising clock edge
		iRstSync : in std_ulogic; -- Reset, active high, synchronous

		-- wishbone
		iWbCtrl : in aWbSlaveCtrlInput; -- All control signals for a wishbone slave
		oWbCtrl : out aWbSlaveCtrlOutput; -- All output signals for a wishbone slave
		iWbDat  : in aSdWbSlaveDataInput;
		oWbDat  : out aSdWbSlaveDataOutput; 
		
		-- To sd controller
		iController : in aSdControllerToSdWbSlave;
		oController : out aSdWbSlaveToSdController;

		-- To write fifo
		oWriteFifo : out aoWriteFifo;
		iWriteFifo : in aiWriteFifo
	);
end entity;

