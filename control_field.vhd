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

type pc_address_computation_mux_t is (pc_alu, pc_branch, pc_jump);
type alu_operation_t is (op_add, op_sll, op_slt, op_sltu, op_xor, op_srl, op_or, op_and, op_eq);
type byte_length_t is (none, word, half, byte);
type alu_port_1_t is (port_1_rs_1, port_1_pc);
type alu_port_2_t is (port_2_rs_2, port_2_i, port_2_s, port_2_u);
type register_file_input_mux_t is (rf_mem_byte, rf_mem_unsigned_byte, rf_mem_half, rf_mem_unsigned_half, rf_mem_word, rf_alu_output, rf_pc_4, rf_u);

type program_counter_t is record
	write_pc : std_logic;
	is_jump : std_logic;
	wait_memory: std_logic;
	negate_alu_output : std_logic;
	address_computation_mux : pc_address_computation_mux_t;
end record;

type register_file_t is record
	write_rd : std_logic;
	input_mux : register_file_input_mux_t;
end record;

type alu_t is record
	operation: alu_operation_t;
	arithmetic: std_logic;
	port_1: alu_port_1_t;
	port_2: alu_port_2_t;
end record;

type memory_t is record
	read_mem: std_logic;
	write_rs_2: std_logic;
	byte_length : byte_length_t;
end record;

type control_field_t is record
	program_counter : program_counter_t;
	register_file : register_file_t;
	alu : alu_t;
	memory : memory_t;
end record;

constant nop : control_field_t := (
	program_counter => (
			write_pc => '0',
			is_jump => '0',
			wait_memory => '0',
			negate_alu_output => '0',
			address_computation_mux => pc_alu
	),
	register_file => (
		write_rd => '0',
		input_mux => rf_u
	),
	alu => (
		operation => op_add,
		arithmetic => '0',
		port_1 => port_1_rs_1,
		port_2 => port_2_rs_2
	),
	memory => (
		read_mem => '0',
		write_rs_2 => '0',
		byte_length => none
	)	
);

--! Pipeline version of control vector
type id_control_t is record
	port_1: alu_port_1_t;
	port_2: alu_port_2_t;
end record;

type ex_control_t is record
	operation: alu_operation_t;
	arithmetic: std_logic;
	write_pc : std_logic;
	is_jump : std_logic;
	negate_alu_output : std_logic;
	address_computation_mux : pc_address_computation_mux_t;
end record;

type mem_control_t is record
	byte_length : byte_length_t;
	read_mem: std_logic;
	wait_memory: std_logic;
	write_rs_2: std_logic;
end record;

type wb_control_t is record
	write_rd : std_logic;
	input_mux : register_file_input_mux_t;
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
