----------------------------------------------------------------------------------
-- Company: The University of Kansas
-- Engineer: Bailey K. Srimoungchanh
-- 
-- Create Date: 04/23/2019 03:17:04 PM
-- Design Name: Program Counter
-- Module Name: program_counter - Behavioral
-- Project Name: 32-bit microprocessor implementing MIPS Architecture 
-- Target Devices: NEXSYS4 DDR
-- Description: Following MIPS conventions implement a 32-bit microprocessor
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity program_counter is
    Port (  clk : in STD_LOGIC;
            addr : out STD_LOGIC_VECTOR (7 downto 0));
end program_counter;

architecture Behavioral of program_counter is

--Signals
signal current_addr : unsigned := x"00"; --current address

begin

--on rising edge give the address and increment
process(clk)
begin
if(rising_edge(clk)) then
    addr <= STD_LOGIC_VECTOR(current_addr);
    current_addr <= current_addr + x"04";
end if;
end process;

end Behavioral;
