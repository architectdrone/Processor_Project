----------------------------------------------------------------------------------
-- Company: The University of Kansas
-- Engineer: Owen Mellema
--
-- Create Date: 04/16/2019 04:42:42 PM
-- Design Name: Register File
-- Module Name: processor_registry - Behavioral
-- Project Name: 32 bit Pseudo-MIPS processor
-- Target Devices: NEXSYS4 DDR
-- Description: Following MIPS conventions implement a 32-bit microprocessor
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity processor_registry is
    Port ( d_addr   : in STD_LOGIC_VECTOR (4 downto 0); --! Address of debug read
           w_addr   : in STD_LOGIC_VECTOR (4 downto 0); --! Address to write to in register file
           w_in     : in STD_LOGIC_VECTOR (31 downto 0); --! Value to write into address at w_addr
           w_en     : in STD_LOGIC; --! write enable signal
           r_addr1  : in STD_LOGIC_VECTOR (4 downto 0); --! First read address
           r_addr2  : in STD_LOGIC_VECTOR (4 downto 0); --! Second read address
           d_out    : out STD_LOGIC_VECTOR (31 downto 0); --! Read address for debug
           r_out1   : out STD_LOGIC_VECTOR (31 downto 0); --! Output of value at r_addr1
           r_out2   : out STD_LOGIC_VECTOR (31 downto 0); --! Output of value at r_addr2
           clk      : in STD_LOGIC; --! Clock signal
           reset    : in STD_LOGIC --! Reset signal
           );
end processor_registry;

architecture Behavioral of processor_registry is
    --Types
    type reg_file_type is array(31 downto 0) of std_logic_vector(31 downto 0);
    
    --Constants
    constant zero_register : std_logic_vector(31 downto 0) := (others => '0');
    --Signals
    signal array_reg: reg_file_type;
    
begin
    --Access locations
    r_out1 <= array_reg(to_integer(unsigned(r_addr1)));
    r_out2 <= array_reg(to_integer(unsigned(r_addr2)));
    d_out <= array_reg(to_integer(unsigned(d_addr)));
    --Normal operation
    process (clk, reset)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                array_reg(array_reg'length - 1 downto 0) <= (others => zero_register);
            else
                --Write
                if ((to_integer(unsigned(w_addr)) >= 8) and (to_integer(unsigned(w_addr)) <= 25)) then --only write to temp/saved registers
                    if (w_en = '1') then
                        array_reg(to_integer(unsigned(w_addr))) <= w_in;
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
