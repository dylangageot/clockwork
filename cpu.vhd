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
           address : inout  STD_LOGIC_VECTOR (31 downto 0);
           data : inout  STD_LOGIC_VECTOR (31 downto 0);
			  wr : inout STD_LOGIC_VECTOR(3 downto 0);
			  rd : inout STD_LOGIC;
			  ready: inout STD_LOGIC
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
			  next_pc : out STD_LOGIC_VECTOR(31 downto 0);
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
		 ena : IN STD_LOGIC;
		 addra : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	  );
	end component;
	
	component control_unit is
		 Port ( opcode : in  STD_LOGIC_VECTOR (6 downto 0);
				  funct3 : in  STD_LOGIC_VECTOR (2 downto 0);
				  funct7 : in  STD_LOGIC_VECTOR (6 downto 0);
				  id_control : out id_control_t;
				  ex_control : out ex_control_t;
				  mem_control : out mem_control_t;
				  wb_control : out wb_control_t);
	end component;
	
	--! signals
	signal id_control : id_control_t := id_nop;
	signal ex_control : ex_control_t := ex_nop;
	signal mem_control : mem_control_t := mem_nop;
	signal wb_control : wb_control_t := wb_nop;
	signal memory_filter_w, memory_write : std_logic_vector(3 downto 0);
	signal pc_output, pc_input, next_pc, instruction,
			 rf_input, rs_1, rs_2, immd, alu_port_1, alu_port_2, 
			 alu_output, memory_filter_r, pc_immd
			 : std_logic_vector(31 downto 0);
	signal write_rd, enable_pc : std_logic;
	
	--! pipeline registers
	signal id_ex_register : id_ex_register_t := id_ex_nop;
	signal ex_mem_register : ex_mem_register_t := ex_mem_nop;
	signal mem_wb_register : mem_wb_register_t := mem_wb_nop;
	
	--! immediate thangs!
	signal immd_i, immd_s, immd_j, immd_b, immd_u : std_logic_vector(31 downto 0);
	
	alias opcode is instruction(6 downto 0); 
	alias funct3 is instruction(14 downto 12);
	alias funct7 is instruction(31 downto 25);
	alias a_rs_1 is instruction(19 downto 15);
	alias a_rs_2 is instruction(24 downto 20);
	alias a_rd is instruction(11 downto 7);
	
	alias memory_out_byte is data(7 downto 0);
	alias memory_out_half is data(15 downto 0);
	
begin

	enable_pc <= not(mem_control.wait_mem and not(ready));
	--! program counter
	process (clk, rst, enable_pc)
	begin
		if rst = '1' then 
			pc_output <= X"FFFF_FFFC";
		elsif rising_edge(clk) and enable_pc = '1' then
			pc_output <= next_pc;
		end if;
	end process;	
	with id_control.pc_immd select pc_immd <= 
		std_logic_vector(signed(pc_output) + signed(immd_j)) when pc_immd_j,
		std_logic_vector(signed(pc_output) + signed(immd_b)) when pc_immd_b,
		X"0000_0000" when others;
	with ex_control.address_computation_mux select pc_input <=
		alu_output(31 downto 1) & '0' when pc_alu,
		pc_immd when pc_id,
		X"0000_0000" when others;
	with ex_control.write_pc and (
				ex_control.is_jump or 
				(alu_output(0) xor ex_control.negate_alu_output)
	) select next_pc <=
		pc_input when '1',
		std_logic_vector(unsigned(pc_output) + 4) when '0';

	--! instruction cache
	ic1: instruction_cache port map (
		clka => clk,
		ena => enable_pc,
		addra => next_pc,
		douta => instruction
	);
	
	--! control unit
	cu1: control_unit port map (
		opcode => opcode,
		funct3 => funct3,
		funct7 => funct7,
		id_control => id_control,
		ex_control => ex_control,
		mem_control => mem_control,
		wb_control => wb_control
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
		wr => write_rd,
		rs1 => a_rs_1,
		rs2 => a_rs_2,
		rd => a_rd,
		id => rf_input,
		os1 => rs_1,
		os2 => rs_2
	);
	--! write back if write rd is set and that if reading from memory is ready
	write_rd <= wb_control.write_rd and not(mem_control.wait_mem and not(ready));
	--! write back input mux
	with wb_control.rd_input_mux select rf_input <=
		alu_output when rf_alu_output,
		std_logic_vector(resize(signed(memory_out_byte), 32)) when rf_mem_byte,
		std_logic_vector(resize(unsigned(memory_out_byte), 32)) when rf_mem_unsigned_byte,
		std_logic_vector(resize(signed(memory_out_half), 32)) when rf_mem_half,
		std_logic_vector(resize(unsigned(memory_out_half), 32)) when rf_mem_unsigned_half,
		data when rf_mem_word,
		std_logic_vector(unsigned(pc_output) + 4) when rf_pc_4,
		immd_u when rf_u,
		X"0000_0000" when others;

	--! alu
	alu1: alu port map (
		operation => ex_control.operation,
		arithmetic => ex_control.arithmetic,
		input_1 => alu_port_1,
		input_2 => alu_port_2,
		output => alu_output
	);
	--! alu port 1 mux
	with id_control.port_1 select alu_port_1 <=
		rs_1 when port_1_rs_1,
		pc_output when port_1_pc,
		X"0000_0000" when others;
	--! alu port 2 mux
	with id_control.port_2 select alu_port_2 <=
		rs_2 when port_2_rs_2,
		immd_i when port_2_i,
		immd_s when port_2_s,
		immd_u when port_2_u,
		X"0000_0000" when others;

	with mem_control.byte_length select memory_filter_w <=
		"1111" when word,
		"0011" when half,
		"0001" when byte,
		"0000" when others;
	with mem_control.write_mem select wr <=
		memory_filter_w when '1',
		"0000" when others;
	
	address <= alu_output;
	data <= rs_2 when mem_control.write_mem = '1' else (others => 'Z');
	rd <= '1' when mem_control.read_mem = '1' else '0';
	ready <= 'Z';
	
end Behavioral;

