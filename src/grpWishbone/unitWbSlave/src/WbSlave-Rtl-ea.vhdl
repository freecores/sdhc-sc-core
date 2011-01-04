-------------------------------------------------
-- file: WbSlave-Rtl-ea.vhdl
-- author: Rainer Kastl
--
-- Generic implementation of a wishbone slave.
-- Wishbone specification revision B.3
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.wishbone.all;

entity WbSlave is
	generic (
		gPortSize: natural := 8; -- in bits, only 8, 16, 32 and 64 are valid
		gPortGranularity : natural := 8; --in bits, only 8, 16, 32 and 64 are valid
		gMaximumOperandSize : natural := 8;  -- in bits, only 8, 16, 32 and 64 are valid
		gEndian : endianness := big -- if the port size equals the granularity
									-- this setting does not make a difference
	);
	port (
	-- Control
	iClk : std_ulogic; -- Clock, rising clock edge
	iRst : std_ulogic; -- Reset, active high

	oAck : std_ulogic; -- Indicates the end of a normal bus cycle
	oErr : std_ulogic; -- Indicates an error
	oRty : std_ulogic; -- Indicates that the request should be retried
	iCyc : std_ulogic; -- Indicates a bus cycle
	iLock : std_ulogic; -- Indicates that the current cycle is not interruptable
	iSel : std_ulogic_vector(gPortSize/gPortGranularity - 1 downto 0); -- TODO:
																	   -- Check this
	iStb : std_ulogic; -- Indicates the selection of the slave
	iWe : std_ulogic; -- Write enable, indicates whether the cycle is a read or
					  -- write cycle

	-- Data 
	iAdr : std_ulogic_vector(gPortSize-1 downto log2(gPortGranularity) - 1);
	iDat : std_ulogic_vector(gPortSize-1 downto 0); -- Data input
	oDat : std_ulogic_vector(gPortSize-1 downto 0); -- Data output

-- Tags are currently not supported

begin

	assert (gPortSize = 8 or gPortSize = 16 or gPortSize = 32 or gPortSize =
	64) report "gPortSize is invalid." severity failure;

	assert (gPortGranularity = 8 or gPortGranularity = 16 or
	gPortGranularity = 32 or gPortGranularity = 64) report "gPortGranularity
	is invalid." severity failure;

	assert (gMaximumOperandSize = 8 or gMaximumOperandSize = 16 or
	gMaximumOperandSize = 32 or gMaximumOperandSize = 64) report
	"gMaximumOperandSize is invalid." severity failure;

end entity;




