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
           funct6 : in  STD_LOGIC_VECTOR (6 downto 0);
           control_field : out  control_field_t);
end control_unit;

architecture Behavioral of control_unit is

begin

	process (opcode, funct3, funct6)
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

