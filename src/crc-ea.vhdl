-------------------------------------------------
-- CRC7
-- author: Rainer Kastl
--
-- CRC implementation with the common polynomial
-- x^7 + x^3 + 1
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.pcrc.all;

entity crc is
    generic (
        gPolynom : std_ulogic_vector := crc7 -- x^7 + x^3 + 1
    );
    port (
        iClk : in std_ulogic;
        inResetAsync : in std_ulogic;
        iEn : in std_ulogic;
        iClear : in std_ulogic;
        iData : in std_ulogic;
        oCRC : out std_ulogic_vector(gPolynom'high - 1 downto gPolynom'low)
    );
end crc;

architecture rtl of crc is

    signal regs : std_ulogic_vector(oCRC'range);

begin

    crc : process (iClk, inResetAsync) is
        variable input : std_ulogic;
    begin
        if (inResetAsync = '0') then
            regs <= (others => '0');
        elsif (rising_edge(iClk)) then
            if (iEn = '1') then
                if (iClear = '0') then
                    input := iData xor regs(regs'high);

                    regs(0) <= input;

                    for idx in 1 to regs'high loop
                        if (gPolynom(idx) = '1') then
                            regs(idx) <= regs(idx-1) xor input;
                        else
                            regs(idx) <= regs(idx-1);
                        end if;
                    end loop;
                else
                    regs <= (others => '0');
                end if;
            end if;
        end if;
    end process crc;

    oCRC <= regs;

end architecture rtl;