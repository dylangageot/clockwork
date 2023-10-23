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
			  id_control : out id_control_t;
			  ex_control : out ex_control_t;
			  mem_control : out mem_control_t;
			  wb_control : out wb_control_t);
end control_unit;

architecture Behavioral of control_unit is

begin

	process (opcode, funct3, funct7)
		variable id_control_var : id_control_t;
		variable ex_control_var : ex_control_t;
		variable mem_control_var : mem_control_t;
		variable wb_control_var : wb_control_t;
	begin
		--! by default, we set the control field to do nothing
		id_control_var := id_nop;
		ex_control_var := ex_nop;
		mem_control_var := mem_nop;
		wb_control_var := wb_nop;
		case opcode is
			--! lui
			when B"0110111" =>
				wb_control_var := (
					rd_input_mux => rf_u,
					write_rd => '1'
				);
			--! auipc
			when B"0010111" =>
				id_control_var.port_1 := port_1_pc;
				id_control_var.port_2 := port_2_u;
				ex_control_var.operation := op_add;
				ex_control_var.arithmetic := '0';
				wb_control_var := (
					rd_input_mux => rf_alu_output,
					write_rd => '1'
				);
			--! jal (jump and link)
			when B"1101111" =>
				id_control_var.pc_immd := pc_immd_j;
				ex_control_var.write_pc := '1';
				ex_control_var.is_jump := '1';
				ex_control_var.address_computation_mux := pc_id;
				wb_control_var := (
					rd_input_mux => rf_pc_4,
					write_rd => '1'
				);
			--! jalr (relative to rs1)
			when B"1100111" =>
				id_control_var.read_rs1 := '1';
				id_control_var.port_1 := port_1_rs_1;
				id_control_var.port_2 := port_2_i;
				ex_control_var.write_pc := '1';
				ex_control_var.is_jump := '1';
				ex_control_var.address_computation_mux := pc_alu;
				ex_control_var.operation := op_add;
				ex_control_var.arithmetic := '0';
				wb_control_var := (
					rd_input_mux => rf_pc_4,
					write_rd => '1'
				);
			--! branch
			when B"1100011" =>
				id_control_var.read_rs1 := '1';
				id_control_var.read_rs2 := '1';
				id_control_var.pc_immd := pc_immd_b;
				id_control_var.port_1 := port_1_rs_1;
				id_control_var.port_2 := port_2_rs_2;
				ex_control_var.write_pc := '1';
				ex_control_var.address_computation_mux := pc_id;
				case funct3 is
					--! beq
					when b"000" =>
						ex_control_var.negate_alu_output := '0';
						ex_control_var.operation := op_eq;
					--! bne
					when b"001" =>
						ex_control_var.negate_alu_output := '1';
						ex_control_var.operation := op_eq;
					--! blt
					when b"100" =>
						ex_control_var.negate_alu_output := '0';
						ex_control_var.operation := op_slt;
					--! bge
					when b"101" =>
						ex_control_var.negate_alu_output := '1';
						ex_control_var.operation := op_slt;
					--! bltu
					when b"110" =>
						ex_control_var.negate_alu_output := '0';
						ex_control_var.operation := op_sltu;
					--! bgeu
					when b"111" =>
						ex_control_var.negate_alu_output := '1';
						ex_control_var.operation := op_sltu;
					when others =>
						--! control_field_var := nop;
				end case;
			--! load
			when B"0000011" =>
				id_control_var.read_rs1 := '1';
				id_control_var.port_1 := port_1_rs_1;
				id_control_var.port_2 := port_2_i;
				ex_control_var.operation := op_add;
				ex_control_var.arithmetic := '0';
				mem_control_var.read_mem := '1';
				mem_control_var.wait_mem := '1';
				wb_control_var.write_rd := '1';
				case funct3 is
					--! lb
					when B"000" =>
						wb_control_var.rd_input_mux := rf_mem_byte;
					--! lh
					when B"001" =>
						wb_control_var.rd_input_mux := rf_mem_half;
					--! lw
					when B"010" =>
						wb_control_var.rd_input_mux := rf_mem_word;
					--! lbu
					when B"100" =>
						wb_control_var.rd_input_mux := rf_mem_unsigned_byte;
					--! lhu
					when B"101" =>
						wb_control_var.rd_input_mux := rf_mem_unsigned_half;
					when others =>
						--!
				end case;
			--! store 
			when B"0100011" =>
				id_control_var.read_rs1 := '1';
				id_control_var.read_rs2 := '1';
				id_control_var.port_1 := port_1_rs_1;
				id_control_var.port_2 := port_2_s;
				ex_control_var.operation := op_add;
				ex_control_var.arithmetic := '0';
				mem_control_var.wait_mem := '1';
				mem_control_var.write_mem := '1';
				case funct3 is
						--! sb
						when B"000" =>
							mem_control_var.byte_length := byte;
						--! sh
						when B"001" =>
							mem_control_var.byte_length := half;
						--! sw
						when B"010" =>
							mem_control_var.byte_length := word;
					when others =>
						--!
				end case;
			--! add(i), slt(i)...
			when B"0010011" | B"0110011" =>
				if opcode(5) = '1' then
					id_control_var.read_rs1 := '1';
					id_control_var.read_rs2 := '1';
					id_control_var.port_1 := port_1_rs_1;
					id_control_var.port_2 := port_2_rs_2;
				else
					id_control_var.read_rs1 := '1';
					id_control_var.port_1 := port_1_rs_1;
					id_control_var.port_2 := port_2_i;
				end if;
				ex_control_var.arithmetic := '0';
				wb_control_var.write_rd := '1';
				wb_control_var.rd_input_mux := rf_alu_output;
				case funct3 is
					-- ! add(i), sub
					when b"000" =>
						ex_control_var.operation := op_add;
						if opcode(5) = '1' then
							ex_control_var.arithmetic := funct7(5);
						end if;
					-- ! slt(i)
					when b"010" =>
						ex_control_var.operation := op_slt;
					-- ! sltu(i)
					when b"011" =>
						ex_control_var.operation := op_sltu;
					-- ! xor(i)
					when b"100" =>
						ex_control_var.operation  := op_xor;
					-- ! or(i)
					when b"110" =>
						ex_control_var.operation  := op_or;
					-- ! and(i)
					when b"111" =>
						ex_control_var.operation  := op_and;
					--! sll(i)
					when "001" =>
						ex_control_var.operation  := op_sll;
					--! srl(i) & sra(i)
					when "101" =>
						ex_control_var.operation  := op_srl;
						ex_control_var.arithmetic := funct7(5);
					when others =>
						--!
				end case;
			when others =>
				--!
			end case;
			id_control <= id_control_var;
			ex_control <= ex_control_var;
			mem_control <= mem_control_var;
			wb_control <= wb_control_var;
	end process;

end Behavioral;

