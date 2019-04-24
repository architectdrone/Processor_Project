----------------------------------------------------------------------------------
-- Company: The University of Kansas
-- Engineer: Owen Mellema
-- 
-- Create Date: 04/16/2019 03:55:20 PM
-- Design Name: Algorithmic Logic Unit
-- Module Name: ALU - Behavioral
-- Project Name: 32 bit Pseudo-MIPS processor
-- Target Devices: NEXSYS4 DDR
-- Description: Following MIPS conventions implement a 32-bit microprocessor
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port ( operation : in STD_LOGIC_VECTOR (7 downto 0);
           operand1 : in STD_LOGIC_VECTOR (31 downto 0);
           operand2 : in STD_LOGIC_VECTOR (31 downto 0);
           result : out STD_LOGIC_VECTOR (31 downto 0));
end ALU;

architecture Behavioral of ALU is

begin

process (operand1, operand2, operation)
    begin
        if (operation = "00000000") then --Add
            result <= STD_LOGIC_VECTOR(signed(operand1)+signed(operand2));
        elsif (operation = "00000001") then --Subtract
            result <= STD_LOGIC_VECTOR(signed(operand1)-signed(operand2));
        elsif (operation = "00000010") then --Shift Right Logical
           result <= std_logic_vector(shift_left(unsigned(operand1), to_integer(unsigned(operand2))));
        elsif (operation = "00000011") then --Shift Left Logical
           result <= std_logic_vector(shift_right(unsigned(operand1), to_integer(unsigned(operand2))));
        else
            result <= (others => '0'); 
        end if;
    end process;

end Behavioral;
