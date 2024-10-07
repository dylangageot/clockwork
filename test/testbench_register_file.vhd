--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:30:34 09/16/2023
-- Design Name:   
-- Module Name:   C:/Users/Dylan/Documents/vhdl/riscv/testbench_register_file.vhd
-- Project Name:  riscv
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: register_file
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
 
ENTITY testbench_register_file IS
END testbench_register_file;
 
ARCHITECTURE behavior OF testbench_register_file IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT register_file
    PORT(
         clk : IN  std_logic;
         wr : IN  std_logic;
         rs1 : IN  std_logic_vector(4 downto 0);
         rs2 : IN  std_logic_vector(4 downto 0);
         rd : IN  std_logic_vector(4 downto 0);
         id : IN  std_logic_vector(31 downto 0);
         os1 : OUT  std_logic_vector(31 downto 0);
         os2 : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal wr : std_logic := '0';
   signal rs1 : std_logic_vector(4 downto 0) := (others => '0');
   signal rs2 : std_logic_vector(4 downto 0) := (others => '0');
   signal rd : std_logic_vector(4 downto 0) := (others => '0');
   signal id : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal os1 : std_logic_vector(31 downto 0);
   signal os2 : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: register_file PORT MAP (
          clk => clk,
          wr => wr,
          rs1 => rs1,
          rs2 => rs2,
          rd => rd,
          id => id,
          os1 => os1,
          os2 => os2
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
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
		--! write to x2
		rd <= B"00010";
		wr <= '1';
		id <= X"ABAB_BABA";
      wait for clk_period;
		wr <= '0';
		rs1 <= B"00010";
		rs2 <= B"00010";
      wait for clk_period;
		assert os1 = X"ABAB_BABA" report "Written value to register x2 could not be read from rs1" severity failure;
		assert os2 = X"ABAB_BABA" report "Written value to register x2 could not be read from rs2" severity failure;
      wait;
   end process;

END;
