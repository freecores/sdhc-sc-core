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
-- File        : TbdSd-Rtl-ea.vhdl
-- Owner       : Rainer Kastl
-- Description : Testbed for SDHC-SC-Core for SbX
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;
use work.Ics307Values.all;
use work.Rs232.all;
use work.Sd.all;

entity TbdSd is
	generic (
		gClkFrequency : natural := 100E6
	);
	port (
	iClk         : std_ulogic;
	inResetAsync : std_ulogic;

	-- SD Card
	ioCmd  : inout std_logic; -- Cmd line to and from card
	oSclk  : out std_ulogic;
	ioData : inout std_logic_vector(3 downto 0);

	-- Ics307
	oIcs307Sclk   : out std_ulogic;
	oIcs307Data   : out std_ulogic;
	oIcs307Strobe : out std_ulogic;

	-- Rs232
	oTx : out std_ulogic;

	-- LEDs
	oLedBank : out aLedBank;
	oDigitAdr : out std_ulogic_vector(1 to 3)); -- A,B,C

end entity TbdSd;

architecture Rtl of TbdSd is

	signal RstSync : std_ulogic_vector(1 downto 0);

	signal iCyc  : std_ulogic := '0';
	signal iLock : std_ulogic := '0';
	signal iStb  : std_ulogic := '0';
	signal iWe   : std_ulogic := '0';
	signal iCti  : std_ulogic_vector(2 downto 0) := (others => '0');
	signal iBte  : std_ulogic_vector(1 downto 0) := (others => '0');
	signal iSel  : std_ulogic_vector(0 downto 0) := (others => '0');
	signal iAdr  : std_ulogic_vector(6 downto 4) := (others => '0');
	signal iDat  : std_ulogic_vector(31 downto 0) := (others => '0');

	signal oDat  : std_ulogic_vector(31 downto 0);
	signal oAck  : std_ulogic;
	signal oErr  : std_ulogic;
	signal oRty  : std_ulogic;

	signal LedBank : std_ulogic_vector(7 downto 0);
	signal LedBank2 : std_ulogic_vector(7 downto 0);

begin

	oLedBank <= LedBank;

	Reg : process (iClk) is
	begin
		if (rising_edge(iClk)) then
			RstSync(0) <= inResetAsync;
			RstSync(1) <= not RstSync(0);
		end if;
	end process Reg;

	oDigitAdr <= "101"; -- DIGIT_6
	oTx       <= '1';

	Gen100MHz: if gClkFrequency = 100E6 generate
	-- Configure clock to 100MHz
		Ics307Configurator_inst : entity work.Ics307Configurator(Rtl)
		generic map(
			gCrystalLoadCapacitance_C   => cCrystalLoadCapacitance_C_100MHz,
			gReferenceDivider_RDW       => cReferenceDivider_RDW_100MHz,
			gVcoDividerWord_VDW         => cVcoDividerWord_VDW_100MHz,
			gOutputDivide_S             => cOutputDivide_S_100MHz,
			gClkFunctionSelect_R        => cClkFunctionSelect_R_100MHz,
			gOutputDutyCycleVoltage_TTL => cOutputDutyCycleVoltage_TTL_100MHz
		)
		port map(
			iClk         => iClk,
			inResetAsync => inResetAsync,
			oSclk        => oIcs307Sclk,
			oData        => oIcs307Data,
			oStrobe      => oIcs307Strobe
		);
	end generate;

	SDTop_inst : entity work.SdTop(Rtl)
	generic map (
		gClkFrequency => gClkFrequency,
		gHighSpeedMode => true
	)
	port map (
		iWbClk       => iClk,
		iWbRstSync   => RstSync(1),

		iCyc         => iCyc,
		iLock        => iLock,
		iStb         => iStb,
		iWe          => iWe,
		iCti         => iCti,
		iBte         => iBte,
		iSel         => iSel,
		iAdr         => iAdr,
		iDat         => iDat,

		oDat         => oDat,
		oAck         => oAck,
		oErr         => oErr,
		oRty         => oRty,

		iSdClk       => iClk,
		iSdRstSync   => RstSync(1),
		ioCmd        => ioCmd,
		oSclk        => oSclk,
		ioData       => ioData,
		oLedBank     => LedBank
	);

	TestWbMaster_inst : entity work.TestWbMaster
	port map (
		CLK_I => iClk,
		RST_I => RstSync(1),
		ERR_I => oErr,
		RTY_I => oRty,
		ACK_I => oAck,
		DAT_I => oDat,
		CYC_O => iCyc,
		STB_O => iStb,
		WE_O => iWe,
		CTI_O => iCti,
		BTE_O => iBte,
		ADR_O => iAdr,
		DAT_O => iDat,
		SEL_O => iSel,
		LEDBANK_O => LedBank2
	);

end architecture Rtl;

