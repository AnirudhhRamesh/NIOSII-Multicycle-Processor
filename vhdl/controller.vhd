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

    signal opcode, opxcode : std_logic_vector(7 downto 0);

begin

    branch_op <= '0';
    pc_add_imm <= '0';
    pc_sel_a <= '0';
    pc_sel_imm <= '0';
    sel_pc <= '0';
    sel_ra <= '0';

    opcode <= "00" & op; --Append to MSB or LSB?
    opxcode <= "00" & opx; --Append to MSB or LSB?

    --pc_en: Enables PC
    pc_en <= '1' when (s_cur_state = FETCH2) else '0';

    --ir_en: Enables Instruction Register (IR)
    ir_en <= '1' when (s_cur_state = FETCH2) else '0';

    --rf_wren: Register file enable
    rf_wren <= '1' when (s_cur_state = I_OP) else 
               '1' when (s_cur_state = R_OP) else 
               '1' when (s_cur_state = LOAD2) else '0';

    --sel_addr: 
    sel_addr <= '1' when (s_cur_state = LOAD1) else 
                '1' when (s_cur_state = STORE) else '0';

    --sel_b: Imm value if I_OP, else B register if R_OP
    sel_b <= '0' when (s_cur_state = I_OP) else 
             '1' when (s_cur_state = R_OP) else
             '1' when (s_cur_state = BREAK) else
             '0' when (s_cur_state = STORE) else '0';

    --sel_mem
    sel_mem <= '1' when (s_cur_state = LOAD2) else '0';

    --sel_rC: Selects write address (aw). Either B if I_OP, else C if R_OP
    sel_rC <= '0' when (s_cur_state = I_OP) else
              '1' when (s_cur_state = R_OP) else '0';

    --read
    read <= '1' when (s_cur_state = FETCH1) else 
            '1' when (s_cur_state = LOAD1) else '0';

    --write
    write <= '1' when (s_cur_state = STORE) else '0';
    
    --Other things
    --imm_signed
    --op_alu

    --I-Type Operations
    switches : process( opcode, opxcode )
    begin
        case opcode is
            when x"04" => op_alu <= "000---"; imm_signed <= '1'; --addi rB, rA, imm => rB = rA + (signed)imm
            when others =>
        end case;
    
        --R-Type Operations
        case opxcode is
            when x"0E" => op_alu <= "10--01"; imm_signed <= '0'; --and rC, rA, rB R OP R-type 0x3A 0x0E rC ← rA AND rB
            when x"1B" => op_alu <= "11-011"; imm_signed <= '0'; --srl rC, rA, rB R OP R-type 0x3A 0x1B rC ← (unsigned)rA  rB4..0
            when x"34" => --BREAK
            when others =>
        end case;
    end process ; -- switches
    
    controller : process( clk, reset_n )
    begin
      if( reset_n = '0' ) then
        s_cur_state <= FETCH1;
      elsif( rising_edge(clk) ) then
        s_cur_state <= s_next_state;
      end if ;
    end process ; -- controller

    transition : process( s_cur_state, opcode, opxcode )
    begin
        case( s_cur_state ) is
            when FETCH1 =>
                s_next_state <= FETCH2;
            when FETCH2 =>
                s_next_state <= DECODE;
            when DECODE =>
                case( opcode ) is
                    when x"3A" => 
                        if (opxcode = x"34") then s_next_state <= BREAK; --BREAK
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
