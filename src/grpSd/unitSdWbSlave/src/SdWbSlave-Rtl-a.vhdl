--
-- Title: SdWbSlave
-- File: SdWbSlave-Rtl-ea.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: Wishbone interface for the SD-Core 
--

architecture Rtl of SdWbSlave is

	type aWbState is (idle, ClassicRead, ClassicWrite);
	type aSdIntState is (idle, newOperation);

	type aRegs is record

		WbState        : aWbState; -- state of the wb interface
		SdIntState     : aSdIntState; -- state of the sd controller interface
		OperationBlock : aOperationBlock; -- Operation for the SdController
		ReqOperation   : std_ulogic; -- Register for catching edges on the SdController ReqOperationEdge line
		-- Register outputs
		oWbDat         : aSdWbSlaveDataOutput;
		oWbCtrl        : aWbSlaveCtrlOutput;
		oController    : aSdWbSlaveToSdController;

	end record aRegs;

	constant cDefaultRegs : aRegs := (
	WbState        => idle,
	SdIntState     => idle,
	OperationBlock => cDefaultOperationBlock,
	ReqOperation   => cInactivated,
	oWbDat         => (Dat => (others                           => '0')),
	oWbCtrl        => cDefaultWbSlaveCtrlOutput,
	oController    => cDefaultSdWbSlaveToSdController);

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

		NxR             <= R;
		NxR.oWbDat.Dat  <= (others => 'X');
		NxR.oWbCtrl     <= cDefaultWbSlaveCtrlOutput;

		-- Determine next state
		case R.WbState is
			when idle =>
				if iWbCtrl.Cyc = cActivated and iWbCtrl.Stb = cActivated then
				
					case iWbCtrl.Cti is
						when cCtiClassicCycle => 
							-- switch to ClassicRead or ClassicWrite
							case iWbCtrl.We is
								when cInactivated => 
									NxR.WbState <= ClassicRead;
								when cActivated => 
									NxR.WbState <= ClassicWrite;
								when others => 
									report "iWbCtrl.We is invalid" severity warning;
							end case;		
			
						when others => null;
					end case;
				
				end if;

			when ClassicRead =>
				assert (iWbCtrl.Cyc = cActivated) report
				"Cyc deactivated mid cyclus" severity warning;

				NxR.oWbCtrl.Ack <= cActivated;	

				if (iWbDat.Sel = "1") then
					case iWbDat.Adr is
						when cOperationAddr => 
							NxR.oWbDat.Dat <= R.OperationBlock.Operation;

						when cStartAddrAddr => 
							NxR.oWbDat.Dat <= R.OperationBlock.StartAddr;

						when cEndAddrAddr => 
							NxR.oWbDat.Dat <= R.OperationBlock.EndAddr;

						when cReadDataAddr => 
							-- read data from fifo

						when others => 
							report "Read to an invalid address" severity warning;
							NxR.oWbCtrl.Err <= cActivated;
							NxR.oWbCtrl.Ack <= cInactivated;
					end case;
				end if;
				
				NxR.WbState <= idle;

			when ClassicWrite =>
				assert (iWbCtrl.Cyc = cActivated) report
				"Cyc deactivated mid cyclus" severity warning;

				-- default state transition and output

				NxR.oWbCtrl.Ack <= cActivated;
				NxR.WbState     <= idle;

				if (iWbDat.Sel = "1") then
					case iWbDat.Adr is
						when cOperationAddr => 
							
							if (R.SdIntState = idle) then
								-- save operation and notify the SdController

								NxR.OperationBlock.Operation <= iWbDat.Dat;
								NxR.SdIntState               <= newOperation;

							else
								-- insert waitstates until we can notify the SdController again

								NxR.oWbCtrl.Ack <= cInactivated; 

							end if;

						when cStartAddrAddr => 

							NxR.OperationBlock.StartAddr <= iWbDat.Dat;

						when cEndAddrAddr => 

							NxR.OperationBlock.EndAddr <= iWbDat.Dat;

						when cWriteDataAddr => 
							-- put into fifo

						when others => 
							report "Read to an invalid address" severity warning;
					end case;
				end if;

			when others => null;
		end case;

		-- send operations to SdController
		case R.SdIntState is
			when idle => 
				-- save edges on the ReqOperationEdge line which would be missed otherwise

				if (iController.ReqOperationEdge = cActivated) then

					R.ReqOperation <= cActivated;
					
				end if;

			when newOperation => 
				-- send a new operation, when the controller requested it
				if (R.ReqOperation = cActivated or iController.ReqOperationEdge = cActivated) then

					NxR.oController.OperationBlock     <= R.OperationBlock;
					NxR.oController.AckOperationToggle <= not R.oController.AckOperationToggle;

					-- go to idle state, the next request will come only after the SdController received this block
					
					NxR.ReqOperation <= cInactivated;
					NxR.SdIntState   <= idle;

				end if;
					
			when others => 
				report "Invalid state" severity error;
		end case;

	end process WbStateAndOutputs;
end architecture Rtl;

