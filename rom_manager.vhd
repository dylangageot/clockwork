----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:05:29 10/30/2023 
-- Design Name: 
-- Module Name:    rom_manager - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rom_manager is
	 Generic(
		initial_threshold : integer := 12;
		steady_threshold : integer := 3
	 );
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  enable : in STD_LOGIC;
           rd : in  STD_LOGIC;
           address : in  STD_LOGIC_VECTOR (26 downto 2);
           ready : out  STD_LOGIC;
			  output : out STD_LOGIC_VECTOR (31 downto 0);
           MemOE : out  STD_LOGIC;
           FlashCS : out  STD_LOGIC;
           FlashRp : out  STD_LOGIC;
           MemAddr : out  STD_LOGIC_VECTOR (26 downto 1);
           MemDB : in  STD_LOGIC_VECTOR (15 downto 0)
	 );
end rom_manager;

architecture Behavioral of rom_manager is

	type fsm_state_t is (idle, wait_lower_nibble, wait_upper_nibble, available);
	signal current_state, next_state : fsm_state_t := idle;

	signal current_address : std_logic_vector (26 downto 1);
	signal lower_nibble, upper_nibble : std_logic_vector (15 downto 0);

begin

	future_state : process (rst, clk, enable)
		variable counter : integer := 0;
	begin
		if rst = '1' then
			current_state <= idle;
		elsif rising_edge(clk) and enable = '1' then
			case current_state is
				when idle =>
					if rd = '1' then
						current_state <= wait_lower_nibble;
						current_address <= address & '0';
						counter := 0;
					end if;
				when wait_lower_nibble =>
					counter := counter + 1;
					if counter > initial_threshold then
						current_state <= wait_upper_nibble;
						current_address(1) <= '1';
						lower_nibble <= MemDB;
						counter := 0;
					end if;
				when wait_upper_nibble =>
					counter := counter + 1;
					if counter > steady_threshold then
						current_state <= available;
						upper_nibble <= MemDB;
					end if;
				when available =>
					if rd = '1' and address /= current_address(26 downto 2) then
						current_state <= wait_lower_nibble;
						current_address <= address & '0';
						counter := 0;
					elsif rd = '0' then
						current_state <= idle;
					end if;
			end case;
		end if;
	end process;
	
	ready_gen : process (address, current_address, current_state)
	begin
		if current_state = available and current_address(26 downto 2) = address then
			ready <= '1';
		else
			ready <= '0';
		end if;
	end process;

	MemAddr <= current_address;
	FlashCS <= '0';
	FlashRp <= '1';
	MemOE <= '0';
	output <=  upper_nibble & lower_nibble;
	
end Behavioral;

