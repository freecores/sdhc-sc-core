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

	type aSdCmdState is (idle, startbit, transbit, cmdid, arg, crc, endbit,
	recvtransbit, recvcmdid, recvarg, recvcrc, recvendbit, recvcrcerror);

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
	signal SerialCrc, CrcCorrect : std_ulogic;
	signal Counter, NextCounter : unsigned(integer(log2(real(32))) - 1 downto 0);
	signal Output : aSdCmdOut;

	constant cDefaultOut : aSdCmdOut := ((cInactivated, cInactivated,cInactivated),
   	(Ack => cInactivated, Receiving => cInactivated, Valid => cInactivated,
	Content => (id => (others => '0'), arg => (others => '0')), Err => 
	cInactivated), 'Z');

	signal ReceivedToken, NextReceivedToken : aSdCmdToken;

begin

	ioCmd <= Output.Cmd;
	oToController <= Output.Controller;

	-- State register
	CmdStateReg : process (iClk, inResetAsync)
	begin
		if inResetAsync = cInactivated then
			State <= idle;
			Counter <= to_unsigned(0, Counter'length);
		elsif iClk'event and iClk = cActivated then
			State <= NextState;
			Counter <= NextCounter;
			ReceivedToken <= NextReceivedToken;
		end if;
	end process CmdStateReg;

	-- Comb. process
	NextStateAndOutput : process (iFromController, ioCmd, SerialCrc, CrcCorrect, State, Counter)

		procedure NextStateWhenAllSent (constant nextlength : in natural; constant toState : in aSdCmdState) is
		begin
			if (Counter > 0) then
				NextCounter <= Counter - 1;
			else
				NextCounter <= to_unsigned(nextlength, NextCounter'length);
				NextState <= toState;
			end if;
		end procedure NextStateWhenAllSent;

		procedure ShiftIntoCrc(constant data : in std_ulogic) is
		begin
			Output.Crc.DataIn <= cActivated;
			Output.Crc.Data <= data;
		end procedure;

		procedure SendBitsAndCalcCrc (signal container : in std_ulogic_vector;
		constant toState : in aSdCmdState; constant nextlength : in natural) is
		begin
			Output.Cmd <= container(to_integer(Counter));		
			ShiftIntoCrc(container(to_integer(Counter)));
			NextStateWhenAllSent(nextlength, toState);
		end procedure SendBitsAndCalcCrc;

		procedure RecvBitsAndCalcCrc (signal container : inout std_ulogic_vector;
		constant toState : in aSdCmdState; constant nextlength : in natural) is
		begin
			container(to_integer(Counter)) <= ioCmd;		
			ShiftIntoCrc(ioCmd);
			NextStateWhenAllSent(nextlength, toState);
		end procedure RecvBitsAndCalcCrc;


	begin
		-- defaults
		NextState <= State;
		NextCounter <= Counter;
		NextReceivedToken <= ReceivedToken;
		Output <= cDefaultOut;
		Output.Controller.Content <= ReceivedToken.content;

		case State is
			when idle => 
				-- Start receiving or start transmitting
				if (ioCmd = cSdStartBit) then
					ShiftIntoCrc(ioCmd);
					NextReceivedToken.startbit <= ioCmd;
					NextState <= recvtransbit;
				elsif (iFromController.Valid = cActivated) then
					NextState <= startbit;
				end if;

			when startbit =>
				Output.Cmd <= cSdStartBit;
				ShiftIntoCrc(cSdStartBit);
				NextState <= transbit;

			when transbit => 
				Output.Cmd <= cSdTransBitHost;
				ShiftIntoCrc(cSdTransBitHost);
				NextCounter <= to_unsigned(iFromController.Content.id'high,
							   NextCounter'length);
				NextState <= cmdid;

			when cmdid => 
				SendBitsAndCalcCrc(iFromController.Content.id, arg,
					iFromController.Content.arg'high);

			when arg => 
				SendBitsAndCalcCrc(iFromController.Content.arg, crc, crc7'high-1);

			when crc => 
				Output.Cmd <= SerialCrc;
				if (Counter > 0) then
					NextCounter <= Counter - 1;
				else
					NextState <= endbit;
					Output.Controller.Ack <= cActivated;
				end if;

			when endbit =>
				Output.Cmd <= cSdEndBit;
				NextState <= idle; -- todo: receive response

			when recvtransbit => 
				Output.Controller.Receiving <= cActivated;
				ShiftIntoCrc(ioCmd);
				NextReceivedToken.transbit <= ioCmd;
				NextCounter <= to_unsigned(NextReceivedToken.Content.id'high,
							   NextCounter'length);
				NextState <= recvcmdid;

			when recvcmdid => 
				Output.Controller.Receiving <= cActivated;
				RecvBitsAndCalcCrc(NextReceivedToken.Content.id, recvarg,
				NextReceivedToken.Content.arg'high);

			when recvarg => 
				Output.Controller.Receiving <= cActivated;
				RecvBitsAndCalcCrc(NextReceivedToken.Content.arg, recvcrc,
				crc7'high-1);

			when recvcrc => 
				NextReceivedToken.crc7(to_integer(Counter)) <= ioCmd;
				ShiftIntoCrc(ioCmd);

				if (Counter > 0) then
					NextCounter <= Counter - 1;
				else
					NextState <= recvendbit;
				end if;

			when recvendbit => 
			   NextReceivedToken.endbit <= ioCmd;

				-- check 
			   if (CrcCorrect = cActivated and ReceivedToken.transbit = cSdTransBitSlave) then
				   Output.Controller.Valid <= cActivated;
			   else
				   Output.Controller.Err <= cActivated;
			   end if;
			   NextState <= idle;

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
			 oIsCorrect => CrcCorrect,
			 oSerial => SerialCrc);

end architecture Rtl;	
