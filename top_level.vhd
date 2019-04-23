----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/23/2019 03:10:55 PM
-- Design Name: 
-- Module Name: top_level - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_level is
    Port ( clk : in STD_LOGIC;
           reset: in STD_LOGIC);
end top_level;

architecture Behavioral of top_level is

component ALU is
    Port ( operation : in STD_LOGIC_VECTOR (7 downto 0);
           operand1 : in STD_LOGIC_VECTOR (31 downto 0);
           operand2 : in STD_LOGIC_VECTOR (31 downto 0);
           result : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component instruction_decoder is
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
end component;

component processor_registry is
    Port ( w_addr : in STD_LOGIC_VECTOR (4 downto 0);
           w_in : in STD_LOGIC_VECTOR (31 downto 0);
           w_en : in STD_LOGIC;
           r_addr1 : in STD_LOGIC_VECTOR (4 downto 0);
           r_addr2 : in STD_LOGIC_VECTOR (4 downto 0);
           r_out1 : out STD_LOGIC_VECTOR (31 downto 0);
           r_out2 : out STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           reset : in STD_LOGIC);
end component;

component program_counter is
    port (
        clk: in STD_LOGIC;
        addr: in STD_LOGIC_VECTOR(7 downto 0)
    );
end component;

component instruction_file is
    Port ( address : in STD_LOGIC_VECTOR (7 downto 0);
           instruction : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component memory is
    Port ( addr : in STD_LOGIC_VECTOR (15 downto 0);
           write: in STD_LOGIC_VECTOR (31 downto 0);
           w_en : in STD_LOGIC;
           r_en : in STD_LOGIC;
           clk  : in STD_LOGIC;
           read : out STD_LOGIC_VECTOR (31 downto 0));
end component;

--Ferrying information - internal signals
signal instruction_addr, alu_func_int: STD_LOGIC_VECTOR(7 downto 0);
signal instruction_content: STD_LOGIC_VECTOR(31 downto 0);
signal r_rs_int, r_rt_int, r_rd_int, i_rt_int: STD_LOGIC_VECTOR(4 downto 0);
signal i_imm_rs_int: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal load_int, i_int, nop_int: STD_LOGIC;

--Registry Accessors
signal registry_input_address, registry_output_address_1, registry_output_address_2: STD_LOGIC_VECTOR(4 downto 0); --Addresses
signal registry_input_data, registry_output_data_1, registry_output_data_2: STD_LOGIC_VECTOR(31 downto 0); --Data
signal registry_input_control: STD_LOGIC; --Control

--ALU Accessors
signal alu_input_data_1, alu_input_data_2, alu_output_data: STD_LOGIC_VECTOR(31 downto 0); --Data
signal alu_function: STD_LOGIC_VECTOR(7 downto 0);

--Memory accessors
signal memory_input_output_address: STD_LOGIC_VECTOR(15 downto 0); --16 bit address.
signal memory_input_data, memory_output_data: STD_LOGIC_VECTOR(31 DOWNTO 0); --Data
signal memory_input_control, memory_output_control: STD_LOGIC; --Control
begin

    counter: program_counter port map(clk => clk, addr => instruction_addr);
    instructions: instruction_file port map(address => instruction_addr, instruction => instruction_content);
    decode: instruction_decoder port map(instruction => instruction_content,
                                            alu_func => alu_func_int,
                                            r_rs => r_rs_int,
                                            r_rd => r_rd_int,
                                            r_rt => r_rt_int,
                                            i_rt => i_rt_int,
                                            i_imm_rs => i_imm_rs_int,
                                            load => load_int,
                                            i => i_int,
                                            nop => nop_int);
    --All outputs from decoder are given "_int" signals.
    the_registry: processor_registry port map(
                                              clk    => clk,
                                              reset  => reset,
                                              w_addr => registry_input_address,
                                              w_in   => registry_input_data,
                                              w_en   => registry_input_control,
                                              r_addr1=> registry_output_address_1,
                                              r_addr2=> registry_output_address_2,
                                              r_out1 => registry_output_data_1,
                                              r_out2 => registry_output_data_2);
    the_alu: ALU port map(
                          operation => alu_function,
                          operand1  => alu_input_data_1,
                          operand2  => alu_input_data_2,
                          result    => alu_output_data);
    the_memory: memory port map(
                                addr => memory_input_output_address,
                                write=> memory_input_data,
                                read => memory_output_data,
                                w_en => memory_input_control,
                                r_en => memory_output_control,
                                clk => clk);
    
    --Registry
    registry_output_address_1 <= r_rs_int when (i_int = '0') else i_rt_int; --When we are in the r mode, we use rs, when in the i mode, we use rt. The output data is sent to the memory input data.
    registry_output_address_2 <= r_rt_int;
    registry_input_address    <= r_rd_int when (i_int = '0') else i_rt_int; --We also use rt when we are in the i mode here.
    registry_input_data       <= alu_output_data when (i_int = '0') else memory_output_data; --Store the results of ALU operations in the registry when in the r mode, otherwise use the output of the memory. Note that the input is only accepted when we are in store for i.
    registry_input_control    <= (not i_int and not nop_int) or (i_int and not load_int and not nop_int); --Allow inputs when we are in the r mode, as all operations lead to a stored value. OR inputs when we are in the i mode and the store function.
    
    --ALU
    alu_input_data_1 <= registry_output_data_1;
    alu_input_data_2 <= registry_output_data_2;
    alu_function <= alu_func_int;
    
    --Memory
    memory_input_output_address <= i_imm_rs_int;
    memory_input_data <= registry_output_data_1; --We read from output data 1 from the registry. See input data 1 for more details...
    memory_input_control <= i_int and not load_int and not nop_int; --When we are in the I mode, and the store function, we allow inputs.
    memory_output_control<= i_int and     load_int and not nop_int; --When we are in the I mode, and the load function, we allow outputs.
    
end Behavioral;
