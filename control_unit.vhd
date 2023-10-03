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
		variable control_field_var : control_field_t;
	begin
		--! by default, we set the control field to do nothing
		control_field_var := nop;
		case opcode is
			--! lui
			when B"0110111" =>
				control_field_var.register_file := (
					write_rd => '1',
					input_mux => rf_u
				);
			--! auipc
			when B"0010111" =>
				control_field_var.alu := (
					operation => op_add,
					arithmetic => '0',
					port_1 => port_1_pc,
					port_2 => port_2_u
				);
				control_field_var.register_file := (
					write_rd => '1',
					input_mux => rf_alu_output
				);
			--! jal (jump and link)
			when B"1101111" =>
				control_field_var.program_counter := (
					write_pc => '1',
					is_jump => '1',
					negate_alu_output => '0',
					address_computation_mux => pc_jump
				);
				control_field_var.register_file := (
					write_rd => '1',
					input_mux => rf_pc_4
				);
			--! jalr (relative to rs1)
			when B"1100111" =>
				control_field_var.program_counter := (
					write_pc => '1',
					is_jump => '1',
					negate_alu_output => '0',
					address_computation_mux => pc_alu
				);
				control_field_var.alu := (
					operation => op_add,
					arithmetic => '0',
					port_1 => port_1_rs_1,
					port_2 => port_2_i
				);
				control_field_var.register_file := (
					write_rd => '1',
					input_mux => rf_pc_4
				);
			--! branch
			when B"1100011" =>
				control_field_var.program_counter := (
					write_pc => '1',
					is_jump => '0',
					negate_alu_output => '0',
					address_computation_mux => pc_branch
				);
				control_field_var.alu := (
					operation => op_eq,
					arithmetic => '0',
					port_1 => port_1_rs_1,
					port_2 => port_2_rs_2
				);
				case funct3 is
					--! beq
					when b"000" =>
						control_field_var.program_counter.negate_alu_output := '0';
						control_field_var.alu.operation := op_eq;
					--! bne
					when b"001" =>
						control_field_var.program_counter.negate_alu_output := '1';
						control_field_var.alu.operation := op_eq;
					--! blt
					when b"100" =>
						control_field_var.program_counter.negate_alu_output := '0';
						control_field_var.alu.operation := op_slt;
					--! bge
					when b"101" =>
						control_field_var.program_counter.negate_alu_output := '1';
						control_field_var.alu.operation := op_slt;
					--! bltu
					when b"110" =>
						control_field_var.program_counter.negate_alu_output := '0';
						control_field_var.alu.operation := op_sltu;
					--! bgeu
					when b"111" =>
						control_field_var.program_counter.negate_alu_output := '1';
						control_field_var.alu.operation := op_sltu;
					when others =>
						control_field_var := nop;
				end case;
			--! load store
			when B"0000011" =>
				case funct3 is
						--! lb
						when B"000" =>
						control_field_var :=   (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_mem_byte
							),
							alu => (
								operation => op_add,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_i
							),
							memory => (
								write_rs_2 => '0',
								byte_length => byte
							)	
						);
						--! lh
						when B"001" =>
						control_field_var :=   (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_mem_half
							),
							alu => (
								operation => op_add,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_i
							),
							memory => (
								write_rs_2 => '0',
								byte_length => half
							)	
						);
						--! lw
						when B"010" =>
						control_field_var :=   (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_mem_word
							),
							alu => (
								operation => op_add,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_i
							),
							memory => (
								write_rs_2 => '0',
								byte_length => word
							)	
						);
						--! lbu
						when B"100" =>
						control_field_var :=  (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_mem_unsigned_byte
							),
							alu => (
								operation => op_add,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_i
							),
							memory => (
								write_rs_2 => '0',
								byte_length => byte
							)	
						);
					--! lhu
					when B"101" =>
						control_field_var :=  (
							program_counter => (
									write_pc => '0',
									is_jump => '0',
									negate_alu_output => '0',
									address_computation_mux => pc_alu
							),
							register_file => (
								write_rd => '1',
								input_mux => rf_mem_unsigned_half
							),
							alu => (
								operation => op_add,
								arithmetic => '0',
								port_1 => port_1_rs_1,
								port_2 => port_2_i
							),
							memory => (
								write_rs_2 => '0',
								byte_length => half
							)	
						);
					when others =>
						control_field_var := nop;
				end case;
			
			--! store 
			when B"0100011" =>
				case funct3 is
						--! sb
						when B"000" =>
							control_field_var := (
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
									port_2 => port_2_s
								),
								memory => (
									write_rs_2 => '1',
									byte_length => byte
								)	
							);
						--! sh
						when B"001" =>
							control_field_var := (
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
									port_2 => port_2_s
								),
								memory => (
									write_rs_2 => '1',
									byte_length => half
								)	
							);
						--! sw
						when B"010" =>
							control_field_var := (
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
									port_2 => port_2_s
								),
								memory => (
									write_rs_2 => '1',
									byte_length => word
								)	
							);
					when others =>
						control_field_var := nop;
				end case;
			--! addi, slti...
			when B"0010011" =>
				case funct3 is
					-- ! addi
					when b"000" =>
						control_field_var := (
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
						control_field_var := (
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
						control_field_var := (
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
						control_field_var := (
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
						control_field_var := (
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
						control_field_var := (
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
						control_field_var := (
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
							control_field_var := (
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
						control_field_var := nop;
				end case;
			--! add, slt...
			when B"0110011" =>
				case funct3 is
					-- ! add or sub
					when b"000" =>
						control_field_var := (
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
						control_field_var := (
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
						control_field_var := (
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
						control_field_var :=  (
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
						control_field_var :=  (
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
						control_field_var := (
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
						control_field_var :=  (
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
						control_field_var := (
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
						control_field_var := nop;
				end case;
			when others =>
				control_field_var := nop;
			end case;
			control_field <= control_field_var;
	end process;

end Behavioral;

