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
-- File        : SdTop-Rtl-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Top level connecting all sub entities
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;
use work.Wishbone.all;
use work.Sd.all;
use work.SdWb.all;

entity SdTop is
	generic (
		gUseSameClocks : boolean := false;
		gClkFrequency  : natural := 100E6;
		gHighSpeedMode : boolean := true
	);
	port (
		-- Wishbone interface
		iWbClk     : in std_ulogic;
		iWbRstSync : in std_ulogic;

		iCyc  : in std_ulogic;
		iLock : in std_ulogic;
		iStb  : in std_ulogic;
		iWe   : in std_ulogic;
		iCti  : in std_ulogic_vector(2 downto 0);
		iBte  : in std_ulogic_vector(1 downto 0);
		iSel  : in std_ulogic_vector(0 downto 0);
		iAdr  : in std_ulogic_vector(6 downto 4);
		iDat  : in std_ulogic_vector(31 downto 0);

		oDat  : out std_ulogic_vector(31 downto 0);
		oAck  : out std_ulogic;
		oErr  : out std_ulogic;
		oRty  : out std_ulogic;

		-- Sd interface
		iSdClk       : in std_ulogic;
		iSdRstSync   : in std_ulogic;
		-- SD Card
		ioCmd  : inout std_logic;
		oSclk  : out std_ulogic;
		ioData : inout std_logic_vector(3 downto 0);

		-- Status
		oLedBank              : out aLedBank
	);

end entity SdTop;

architecture Rtl of SdTop is

	signal SdCmdToController            : aSdCmdToController;
	signal SdCmdFromController          : aSdCmdFromController;
	signal SdDataToController           : aSdDataToController;
	signal SdDataFromController         : aSdDataFromController;
	signal SdDataFromRam                : aSdDataFromRam;
	signal SdDataToRam                  : aSdDataToRam;
	signal SdControllerToDataRam        : aSdControllerToRam;
	signal SdControllerFromDataRam      : aSdControllerFromRam;
	signal iSdWbSync, oSdControllerSync : aSdWbSlaveToSdController;
	signal iSdControllerSync, oSdWbSync : aSdControllerToSdWbSlave;
	signal SdStrobe                     : std_ulogic;
	signal SdInStrobe                   : std_ulogic;
	signal HighSpeed                    : std_ulogic;
	signal iCmd                         : aiSdCmd;
	signal oCmd                         : aoSdCmd;
	signal iData                        : aiSdData;
	signal oData                        : aoSdData;
	signal iWbCtrl                      : aWbSlaveCtrlInput;
	signal oWbCtrl                      : aWbSlaveCtrlOutput;
	signal iWbDat                       : aSdWbSlaveDataInput;
	signal oWbDat                       : aSdWbSlaveDataOutput;
	signal SdWbSlaveToWriteFifo         : aoWriteFifo;
	signal SdWbSlaveToReadFifo          : aoReadFifo;
	signal WriteFifoToSdWbSlave         : aiWriteFifo;
	signal SdWbSlaveFromReadFifo        : aiReadFifo;
	signal iReadWriteFifo               : aiReadFifo;
	signal oReadWriteFifo               : aoReadFifo;
	signal iWriteReadFifo               : aiWriteFifo;
	signal oWriteReadFifo               : aoWriteFifo;
	signal ReadFifoQTemp                : std_logic_vector(31 downto 0);
	signal WriteFifoQTemp               : std_logic_vector(31 downto 0);
	signal DisableSdClk                 : std_ulogic;

begin

	ioCmd <= oCmd.Cmd when oCmd.En = cActivated else 'Z';
	Gen_data : for i in 0 to 3 generate
		ioData(i) <= oData.Data(i) when oData.En(i) = cActivated else 'Z';
	end generate;

	-- map wishbone signals to internal signals
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

	SdWbControllerSync_inst: entity work.SdWbControllerSync
	generic map (
		gUseSameClocks => gUseSameClocks
	)
	port map (
		iWbClk        => iWbClk,
		iWbRstSync    => iWbRstSync,
		iSdClk        => iSdClk,
		iSdRstSync    => iSdRstSync,
		iSdWb         => iSdWbSync,
		oSdWb         => oSdWbSync,
		iSdController => iSdControllerSync,
		oSdController => oSdControllerSync
	);

	SdWbSlave_inst : entity work.SdWbSlave
	port map (
		iClk                => iWbClk,
		iRstSync            => iWbRstSync,

		-- wishbone
		iWbCtrl             => iWbCtrl,
		oWbCtrl             => oWbCtrl,
		iWbDat              => iWbDat,
		oWbDat              => oWbDat,

		-- To sd controller
		iController         => oSdWbSync,
		oController         => iSdWbSync,

		-- To write fifo
		oWriteFifo          => SdWbSlaveToWriteFifo,
		iWriteFifo          => WriteFifoToSdWbSlave,

		-- To read fifo
		oReadFifo           => SdWbSlaveToReadFifo,
		iReadFifo           => SdWbSlaveFromReadFifo
	);

	SdController_inst: entity work.SdController(Rtl)
	generic map (
		gClkFrequency  => gClkFrequency,
		gHighSpeedMode => gHighSpeedMode
	)
	port map (
		iClk         => iSdClk,
		iRstSync     => iSdRstSync,
		oHighSpeed   => HighSpeed,
		iSdCmd       => SdCmdToController,
		oSdCmd       => SdCmdFromController,
		iSdData      => SdDataToController,
		oSdData		 => SdDataFromController,
		oSdWbSlave   => iSdControllerSync,
		iSdWbSlave   => oSdControllerSync,
		oLedBank     => oLedBank
	);

	SdCmd_inst: entity work.SdCmd(Rtl)
	port map (
		iClk            => iSdClk,
		iRstSync        => iSdRstSync,
		iStrobe         => SdStrobe,
		iFromController => SdCmdFromController,
		oToController   => SdCmdToController,
		iCmd            => iCmd,
		oCmd            => oCmd
	);

	SdData_inst: entity work.SdData 
	port map (
		iClk                  => iSdClk,
		iRstSync			  => iSdRstSync,
		iStrobe               => SdStrobe,
		iSdDataFromController => SdDataFromController,
		oSdDataToController   => SdDataToController,
		iData                 => iData,
		oData                 => oData,
		oReadWriteFifo        => oReadWriteFifo,
		iReadWriteFifo        => iReadWriteFifo,
		oWriteReadFifo        => oWriteReadFifo,
		iWriteReadFifo        => iWriteReadFifo,
		oDisableSdClk         => DisableSdClk
	);

	SdClockMaster_inst: entity work.SdClockMaster
	generic map (
		gClkFrequency => gClkFrequency
	)
	port map (
		iClk       => iSdClk,
		iRstSync   => iSdRstSync,
		iHighSpeed => HighSpeed,
		iDisable   => DisableSdClk,
		oSdStrobe  => SdStrobe,
		oSdInStrobe => SdInStrobe,
		oSdCardClk => oSClk
	);

	SdCardSynchronizer_inst : entity work.SdCardSynchronizer
	port map (

		iClk       => iSdClk,
		iRstSync   => iSdRstSync,
		iStrobe    => SdInStrobe,
		iCmd       => ioCmd,
		iData      => ioData,
		oCmdSync   => iCmd.Cmd,
		oDataSync  => iData.Data

	);

	WriteDataFifo_inst: entity work.WriteDataFifo
	port map (
		data    => std_logic_vector(SdWbSlaveToWriteFifo.data),
		rdclk   => iSdClk,
		rdreq   => oReadWriteFifo.rdreq,
		wrclk   => iWbClk,
		wrreq   => SdWbSlaveToWriteFifo.wrreq,
		q       => ReadFifoQTemp,
		rdempty => iReadWriteFifo.rdempty,
		wrfull  => WriteFifoToSdWbSlave.wrfull
	);

	iReadWriteFifo.q <= std_ulogic_vector(ReadFifoQTemp);

	ReadDataFifo_inst: entity work.WriteDataFifo
	port map (
		data    => std_logic_vector(oWriteReadFifo.data),
		rdclk   => iWbClk,
		rdreq   => SdWbSlaveToReadFifo.rdreq,
		wrclk   => iSdClk,
		wrreq   => oWriteReadFifo.wrreq,
		q       => WriteFifoQTemp,
		rdempty => SdWbSlaveFromReadFifo.rdempty,
		wrfull  => iWriteReadFifo.wrfull
	);

	SdWbSlaveFromReadFifo.q <= std_ulogic_vector(WriteFifoQTemp);

end architecture Rtl;

