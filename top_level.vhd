----------------------------------------------------------------------------------
-- Company: The University of Kansas
-- Engineer: Owen Mellema
--
-- Create Date: 04/23/2019 03:10:55 PM
-- Design Name: Top Level
-- Module Name: top_level - Behavioral
-- Project Name: 32 bit Pseudo-MIPS processor
-- Target Devices: NEXSYS4 DDR
-- Description: Following MIPS conventions implement a 32-bit microprocessor
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.math_real.all;

entity top_level is
    Port ( clk          : in STD_LOGIC; --! Clock Signal
           reset        : in STD_LOGIC; --! Reset signal
           debug_input  : in STD_LOGIC_VECTOR(15 downto 0); --! Address of register you want displayed on Seven Segment
           anode        : out STD_LOGIC_VECTOR (7 downto 0); --! Anode port of Seven Segment display
           cathode      : out STD_LOGIC_VECTOR (6 downto 0); --! Cathode port of Seven Segment display
           display      : out STD_LOGIC_VECTOR(15 downto 0); --! LED display
           debug_switch : in STD_LOGIC --! Switches between displaying registry or memory
           );
end top_level;

architecture Behavioral of top_level is

--Components
component ALU is
    Port ( operation: in STD_LOGIC_VECTOR (7 downto 0); --! Operation to perform
           operand1 : in STD_LOGIC_VECTOR (31 downto 0); --! First operand
           operand2 : in STD_LOGIC_VECTOR (31 downto 0); --! Second operand
           result   : out STD_LOGIC_VECTOR (31 downto 0) --! Result of opration on operands
           );
end component;

component instruction_decoder is
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
end component;

component processor_registry is
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
end component;

component program_counter is
    Port (  clk     : in STD_LOGIC; --! Clock signal
            reset   : in STD_LOGIC; --! Reset signal
            addr    : out STD_LOGIC_VECTOR(7 downto 0) --! Address of next instruction
            );
end component;

component instruction_file is
    Port ( address      : in STD_LOGIC_VECTOR (7 downto 0); --! Address of instruction
           instruction  : out STD_LOGIC_VECTOR (31 downto 0) --! Value of register at address
           );
end component;

component memory is
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
end component;

component seven_segment_driver is
    generic(
        f_board     : natural := 100E6;
        f_flicker   : natural := 62; --Error: This is not 62.5. This shouldn't matter.
        n_segments  : natural := 8
    );
    Port ( data     : in STD_LOGIC_VECTOR (31 downto 0);
           clk      : in STD_LOGIC;
           rst      : in STD_LOGIC;
           anode    : out STD_LOGIC_VECTOR (7 downto 0);
           cathode  : out STD_LOGIC_VECTOR (6 downto 0));
end component;

--Internal signals
signal instruction_addr, alu_func_int: STD_LOGIC_VECTOR(7 downto 0);
signal instruction_content: STD_LOGIC_VECTOR(31 downto 0);
signal rs_int, rt_int, r_rd_int: STD_LOGIC_VECTOR(4 downto 0);
signal opcode_int: STD_LOGIC_VECTOR(5 downto 0);
signal offset_int: STD_LOGIC_VECTOR(15 DOWNTO 0);
signal load_en_int, i_format_int, nop_int: STD_LOGIC;

--Registry accessors
signal registry_input_address, registry_output_address_1, registry_output_address_2, registry_debug_address: STD_LOGIC_VECTOR(4 downto 0); --Addresses
signal registry_input_data, registry_output_data_1, registry_output_data_2, registry_debug_data: STD_LOGIC_VECTOR(31 downto 0); --Data
signal registry_input_control: STD_LOGIC; --Control

--ALU accessors
signal alu_input_data_1, alu_input_data_2, alu_output_data: STD_LOGIC_VECTOR(31 downto 0); --Data
signal alu_function: STD_LOGIC_VECTOR(7 downto 0);

--Memory accessors
signal memory_input_output_address, memory_debug_address: STD_LOGIC_VECTOR(15 downto 0); --16 bit address.
signal memory_input_data, memory_output_data, memory_debug_data: STD_LOGIC_VECTOR(31 DOWNTO 0); --Data
signal memory_input_control, memory_output_control: STD_LOGIC; --Control

--Debug signal
signal debug_display: STD_LOGIC_VECTOR(31 downto 0);
signal debug_registry: STD_LOGIC; --False if reading from memory.
signal an_inter: STD_LOGIC_VECTOR(7 downto 0);
signal ca_inter: STD_LOGIC_VECTOR(6 downto 0);
signal current_state_1, next_state_1: STD_LOGIC_VECTOR(31 downto 0);
signal new_clk: STD_LOGIC;

begin

    counter: program_counter port map(clk   => new_clk,
                                      reset => reset,
                                      addr  => instruction_addr);
                                      
    instructions: instruction_file port map(address     => instruction_addr,
                                            instruction => instruction_content);
    
    --All outputs from decoder are given "_int" signals.                                       
    decode: instruction_decoder port map(instruction=> instruction_content,
                                         alu_func   => alu_func_int,
                                         rs         => rs_int,
                                         r_rd       => r_rd_int,
                                         rt         => rt_int,
                                         offset     => offset_int,
                                         load_en    => load_en_int,
                                         i_format   => i_format_int,
                                         nop        => nop_int,
                                         opcode     => opcode_int);
                                         
    the_registry: processor_registry port map(d_addr => registry_debug_address,
                                              d_out  => registry_debug_data,
                                              clk    => new_clk,
                                              reset  => reset,
                                              w_addr => registry_input_address,
                                              w_in   => registry_input_data,
                                              w_en   => registry_input_control,
                                              r_addr1=> registry_output_address_1,
                                              r_addr2=> registry_output_address_2,
                                              r_out1 => registry_output_data_1,
                                              r_out2 => registry_output_data_2);
    
    the_alu: ALU port map(operation => alu_function,
                          operand1  => alu_input_data_1,
                          operand2  => alu_input_data_2,
                          result    => alu_output_data);
                          
    the_memory: memory port map(debug_addr  => memory_debug_address,
                                debug_read  => memory_debug_data,
                                addr        => memory_input_output_address,
                                write       => memory_input_data,
                                read        => memory_output_data,
                                w_en        => memory_input_control,
                                r_en        => memory_output_control,
                                clk         => new_clk,
                                reset       => reset);
    
    seven_out: seven_segment_driver port map(data => debug_display,
                                             clk => clk,
                                             anode => an_inter,
                                             cathode => ca_inter,
                                             rst => reset);
    --Registry
    registry_output_address_1 <= rs_int when (i_format_int = '0') else rt_int; --When we are in the r mode, we use rs, when in the i mode, we use rt. The output data is sent to the memory input data.
    registry_output_address_2 <= rt_int;
    registry_input_address    <= r_rd_int when (i_format_int = '0') else rt_int; --We also use rt when we are in the i mode here.
    registry_input_data       <= alu_output_data when (i_format_int = '0') else memory_output_data; --Store the results of ALU operations in the registry when in the r mode, otherwise use the output of the memory. Note that the input is only accepted when we are in store for i.
    registry_input_control    <= (not i_format_int and not nop_int) or (i_format_int and load_en_int and not nop_int); --Allow inputs when we are in the r mode, as all operations lead to a stored value. OR inputs when we are in the i mode and the store function.
    registry_debug_address    <= debug_input(4 downto 0);
    
    --ALU
    alu_input_data_1 <= registry_output_data_1;
    alu_input_data_2 <= registry_output_data_2;
    alu_function <= alu_func_int;
    
    --Memory
    memory_input_output_address <= offset_int;
    memory_input_data <= registry_output_data_1; --We read from output data 1 from the registry. See input data 1 for more details...
    memory_input_control <= i_format_int and not load_en_int and not nop_int; --When we are in the I mode, and the store function, we allow inputs.
    memory_output_control<= i_format_int and     load_en_int and not nop_int; --When we are in the I mode, and the fix function, we allow outputs.
    memory_debug_address <= debug_input;
    
    display <= alu_output_data(15 downto 0);
    debug_display <= registry_debug_data when (debug_registry = '1') else memory_debug_data;
    
    --Seven segment
    cathode <= ca_inter; 
    anode <= an_inter; 
    
--Debug logic
with debug_switch select debug_registry <=
    not(debug_registry) when '1',
    debug_registry when others;

    process (current_state_1)
    begin

        --Next State 1
        if (to_integer(unsigned(current_state_1)) = 100E6) then
            next_state_1 <= (others => '0');            
        else
            next_state_1 <= std_logic_vector((unsigned(current_state_1)+1));
        end if;
        
    end process;
    
    -- Current State 1
    process(clk, reset)
    begin
     if (rising_edge(clk)) then
        if (reset = '1') then
            current_state_1 <= (others => '0');
        else
            current_state_1 <= next_state_1;
        end if;
     end if;
    end process;
    
    new_clk <= '1' when (to_integer(unsigned(current_state_1)) = 0) else '0';
 
    
end Behavioral;
