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
