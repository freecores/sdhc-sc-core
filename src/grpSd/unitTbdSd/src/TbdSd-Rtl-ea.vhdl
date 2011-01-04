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
use work.Sd.all;

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

	type aState is (id, arg, waitforchange, data, crc);
	type aReg is record
		State : aState;
		Counter : natural;
		ReceivedContent : aSdCmdContent;
		ValidContent : aSdCmdContent;
		Data : std_ulogic_vector(7 downto 0);
		DataAvailable : std_ulogic;
	end record aReg;

	constant cDefaultReg : aReg := (
		State           => waitforchange,
		Counter         => 3,
		ReceivedContent => cDefaultSdCmdContent,
		ValidContent    => cDefaultSdCmdContent,
		Data            => (others               => '0'),
		DataAvailable   => cInactivated);

	signal R                     : aReg := cDefaultReg;
	signal NextR                 : aReg;
	signal ReceivedContent       : aSdCmdContent;
	signal oReceivedContentValid : std_ulogic;
	signal ReceivedData          : std_ulogic_vector(511 downto 0);
	signal ReceivedDataValid     : std_ulogic;
	signal ReceivedCrc                   : std_ulogic_vector(15 downto 0);

begin

	oDigitAdr <= "101"; -- DIGIT_6
	oTx       <= oRs232Tx.Tx;

	iRs232Tx.Transmit      <= cActivated;
	iRs232Tx.Data          <= R.Data;
	iRs232Tx.DataAvailable <= R.DataAvailable;

	-- Send ReceivedContent via Rs232
	Rs232_Send : process (iClk, inResetAsync)
	begin
		if (inResetAsync = cnActivated) then
			R <= cDefaultReg;

		elsif (iClk'event and iClk = cActivated) then
			R <= NextR;
			
		end if;
	end process Rs232_Send;

	Rs232_comb : process (oRs232Tx.DataWasRead, ReceivedContent, oReceivedContentValid, ReceivedDataValid, ReceivedData, ReceivedCrc, R)
	begin
		NextR <= R;

		case R.State is
			when waitforchange => 
				NextR.DataAvailable <= cInactivated;

--				if (R.ReceivedContent /= R.ValidContent) then
--					NextR.ReceivedContent <= R.ValidContent;
--					NextR.State <= id;
--				end if;

				if (ReceivedDataValid = cActivated) then
					NextR.Counter <= 63;
					NextR.State <= data;
				end if;

			when id => 
				NextR.DataAvailable <= cActivated;
				NextR.Data <= "00" & R.ReceivedContent.id;

				if (oRs232Tx.DataWasRead = cActivated) then
					NextR.DataAvailable <= cInactivated;
					NextR.State <= arg;
				end if;

			when arg => 
				NextR.DataAvailable <= cActivated;
				NextR.Data <= R.ReceivedContent.arg(R.Counter * 8 + 7 downto R.Counter * 8);

				if (oRs232Tx.DataWasRead = cActivated) then
					NextR.DataAvailable <= cInactivated;
					if (R.Counter = 0) then
						NextR.Counter <= 3;
						NextR.State <= waitforchange;
					else
						NextR.Counter <= R.Counter - 1;
					end if;
				end if;

			when data => 
				NextR.DataAvailable <= cActivated;
				NextR.Data <= ReceivedData(R.Counter * 8 + 7 downto R.Counter * 8);
				
				if (oRs232Tx.DataWasRead = cActivated) then
					NextR.DataAvailable <= cInactivated;
					if (R.Counter = 0) then
						NextR.Counter <= 1;
						NextR.State <= crc;
					else
						NextR.Counter <= R.Counter - 1;
					end if;
				end if;

			when crc => 
				NextR.DataAvailable <= cActivated;
				NextR.Data <= ReceivedCrc(R.Counter * 8 + 7 downto R.Counter * 8);
				
				if (oRs232Tx.DataWasRead = cActivated) then
					NextR.DataAvailable <= cInactivated;
					if (R.Counter = 0) then
						NextR.Counter <= 0;
						NextR.State <= waitforchange;
					else
						NextR.Counter <= R.Counter - 1;
					end if;
				end if;

			when others => 
				report "Unhandled state" severity error;
		end case;

		if (oReceivedContentValid = cActivated) then
			NextR.ValidContent <= ReceivedContent;
		end if;

	end process Rs232_comb;
		
	SDTop_inst : entity work.SdTop(Rtl)
	port map (
		iClk                 => iClk,
		inResetAsync          => inResetAsync,
		ioCmd                 => ioCmd,
		oSclk                 => oSclk,
		ioData                => ioData,
		oReceivedContent      => ReceivedContent,
		oReceivedContentValid => oReceivedContentValid,
		oReceivedData         => ReceivedData,
		oReceivedDataValid    => ReceivedDataValid,
		oCrc                  => ReceivedCrc,
		oLedBank              => oLedBank
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

