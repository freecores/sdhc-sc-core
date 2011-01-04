--
-- Title: 
-- File: SdClockMaster-Rtl-a.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: Architecture for SdClockMaster 
--

architecture Rtl of SdClockMaster is

	subtype aCounter is unsigned(1 downto 0); -- maximal division through 4

	type aRegSet is record
		Counter   : aCounter;
		Clk       : std_ulogic;
		Strobe    : std_ulogic;
		InStrobe  : std_ulogic;
		HighSpeed : std_ulogic;
	end record aRegSet;

	signal R,NxR : aRegSet;

begin

	-- connect outputs with registers
	oSdCardClk <= R.Clk;
	oSdStrobe  <= R.Strobe;
	oSdInStrobe <= R.InStrobe;

	Regs : process (iClk, iRstSync)
	begin
		if (rising_edge(iClk)) then

			-- synchronous reset
			if (iRstSync = cActivated) then

				R.Counter   <= to_unsigned(0, R.Counter'length);
				R.Clk       <= cInactivated;
				R.Strobe    <= cInactivated;
				R.InStrobe  <= cInactivated;
				R.HighSpeed <= cInactivated;

			else 
				R <= NxR;

			end if;
		end if;
	end process Regs;

	Comb : process (R, iHighSpeed, iDisable)
	begin

		-- defaults

		NxR <= R;

		case iDisable is
			when cInactivated => 
				NxR.Counter <= R.Counter + 1;

				-- generate clock and strobe
				case R.HighSpeed is
					when cInactivated => -- default mode
						NxR.Clk <= R.Counter(1);

						case R.Counter is
							when "00" | "11"  => 
								NxR.Strobe <= cInactivated;
								NxR.InStrobe <= cInactivated;

							when "10" => 
								NxR.Strobe <= cActivated;
								NxR.InStrobe <= cInactivated;

							when "01" => 
								NxR.InStrobe <= cActivated;
								NxR.Strobe <= cInactivated;

							when others => 
								NxR.Strobe <= 'X';
								NxR.InStrobe <= 'X';
						end case;

					when cActivated => -- High-Speed mode
						NxR.Clk <= R.Counter(0);
						NxR.Strobe  <= R.Counter(0);
						NxR.InStrobe <= not R.Counter(0);

					when others => 
						NxR.Clk <= 'X';
				end case;

				-- switch speeds and increment counter
				case R.HighSpeed is
					when cInactivated => 
						if (R.Counter = 3) then
							NxR.HighSpeed <= iHighSpeed;
						end if;

					when cActivated => 
						if (R.Counter(0) = '1') then
							NxR.HighSpeed <= iHighSpeed;
							NxR.Counter <= "00";
						end if;

					when others => 
						NxR.HighSpeed <= 'X';
				end case;

			when cActivated => 
				-- disable strobes and do not increment the counter 
				NxR.Strobe <= cInactivated;
				NxR.InStrobe <= cInactivated;

			when others => 
				NxR.Clk    <= 'X';
				NxR.Strobe <= 'X';
				NxR.InStrobe <= 'X';

		end case;

	end process Comb;


end architecture Rtl;

