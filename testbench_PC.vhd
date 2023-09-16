--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:46:58 09/16/2023
-- Design Name:   
-- Module Name:   C:/Users/Dylan/Documents/vhdl/riscv/testbench_PC.vhd
-- Project Name:  riscv
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: PC
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
USE ieee.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
 
ENTITY testbench_PC IS
END testbench_PC;
 
ARCHITECTURE behavior OF testbench_PC IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PC
    PORT(
         clk : IN  std_logic;
         ce : IN  std_logic;
         rst : IN  std_logic;
         ci : IN  std_logic;
         input : IN  std_logic_vector(31 downto 0);
         output : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal ce : std_logic := '0';
   signal rst : std_logic := '0';
   signal ci : std_logic := '0';
   signal input : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal output : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PC PORT MAP (
          clk => clk,
          ce => ce,
          rst => rst,
          ci => ci,
          input => input,
          output => output
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		rst <= '1';
      wait for clk_period*2;	
		rst <= '0';
      wait for clk_period*2;
      --! check that counting is performed by +4 increment. 
		ce <= '1';
		for i in 0 to 24 loop
			assert output = std_logic_vector(to_unsigned(i * 4, output'length)) report "PC does not count correctly" severity failure;
			wait for clk_period;
		end loop;
		--! check that input is taken if ci is set
		ci <= '1';
		input <= X"AAAA_AAA6";
      wait for clk_period*1;
		ci <= '0';
		assert output = X"AAAA_AAA6" report "PC does not take into account input value" severity failure;
      wait for clk_period;
		assert output = X"AAAA_AAAA" report "PC does not count from latest loaded value" severity failure;
      wait;
   end process;

END;
