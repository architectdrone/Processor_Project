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
    Port ( address : in STD_LOGIC_VECTOR (31 downto 0);
           instruction : out STD_LOGIC_VECTOR (31 downto 0));
end instruction_file;

architecture Behavioral of instruction_file is

--Types
type memory_type is array(0 to 31) of STD_LOGIC_VECTOR(31 downto 0);

--Constants
constant zero_register : std_logic_vector(31 downto 0) := (others => '0');

constant instructions: memory_type:=(
"1001000010101011100011100100100",
"0101000010101011100011100110100",
"1011000010101011100011100000000",
"0111000010101011100011100000000",
"1101000010101011100011101001010",
"1101000010101011100011110110101",
"1100111110100100000011100000000",
others => zero_register --Leave at end to default remaining registers to 0
); 

begin

instruction <= instructions(to_integer(unsigned(address(4 downto 0)))) when to_integer(unsigned(address(4 downto 0))) < 32 else
               (others => '0');

end Behavioral;
