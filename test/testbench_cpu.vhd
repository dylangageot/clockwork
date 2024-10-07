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
		Port ( 
			clk : in  STD_LOGIC;
			rst : in STD_LOGIC;
			enable : in STD_LOGIC;
			daddress : inout  STD_LOGIC_VECTOR (31 downto 0);
			ddata : inout  STD_LOGIC_VECTOR (31 downto 0);
			dwr : inout STD_LOGIC_VECTOR(3 downto 0);
			drd : inout STD_LOGIC;
			dready: inout STD_LOGIC;
			iaddress : out STD_LOGIC_VECTOR (31 downto 0);
			idata : in STD_LOGIC_VECTOR (31 downto 0);
			iready: in STD_LOGIC
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
	
	component instruction_cache is
		Port (
			clka : IN STD_LOGIC;
			ena : IN STD_LOGIC;
			addra : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	end component;
	
   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
	signal enable: std_logic := '1';

	--BiDirs
	signal gpio: std_logic_vector (31 downto 0) := (others => '0');
	signal drd, dready : std_logic := 'Z';
	signal ddata, daddress, previous_daddress : std_logic_vector (31 downto 0) := (others => 'Z');
	signal dwr : std_logic_vector (3 downto 0) := (others => 'Z');
	
	signal idata, iaddress, previous_iaddress : std_logic_vector (31 downto 0) := (others => 'Z');
	signal iready : std_logic := '0';

   signal mem_out : std_logic_vector(31 downto 0);
	signal enable_gpio, enable_mem, mem_ready : std_logic := '0';

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cpu PORT MAP (
		 clk => clk,
		 rst => rst,
		 enable => enable,
		 daddress => daddress,
		 ddata => ddata,
		 dwr => dwr,
		 drd => drd,
		 dready => dready,
		 iaddress => iaddress,
		 idata => idata,
		 iready => iready
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
	enable_gpio <= daddress(31);
	dready <= '1' when enable_gpio = '1' and (drd = '1' or dwr(0) = '1') else 'Z';
	ddata <= gpio when enable_gpio = '1' and drd = '1' else (others => 'Z');
	gpio_gen: process (clk, rst, enable_gpio, dwr)
	begin
		if rst = '1' then
			gpio <= (others => '0');
		elsif rising_edge(clk) and enable_gpio = '1' and dwr /= "0000" then
			gpio <= ddata;
		end if;
	end process;
	
	--! data cache
	enable_mem <= not(daddress(31));
	dc1: data_cache port map (
		clka => clk,
		ena => enable_mem,
		wea => dwr,
		addra => daddress,
		dina => ddata,
		douta => mem_out
	);
	
	dready <= mem_ready when enable_mem = '1' and (dwr(0) = '1' or drd = '1') else 'Z';
	ddata <= mem_out when enable_mem = '1' and drd = '1' else (others => 'Z');
	
	mem_ready_gen: process (dwr, drd, daddress, previous_daddress)
	begin
		if dwr(0) = '1' then
			mem_ready <= '1';
		elsif drd = '1' and previous_daddress = daddress then
			mem_ready <= '1';
		else
			mem_ready <= '0';
		end if;
	end process;
	
	--! the memory shall throw a non-ready state once a new address is requested
	previous_daddress_gen: process (clk, daddress, dwr, enable_mem)
	begin
		if rising_edge(clk) and enable_mem = '1' then
			previous_daddress <= daddress;
		end if;
	end process;

	ic1: instruction_cache port map (
		clka => clk,
		ena => enable,
		addra => iaddress,
		douta => idata
	);
	
	iready_gen: process (iaddress, previous_iaddress)
	begin
		if previous_iaddress = iaddress then
			iready <= '1';
		else
			iready <= '0';
		end if;
	end process;
	
	previous_iaddress_gen: process (rst, clk, iaddress)
	begin
		if rst = '1' then
			previous_iaddress <= (others => '0');
		elsif rising_edge(clk) then
			previous_iaddress <= iaddress;
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
