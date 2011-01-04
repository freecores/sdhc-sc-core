--
-- Title: Architecture of TestWbMaster
-- File: TestWbMaster-Rtl-a.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description:  
--

architecture Rtl of TestWbMaster is

	type aState is (startAddr, writeBuffer, write, readbuffer, read, done);
	subtype aCounter is unsigned(7 downto 0); -- 128 * 32 bit = 512 byte

	type aWbState is (idle, write, read);

	type aReg is record

		State : aState;
		Counter : aCounter;
		WbState : aWbState;
		Err : std_ulogic;

	end record aReg;

	signal R, NxR : aReg;

begin

	Regs : process (CLK_I)
	begin
		if (rising_edge(CLK_I)) then

			if (RST_I = '1') then
				-- sync. reset
				R.State   <= startAddr;
				R.Counter <= (others => '0');
				R.WbState <= write;
				R.Err     <= '0';

			else
				R <= NxR;

			end if;

		end if;
	end process Regs;

	StateMachine : process (R, ERR_I, RTY_I, ACK_I, DAT_I)
	begin

		-- default assignment
		NxR <= R;
		ERR_O <= R.Err;
		CTI_O <= "000";
		CYC_O <= '0';
		WE_O  <= '0';
		SEL_O <= "0";
		STB_O <= '0';
		ADR_O <= "000";
		DAT_O <= (others => '0');
		BTE_O <= "00";
		DON_O <= '0';

		-- we don´t care for errors or retrys
		if (ERR_I = '1' or RTY_I = '1') then
			NxR.Err <= '1';
		end if;

		case R.WbState is
			when idle => 
				null;

			when write => 
				-- write data 
				CTI_O <= "000";
				CYC_O <= '1';
				WE_O  <= '1';
				SEL_O <= "1";
				STB_O <= '1';

				if (ACK_I = '1') then
					if (R.Counter = 128) then
						NxR.Counter <= (others => '0');
					else
						NxR.Counter <= R.Counter + 1;
					end if;
				end if;

			when read => 
				-- read data
				CTI_O <= "000";
				CYC_O <= '1';
				WE_O  <= '0';
				SEL_O <= "1";
				STB_O <= '1';

				if (ACK_I = '1') then
					-- check data
					--if to_unsigned(to_integer(DAT_I),32) /= to_unsigned(R.Counter, 32) then
					--	NxR.Err <= '1';
					--end if;

					if (R.Counter = 128) then
						NxR.Counter <= (others => '0');
						NxR.WbState <= idle;
					else
						NxR.Counter <= R.Counter + 1;
					end if;
				end if;

			when others => 
				report "Invalid wbState" severity error;
		end case;
					
		case R.State is
			when startAddr => 
				ADR_O <= "001";
				DAT_O <= X"00000004";

				if (ACK_I = '1') then
					NxR.State <= writeBuffer;
					NxR.Counter <= (others => '0');
					NxR.WbState <= write;
				end if;

			when writeBuffer => 
				ADR_O <= "100"; -- write data
				DAT_O <= std_ulogic_vector(R.Counter) & std_ulogic_vector(R.Counter) &
						 std_ulogic_vector(R.Counter) & std_ulogic_vector(R.Counter);

				if (R.Counter = 128) then
					NxR.State   <= write;
					NxR.Counter <= to_unsigned(128, aCounter'length);
					NxR.WbState <= write;
				end if;

			when write => 
				ADR_O <= "000"; 
				DAT_O <= X"00000010"; -- start write operation

				if (ACK_I = '1') then
					NxR.State   <= done;
					NxR.WbState <= idle;
				end if;

			when read => 
				ADR_O <= "000"; 
				DAT_O <= X"00000001"; -- start read operation

				if (ACK_I = '1') then
					NxR.State <= readBuffer;
					NxR.WbState <= read;
				end if;
				
			when readBuffer => 
				ADR_O <= "011"; -- read data
				
				if (R.Counter = 128) then
					NxR.Counter <= (others => '0');
					NxR.State   <= done;
					NxR.WbState <= idle;
				end if;

			when done => 
				DON_O <= '1';

			when others => 
				report "Invalid state" severity error;
		end case;
		
	end process StateMachine;


end architecture Rtl;
