--
-- Title: 
-- File: SdClockMaster-Rtl-a.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: Architecture for SdClockMaster 
--

architecture Rtl of SdClockMaster is

	signal SdClk         : std_ulogic;
	signal Counter       : natural range 0 to 3;
	signal SdStrobe25MHz : std_ulogic;
	signal SdStrobe50MHz : std_ulogic;
	signal Disable 		 : std_ulogic;

begin

	SdClk100MHz:  if gClkFrequency = 100E6 generate

		ClkDivider : process (iClk, iRstSync)
		begin
			if (rising_edge(iClk)) then

				-- synchronous reset
				if (iRstSync = cActivated) then
					Counter <= 0;
					SdClk <= cInactivated;
				else
					if (iDisable = cActivated and SdClk = cInactivated) then
						Disable <= cActivated;
					else

						if (Disable = cActivated and iDisable = cInactivated) then
							Disable <= cInactivated;
						else

							if (iHighSpeed = cActivated) then
								if (Counter = 0 or Counter = 2) then
									SdClk <= cActivated;
								else
									SdClk <= cInactivated;
								end if;
							else
								if (Counter = 0 or Counter = 1) then
									SdClk <= cActivated;
								else
									SdClk <= cInactivated;
								end if;
							end if;

							if (Counter < 3) then
								Counter <= Counter + 1;
							else 
								Counter <= 0;
							end if;
						end if;
					end if;
				end if;
			end if;
		end process ClkDivider;


		RegSdStrobe : process (iClk, iRstSync)
		begin
			if (rising_edge(iClk)) then
				-- synchronous reset
				if (iRstSync = cActivated) then
					oSdCardClk <= cInactivated;
					oSdStrobe <= cInactivated;
				else

					if (iDisable = cActivated) then
						oSdCardClk <= cInactivated;
						oSdStrobe  <= cInactivated;

					else

						oSdCardClk <= not SdClk;

						if (iHighSpeed = cInactivated) then
							oSdStrobe <= SdStrobe25MHz;
						else 
							oSdStrobe <= SdStrobe50MHz;
						end if;

					end if;
				end if;
			end if;
		end process RegSdStrobe;

		SdStrobe_inst25: entity work.StrobeGen(Rtl)
		generic map (
			gClkFrequency    => gClkFrequency,
			gStrobeCycleTime => 1 sec / 25E6)
		port map (
			iClk     => iClk,
			iRstSync => iRstSync,
			oStrobe  => SdStrobe25MHz);

		SdStrobe_inst50: entity work.StrobeGen(Rtl)
		generic map (
			gClkFrequency    => gClkFrequency,
			gStrobeCycleTime => 1 sec / 50E6)
		port map (
			iClk     => iClk,
			iRstSync => iRstSync,
			oStrobe  => SdStrobe50MHz);

	end generate;

end architecture Rtl;

