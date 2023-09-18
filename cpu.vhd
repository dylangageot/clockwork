----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:24:48 09/17/2023 
-- Design Name: 
-- Module Name:    cpu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use work.control_field.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is
    Port ( clk : in  STD_LOGIC;
			  rst : in STD_LOGIC;
           address : out  STD_LOGIC_VECTOR (31 downto 0);
           data : inout  STD_LOGIC_VECTOR (31 downto 0);
           enable : out  STD_LOGIC;
			  wr : out STD_LOGIC
			 );
end cpu;

architecture Behavioral of cpu is

	component alu is
		 Port ( operation: alu_operation_t;
				  arithmetic : in STD_LOGIC;
				  input_1 : in  STD_LOGIC_VECTOR (31 downto 0);
				  input_2 : in  STD_LOGIC_VECTOR (31 downto 0);
				  output : out  STD_LOGIC_VECTOR (31 downto 0));
	end component;
	
	
	component program_counter is
    Port ( clk : in  STD_LOGIC;
           ce : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  ci : in STD_LOGIC;
			  input : in  STD_LOGIC_VECTOR (31 downto 0);
           output : out  STD_LOGIC_VECTOR (31 downto 0));
	end component;

	component register_file is
		 Port ( clk : in  STD_LOGIC;
				  wr : in STD_LOGIC;
				  rs1 : in  STD_LOGIC_VECTOR (4 downto 0);
				  rs2 : in  STD_LOGIC_VECTOR (4 downto 0);
				  rd : in  STD_LOGIC_VECTOR (4 downto 0);
				  id : in  STD_LOGIC_VECTOR (31 downto 0);
				  os1 : out  STD_LOGIC_VECTOR (31 downto 0);
				  os2 : out  STD_LOGIC_VECTOR (31 downto 0));
	end component;
	
	component instruction_cache is
	  port (
		 clka : IN STD_LOGIC;
		 addra : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	  );
	end component;
	
	component data_cache
	  port (
		 clka : IN STD_LOGIC;
		 wea : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 addra : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	  );
	end component;
	
	
	--! signals
	signal control_field : control_field_t;
	signal memory_filter_w, memory_write : std_logic_vector(3 downto 0);
	signal a_rs_1, a_rs_2, a_rd : std_logic_vector(4 downto 0);
	signal pc_output, pc_input, instruction,
			 rf_input, rs_1, rs_2, immd, alu_port_2, 
			 alu_output, memory_filter_r, memory_input, memory_output 
			 : std_logic_vector(31 downto 0);
	
	--! immediate thangs!
	signal immd_i, immd_s, immd_j, immd_b, immd_u : std_logic_vector(31 downto 0);
	
begin

	--! program counter
	pc1: program_counter port map (
		clk => clk,
		ce => control_field.program_counter.enable,
		rst => rst,
		ci => control_field.program_counter.write_pc,
		input => pc_input,
		output => pc_output
	);

	--! instruction cache
	ic1: instruction_cache port map (
		clka => clk,
		addra => pc_output,
		douta => instruction
	);
	
	--! retrieve immediates from instructions, depending on the type.
	immd_i <= std_logic_vector(resize(signed(instruction(31 downto 20)), immd_i'length));
	immd_s <= std_logic_vector(resize(signed(instruction(31 downto 25) & instruction(11 downto 7)), immd_s'length));
	immd_b <= std_logic_vector(resize(signed(
			instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0'
			), immd_b'length));
	immd_u <= std_logic_vector(instruction(31 downto 12) & X"000"); 
	immd_j <= std_logic_vector(resize(signed(
		instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & '0'
		), immd_j'length));
	
	--! register file
	rf1: register_file port map (
		clk => clk,
		wr => control_field.register_file.write_rd,
		rs1 => a_rs_1,
		rs2 => a_rs_2,
		rd => a_rd,
		id => rf_input,
		os1 => rs_1,
		os2 => rs_2
	);

	--! alu
	with control_field.alu.port_2 select alu_port_2 <=
		rs_2 when port_2_rs_2,
		immd when others;
	alu1: alu port map (
		operation => control_field.alu.operation,
		arithmetic => control_field.alu.arithmetic,
		input_1 => rs_1,
		input_2 => alu_port_2,
		output => alu_output
	);

	--! data cache
	with control_field.memory.byte_length select memory_filter_w <=
		"1111" when word,
		"0011" when half,
		"0001" when byte,
		"0000" when others;
	with control_field.memory.write_rs_2 select memory_write <=
		memory_filter_w when '1',
		"0000" when others;
	with control_field.memory.byte_length select memory_filter_r <=
		X"FFFF_FFFF" when word,
		X"0000_FFFF" when half,
		X"0000_00FF" when byte,
		X"0000_0000" when others;
	memory_input <= memory_filter_r and rs_2;
	dc1: data_cache port map (
		clka => clk,
		wea => memory_write,
		addra => alu_output,
		dina => memory_input,
		douta => memory_output
	);
	
end Behavioral;

