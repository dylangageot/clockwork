library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gpio is
	Port (
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
end gpio;

architecture Behavioral of gpio is

	signal gpio_register : std_logic_vector(31 downto 0) := (others => '0');
	
begin

	process (clk, rst, enable, dwr)
	begin
		if rst = '1' then
			gpio_register <= (others => '0');
		elsif rising_edge(clk) and enable = '1'
				and dwr /= "0000" --! write value on data bus if requested for a write operation
		then
			gpio_register <= ddata;
		end if;
	end process;

	gpio_out <= gpio_register;	
	
	--! Data bus get the GPIO value written when enabled and requested for a read operation.
	ddata <= gpio_register when enable = '1' and drd = '1' else (others => 'Z');
	--! GPIO is ready as it get enabled.
	dready <= '1' when enable = '1' and (drd = '1' or dwr(0) = '1') else 'Z';
	
end Behavioral;

