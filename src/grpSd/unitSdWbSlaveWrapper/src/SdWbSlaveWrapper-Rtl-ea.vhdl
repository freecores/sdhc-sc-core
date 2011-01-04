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
