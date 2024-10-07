--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:33:56 11/06/2023
-- Design Name:   
-- Module Name:   C:/Users/Dylan/Documents/vhdl/riscv/testbench_i_cache.vhd
-- Project Name:  riscv
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: i_cache
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
USE ieee.numeric_std.ALL;
 
ENTITY testbench_i_cache IS
END testbench_i_cache;
 
ARCHITECTURE behavior OF testbench_i_cache IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT i_cache
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         enable : IN  std_logic;
         iaddress : IN  std_logic_vector(31 downto 2);
         idata : OUT  std_logic_vector(31 downto 0);
         iready : OUT  std_logic;
         memaddress : OUT  std_logic_vector(31 downto 0);
         memdata : IN  std_logic_vector(31 downto 0);
         memready : IN  std_logic
        );
    END COMPONENT;
    
   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal enable : std_logic := '0';
   signal iaddress : std_logic_vector(31 downto 2) := (others => '0');
   signal memdata : std_logic_vector(31 downto 0) := (others => '0');
   signal memready : std_logic := '0';

 	--Outputs
   signal idata : std_logic_vector(31 downto 0);
   signal iready : std_logic;
   signal memaddress : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: i_cache PORT MAP (
          clk => clk,
          rst => rst,
          enable => enable,
          iaddress => iaddress,
          idata => idata,
          iready => iready,
          memaddress => memaddress,
          memdata => memdata,
          memready => memready
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
		rst <= '1';
      wait for 100 ns;	
		rst <= '0';
		enable <= '1';
      wait for clk_period*10;

      -- insert stimulus here 
		iaddress(4 downto 2) <= "010";
		iaddress(10 downto 5) <= "000101";
		iaddress(15 downto 11) <= "00000";
		iaddress(31 downto 16) <= X"ABAB";

		for k in 0 to 7 loop
			memready <= '0';
			wait for clk_period * 2;
			memdata <= std_logic_vector(to_unsigned(k, 32));
			wait for clk_period * 1;
			memready <= '1';
			wait for clk_period;
		end loop;
		memready <= '0';
	
		wait for clk_period*4;
		iaddress(4 downto 2) <= "010";
		iaddress(10 downto 5) <= "000110";
		iaddress(15 downto 11) <= "00000";
		iaddress(31 downto 16) <= X"BBBB";

		for k in 0 to 7 loop
			memready <= '0';
			wait for clk_period * 2;
			memdata <= std_logic_vector(to_unsigned(2*k, 32));
			wait for clk_period * 1;
			memready <= '1';
			wait for clk_period;
		end loop;
		memready <= '0';

		wait for clk_period*4;
		iaddress(4 downto 2) <= "010";
		iaddress(10 downto 5) <= "000101";
		iaddress(15 downto 11) <= "00000";
		iaddress(31 downto 16) <= X"ABAB";

		for k in 0 to 7 loop
			memready <= '0';
			wait for clk_period * 2;
			memdata <= std_logic_vector(to_unsigned(2*k, 32));
			wait for clk_period * 1;
			memready <= '1';
			wait for clk_period;
		end loop;
		memready <= '0';


      wait;
   end process;

END;
