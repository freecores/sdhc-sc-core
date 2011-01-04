-- SDHC-SC-Core
-- Secure Digital High Capacity Self Configuring Core
-- 
-- (C) Copyright 2010, Rainer Kastl
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--     * Neither the name of the <organization> nor the
--       names of its contributors may be used to endorse or promote products
--       derived from this software without specific prior written permission.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- File        : SdWbSlaveWrapper-Rtl-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : 
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wishbone.all;
use work.sdwb.all;

entity SdWbSlaveWrapper is
	port (
		iClk     : in std_ulogic; -- Clock, rising clock edge
		iRstSync : in std_ulogic; -- Reset, active high, synchronous

		iCyc : in std_ulogic;
		iLock : in std_ulogic;
		iStb : in std_ulogic;
		iWe : in std_ulogic;
		iCti : in std_ulogic_vector(2 downto 0);
		iBte : in std_ulogic_vector(1 downto 0);
		oAck : out std_ulogic;
		oErr : out std_ulogic;
		oRty : out std_ulogic;	
		iSel : in std_ulogic_vector(0 downto 0);
		iAdr : in std_ulogic_vector(6 downto 4);
		iDat : in std_ulogic_vector(31 downto 0);
		oDat : out std_ulogic_vector(31 downto 0);
		iReqOperationEdge : in std_ulogic;
		iReadData : in std_ulogic_vector(31 downto 0);

		oAckOperationToggle : out std_ulogic;
		oStartAddr : out std_ulogic_vector(31 downto 0);
		oEndAddr : out std_ulogic_vector(31 downto 0);
		oOperation : out std_ulogic_vector(31 downto 0);
		oWriteData : out std_ulogic_vector(31 downto 0)
	);

end entity SdWbSlaveWrapper;

architecture Rtl of SdWbSlaveWrapper is

	signal 	iWbCtrl     : aWbSlaveCtrlInput;
	signal 	oWbCtrl     : aWbSlaveCtrlOutput;
	signal 	iWbDat      : aSdWbSlaveDataInput;
	signal 	oWbDat      : aSdWbSlaveDataOutput;
	signal 	oController : aSdWbSlaveToSdController;
	signal 	iController : aSdControllerToSdWbSlave;

begin
	iWbCtrl <= (
			   Cyc  => iCyc,
			   Lock => iLock,
			   Stb  => iStb,
			   We   => iWe,
			   Cti  => iCti,
			   Bte  => iBte
		   );

	oAck <= oWbCtrl.Ack;
	oErr <= oWbCtrl.Err;
	oRty <= oWbCtrl.Rty;
	oDat <= oWbDat.Dat;

	iWbDat <= (
			  Sel => iSel,
			  Adr => iAdr,
			  Dat => iDat
		  );

	oAckOperationToggle <= oController.AckOperationToggle;
	oOperation          <= oController.OperationBlock.Operation;
	oStartAddr          <= oController.OperationBlock.StartAddr;
	oEndAddr            <= oController.OperationBlock.EndAddr;
	oWriteData          <= oController.WriteData;

	iController <= (
				   ReqOperationEdge  => iReqOperationEdge,
				   ReadData          => iReadData         
			   );


	SdWbSlave_inst: entity work.SdWbSlave
	port map (
		iClk  => iClk, 
		iRstSync => iRstSync,
		iWbCtrl => iWbCtrl,
		oWbCtrl => oWbCtrl,
		iWbDat => iWbDat, 
		oWbDat  => oWbDat ,
		iController => iController,
		oController => oController
	);

end architecture Rtl;	
