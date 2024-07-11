library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity divider is
    port(
        clk_50M: IN std_logic;
        clk_1: OUT std_logic
    );
end divider;

architecture data_flow of divider is
    signal counter: std_logic_vector(26 downto 0) := (others=>'0');
begin
    process(clk_50M)
    begin
        if (clk_50M'event and clk_50M = '1') then
            counter <= counter + conv_std_logic_vector(16,6);
        end if;
        clk_1 <= counter(26);
    end process;
end architecture data_flow; 