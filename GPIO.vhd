library IEEE;
use IEEE.std_logic_1164.all;

entity GPIO is
  generic (G: Integer:= 8);
  port (
    clk, reset, IE, OE: IN std_logic;
    Din: IN std_logic_vector(G-1 downto 0);
    Dout: OUT std_logic_vector(G-1 downto 0)
  ) ;
end GPIO;

architecture behave of GPIO is

    signal reg: std_logic_vector(G-1 downto 0);
begin
    process( clk, reset )
    begin
        if reset = '1' then
            reg <= (others => '0');
        
        elsif rising_edge(clk) then
            if IE = '1' then
                reg <= Din;
            
            end if ;
        end if ;
    end process ;


    Dout <= reg when OE='1' else (others => '0');
end behave ; 