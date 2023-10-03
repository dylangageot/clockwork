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
   signal data : std_logic_vector(31 downto 0);
   signal address : std_logic_vector(31 downto 0);
   signal wr : std_logic_vector(3 downto 0);
   signal rd, ready, rd_ready : std_logic := 'Z';


   signal mem_out : std_logic_vector(31 downto 0);

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


	--! data cache
	dc1: data_cache port map (
		clka => clk,
		wea => wr,
		addra => address,
		dina => data,
		douta => mem_out
	);
	data <= mem_out when rd_ready = '1' else (others => 'Z');
	ready <= rd_ready or wr(0);
	
	rd_ready_gen: process (clk)
	begin
		if rising_edge(clk) then
			rd_ready <= rd;
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
