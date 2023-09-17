--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:45:41 09/17/2023
-- Design Name:   
-- Module Name:   C:/Users/Dylan/Documents/vhdl/riscv/testbench_alu.vhd
-- Project Name:  riscv
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: alu
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
 
ENTITY testbench_alu IS
END testbench_alu;
 
ARCHITECTURE behavior OF testbench_alu IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT alu
    PORT(
         op : IN  std_logic_vector(2 downto 0);
         arithmetic : IN  std_logic;
         input_1 : IN  std_logic_vector(31 downto 0);
         input_2 : IN  std_logic_vector(31 downto 0);
         output : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal op : std_logic_vector(2 downto 0) := (others => '0');
   signal arithmetic : std_logic := '0';
   signal input_1 : std_logic_vector(31 downto 0) := (others => '0');
   signal input_2 : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal output : std_logic_vector(31 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu PORT MAP (
          op => op,
          arithmetic => arithmetic,
          input_1 => input_1,
          input_2 => input_2,
          output => output
        );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      -- insert stimulus here 
		-- test add
		op <= "000";
		arithmetic <= '0';
		input_1 <= X"0000_FFFF";
		input_2 <= X"0000_0001";
		wait for 10 ns;
		assert output = X"0001_0000" report "add failed" severity failure;
		wait for 10 ns;
		
		-- test sub
		op <= "000";
		arithmetic <= '1';
		input_1 <= X"0000_FFFF";
		input_2 <= X"0000_0001";
		wait for 10 ns;
		assert output = X"0000_FFFE" report "sub failed" severity failure;		
		wait for 10 ns;
		
		-- test sll
		op <= "001";
		arithmetic <= '0';
		input_1 <= X"0000_FFFF";
		input_2 <= X"0000_0001";
		wait for 10 ns;
		assert output = X"0001_FFFE" report "sll failed" severity failure;
		wait for 10 ns;
		
		-- test slt
		op <= "010";
		arithmetic <= '0';
		input_1 <= X"FFFF_FFFF";
		input_2 <= X"FFFF_FFFF";
		wait for 10 ns;
		assert output = X"0000_0000" report "slt failed" severity failure;
		wait for 10 ns;
		input_1 <= X"FFFF_FFFF";
		input_2 <= X"0000_FFFF";
		wait for 10 ns;
		assert output = X"0000_0001" report "slt failed" severity failure;
		wait for 10 ns;
		
		-- test sltu
		op <= "011";
		arithmetic <= '0';
		input_1 <= X"FFFF_FFFF";
		input_2 <= X"0000_FFFF";
		wait for 10 ns;
		assert output = X"0000_0000" report "sltu failed" severity failure;
		wait for 10 ns;
		input_1 <= X"0000_FFFE";
		input_2 <= X"0000_FFFF";
		wait for 10 ns;
		assert output = X"0000_0001" report "sltu failed" severity failure;
		wait for 10 ns;
		
		-- test xor
		op <= "100";
		arithmetic <= '0';
		input_1 <= X"0000_FFFF";
		input_2 <= X"FFFF_FFFF";
		wait for 10 ns;
		assert output = X"FFFF_0000" report "xor failed" severity failure;
		wait for 10 ns;
		
		-- test srl
		op <= "101";
		arithmetic <= '0';
		input_1 <= X"0000_FFFF";
		input_2 <= X"0000_0001";
		wait for 10 ns;
		assert output = X"0000_7FFF" report "srl failed" severity failure;
		wait for 10 ns;
		
		-- test sra
		op <= "101";
		arithmetic <= '1';
		input_1 <= X"8000_FFFF";
		input_2 <= X"0000_0001";
		wait for 10 ns;
		assert output = X"C000_7FFF" report "sra failed" severity failure;
		wait for 10 ns;
		
		-- test or
		op <= "110";
		arithmetic <= '0';
		input_1 <= X"A0A0_A0A0";
		input_2 <= X"0505_0505";
		wait for 10 ns;
		assert output = X"A5A5_A5A5" report "or failed" severity failure;
		wait for 10 ns;
				
		-- test and
		op <= "111";
		arithmetic <= '0';
		input_1 <= X"A0A0_A0A0";
		input_2 <= X"FFFF_0000";
		wait for 10 ns;
		assert output = X"A0A0_0000" report "and failed" severity failure;
		wait for 10 ns;
		
	
      wait;
   end process;

END;
