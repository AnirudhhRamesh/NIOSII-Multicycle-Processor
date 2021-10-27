library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);
        rddata  : out std_logic_vector(31 downto 0));
end RAM;

architecture synth of RAM is
    type reg_type is array(0 to 1023) of std_logic_vector(31 downto 0);
    signal reg: reg_type;
    signal s_cs : std_logic;
    signal s_read: std_logic;
    signal s_address: std_logic_vector(9 downto 0);
begin

    clock: process(clk)
    begin
        if(rising_edge(clk)) then
            s_cs <= cs;
            s_read <= read;
            if cs = '1' then
                if write = '1' then 
                    reg(to_integer(unsigned(address))) <= wrdata;
                end if; 
                if read = '1' then 
                    s_address <= address;
                end if;
            end if;
        end if;
    end process;

    rddata <= reg(to_integer(unsigned(s_address))) when (s_cs = '1' and s_read = '1') else (others => 'Z');

end synth;
