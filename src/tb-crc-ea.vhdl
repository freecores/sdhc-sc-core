-------------------------------------------------
-- tb-crc-ea.vhdl
-- author: Rainer Kastl
--
-- Testbench for the generic crc implementation
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.pcrc.all;

entity tb_crc is
end entity tb_crc;

architecture bhv of tb_crc is
    signal Clk, nResetAsync : std_ulogic := '0';
    signal CRC_7 : std_ulogic_vector(6 downto 0);
    signal CRC_16 : std_ulogic_vector(15 downto 0);
    signal DataToCrc_7, DataToCrc_16 : std_ulogic;
    signal CRCDataIn_7,CRCClear_7 : std_ulogic;
    signal CRCDataIn_16,CRCClear_16 : std_ulogic;
    signal SerialCRC_7, SerialCRC_16 : std_ulogic;

    signal EndOfSim : boolean := false;

    -- setup data in front of clk -> use the negative clock edge
    procedure Test (
        Data : in std_ulogic_vector;
        Valid : in std_ulogic_vector;
        signal CRC : in std_ulogic_vector;
        signal SerialCRC : in std_ulogic;
        signal CRCDataIn : out std_ulogic;
        signal DataToCrc : out std_ulogic;
        signal CRCClear : out std_ulogic) is

        variable counter : natural := 0;

    begin
        wait until Clk = '0';
        CRCClear <= '0';
        CRCDataIn <= '1';

        while (counter <= Data'high) loop
            DataToCrc <= Data(counter);
            counter := counter + 1;
            wait until Clk = '0';
        end loop;

        DataToCrc <= '0';
        CRCDataIn <= '0';

        assert (Valid = CRC) report "CRC error." severity error;

        counter := 0;
        while (counter <= CRC'high) loop
            assert (Valid(counter) = SerialCRC) report "Serial CRC error"
            severity error;
            counter := counter + 1;
            wait until clk = '0';
        end loop;

        CRCClear <= '1';
        wait until Clk = '0';

        CRCClear <= '0';
    end procedure;

begin

    Clk <= not Clk after 10 ns when EndOfSim = false else '0';
    nResetAsync <= '1' after 100 ns;

    generate_and_test7 : process is
        procedure Test7(
            Data : in std_ulogic_vector;
            Valid : in std_ulogic_vector) is
        begin
            Test(Data, Valid, CRC_7, SerialCRC_7, CRCDataIn_7, DataToCrc_7,
                CRCClear_7);
        end procedure;

        procedure Test16(
            Data : in std_ulogic_vector;
            Valid : in std_ulogic_vector) is
        begin
            Test(Data, Valid, CRC_16, SerialCRC_16, CRCDataIn_16, DataToCrc_16,
                CRCClear_16);
        end procedure;

        variable data : std_ulogic_vector(0 to (512*8)-1) := (others => '1');
        variable DataWithCRC : std_ulogic_vector(0 to (516*8)-1) := (
            512*8 to 516*8-1 => std_ulogic_vector(X"7FA1"),
            others => '1');
    begin
        wait until (nResetAsync = '1');

        Test7("0100000000000000000000000000000000000000","1001010");
        Test7("01000000000000000000000000000000000000001001010","0000000");
        Test7("0101000100000000000000000000000000000000","0101010");
        Test7("01010001000000000000000000000000000000000101010","0000000");
        Test7("0001000100000000000000000000100100000000","0110011");
        Test7("00010001000000000000000000001001000000000110011","0000000");
        Test16(data, X"7FA1");

        EndOfSim <= true;
        report "Simulation finished." severity note;
    end process;

    duv7: entity work.crc
    port map (iClk => Clk,
        inResetAsync => nResetAsync,
        iDataIn => CRCDataIn_7,
        iClear => CRCClear_7,
        iData => DataToCrc_7,
        oParallel => CRC_7,
        oSerial => SerialCRC_7);

    duv16: entity work.crc
    generic map (gPolynom => crc16)
    port map (iClk => Clk,
        inResetAsync => nResetAsync,
        iDataIn => CRCDataIn_16,
        iClear => CRCClear_16,
        iData => DataToCrc_16,
        oParallel => CRC_16,
        oSerial => SerialCRC_16);

end architecture bhv;