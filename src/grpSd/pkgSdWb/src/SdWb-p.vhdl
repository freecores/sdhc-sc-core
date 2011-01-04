--
-- Title: SD Wishbone interface package
-- File: SdWb-p.vhdl
-- Author: Copyright 2010: Rainer Kastl
-- Standard: VHDL'93
-- 
-- Description: 
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package SdWb is

	-- data and address types
	subtype aData is std_ulogic_vector(31 downto 0);
	subtype aAddr is std_ulogic_vector(31 downto 0);

	subtype aWbAddr is std_ulogic_vector(6 downto 4);

	-- operation type
	subtype aOperation is std_ulogic_vector(31 downto 0);

	-- different valid operation values
	constant cOperationRead : aOperation := (0 => '1', others => '0');


	-- addresses for register banks in SdWbSlave
	constant cOperationAddr : aWbAddr := "000";
	constant cStartAddrAddr : aWbAddr := "001";
	constant cEndAddrAddr   : aWbAddr := "010";
	constant cReadDataAddr  : aWbAddr := "011";
	constant cWriteDataAddr : aWbAddr := "100";

	-- ports
	type aSdWbSlaveToSdController is record
		StartAddr : aAddr;
		EndAddr   : aAddr;
		Operation : aOperation;
		Valid     : std_ulogic;
		WriteData : aData;
	end record aSdWbSlaveToSdController;

	type aSdControllerToSdWbSlave is record
		Done     : std_ulogic;
		ReadData : aData;
	end record aSdControllerToSdWbSlave;

	type aSdWbSlaveDataOutput is record
		Dat : aData;
	end record aSdWbSlaveDataOutput;

	type aSdWbSlaveDataInput is record
		Sel : std_ulogic_vector(0 downto 0);
		Adr : aWbAddr;
		Dat : aData;
	end record aSdWbSlaveDataInput;

	-- default port values
	constant cDefaultSdWbSlaveToSdController : aSdWbSlaveToSdController := (
	StartAddr => (others => '0'),
	EndAddr   => (others => '0'),
	Operation => (others => '0'),
	Valid     => '0',
	WriteData => (others => '0'));

end package SdWb;

