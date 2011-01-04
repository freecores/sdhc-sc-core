-- SDHC-SC-Core
-- Secure Digital High Capacity Self Configuring Core
-- 
-- (C) Copyright 2010 Rainer Kastl
-- 
-- This file is part of SDHC-SC-Core.
-- 
-- SDHC-SC-Core is free software: you can redistribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or (at
-- your option) any later version.
-- 
-- SDHC-SC-Core is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public License
-- along with SDHC-SC-Core. If not, see http://www.gnu.org/licenses/.
-- 
-- File        : SdCmd-Rtl-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : FSM for low level sending of SD commands and receiving responses
-- Links       : SD Spec 2.00
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.Global.all;
use work.Sd.all;
use work.CRCs.all;

entity SdCmd is
	port (
		iClk         : in std_ulogic; -- Clk, rising edge
		iRstSync     : in std_ulogic; -- Reset, synchronous active high

		iStrobe      : in std_ulogic; -- Strobe to send data

		iFromController : in aSdCmdFromController;
		oToController   : out aSdCmdToController;

		-- SDCard
		iCmd : in aiSdCmd;
		oCmd : out aoSdCmd
	);
end entity SdCmd;

architecture Rtl of SdCmd is

	type aSdCmdState is (idle, sending, receiving);
	type aRegion is (startbit, transbit, cmdid, arg, cid, crc, endbit, waitstate);
	
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
		Controller : aSdCmdToController;
		Cmd        : aoSdCmd;
	end record aOutputRegSet;

	constant cDefaultOutputRegSet : aOutputRegSet := (
	Controller => cDefaultSdCmdToController,
	Cmd => (Cmd       => '0',
	En         => '0'));

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

	oToController <= O.Controller;
	oCmd <= O.Cmd;

	-- State register
	CmdStateReg : process (iClk)
	begin
		if iClk'event and iClk = cActivated then
			if iRstSync = cActivated then
				R <= cDefaultRegSet;
				O <= cDefaultOutputRegSet;
			else

				if (iStrobe = cActivated) then
					R <= NextR;
					O <= NextO;
				end if;
			end if;
		end if;
	end process CmdStateReg;

	-- Comb. process
	NextStateAndOutput : process (iFromController, iCmd.Cmd, SerialCrc, CrcCorrect, iStrobe, R)
		
		procedure NextStateWhenAllSent (constant nextlength : in natural; constant toRegion : in aRegion) is
		begin
			if (R.Counter > 0) then
				NextR.Counter <= R.Counter - 1;
			else
				NextR.Counter <= to_unsigned(nextlength, NextR.Counter'length);
				NextR.Region <= toRegion;
			end if;
		end procedure NextStateWhenAllSent;

		procedure ShiftIntoCrc(constant data : in std_ulogic) is
		begin
			CrcOut.DataIn <= cActivated;
			CrcOut.Data   <= data;
		end procedure;

		procedure SendBitsAndCalcCrc (signal container : in std_ulogic_vector; constant toRegion : in aRegion; constant nextlength : in natural) is
		begin
			NextO.Cmd.En  <= cActivated;
			NextO.Cmd.Cmd <= container(to_integer(R.Counter));

			ShiftIntoCrc(container(to_integer(R.Counter)));
			NextStateWhenAllSent(nextlength, toRegion);
		end procedure SendBitsAndCalcCrc;

		procedure RecvBitsAndCalcCrc (signal container : out std_ulogic_vector;	constant toRegion : in aRegion; constant nextlength : in natural) is
		begin
			container(to_integer(R.Counter)) <= iCmd.Cmd;		
			ShiftIntoCrc(iCmd.Cmd);
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
				if (iCmd.Cmd = cSdStartBit) then
					-- Start receiving
					ShiftIntoCrc(iCmd.Cmd);

					NextR.ReceivedToken.startbit <= iCmd.Cmd;
					NextR.State                  <= receiving;
					NextR.Region                 <= transbit;

				elsif (iFromController.Valid = cActivated) then
					-- Start sending
					NextR.State  <= sending;
					NextR.Region <= startbit;

				end if;

			when sending => 
				NextO.Cmd.En <= cActivated;

				case R.Region is
					when startbit =>
						NextO.Cmd.Cmd  <= cSdStartBit;
						NextR.Region <= transbit;
						ShiftIntoCrc(cSdStartBit);

					when transbit => 
						NextO.Cmd.Cmd   <= cSdTransBitHost;
						NextR.Counter <= to_unsigned(iFromController.Content.id'high, aCounter'length);
						NextR.Region <= cmdid;
						ShiftIntoCrc(cSdTransBitHost);

					when cmdid => 
						SendBitsAndCalcCrc(iFromController.Content.id, arg,	iFromController.Content.arg'high);

					when arg => 
						SendBitsAndCalcCrc(iFromController.Content.arg, crc, crc7'high-1);

					when crc => 
						NextO.Cmd.Cmd <= SerialCrc;

						if (R.Counter > 0) then
							NextR.Counter <= R.Counter - 1;

						else
							NextR.Region         <= endbit;
							NextO.Controller.Ack <= cActivated;
						end if;

					when endbit => 
						NextO.Cmd.Cmd <= cSdEndBit;
						NextR.Region  <= waitstate;

					when waitstate => 
						NextO.Cmd.En <= cInactivated;
						NextR.State  <= idle;
						NextR.Region <= startbit;

					when others => 
						report "SdCmd: Region not handled" severity error;

				end case;

			when receiving => 
				NextO.Controller.Receiving   <= cActivated;

				case R.Region is
					when transbit => 
						NextR.ReceivedToken.transbit <= iCmd.Cmd;
						NextR.Counter <= to_unsigned(NextR.ReceivedToken.Content.id'high, NextR.Counter'length);
						NextR.Region <= cmdid;
						ShiftIntoCrc(iCmd.Cmd);

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
						NextR.Cid <= UpdateCID(R.Cid, iCmd.Cmd, to_integer(R.Counter)+8);
						ShiftIntoCrc(iCmd.Cmd);
						NextStateWhenAllSent(crc7'high-1, crc);

					when crc => 
						NextR.ReceivedToken.crc7(to_integer(R.Counter)) <= iCmd.Cmd;
						ShiftIntoCrc(iCmd.Cmd);

						if (R.Counter > 0) then
							NextR.Counter <= R.Counter - 1;
						else
							NextR.Region <= endbit;
						end if;

					when endbit => 
						NextR.ReceivedToken.endbit <= iCmd.Cmd;

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
		iRstSync     => iRstSync,
		iClear		 => CrcOut.Clear,
		iStrobe      => iStrobe,
		iDataIn      => CrcOut.DataIn,
		iData        => CrcOut.Data,
		oIsCorrect   => CrcCorrect,
		oSerial      => SerialCrc);

end architecture Rtl;	
