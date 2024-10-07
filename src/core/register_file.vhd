----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:11:52 09/16/2023 
-- Design Name: 
-- Module Name:    register_file - Behavioral 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_file is
    Port ( clk : in  STD_LOGIC;
			  wr : in STD_LOGIC;
			  --! addresses
           rs1 : in  STD_LOGIC_VECTOR (4 downto 0);
           rs2 : in  STD_LOGIC_VECTOR (4 downto 0);
           rd : in  STD_LOGIC_VECTOR (4 downto 0);
			  --! input and output data
           id : in  STD_LOGIC_VECTOR (31 downto 0);
           os1 : out  STD_LOGIC_VECTOR (31 downto 0);
           os2 : out  STD_LOGIC_VECTOR (31 downto 0));
end register_file;

architecture Behavioral of register_file is

	type register_file_t is array (0 to 31) of std_logic_vector(31 downto 0);
	signal register_file: register_file_t := (others => (others => '0'));

begin

	os1 <= register_file(to_integer(unsigned(rs1)));
	os2 <= register_file(to_integer(unsigned(rs2)));
	
	write_into_destination_register : process (clk, wr)
	begin
		if rising_edge(clk) and wr = '1' then
			--! only write into register file if destination register is not x0.
			if rd /= B"00000" then
				register_file(to_integer(unsigned(rd))) <= id;
			end if;
		end if;
	end process;

end Behavioral;

