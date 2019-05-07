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
    Port ( address      : in STD_LOGIC_VECTOR (7 downto 0); --! Address of instruction
           instruction  : out STD_LOGIC_VECTOR (31 downto 0) --! Value of register at address
           );
end instruction_file;

architecture Behavioral of instruction_file is

--Types
type memory_type is array(0 to 255) of STD_LOGIC_VECTOR(31 downto 0);

--Constants
constant zero_register : std_logic_vector(31 downto 0) := (others => '0');
--Hey bailey use this: https://www.eg.bucknell.edu/~csci320/mips_web/

--A clever usage of the "others" keyword. The number on the display is equal to 2x, where x is the current instruction.
constant instructions: memory_type:=(
0 => "10000000000010000000000000000001", --Load M1 into R8
1 => "00000001000000000000000000100000", --For my OCD, the first number of the sequence is 1. This bit of microcode adds R8 with R0, and stores the result in R0.
others => "00000001000010000100000000100000" --Add R8 and R8 and store the result in R8.
); 

begin

instruction <= instructions(to_integer(unsigned(address))); -- when to_integer(unsigned(address(4 downto 0))) < 32 else (others => '0');

end Behavioral;
