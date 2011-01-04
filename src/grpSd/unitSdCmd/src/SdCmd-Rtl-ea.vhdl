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

		iCmdContent: in aSdCmdContent; -- Content to send to card
		ioCmd : inout std_logic -- Cmd line to and from card
	);
end entity SdCmd;

architecture Rtl of SdCmd is

	type aSdCmdState is (idle, startbit, transbit, cmdid, arg, crc, endbit);
	signal State, NextState : aSdCmdState;
	signal CrcClear, CrcDataIn : std_ulogic;
	signal CrcData, SerialCrc : std_ulogic;
	signal Counter, NextCounter : unsigned(integer(log2(real(32))) - 1 downto 0);

begin

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
	NextStateAndOutput : process (iCmdContent, State, Counter)

		procedure NextStateWhenAllSent (constant length : in natural; constant toState : in aSdCmdState) is
		begin
			if (NextCounter < length-1) then
				NextCounter <= NextCounter + 1;
			else
				NextCounter <= to_unsigned(0, NextCounter'length);
				NextState <= toState;
			end if;
		end procedure NextStateWhenAllSent;

	begin
		-- CRC calculation needs one cycle. Therefore we have to start it
		-- ahead of putting the data on ioCmd.

		-- defaults
		NextState <= State;
		NextCounter <= Counter;
		ioCmd <= 'Z';
		CrcClear <= cInactivated;
		CrcDataIn <= cInactivated;
		CrcData <= cInactivated;

		case State is
			when idle => 
				-- todo: implement Sync. with host
				NextState <= startbit;
				CrcDataIn <= cActivated;
				CrcData <= cSdStartBit;

			when startbit =>
				ioCmd <= cSdStartBit;
				NextState <= transbit;
				CrcDataIn <= cActivated;
				CrcData <= cSdTransBitHost;

			when transbit => 
				ioCmd <= cSdTransBitHost;
				NextState <= cmdid;
				CrcDataIn <= cActivated;
				CrcData <= iCmdContent.id(0);

			when cmdid => 
				ioCmd <= iCmdContent.id(to_integer(NextCounter));
				if (NextCounter < iCmdContent.id'length-2) then
					CrcData <= iCmdContent.id(to_integer(NextCounter)+1);
				else 
					CrcData <= iCmdContent.arg(0);
				end if;
				CrcDataIn <= cActivated;
				NextStateWhenAllSent(iCmdContent.id'length, arg);


			when arg => 
				ioCmd <= iCmdContent.arg(to_integer(NextCounter));
				if (NextCounter < iCmdContent.arg'length-2) then
					CrcData <= iCmdContent.arg(to_integer(NextCounter)+1);
					CrcDataIn <= cActivated;
				else 
					CrcDataIn <= cInactivated;
				end if;
				NextStateWhenAllSent(iCmdContent.arg'length, crc);

			when crc => 
				ioCmd <= SerialCrc;
				NextStateWhenAllSent(crc7'length-1, endbit);

			when endbit =>
				ioCmd <= cSdEndBit;
				NextState <= idle; -- todo: receive response

			when others =>
				report "SdCmd: State not handled" severity error;
		end case;
	end process NextStateAndOutput;

	CRC7_inst: entity work.Crc
	generic map(gPolynom => crc7)
	port map(iClk => iClk,
			 inResetAsync => inResetAsync,
			 iClear => CrcClear,
			 iDataIn => CrcDataIn,
			 iData => CrcData,
			 oSerial => SerialCrc);

end architecture Rtl;	
