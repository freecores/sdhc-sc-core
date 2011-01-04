--
-- Title: Rs232 Transmitter
-- File: Rs232Tx-Rtl-ea.vhdl
-- Author: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description:  
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Global.all;
use work.Rs232.all;

entity Rs232Tx is
	generic (
		gDataBitWidth : natural := 8
	);
	port (
		iClk         : in std_ulogic;
		inResetAsync : in std_ulogic;
		iRs232Tx     : in aiRs232Tx;
		oRs232Tx     : out aoRs232Tx
	);
end entity Rs232Tx;

architecture Rtl of Rs232Tx is

	type aDataInputState is (
	CanAcceptNewData, 
	FreshDataArrived, 
	DataBufferBusy);

	type aRegion is (
		StartBit,
		DataBits,
		ParityBit,
		StopBit,
		StopBitAndIdle);


	type aRegSet is record
		DataInputState : aDataInputState;
		Region         : aRegion;
		BitIdx         : natural range 0 to gDataBitWidth;
		DataWasRead    : std_ulogic;
		Data           : std_ulogic_vector(gDataBitWidth - 1 downto 0);
		Tx             : std_ulogic;
	end record aRegSet;	

	constant cInitValR : aRegSet := (
		DataInputState => CanAcceptNewData,
		Region         => StopBitAndIdle,
		BitIdx         => 0,
		DataWasRead    => cInactivated,
		Data           => (others => '0'),
		Tx             => cTxLineStopBitVal
	);

	signal R, NextR : aRegSet;

begin
	
	Comb : process (R, iRs232Tx)
		variable parity : std_ulogic;
	begin
		NextR             <= R;
		NextR.DataWasRead <= cInactivated;

		-- Parallel data input
		case R.DataInputState is
			when CanAcceptNewData => 
				-- We are waiting for data to be transmitted
				if (iRs232Tx.Transmit = cActivated and 
				iRs232Tx.DataAvailable = cActivated) then
					NextR.Data           <= iRs232Tx.Data;
					NextR.DataInputState <= FreshDataArrived;
					NextR.DataWasRead    <= cActivated;
				end if;

			when FreshDataArrived => 
				-- We have loaded new data into the send register
				if (R.Region = StartBit) then
					NextR.DataInputState <= DataBufferBusy;
				end if;

			when DataBufferBusy => 
				-- The send register is still occupied.
				if (R.Region = StopBitAndIdle) then
					NextR.DataInputState <= CanAcceptNewData;
				end if;
		end case;

		-- Serial data output
		case R.Region is
			when StartBit => 
				NextR.Tx <= cTxLineStartBitVal;
				if (iRs232Tx.BitStrobe = cActivated) then
					NextR.Region <= DataBits;
					NextR.BitIdx <= 0;
				end if;

			when DataBits => 
				NextR.Tx <= R.Data(R.BitIdx);
				if (iRs232Tx.BitStrobe = cActivated) then
					if (R.BitIdx = gDataBitWidth - 1) then
						-- All bits sent
						NextR.Region <= ParityBit;
					else
						-- Send next bit
						NextR.BitIdx <= R.BitIdx + 1;
					end if;
				end if;

			when ParityBit => 
				-- Use even parity
				parity := R.Data(0);
				for i in 1 to gDataBitWidth-1 loop
					parity := parity xor R.Data(i);
				end loop;
				NextR.Tx <= parity;
				
				if (iRs232Tx.BitStrobe = cActivated) then
					NextR.Region <= StopBit;
				end if;

			when StopBit => 
				NextR.Tx <= cTxLineStopBitVal;
				if (iRs232Tx.BitStrobe = cActivated) then
					NextR.Region <= StopBitAndIdle;
				end if;

			when StopBitAndIdle => 
				NextR.Tx <= cTxLineStopBitVal;
				if (iRs232Tx.BitStrobe = cActivated) then
					if (R.DataInputState = FreshDataArrived) then
						NextR.Region <= StartBit;
					end if;
				end if;
		end case;
	end process Comb;

	Regs : process (iClk, inResetAsync)
	begin
		if (inResetAsync = cnActivated) then
			R <= cInitValR;
		elsif (iClk'event and iClk = '1') then
			R <= NextR;
		end if;
	end process Regs;

	-- Connect registers to ports
	oRs232Tx.DataWasRead <= R.DataWasRead;
	oRs232Tx.Tx          <= R.Tx;

end architecture Rtl;

