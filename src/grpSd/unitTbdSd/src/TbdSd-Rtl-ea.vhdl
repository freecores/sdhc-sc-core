--
-- Title: Testbed for SD-Core
-- File: TbdSd-Rtl-ea.vhdl
-- Author: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;
use work.Ics307Values.all;
use work.Rs232.all;

entity TbdSd is

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
	oDigitAdr : out std_ulogic_vector(1 to 3) -- A,B,C
);

end entity TbdSd;

architecture Rtl of TbdSd is

	constant cClkFreq  : natural := 25E6;
	constant cBaudRate : natural := 115200;

	signal iRs232Tx : aiRs232Tx;
	signal oRs232Tx : aoRs232Tx;

	signal SdCardStatus : std_ulogic_vector(31 downto 0);

	type aState is (send, waitforchange);
	type aReg is record
		State : aState;
		SdCardStatus : std_ulogic_vector(31 downto 0);
		Counter : unsigned(1 downto 0);
	end record aReg;

	signal R, NextR : aReg;
	signal Ledbank  : aLedBank;

begin

	oLedBank(6 downto 0) <= Ledbank(6 downto 0);
	oDigitAdr <= "101"; -- DIGIT_6
	oTx       <= oRs232Tx.Tx;

	-- Send SdCardStatus via Rs232
	Rs232_Send : process (iClk, inResetAsync)
	begin
		if (inResetAsync = cnActivated) then
			R.State <= send;
			R.SdCardStatus <= (others => '0');
			R.Counter <= "11";

		elsif (iClk'event and iClk = cActivated) then
			R <= NextR;
			
		end if;
	end process Rs232_Send;

	Rs232_comb : process (oRs232Tx.DataWasRead, SdCardStatus, R)
	begin
		NextR <= R;
		iRs232Tx.Transmit <= cInactivated;
		iRs232Tx.Data <= R.SdCardStatus((to_integer(R.Counter) * 8) + 7 downto to_integer(R.Counter) * 8);
		iRs232Tx.DataAvailable <= cInactivated;

		case R.State is
			when waitforchange => 
				oLedBank(7) <= cActivated;
				if (R.SdCardStatus /= SdCardStatus) then
					NextR.SdCardStatus <= SdCardStatus;
					NextR.State <= send;
				end if;

			when send => 
				oLedBank(7) <= cInactivated;
				iRs232Tx.DataAvailable <= cActivated;
				iRs232Tx.Transmit <= cActivated;

				if (oRs232Tx.DataWasRead = cActivated) then
					if (R.Counter = "00") then
						NextR.Counter <= "11";
						NextR.State <= waitforchange;
					else
						NextR.Counter <= R.Counter - 1;
					end if;
				end if;

			when others => 
				report "Unhandled state" severity error;
		end case;

	end process Rs232_comb;
		
	SDTop_inst : entity work.SdTop(Rtl)
	port map (
		iClk          => iClk,
		inResetAsync  => inResetAsync,
		ioCmd         => ioCmd,
		oSclk         => oSclk,
		ioData        => ioData,
		oSdCardStatus => SdCardStatus,
		oLedBank      => LedBank
	);

	Rs232Tx_inst : entity work.Rs232Tx
	port map(
		iClk         => iClk,
		inResetAsync => inResetAsync,
		iRs232Tx     => iRs232Tx,
		oRs232Tx     => oRs232Tx);

	StrobeGen_Rs232 : entity work.StrobeGen
	generic map (
		gClkFrequency    => cClkFreq,
		gStrobeCycleTime => 1 sec / cBaudRate)
	port map (
		iClk         => iClk,
		inResetAsync => inResetAsync,
		oStrobe      => iRs232Tx.BitStrobe);


	-- Configure clock to 25MHz, it could be configured differently!
	Ics307Configurator_inst : entity work.Ics307Configurator(Rtl)
	generic map(
		gCrystalLoadCapacitance_C   => cCrystalLoadCapacitance_C_25MHz,
		gReferenceDivider_RDW       => cReferenceDivider_RDW_25MHz,
		gVcoDividerWord_VDW         => cVcoDividerWord_VDW_25MHz,
		gOutputDivide_S             => cOutputDivide_S_25MHz,
		gClkFunctionSelect_R        => cClkFunctionSelect_R_25MHz,
		gOutputDutyCycleVoltage_TTL => cOutputDutyCycleVoltage_TTL_25MHz
	)
	port map(
		iClk         => iClk,
		inResetAsync => inResetAsync,
		oSclk        => oIcs307Sclk,
		oData        => oIcs307Data,
		oStrobe      => oIcs307Strobe
	);

end architecture Rtl;

