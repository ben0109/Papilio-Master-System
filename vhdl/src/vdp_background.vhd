library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity vdp_background is
port (
	clk		: in  std_logic;
	reset		: in  std_logic;
	address	: in  std_logic_vector(2 downto 0);
	scroll_x	: in  unsigned(7 downto 0);
	y			: in  unsigned(7 downto 0);

	vram_A	: out std_logic_vector(13 downto 0);
	vram_D	: in  std_logic_vector(7 downto 0);

	color		: out std_logic_vector(4 downto 0);
	priority	: out std_logic
);
end entity;

architecture rtl of vdp_background is

	signal tile_index		: std_logic_vector (8 downto 0);
	signal x					: unsigned (7 downto 0);
	signal tile_y			: std_logic_vector (2 downto 0);
	signal palette			: std_logic;
	signal priority_latch: std_logic;
	signal flip_x			: std_logic;

	signal data0			: std_logic_vector(7 downto 0);
	signal data1			: std_logic_vector(7 downto 0);
	signal data2			: std_logic_vector(7 downto 0);
	signal data3			: std_logic_vector(7 downto 0);
	
	signal shift0			: std_logic_vector(7 downto 0);
	signal shift1			: std_logic_vector(7 downto 0);
	signal shift2			: std_logic_vector(7 downto 0);
	signal shift3			: std_logic_vector(7 downto 0);
	
begin
	
	process (clk) begin
		if (rising_edge(clk)) then
			if (reset='1') then
				x <= scroll_x+248;
			else
				x <= x + 1;
			end if;
		end if;
	end process;

	process (clk)
		variable table_address	: std_logic_vector(12 downto 0);
		variable char_address	: std_logic_vector(11 downto 0);
	begin
		if (rising_edge(clk)) then
			table_address(12 downto 10) := address;
			table_address(9 downto 5) := std_logic_vector(y(7 downto 3));
			table_address(4 downto 0) := std_logic_vector(x(7 downto 3) + 1);
			char_address := tile_index & tile_y;
			
			case x(2 downto 0) is
			when "000" => vram_A <= table_address & "0";
			when "001" => vram_A <= table_address & "1";
			when "010" => vram_A <= char_address & "00";
			when "011" => vram_A <= char_address & "01";
			when "100" => vram_A <= char_address & "10";
			when "101" => vram_A <= char_address & "11";
			when others =>
			end case;
		end if;
	end process;
	
	process (clk) begin
		if (rising_edge(clk)) then
			case x(2 downto 0) is
			when "010" =>
				tile_index(7 downto 0) <= vram_D;
			when "011" =>
				tile_index(8) <= vram_D(0);
				flip_x <= vram_D(1);
				tile_y(0) <= y(0) xor vram_D(2);
				tile_y(1) <= y(1) xor vram_D(2);
				tile_y(2) <= y(2) xor vram_D(2);
				palette <= vram_D(3);
				priority_latch <= vram_D(4);
			when "100" =>
				data0 <= vram_D;
			when "101" =>
				data1 <= vram_D;
			when "110" =>
				data2 <= vram_D;
			when "111" =>
				data3 <= vram_D;
			when others =>
			end case;
		end if;
	end process;
	
	process (clk) begin
		if (rising_edge(clk)) then
			color(0) <= shift0(7);
			color(1) <= shift1(7);
			color(2) <= shift2(7);
			color(3) <= shift3(7);
			case x(2 downto 0) is
			when "111" =>
				shift0 <= data0;
				shift1 <= data1;
				shift2 <= data2;
				shift3 <= data3;
				color(4) <= palette;
				priority <= priority_latch;
			when others =>
				shift0(7 downto 1) <= shift0(6 downto 0);
				shift1(7 downto 1) <= shift1(6 downto 0);
				shift2(7 downto 1) <= shift2(6 downto 0);
				shift3(7 downto 1) <= shift3(6 downto 0);
			end case;
		end if;
	end process;
end architecture;

