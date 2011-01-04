-------------------------------------------------
-- file: ../../unitSdTop/src/SdTop-Rtl-ea.vhdl
-- author: Rainer Kastl
--
-- Top level entity for a SD Controller
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;
use work.Sd.all;

entity SdTop is
	generic (
		gClkFrequency  : natural := 25E6;
		gHighSpeedMode : boolean := true
	);
	port (
		iClk         : in std_ulogic;
		inResetAsync : in std_ulogic;

		-- SD Card
		ioCmd  : inout std_logic;
		oSclk  : out std_ulogic;
		ioData : inout std_logic_vector(3 downto 0);

		-- Status
		oReceivedContent      : out aSdCmdContent;
		oReceivedContentValid : out std_ulogic;
		oReceivedData         : out std_ulogic_vector(511 downto 0);
		oReceivedDataValid    : out std_ulogic;
		oLedBank              : out aLedBank
	);

end entity SdTop;

architecture Rtl of SdTop is

	signal SdCmdToController       : aSdCmdToController;
	signal SdCmdFromController     : aSdCmdFromController;
	signal SdDataToController      : aSdDataToController;
	signal SdDataFromController    : aSdDataFromController;
	signal SdDataFromRam           : aSdDataFromRam;
	signal SdDataToRam             : aSdDataToRam;
	signal SdControllerToDataRam   : aSdControllerToRam;
	signal SdControllerFromDataRam : aSdControllerFromRam;
	signal SdStrobe                : std_ulogic;
	signal SdStrobe25MHz           : std_ulogic;
	signal SdStrobe50MHz           : std_ulogic;
	signal HighSpeed               : std_ulogic;

	signal iCmd : aiSdCmd;
	signal oCmd : aoSdCmd;
	signal iData : aiSdData;
	signal oData : aoSdData;

	signal Sclk : std_ulogic;
	signal Counter : natural range 0 to 3;

begin

	Reg : process (iClk, inResetAsync)
	begin
		if (inResetAsync = cnActivated) then
			iCmd.Cmd   <= '1';
			iData.Data <= (others => '1');
		elsif (rising_edge(iClk)) then
			iCmd.Cmd   <= ioCmd;
			iData.Data <= std_ulogic_vector(ioData);
		end if;
	end process Reg;

	ioCmd <= oCmd.Cmd when oCmd.En = cActivated else 'Z';
	Gen_data : for i in 0 to 3 generate
		ioData(i) <= oData.Data(i) when oData.En(i) = cActivated else 'Z';
	end generate;

	Sclk100MHz:  if gClkFrequency = 100E6 generate

		ClkDivider : process (iClk, inResetAsync)
		begin
			if (inResetAsync = cnActivated) then
				Counter <= 0;
				Sclk <= cInactivated;

			elsif (rising_edge(iClk)) then
				if (HighSpeed = cActivated) then
					if (Counter = 0 or Counter = 2) then
						Sclk <= cActivated;
					else
						Sclk <= cInactivated;
					end if;
				else
					if (Counter = 0 or Counter = 1) then
						Sclk <= cActivated;
					else
						Sclk <= cInactivated;
					end if;
				end if;

				if (Counter < 3) then
					Counter <= Counter + 1;
				else 
					Counter <= 0;
				end if;
			end if;
		end process ClkDivider;

		oSclk    <= not Sclk;
		SdStrobe <= SdStrobe25MHz when HighSpeed = cInactivated else SdStrobe50MHz;
	
		SdStrobe_inst25: entity work.StrobeGen(Rtl)
		generic map (
			gClkFrequency    => gClkFrequency,
			gStrobeCycleTime => 1 sec / 25E6)
		port map (
			iClk         => iClk,
			inResetAsync => inResetAsync,
			oStrobe      => SdStrobe25MHz);
	
		SdStrobe_inst50: entity work.StrobeGen(Rtl)
		generic map (
			gClkFrequency    => gClkFrequency,
			gStrobeCycleTime => 1 sec / 50E6)
		port map (
			iClk         => iClk,
			inResetAsync => inResetAsync,
			oStrobe      => SdStrobe50MHz);
	
	end generate;

	Sclk50Mhz: if gClkFrequency = 50E6 generate

		oSclk <= not Sclk;
		Sclk    <= SdStrobe25MHz when HighSpeed = cInactivated else iClk;
		SdStrobe <= SdStrobe25MHz when HighSpeed = cInactivated else cActivated;
	
		SdStrobe_inst: entity work.StrobeGen(Rtl)
		generic map (
			gClkFrequency    => gClkFrequency,
			gStrobeCycleTime => 1 sec / 25E6)
		port map (
			iClk         => iClk,
			inResetAsync => inResetAsync,
			oStrobe      => SdStrobe25MHz);
	
	end generate;	

	Sclk25MHz: if gClkFrequency = 25E6 generate

		oSclk    <= not iClk;
		SdStrobe <= cActivated;

	end generate;

	oReceivedContent      <= SdCmdToController.Content;
	oReceivedContentValid <= SdCmdToController.Valid;
	oReceivedDataValid    <= SdDataToController.Valid;

	SdController_inst: entity work.SdController(Rtl)
	generic map (
		gClkFrequency  => gClkFrequency,
		gHighSpeedMode => gHighSpeedMode
	)
	port map (
		iClk         => iClk,
		inResetAsync => inResetAsync,
		oHighSpeed   => HighSpeed,
		iSdCmd       => SdCmdToController,
		oSdCmd       => SdCmdFromController,
		iSdData      => SdDataToController,
		oSdData		 => SdDataFromController,
		iDataRam     => SdControllerFromDataRam,
		oDataRam     => SdControllerToDataRam,
		oLedBank     => oLedBank
	);

	SdCmd_inst: entity work.SdCmd(Rtl)
	port map (
		iClk            => iClk,
		inResetAsync    => inResetAsync,
		iStrobe         => SdStrobe,
		iFromController => SdCmdFromController,
		oToController   => SdCmdToController,
		iCmd            => iCmd,
		oCmd            => oCmd
	);

	SdData_inst: entity work.SdData 
	port map (
		iClk                  => iClk,
		inResetAsync          => inResetAsync,
		iStrobe               => SdStrobe,
		iSdDataFromController => SdDataFromController,
		oSdDataToController   => SdDataToController,
		iSdDataFromRam        => SdDataFromRam,
		oSdDataToRam          => SdDataToRam,
		iData                 => iData,
		oData                 => oData
	);

	DataRam_inst: entity work.SimpleDualPortedRam
	generic map (
		gDataWidth => 32,
		gAddrWidth => 7
	)
	port map (
		iClk    => iClk,
		iAddrRW => SdDataToRam.Addr,
		iDataRW => SdDataToRam.Data,
		iWeRW   => SdDataToRam.We,
		oDataRW => SdDataFromRam.Data,
		iAddrR  => SdControllerToDataRam.Addr,
		oDataR  => SdControllerFromDataRam.Data
	);

end architecture Rtl;

