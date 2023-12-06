library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ram is
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
end ram;

architecture Behavioral of ram is

	component data_cache
		port (
			clka : in std_logic;
			ena : in std_logic;
			wea : in std_logic_vector(3 downto 0);
			addra : in std_logic_vector(31 downto 0);
			dina : in std_logic_vector(31 downto 0);
			douta : out std_logic_vector(31 downto 0)
		);
	end component;
	
	signal previous_daddress : std_logic_vector(31 downto 0) := (others => 'Z');
   signal mem_out : std_logic_vector(31 downto 0);
	signal mem_ready : std_logic := '0';
	
begin

	dc1: data_cache port map (
		clka => clk,
		ena => enable,
		wea => dwr,
		addra => daddress,
		dina => ddata,
		douta => mem_out
	);
	
	--! the memory shall throw a non-ready state once a new address is requested
	previous_address_gen: process (clk, daddress, dwr, enable)
	begin
		if rising_edge(clk) and enable = '1' then
			previous_daddress <= daddress;
		end if;
	end process;
	
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
	
	dready <= mem_ready when enable = '1' and (dwr(0) = '1' or drd = '1') else 'Z';
	ddata <= mem_out when enable = '1' and drd = '1' else (others => 'Z');
	
end Behavioral;

