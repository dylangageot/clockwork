----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:54:14 09/17/2023 
-- Design Name: 
-- Module Name:    alu - Behavioral 
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

entity alu is
    Port ( operation: in alu_operation_t;
			  arithmetic : in STD_LOGIC;
			  input_1 : in  STD_LOGIC_VECTOR (31 downto 0);
           input_2 : in  STD_LOGIC_VECTOR (31 downto 0);
           output : out  STD_LOGIC_VECTOR (31 downto 0));
end alu;

architecture Behavioral of alu is
begin

	process (operation, arithmetic, input_1, input_2)
	begin
		case operation is
			when op_add =>
				--! it is an addition!
				if arithmetic = '0' then
					output <= std_logic_vector(unsigned(input_1) + unsigned(input_2));
				--! it is a sub operation!
				else
					output <= std_logic_vector(unsigned(input_1) - unsigned(input_2));
				end if;
			when op_sll =>
				output <= std_logic_vector(shift_left(unsigned(input_1), to_integer(unsigned(input_2(4 downto 0)))));
			when op_slt =>
				if signed(input_1) < signed(input_2) then
					output <= (0 => '1', others => '0');
				else
					output <= (others => '0');
				end if;
			when op_sltu =>
				if unsigned(input_1) < unsigned(input_2) then
					output <= (0 => '1', others => '0');
				else
					output <= (others => '0');
				end if;
			when op_xor =>
				output <= input_1 xor input_2;
			when op_srl =>
				--! it is a srl operation!
				if arithmetic = '0' then
					output <= std_logic_vector(shift_right(unsigned(input_1), to_integer(unsigned(input_2(4 downto 0)))));
				--! it is a sra operation!
				else
					output <= std_logic_vector(shift_right(signed(input_1), to_integer(unsigned(input_2(4 downto 0)))));
				end if;
			when op_or =>
				output <= input_1 or input_2;
			when op_and =>
				output <= input_1 and input_2;
			when others =>
            output <= (others => '0');
		end case;
	end process;

end Behavioral;

