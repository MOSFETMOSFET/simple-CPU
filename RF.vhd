-- use work.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity RF is
    generic(N:integer:=4;
            M:integer:=3);
    port (
        clk,reset,write,readA,readB:IN std_logic; -- Is "write" a reserved word in VHDL?
        WD:IN std_logic_vector(N-1 downto 0);  -- WD=Write_Data
        WAddr,RA,RB:IN std_logic_vector(M-1 downto 0); -- WAddr=Write_Addr, RA=Read_A_Addr, RB=Read_B_Addr
        QA,QB:OUT std_logic_vector(N-1 downto 0)
    );
end entity RF;

architecture data_flow of RF is
    type registerFile is array(0 to 2**M-1) of std_logic_vector(N-1 downto 0);
    signal registers: registerFile:= (others => (others => '0'));
    
begin
    -- Write:
    process(clk, reset)
    begin
        if (reset = '1') then
            for i in registers'range loop
                registers(i) <= (others=>'0');
            end loop;
        
        elsif clk'event and (clk='1') then -- Positive flank
            if (write = '1') then
                registers(conv_integer(unsigned(WAddr))) <= WD;
            end if;
            --PC <= registers(2**M-1);
        end if;
    end process;
    
    QA <= registers(conv_integer(unsigned(RA))) when readA = '1' else (others => '0');
    QB <= registers(conv_integer(unsigned(RB))) when readB = '1' else (others => '0');
    

    -- process(clk)
    -- begin
    --     if clk'event and (clk='0') then -- Negative flank
    --         if (readA='1') then
    --             QA <= registers(conv_integer(unsigned(RA)));
    --         elsif (readA='0') then
    --             QA <= (others=>'0');
    --         end if;
    --         if (readB='1') then
    --             QB <= registers(conv_integer(unsigned(RB)));
    --         elsif (readB='0') then
    --             QB <= (others=>'0');
    --         end if;
    --     end if;
    -- end process;
                                                                                                                                                                                                                          

    -- Read:
    -- * The spec said "output should updated immediately" about readA and readB
    -- process(readA,readB,RA,RB,clk) 
    -- begin
    --     if (readA='1') then
    --         QA <= registers(conv_integer(unsigned(RA)));
    --     elsif (readA='0') then
    --         QA <= (others=>'0');
    --     end if;
    --     if (readB='1') then
    --         QB <= registers(conv_integer(unsigned(RB)));
    --     elsif (readB='0') then
    --         QB <= (others=>'0');
    --     end if;
    -- end process;
    
    
end architecture data_flow;
