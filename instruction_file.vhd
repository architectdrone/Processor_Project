----------------------------------------------------------------------------------
-- Company: The University of Kansas
-- Engineer: Bailey K. Srimoungchanh
-- 
-- Create Date: 04/16/2019 04:07:27 PM
-- Design Name: Instruction File
-- Module Name: instruction_file - Behavioral
-- Project Name: 32-bit microprocessor implementing MIPS Architecture 
-- Target Devices: NEXSYS4 DDR
-- Description: Following MIPS conventions implement a 32-bit microprocessor
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_file is
    Port ( address : in STD_LOGIC_VECTOR (7 downto 0);
           instruction : out STD_LOGIC_VECTOR (31 downto 0));
end instruction_file;

architecture Behavioral of instruction_file is

--Types
type memory_type is array(0 to 255) of STD_LOGIC_VECTOR(31 downto 0);

--Constants
constant zero_register : std_logic_vector(31 downto 0) := (others => '0');
--Hey bailey use this: https://www.eg.bucknell.edu/~csci320/mips_web/
constant instructions: memory_type:=(
0 => "10000000000010000000000000000001", --Load M1 into R8 "100000 00000 01000 0000000000000001"
1 => "10000000000010010000000000000001", --Load M1 into R9 "100000 00000 01001 0000000000000001"
2 => "00000001001010000101000000100000", --Add R8 and R9, put the result in R10. Display should read 2.
3 => "00000001010010010101000000000000", --Shift R10 left by R9, store in R10. Display should read 4.
4 => "00000001010010010101000000000010", --Shift R10 right by R9, store in R10. Display should read 2.
5 => "10100000000010100000000000010001", --Store R10 into M11.
6 => "10000000000010110000000000010001", --Load M11 into R11.
7 => "00000001011000000000000000100000", --Add R0 and R11. Display should read 2. (R0 is always 0, so this just shows what is in R11).
others => "00000000000000000000000000000000" --Leave at end to default remaining registers to 0
); 

begin

instruction <= instructions(to_integer(unsigned(address))); -- when to_integer(unsigned(address(4 downto 0))) < 32 else (others => '0');

end Behavioral;
