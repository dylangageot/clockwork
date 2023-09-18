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

type alu_operation_t is (op_add, op_sll, op_slt, op_sltu, op_xor, op_srl, op_or, op_and);
type byte_length_t is (none, word, half, byte);
type alu_port_2_t is (port_2_rs_2, port_2_i, port_2_u);

type program_counter_t is record
	enable : std_logic;
	write_pc : std_logic;
end record;

type register_file_t is record
	write_rd : std_logic;
end record;

type alu_t is record
	operation: alu_operation_t;
	arithmetic: std_logic;
	port_2: alu_port_2_t;
end record;

type memory_t is record
	write_rs_2: std_logic;
	byte_length : byte_length_t;
end record;

type control_field_t is record
	program_counter : program_counter_t;
	register_file : register_file_t;
	alu : alu_t;
	memory : memory_t;
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
