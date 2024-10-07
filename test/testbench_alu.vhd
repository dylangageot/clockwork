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
USE work.control_field.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY testbench_alu IS
END testbench_alu;
 
ARCHITECTURE behavior OF testbench_alu IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT alu
    PORT(
         operation : IN  alu_operation_t;
         arithmetic : IN  std_logic;
         input_1 : IN  std_logic_vector(31 downto 0);
         input_2 : IN  std_logic_vector(31 downto 0);
         output : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal operation : alu_operation_t := op_add;
   signal arithmetic : std_logic := '0';
   signal input_1 : std_logic_vector(31 downto 0) := (others => '0');
   signal input_2 : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal output : std_logic_vector(31 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu PORT MAP (
          operation => operation,
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
		operation <= op_add;
		arithmetic <= '0';
		input_1 <= X"0000_FFFF";
		input_2 <= X"0000_0001";
		wait for 10 ns;
		assert output = X"0001_0000" report "add failed" severity failure;
		wait for 10 ns;
		
		-- test sub
		operation <= op_add;
		arithmetic <= '1';
		input_1 <= X"0000_FFFF";
		input_2 <= X"0000_0001";
		wait for 10 ns;
		assert output = X"0000_FFFE" report "sub failed" severity failure;		
		wait for 10 ns;
		
		-- test sll
		operation <= op_sll;
		arithmetic <= '0';
		input_1 <= X"0000_FFFF";
		input_2 <= X"0000_0001";
		wait for 10 ns;
		assert output = X"0001_FFFE" report "sll failed" severity failure;
		wait for 10 ns;
		
		-- test slt
		operation <= op_slt;
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
		operation <= op_sltu;
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
		operation <= op_xor;
		arithmetic <= '0';
		input_1 <= X"0000_FFFF";
		input_2 <= X"FFFF_FFFF";
		wait for 10 ns;
		assert output = X"FFFF_0000" report "xor failed" severity failure;
		wait for 10 ns;
		
		-- test srl
		operation <= op_srl;
		arithmetic <= '0';
		input_1 <= X"0000_FFFF";
		input_2 <= X"0000_0001";
		wait for 10 ns;
		assert output = X"0000_7FFF" report "srl failed" severity failure;
		wait for 10 ns;
		
		-- test sra
		operation <= op_srl;
		arithmetic <= '1';
		input_1 <= X"8000_FFFF";
		input_2 <= X"0000_0001";
		wait for 10 ns;
		assert output = X"C000_7FFF" report "sra failed" severity failure;
		wait for 10 ns;
		
		-- test or
		operation <= op_or;
		arithmetic <= '0';
		input_1 <= X"A0A0_A0A0";
		input_2 <= X"0505_0505";
		wait for 10 ns;
		assert output = X"A5A5_A5A5" report "or failed" severity failure;
		wait for 10 ns;
				
		-- test and
		operation <= op_and;
		arithmetic <= '0';
		input_1 <= X"A0A0_A0A0";
		input_2 <= X"FFFF_0000";
		wait for 10 ns;
		assert output = X"A0A0_0000" report "and failed" severity failure;
		wait for 10 ns;
		
	
      wait;
   end process;

END;
