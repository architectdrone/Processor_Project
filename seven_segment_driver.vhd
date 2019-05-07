----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2019 02:11:51 PM
-- Design Name: 
-- Module Name: seven_segment_driver - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.math_real.all;

entity seven_segment_driver is
    generic(
        f_board: natural := 100E6;
        f_flicker: natural := 62; --Error: This is not 62.5. This shouldn't matter.
        n_segments: natural := 8
    );
    Port ( data : in STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           anode : out STD_LOGIC_VECTOR (7 downto 0);
           cathode : out STD_LOGIC_VECTOR (6 downto 0));
end seven_segment_driver;

architecture Behavioral of seven_segment_driver is
    constant f_refresh: natural := n_segments*f_flicker;
    constant count_max1: integer := (f_board/f_refresh)-1;
    constant count_max2: integer := n_segments-1; 
    signal current_state_1, next_state_1: STD_LOGIC_VECTOR(18 downto 0);
    signal current_state_2, next_state_2: STD_LOGIC_VECTOR(3 downto 0);
    signal display_hex: STD_LOGIC_VECTOR(3 downto 0);
    signal data_ext : std_logic_vector(31 downto 0);
    
    component BCH_ROM_16x7 is
        Port ( a : in STD_LOGIC_VECTOR (3 downto 0);
               seg : out STD_LOGIC_VECTOR (6 downto 0));
    end component;
begin
    data_ext <= data;
    process (current_state_1)
    begin

        --Next State 1
        if (to_integer(unsigned(current_state_1)) = count_max1) then
            next_state_1 <= (others => '0');            
        else
            next_state_1 <= std_logic_vector((unsigned(current_state_1)+1));
        end if;
        
    end process;
    
    process (current_state_2, current_state_1)
    begin
        --Next State 2
        if (to_integer(unsigned(current_state_1)) /= count_max1) then
            next_state_2 <= current_state_2;
        else
            if (to_integer(unsigned(current_state_2)) = count_max2) then
                next_state_2 <= (others => '0');            
            else
                next_state_2 <= std_logic_vector((unsigned(current_state_2)+1));
            end if;
        end if;

    end process;
  
    -- Current State 1
    process(clk, rst)
    begin
     if (rising_edge(clk)) then
        if (rst = '1') then
            current_state_1 <= (others => '0');
        else
            current_state_1 <= next_state_1;
        end if;
     end if;
    end process;
        
    -- Current State 2
    process(clk, rst)
    begin
     if (rising_edge(clk)) then
        if (rst = '1') then
            current_state_2 <= (others => '0');
        else
            current_state_2 <= next_state_2;
        end if;
     end if;
    end process;
   
    
    anode <= "11111110" when (to_integer(unsigned(current_state_2)) = 0) else
             "11111101" when (to_integer(unsigned(current_state_2)) = 1) else
             "11111011" when (to_integer(unsigned(current_state_2)) = 2) else
             "11110111" when (to_integer(unsigned(current_state_2)) = 3) else
             "11101111" when (to_integer(unsigned(current_state_2)) = 4) else
             "11011111" when (to_integer(unsigned(current_state_2)) = 5) else
             "10111111" when (to_integer(unsigned(current_state_2)) = 6) else
             "01111111" when (to_integer(unsigned(current_state_2)) = 7) else
             "11111111";
    display_hex <= data_ext((to_integer((unsigned(current_state_2)))*4)+3 downto to_integer(unsigned(current_state_2))*4);
    decoder: BCH_ROM_16x7 port map(a => display_hex, seg => cathode);
end Behavioral;
