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
				  rst : in STD_LOGIC;
				  address : inout  STD_LOGIC_VECTOR (31 downto 0);
				  data : inout  STD_LOGIC_VECTOR (31 downto 0);
				  wr : inout STD_LOGIC_VECTOR(3 downto 0);
				  rd : inout STD_LOGIC;
				  ready: inout STD_LOGIC
				 );
	end component;

	component clock_gen
	port
	(
	  CLK_IN1           : in     std_logic;
	  CLK_OUT1          : out    std_logic
	 );
	end component;

	COMPONENT data_cache
	  PORT (
		 clka : IN STD_LOGIC;
		 ena : IN STD_LOGIC;
		 wea : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 addra : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	  );
	END COMPONENT;

	signal clk_40m: std_logic := '0';
	signal gpio: std_logic_vector (31 downto 0) := (others => '0');
	signal rd, ready : std_logic := 'Z';
	signal data, address, previous_address : std_logic_vector (31 downto 0) := (others => 'Z');
	signal wr : std_logic_vector (3 downto 0) := (others => 'Z');

   signal mem_out : std_logic_vector(31 downto 0);
	signal enable_gpio, enable_mem, mem_ready : std_logic := '0';

begin
	
	cpu1: cpu port map (
		clk => clk_40m,
		rst => rst,
		address => address,
		data => data,
		wr => wr,
		rd => rd,
		ready => ready
	);
	
	cg1: clock_gen port map (
		CLK_IN1 => clk,
		CLK_OUT1 => clk_40m
	);
	
	led <= gpio(7 downto 0);

	--! GPIO
	enable_gpio <= address(31);
	ready <= '1' when enable_gpio = '1' and (rd = '1' or wr(0) = '1') else 'Z';
	data <= gpio when enable_gpio = '1' and rd = '1' else (others => 'Z');
	gpio_gen: process (clk_40m, rst, enable_gpio, wr)
	begin
		if rst = '1' then
			gpio <= (others => '0');
		elsif rising_edge(clk_40m) and enable_gpio = '1' and wr /= "0000" then
			gpio <= data;
		end if;
	end process;
	
	--! data cache
	enable_mem <= not(address(31));
	dc1: data_cache port map (
		clka => clk_40m,
		ena => enable_mem,
		wea => wr,
		addra => address,
		dina => data,
		douta => mem_out
	);
	
	ready <= mem_ready when enable_mem = '1' and (wr(0) = '1' or rd = '1') else 'Z';
	data <= mem_out when enable_mem = '1' and rd = '1' else (others => 'Z');
	
	mem_ready_gen: process (wr, rd, address, previous_address)
	begin
		if wr(0) = '1' then
			mem_ready <= '1';
		elsif rd = '1' and previous_address = address then
			mem_ready <= '1';
		else
			mem_ready <= '0';
		end if;
	end process;
	--! the memory shall throw a non-ready state once a new address is requested
	previous_address_gen: process (clk_40m, address, wr, enable_mem)
	begin
		if rising_edge(clk_40m) and enable_mem = '1' then
			previous_address <= address;
		end if;
	end process;
	
	

end Behavioral;

