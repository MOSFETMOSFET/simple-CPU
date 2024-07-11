library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_arith.all;

entity ALU is 
    generic(N:integer:=4);
    port(
        clk,reset,en: IN std_logic;
        op: IN std_logic_vector(2 downto 0);
        a, b: IN std_logic_vector(N-1 downto 0);
        y: OUT std_logic_vector(N-1 downto 0);
        Z_flag, N_flag, O_flag: OUT std_logic
    );
end ALU;

architecture structure of ALU is
    signal tmp_y: std_logic_vector(N-1 downto 0) := conv_std_logic_vector(0,N);
    signal tmp_z,tmp_n,tmp_o:std_logic:='0';
begin
    process(op, a, b, tmp_y)
    begin
        case op is
            when "000" => --add
                tmp_y <= a + b;
                if (tmp_y = conv_std_logic_vector(0,N)) then tmp_z <= '1';
                else tmp_z <= '0';
                end if;
                if (tmp_y(N-1) = '1') then tmp_n <= '1';
                else tmp_n <= '0';
                end if;
                if (a(N-1) = b(N-1) and tmp_y(N-1) /= a(N-1)) then tmp_o <= '1';
                else tmp_o <= '0';
                end if;
            when "001" => --sub
                tmp_y <= a - b;
                if (tmp_y = conv_std_logic_vector(0,N)) then tmp_z <= '1';
                else tmp_z <= '0';
                end if;
                if (tmp_y(N-1) = '1') then tmp_n <= '1';
                else tmp_n <= '0';
                end if;
                if (a(N-1) /= b(N-1) and tmp_y(N-1) /= a(N-1)) then tmp_o <= '1';
                else tmp_o <= '0';
                end if;
            when "010" => --and
                tmp_y <= a and b;
                tmp_o <= '0';
                if (tmp_y = conv_std_logic_vector(0,N)) then tmp_z <= '1';
                else tmp_z <= '0';
                end if;
                if (tmp_y(N-1) = '1') then tmp_n <= '1';
                else tmp_n <= '0';
                end if;
            when "011" => -- or
                tmp_y <= a or b;
                tmp_o <= '0';
                if (tmp_y = conv_std_logic_vector(0,N)) then tmp_z <= '1';
                else tmp_z <= '0';
                end if;
                if (tmp_y(N-1) = '1') then tmp_n <= '1';
                else tmp_n <= '0';
                end if;
            when "100" => --xor
                tmp_y <= a xor b;
                tmp_o <= '0';
                if (tmp_y = conv_std_logic_vector(0,N)) then tmp_z <= '1';
                else tmp_z <= '0';
                end if;
                if (tmp_y(N-1) = '1') then tmp_n <= '1';
                else tmp_n <= '0';
                end if;
            when "101" => --not
                tmp_y <= not(a);
                tmp_o <= '0';
                if (tmp_y = conv_std_logic_vector(0,N)) then tmp_z <= '1';
                else tmp_z <= '0';
                end if;
                if (tmp_y(N-1) = '1') then tmp_n <= '1';
                else tmp_n <= '0';
                end if;
            when "110" => --mov
                tmp_y <= a;
                tmp_o <= '0';
                if (tmp_y = conv_std_logic_vector(0,N)) then tmp_z <= '1';
                else tmp_z <= '0';
                end if;
                if (tmp_y(N-1) = '1') then tmp_n <= '1';
                else tmp_n <= '0';
                end if;
            when "111" => --increment 1
                tmp_y <= a + '1';
                if (tmp_y = conv_std_logic_vector(0,N)) then tmp_z <= '1';
                else tmp_z <= '0';
                end if;
                if (tmp_y(N-1) = '1') then tmp_n <= '1';
                else tmp_n <= '0';
                end if;
                if (tmp_y(N-1) = '1' and tmp_y((N-2) downto 0) = conv_std_logic_vector(0,N-1)) then tmp_o <= '1';
                else tmp_o <= '0';
                end if;
            when others =>
                tmp_y <= conv_std_logic_vector(0,N);
                tmp_z <= '1';
                tmp_n <= '0';
                tmp_o <= '0';
        end case;
    end process;

    y <= tmp_y;
    Z_flag <= tmp_z;
    N_flag <= tmp_n;
    O_flag <= tmp_o;
    -- process(clk, reset)
    -- begin
    --     if reset = '1' then
    --         y <= conv_std_logic_vector(0,N);
    --         Z_flag <= '0';
    --         N_flag <= '0';
    --         O_flag <= '0';
            
    --     elsif clk'event and (clk='1') then
    --         if (en='1') then
    --             y <= tmp_y;
    --             Z_flag <= tmp_z;
    --             N_flag <= tmp_n;
    --             O_flag <= tmp_o;
    --         end if;
    --     end if;
    -- end process;


end structure ; -- structure



