----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:47:25 09/18/2023 
-- Design Name: 
-- Module Name:    control_unit - Behavioral 
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
use work.control_field.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_unit is
    Port ( opcode : in  STD_LOGIC_VECTOR (6 downto 0);
           funct3 : in  STD_LOGIC_VECTOR (2 downto 0);
           funct7 : in  STD_LOGIC_VECTOR (6 downto 0);
           control_field : out  control_field_t);
end control_unit;

architecture Behavioral of control_unit is

begin

	process (opcode, funct3, funct7)
	begin
		case opcode is
			--! LUI
			when B"0110111" =>
				control_field <= (
					program_counter => (
							write_pc => '0',
							is_jump => '0',
							negate_alu_output => '0',
							address_computation_mux => pc_alu
					),
					register_file => (
						write_rd => '1',
						input_mux => rf_u
					),
					alu => (
						operation => op_add,
						arithmetic => '0',
						port_1 => port_1_rs_1,
						port_2 => port_2_rs_2
					),
					memory => (
						write_rs_2 => '0',
						byte_length => none
					)	
				);
			--! AUIPC
			when B"0010111" =>
				control_field <= (
					program_counter => (
							write_pc => '0',
							is_jump => '0',
							negate_alu_output => '0',
							address_computation_mux => pc_alu
					),
					register_file => (
						write_rd => '1',
						input_mux => rf_alu_output
					),
					alu => (
						operation => op_add,
						arithmetic => '0',
						port_1 => port_1_pc,
						port_2 => port_2_u
					),
					memory => (
						write_rs_2 => '0',
						byte_length => none
					)	
				);
			--! JAL (jump and link)
			when B"1101111" =>
				control_field <= (
					program_counter => (
							write_pc => '1',
							is_jump => '1',
							negate_alu_output => '0',
							address_computation_mux => pc_jump
					),
					register_file => (
						write_rd => '1',
						input_mux => rf_pc_4
					),
					alu => (
						operation => op_add,
						arithmetic => '0',
						port_1 => port_1_rs_1,
						port_2 => port_2_rs_2
					),
					memory => (
						write_rs_2 => '0',
						byte_length => none
					)	
				);
			--! JALR (relative to rs1)
			when B"1100111" =>
				control_field <= (
					program_counter => (
							write_pc => '1',
							is_jump => '1',
							negate_alu_output => '0',
							address_computation_mux => pc_alu
					),
					register_file => (
						write_rd => '1',
						input_mux => rf_pc_4
					),
					alu => (
						operation => op_add,
						arithmetic => '0',
						port_1 => port_1_rs_1,
						port_2 => port_2_i
					),
					memory => (
						write_rs_2 => '0',
						byte_length => none
					)	
				);
			--! branch
			when B"1100011" =>
				case funct3 is
					--! beq
					when b"000" =>
						control_field <= (
							program_counter => (
									write_pc => '1',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_branch
							),
							register_file => (
								write_rd => '0',
								input_mux => rf_u
							),
							alu => (
								operation => op_eq,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_rs_2
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					--! bne
					when b"001" =>
						control_field <= (
							program_counter => (
									write_pc => '1',
									is_jump => '0',
									negate_alu_output => '1',
									address_computation_mux => pc_branch
							),
							register_file => (
								write_rd => '0',
								input_mux => rf_u
							),
							alu => (
								operation => op_eq,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_rs_2
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					--! blt
					when b"100" =>
						control_field <= (
							program_counter => (
									write_pc => '1',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_branch
							),
							register_file => (
								write_rd => '0',
								input_mux => rf_u
							),
							alu => (
								operation => op_slt,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_rs_2
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					--! bge
					when b"101" =>
						control_field <= (
							program_counter => (
									write_pc => '1',
									is_jump => '0',
									negate_alu_output => '1',
									address_computation_mux => pc_branch
							),
							register_file => (
								write_rd => '0',
								input_mux => rf_u
							),
							alu => (
								operation => op_slt,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_rs_2
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					--! bltu
					when b"110" =>
						control_field <= (
							program_counter => (
									write_pc => '1',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_branch
							),
							register_file => (
								write_rd => '0',
								input_mux => rf_u
							),
							alu => (
								operation => op_sltu,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_rs_2
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					--! bgeu
					when b"111" =>
						control_field <= (
							program_counter => (
									write_pc => '1',
									is_jump => '0',
									negate_alu_output => '1',
									address_computation_mux => pc_branch
							),
							register_file => (
								write_rd => '0',
								input_mux => rf_u
							),
							alu => (
								operation => op_sltu,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_rs_2
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					when others =>
						control_field <= (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
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
								write_rs_2 => '0',
								byte_length => none
							)	
						);
				end case;
			--! addi, slti...
			when B"0010011" =>
				case funct3 is
					-- ! addi
					when b"000" =>
						control_field <= (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_alu_output
							),
							alu => (
								operation => op_add,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_i
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					-- ! slti
					when b"010" =>
						control_field <= (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_alu_output
							),
							alu => (
								operation => op_slt,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_i
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					-- ! sltui
					when b"011" =>
						control_field <= (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_alu_output
							),
							alu => (
								operation => op_sltu,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_i
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					-- ! xori
					when b"100" =>
						control_field <= (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_alu_output
							),
							alu => (
								operation => op_xor,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_i
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					-- ! ori
					when b"110" =>
						control_field <= (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_alu_output
							),
							alu => (
								operation => op_or,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_i
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					-- ! andi
					when b"111" =>
						control_field <= (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_alu_output
							),
							alu => (
								operation => op_and,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_i
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					--! slli
					when "001" =>
						control_field <= (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_alu_output
							),
							alu => (
								operation => op_sll,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_i
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					--! srli & srai
					when "101" =>
							control_field <= (
								program_counter => (
										write_pc => '0',
										is_jump => '0',
										negate_alu_output => '0',
										address_computation_mux => pc_alu
								),
								register_file => (
									write_rd => '1',
									input_mux => rf_alu_output
								),
								alu => (
									operation => op_srl,
									arithmetic => funct7(5),
									port_1 => port_1_rs_1,
									port_2 => port_2_i
								),
								memory => (
									write_rs_2 => '0',
									byte_length => none
								)	
							);
					when others =>
						control_field <= (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
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
								write_rs_2 => '0',
								byte_length => none
							)	
						);
				end case;
			--! add, slt...
			when B"0110011" =>
				case funct3 is
					-- ! add or sub
					when b"000" =>
						control_field <= (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_alu_output
							),
							alu => (
								operation => op_add,
								arithmetic => funct7(5),
								port_1 => port_1_rs_1,
								port_2 => port_2_rs_2
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					-- ! slt
					when b"010" =>
						control_field <= (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_alu_output
							),
							alu => (
								operation => op_slt,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_rs_2
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					-- ! sltu
					when b"011" =>
						control_field <= (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_alu_output
							),
							alu => (
								operation => op_sltu,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_rs_2
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					-- ! xor
					when b"100" =>
						control_field <= (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_alu_output
							),
							alu => (
								operation => op_xor,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_rs_2
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					--! or
					when b"110" =>
						control_field <= (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_alu_output
							),
							alu => (
								operation => op_or,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_rs_2
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					--! and
					when b"111" =>
						control_field <= (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_alu_output
							),
							alu => (
								operation => op_and,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_rs_2
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					--! sll
					when "001" =>
						control_field <= (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_alu_output
							),
							alu => (
								operation => op_sll,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_rs_2
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					--! srli & srai
					when "101" =>
						control_field <= (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_alu_output
							),
							alu => (
								operation => op_srl,
								arithmetic => funct7(5),
								port_1 => port_1_rs_1,
								port_2 => port_2_rs_2
							),
							memory => (
								write_rs_2 => '0',
								byte_length => none
							)	
						);
					when others =>
						control_field <= (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
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
								write_rs_2 => '0',
								byte_length => none
							)	
						);
				end case;
			when others =>
				control_field <= (
					program_counter => (
							write_pc => '0',
							is_jump => '0',
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
						write_rs_2 => '0',
						byte_length => none
					)	
				);
			end case;
	end process;

end Behavioral;

