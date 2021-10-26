library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity PC is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        en      : in  std_logic;
        sel_a   : in  std_logic;
        sel_imm : in  std_logic;
        add_imm : in  std_logic;
        imm     : in  std_logic_vector(15 downto 0);
        a       : in  std_logic_vector(15 downto 0);
        addr    : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is

	 signal address : std_logic_vector(15 downto 0);
	 
begin
    
    addr <= X"0000" & address; --sets 0s to address 31..16
    
    PC : process( clk, reset_n )
    begin
      if( reset_n = '0' ) then
        --Address of next instruction and signal read are set to start a new read process
        --Instruction word is available during the next cycle

        --reset_n initializes the address register to 0
        address <= std_logic_vector(to_unsigned(0,16));
      elsif( rising_edge(clk) ) then
        if (en = '1') then
          if (add_imm = '1') then
            address <= address + imm; 
          elsif (sel_a = '1') then
            address <= a;
          else
            address <= address + std_logic_vector(to_unsigned(4,16));    
          end if;
        end if;
      end if ;
    end process ; -- PC

    addr <= X"0000" & address when sel_imm = '0' else "0000000000000000" & std_logic_vector(shift_left(signed(imm), 2)); --sets 0s to address 31..16

end synth;
