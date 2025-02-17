library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.control_field.ALL;

entity cpu is
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
end cpu;

architecture Behavioral of cpu is

	component alu is
		Port ( 
			operation: alu_operation_t;
			arithmetic : in STD_LOGIC;
			input_1 : in  STD_LOGIC_VECTOR (31 downto 0);
			input_2 : in  STD_LOGIC_VECTOR (31 downto 0);
			output : out  STD_LOGIC_VECTOR (31 downto 0)
		);
	end component;
	
	component register_file is
		Port ( 
			clk : in  STD_LOGIC;
			wr : in STD_LOGIC;
			rs1 : in  STD_LOGIC_VECTOR (4 downto 0);
			rs2 : in  STD_LOGIC_VECTOR (4 downto 0);
			rd : in  STD_LOGIC_VECTOR (4 downto 0);
			id : in  STD_LOGIC_VECTOR (31 downto 0);
			os1 : out  STD_LOGIC_VECTOR (31 downto 0);
			os2 : out  STD_LOGIC_VECTOR (31 downto 0)
		);
	end component;
	
	component control_unit is
		 Port ( 
			opcode : in  STD_LOGIC_VECTOR (6 downto 0);
			funct3 : in  STD_LOGIC_VECTOR (2 downto 0);
			funct7 : in  STD_LOGIC_VECTOR (6 downto 0);
			id_control : out id_control_t;
			ex_control : out ex_control_t;
			mem_control : out mem_control_t;
			wb_control : out wb_control_t
		);
	end component;
	
	--! signals
	signal id_control : id_control_t := id_nop;
	signal ex_control : ex_control_t := ex_nop;
	signal mem_control : mem_control_t := mem_nop;
	signal wb_control : wb_control_t := wb_nop;
	signal memory_filter_w, memory_write : std_logic_vector(3 downto 0);
	signal pc_output : std_logic_vector(31 downto 0) := (others => '0');
	signal pc_input, pc_4, rf_input, rs_1, rs_2, alu_port_1, 
			 alu_port_2, alu_output, memory_filter_r, pc_immd
			 : std_logic_vector(31 downto 0);
	signal mem_stall, branch_taken, raw : std_logic;
	
	--! pipeline registers
	signal if_id_register : if_id_register_t := if_id_nop;
	signal id_ex_register : id_ex_register_t := id_ex_nop;
	signal ex_mem_register : ex_mem_register_t := ex_mem_nop;
	signal mem_wb_register : mem_wb_register_t := mem_wb_nop;
	
	--! immediate thangs!
	signal immd_i, immd_s, immd_j, immd_b, immd_u : 
															std_logic_vector(31 downto 0);

	alias instruction is if_id_register.instruction;
	alias opcode is if_id_register.instruction(6 downto 0); 
	alias funct3 is if_id_register.instruction(14 downto 12);
	alias funct7 is if_id_register.instruction(31 downto 25);
	alias a_rs_1 is if_id_register.instruction(19 downto 15);
	alias a_rs_2 is if_id_register.instruction(24 downto 20);
	alias a_rd   is if_id_register.instruction(11 downto 7);
	
	alias memory_out_byte is mem_wb_register.mem_output(7  downto 0);
	alias memory_out_half is mem_wb_register.mem_output(15 downto 0);
	
begin

	--! INSTRUCTION FETCH ------------------------------------------------------

	pc_4 <= std_logic_vector(unsigned(pc_output) + 4);

	--! program counter
	process (clk, rst, enable)
	begin
		if rst = '1' then
			pc_output <= (others => '0');
		elsif rising_edge(clk) and enable = '1' then
			if branch_taken = '1' then
				pc_output <= pc_input;
			elsif iready = '1' and raw = '0' and mem_stall = '0' then
				pc_output <= pc_4;
			end if;
		end if;
	end process;
	
	iaddress <= pc_output;
	
	--! if to id register
	if_id_reg: process (clk, rst, enable, raw, mem_stall)
	begin
		if rst = '1' then 
			if_id_register <= if_id_nop;
		elsif rising_edge(clk) and enable = '1' and raw = '0' and mem_stall = '0' then
			if branch_taken = '1' or iready = '0' then
				if_id_register <= if_id_nop;
			else
				if_id_register <= (
					instruction => idata,
					pc => pc_output,
					pc_4 => pc_4
				);
			end if;
		end if;
	end process;

	--! INSTRUCTION DECODE -----------------------------------------------------
	
	--! control unit
	cu1: control_unit port map (
		opcode => opcode,
		funct3 => funct3,
		funct7 => funct7,
		id_control => id_control,
		ex_control => ex_control,
		mem_control => mem_control,
		wb_control => wb_control
	);			
	
	--! retrieve immediates from instructions, depending on the type.
	immd_i <= std_logic_vector(resize(signed(instruction(31 downto 20)), 
																				immd_i'length));
	immd_s <= std_logic_vector(resize(signed(instruction(31 downto 25) & 
												instruction(11 downto 7)), immd_s'length));
	immd_b <= std_logic_vector(resize(signed(instruction(31) & instruction(7) &
						instruction(30 downto 25) & instruction(11 downto 8) & '0'),
						immd_b'length));
	immd_u <= std_logic_vector(instruction(31 downto 12) & X"000"); 
	immd_j <= std_logic_vector(resize(signed(instruction(31) & 
						instruction(19 downto 12) & instruction(20) & 
						instruction(30 downto 21) & '0'), immd_j'length));
	
	with id_control.pc_immd select pc_immd <= 
		std_logic_vector(signed(if_id_register.pc) + signed(immd_j)) when pc_immd_j,
		std_logic_vector(signed(if_id_register.pc) + signed(immd_b)) when pc_immd_b,
		X"0000_0000" when others;
	
	--! register file
	rf1: register_file port map (
		clk => clk,
		wr => mem_wb_register.wb_control.write_rd,
		rs1 => a_rs_1,
		rs2 => a_rs_2,
		rd => mem_wb_register.a_rd,
		id => rf_input,
		os1 => rs_1,
		os2 => rs_2
	);
	
	--! alu port 1 mux
	with id_control.port_1 select alu_port_1 <=
		rs_1 when port_1_rs_1,
		pc_output when port_1_pc,
		X"0000_0000" when others;
		
	--! alu port 2 mux
	with id_control.port_2 select alu_port_2 <=
		rs_2 when port_2_rs_2,
		immd_i when port_2_i,
		immd_s when port_2_s,
		immd_u when port_2_u,
		X"0000_0000" when others;
		
	raw_gen: process (clk, id_control, if_id_register, id_ex_register, ex_mem_register,
							mem_wb_register)
	begin
		if (not (id_ex_register.a_rd  = B"00000") and 
			id_ex_register.wb_control.write_rd = '1' 
			and  ((id_ex_register.a_rd = a_rs_1 and id_control.read_rs1 = '1') 
				or (id_ex_register.a_rd  = a_rs_2 and id_control.read_rs2 = '1')))  
		or (not (ex_mem_register.a_rd = B"00000") and 
			ex_mem_register.wb_control.write_rd = '1' 
			and  ((ex_mem_register.a_rd = a_rs_1 and id_control.read_rs1 = '1') 
				or (ex_mem_register.a_rd  = a_rs_2 and id_control.read_rs2 = '1')))  
		or (not (mem_wb_register.a_rd = B"00000") and 
			mem_wb_register.wb_control.write_rd = '1' 
			and  ((mem_wb_register.a_rd = a_rs_1 and id_control.read_rs1 = '1') 
				or (mem_wb_register.a_rd  = a_rs_2 and id_control.read_rs2 = '1')))  
		then 
			raw <= '1';
		else
			raw <= '0';
		end if;
	end process;
	
	--! id to ex register
	id_ex_reg: process (clk, rst, enable, branch_taken, mem_stall)
	begin
		if rst = '1' then 
			id_ex_register <= id_ex_nop;
		elsif rising_edge(clk) and enable = '1' and mem_stall = '0' then
			if branch_taken = '1' or raw = '1' then
				id_ex_register <= id_ex_nop;
			else
				id_ex_register <= (
					ex_control => ex_control,
					mem_control => mem_control,
					wb_control => wb_control,
					a_rd => a_rd,
					pc_4 => if_id_register.pc_4,
					pc_immd_jb => pc_immd,
					rs_2 => rs_2,
					alu_port_1 => alu_port_1,
					alu_port_2 => alu_port_2,
					immd_u => immd_u
				);
			end if;
		end if;
	end process;
	
	--! EXECUTE ----------------------------------------------------------------

	--! alu
	alu1: alu port map (
		operation => id_ex_register.ex_control.operation,
		arithmetic => id_ex_register.ex_control.arithmetic,
		input_1 => id_ex_register.alu_port_1,
		input_2 => id_ex_register.alu_port_2,
		output => alu_output
	);
	
	branch_taken <= id_ex_register.ex_control.write_pc and (
				id_ex_register.ex_control.is_jump or 
				(alu_output(0) xor id_ex_register.ex_control.negate_alu_output));
				
	with id_ex_register.ex_control.address_computation_mux select pc_input <=
		alu_output(31 downto 1) & '0' when pc_alu,
		id_ex_register.pc_immd_jb when pc_id,
		X"0000_0000" when others;
	
	--! ex to mem register
	ex_mem_reg: process (clk, rst, enable, mem_stall)
	begin
		if rst = '1' then 
			ex_mem_register <= ex_mem_nop;
		elsif rising_edge(clk) and enable = '1' and mem_stall = '0' then
			ex_mem_register <= (
				mem_control => id_ex_register.mem_control,
				wb_control => id_ex_register.wb_control,
				a_rd => id_ex_register.a_rd,
				pc_4 => id_ex_register.pc_4,
				alu_output => alu_output,
				rs_2 => id_ex_register.rs_2,
				immd_u => id_ex_register.immd_u
			);
		end if;
	end process;
	
	--! MEMORY -----------------------------------------------------------------

	mem_stall <= ex_mem_register.mem_control.wait_mem and not(dready);

	with ex_mem_register.mem_control.byte_length select memory_filter_w <=
		"1111" when word,
		"0011" when half,
		"0001" when byte,
		"0000" when others;
	with ex_mem_register.mem_control.write_mem select dwr <=
		memory_filter_w when '1',
		"0000" when others;
	
	daddress <= ex_mem_register.alu_output;
	ddata <= ex_mem_register.rs_2 
		when ex_mem_register.mem_control.write_mem = '1' else (others => 'Z');
	drd <= '1' when ex_mem_register.mem_control.read_mem = '1' else '0';
	dready <= 'Z';
	
	--! mem to wb register
	mem_wb_reg: process (clk, rst, enable)
	begin
		if rst = '1' then 
			mem_wb_register <= mem_wb_nop;
		elsif rising_edge(clk) and enable = '1' then
			if mem_stall = '1' then
				mem_wb_register <= mem_wb_nop;
			else
				mem_wb_register <= (
					wb_control => ex_mem_register.wb_control,
					a_rd => ex_mem_register.a_rd,
					mem_output => ddata,
					pc_4 => ex_mem_register.pc_4,
					alu_output => ex_mem_register.alu_output,
					immd_u => ex_mem_register.immd_u
				);
			end if;
		end if;
	end process;
	
	--! WRITE BACK -------------------------------------------------------------
	
	--! write back input mux
	with mem_wb_register.wb_control.rd_input_mux select rf_input <=
		mem_wb_register.alu_output when rf_alu_output,
		std_logic_vector(resize(signed(memory_out_byte), 32)) when rf_mem_byte,
		std_logic_vector(resize(unsigned(memory_out_byte), 32)) 
																	when rf_mem_unsigned_byte,
		std_logic_vector(resize(signed(memory_out_half), 32)) when rf_mem_half,
		std_logic_vector(resize(unsigned(memory_out_half), 32)) 
																	when rf_mem_unsigned_half,
		mem_wb_register.mem_output when rf_mem_word,
		mem_wb_register.pc_4 when rf_pc_4,
		mem_wb_register.immd_u when rf_u,
		X"0000_0000" when others;

end Behavioral;

