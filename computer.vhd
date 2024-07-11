library IEEE;
use IEEE.std_logic_1164.all;

entity computer is
  port (
    clk, reset: IN std_logic;
    GPIO_Dout: OUT std_logic_vector(7 downto 0);
    reset_out: OUT std_logic;
    address_out: OUT std_logic_vector(7 downto 0)
  ) ;
end computer;


architecture behave of computer is

    component cpu
        generic(N:integer:=16;M:integer:=3);
        port(
            clk, reset: IN std_logic;
            RW: OUT std_logic;
            Din: IN std_logic_vector(N-1 downto 0);
            Dout, Address: OUT std_logic_vector(N-1 downto 0)
        );
    end component;

    component ram
        PORT
        (
            clock		: IN STD_LOGIC  := '1';
            data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            rdaddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            rden		: IN STD_LOGIC  := '1';
            wraddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            wren		: IN STD_LOGIC  := '0';
            q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
        );
    end component;

    component GPIO
        generic (G: Integer:= 8);
        port (
        clk, reset, IE, OE: IN std_logic;
        Din: IN std_logic_vector(G-1 downto 0);
        Dout: OUT std_logic_vector(G-1 downto 0)
        ) ;
    end component;

    component divider
        port (
            clk_50M: IN std_logic;
            clk_1: OUT std_logic
        );
    end component;
    -- signal clk: std_logic;
    signal RW, wren_ram, IE: std_logic;
    signal Din, Dout, Address: std_logic_vector(15 downto 0);

begin

    address_out <= Address(7 downto 0);
    reset_out <= reset;

    C0: cpu
    port map(
        clk => clk,
        reset => reset,
        RW => RW,
        Din => Din,
        Dout => Dout,
        Address => Address
    );

    R0: ram
    port map(
        clock => clk,
        data => Dout,
        rdaddress => Address(7 downto 0),
        rden => RW,
        wraddress => Address(7 downto 0),
        wren => wren_ram,
        q => Din
    );

    wren_ram <= '0' when RW='0' and Address="1111000000000000" else not(RW);
    IE <= '1' when RW='0' and Address="1111000000000000" else '0';

    -- GPIO for F000
    G0: GPIO
    port map(
        clk => clk,
        reset => reset,
        IE => IE,
        OE => '1',
        Din => Dout(7 downto 0),
        Dout => GPIO_Dout
    );

end behave ; -- behave