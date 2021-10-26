library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is
    port(
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        sub_mode : in  std_logic;
        carry    : out std_logic;
        zero     : out std_logic;
        r        : out std_logic_vector(31 downto 0)
    );
end add_sub;

architecture synth of add_sub is
	signal mask: std_logic_vector(31 downto 0) := (others => '0');
	signal inverse_mask : std_logic_vector(31 downto 0) := (others => '1');
	signal b_sig: std_logic_vector(31 downto 0);
	
	signal sub: unsigned(32 downto 0);
	signal add: unsigned(32 downto 0);

begin
	mask <= "00000000000000000000000000000000" when sub_mode = '0' else "11111111111111111111111111111111";
	b_sig <= b xor mask;
	
	sub <= to_unsigned(0,33) when sub_mode = '0' else to_unsigned(1,33);
	add <= unsigned("0" & a) + unsigned("0" & b_sig) + sub;
	carry <= add(32);

	r <= std_logic_vector(add(31 downto 0));
	zero <= '1' when add(31 downto 0) = to_unsigned(0,32) else '0';

end synth;
