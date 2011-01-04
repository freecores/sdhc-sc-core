-- SDHC-SC-Core
-- Secure Digital High Capacity Self Configuring Core
-- 
-- (C) Copyright 2010 Rainer Kastl
-- 
-- This file is part of SDHC-SC-Core.
-- 
-- SDHC-SC-Core is free software: you can redistribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or (at
-- your option) any later version.
-- 
-- SDHC-SC-Core is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- General Public License for more details.
-- 
-- You should have received a copy of the GNU Lesser General Public License
-- along with SDHC-SC-Core. If not, see http://www.gnu.org/licenses/.
-- 
-- File        : SdWb-p.vhdl
-- Owner       : Rainer Kastl
-- Description : SD Wishbone interface package
-- Links       : 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package SdWb is

	-- data and address types
	subtype aData is std_ulogic_vector(31 downto 0);
	subtype aSdBlockAddr is std_ulogic_vector(31 downto 0);

	subtype aWbAddr is std_ulogic_vector(6 downto 4);

	-- operation type
	subtype aOperation is std_ulogic_vector(31 downto 0);

	-- different valid operation values
	constant cOperationRead  : aOperation := X"00000001";
	constant cOperationWrite : aOperation := X"00000010";


	-- addresses for register banks in SdWbSlave

	constant cOperationAddr : aWbAddr := "000";
	constant cStartAddrAddr : aWbAddr := "001";
	constant cEndAddrAddr   : aWbAddr := "010";
	constant cReadDataAddr  : aWbAddr := "011";
	constant cWriteDataAddr : aWbAddr := "100";

	-- configuration of the next operation
	type aOperationBlock is record

		StartAddr       : aSdBlockAddr; -- start block address for SD card the next operation
		EndAddr         : aSdBlockAddr; -- last block address
		Operation       : aOperation; -- operation to execute (Read, write, etc.)

	end record aOperationBlock;

	constant cDefaultOperationBlock : aOperationBlock := (
	StartAddr => (others => '0'),
	EndAddr   => (others => '0'),
	Operation => (others => '0'));


	-- ports
	type aSdWbSlaveToSdController is record

		AckOperation   : std_ulogic; -- every edge signals that the OperationBlock is valid
		OperationBlock : aOperationBlock;
		WriteData      : aData; -- data to write to the card (32 bit blocks)

	end record aSdWbSlaveToSdController;

	type aSdControllerToSdWbSlave is record

		ReqOperation : std_ulogic; -- Request a new OperationBlock
		ReadData     : aData;

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
	OperationBlock => cDefaultOperationBlock,
	WriteData      => (others                 => '0'),
	AckOperation   => '0');

	constant cDefaultSdControllerToSdWbSlave : aSdControllerToSdWbSlave := (
	ReqOperation => '0',
	ReadData     => (others => '0'));

	-- to fifo

	type aoWriteFifo is record

		data : aData;
		wrreq : std_ulogic; -- write request

	end record aoWriteFifo;

	constant cDefaultoWriteFifo : aoWriteFifo := (
	data  => (others => '0'),
	wrreq => '0');

	type aiWriteFifo is record

		wrfull : std_ulogic; -- write full

	end record aiWriteFifo;
	
	type aoReadFifo is record
		rdreq : std_ulogic; -- read request
	end record aoReadFifo;

	constant cDefaultoReadFifo : aoReadFifo := (rdreq => '0');

	type aiReadFifo is record
		q       : std_ulogic_vector(31 downto 0); -- read data (1 cycle after rdreq)
		rdempty : std_ulogic; -- no data available
	end record aiReadFifo;

end package SdWb;

