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
		oLedBank              : out aLedBank
	);
end entity SdTop;

architecture Rtl of SdTop is

	signal SdCmdToController    : aSdCmdToController;
	signal SdCmdFromController  : aSdCmdFromController;
	signal SdRegisters          : aSdRegisters;
	signal SdDataToController   : aSdDataToController;
	signal SdDataFromController : aSdDataFromController;

begin
	oSclk                 <= iClk;
	oReceivedContent      <= SdCmdToController.Content;
	oReceivedContentValid <= SdCmdToController.Valid;

	SdController_inst: entity work.SdController(Rtl)
	port map (
		iClk         => iClk,
		inResetAsync => inResetAsync,
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
		iFromController => SdCmdFromController,
		oToController   => SdCmdToController,
		ioCmd           => ioCmd
	);

	SdData_inst: entity work.SdData 
	port map (
		iClk                  => iClk,
		inResetAsync          => inResetAsync,
		iSdDataFromController => SdDataFromController,
		oSdDataToController   => SdDataToController,
		ioData                => ioData
	);

end architecture Rtl;

