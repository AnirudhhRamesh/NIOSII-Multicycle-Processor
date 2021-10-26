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

    --FETCH 1
    read <= '1' when s_cur_state == FETCH1 else '0';

    --FETCH 2
    pc_en <= '1' when s_cur_state == FETCH2 else '0';
    ir_en <= '1' when s_cur_state == FETCH2 else '0';
    

begin
    controller : process( clk, reset_n )
    begin
      if( reset_n = '0' ) then
        read <= '1';
      elsif( rising_edge(clk) ) then
        s_cur_state <= s_next_state;

        --FETCH1        
        if s_cur_state == FETCH1 then
        if s_cur_state == FETCH2 then

        --Decode the OP Code
        if s_cur_state == DECODE then

        --Decode the OPX code


      end if ;
    end process ; -- controller
    
    --stateless
    op_alu <= op + opx --This is placeholder (obviously wrong)

    transition : process( s_cur_state )
    begin
        case( s_cur_state ) is
            when FETCH1 =>
                s_next_state <= FETCH2;
            when FETCH2 =>
                s_next_state <= DECODE;
            when DECODE =>
                if () then s_next_state <=
            when I_OP =>
                s_next_state <= FETCH1;
            when R_OP =>
                s_next_state <= FETCH1;
            when LOAD1 =>
                s_next_state <= IDLE;
            when LOAD2 =>
                s_next_state <= FETCH1;
            when STORE =>
                s_next_state <= FETCH1;

            when BREAK =>
                s_next_state <= BREAK;
            when others =>
                s_next_state <= FETCH1;
        end case ;
    end process ; -- transition
end synth;
