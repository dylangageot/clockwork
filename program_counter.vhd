----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:22:23 09/16/2023 
-- Design Name: 
-- Module Name:    PC - Behavioral 
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

entity program_counter is
    Port ( clk : in  STD_LOGIC;
           ce : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  ci : in STD_LOGIC;
			  input : in  STD_LOGIC_VECTOR (31 downto 0);
           output : out  STD_LOGIC_VECTOR (31 downto 0));
end program_counter;

architecture Behavioral of program_counter is

	signal pc_counter: UNSIGNED(31 downto 0) := (others => '0');

begin

process (clk, ce, rst)
begin
	if rst = '1' then
		pc_counter <= (others => '0');
	elsif rising_edge(clk) and ce = '1' then
		if ci = '1' then
			pc_counter <= UNSIGNED(input);
		else
			pc_counter <= pc_counter + 4;
		end if;
	end if;
end process;

output <= std_logic_vector(pc_counter);

end Behavioral;

