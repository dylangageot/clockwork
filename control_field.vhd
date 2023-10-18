--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package control_field is

type pc_immd_t is (pc_immd_j, pc_immd_b);
type pc_address_computation_mux_t is (pc_alu, pc_id);
type alu_operation_t is (op_add, op_sll, op_slt, op_sltu, op_xor, op_srl, op_or, op_and, op_eq);
type byte_length_t is (none, word, half, byte);
type alu_port_1_t is (port_1_rs_1, port_1_pc);
type alu_port_2_t is (port_2_rs_2, port_2_i, port_2_s, port_2_u);
type register_file_input_mux_t is (rf_mem_byte, rf_mem_unsigned_byte, rf_mem_half, rf_mem_unsigned_half, rf_mem_word, rf_alu_output, rf_pc_4, rf_u);

type id_control_t is record
	pc_immd : pc_immd_t;
	port_1: alu_port_1_t;
	port_2: alu_port_2_t;
end record;

type ex_control_t is record
	operation: alu_operation_t;
	arithmetic: std_logic;
	is_jump : std_logic;
	negate_alu_output : std_logic;
	address_computation_mux : pc_address_computation_mux_t;
	write_pc : std_logic;
end record;

type mem_control_t is record
	byte_length : byte_length_t;
	read_mem: std_logic;
	wait_mem: std_logic;
	write_mem: std_logic;
end record;

type wb_control_t is record
	rd_input_mux : register_file_input_mux_t;
	write_rd : std_logic;
end record;

constant id_nop: id_control_t := (
	pc_immd => pc_immd_j,
	port_1 => port_1_rs_1,
	port_2 => port_2_rs_2
);

constant ex_nop: ex_control_t := (
	operation => op_add,
	arithmetic => '0',
	is_jump => '0',
	negate_alu_output => '0',
	address_computation_mux => pc_alu,
	write_pc => '0'
);

constant mem_nop : mem_control_t := (
	byte_length => none,
	read_mem => '0',
	wait_mem => '0',
	write_mem => '0'
);

constant wb_nop : wb_control_t := (
	rd_input_mux => rf_alu_output,
	write_rd => '0'
);

type id_ex_register_t is record
	ex_control : ex_control_t;
	mem_control : mem_control_t;
	wb_control : wb_control_t;
	a_rd : std_logic_vector(4 downto 0);
	pc_4 : std_logic_vector(31 downto 0);
	pc_immd_jb : std_logic_vector(31 downto 0);
	rs_2 : std_logic_vector(31 downto 0);
	alu_port_1 : std_logic_vector(31 downto 0);
	alu_port_2 : std_logic_vector(31 downto 0);
	immd_u : std_logic_vector(31 downto 0);
end record;

type ex_mem_register_t is record
	mem_control : mem_control_t;
	wb_control : wb_control_t;
	a_rd : std_logic_vector(4 downto 0);
	pc_4 : std_logic_vector(31 downto 0);
	alu_output : std_logic_vector(31 downto 0);
	rs_2 : std_logic_vector(31 downto 0);
	immd_u : std_logic_vector(31 downto 0);
end record;

type mem_wb_register_t is record
	wb_control : wb_control_t;
	a_rd : std_logic_vector(4 downto 0);
	mem_output : std_logic_vector(31 downto 0);
	pc_4 : std_logic_vector(31 downto 0);
	alu_output : std_logic_vector(31 downto 0);
	immd_u : std_logic_vector(31 downto 0);
end record;

-- Declare constants
--
-- constant <constant_name>		: time := <time_unit> ns;
-- constant <constant_name>		: integer := <value;
--
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
--

end control_field;

package body control_field is
end control_field;
