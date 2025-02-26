library ieee;
use ieee.std_logic_1164.all;
package assembly_instructions is
    subtype instruction is std_logic_vector(15 downto 0);
    type program is array(natural range<>) of instruction;
    subtype opcode is std_logic_vector(3 downto 0);
    subtype reg_code is std_logic_vector(2 downto 0);
    constant ADD: opcode:= "0000";
    constant iSUB: opcode:= "0001";
    constant iAND: opcode:= "0010";
    constant iOR: opcode:= "0011";
    constant iXOR: opcode:= "0100";
    constant iNOT: opcode:= "0101";
    constant MOV: opcode:= "0110";
    constant NOP: opcode:= "0111";
    constant LD: opcode:= "1000";
    constant ST: opcode:= "1001";
    constant LDI: opcode:= "1010";
    constant NU: opcode:= "1011";
    constant BRZ: opcode:= "1100";
    constant BRN: opcode:= "1101";
    constant BRO: opcode:= "1110";
    constant BRA: opcode:= "1111";
    constant R0: reg_code:= "000";
    constant R1: reg_code:= "001";
    constant R2: reg_code:= "010";
    constant R3: reg_code:= "011";
    constant R4: reg_code:= "100";
    constant R5: reg_code:= "101";
    constant R6: reg_code:= "110";
    constant R7: reg_code:= "111";
    constant Zero_b3: std_logic_vector(2 downto 0):= "000";
    constant Zero_b6: std_logic_vector(5 downto 0):= "000000";
end assembly_instructions;