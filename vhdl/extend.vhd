library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity extend is
    port(
        imm16  : in  std_logic_vector(15 downto 0);
        signed : in  std_logic;
        imm32  : out std_logic_vector(31 downto 0)
    );
end extend;

architecture synth of extend is
begin
    with signed select imm32 <=
    x"0000" & imm16 when '0',
    x"FFFF" & imm16 when '1',
    (others=> '0') when others;
end synth;
