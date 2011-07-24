library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vdp_sprites is
	port (clk			: in  std_logic;
			spr_table	: in  STD_LOGIC_VECTOR (5 downto 0);
			spr_high_bit: in  std_logic;
			vram_a		: out STD_LOGIC_VECTOR (13 downto 0);
			vram_d		: in  STD_LOGIC_VECTOR (7 downto 0);
			scr_x			: in  unsigned (8 downto 0);
			scr_y			: in  unsigned (7 downto 0);
			color			: out STD_LOGIC_VECTOR (3 downto 0));
end vdp_sprites;

architecture Behavioral of vdp_sprites is

	component vpd_sprite_shifter is
	port( clk	: in  std_logic;
			scr_x	: in  unsigned (7 downto 0);
			x		: in  unsigned (7 downto 0);
			d0		: in  std_logic_vector (7 downto 0);
			d1		: in  std_logic_vector (7 downto 0);
			d2		: in  std_logic_vector (7 downto 0);
			d3		: in  std_logic_vector (7 downto 0);
			color : out std_logic_vector (3 downto 0);
			active: out std_logic);
	end component;
	
	signal last_x : unsigned (8 downto 0);

	-- FIFO
	type tindex is array (0 to 7) of std_logic_vector(5 downto 0);
	signal index	: tindex := (others=>"101010");
	signal count	: unsigned(3 downto 0) := "0000";
	signal enable	: std_logic_vector(7 downto 0);
	
	-- data for sprite
	signal n		: std_logic_vector(7 downto 0);
	signal y		: std_logic_vector(2 downto 0);

	type tx is array (0 to 7) of unsigned(7 downto 0);
	type tdata is array (0 to 7) of std_logic_vector(7 downto 0);
	signal x		: tx;
	signal d0	: tdata;
	signal d1	: tdata;
	signal d2	: tdata;
	signal d3	: tdata;

	type tcolor is array (0 to 7) of std_logic_vector(3 downto 0);
	signal spr_color	: tcolor;
	signal active		: std_logic_vector(7 downto 0);
	
	signal delta		: unsigned(3 downto 0);
begin

	shifter0: vpd_sprite_shifter
	port map(clk	=> clk,
				scr_x	=> scr_x(7 downto 0),
				x		=> x(0),
				d0		=> d0(0),
				d1		=> d1(0),
				d2		=> d2(0),
				d3		=> d3(0),
				color => spr_color(0),
				active=> active(0));

	shifter1: vpd_sprite_shifter
	port map(clk	=> clk,
				scr_x	=> scr_x(7 downto 0),
				x		=> x(1),
				d0		=> d0(1),
				d1		=> d1(1),
				d2		=> d2(1),
				d3		=> d3(1),
				color => spr_color(1),
				active=> active(1));

	shifter2: vpd_sprite_shifter
	port map(clk	=> clk,
				scr_x	=> scr_x(7 downto 0),
				x		=> x(2),
				d0		=> d0(2),
				d1		=> d1(2),
				d2		=> d2(2),
				d3		=> d3(2),
				color => spr_color(2),
				active=> active(2));

	shifter3: vpd_sprite_shifter
	port map(clk	=> clk,
				scr_x	=> scr_x(7 downto 0),
				x		=> x(3),
				d0		=> d0(3),
				d1		=> d1(3),
				d2		=> d2(3),
				d3		=> d3(3),
				color => spr_color(3),
				active=> active(3));

	shifter4: vpd_sprite_shifter
	port map(clk	=> clk,
				scr_x	=> scr_x(7 downto 0),
				x		=> x(4),
				d0		=> d0(4),
				d1		=> d1(4),
				d2		=> d2(4),
				d3		=> d3(4),
				color => spr_color(4),
				active=> active(4));

	shifter5: vpd_sprite_shifter
	port map(clk	=> clk,
				scr_x	=> scr_x(7 downto 0),
				x		=> x(5),
				d0		=> d0(5),
				d1		=> d1(5),
				d2		=> d2(5),
				d3		=> d3(5),
				color => spr_color(5),
				active=> active(5));

	shifter6: vpd_sprite_shifter
	port map(clk	=> clk,
				scr_x	=> scr_x(7 downto 0),
				x		=> x(0),
				d0		=> d0(6),
				d1		=> d1(6),
				d2		=> d2(6),
				d3		=> d3(6),
				color => spr_color(6),
				active=> active(6));

	shifter7: vpd_sprite_shifter
	port map(clk	=> clk,
				scr_x	=> scr_x(7 downto 0),
				x		=> x(7),
				d0		=> d0(7),
				d1		=> d1(7),
				d2		=> d2(7),
				d3		=> d3(7),
				color => spr_color(7),
				active=> active(7));
				
	delta <= scr_y-unsigned(vram_d);

	process (clk, vram_d, scr_x)
		variable i: integer range 0 to 7;
	begin
		if rising_edge(clk) then
			if scr_x<256 then
			
			elsif scr_x<320 then
				vram_a <= spr_table & "00" & std_logic_vector(scr_x(5 downto 0));
				
			elsif scr_x<384 then
				if scr_x(2)='0' then
					i := to_integer(scr_x(5 downto 3));
					case scr_x(2 downto 0) is
					when "000" => vram_a <= spr_table & "00" & index(i);
					when "001" => vram_a <= spr_table & "1" & index(i) & "0";
					when "010" => vram_a <= spr_table & "1" & index(i) & "1";
					when others=>
					end case;
				else
					vram_a <= spr_high_bit & n & y & scr_x(1) & scr_x(0);
				end if;
				last_x <= scr_x;
			end if;
		end if;
	end process;

	process (clk, vram_d, last_x, delta)
		variable i: integer range 0 to 7;
	begin
		if rising_edge(clk) then
			if last_x<256 then
			
			elsif last_x<320 then
				if 0<=delta and delta<8 then
					if count<8 then
						index(to_integer(count)) <= std_logic_vector(last_x(5 downto 0));
						enable(to_integer(count)) <= '1';
						count <= count+1;
					end if;
				end if;
				
			elsif last_x<384 then
				i := to_integer(last_x(5 downto 3));
				case last_x(2 downto 0) is
				when "000" => y <= std_logic_vector(delta(2 downto 0));
				when "001" => x(i) <= unsigned(vram_d);
				when "010" => n <= vram_d;
				when "100" => d0(i) <= vram_d;
				when "101" => d1(i) <= vram_d;
				when "110" => d2(i) <= vram_d;
				when "111" => d3(i) <= vram_d;
				when others=>
				end case;
			end if;
		end if;
	end process;

	process (clk, vram_d, enable, active, spr_color)
	begin
		if rising_edge(clk) then
			if enable(0)='1' and active(0)='1' then
				color <= spr_color(0);
			elsif enable(1)='1' and active(1)='1' then
				color <= spr_color(1);
			elsif enable(2)='1' and active(2)='1' then
				color <= spr_color(2);
			elsif enable(3)='1' and active(3)='1' then
				color <= spr_color(3);
			elsif enable(4)='1' and active(4)='1' then
				color <= spr_color(4);
			elsif enable(5)='1' and active(5)='1' then
				color <= spr_color(5);
			elsif enable(6)='1' and active(6)='1' then
				color <= spr_color(6);
			elsif enable(7)='1' and active(7)='1' then
				color <= spr_color(7);
			else
				color <= "0000";
			end if;
		end if;
	end process;

end Behavioral;

