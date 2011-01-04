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
		ioCmd : inout std_ulogic -- Cmd line to and from card
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
			State <= endbit;
			Counter <= to_unsigned(0, Counter'length);
		elsif iClk'event and iClk = cActivated then
			State <= NextState;
		end if;
	end process CmdStateReg;

	-- Comb. process
	NextStateAndOutput : process (iCmdContent, State)

		procedure NextStateWhenAllSent (constant length : in natural; constant toState : in aSdCmdState) is
		begin
			if (NextCounter < length-1) then
				NextCounter <= NextCounter + 1;
			else
				NextCounter <= to_unsigned(0, NextCounter'length);
				NextState <= toState;
			end if;
		end procedure NextStateWhenAllSent;



		procedure SendBitsAndCalcCrc (signal container : in std_ulogic_vector; constant toState : in aSdCmdState) is
		begin
			ioCmd <= container(to_integer(NextCounter));
			CrcData <= container(to_integer(NextCounter));
			CrcDataIn <= cActivated;
			NextStateWhenAllSent(container'length, toState);
		end procedure SendBitsAndCalcCrc;


	begin
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

			when startbit =>
				ioCmd <= cSdStartBit;
				NextState <= transbit;

			when transbit => 
				ioCmd <= cSdTransBitHost;
				NextState <= cmdid;

			when cmdid => 
				SendBitsAndCalcCrc(iCmdContent.id, arg);

			when arg => 
				SendBitsAndCalcCrc(iCmdContent.arg, crc);

			when crc => 
				ioCmd <= SerialCrc;
				NextStateWhenAllSent(crc7'length, endbit);

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
