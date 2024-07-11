use work.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity datapath is
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
end entity datapath;

architecture data_flow of datapath is 

    component RF
    generic(N:integer:=4;
            M:integer:=3);
    port (
        clk,reset,write,readA,readB:IN std_logic; -- Is "write" a reserved word in VHDL?
        WD:IN std_logic_vector(N-1 downto 0);  -- WD=Write_Data
        WAddr,RA,RB:IN std_logic_vector(M-1 downto 0); -- WAddr=Write_Addr, RA=Read_A_Addr, RB=Read_B_Addr
        QA,QB:OUT std_logic_vector(N-1 downto 0)
    );
    end component;

    component ALU
    generic(N:integer:=4);
    port(
        clk,reset,en: IN std_logic;
        op: IN std_logic_vector(2 downto 0);
        a, b: IN std_logic_vector(N-1 downto 0);
        y: OUT std_logic_vector(N-1 downto 0);
        Z_flag, N_flag, O_flag: OUT std_logic
    );
    end component;
    component mux
    generic(N:integer:=4);
    port (
        sel: IN std_logic;
        in1, in2: IN std_logic_vector(N-1 downto 0);
        y: OUT std_logic_vector(N-1 downto 0)
    );
    end component;
    signal readA_inside: std_logic;
    signal WD, tmp_out, QA, QB, ALU_inA, ALU_inB, tmp_z, tmp_n, tmp_o: std_logic_vector(N-1 downto 0);
    signal RA_inside, WA_inside: std_logic_vector(M-1 downto 0); -- RA will be set to PC register for branch instructions
begin
    RA_inside <= RA when byPassB = '0' else (others => '1');
    WA_inside <= WAddr when byPassW = '0' else (others => '1');
    readA_inside <= readA when byPassB = '0' else '1';

    M0: mux
    generic map(N => N)
    port map(sel => IE,
    in1 => tmp_out,
    in2 => input_data,
    y => WD);

    M1: mux 
    generic map(N => N)
    port map(sel => byPassA,
    in1 => QA,
    in2 => offset,
    y => ALU_inA); 

    M2: mux
    generic map(N => N)
    port map(sel => byPassB,
    in1 => QB,
    in2 => offset,
    y => ALU_inB); 
    
    RF0: RF
    generic map(N => N, M => M)
    port map(clk => clk,
    reset => reset,
    write => write,
    readA => readA_inside,
    readB => readB,
    WD => WD,
    WAddr => WA_inside,
    RA => RA_inside,
    RB => RB,
    QA => QA,
    QB => QB
    );
    ALU0: ALU
    generic map(N => N)
    port map(clk => clk, 
    reset => '0',
    en => '1',
    op => op,
    a => ALU_inA,
    b => ALU_inB,
    y => tmp_out,
    Z_flag => Z_flag,
    N_flag => N_flag,
    O_flag => O_flag);
    output_data <= tmp_out when OE = '1' else (others => 'Z');    
end architecture data_flow; 
