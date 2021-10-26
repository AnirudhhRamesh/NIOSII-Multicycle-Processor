library ieee;
use ieee.std_logic_1164.all;

entity decoder is
    port(
        address : in  std_logic_vector(15 downto 0);
        cs_LEDS : out std_logic;
        cs_RAM  : out std_logic;
        cs_ROM  : out std_logic;
        cs_buttons : out std_logic
    );
end decoder;

architecture synth of decoder is
begin
    comb_proc1: process(address)
    begin
        if address >= x"0000" and address <= x"0FFC" then
            cs_buttons <= '0';
            cs_ROM <= '1';
            cs_RAM <= '0';
            cs_LEDS <= '0';
        elsif address >= x"1000" and address <= x"1FFC" then
            cs_buttons <= '0';
            cs_ROM <= '0';
            cs_RAM <= '1';
            cs_LEDS <= '0';
        elsif address >= x"2000" and address <= x"200C" then
            cs_buttons <= '0';
            cs_ROM <= '0';
            cs_RAM <= '0';
            cs_LEDS <= '1';
        elsif address >= x"2030" and address <= x"2034" then
            cs_buttons <= '1';
            cs_ROM <= '0';
            cs_RAM <= '0';
            cs_LEDS <= '0';
        else
            cs_buttons <= '0';
            cs_ROM <= '0';
            cs_RAM <= '0';
            cs_LEDS <= '0';
        end if;
        end process;
end synth;
