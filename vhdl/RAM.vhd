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
    signal reg : reg_type;
    signal address_prev : unsigned(9 downto 0) := "0000000000";
    signal cs_and_read : std_logic; 
begin

    rddata <= (others => 'Z') when cs_and_read = '0' else reg(to_integer(unsigned(address_prev)));

    rd: process (clk)
    begin
        if(rising_edge(clk)) then
            cs_and_read <= cs and read;
            
            if(cs = '1') then
                if(read = '1') then
                    address_prev <= unsigned(address);
                end if;
                if(write = '1') then
                    reg(to_integer(unsigned(address))) <= wrdata;
                end if;
            end if;
        end if;
    end process rd;
end synth;
