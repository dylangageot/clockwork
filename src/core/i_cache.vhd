library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i_cache is
	port (
		clk : in std_logic;
		rst : in std_logic;
		enable : in std_logic;
		iaddress : in std_logic_vector(31 downto 2);
		idata : out std_logic_vector(31 downto 0);
		iready : out std_logic;
		memaddress : out std_logic_vector(31 downto 0);
		memdata : in std_logic_vector(31 downto 0);
		memready : in std_logic
	);
end i_cache;

architecture Behavioral of i_cache is

	--! The tag cache contains tag for each cache line.
	--! A tag is 20 bits length, an extra bit is used to check validity of cache line.
	component tag_cache
	  port (
		 clka : in std_logic;
		 rsta : in std_logic;
		 ena : in std_logic;
		 wea : in std_logic_vector(0 downto 0);
		 addra : in std_logic_vector(5 downto 0);
		 dina : in std_logic_vector(21 downto 0);
		 douta : out std_logic_vector(21 downto 0)
	  );
	end component;

	--! The memory cache contains the useful data.
	--! The memory is currently organized to contains 512 instructions, banked into 64 sets of 8 instructions each (32 bytes).
	component memory_cache
	  port (
		 clka : in std_logic;
		 rsta : in std_logic;
		 ena : in std_logic;
		 wea : in std_logic_vector(0 downto 0);
		 addra : in std_logic_vector(8 downto 0);
		 dina : in std_logic_vector(31 downto 0);
		 douta : out std_logic_vector(31 downto 0)
	  );
	end component;

	--! address layout: | ---- tag ---- | -- index -- | - offset - |
	alias offset is iaddress(4 downto 2);
	alias index is iaddress(10 downto 5);
	alias tag is iaddress(31 downto 11);
	
	--! The instruction address is latched to perform safe operation, inspite of a volatile input.
	signal previous_iaddress : std_logic_vector(31 downto 2) := (others => 'U');
	alias latched_offset is previous_iaddress(4 downto 2);
	alias latched_index is previous_iaddress(10 downto 5);
	alias latched_tag is previous_iaddress(31 downto 11);
	
	--! Beginning state: idle
	--! The idle state does wait for a valid address prompt (previous address matched with current address)
	--! If the prompted address has an invalid tag of different tag, current state is set to fetch cache line.
	--! The fetch cache line state performs the memory transfer from lower memory to the memory cache.
	--! Once the eight instructions are transfered, current state is set to update tag.
	--! The update tag state writes to the tag cache the prompted tag with a valid bit, then the current state is set to idle.
	type fsm_state_t is (idle, fetch_cache_line, update_tag);
	signal current_state : fsm_state_t := idle;
	
	signal hit, write_tag, write_mem : std_logic := 'U';
	signal tag_in, tag_out : std_logic_vector(21 downto 0) := (others => 'U');
	signal fetch_addr, mem_cache_addr : std_logic_vector(8 downto 0) :=  (others => 'U');
	
begin

	tag_cache_1 : tag_cache port map (
		clka => clk,
		rsta => rst,
		ena => enable,
		wea(0) => write_tag,
		addra => index,
		dina => tag_in,
		douta => tag_out
	);
	
	mem_cache_1 : memory_cache port map (
		clka => clk,
		rsta => rst,
		ena => enable,
		wea(0) => write_mem,
		addra => mem_cache_addr,
		dina => memdata,
		douta => idata
	);

	with write_mem select mem_cache_addr <=
		fetch_addr when '1',
		index & offset when others;

	with current_state select write_mem <= 
		'1' when fetch_cache_line,
		'0' when others;
		
	with current_state select write_tag <= 
		'1' when update_tag,
		'0' when others;

	hit_gen : process (iaddress, tag_out, current_state, previous_iaddress)
	begin
		if tag_out(21) = '1' and tag = tag_out(20 downto 0) then
			hit <= '1';
			if current_state = idle and previous_iaddress = iaddress then
				iready <= '1';
			else 
				iready <= '0';
			end if;
 		else
			hit <= '0';
			iready <= '0';
		end if;
	end process;

	future_state : process (rst, clk, enable)
		variable offset_counter : integer := 0;
	begin
		if rst = '1' then
			memaddress <= (others => '0');
			fetch_addr <= (others => '0');
			previous_iaddress <= (others => '0');
			current_state <= idle;
		elsif rising_edge(clk) and enable = '1' then
			case current_state is
				when idle =>
					if hit = '0' and previous_iaddress = iaddress then
						current_state <= fetch_cache_line;
						offset_counter := 0;
					else
						previous_iaddress <= iaddress;
					end if;
				when fetch_cache_line =>
					if memready = '1' then
						offset_counter := offset_counter + 1;
						if offset_counter >= 2**(offset'length) then
							current_state <= update_tag;
							tag_in <= '1' & latched_tag;
						end if;
					end if;
				when update_tag =>
					current_state <= idle;
				when others =>
			end case;
			fetch_addr <= latched_index & std_logic_vector(to_unsigned(offset_counter, offset'length));
			memaddress <=  latched_tag & latched_index & std_logic_vector(to_unsigned(offset_counter, offset'length)) & "00";
		end if;
	end process;

end Behavioral;

