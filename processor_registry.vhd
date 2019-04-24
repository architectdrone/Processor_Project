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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity processor_registry is
    Port ( w_addr : in STD_LOGIC_VECTOR (4 downto 0);
           w_in : in STD_LOGIC_VECTOR (31 downto 0);
           w_en : in STD_LOGIC;
           r_addr1 : in STD_LOGIC_VECTOR (4 downto 0);
           r_addr2 : in STD_LOGIC_VECTOR (4 downto 0);
           r_out1 : out STD_LOGIC_VECTOR (31 downto 0);
           r_out2 : out STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           reset : in STD_LOGIC);
end processor_registry;

architecture Behavioral of processor_registry is
    type reg_file_type is array(31 downto 0) of std_logic_vector(31 downto 0);
    signal array_reg: reg_file_type;
begin
    --Normal operation
    process (clk)
    begin
        if (rising_edge(clk)) then
            --Access locations
            r_out1 <= array_reg(to_integer(unsigned(r_addr1)));
            r_out2 <= array_reg(to_integer(unsigned(r_addr2)));
            
            --Write
            if ((to_integer(unsigned(w_addr)) >= 8) and (to_integer(unsigned(r_addr1)) <= 23)) then --This line garuntees that we will only write to allowed locations
                if (w_en = '1') then
                    array_reg(to_integer(unsigned(w_addr))) <= w_in;
                end if;
            end if;
        end if;
    end process;
    
    --Reset
    process (reset)
    begin
        if (rising_edge(reset)) then
            for i in 32 loop
                array_reg(i) <= (others <= '0');
            end loop;
        end if;
    end process;
end Behavioral;
