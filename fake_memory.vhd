library ieee;
use ieee.std_logic_1164.all;
use work.assembly_instructions.all;

architecture fake of ram is
    
    signal instruction: program(0 to 255) := (
        (LDI & R5 & B"1_0000_0000"),
        (ADD & R5 & R5 & R5 & Zero_b3),
        (ADD & R5 & R5 & R5 & Zero_b3),
        (ADD & R5 & R5 & R5 & Zero_b3),
        (ADD & R5 & R5 & R5 & Zero_b3),
        (LDI & R6 & B"0_0010_0000"),
        (LDI & R3 & B"0_0000_0011"),
        (ST & Zero_b3 & R6 & R3 & Zero_b3),
        (LDI & R1 & B"0_0000_0001"),
        (LDI & R0 & B"0_0000_1110"),
        (MOV & R2 & R0 & Zero_b6),
        (ADD & R2 & R2 & R1 & Zero_b3),
        (iSUB & R0 & R0 & R1 & Zero_b3),
        (BRZ & X"003"),
        (NOP & R0 & R0 & R0 & Zero_b3),
        (BRA & X"FFC"),
        (ST & Zero_b3 & R6 & R2 & Zero_b3),
        (ST & Zero_b3 & R5 & R2 & Zero_b3),
        (BRA & X"000"),
        others=>(NOP & R0 & R0 & R0 & Zero_b3)
    );

begin

end fake ; -- fake