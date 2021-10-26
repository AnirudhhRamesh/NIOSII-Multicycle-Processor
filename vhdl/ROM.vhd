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

	signal s_read : std_logic;
	
	signal s_dff1_current, s_dff1_next : std_logic_vector(9 downto 0);
	signal s_dff2_current, s_dff2_next: std_logic;
	
	signal s_rddata : std_logic_vector(31 downto 0);
	
	--ROM-Block component
	component ROM_Block
		PORT(
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0));
	end component;
		
begin

	--ROM_Block port mapping
	memory_Block: ROM_Block port map (
		address => address,
		clock => clk,
		q => s_rddata);

	s_dff1_next <= address;
	
	--D-Flip Flop 1
	dff_1 : process(clk)
	begin
		if (rising_edge(clk)) then
			s_dff1_current <= s_dff1_next;
		end if;
	end process;	
	
	
	-- Read & cs -> 
	s_dff2_next <= read and cs;
	
	--D-Flip Flop 2
	dff_2 : process(clk)
	begin
		if (rising_edge(clk)) then
			s_dff2_current <= s_dff2_next;
		end if;
	end process;
		
	--Tri-state buffer
	rddata <= s_rddata when (s_dff2_current <= '1') else (others => 'Z');

end synth;
