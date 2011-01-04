--
-- Title: SdWbSlave
-- File: SdWbSlave-Rtl-ea.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: Wishbone interface for the SD-Core 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.Global.all;
use work.wishbone.all;
use work.SdWb.all;

entity SdWbSlave is
	generic (
		gPortSize           : natural := 32; -- in bits, only 8, 16, 32 and 64 are valid
		gPortGranularity    : natural := 32; -- in bits, only 8, 16, 32 and 64 are valid
		gMaximumOperandSize : natural := 32; -- in bits, only 8, 16, 32 and 64 are valid
		gAddressWidth       : natural := 8 -- in bits, see also gPortGranularity and iAdr
	);
	port (
		iClk     : in std_ulogic; -- Clock, rising clock edge
		iRstSync : in std_ulogic; -- Reset, active high, synchronous

		-- wishbone
		iWbCtrl : in aWbSlaveCtrlInput; -- All control signals for a wishbone slave
		oWbCtrl : out aWbSlaveCtrlOutput; -- All output signals for a wishbone slave
		iWbDat  : in aSdWbSlaveDataInput;
		oWbDat  : out aSdWbSlaveDataOutput; 
		
		-- To sd controller
		iController : in aSdControllerToSdWbSlave;
		oController : out aSdWbSlaveToSdController	
	);
end entity;

architecture Rtl of SdWbSlave is

	type aWbState is (idle, ClassicRead, ClassicWrite);

	type aRegs is record
		State     : aWbState;
		Operation : aData;
		StartAddr : aData;
		EndAddr   : aData;
	end record aRegs;

	constant cDefaultRegs : aRegs := (
	State     => idle,
	Operation => (others => '0'),
	StartAddr => (others => '0'),
	EndAddr   => (others => '0'));

	signal R, NxR : aRegs;

begin
 
	WbStateReg  : process (iClk, iRstSync)
	begin
		if (iClk'event and iClk = cActivated) then
			if (iRstSync = cActivated) then -- sync. reset
				R <= cDefaultRegs;
			else
				R <= NxR;
			end if;
		end if;
	end process WbStateReg ;

	WbStateAndOutputs : process (iWbCtrl, iWbDat, iController, R)
	begin
		-- Default Assignments
		oWbDat.Dat  <= (others => 'X');
		oWbCtrl    <= cDefaultWbSlaveCtrlOutput;
		oController <= cDefaultSdWbSlaveToSdController;
		NxR         <= R;

		-- Determine next state
		case R.State is
			when idle =>
				if iWbCtrl.Cyc = cActivated and iWbCtrl.Stb = cActivated then
				
					case iWbCtrl.Cti is
						when cCtiClassicCycle => 
			
							if (iWbCtrl.We = cInactivated) then
								NxR.State <= ClassicRead;
							elsif (iWbCtrl.We = cActivated) then
								NxR.State <= ClassicWrite;
							end if;
			
						when others => null;
					end case;
				
				end if;

			when ClassicRead =>
				assert (iWbCtrl.Cyc = cActivated) report
				"Cyc deactivated mid cyclus" severity warning;

				oWbCtrl.Ack <= cActivated;	

				if (iWbDat.Sel = "1") then
					case iWbDat.Adr is
						when cOperationAddr => 
							oWbDat.Dat <= R.Operation;

						when cStartAddrAddr => 
							oWbDat.Dat <= R.StartAddr;

						when cEndAddrAddr => 
							oWbDat.Dat <= R.EndAddr;

						when cWriteDataAddr => 
							-- put into fifo

						when others => 
							report "Read to an invalid address" severity warning;
					end case;
				end if;
				
				NxR.State <= idle;

			when ClassicWrite =>
				assert (iWbCtrl.Cyc = cActivated) report
				"Cyc deactivated mid cyclus" severity warning;

				oWbCtrl.Ack <= cActivated;	
				
				if (iWbDat.Sel = "1") then
					case iWbDat.Adr is
						when cOperationAddr => 
							NxR.Operation <= iWbDat.Dat;
							-- notify controller

						when cStartAddrAddr => 
							NxR.StartAddr <= iWbDat.Dat;

						when cEndAddrAddr => 
							NxR.EndAddr <= iWbDat.Dat;

						when cWriteDataAddr => 
							-- put into fifo

						when others => 
							report "Read to an invalid address" severity warning;
					end case;
				end if;

				NxR.State <= idle;

			when others => null;
		end case;

	end process WbStateAndOutputs;
end architecture Rtl;

