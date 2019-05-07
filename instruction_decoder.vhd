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

entity instruction_decoder is
    Port ( instruction  : in  STD_LOGIC_VECTOR (31 downto 0); --! Instruction from instruction file
           alu_func     : out STD_LOGIC_VECTOR (7 downto 0); --! ALU function code
           r_rd         : out STD_LOGIC_VECTOR (4 downto 0); --! R-format register destination
           rs           : out STD_LOGIC_VECTOR (4 downto 0); --! R-format source 1st register / I-format base register
           rt           : out STD_LOGIC_VECTOR (4 downto 0); --! R-format source 2nd register / I-Format destination register
           offset       : out STD_LOGIC_VECTOR (15 downto 0); --! I-format Offset value
           load_en      : out STD_LOGIC; --! Perform load operation
           nop          : out STD_LOGIC; --! No operation
           i_format     : out STD_LOGIC; --! I-format instruction
           opcode       : out STD_LOGIC_VECTOR(5 downto 0) --! Operation code
       );
end instruction_decoder;

architecture Behavioral of instruction_decoder is
    --signal opcode: STD_LOGIC_VECTOR(5 DOWNTO 0);
    signal func  : STD_LOGIC_VECTOR(5 downto 0);
    signal opcode_int  : STD_LOGIC_VECTOR(5 downto 0);
    
begin
--Assume the bytecode used here: https://en.wikibooks.org/wiki/MIPS_Assembly/Instruction_Formats
    process (instruction, opcode_int, func)
    
    begin
        opcode_int <= instruction(31 downto 26);
        opcode <= opcode_int;
        func <= instruction(5 downto 0);
        
        rs     <= instruction(25 downto 21);
        rt     <= instruction(20 downto 16);
        r_rd     <= instruction(15 downto 11);
        rt     <= instruction(20 downto 16);
        offset <= instruction(15 downto 0);
        
        if (opcode_int = "000000") then --R Mode 
            i_format <= '0';
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
        elsif (opcode_int = "101000") then --I Mode: Store. (I'm using opcode 0x28, which translates to "store byte" (sb))
            i_format <= '1';
            nop <= '0';
            load_en <= '0';
            
        elsif (opcode_int = "100000") then --I Mode: Load (0x20) Load Byte
            i_format <= '1';
            nop <= '0';
            load_en <= '1';
            
        else --NOP. (Anything besides I and J modes understood.)
            i_format <= '0';
            nop <= '1';
            
        end if;   
    end process;
        
end Behavioral;
