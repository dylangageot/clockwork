----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:50:45 09/25/2023 
-- Design Name: 
-- Module Name:    top_level - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_level is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  nibble : in STD_LOGIC;
			  word_select: in STD_LOGIC;
           led : out  STD_LOGIC_VECTOR (7 downto 0);
			  MemOE : out  STD_LOGIC;
			  FlashCS : out  STD_LOGIC;
			  FlashRp : out  STD_LOGIC;
			  MemAddr : out  STD_LOGIC_VECTOR (26 downto 1);
			  MemDB : in  STD_LOGIC_VECTOR (15 downto 0);
           seg : out  STD_LOGIC_VECTOR (7 downto 0);
           an : out  STD_LOGIC_VECTOR (3 downto 0)
	);
end top_level;

architecture Behavioral of top_level is

	component clock_gen
	port
	(
	  CLK_IN1           : in     std_logic;
	  CLK_OUT1          : out    std_logic
	 );
	end component;

	component cpu is
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
	end component;

	COMPONENT data_cache
	  PORT (
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

	component rom_manager is
		 Generic(
			initial_threshold : integer := 12;
			steady_threshold : integer := 3
		 );
		 Port ( clk : in  STD_LOGIC;
				  rst : in  STD_LOGIC;
				  enable : in STD_LOGIC;
				  rd : in  STD_LOGIC;
				  address : in  STD_LOGIC_VECTOR (26 downto 2);
				  ready : out  STD_LOGIC;
				  output : out STD_LOGIC_VECTOR (31 downto 0);
				  MemOE : out  STD_LOGIC;
				  FlashCS : out  STD_LOGIC;
				  FlashRp : out  STD_LOGIC;
				  MemAddr : out  STD_LOGIC_VECTOR (26 downto 1);
				  MemDB : in  STD_LOGIC_VECTOR (15 downto 0)
		 );
	end component;

	component seg8_mux is
		 Port ( CLK_100MHZ : in  STD_LOGIC;
				  Seg1 : in  STD_LOGIC_VECTOR (7 downto 0);
				  Seg2 : in  STD_LOGIC_VECTOR (7 downto 0);
				  Seg3 : in  STD_LOGIC_VECTOR (7 downto 0);
				  Seg4 : in  STD_LOGIC_VECTOR (7 downto 0);
				  Segments : out  STD_LOGIC_VECTOR (7 downto 0);
				  Anodes : out  STD_LOGIC_VECTOR (3 downto 0));
	end component;

	component bcd7seg is
		 Port ( Val_BCD : in STD_LOGIC_VECTOR (3 downto 0);
				  Seg : out STD_LOGIC_VECTOR (6 downto 0));
	end component;

	signal clk_40m: std_logic := '0';
	signal gpio: std_logic_vector (31 downto 0) := (others => '0');
	signal drd, dready : std_logic := 'Z';
	signal ddata, daddress, previous_daddress : std_logic_vector (31 downto 0) := (others => 'Z');
	signal dwr : std_logic_vector (3 downto 0) := (others => 'Z');

	signal idata, iaddress : std_logic_vector (31 downto 0) := (others => '0');
	signal iready : std_logic := '0';

   signal mem_out : std_logic_vector(31 downto 0);
	signal enable_gpio, enable_mem, mem_ready : std_logic := '0';

	type segments_t is array (0 to 3) of std_logic_vector(7 downto 0);
	signal segments : segments_t := (others => (others => '1'));
	signal selected_input_32b : std_logic_vector(31 downto 0);
	signal selected_input : std_logic_vector(15 downto 0);

begin
	
	cg1: clock_gen port map (
		CLK_IN1 => clk,
		CLK_OUT1 => clk_40m
	);
	
	cpu1: cpu port map (
		 clk => clk_40m,
		 rst => rst,
		 enable => '1',
		 daddress => daddress,
		 ddata => ddata,
		 dwr => dwr,
		 drd => drd,
		 dready => dready,
		 iaddress => iaddress,
		 idata => idata,
		 iready => iready
	);
	
	rm1: rom_manager port map (
		clk => clk_40m,
		rst => rst,
		enable => '1',
		rd => '1',
		address => iaddress(26 downto 2),
		ready => iready,
		output => idata,
		MemOE => MemOE,
		FlashCS => FlashCS,
		FlashRp => FlashRp,
		MemAddr => MemAddr,
		MemDB => MemDB
	);
	
	led <= gpio(7 downto 0);

	--! GPIO
	enable_gpio <= daddress(31);
	dready <= '1' when enable_gpio = '1' and (drd = '1' or dwr(0) = '1') else 'Z';
	ddata <= gpio when enable_gpio = '1' and drd = '1' else (others => 'Z');
	gpio_gen: process (clk_40m, rst, enable_gpio, dwr)
	begin
		if rst = '1' then
			gpio <= (others => '0');
		elsif rising_edge(clk_40m) and enable_gpio = '1' and dwr /= "0000" then
			gpio <= ddata;
		end if;
	end process;
	
	--! data cache
	enable_mem <= not(daddress(31));
	dc1: data_cache port map (
		clka => clk_40m,
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
	previous_address_gen: process (clk_40m, daddress, dwr, enable_mem)
	begin
		if rising_edge(clk_40m) and enable_mem = '1' then
			previous_daddress <= daddress;
		end if;
	end process;

	with word_select select selected_input_32b <=
		iaddress when '0',
		idata when '1';

	with nibble select selected_input <=
		selected_input_32b(15 downto 0) when '0',
		selected_input_32b(31 downto 16) when '1';
		
	seg8 : seg8_mux port map (
		CLK_100MHZ => clk_40m,
		Seg1 => segments(0),
		Seg2 => segments(1),
		Seg3 => segments(2),
		Seg4 => segments(3),
		Segments => seg,
		Anodes => an
	);
	
	segments(0)(7) <= not(iready);
	seg_gen : for i in segments'range generate 
		bcd2seg : bcd7seg port map (
			Val_BCD => selected_input((4*i + 3) downto 4*i),
			Seg => segments(i)(6 downto 0)
		);
	end generate;


end Behavioral;

