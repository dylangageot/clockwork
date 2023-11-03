----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:27:10 01/21/2017 
-- Design Name: 
-- Module Name:    seg8_mux - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seg8_mux is
    Port ( CLK_100MHZ : in  STD_LOGIC;
           Seg1 : in  STD_LOGIC_VECTOR (7 downto 0);
           Seg2 : in  STD_LOGIC_VECTOR (7 downto 0);
           Seg3 : in  STD_LOGIC_VECTOR (7 downto 0);
           Seg4 : in  STD_LOGIC_VECTOR (7 downto 0);
           Segments : out  STD_LOGIC_VECTOR (7 downto 0);
           Anodes : out  STD_LOGIC_VECTOR (3 downto 0));
end seg8_mux;

architecture Behavioral of seg8_mux is

	signal cnt_divider	: unsigned (16 downto 0) := (others=>'0');
	signal cnt_compteur  : unsigned (1 downto 0) := (others=>'0');
	signal CLK_500HZ	: std_logic := '0';

begin

	clk_divider : process
	begin
		wait until (rising_edge(CLK_100MHZ));
		if (cnt_divider = 9999) then
			CLK_500HZ <= not(CLK_500HZ);
			cnt_divider <= (others=>'0');
		else
			cnt_divider <= cnt_divider + 1;
		end if;
	end process;

	compteur_base_4 : process
	begin
		wait until (rising_edge(CLK_500HZ));
		case cnt_compteur is
			when "11" =>
				cnt_compteur <= (others=>'0');
			when others =>
				cnt_compteur <= cnt_compteur + 1;
		end case;
	end process;
	
	with cnt_compteur select
		Segments <= Seg1 when "00",
						Seg2 when "01",
						Seg3 when "10",
						Seg4 when others;
	
	with cnt_compteur select
		Anodes <= 	"1110" when "00",
						"1101" when "01",
						"1011" when "10",
						"0111" when others;

end Behavioral;

