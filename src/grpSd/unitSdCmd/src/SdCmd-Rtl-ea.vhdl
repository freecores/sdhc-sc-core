-------------------------------------------------
-- file: SdCmd-ea.vhdl
-- author: Rainer Kastl
--
-- Low level sending commands and receiving responses
-- SD Spec 2.00
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.Global.all;
use work.Sd.all;
use work.CRCs.all;

entity SdCmd is
	port (
		iClk : in std_ulogic; -- Clk, rising edge
		inResetAsync : in std_ulogic; -- Reset, asynchronous active low

		iFromController : in aSdCmdFromController;
		oToController : out aSdCmdToController;	

		-- SDCard
		ioCmd : inout std_logic -- Cmd line to and from card
	);
end entity SdCmd;

architecture Rtl of SdCmd is

	type aSdCmdState is (idle, startbit, transbit, cmdid, arg, crc, endbit);

	type aCrcOut is record 
		Clear : std_ulogic;
		DataIn : std_ulogic;
		Data : std_ulogic;
	end record aCrcOut;

	type aSdCmdOut is record
		Crc : aCrcOut;
		Controller : aSdCmdToController;
		Cmd : std_logic;
	end record aSdCmdOut;

	signal State, NextState : aSdCmdState;
	signal SerialCrc : std_ulogic;
	signal Counter, NextCounter : unsigned(integer(log2(real(32))) - 1 downto 0);
	signal Output : aSdCmdOut;

	constant cDefaultOut : aSdCmdOut := ((cInactivated, cInactivated,
	cInactivated), (Receiving => cInactivated), 'Z');

begin

	ioCmd <= Output.Cmd;
	oToController.Receiving <= cInactivated;

	-- State register
	CmdStateReg : process (iClk, inResetAsync)
	begin
		if inResetAsync = cInactivated then
			State <= idle;
			Counter <= to_unsigned(0, Counter'length);
		elsif iClk'event and iClk = cActivated then
			State <= NextState;
			Counter <= NextCounter;
		end if;
	end process CmdStateReg;

	-- Comb. process
	NextStateAndOutput : process (iFromController, ioCmd, SerialCrc, State, Counter)

		procedure NextStateWhenAllSent (constant length : in natural; constant toState : in aSdCmdState) is
		begin
			if (Counter < length-1) then
				NextCounter <= Counter + 1;
			else
				NextCounter <= to_unsigned(0, NextCounter'length);
				NextState <= toState;
			end if;
		end procedure NextStateWhenAllSent;

		procedure SendBitsAndCalcCrc (signal container : in std_ulogic_vector; constant toState : in aSdCmdState) is
		begin
			Output.Cmd <= container(to_integer(NextCounter));		
			Output.Crc.Data <= container(to_integer(NextCounter));
			Output.Crc.DataIn <= cActivated;
			NextStateWhenAllSent(container'length, toState);
		end procedure SendBitsAndCalcCrc;

	begin
		-- CRC calculation needs one cycle. Therefore we have to start it
		-- ahead of putting the data on ioCmd.

		-- defaults
		NextState <= State;
		NextCounter <= Counter;
		Output <= cDefaultOut;

		case State is
			when idle => 
				if (iFromController.Valid = cActivated) then
					NextState <= startbit;
				end if;

			when startbit =>
				Output.Cmd <= cSdStartBit;
				Output.Crc.DataIn <= cActivated;
				Output.Crc.Data <= cSdStartBit;
				NextState <= transbit;

			when transbit => 
				Output.Cmd <= cSdTransBitHost;
				Output.Crc.DataIn <= cActivated;
				Output.Crc.Data <= cSdTransBitHost;
				NextState <= cmdid;

			when cmdid => 
				SendBitsAndCalcCrc(iFromController.Content.id, arg);

			when arg => 
				SendBitsAndCalcCrc(iFromController.Content.arg, crc);

			when crc => 
				Output.Cmd <= SerialCrc;
				NextStateWhenAllSent(crc7'length-1, endbit);

			when endbit =>
				Output.Cmd <= cSdEndBit;
				NextState <= idle; -- todo: receive response

			when others =>
				report "SdCmd: State not handled" severity error;
		end case;
	end process NextStateAndOutput;

	CRC7_inst: entity work.Crc
	generic map(gPolynom => crc7)
	port map(iClk => iClk,
			 inResetAsync => inResetAsync,
			 iClear => Output.Crc.Clear,
			 iDataIn => Output.Crc.DataIn,
			 iData => Output.Crc.Data,
			 oSerial => SerialCrc);

end architecture Rtl;	
