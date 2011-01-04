-------------------------------------------------
-- file: ../../unitSdCmdWrapper/src/SdCmdWrapper-Rtl-ea.vhdl
-- author: Rainer Kastl
--
-- Wrapper for access from system verilog
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Sd.all;

entity SdCmdWrapper is
	port (
		iClk : in std_ulogic; -- Clk
		inResetAsync : in std_ulogic; -- Reset

		iCmdId : in std_ulogic_vector(5 downto 0);
		iArg : in std_ulogic_vector(31 downto 0);
		iValid : in std_ulogic;
		oReceiving : out std_ulogic;
		ioCmd : inout std_ulogic
	);
end entity SdCmdWrapper;

architecture Rtl of SdCmdWrapper is
	signal FromController : aSdCmdFromController;
	signal ToController : aSdCmdToController;

begin

	FromController.Content.id <= iCmdId;
	FromController.Content.arg <= iArg;
	FromController.Send <= iValid;
	oReceiving <= ToController.Receiving;


	SdCmd: entity work.SdCmd(Rtl)
	port map (
		iClk => iClk,
		inResetAsync => inResetAsync,
		iFromController => FromController,
		oToController => ToController,
		ioCmd => ioCmd
	);

end architecture Rtl;
