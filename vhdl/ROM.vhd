library ieee;
use ieee.std_logic_1164.all;

entity ROM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        rddata  : out std_logic_vector(31 downto 0)
    );
end ROM;

architecture synth of ROM is

    component ROM_Block is
        port(
            address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
            clock		: IN STD_LOGIC  := '1';
            q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    end component;

Signal q : STD_LOGIC_VECTOR (31 DOWNTO 0);
signal number_cycles : std_logic := '0';
signal cs_and_read : std_logic;
signal prev_address : STD_LOGIC_VECTOR (9 DOWNTO 0);

begin
    ROM_Block_0: ROM_Block port map(
        clock  => clk,
        address  => address,
        q => q
    );

    rddata <= (others => 'Z') when cs_and_read = '0' else q;

    rd: process (clk)
    begin
        if(rising_edge(clk)) then
            cs_and_read <= cs and read;
        end if;
    end process rd;
end synth;
