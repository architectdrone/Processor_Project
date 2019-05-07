----------------------------------------------------------------------------------
-- Company: The University of Kansas
-- Engineer: Bailey K. Srimoungchanh
-- 
-- Create Date: 04/23/2019 03:17:04 PM
-- Design Name: Program Counter
-- Module Name: program_counter - Behavioral
-- Project Name: 32 bit Pseudo-MIPS processor 
-- Target Devices: NEXSYS4 DDR
-- Description: Following MIPS conventions implement a 32-bit microprocessor
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity program_counter is
    Port (  clk     : in STD_LOGIC; --! Clock signal
            reset   : in STD_LOGIC; --! Reset signal
            addr    : out STD_LOGIC_VECTOR(7 downto 0) --! Address of next instruction
            );
end program_counter;

architecture Behavioral of program_counter is

--Signals
signal current_addr: STD_LOGIC_VECTOR(7 downto 0) := "00000000";--unsigned RANGE x"00" to x"FF" := x"00"; --current address

begin

    --on rising edge give the address and increment
    process(clk)
    begin
        if(rising_edge(clk)) then
            if (reset = '0') then 
                current_addr <= STD_LOGIC_VECTOR(unsigned(current_addr) + 1);
            else
                current_addr <= "00000000";
            end if;
        end if;
    end process;
    
    addr <= current_addr;
    
end Behavioral;
