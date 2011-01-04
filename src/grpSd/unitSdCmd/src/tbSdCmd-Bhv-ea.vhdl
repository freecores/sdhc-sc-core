-------------------------------------------------
-- file: tbSdCmd-Bhv-ea.vhdl
-- author: Rainer Kastl
--
-- Simple testbench for the SDCmd entity
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;
use work.Sd.all;

entity tbSdCmd is
	generic (gClkPeriod : time := 10 ns);
end entity tbSdCmd;

architecture Bhv of tbSdCmd is

	signal Clk : std_ulogic := cInactivated;
	signal Finished : std_ulogic := cInactivated;
	signal nResetAsync : std_ulogic;
	signal ToCmd : aSdCmdFromController;
	signal FromCmd : aSdCmdToController;
	signal Cmd : std_logic;

	signal sentCmd : std_ulogic_vector(47 downto 0) := (others => 'U');
	signal counter : integer := 0;
	signal save : std_ulogic := cInactivated;


begin

	-- Clock generator
	Clk <= not Clk after gClkPeriod/2 when (Finished = cInactivated);

	-- Reset
	nResetAsync <= cnActivated after 2*gClkPeriod,
				   cnInactivated after 3*gClkPeriod;

	Finished <= cActivated after 53*gClkPeriod;

	save <= cActivated after 36 ns;
	SaveCmd : process (Clk, save)
	begin
		if (Clk'event and Clk = cActivated and save = cActivated) then
			if (counter < sentCmd'length) then
				sentCmd(sentCmd'length - 1 - counter) <= Cmd;
				counter <= counter + 1;
			end if;
		end if;
	end process SaveCmd ;

	-- Stimuli:
	Cmd <= 'Z';
	ToCmd.Content.id <= cSdCmdGoIdleState;
	ToCmd.Content.arg <= (others => '0');
	ToCmd.Valid <= cActivated;

	Stimuli : process is
	begin
		wait for 54*gClkPeriod;
		assert(sentCmd = "010000000000000000000000000000000000000010010101") report
		"sentCmd invalid: " & integer'image(to_integer(unsigned(sentCmd))) severity error;
		wait;
	end process Stimuli;

	DUT: entity work.SdCmd(Rtl)
	port map(
		iClk => Clk,
		inResetAsync => nResetAsync,
		iFromController => ToCmd,
		oToController => FromCmd,
		ioCmd => Cmd
	);

end architecture Bhv;
