library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity vdp_background is
port (
	clk			:in std_logic;
	reset			:in std_logic;
	map_base		:in std_logic_vector(2 downto 0);
	scroll_x		:in unsigned(7 downto 0);
	y				:in unsigned(7 downto 0);

	vram_address:out std_logic_vector(13 downto 0);
	vram_read	:out std_logic;
	vram_data	:in std_logic_vector(7 downto 0);

	color			:out std_logic_vector(4 downto 0)
);
end entity;

architecture rtl of vdp_background is

	component vdp_shifter
	generic (width: natural);
	port(
		input	:in std_logic_vector(7 downto 0);
		latch	:in std_logic;
		swap	:in std_logic;
		clk	:in std_logic;
		output:out std_logic
	);
	end component;
	signal table_address	:std_logic_vector (13 downto 0);
	signal char_address	:std_logic_vector (13 downto 0);
	signal tile_index		:std_logic_vector (8 downto 0);
	signal x					:unsigned (7 downto 0);
	signal tile_y			:std_logic_vector (2 downto 0);
	signal palette			:std_logic;
	signal priority		:std_logic;
	signal flip_x			:std_logic;
--	signal latch0,latch1,latch2,latch3: std_logic;

	signal data0			: std_logic_vector(7 downto 0);
	signal data1			: std_logic_vector(7 downto 0);
	signal data2			: std_logic_vector(7 downto 0);
	signal data3			: std_logic_vector(7 downto 0);
	
	signal shift0			: std_logic_vector(7 downto 0);
	signal shift1			: std_logic_vector(7 downto 0);
	signal shift2			: std_logic_vector(7 downto 0);
	signal shift3			: std_logic_vector(7 downto 0);
begin
--	shifter0: vdp_shifter generic map (width=>11) port map (vram_data, latch0, flip_x, clk, color(0));
--	shifter1: vdp_shifter generic map (width=>10) port map (vram_data, latch1, flip_x, clk, color(1));
--	shifter2: vdp_shifter generic map (width=> 9) port map (vram_data, latch2, flip_x, clk, color(2));
--	shifter3: vdp_shifter generic map (width=> 8) port map (vram_data, latch3, flip_x, clk, color(3));

--	process (clk) begin
--		if (rising_edge(clk)) then
--			if (reset='1') then
--				screen_x <= scroll_x+248;
--			else
--				case screen_x(2 downto 0) is
--				when "010" =>
--					tile_index(7 downto 0) <= vram_data;
--				when "011" =>
--					tile_index(8) <= vram_data(0);
--					flip_x <= vram_data(1);
--					tile_y(0) <= y(0) xor vram_data(2);
--					tile_y(1) <= y(1) xor vram_data(2);
--					tile_y(2) <= y(2) xor vram_data(2);
--					palette <= vram_data(3);
--					priority <= vram_data(4);
--				when "111" =>
--					color(4) <= palette;
--				when others =>
--				end case;
--				screen_x <= screen_x + 1;
--			end if;
--		end if;
--	end process;
	
	-- char table address (pixel 2,3)
--	table_address(13 downto 11) <= map_base;
--	table_address(10 downto 6) <= std_logic_vector(y(7 downto 3));
--	table_address(5 downto 1) <= std_logic_vector(screen_x(7 downto 3) + 1);
--	table_address(0) <= screen_x(0);

	-- char data address (pixel 4,5,6,7)
--	char_address <= tile_index & tile_y & std_logic_vector(screen_x(1 downto 0));
--	latch0 <= '1' when screen_x(2 downto 0)="100" else '0';
--	latch1 <= '1' when screen_x(2 downto 0)="101" else '0';
--	latch2 <= '1' when screen_x(2 downto 0)="110" else '0';
--	latch3 <= '1' when screen_x(2 downto 0)="111" else '0';

--	vram_address <= char_address when screen_x(2)='1' else table_address;
--	vram_read <= screen_x(2) or screen_x(1);

	
	process (clk,x) begin
		if (rising_edge(clk)) then
			if (reset='1') then
				x <= scroll_x+248;
			else
				x <= x + 1;
			end if;
		end if;
	end process;

	process (clk, x)
		variable table_address	: std_logic_vector(12 downto 0);
		variable char_address	: std_logic_vector(11 downto 0);
	begin
		if (rising_edge(clk)) then
			table_address(12 downto 10) := map_base;
			table_address(9 downto 5) := std_logic_vector(y(7 downto 3));
			table_address(4 downto 0) := std_logic_vector(x(7 downto 3) + 1);
			char_address := tile_index & tile_y;
			
			case x(2 downto 0) is
			when "000" => vram_address <= table_address & "0";
			when "001" => vram_address <= table_address & "1";
			when "010" => vram_address <= char_address & "00";
			when "011" => vram_address <= char_address & "01";
			when "100" => vram_address <= char_address & "10";
			when "101" => vram_address <= char_address & "11";
			when others =>
			end case;
		end if;
	end process;
	
	process (clk,x) begin
		if (rising_edge(clk)) then
			case x(2 downto 0) is
			when "010" =>
				tile_index(7 downto 0) <= vram_data;
			when "011" =>
				tile_index(8) <= vram_data(0);
				flip_x <= vram_data(1);
				tile_y(0) <= y(0) xor vram_data(2);
				tile_y(1) <= y(1) xor vram_data(2);
				tile_y(2) <= y(2) xor vram_data(2);
				palette <= vram_data(3);
				priority <= vram_data(4);
			when "100" =>
				data0 <= vram_data;
			when "101" =>
				data1 <= vram_data;
			when "110" =>
				data2 <= vram_data;
			when "111" =>
				data3 <= vram_data;
			when others =>
			end case;
		end if;
	end process;
	
	process (clk,x) begin
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
			when others =>
				shift0(7 downto 1) <= shift0(6 downto 0);
				shift1(7 downto 1) <= shift1(6 downto 0);
				shift2(7 downto 1) <= shift2(6 downto 0);
				shift3(7 downto 1) <= shift3(6 downto 0);
			end case;
		end if;
	end process;
end architecture;

