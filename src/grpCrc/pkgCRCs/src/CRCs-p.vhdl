library ieee;
use ieee.std_logic_1164.all;

package CRCs is

    constant crc7 : std_ulogic_vector(7 downto 0) := B"1000_1001";
    constant crc16 : std_ulogic_vector(16 downto 0) := (16 => '1', 12 => '1',
        5 => '1', 0 => '1', others => '0');

end package CRCs;
