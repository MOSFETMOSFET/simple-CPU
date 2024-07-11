library IEEE;
use IEEE.std_logic_1164.all;

entity cpu is
    generic(N:integer:=16;M:integer:=3);
    port(
        clk, reset: IN std_logic;   --input reset and clk         
        RW: OUT std_logic;          -- 0 read 1 write
        Din: IN std_logic_vector(N-1 downto 0); --input instruction
        Dout, Address: OUT std_logic_vector(N-1 downto 0) --output result and address(pc)
    );
end entity cpu;

architecture behave of cpu is


    signal Instruction_register: std_logic_vector(15 downto 0);  --a register to latch instruction
    signal ALU_out: std_logic_vector(N-1 downto 0);              --result of ALU
    signal Z_flag, N_flag, O_flag, selected_flag, clk_after_divider: std_logic; --flags and clk after clk divider
    signal flag_selection_signal: std_logic_vector(2 downto 0);                           --select Z N or O flags according to requirements
    signal Control_signal_register: std_logic_vector(3 downto 0);                            -- a combined control signal for datapath
    signal offset_register: std_logic_vector(15 downto 0);                  --store the offset and do sign extended
    signal write_enable_wire: std_logic;
    signal readA_enable_wire, readB_enable_wire: std_logic; 
    signal IE_wire, OE_wire :std_logic; 
    signal byPassA_wire, byPassB_wire: std_logic;
    signal byPassW_wire: std_logic;
    signal Z_flag_Register, N_flag_Register, O_flag_Register: std_logic; --several signals for datapath
    signal opcodes: std_logic_vector(2 downto 0);                            --opcodes for ALU
    signal uPC: std_logic_vector(1 downto 0);                           --upc for system

    component datapath
        generic(N:integer:=4;
                M:integer:=3);
        port (
            input_data, offset: IN std_logic_vector(N-1 downto 0);
            clk, reset, write, readA, readB, IE, OE, byPassA, byPassB, byPassW:IN std_logic;
            op: IN std_logic_vector(2 downto 0);
            WAddr, RA, RB:IN std_logic_vector(M-1 downto 0);
            Z_flag, N_flag, O_flag: OUT std_logic;
            output_data: OUT std_logic_vector(N-1 downto 0);
            slowed_clock: OUT std_logic
        );
    end component;

    component fsm_controller
        generic(N:integer:=16);
        port(
            instruction_op: IN std_logic_vector(3 downto 0); 
            Z_reg, N_reg, O_reg, clk, reset: IN std_logic;
            readA_enable, readB_enable, write_enable, byPassA, byPassB, byPassW, IE, OE, RW: OUT std_logic; 
            op, sel: OUT std_logic_vector(2 downto 0); 
            control_signal: OUT std_logic_vector(3 downto 0); 
            uPC: OUT std_logic_vector(1 downto 0)
        );
    end component;

begin
    offset_register(8 downto 0) <= Instruction_register(8 downto 0);
    offset_register(11 downto 9) <= (others => Instruction_register(8)) when Instruction_register(15 downto 12) = "1010" else
        Instruction_register(11 downto 9);
        offset_register(15 downto 12) <= (others => Instruction_register(8)) when Instruction_register(15 downto 12) = "1010" else
        (others => Instruction_register(11));

    D0: datapath
    generic map(N => N)
    port map(
        input_data => Din,
        offset => offset_register,
        clk => clk,
        reset => '0',
        write => write_enable_wire,
        readA => readA_enable_wire,
        readB => readB_enable_wire,
        IE => IE_wire,
        OE => OE_wire,
        byPassA => byPassA_wire,
        byPassB => byPassB_wire,
        byPassW => byPassW_wire,
        op => opcodes,
        WAddr => Instruction_register(11 downto 9),
        RA => Instruction_register(8 downto 6),
        RB => Instruction_register(5 downto 3),
        Z_flag => Z_flag,
        N_flag => N_flag,
        O_flag => O_flag,
        output_data => ALU_out,
        slowed_clock => clk_after_divider
    );

    DC0: fsm_controller
    generic map(N => N)
    port map(
        instruction_op => Instruction_register(15 downto 12),
        Z_reg => Z_flag_Register,
        N_reg => N_flag_Register,
        O_reg => O_flag_Register,
        clk => clk,
        reset => reset,
        readA_enable => readA_enable_wire,
        readB_enable => readB_enable_wire,
        write_enable => write_enable_wire,
        byPassA => byPassA_wire,
        byPassB => byPassB_wire,
        byPassW => byPassW_wire,
        IE => IE_wire,
        OE => OE_wire,
        RW => RW,
        op => opcodes,
        sel => flag_selection_signal,
        control_signal => Control_signal_register,
        uPC => uPC
    );
    selected_flag <= Z_flag_Register when flag_selection_signal = "100" else
        N_flag_Register when flag_selection_signal = "010" else
        O_flag_Register when flag_selection_signal = "001" else
        '0';
    process(clk, reset)
    begin
        if reset = '1' then
            Instruction_register <= (others => '0');
            Address <= (others => '0');
            Dout <= (others => '0');
            Z_flag_Register <= '0';
            N_flag_Register <= '0';
            O_flag_Register <= '0';
        
        elsif clk'event and clk = '1' then
            if Control_signal_register(3) = '1' then Instruction_register <= Din; end if;
            if Control_signal_register(2) = '1' then
                Z_flag_Register <= Z_flag;
                N_flag_Register <= N_flag;
                O_flag_Register <= O_flag;
            end if;
            if Control_signal_register(1) = '1' then Address <= ALU_out; end if;
            if Control_signal_register(0) = '1' then Dout <= ALU_out; end if;
        end if;
    end process;
end behave; 