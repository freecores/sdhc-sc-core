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

	constant cSdStartBit : std_ulogic := '0';
	constant cSdEndBit : std_ulogic := '1';
	constant cSdTransBitHost : std_ulogic := '1';
	constant cSdTransBitSlave : std_ulogic := '0';

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
	cSdCmdIdHigh)); -- [31:12] reserved, [11:8] supply voltage, [7:0] check
					-- pattern

	constant cSdCmdSendCSD : aSdCmdId := std_ulogic_vector(to_unsigned(9,
	cSdCmdIdHigh)); -- [31:16] RCA

	constant cSdCmdSendCID : aSdCmdId := std_ulogic_vector(to_unsigned(10,
	cSdCmdIdHigh)); -- [31:16] RCA

	constant cSdCmdStopTrans : aSdCmdId := std_ulogic_vector(to_unsigned(12,
	cSdCmdIdHigh)); -- no args

	constant cSdCmdSendStatus : aSdCmdId := std_ulogic_vector(to_unsigned(13,
	cSdCmdIdHigh)); -- [31:16] RCA

end package Sd;
