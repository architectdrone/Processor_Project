----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/06/2019 03:58:32 PM
-- Design Name: 
-- Module Name: BCH_ROM_16x7 - Behavioral
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BCH_ROM_16x7 is
    Port ( a : in STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0));
end BCH_ROM_16x7;

architecture Behavioral of BCH_ROM_16x7 is
type rom is array (0 to 2**4-1) of std_logic_vector (6 downto 0);

constant MY_ROM : rom := (
    0  => "1000000",
    1  => "1111001",
    2  => "0100100",
    3  => "0110000",
    4  => "0011001",
    5  => "0010010",
    6  => "0000010",
    7  => "1111000",
    8  => "0000000",
    9  => "0011000",
    10 => "0001000",
    11 => "0000011",
    12 => "1000110",
    13 => "0100001",
    14 => "0000110",
    15 => "0001110"
    );
begin
    seg <= MY_ROM(to_integer(unsigned(a)));

end Behavioral;
