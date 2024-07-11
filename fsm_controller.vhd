library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity fsm_controller is
    generic(N:integer:=16);
    port(
        instruction_op: IN std_logic_vector(3 downto 0); 
        Z_reg, N_reg, O_reg, clk, reset: IN std_logic; --From flag mux
        readA_enable, readB_enable, write_enable, byPassA, byPassB, byPassW, IE, OE, RW: OUT std_logic; 
        op, SEL: OUT std_logic_vector(2 downto 0); -- several signal for datapath
        control_signal: OUT std_logic_vector(3 downto 0); -- Latch signal for IR, flag, Addr and Dout
        uPC: OUT std_logic_vector(1 downto 0)
    );
end entity fsm_controller;

architecture structure of fsm_controller is
    signal pres_state: std_logic_vector(1 downto 0) := "00"; 

    subtype opcodes is std_logic_vector(2 downto 0);
    constant opcodes_ADD: opcodes:= "000";
    constant opcodes_SUB: opcodes:= "001";
    constant opcodes_AND: opcodes:= "010";
    constant opcodes_OR: opcodes:= "011";
    constant opcodes_XOR: opcodes:= "100";
    constant opcodes_NOT: opcodes:= "101";
    constant opcodes_MOV: opcodes:= "110";
    constant opcodes_INC: opcodes:= "111";

    subtype flags_type is std_logic_vector(2 downto 0);
    constant z_flag: flags_type:= "100";
    constant n_flag: flags_type:= "010";
    constant o_flag: flags_type:= "001";

    subtype latch_control_signal is std_logic_vector(3 downto 0);
    constant latch_control_instruction                  : latch_control_signal:= "1000";
    constant latch_control_flag                         : latch_control_signal:= "0100";
    constant latch_control_address: latch_control_signal:= "0010";
    constant latch_control_Dout: latch_control_signal   := "0001";
    constant latch_control_none                         : latch_control_signal:= "0000";

    type uIns is record
        IE: std_logic;
        bypass: std_logic_vector(2 downto 0); 
        write_en: std_logic;
        readA_en: std_logic;
        readB_en: std_logic;
        ALU: opcodes;
        OE: std_logic; 
        RW: std_logic; 
        SEL: flags_type; 
        control_signal: std_logic_vector(3 downto 0); 
    end record;

    type FSM_controller_signal is array(0 to 3) of uIns; 


    constant control_signal_ADD: FSM_controller_signal:= (
        ('0', "000", '0', '0', '0', opcodes_ADD, '1', '1', z_flag, latch_control_instruction),
        ('0', "000", '1','1','1', opcodes_ADD, '1', '1' ,z_flag , latch_control_flag        ), 
        ('0', "011", '1','1','0', opcodes_INC, '1', '1' ,z_flag, latch_control_address      ), 
        ('0', "000", '0','0','0', opcodes_MOV,'1', '1', z_flag, latch_control_none          ) 
    );

    constant control_signal_SUB: FSM_controller_signal:= (
        ('0', "000", '0', '0', '0', opcodes_ADD, '1', '1', z_flag, latch_control_instruction),
        ('0', "000", '1','1','1', opcodes_SUB, '1', '1' ,z_flag , latch_control_flag        ), 
        ('0', "011", '1','1','0', opcodes_INC, '1', '1' ,z_flag, latch_control_address      ), 
        ('0', "000", '0','0','0', opcodes_MOV,'1', '1', z_flag, latch_control_none          ) 
    );

    constant control_signal_AND: FSM_controller_signal:= (
        ('0', "000", '0', '0', '0', opcodes_ADD, '1', '1', z_flag, latch_control_instruction),
        ('0', "000", '1','1','1', opcodes_AND, '1', '1' ,z_flag , latch_control_flag        ), 
        ('0', "011", '1','1','0', opcodes_INC, '1', '1' ,z_flag, latch_control_address      ), 
        ('0', "000", '0','0','0', opcodes_MOV,'1', '1', z_flag, latch_control_none          ) 
    );

    constant control_signal_OR: FSM_controller_signal:= (
        ('0', "000", '0', '0', '0', opcodes_ADD, '1', '1', z_flag, latch_control_instruction),
        ('0', "000", '1','1','1', opcodes_OR, '1', '1' ,z_flag , latch_control_flag         ), 
        ('0', "011", '1','1','0', opcodes_INC, '1', '1' ,z_flag, latch_control_address      ), 
        ('0', "000", '0','0','0', opcodes_MOV,'1', '1', z_flag, latch_control_none          ) 
    );
    
    constant control_signal_XOR: FSM_controller_signal:= (
        ('0', "000", '0', '0', '0', opcodes_ADD, '1', '1', z_flag, latch_control_instruction),
        ('0', "000", '1','1','1', opcodes_XOR, '1', '1' ,z_flag , latch_control_flag        ), 
        ('0', "011", '1','1','0', opcodes_INC, '1', '1' ,z_flag, latch_control_address      ), 
        ('0', "000", '0','0','0', opcodes_MOV,'1', '1', z_flag, latch_control_none          ) 
    );

    constant control_signal_NOT: FSM_controller_signal:= (
        ('0', "000", '0', '0', '0', opcodes_ADD, '1', '1', z_flag, latch_control_instruction),
        ('0', "000", '1','1','1', opcodes_NOT, '1', '1' ,z_flag , latch_control_flag        ), 
        ('0', "011", '1','1','0', opcodes_INC, '1', '1' ,z_flag, latch_control_address      ), 
        ('0', "000", '0','0','0', opcodes_MOV,'1', '1', z_flag, latch_control_none          ) 
    );

    constant control_signal_MOV: FSM_controller_signal:= (
        ('0', "000", '0', '0', '0', opcodes_ADD, '1', '1', z_flag, latch_control_instruction),
        ('0', "000", '1','1','1', opcodes_MOV, '1', '1' ,z_flag , latch_control_flag        ), 
        ('0', "011", '1','1','0', opcodes_INC, '1', '1' ,z_flag, latch_control_address      ), 
        ('0', "000", '0','0','0', opcodes_MOV,'1', '1', z_flag, latch_control_none          )
    );



    constant control_signal_not_used: FSM_controller_signal:= (
        ('0', "000", '0', '0', '0', opcodes_INC, '1', '1', z_flag, latch_control_instruction),
        ('0', "011", '1','1','0', opcodes_INC, '1', '1' ,z_flag, latch_control_address      ),
        ('0', "000", '0','0','0', opcodes_MOV, '1', '1' ,z_flag , latch_control_none        ), 
        ('0', "000", '0','0','0', opcodes_MOV,'1', '1', z_flag, latch_control_none          ) 
    );

    constant control_signal_BRZ_NOT_BRANCHED: FSM_controller_signal:= (
        ('0', "000", '0', '0', '0', opcodes_MOV, '1', '1', z_flag, latch_control_instruction),
        ('0', "011", '1', '1','0', opcodes_INC, '1', '1', z_flag, latch_control_address     ),
        ('0', "000", '0', '0', '0', opcodes_MOV, '1', '1', z_flag, latch_control_none       ),
        ('0', "000", '0', '0','0', opcodes_MOV,'1', '1', z_flag, latch_control_none         )
    );

    constant control_signal_BRZ_BRANCHED: FSM_controller_signal:= (
        ('0', "000", '0', '0', '0', opcodes_MOV, '1', '1', z_flag, latch_control_instruction),
        ('0', "011", '1', '1','0', opcodes_ADD, '1', '1', z_flag, latch_control_address     ),
        ('0', "000", '0', '0', '0', opcodes_MOV, '1', '1', z_flag, latch_control_none       ),
        ('0', "000", '0', '0','0', opcodes_MOV,'1', '1', z_flag, latch_control_none         )
    );

    constant control_signal_BRN_NOT_BRANCHED: FSM_controller_signal:= (
        ('0', "000", '0', '0', '0', opcodes_MOV, '1', '1', z_flag, latch_control_instruction),
        ('0', "011", '1', '1','0', opcodes_INC, '1', '1', n_flag, latch_control_address     ),
        ('0', "000", '0', '0', '0', opcodes_MOV, '1', '1', n_flag, latch_control_none       ),
        ('0', "000", '0', '0','0', opcodes_MOV,'1', '1', z_flag, latch_control_none         )
    );

    constant control_signal_BRN_BRANCHED: FSM_controller_signal:= (
        ('0', "000", '0', '0', '0', opcodes_MOV, '1', '1', z_flag, latch_control_instruction),
        ('0', "011", '1', '1','0', opcodes_ADD, '1', '1', n_flag, latch_control_address     ),
        ('0', "000", '0', '0', '0', opcodes_MOV, '1', '1', n_flag, latch_control_none       ),
        ('0', "000", '0', '0','0', opcodes_MOV,'1', '1', z_flag, latch_control_none         )
    );

    constant control_signal_BRO_NOT_BRANCHED: FSM_controller_signal:= (
        ('0', "000", '0', '0', '0', opcodes_MOV, '1', '1', z_flag, latch_control_instruction),
        ('0', "011", '1', '1','0', opcodes_INC, '1', '1', o_flag, latch_control_address     ),
        ('0', "000", '0', '0', '0', opcodes_MOV, '1', '1', o_flag, latch_control_none       ),
        ('0', "000", '0', '0','0', opcodes_MOV,'1', '1', z_flag, latch_control_none         )
    );
    
    constant control_signal_BRO_BRANCHED: FSM_controller_signal:= (
        ('0', "000", '0', '0', '0', opcodes_MOV, '1', '1', z_flag, latch_control_instruction),
        ('0', "011", '1', '1','0', opcodes_ADD, '1', '1', o_flag, latch_control_address     ),
        ('0', "000", '0', '0', '0', opcodes_MOV, '1', '1', o_flag, latch_control_none       ),
        ('0', "000", '0', '0','0', opcodes_MOV,'1', '1', z_flag, latch_control_none         )
    );

    constant control_signal_BRA: FSM_controller_signal:= ( 
        ('0', "000", '0', '0', '0', opcodes_MOV, '1', '1', z_flag, latch_control_instruction),
        ('0', "011", '1', '1', '0', opcodes_ADD, '1', '1' ,z_flag, latch_control_address    ),
        ('0', "000", '0', '0', '0', opcodes_MOV, '1', '1', z_flag, latch_control_none       ),
        ('0', "000", '0', '0', '0', opcodes_MOV,'1', '1', z_flag, latch_control_none        )
    );


    constant control_signal_ST: FSM_controller_signal:= (
        ('0', "000", '0', '0', '0', opcodes_MOV, '1', '0', z_flag, latch_control_instruction),
        ('0', "011", '1', '1', '0', opcodes_INC, '1', '1', z_flag, latch_control_address    ),
        ('0', "000", '0', '0', '1', opcodes_ADD, '1', '1', z_flag, latch_control_Dout       ),
        ('0', "000", '0', '1', '0', opcodes_MOV, '1', '1', z_flag, latch_control_address    )
    );

    constant control_signal_LD: FSM_controller_signal:= (
        ('0', "000", '0', '0', '0', opcodes_MOV, '1', '1', z_flag, latch_control_instruction),
        ('0', "000", '0', '1', '0', opcodes_MOV, '1', '1', z_flag, latch_control_address    ),
        ('0', "011", '1', '1', '0', opcodes_INC, '1', '1', z_flag, latch_control_address    ),
        ('1', "000", '1', '0', '0', opcodes_MOV, '1', '1', z_flag, latch_control_none       )
        
    );

    constant control_signal_LDI: FSM_controller_signal:= (
        ('0', "000", '0', '0', '0', opcodes_MOV, '1', '1', z_flag, latch_control_instruction),
        ('0', "100", '1', '0', '0', opcodes_MOV, '1', '1', z_flag, latch_control_flag       ),
        ('0', "011", '1', '1', '0', opcodes_INC, '1', '1', z_flag, latch_control_address    ),
        ('0', "000", '0', '0', '0', opcodes_MOV,'1', '1', z_flag, latch_control_none        )
    );
    
    signal pres_FSM_controller_signal: FSM_controller_signal;
begin
    pres_FSM_controller_signal <= control_signal_ADD when instruction_op = "0000" else
        control_signal_SUB when instruction_op = "0001" else
        control_signal_AND when instruction_op = "0010" else
        control_signal_OR when instruction_op = "0011" else
        control_signal_XOR when instruction_op = "0100" else
        control_signal_NOT when instruction_op = "0101" else
        control_signal_MOV when instruction_op = "0110" else
        control_signal_not_used when instruction_op = "0111" else
        control_signal_LD when instruction_op = "1000" else
        control_signal_ST when instruction_op = "1001" else
        control_signal_LDI when instruction_op = "1010" else
        control_signal_BRZ_NOT_BRANCHED when instruction_op = "1100" and Z_reg = '0' else
        control_signal_BRZ_BRANCHED when instruction_op = "1100" and Z_reg = '1' else
        control_signal_BRN_NOT_BRANCHED when instruction_op = "1101" and N_reg = '0' else
        control_signal_BRN_BRANCHED when instruction_op = "1101" and N_reg = '1' else
        control_signal_BRO_NOT_BRANCHED when instruction_op = "1110" and O_reg = '0' else
        control_signal_BRO_BRANCHED when instruction_op = "1110" and O_reg = '1' else
        control_signal_BRA when instruction_op = "1111" else
        control_signal_not_used;
    
    uPC <= pres_state;
    process(clk, reset)
    begin
        if reset = '1' then
            pres_state <= "00";
        elsif clk'event and clk = '1' then
            pres_state <= pres_state + 1;
        end if; 
    end process;

    process(pres_state, pres_FSM_controller_signal)
    begin
        IE <= pres_FSM_controller_signal(conv_integer(pres_state)).IE;
        byPassA <= pres_FSM_controller_signal(conv_integer(pres_state)).bypass(2);
        byPassB <= pres_FSM_controller_signal(conv_integer(pres_state)).bypass(1);
        byPassW <= pres_FSM_controller_signal(conv_integer(pres_state)).bypass(0);
        write_enable <= pres_FSM_controller_signal(conv_integer(pres_state)).write_en;
        readA_enable <= pres_FSM_controller_signal(conv_integer(pres_state)).readA_en;
        readB_enable <= pres_FSM_controller_signal(conv_integer(pres_state)).readB_en;
        op <= pres_FSM_controller_signal(conv_integer(pres_state)).ALU;
        OE <= pres_FSM_controller_signal(conv_integer(pres_state)).OE;
        RW <= pres_FSM_controller_signal(conv_integer(pres_state)).RW;
        SEL <= pres_FSM_controller_signal(conv_integer(pres_state)).SEL;
        control_signal <= pres_FSM_controller_signal(conv_integer(pres_state)).control_signal;
    end process;
end structure; 