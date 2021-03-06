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

    type stateType is (FETCH1, FETCH2, DECODE, I_OP, R_OP, LOAD1, LOAD2, STORE, BREAK, BRANCH, CALL, CALLR, JMP, JMPI, IMM, SHIFT, DEBUG);
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
               '1' when (s_cur_state = IMM) else 
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
             '0' when (s_cur_state = IMM) else
             '1' when (s_cur_state = R_OP) else
             '1' when (s_cur_state = BRANCH) else
             '0' when (s_cur_state = STORE) else 
             '0' when (s_cur_state = SHIFT) else '0';

    --sel_mem
    sel_mem <= '1' when (s_cur_state = LOAD2) else '0';

    --sel_rC: Selects write address (aw). Either B if I_OP, else C if R_OP
    sel_rC <= '0' when (s_cur_state = I_OP) else
              '0' when (s_cur_state = IMM) else
              '1' when (s_cur_state = R_OP) else 
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

    --imm_signed
    imm_signed <= '1' when (s_cur_state = I_OP) else
                  '1' when (s_cur_state = LOAD1) else
                  '1' when (s_cur_state = STORE) else '0';
    
    --s_op_alu
    s_op_alu <= --I_OP
                "000" when (opcode = x"04") else
                "011" when (opcode = x"08") else
                "011" when (opcode = x"10") else
                "011" when (opcode = x"18") else
                "011" when (opcode = x"20") else
                --IMM
                "100" when (opcode = x"0C") else --andi
                "100" when (opcode = x"14") else --ori
                "100" when (opcode = x"1C") else --xnori
                "011" when (opcode = x"28") else --cmpleui
                "011" when (opcode = x"30") else --compgtui
                --BRANCH
                "011" when (opcode = x"06") else
                "011" when (opcode = x"0E") else
                "011" when (opcode = x"16") else
                "011" when (opcode = x"1E") else
                "011" when (opcode = x"26") else
                "011" when (opcode = x"2E") else
                "011" when (opcode = x"36") else

                --R_OP
                "000" when (opcode = x"3A" and opxcode = x"31") else
                "001" when (opcode = x"3A" and opxcode = x"39") else
                "011" when (opcode = x"3A" and opxcode = x"08") else
                "011" when (opcode = x"3A" and opxcode = x"10") else
                "100" when (opcode = x"3A" and opxcode = x"06") else
                "100" when (opcode = x"3A" and opxcode = x"0E") else
                "100" when (opcode = x"3A" and opxcode = x"16") else
                "100" when (opcode = x"3A" and opxcode = x"1E") else
                "110" when (opcode = x"3A" and opxcode = x"13") else
                "110" when (opcode = x"3A" and opxcode = x"1B") else
                "110" when (opcode = x"3A" and opxcode = x"3B") else
                "011" when (opcode = x"3A" and opxcode = x"18") else
                "011" when (opcode = x"3A" and opxcode = x"20") else
                "011" when (opcode = x"3A" and opxcode = x"28") else
                "011" when (opcode = x"3A" and opxcode = x"30") else
                "110" when (opcode = x"3A" and opxcode = x"03") else
                "110" when (opcode = x"3A" and opxcode = x"0B") else
                --SHIFT
                "110" when (opcode = x"3A" and opxcode = x"12") else
                "110" when (opcode = x"3A" and opxcode = x"1A") else
                "110" when (opcode = x"3A" and opxcode = x"3A") else
                "110" when (opcode = x"3A" and opxcode = x"02") else "000";

    --op_alu is not working correctly for all R_TYPE signals
    op_alu <= "011100" when (opcode = x"06" and s_cur_state = BRANCH) else --unconditional branch
              s_op_alu & opxcode(5 downto 3) when (s_cur_state = R_OP or s_cur_state = CALLR or s_cur_state = JMP or s_cur_state = SHIFT) else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"31") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"39") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"08") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"10") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"06") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"0E") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"16") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"1E") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"13") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"1B") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"3B") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"18") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"20") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"28") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"30") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"03") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"0B") else
              
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"12") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"1A") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"3A") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"02") else

              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"1D") else

              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"05") else
              s_op_alu & opxcode(5 downto 3) when (opcode = x"3A" and opxcode = x"0D") else

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
            
            when LOAD1 => s_next_state <= LOAD2;
            when BREAK => s_next_state <= BREAK;
            
            when DECODE =>
                case( opcode ) is
                    when x"04" => s_next_state <= I_OP; --

                    when x"08" => s_next_state <= I_OP; --
                    when x"10" => s_next_state <= I_OP; --
                    when x"18" => s_next_state <= I_OP; --
                    when x"20" => s_next_state <= I_OP; --

                    when x"0C" => s_next_state <= IMM; --
                    when x"14" => s_next_state <= IMM; --
                    when x"1C" => s_next_state <= IMM; --

                    when x"28" => s_next_state <= IMM; --
                    when x"30" => s_next_state <= IMM; --
                
                    when x"17" => s_next_state <= LOAD1; --
                    when x"15" => s_next_state <= STORE; --

                    when x"06" => s_next_state <= BRANCH; --
                    when x"0E" => s_next_state <= BRANCH; --
                    when x"16" => s_next_state <= BRANCH; --
                    when x"1E" => s_next_state <= BRANCH; --
                    when x"26" => s_next_state <= BRANCH; --
                    when x"2E" => s_next_state <= BRANCH; --
                    when x"36" => s_next_state <= BRANCH; --

                    when x"00" => s_next_state <= CALL; --
                    when x"01" => s_next_state <= JMPI; --

                    when x"3A" => 
                        case (opxcode) is
                            when x"34" => s_next_state <= BREAK; --
                            when x"1D" => s_next_state <= CALLR; --
                            when x"05" => s_next_state <= JMP; --
                            when x"0D" => s_next_state <= JMP; --

                            when x"12" => s_next_state <= SHIFT; --
                            when x"1A" => s_next_state <= SHIFT; --
                            when x"3A" => s_next_state <= SHIFT; --
                            when x"02" => s_next_state <= SHIFT; --

                            when others => s_next_state <= R_OP; --
                        end case;
                    
                    when others => s_next_state <= DEBUG; --Find the sentinel state (eg extra state). Check for what instructions we get the sentinel state
                end case ;

            when others => s_next_state <= FETCH1;
        end case ;
    end process ; -- transition
end synth;
