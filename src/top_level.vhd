library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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
		port (
			CLK_IN1 : in std_logic;
			CLK_OUT1 : out std_logic
		 );
	end component;

	component cpu is
		 port (
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
	
	component i_cache is
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
	end component;

	component rom_manager is
		generic(
			initial_threshold : integer := 12;
			steady_threshold : integer := 3
		);
		port ( 
			clk : in  STD_LOGIC;
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
		port ( 
			CLK_100MHZ : in  STD_LOGIC;
			Seg1 : in  STD_LOGIC_VECTOR (7 downto 0);
			Seg2 : in  STD_LOGIC_VECTOR (7 downto 0);
			Seg3 : in  STD_LOGIC_VECTOR (7 downto 0);
			Seg4 : in  STD_LOGIC_VECTOR (7 downto 0);
			Segments : out  STD_LOGIC_VECTOR (7 downto 0);
			Anodes : out  STD_LOGIC_VECTOR (3 downto 0)
		);
	end component;

	component bcd7seg is
		port ( 
			Val_BCD : in STD_LOGIC_VECTOR (3 downto 0);
			Seg : out STD_LOGIC_VECTOR (6 downto 0)
		);
	end component;

	component gpio is
		port (
			clk : in  STD_LOGIC;
			rst : in  STD_LOGIC;
			gpio_out : out STD_LOGIC_VECTOR(31 downto 0);
			enable : in STD_LOGIC;
			daddress : inout  STD_LOGIC_VECTOR(31 downto 0);
			ddata : inout  STD_LOGIC_VECTOR(31 downto 0);
			dwr : inout STD_LOGIC_VECTOR(3 downto 0);
			drd : inout STD_LOGIC;
			dready: inout STD_LOGIC
		);
	end component;
	
	component ram is
		port (
			clk : in std_logic;
			rst : in std_logic;
			enable : in std_logic;
			daddress : inout std_logic_vector(31 downto 0);
			ddata : inout std_logic_vector(31 downto 0);
			dwr : inout std_logic_vector(3 downto 0);
			drd : inout std_logic;
			dready: inout std_logic
		);
	end component;

	signal clk_40m: std_logic := '0';
	signal drd, dready : std_logic := 'Z';
	signal ddata, daddress : std_logic_vector (31 downto 0) := (others => 'Z');
	signal dwr : std_logic_vector (3 downto 0) := (others => 'Z');

	signal idata, iaddress : std_logic_vector (31 downto 0) := (others => 'U');
	signal iready : std_logic := 'U';
	
	signal memdata, memaddress : std_logic_vector (31 downto 0) := (others => 'U');
	signal memready : std_logic := 'U';

	signal enable_mem : std_logic := '0';
	signal gpio_out: std_logic_vector (31 downto 0) := (others => '0');

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
	
	ic1: i_cache port map (
		clk => clk_40m,
		rst => rst,
		enable => '1',
		iaddress => iaddress(31 downto 2),
		idata => idata,
		iready => iready,
		memaddress => memaddress,
		memdata => memdata,
		memready => memready
	);
	
	rm1: rom_manager port map (
		clk => clk_40m,
		rst => rst,
		enable => '1',
		rd => '1',
		address => memaddress(26 downto 2),
		ready => memready,
		output => memdata,
		MemOE => MemOE,
		FlashCS => FlashCS,
		FlashRp => FlashRp,
		MemAddr => MemAddr,
		MemDB => MemDB
	);
	
	gpio1: gpio port map (
		clk => clk_40m,
		rst => rst,
		enable => daddress(31),
		daddress => daddress,
		ddata => ddata,
		dwr => dwr,
		drd => drd,
		dready => dready,
		gpio_out => gpio_out
	);
	led <= gpio_out(7 downto 0);
	
	enable_mem <= not(daddress(31));
	ram1 : ram port map (
		clk => clk_40m,
		rst => rst,
		enable => enable_mem,
		daddress => daddress,
		ddata => ddata,
		dwr => dwr,
		drd => drd,
		dready => dready
	);
	
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

