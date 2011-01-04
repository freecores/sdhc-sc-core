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
use work.Sd.all;

entity SdTop is
	generic (
		gClkFrequency  : natural := 25E6;
		gHighSpeedMode : boolean := false
	);
	port (
		iClk         : in std_ulogic;
		inResetAsync : in std_ulogic;

		-- SD Card
		ioCmd  : inout std_logic;
		oSclk  : out std_ulogic;
		ioData : inout std_logic_vector(3 downto 0);

		-- Status
		oReceivedContent      : out aSdCmdContent;
		oReceivedContentValid : out std_ulogic;
		oReceivedData         : out std_ulogic_vector(511 downto 0);
		oReceivedDataValid    : out std_ulogic;
		oLedBank              : out aLedBank
	);

	begin

		assert (gClkFrequency = 25E6 or gClkFrequency = 50E6)
		report "invalid clock frequency"
		severity failure;

		assert ((gHighSpeedMode = true and gClkFrequency = 50E6) or gHighSpeedMode = false)
		report "High speed mode needs 50 MHz clock"
		severity note;

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
	signal SdStrobe                : std_ulogic;
	signal SdStrobe25MHz           : std_ulogic;
	signal HighSpeed               : std_ulogic;

begin

	Sclk50Mhz: if gClkFrequency = 50E6 generate

		oSclk    <= SdStrobe25MHz when HighSpeed = cInactivated else iClk;
		SdStrobe <= SdStrobe25MHz when HighSpeed = cInactivated else cActivated;
	
		SdStrobe_inst: entity work.StrobeGen(Rtl)
		generic map (
			gClkFrequency    => gClkFrequency,
			gStrobeCycleTime => 1 sec / 25E6)
		port map (
			iClk         => iClk,
			inResetAsync => inResetAsync,
			oStrobe      => SdStrobe25MHz);
	
	end generate;	

	Sclk25MHz: if gClkFrequency = 25E6 generate

		oSclk    <= iClk;
		SdStrobe <= cActivated;

	end generate;

	oReceivedContent      <= SdCmdToController.Content;
	oReceivedContentValid <= SdCmdToController.Valid;
	oReceivedDataValid    <= SdDataToController.Valid;

	SdController_inst: entity work.SdController(Rtl)
	generic map (
		gClkFrequency  => gClkFrequency,
		gHighSpeedMode => gHighSpeedMode
	)
	port map (
		iClk         => iClk,
		inResetAsync => inResetAsync,
		oHighSpeed   => HighSpeed,
		iSdCmd       => SdCmdToController,
		oSdCmd       => SdCmdFromController,
		iSdData      => SdDataToController,
		oSdData		 => SdDataFromController,
		iDataRam     => SdControllerFromDataRam,
		oDataRam     => SdControllerToDataRam,
		oLedBank     => oLedBank
	);

	SdCmd_inst: entity work.SdCmd(Rtl)
	port map (
		iClk            => iClk,
		inResetAsync    => inResetAsync,
		iStrobe         => SdStrobe,
		iFromController => SdCmdFromController,
		oToController   => SdCmdToController,
		ioCmd           => ioCmd
	);

	SdData_inst: entity work.SdData 
	port map (
		iClk                  => iClk,
		inResetAsync          => inResetAsync,
		iStrobe               => SdStrobe,
		iSdDataFromController => SdDataFromController,
		oSdDataToController   => SdDataToController,
		iSdDataFromRam        => SdDataFromRam,
		oSdDataToRam		  => SdDataToRam,
		ioData                => ioData
	);

	DataRam_inst: entity work.SimpleDualPortedRam
	generic map (
		gDataWidth => 32,
		gAddrWidth => 7
	)
	port map (
		iClk  => iClk,
		iAddrRW => SdDataToRam.Addr,
		iDataRW => SdDataToRam.Data,
		iWeRW   => SdDataToRam.We,
		oDataRW => SdDataFromRam.Data,
		iAddrR  => SdControllerToDataRam.Addr,
		oDataR  => SdControllerFromDataRam.Data
	);

end architecture Rtl;

