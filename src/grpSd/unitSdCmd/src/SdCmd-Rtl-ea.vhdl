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

	type aSdCmdState is (idle, sending, receiving);
	type aRegion is (startbit, transbit, cmdid, arg, cid, crc, endbit);
	subtype aCounter is unsigned(integer(log2(real(128))) - 1 downto 0);

	type aRegSet is record
		State         : aSdCmdState;
		Region        : aRegion;
		Counter       : aCounter;
		ReceivedToken : aSdCmdToken;
		Cid           : aSdRegCID;
	end record aRegSet;

	constant cDefaultRegSet : aRegSet := (
	State         => idle,
	Region        => startbit,
	Counter       => to_unsigned(0, aCounter'length),
	ReceivedToken => cDefaultSdCmdToken,
	Cid           => cDefaultSdRegCID);

	type aOutputRegSet is record
		Controller    : aSdCmdToController;
		Cmd           : std_ulogic;
		En            : std_ulogic;
	end record aOutputRegSet;

	constant cDefaultOutputRegSet : aOutputRegSet := (
	Controller => cDefaultSdCmdToController,
	Cmd        => '0',
	En         => '0');

	type aCrcOut is record 
		Clear  : std_ulogic;
		DataIn : std_ulogic;
		Data   : std_ulogic;
	end record aCrcOut;

	constant cDefaultCrcOut : aCrcOut := (
	Clear  => cInactivated,
	DataIn => cInactivated,
	Data   => cInactivated);

	signal SerialCrc, CrcCorrect : std_ulogic;
	signal CrcOut : aCrcOut;

	signal R, NextR : aRegSet;
	signal O, NextO : aOutputRegSet;

begin

	ioCmd         <= O.Cmd when O.En = cActivated else 'Z';
	oToController <= O.Controller;

	-- State register
	CmdStateReg : process (iClk, inResetAsync)
	begin
		if inResetAsync = cInactivated then
			R <= cDefaultRegSet;
			O <= cDefaultOutputRegSet;

		elsif iClk'event and iClk = cActivated then
			R <= NextR;
			O <= NextO;

		end if;
	end process CmdStateReg;

	-- Comb. process
	NextStateAndOutput : process (iFromController, ioCmd, SerialCrc, CrcCorrect,
		R)

		procedure NextStateWhenAllSent (constant nextlength : in natural; constant toRegion : in aRegion) is
		begin
			if (R.Counter > 0) then
				NextR.Counter <= R.Counter - 1;
			else
				NextR.Counter <= to_unsigned(nextlength, NextR.Counter'length);
				NextR.Region  <= toRegion;
			end if;
		end procedure NextStateWhenAllSent;

		procedure ShiftIntoCrc(constant data : in std_ulogic) is
		begin
			CrcOut.DataIn <= cActivated;
			CrcOut.Data   <= data;
		end procedure;

		procedure SendBitsAndCalcCrc (signal container : in std_ulogic_vector; constant toRegion : in aRegion; constant nextlength : in natural) is
		begin
			NextO.En  <= cActivated;
			NextO.Cmd <= container(to_integer(R.Counter));

			ShiftIntoCrc(container(to_integer(R.Counter)));
			NextStateWhenAllSent(nextlength, toRegion);
		end procedure SendBitsAndCalcCrc;

		procedure RecvBitsAndCalcCrc (signal container : out std_ulogic_vector;	constant toRegion : in aRegion; constant nextlength : in natural) is
		begin
			container(to_integer(R.Counter)) <= ioCmd;		
			ShiftIntoCrc(ioCmd);
			NextStateWhenAllSent(nextlength, toRegion);
		end procedure RecvBitsAndCalcCrc;


	begin
		-- defaults
		NextR                    <= R;
		NextO                    <= cDefaultOutputRegSet;
		NextO.Controller.Content <= R.ReceivedToken.content;
		NextO.Controller.Cid     <= R.Cid;
		CrcOut                   <= cDefaultCrcOut;

		case R.State is
			when idle => 
				-- Start receiving or start transmitting
				if (ioCmd = cSdStartBit) then
					ShiftIntoCrc(ioCmd);
					NextR.ReceivedToken.startbit <= ioCmd;
					NextR.State <= receiving;
					NextR.Region <= transbit;
				elsif (iFromController.Valid = cActivated) then
					NextR.State <= sending;
					NextR.Region <= startbit;
				end if;

			when sending => 
				NextO.En <= cActivated;

				case R.Region is
					when startbit =>
						NextO.Cmd    <= cSdStartBit;
						NextR.Region <= transbit;
						ShiftIntoCrc(cSdStartBit);

					when transbit => 
						NextO.Cmd     <= cSdTransBitHost;
						NextR.Counter <= to_unsigned(iFromController.Content.id'high, aCounter'length);
						NextR.Region  <= cmdid;
						ShiftIntoCrc(cSdTransBitHost);

					when cmdid => 
						SendBitsAndCalcCrc(iFromController.Content.id, arg,
						iFromController.Content.arg'high);

					when arg => 
						SendBitsAndCalcCrc(iFromController.Content.arg, crc, crc7'high-1);

					when crc => 
						NextO.Cmd <= SerialCrc;

						if (R.Counter > 0) then
							NextR.Counter <= R.Counter - 1;

						else
							NextR.Region         <= endbit;
							NextO.Controller.Ack <= cActivated;
						end if;

					when endbit => 
						NextO.Cmd    <= cSdEndBit;
						NextR.State  <= idle;
						NextR.Region <= startbit;

					when others => 
						report "SdCmd: Region not handled" severity error;

				end case;

			when receiving => 
				NextO.Controller.Receiving   <= cActivated;

				case R.Region is
					when transbit => 
						NextR.ReceivedToken.transbit <= ioCmd;
						NextR.Counter                <= to_unsigned(NextR.ReceivedToken.Content.id'high, NextR.Counter'length);
						NextR.Region                 <= cmdid;
						ShiftIntoCrc(ioCmd);

					when cmdid => 
						if (iFromController.ExpectCID = cInactivated) then
							RecvBitsAndCalcCrc(NextR.ReceivedToken.Content.id, arg, NextR.ReceivedToken.Content.arg'high);

						elsif (iFromController.ExpectCID = cActivated) then
							RecvBitsAndCalcCrc(NextR.ReceivedToken.Content.id, cid, cCIDLength-8);
							CrcOut.Clear <= cActivated;

						end if;

					when arg => 
						RecvBitsAndCalcCrc(NextR.ReceivedToken.Content.arg, crc, crc7'high-1);

					when cid => 
						NextR.Cid <= UpdateCID(R.Cid, ioCmd, to_integer(R.Counter)+8);
						ShiftIntoCrc(ioCmd);
						NextStateWhenAllSent(crc7'high-1, crc);

					when crc => 
						NextR.ReceivedToken.crc7(to_integer(R.Counter)) <= ioCmd;
						ShiftIntoCrc(ioCmd);

						if (R.Counter > 0) then
							NextR.Counter <= R.Counter - 1;
						else
							NextR.Region <= endbit;
						end if;

					when endbit => 
						NextR.ReceivedToken.endbit <= ioCmd;

						-- check 
						if (iFromController.CheckCrc = cActivated) then
							if (CrcCorrect = cActivated and R.ReceivedToken.transbit = cSdTransBitSlave) then
								NextO.Controller.Valid <= cActivated;

							else
								NextO.Controller.Err <= cActivated;

							end if;
						else 
							NextO.Controller.Valid <= cActivated;
						end if;
						
						NextR.State <= idle;
						NextR.Region <= startbit;

					when others => 
						report "SdCmd : Region not handled" severity error;

				end case;

			when others => 
				report "SdCmd: State not handled" severity error;

		end case;

	end process NextStateAndOutput;

	CRC7_inst: entity work.Crc
	generic map(
		gPolynom => crc7)
	port map(
		iClk         => iClk,
		inResetAsync => inResetAsync,
		iClear       => CrcOut.Clear,
		iDataIn      => CrcOut.DataIn,
		iData        => CrcOut.Data,
		oIsCorrect   => CrcCorrect,
		oSerial      => SerialCrc);

end architecture Rtl;	
