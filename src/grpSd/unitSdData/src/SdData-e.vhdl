--
-- Title: SdData
-- File: SdData-e.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: Low level sending and receiving data
-- SD Spec 2.00
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;
use work.Sd.all;
use work.CRCs.all;

entity SdData is
	port (
		iClk         : in std_ulogic;
		inResetAsync : in std_ulogic;
		iStrobe      : in std_ulogic;

		-- Controller
		iSdDataFromController : in aSdDataFromController;
		oSdDataToController   : out aSdDataToController;

		-- Ram
		iSdDataFromRam : in aSdDataFromRam;
		oSdDataToRam   : out aSdDataToRam;

		-- Card
		iData : in aiSdData;
		oData : out aoSdData;
		
		-- ReadFifo
		iReadFifo : in aiReadFifo;
		oReadFifo : out aoReadFifo;

		oDisableSdClk : out std_ulogic
	);
end entity SdData;

