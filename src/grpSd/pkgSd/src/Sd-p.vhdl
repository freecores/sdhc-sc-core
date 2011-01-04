-------------------------------------------------
-- file: Sd-p.vhdl
-- author: Rainer Kastl
--
-- Contains definitions for SD cards and controllers
-- according to Simplified Physical Layer Spec 2.0
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Sd is

	-- CMD transfer: constants
	constant cSdStartBit : std_ulogic := '0';
	constant cSdEndBit : std_ulogic := '1';
	constant cSdTransBitHost : std_ulogic := '1';
	constant cSdTransBitSlave : std_ulogic := '0';

	-- CMD transfer: types
	constant cSdCmdIdHigh : natural := 6;
	subtype aSdCmdId is std_ulogic_vector(cSdCmdIdHigh-1 downto 0);
	subtype aSdCmdArg is std_ulogic_vector(31 downto 0);

	type aSdCmdContent is record
		id : aSdCmdId;
		arg : aSdCmdArg;
	end record aSdCmdContent;

	type aSdCmdToken is record
		startbit : std_ulogic; -- cSdStartBit
		transbit : std_ulogic;
		content : aSdCmdContent;		
		crc7 : std_ulogic_vector(6 downto 0); -- CRC of content
		endbit : std_ulogic; --cSdEndBit
	end record aSdCmdToken;

	-- Types for entities
	type aSdCmdFromController is record
		Content : aSdCmdContent;
		Valid : std_ulogic;
	end record aSdCmdFromController;

	type aSdCmdToController is record
		Ack : std_ulogic; -- Gets asserted when crc was sent, but endbit was
		-- not. This way we can minimize the wait time between sending 2 cmds.
		Receiving : std_ulogic;
		Content : aSdCmdContent;
		Valid : std_ulogic; -- gets asserted when CmdContent is valid (therefore
		-- a cmd was received)
		Err : std_ulogic; -- gets asserted when an error occurred during
		-- receiving a cmd
	end record aSdCmdToController;

	-- constants for Controller
	subtype aRCA is std_ulogic_vector(15 downto 0);
	constant cSdDefaultRCA : aRCA := (others => '0');

	-- command ids
	-- abbreviations:
	-- RCA: relative card address

	constant cSdCmdGoIdleState : aSdCmdId := std_ulogic_vector(to_unsigned(0,
	cSdCmdIdHigh)); -- no args

	constant cSdCmdAllSendCID : aSdCmdId := std_ulogic_vector(to_unsigned(2,
	cSdCmdIdHigh)); -- no args

	constant cSdCmdSendRelAdr : aSdCmdId := std_ulogic_vector(to_unsigned(3,
	cSdCmdIdHigh)); -- no args

	constant cSdCmdSetDSR : aSdCmdId := std_ulogic_vector(to_unsigned(4,
	cSdCmdIdHigh)); -- [31:16] DSR

	constant cSdCmdSelCard : aSdCmdId := std_ulogic_vector(to_unsigned(7,
	cSdCmdIdHigh)); -- [31:16] RCA

	constant cSdCmdDeselCard : aSdCmdId := cSdCmdSelCard; -- [31:16] RCA

	constant cSdCmdSendIfCond : aSdCmdId := std_ulogic_vector(to_unsigned(8,
	cSdCmdIdHigh));

	constant cSdDefaultVoltage : std_ulogic_vector(3 downto 0) := "0001"; -- 2.7
	-- - 3.6 V
	constant cCheckpattern : std_ulogic_vector(7 downto 0) := "10101010";
	-- recommended

	constant cSdArgVoltage : aSdCmdArg := 
		"00000000000000000000" & -- reserved 
		cSdDefaultVoltage & -- supply voltage
		cCheckPattern;

	constant cSdCmdSendCSD : aSdCmdId := std_ulogic_vector(to_unsigned(9,
	cSdCmdIdHigh)); -- [31:16] RCA

	constant cSdCmdSendCID : aSdCmdId := std_ulogic_vector(to_unsigned(10,
	cSdCmdIdHigh)); -- [31:16] RCA

	constant cSdCmdStopTrans : aSdCmdId := std_ulogic_vector(to_unsigned(12,
	cSdCmdIdHigh)); -- no args

	constant cSdCmdSendStatus : aSdCmdId := std_ulogic_vector(to_unsigned(13,
	cSdCmdIdHigh)); -- [31:16] RCA

	constant cSdNextIsACMD : aSdCmdId := std_ulogic_vector(to_unsigned(55,
	cSdCmdIdHigh));
	constant cSdACMDArg : aSdCmdArg := cSdDefaultRCA & X"0000"; -- [31:16] RCA
	constant cSdArgAppCmdPos : natural := 5;

	constant cSdCmdACMD41 : aSdCmdId := std_ulogic_vector(to_unsigned(41, cSdCmdIdHigh));

	subtype aVoltageWindow is std_ulogic_vector(23 downto 15);
	constant cVoltageWindow : aVoltageWindow := (others => '1');
	constant cSdR3Id : aSdCmdId := (others => '1');

	type aSdRegOCR is record
		voltagewindow : aVoltageWindow;
		ccs : std_ulogic;
		nBusy : std_ulogic;
	end record aSdRegOCR;

	function OCRToArg (ocr : in aSdRegOCR) return aSdCmdArg;
	function ArgToOcr (arg : in aSdCmdArg) return aSdRegOCR;

end package Sd;

package body Sd is

	function OCRToArg (ocr : in aSdRegOCR) return aSdCmdArg is
		variable temp : aSdCmdArg;
	begin
		temp := ocr.nBusy & ocr.ccs & "000000" & ocr.voltagewindow &
		"000000000000000";
		return temp;
	end function OCRtoArg;

	function ArgToOcr (arg : in aSdCmdArg) return aSdRegOCR is
		variable ocr : aSdRegOCR;
	begin
		ocr.nBusy := arg(31);
		ocr.ccs := arg(30);
		ocr.voltagewindow := arg(23 downto 15);
		return ocr;
	end function ArgToOcr;

end package body Sd;

