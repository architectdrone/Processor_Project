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
0=>"10000000000010000000000000000001", --Load M1 into R8.
--The fun part. Copy and paste to taste.
1=>"00000001001010000100000000100000", --Add R8 and R9, put the result in R8.
2=>"00000001001010000100100000100000", --Add R8 and R9, put the result in R9.
--Here I've copied and pasted a few times.
3=>"00000001001010000100000000100000", --Add R8 and R9, put the result in R8.
4=>"00000001001010000100100000100000", --Add R8 and R9, put the result in R9.
5=>"00000001001010000100000000100000", --Add R8 and R9, put the result in R8.
6=>"00000001001010000100100000100000", --Add R8 and R9, put the result in R9.
7=>"00000001001010000100000000100000", --Add R8 and R9, put the result in R8.
8=>"00000001001010000100100000100000", --Add R8 and R9, put the result in R9.
9=>"00000001001010000100000000100000", --Add R8 and R9, put the result in R8.
10=>"00000001001010000100100000100000", --Add R8 and R9, put the result in R9.
others => "00000000000000000000000000000000" 
); 

begin

instruction <= instructions(to_integer(unsigned(address))); -- when to_integer(unsigned(address(4 downto 0))) < 32 else (others => '0');

end Behavioral;
