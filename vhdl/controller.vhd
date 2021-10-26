library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        -- instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        -- activates branch condition
        branch_op  : out std_logic;
        -- immediate value sign extention
        imm_signed : out std_logic;
        -- instruction register enable
        ir_en      : out std_logic;
        -- PC control signals
        pc_add_imm : out std_logic;
        pc_en      : out std_logic;
        pc_sel_a   : out std_logic;
        pc_sel_imm : out std_logic;
        -- register file enable
        rf_wren    : out std_logic;
        -- multiplexers selections
        sel_addr   : out std_logic;
        sel_b      : out std_logic;
        sel_mem    : out std_logic;
        sel_pc     : out std_logic;
        sel_ra     : out std_logic;
        sel_rC     : out std_logic;
        -- write memory output
        read       : out std_logic;
        write      : out std_logic;
        -- alu op
        op_alu     : out std_logic_vector(5 downto 0)
    );
end controller;

architecture synth of controller is

    type stateType is (FETCH1, FETCH2, DECODE, I_OP, R_OP, LOAD1, LOAD2, STORE, BREAK);
    signal s_cur_state, s_next_state: stateType;

begin

	 --FETCH 1
    --read <= '1' when s_cur_state == FETCH1 else '0';

    --FETCH 2
    pc_en <= '1' when (s_cur_state = FETCH2) else '0';
    ir_en <= '1' when (s_cur_state = FETCH2) else '0';
	 
    controller : process( clk, reset_n )
    begin
      if( reset_n = '0' ) then
        read <= '1';
      elsif( rising_edge(clk) ) then
        s_cur_state <= s_next_state;
         case( s_cur_state ) is
            when FETCH1 => read <= '1';
            when I_OP => -- I_OP
                sel_b <= '0'; --Take immediate value
                sel_rC <= '1'; --B is destination write address (aw)
                rf_wren <= '1';

                case( op ) is
                    when x"04" => --addi rB, rA, imm => rB = rA + (signed)imm
                        --op_alu <= "000---" --addition
                        imm_signed <= '1';
                    when others =>
                        rf_wren <= '0';
                        imm_signed <= '0';
                end case ;
            when R_OP => --R_OP
                sel_b <= '1'; --Take register value
                sel_rC <= '0'; --C is destination write address (aw)
                rf_wren <= '1';

                case( opx ) is
                    when x"0E" => --and rC, rA, rB R OP R-type 0x3A 0x0E rC ← rA AND rB
                        --op_alu <= "10--01";
                        imm_signed <= '0';
                    when x"1B" => --srl rC, rA, rB R OP R-type 0x3A 0x1B rC ← (unsigned)rA  rB4..0
                        --op_alu <= "11-011";
                        imm_signed <= '0';
                    when others =>
                end case ;

            when LOAD1 => --LOAD1
                    sel_addr <= '1'; --Select memory address from ALU result
                    read <= '1';
                    --op_alu <= "000---";
                    imm_signed <= '1';
                    sel_b <= '0';


            when LOAD2 => --LOAD2
                    read <= '0';
                    sel_mem <= '1'; --write the data from the memory (with address A + (signed)imm)
            
            when STORE => --STORE
                    sel_addr <= '1';
                    write <= '1';
                    --op_alu <= "000---";
                    imm_signed <= '1';
                    sel_b <= '0';

            when BREAK => --BREAK, do nothing
                    case( opx ) is
                        when x"34" => --Stop program execution    
                        when others =>
                    end case ;
            when others =>
                    rf_wren <= '0';
         end case ;

      end if ;
    end process ; -- controller
    
    --stateless
    --op_alu <= op + opx --This is placeholder (obviously wrong)

    transition : process( s_cur_state, op, opx )
    begin
        case( s_cur_state ) is
            when FETCH1 =>
                s_next_state <= FETCH2;
            when FETCH2 =>
                s_next_state <= DECODE;
            when DECODE =>
                case( op ) is
                    when x"3A" => 
                        if (opx = x"34") then s_next_state <= BREAK; --BREAK
                            else s_next_state <= R_OP; --R_OP
                        end if;
                    
                    when x"04" => s_next_state <= I_OP; --I_OP

                    when x"17" => s_next_state <= LOAD1; --LOAD

                    when x"15" => s_next_state <= STORE; --STORE

                    when others => s_next_state <= BREAK;
                end case ;
            when I_OP =>
                s_next_state <= FETCH1;
            when R_OP =>
                s_next_state <= FETCH1;
            when LOAD1 =>
                s_next_state <= LOAD2;
            when LOAD2 =>
                s_next_state <= FETCH1;
            when STORE =>
                s_next_state <= FETCH1;
            when BREAK =>
                s_next_state <= BREAK;
            when others =>
                s_next_state <= BREAK;
        end case ;
    end process ; -- transition
end synth;
