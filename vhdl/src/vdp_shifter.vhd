library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity vdp_shifter is
generic (width: positive);
port(
	clk		: in  std_logic;
	latch		: in  std_logic;
	swap		: in  std_logic;
	input		: in  std_logic_vector(7 downto 0);
	output	: out std_logic
);
end entity;

architecture rtl of vdp_shifter is
signal data	:std_logic_vector(width-1 downto 0);
begin
	process (clk, input, latch, swap) begin
		if (rising_edge(clk)) then
			if (latch='1') then
				data(width-9 downto 0) <= data(width-8 downto 1);
				if (swap='1') then
					data(width-1 downto width-8) <= input;
				else 
					data(width-1) <= input(0);
					data(width-2) <= input(1);
					data(width-3) <= input(2);
					data(width-4) <= input(3);
					data(width-5) <= input(4);
					data(width-6) <= input(5);
					data(width-7) <= input(6);
					data(width-8) <= input(7);
				end if;
			else
				data(width-2 downto 0) <= data(width-1 downto 1);
			end if;
		end if;
	end process;
	output <= data(0);
end architecture;

