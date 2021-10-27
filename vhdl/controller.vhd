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

    type stateType is (FETCH1, FETCH2, DECODE, I_OP, R_OP, LOAD1, LOAD2, STORE, BREAK, BRANCH, CALL, CALLR, JMP, JMPI, IMM, SHIFT);
    signal s_cur_state, s_next_state: stateType;

    signal opcode, opxcode : std_logic_vector(7 downto 0);
    signal s_op_alu : std_logic_vector (2 downto 0);

begin

    opcode <= "00" & op;
    opxcode <= "00" & opx;

    --pc_en: Enables PC
    pc_en <= '1' when (s_cur_state = FETCH2) else 
             '1' when (s_cur_state = CALL) else 
             '1' when (s_cur_state = CALLR) else 
             '1' when (s_cur_state = JMP) else 
             '1' when (s_cur_state = JMPI) else '0';

    --ir_en: Enables Instruction Register (IR)
    ir_en <= '1' when (s_cur_state = FETCH2) else '0';

    --rf_wren: Register file enable
    rf_wren <= '1' when (s_cur_state = I_OP) else 
               '1' when (s_cur_state = R_OP) else 
               '1' when (s_cur_state = LOAD2) else 
               '1' when (s_cur_state = CALL) else 
               '1' when (s_cur_state = CALLR) else 
               '1' when (s_cur_state = SHIFT) else '0';

    --sel_addr: 
    sel_addr <= '1' when (s_cur_state = LOAD1) else 
                '1' when (s_cur_state = STORE) else '0';

    --sel_b: Imm value if I_OP, else B register if R_OP
    sel_b <= '0' when (s_cur_state = I_OP) else 
             '1' when (s_cur_state = R_OP) else
             '1' when (s_cur_state = BREAK) else
             '1' when (s_cur_state = BRANCH) else
             '0' when (s_cur_state = STORE) else 
             '0' when (s_cur_state = SHIFT) else '0';

    --sel_mem
    sel_mem <= '1' when (s_cur_state = LOAD2) else '0';

    --sel_rC: Selects write address (aw). Either B if I_OP, else C if R_OP
    sel_rC <= '0' when (s_cur_state = I_OP) else
              '1' when (s_cur_state = R_OP) else 
              '1' when (s_cur_state = BREAK) else 
              '1' when (s_cur_state = SHIFT) else '0';

    --read
    read <= '1' when (s_cur_state = FETCH1) else 
            '1' when (s_cur_state = LOAD1) else '0';

    --write
    write <= '1' when (s_cur_state = STORE) else '0';
    
    --branch_op
    branch_op <= '1' when (s_cur_state = BRANCH) else '0';

    --pc_sel_imm: Selects immediate field as next value of PC
    pc_sel_imm <= '1' when (s_cur_state = CALL) else 
                  '1' when (s_cur_state = JMPI) else '0';

    --pc_sel_a:
    pc_sel_a <= '1' when (s_cur_state = CALLR) else 
                '1' when (s_cur_state = JMP) else '0';

    --pc_add_imm
    pc_add_imm <= '1' when (s_cur_state = BRANCH) else '0';

    --sel_pc
    sel_pc <= '1' when (s_cur_state = CALL) else 
              '1' when (s_cur_state = CALLR) else '0';

    --sel_ra
    sel_ra <= '1' when (s_cur_state = CALL) else 
              '1' when (s_cur_state = CALLR) else '0';

    --Other things
    --imm_signed
    --op_alu

    --I-Type Operations
    switches : process( opcode, opxcode )
    begin
        case opcode is
            --I_OP Operations
            when x"04" => s_op_alu <= "000"; imm_signed <= '1'; --I_OP: addi rB, rA, imm => rB = rA + (signed)imm

            when x"0C" => s_op_alu <= "100"; imm_signed <= '0';
            when x"14" => s_op_alu <= "100"; imm_signed <= '0';
            when x"1C" => s_op_alu <= "100"; imm_signed <= '0';

            when x"08" => s_op_alu <= "011"; imm_signed <= '1'; 
            when x"10" => s_op_alu <= "011"; imm_signed <= '1';
            when x"18" => s_op_alu <= "011"; imm_signed <= '1';
            when x"20" => s_op_alu <= "011"; imm_signed <= '1';

            when x"28" => s_op_alu <= "011"; imm_signed <= '0';  --TODO: Error here: 011000 instead of 011001
            when x"30" => s_op_alu <= "011"; imm_signed <= '0';

            --BRANCH Operations
            when x"06" => s_op_alu <= "011"; --BRANCH: br jumps to label if: no condition (check that rA = rB since A and B = x00)
            when x"0E" => s_op_alu <= "011"; --BRANCH: ble jumps to label if: rA <= rB
            when x"16" => s_op_alu <= "011"; --BRANCH: bgt jumps to label if: rA > rB
            when x"1E" => s_op_alu <= "011"; --BRANCH: bne jumps to label if: rA != rB
            when x"26" => s_op_alu <= "011"; --BRANCH: beq jumps to label if: rA = rB
            when x"2E" => s_op_alu <= "011"; --BRANCH: bleu jumps to label if: (unsigned) rA <= (unsigned) rB
            when x"36" => s_op_alu <= "011"; --BRANCH: bgtu jumps to label if: (unsigned) rA > (unsigned) rB

            --CALL Operations
            when x"00" => --CALL: call

            --JMPI Operations
            when x"01" => --JMPI: jmpi

            when others =>
        end case;
    
        --R-Type Operations
        case opxcode is
            --R_OP Operations
            when x"31" => s_op_alu <= "000";
            when x"39" => s_op_alu <= "001";
            when x"08" => s_op_alu <= "011"; --TODO: Error here: 011000 instead of 011001
            when x"10" => s_op_alu <= "011";
            when x"06" => s_op_alu <= "100";
            when x"0E" => s_op_alu <= "100";
            when x"16" => s_op_alu <= "100";
            when x"1E" => s_op_alu <= "100";
            when x"13" => s_op_alu <= "110";
            when x"1B" => s_op_alu <= "110"; imm_signed <= '0';
            when x"3B" => s_op_alu <= "110"; imm_signed <= '1';

            when x"18" => s_op_alu <= "011";
            when x"20" => s_op_alu <= "011";
            when x"28" => s_op_alu <= "011"; imm_signed <= '0';
            when x"30" => s_op_alu <= "011"; imm_signed <= '0';
            when x"03" => s_op_alu <= "110";
            when x"0B" => s_op_alu <= "110";

            --SHIFT Operations
            when x"12" => s_op_alu <= "110";
            when x"1A" => s_op_alu <= "110"; imm_signed <= '0';
            when x"3A" => s_op_alu <= "110"; imm_signed <= '1';

            when x"02" => s_op_alu <= "110";

            --CALLR Operations
            when x"1D" => --CALLR: callr

            --JMP Operations
            when x"0D" => --JMP: jmp
            when x"05" => --JMP: ret

            --BREAK Operation
            when x"34" => --BREAK

            when others =>
        end case;
    end process ; -- switches

    op_alu <= s_op_alu & opxcode(5 downto 3) when (s_cur_state = R_OP or s_cur_state = CALLR or s_cur_state = JMP or s_cur_state = BREAK or s_cur_state = SHIFT) else
              "011100" when (opcode = x"06") else --unconditional branch verifies A (x00) == B (x00)
              s_op_alu & opcode(5 downto 3);
    
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
            when FETCH1 => s_next_state <= FETCH2;
            when FETCH2 => s_next_state <= DECODE;
            when DECODE =>
                case( opcode ) is
                    when x"3A" => 
                        case (opxcode) is
                            when x"34" => s_next_state <= BREAK;
                            when x"1D" => s_next_state <= CALLR;
                            when x"05" => s_next_state <= JMP;
                            when x"0D" => s_next_state <= JMP;
                            when x"12" => s_next_state <= SHIFT;
                            when x"1A" => s_next_state <= SHIFT;
                            when x"3A" => s_next_state <= SHIFT;
                            when x"02" => s_next_state <= SHIFT;
                            when others => s_next_state <= R_OP;
                        end case;
                    when x"04" => s_next_state <= I_OP; --I_OP
                    when x"17" => s_next_state <= LOAD1; --LOAD
                    when x"15" => s_next_state <= STORE; --STORE

                    when x"0C" => s_next_state <= IMM;
                    when x"14" => s_next_state <= IMM;
                    when x"1C" => s_next_state <= IMM;

                    when x"06" => s_next_state <= BRANCH;
                    when x"0E" => s_next_state <= BRANCH;
                    when x"16" => s_next_state <= BRANCH;
                    when x"1E" => s_next_state <= BRANCH;
                    when x"26" => s_next_state <= BRANCH;
                    when x"2E" => s_next_state <= BRANCH;
                    when x"36" => s_next_state <= BRANCH;

                    when x"00" => s_next_state <= CALL;
                    when x"01" => s_next_state <= JMPI;
                    when others => s_next_state <= BREAK;
                end case ;
            when LOAD1 => s_next_state <= LOAD2;
            when BREAK => s_next_state <= BREAK;
            when others => s_next_state <= FETCH1;
        end case ;
    end process ; -- transition
end synth;
