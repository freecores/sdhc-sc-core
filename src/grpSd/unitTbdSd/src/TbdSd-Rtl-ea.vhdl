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
	generic (
		gClkFreq : natural := 100E6;
		gDebug : boolean := false
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

	constant cClkFreq  : natural := gClkFreq;
	constant cBaudRate : natural := 115200;

	signal iRs232Tx : aiRs232Tx;
	signal oRs232Tx : aoRs232Tx;

	type aReadState is (waitforchange, send);
	type aWriteState is (idle, id, arg, data, crc);
	type aRamMode is (read, write);

	type aReg is record
		ReadState     : aReadState;
		ReadCounter   : natural;
		WriteState    : aWriteState;
		WriteCounter  : natural;
		RamMode		  : aRamMode;
		Data          : std_ulogic_vector(7 downto 0);
		RamBuffer	  : std_ulogic_vector(31 downto 0);
		DataAvailable : std_ulogic;
		RamReadAddr   : natural range 0 to 2**8-1;
		RamAddr       : natural range 0 to 2**8-1;
		RamWriteAddr  : natural range 0 to 2**8-1;
		RamWe         : std_ulogic;
		RamData       : std_ulogic_vector(31 downto 0);
	end record aReg;

	constant cDefaultReg : aReg := (
	ReadState     => waitforchange,
	ReadCounter   => 0,
	WriteState    => idle,
	WriteCounter  => 0,
	RamMode		  => read,
	Data          => (others => '0'),
	RamBuffer     => (others => '0'),
	DataAvailable => cInactivated,
	RamReadAddr   => 0,
	RamAddr		  => 0,
	RamWriteAddr  => 0,
	RamWe         => cInactivated,
	RamData       => (others       => '0'));

	signal R                     : aReg                             := cDefaultReg;
	signal NextR                 : aReg;
	signal ReceivedContent       : aSdCmdContent;
	signal oReceivedContentValid : std_ulogic;
	signal ReceivedData          : std_ulogic_vector(511 downto 0);
	signal ReceivedDataValid     : std_ulogic;
	signal RamData               : std_ulogic_vector(31 downto 0);

begin

	oDigitAdr              <= "101"; -- DIGIT_6

	NoDebug_inst: if gDebug = false generate
		oTx <= '1';
	end generate;

	Debug_inst: if gDebug = true generate
		oTx                    <= oRs232Tx.Tx;

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

		Rs232_comb : process (oRs232Tx.DataWasRead, ReceivedContent, oReceivedContentValid, ReceivedDataValid, ReceivedData, RamData, R)
			variable NextWrite : std_ulogic;

		begin
			NextR       <= R;
			NextR.RamWe <= cInactivated;
			NextWrite := cActivated;

			case R.WriteState is
				when idle => 
					NextR.WriteCounter <= 0;
					NextWrite := cInactivated;

					if (ReceivedDataValid = cActivated) then
						NextR.WriteState <= data;
					elsif (oReceivedContentValid = cActivated) then
						NextR.WriteState <= id;
					end if;

				when id => 
					NextR.RamWriteAddr <= R.RamWriteAddr + 1;
					NextR.RamAddr      <= R.RamWriteAddr + 1;
					NextR.RamData      <= X"000000" & "00" & ReceivedContent.id;
					NextR.RamWe        <= cActivated;
					NextR.WriteState   <= arg;

				when arg => 
					NextR.RamWriteAddr <= R.RamWriteAddr + 1;
					NextR.RamAddr      <= R.RamWriteAddr + 1;
					NextR.RamData      <= ReceivedContent.arg;
					NextR.RamWe        <= cActivated;
					NextR.WriteState   <= idle;

				when data => 
					NextR.RamWriteAddr <= R.RamWriteAddr + 1;
					NextR.RamAddr      <= R.RamWriteAddr + 1;
					NextR.RamData      <= ReceivedData((15-R.WriteCounter) * 32 + 31 downto (15 - R.WriteCounter) * 32);
					NextR.RamWe        <= cActivated;

					if (R.WriteCounter = 15) then
						NextR.WriteState   <= idle;
					else
						NextR.WriteCounter <= R.WriteCounter + 1;
					end if;

				when others => 
					report "Unhandled state" severity error;
			end case;

			case R.ReadState is
				when waitforchange => 
					NextR.DataAvailable <= cInactivated;

					if (R.RamReadAddr /= R.RamWriteAddr and NextWrite = cInactivated) then
						NextR.RamReadAddr <= R.RamReadAddr + 1;
						NextR.RamAddr <= R.RamReadAddr + 1;
						NextR.ReadCounter <= 0;
						NextR.ReadState   <= send;
					end if;

				when send =>
					NextR.DataAvailable <= cActivated;

					if (R.ReadCounter = 0) then
						NextR.Data <= RamData((3-R.ReadCounter)*8 + 7 downto (3-R.ReadCounter)*8);
						NextR.RamBuffer <= RamData;
					else
						NextR.Data <= R.RamBuffer((3-R.ReadCounter)*8 + 7 downto (3-R.ReadCounter)*8);
					end if;

					if (oRs232Tx.DataWasRead = cActivated) then
						NextR.DataAvailable <= cInactivated;

						if (R.ReadCounter = 3) then
							NextR.ReadState <= waitforchange;
						else
							NextR.ReadCounter <= R.ReadCounter + 1;
						end if;
					end if;

				when others => 
					report "Invalid state" severity error;
			end case;

		end process Rs232_comb;

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

		Ram_inst : entity work.SinglePortedRam
		generic map(
			gDataWidth => 32,
			gAddrWidth => 7
		)
		port map (
			iClk  => iClk,
			iAddr => R.RamAddr,
			iData => R.RamData,
			iWe   => R.RamWe,
			oData => RamData
		);

	end generate;

	Gen25MHz: if gClkFreq = 25E6 generate
	-- Configure clock to 25MHz
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
	end generate;

	Gen50MHz: if gClkFreq = 50E6 generate
	-- Configure clock to 50MHz
		Ics307Configurator_inst : entity work.Ics307Configurator(Rtl)
		generic map(
			gCrystalLoadCapacitance_C   => cCrystalLoadCapacitance_C_50MHz,
			gReferenceDivider_RDW       => cReferenceDivider_RDW_50MHz,
			gVcoDividerWord_VDW         => cVcoDividerWord_VDW_50MHz,
			gOutputDivide_S             => cOutputDivide_S_50MHz,
			gClkFunctionSelect_R        => cClkFunctionSelect_R_50MHz,
			gOutputDutyCycleVoltage_TTL => cOutputDutyCycleVoltage_TTL_50MHz
		)
		port map(
			iClk         => iClk,
			inResetAsync => inResetAsync,
			oSclk        => oIcs307Sclk,
			oData        => oIcs307Data,
			oStrobe      => oIcs307Strobe
		);
	end generate;

	Gen100MHz: if gClkFreq = 100E6 generate
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
		gClkFrequency => cClkFreq,
		gHighSpeedMode => false
	)
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
		oLedBank              => oLedBank
	);

end architecture Rtl;

