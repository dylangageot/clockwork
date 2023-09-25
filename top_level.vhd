----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:50:45 09/25/2023 
-- Design Name: 
-- Module Name:    top_level - Behavioral 
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

entity top_level is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           led : out  STD_LOGIC_VECTOR (7 downto 0));
end top_level;

architecture Behavioral of top_level is

component cpu is
    Port ( clk : in  STD_LOGIC;
			  neg_clk: in STD_LOGIC;
			  rst : in STD_LOGIC;
           address : out  STD_LOGIC_VECTOR (31 downto 0);
           data : inout  STD_LOGIC_VECTOR (31 downto 0);
           enable : out  STD_LOGIC;
			  wr : out STD_LOGIC
			 );
end component;

component neg_clk
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  CLK_OUT2          : out    std_logic
 );
end component;
 
	signal clk1, neg_clk1: std_logic := '0';
	signal gpio: std_logic_vector (31 downto 0) := (others => '0');

begin

	nc1: neg_clk port map (
		CLK_IN1 => clk,
		CLK_OUT1 => clk1,
		CLK_OUT2 => neg_clk1
	);
	
	cpu1: cpu port map (
		clk => clk1,
		neg_clk => neg_clk1,
		rst => rst,
		address => gpio,
		data => open,
		enable => open,
		wr => open
	);
	
	led <= gpio(7 downto 0);

end Behavioral;

