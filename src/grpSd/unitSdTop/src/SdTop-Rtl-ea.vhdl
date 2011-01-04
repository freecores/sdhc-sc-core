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
		gClkFrequency : natural := 25E6
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
		oCrc                  : out std_ulogic_vector(15 downto 0);
		oLedBank              : out aLedBank
	);
end entity SdTop;

architecture Rtl of SdTop is

	signal SdCmdToController    : aSdCmdToController;
	signal SdCmdFromController  : aSdCmdFromController;
	signal SdRegisters          : aSdRegisters;
	signal SdDataToController   : aSdDataToController;
	signal SdDataFromController : aSdDataFromController;
	signal SdStrobe				: std_ulogic;
	signal SdStrobe25MHz        : std_ulogic;
	signal HighSpeed		    : std_ulogic;

begin
	oSclk                 <= SdStrobe25MHz when HighSpeed = cInactivated else iClk;
	oReceivedContent      <= SdCmdToController.Content;
	oReceivedContentValid <= SdCmdToController.Valid;
	oReceivedData         <= SdDataToController.DataBlock(511 downto 0);
	oReceivedDataValid    <= SdDataToController.Valid;
	SdStrobe              <= SdStrobe25MHz when HighSpeed = cInactivated else cActivated;

	SdController_inst: entity work.SdController(Rtl)
	generic map (
		gClkFrequency => gClkFrequency
	)
	port map (
		iClk         => iClk,
		inResetAsync => inResetAsync,
		oHighSpeed   => HighSpeed,
		iSdCmd       => SdCmdToController,
		oSdCmd       => SdCmdFromController,
		iSdData      => SdDataToController,
		oSdData		 => SdDataFromController,
		oSdRegisters => SdRegisters,
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
		ioData                => ioData,
		oCrc                  => oCrc
	);

	SdStrobe_inst: entity work.StrobeGen(Rtl)
	generic map (
		gClkFrequency    => gClkFrequency,
		gStrobeCycleTime => 1 sec / 25E6)
	port map (
		iClk         => iClk,
		inResetAsync => inResetAsync,
		oStrobe      => SdStrobe25MHz);


end architecture Rtl;

