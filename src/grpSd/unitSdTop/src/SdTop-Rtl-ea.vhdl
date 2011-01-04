-------------------------------------------------
-- file: ../../unitSdTop/src/SdTop-Rtl-ea.vhdl
-- author: Rainer Kastl
--
-- Top level entity for a SD Controller
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;
use work.Wishbone.all;
use work.Sd.all;
use work.SdWb.all;

entity SdTop is
	generic (
		gUseSameClocks : boolean := true;
		gClkFrequency  : natural := 100E6;
		gHighSpeedMode : boolean := true
	);
	port (
		-- Wishbone interface
		iWbClk   : in std_ulogic;
		iRstSync : in std_ulogic;

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
		inResetAsync : in std_ulogic;

		-- SD Card
		ioCmd  : inout std_logic;
		oSclk  : out std_ulogic;
		ioData : inout std_logic_vector(3 downto 0);

		-- Status
		oLedBank              : out aLedBank
	);

end entity SdTop;

architecture Rtl of SdTop is

	signal SdCmdToController       : aSdCmdToController;
	signal SdCmdFromController     : aSdCmdFromController;
	signal SdDataToController      : aSdDataToController;
	signal SdDataFromController    : aSdDataFromController;
	signal SdDataFromRam           : aSdDataFromRam;
	signal SdDataToRam             : aSdDataToRam;
	signal SdControllerToDataRam   : aSdControllerToRam;
	signal SdControllerFromDataRam : aSdControllerFromRam;
	signal SdWbSlaveToController   : aSdWbSlaveToSdController;
	signal SdWbSlaveFromController : aSdControllerToSdWbSlave;

	signal SdStrobe                : std_ulogic;
	signal HighSpeed               : std_ulogic;

	signal iCmd                    : aiSdCmd;
	signal oCmd                    : aoSdCmd;
	signal iData                   : aiSdData;
	signal oData                   : aoSdData;

	signal iWbCtrl                 : aWbSlaveCtrlInput;
	signal oWbCtrl                 : aWbSlaveCtrlOutput;
	signal iWbDat                  : aSdWbSlaveDataInput;
	signal oWbDat                  : aSdWbSlaveDataOutput;
	
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

	SdWbSlave_inst : entity work.SdWbSlave
	port map (
		iClk                => iWbClk,
		iRstSync            => iRstSync,

		-- wishbone
		iWbCtrl             => iWbCtrl,
		oWbCtrl             => oWbCtrl,
		iWbDat              => iWbDat,
		oWbDat              => oWbDat,
		
		-- To sd controller
		iController         => SdWbSlaveFromController,
		oController         => SdWbSlaveToController
	);


	SdClockMaster_inst: entity work.SdClockMaster
	generic map (
		gClkFrequency => gClkFrequency
	)
	port map (
		iClk       => iSdClk,
		iRstSync   => iRstSync,
		iHighSpeed => HighSpeed,
		oSdStrobe  => SdStrobe,
		oSdCardClk => oSClk
	);

	SdCardSynchronizer_inst : entity work.SdCardSynchronizer
	port map (

		iClk       => iSdClk,
		iRstSync   => iRstSync,
		iCmd       => ioCmd,
		iData      => ioData,
		oCmdSync   => iCmd.Cmd,
		oDataSync  => iData.Data

	);

	SdController_inst: entity work.SdController(Rtl)
	generic map (
		gClkFrequency  => gClkFrequency,
		gHighSpeedMode => gHighSpeedMode
	)
	port map (
		iClk         => iSdClk,
		inResetAsync => inResetAsync,
		oHighSpeed   => HighSpeed,
		iSdCmd       => SdCmdToController,
		oSdCmd       => SdCmdFromController,
		iSdData      => SdDataToController,
		oSdData		 => SdDataFromController,
		iDataRam     => SdControllerFromDataRam,
		oDataRam     => SdControllerToDataRam,
		oSdWbSlave   => SdWbSlaveFromController,
		iSdWbSlave   => SdWbSlaveToController,
		oLedBank     => oLedBank
	);

	SdCmd_inst: entity work.SdCmd(Rtl)
	port map (
		iClk            => iSdClk,
		inResetAsync    => inResetAsync,
		iStrobe         => SdStrobe,
		iFromController => SdCmdFromController,
		oToController   => SdCmdToController,
		iCmd            => iCmd,
		oCmd            => oCmd
	);

	SdData_inst: entity work.SdData 
	port map (
		iClk                  => iSdClk,
		inResetAsync          => inResetAsync,
		iStrobe               => SdStrobe,
		iSdDataFromController => SdDataFromController,
		oSdDataToController   => SdDataToController,
		iSdDataFromRam        => SdDataFromRam,
		oSdDataToRam          => SdDataToRam,
		iData                 => iData,
		oData                 => oData
	);

	DataRam_inst: entity work.SimpleDualPortedRam
	generic map (
		gDataWidth => 32,
		gAddrWidth => 7
	)
	port map (
		iClk    => iSdClk,
		iAddrRW => SdDataToRam.Addr,
		iDataRW => SdDataToRam.Data,
		iWeRW   => SdDataToRam.We,
		oDataRW => SdDataFromRam.Data,
		iAddrR  => SdControllerToDataRam.Addr,
		oDataR  => SdControllerFromDataRam.Data
	);

end architecture Rtl;

