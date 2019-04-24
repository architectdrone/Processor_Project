----------------------------------------------------------------------------------
-- Company: The University of Kansas
-- Engineer: Owen Mellema
--
-- Create Date: 04/19/2019 03:03:45 PM
-- Design Name: Instruction Decoder
-- Module Name: instruction_decoder - Behavioral
-- Project Name: 32 bit Pseudo-MIPS processor
-- Target Devices: NEXSYS4 DDR
-- Description: Following MIPS conventions implement a 32-bit microprocessor
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instruction_decoder is
    Port ( instruction : in  STD_LOGIC_VECTOR (31 downto 0);
           alu_func    : out STD_LOGIC_VECTOR (7 downto 0);
           r_rd        : out STD_LOGIC_VECTOR (4 downto 0);
           r_rs        : out STD_LOGIC_VECTOR (4 downto 0);
           r_rt        : out STD_LOGIC_VECTOR (4 downto 0);
           i_rt        : out STD_LOGIC_VECTOR (4 downto 0);
           i_imm_rs    : out STD_LOGIC_VECTOR (15 downto 0);
           load        : out STD_LOGIC;
           nop         : out STD_LOGIC;
           i           : out STD_LOGIC
           );
end instruction_decoder;

architecture Behavioral of instruction_decoder is
    signal opcode: STD_LOGIC_VECTOR(5 DOWNTO 0);
    signal func  : STD_LOGIC_VECTOR(5 downto 0);
    
begin
--Assume the bytecode used here: https://en.wikibooks.org/wiki/MIPS_Assembly/Instruction_Formats
    process (instruction)
    
    begin
        opcode <= instruction(31 downto 26);
        func <= instruction(5 downto 0);
        
        r_rs     <= instruction(25 downto 21);
        r_rt     <= instruction(20 downto 16);
        r_rd     <= instruction(15 downto 11);
        i_rs     <= instruction(25 downto 21);
        i_rt     <= instruction(20 downto 16);
        i_imm_rs <= instruction(15 downto 0);
        
        if (opcode = "000000") then --R Mode 
            i <= '0';
            nop <= '0';
            
            if (func = "100000") then --Add (add)
                alu_func <= "00000000";
            elsif (func = "100010") then --Subtract (sub)
                alu_func <= "00000001";
            elsif (func = "000010") then --SRL (srl)
                alu_func <= "00000010";
            elsif (func = "000000") then --SLL (sll)
                alu_func <= "00000011";
            else --Assume add
                alu_func <= "00000000";
            end if;
        elsif (opcode = "101000") then --I Mode: Store. (I'm using opcode 0x28, which translates to "store byte" (sb))
            i <= '1';
            nop <= '0';
            load <= '0';
            
        elsif (opcode = "100000") then --I Mode: Load (0x20) Load Byte
            i <= '1';
            nop <= '0';
            load <= '1';
            
        else --NOP. (Anything besides I and J modes understood.)
            i <= '0';
            nop <= '1';
            
        end if;   
    end process;
        
end Behavioral;
