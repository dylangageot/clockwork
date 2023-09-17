----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:24:48 09/17/2023 
-- Design Name: 
-- Module Name:    cpu - Behavioral 
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
use work.control_field.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is
    Port ( clk : in  STD_LOGIC;
			  rst : in STD_LOGIC;
           address : out  STD_LOGIC_VECTOR (31 downto 0);
           data : inout  STD_LOGIC_VECTOR (31 downto 0);
           enable : out  STD_LOGIC;
			  wr : out STD_LOGIC
			 );
end cpu;

architecture Behavioral of cpu is

	component alu is
		 Port ( op: in STD_LOGIC_VECTOR(2 downto 0);
				  arithmetic : in STD_LOGIC;
				  input_1 : in  STD_LOGIC_VECTOR (31 downto 0);
				  input_2 : in  STD_LOGIC_VECTOR (31 downto 0);
				  output : out  STD_LOGIC_VECTOR (31 downto 0));
	end component;
	
	
	component program_counter is
    Port ( clk : in  STD_LOGIC;
           ce : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  ci : in STD_LOGIC;
			  input : in  STD_LOGIC_VECTOR (31 downto 0);
           output : out  STD_LOGIC_VECTOR (31 downto 0));
	end component;

	component register_file is
		 Port ( clk : in  STD_LOGIC;
				  wr : in STD_LOGIC;
				  rs1 : in  STD_LOGIC_VECTOR (4 downto 0);
				  rs2 : in  STD_LOGIC_VECTOR (4 downto 0);
				  rd : in  STD_LOGIC_VECTOR (4 downto 0);
				  id : in  STD_LOGIC_VECTOR (31 downto 0);
				  os1 : out  STD_LOGIC_VECTOR (31 downto 0);
				  os2 : out  STD_LOGIC_VECTOR (31 downto 0));
	end component;
	
	component instruction_cache is
	  port (
		 clka : IN STD_LOGIC;
		 addra : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	  );
	end component;
	
	component data_cache
	  port (
		 clka : IN STD_LOGIC;
		 wea : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 addra : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	  );
	end component;
	
	
	--! signals
	signal control_field : control_field_t;
	signal dc_wea : std_logic_vector(3 downto 0);
	signal ars_1, ars_2, ard : std_logic_vector(4 downto 0);
	signal pc_output, pc_input, instruction,
			 rf_input, rs_1, rs_2, immd, alu_port_2, 
			 alu_output, dc_output 
			 : std_logic_vector(31 downto 0);
	
begin

	--! program counter
	pc1: program_counter port map (
		clk => clk,
		ce => control_field.pc_enable,
		rst => rst,
		ci => control_field.pc_write_input,
		input => pc_input,
		output => pc_output
	);

	--! register file
	rf1: register_file port map (
		clk => clk,
		wr => control_field.rf_write_input,
		rs1 => ars_1,
		rs2 => ars_2,
		rd => ard,
		id => rf_input,
		os1 => rs_1,
		os2 => rs_2
	);

	--! alu
	with control_field.alu_immd select alu_port_2 <=
		rs_2 when '0',
		immd when others;
	alu1: alu port map (
		op => control_field.alu_op,
		arithmetic => control_field.alu_arithmetic,
		input_1 => rs_1,
		input_2 => alu_port_2,
		output => alu_output
	);
	
	--! instruction cache
	ic1: instruction_cache port map (
		clka => clk,
		addra => pc_output,
		douta => instruction
	);

	--! data cache
	with control_field.dc_write_input select dc_wea <=
		"1111" when word,
		"0011" when half,
		"0001" when byte,
		"0000" when others;
	dc1: data_cache port map (
		clka => clk,
		wea => dc_wea,
		addra => alu_output,
		dina => rs_2,
		douta => dc_output
	);
	
end Behavioral;

