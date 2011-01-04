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
		iClk : in std_ulogic; 
		inResetAsync : in std_ulogic; 

		-- SD Card
		ioCmd : inout std_logic; -- Cmd line to and from card
		oSclk : out std_ulogic;
		ioData : inout std_logic_vector(3 downto 0);

		-- Status
		oSdCardStatus         : out aSdCardStatus;
		oReceivedContent      : out aSdCmdContent;
		oReceivedContentValid : out std_ulogic;
		oLedBank              : out aLedBank
	);
end entity SdTop;

architecture Rtl of SdTop is

	signal ToController   : aSdCmdToController;
	signal FromController : aSdCmdFromController;
	signal SdRegisters    : aSdRegisters;

begin
	ioData                <= "ZZZZ";
	oSclk                 <= iClk;
	oSdCardStatus         <= SdRegisters.CardStatus;
	oReceivedContent      <= ToController.Content;
	oReceivedContentValid <= ToController.Valid;

	SdController_inst: entity work.SdController(Rtl)
	port map (
		iClk         => iClk,
		inResetAsync => inResetAsync,
		iSdCmd       => ToController,
		oSdCmd       => FromController,
		oSdRegisters => SdRegisters,
		oLedBank     => oLedBank
	);


	SdCmd_inst: entity work.SdCmd(Rtl)
	port map (
		iClk            => iClk,
		inResetAsync    => inResetAsync,
		iFromController => FromController,
		oToController   => ToController,
		ioCmd           => ioCmd
	);

end architecture Rtl;

