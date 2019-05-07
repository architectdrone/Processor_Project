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
    Port ( debug_addr   : in STD_LOGIC_VECTOR(15 downto 0); --! Address of debug read
           addr         : in STD_LOGIC_VECTOR (15 downto 0); --! Address to write/read from
           write        : in STD_LOGIC_VECTOR (31 downto 0); --! Valuet o write to addr
           w_en         : in STD_LOGIC; --! Write enable signal
           r_en         : in STD_LOGIC; --! Read enable signal
           clk          : in STD_LOGIC; --! Clock signal
           read         : out STD_LOGIC_VECTOR (31 downto 0); --! Value stored at addr when r_en is '1'
           debug_read   : out STD_LOGIC_VECTOR(31 downto 0); --! Output of register at debug_addr
           reset        : in STD_LOGIC --! Reset signal
           );
end memory;

architecture Behavioral of memory is

--Types
type memory_type is array(0 to 31) of STD_LOGIC_VECTOR(31 downto 0);

--Constants
constant zero_register : std_logic_vector(31 downto 0) := (others => '0');

--Signals
signal memory_bank : memory_type:=(
others => zero_register --Leave at end to default remaining registers to 0
); 

begin

--Write
process(clk, reset)
    begin
        if(rising_edge(clk)) then
            if (reset = '0') then
                if(w_en='1') then
                    memory_bank(to_integer(unsigned(addr(4 downto 0)))) <= write;
                end if;
            else
                --On a reset, we set most registers to 0, except for a few, which are set to initial data.
                memory_bank <= (
                                0 => "00000000000000000000000000000000", --Register 0 has a zero.
                                1 => "00000000000000000000000000000001", --Register 1 has a 1.
                                2 => "00000000000000000000000000000010", --Register 2 has a 2.
                                3 => "00000000000000000000000000000011", --Register 3 has a 3.
                                4 => "00000000000000000000000000000100", --Register 4 has a 4.
                                5 => "00000000000000000000000000000101", --Register 5 has a 5.
                                6 => "00000000000000000000000000000110", --Register 6 has a 6.
                                7 => "00000000000000000000000000000111", --Register 7 has a 7.
                                8 => "00000000000000000000000000001000", --Register 8 has a 8.
                                9 => "00000000000000000000000000001001", --Register 9 has a 9.
                                others => zero_register);
            end if;
        end if;
end process;

--Read
read <= memory_bank(to_integer(unsigned(addr(4 downto 0)))) when r_en='1' else
        (others => '0');
debug_read <= memory_bank(to_integer(unsigned(debug_addr(4 downto 0))));


end Behavioral;