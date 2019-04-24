----------------------------------------------------------------------------------
-- Company: The University of Kansas
-- Engineer: Bailey K. Srimoungchanh
-- 
-- Create Date: 04/23/2019 03:17:04 PM
-- Design Name: Memory
-- Module Name: memory - Behavioral
-- Project Name: 32 bit Pseudo-MIPS processor
-- Target Devices: NEXSYS4 DDR
-- Description: Following MIPS conventions implement a 32-bit microprocessor
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory is
    Port ( addr : in STD_LOGIC_VECTOR (15 downto 0);
           write: in STD_LOGIC_VECTOR (31 downto 0);
           w_en : in STD_LOGIC;
           r_en : in STD_LOGIC;
           clk  : in STD_LOGIC;
           read : out STD_LOGIC_VECTOR (31 downto 0));
end memory;

architecture Behavioral of memory is

--Types
type memory_type is array(0 to 4095) of STD_LOGIC_VECTOR(31 downto 0); --3 Hexadecimal addresses

--Constants
constant zero_register : std_logic_vector(31 downto 0) := (others => '0');

--Signals
signal memory_bank : memory_type:=(
others => zero_register --Leave at end to default remaining registers to 0
); 

begin

--Write
process(clk)
begin
if(rising_edge(clk)) then
    if(w_en='1') then
        memory_bank(to_integer(unsigned(addr))) <= write;
    end if;
end if;
end process;

--Read
read <= memory_bank(to_integer(unsigned(addr))) when r_en='1' else
        (others => '0');

end Behavioral;