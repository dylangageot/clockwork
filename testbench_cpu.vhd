--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:17:20 09/25/2023
-- Design Name:   
-- Module Name:   C:/Users/Dylan/Documents/vhdl/riscv/testbench_cpu.vhd
-- Project Name:  riscv
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cpu
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY testbench_cpu IS
END testbench_cpu;
 
ARCHITECTURE behavior OF testbench_cpu IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cpu
    PORT(
         clk : IN  std_logic;
			  rst : in STD_LOGIC;
			  address : inout  STD_LOGIC_VECTOR (31 downto 0);
			  data : inout  STD_LOGIC_VECTOR (31 downto 0);
			  wr : inout STD_LOGIC_VECTOR(3 downto 0);
			  rd : inout STD_LOGIC;
			  ready: inout STD_LOGIC
        );
    END COMPONENT;
   
	COMPONENT data_cache
	  port (
		 clka : IN STD_LOGIC;
	    ena : IN STD_LOGIC;
		 wea : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 addra : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	  );
	END COMPONENT;
	
   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';

	--BiDirs
	signal gpio: std_logic_vector (31 downto 0) := (others => '0');
	signal rd, ready : std_logic := 'Z';
	signal data, address, previous_address : std_logic_vector (31 downto 0) := (others => 'Z');
	signal wr : std_logic_vector (3 downto 0) := (others => 'Z');

   signal mem_out : std_logic_vector(31 downto 0);
	signal enable_gpio, enable_mem, mem_ready : std_logic := '0';

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cpu PORT MAP (
		 clk => clk,
		 rst => rst,
		 address => address,
		 data => data,
		 wr => wr,
		 rd => rd,
		 ready => ready
	  );


   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

	--! GPIO
	enable_gpio <= address(31);
	ready <= '1' when enable_gpio = '1' and (rd = '1' or wr(0) = '1') else 'Z';
	data <= gpio when enable_gpio = '1' and rd = '1' else (others => 'Z');
	gpio_gen: process (clk, rst, enable_gpio, wr)
	begin
		if rst = '1' then
			gpio <= (others => '0');
		elsif rising_edge(clk) and enable_gpio = '1' and wr /= "0000" then
			gpio <= data;
		end if;
	end process;
	
	--! data cache
	enable_mem <= not(address(31));
	dc1: data_cache port map (
		clka => clk,
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
	previous_address_gen: process (clk, address, wr, enable_mem)
	begin
		if rising_edge(clk) and enable_mem = '1' then
			previous_address <= address;
		end if;
	end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rst <= '1';
      wait for 100 ns;	
		rst <= '0';
      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
