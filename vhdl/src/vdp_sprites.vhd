library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vdp_sprites is
	port (clk				: in  std_logic;
			address			: in  STD_LOGIC_VECTOR (5 downto 0);
			char_high_bit	: in  std_logic;
			tall				: in  std_logic;
			vram_A			: out STD_LOGIC_VECTOR (13 downto 0);
			vram_D			: in  STD_LOGIC_VECTOR (7 downto 0);
			x					: in  unsigned (8 downto 0);
			y					: in  unsigned (7 downto 0);
			color				: out STD_LOGIC_VECTOR (3 downto 0));
end vdp_sprites;

architecture Behavioral of vdp_sprites is

	component vpd_sprite_shifter is
	port( clk	: in  std_logic;
			x		: in  unsigned (7 downto 0);
			spr_x	: in  unsigned (7 downto 0);
			spr_d0: in  std_logic_vector (7 downto 0);
			spr_d1: in  std_logic_vector (7 downto 0);
			spr_d2: in  std_logic_vector (7 downto 0);
			spr_d3: in  std_logic_vector (7 downto 0);
			color : out std_logic_vector (3 downto 0);
			active: out std_logic);
	end component;

	-- FIFO
	type tindex is array (0 to 7) of std_logic_vector(5 downto 0);
	signal index	: tindex;-- := (others=>"101010");
	signal count	: integer range 0 to 8;
	signal enable	: std_logic_vector(7 downto 0);
	
	-- data for sprite
	signal spr_n	: std_logic_vector(7 downto 0);
	signal spr_y	: std_logic_vector(3 downto 0);

	type tx is array (0 to 7) of unsigned(7 downto 0);
	type tdata is array (0 to 7) of std_logic_vector(7 downto 0);
	signal spr_x	: tx;
	signal spr_d0	: tdata;
	signal spr_d1	: tdata;
	signal spr_d2	: tdata;
	signal spr_d3	: tdata;

	type tcolor is array (0 to 7) of std_logic_vector(3 downto 0);
	signal spr_color	: tcolor;
	signal active		: std_logic_vector(7 downto 0);
	
begin

	shifter0: vpd_sprite_shifter
	port map(clk	=> clk,
				x		=> x(7 downto 0),
				spr_x	=> spr_x(0),
				spr_d0=> spr_d0(0),
				spr_d1=> spr_d1(0),
				spr_d2=> spr_d2(0),
				spr_d3=> spr_d3(0),
				color => spr_color(0),
				active=> active(0));

	shifter1: vpd_sprite_shifter
	port map(clk	=> clk,
				x		=> x(7 downto 0),
				spr_x	=> spr_x(1),
				spr_d0=> spr_d0(1),
				spr_d1=> spr_d1(1),
				spr_d2=> spr_d2(1),
				spr_d3=> spr_d3(1),
				color => spr_color(1),
				active=> active(1));

	shifter2: vpd_sprite_shifter
	port map(clk	=> clk,
				x		=> x(7 downto 0),
				spr_x	=> spr_x(2),
				spr_d0=> spr_d0(2),
				spr_d1=> spr_d1(2),
				spr_d2=> spr_d2(2),
				spr_d3=> spr_d3(2),
				color => spr_color(2),
				active=> active(2));

	shifter3: vpd_sprite_shifter
	port map(clk	=> clk,
				x		=> x(7 downto 0),
				spr_x	=> spr_x(3),
				spr_d0=> spr_d0(3),
				spr_d1=> spr_d1(3),
				spr_d2=> spr_d2(3),
				spr_d3=> spr_d3(3),
				color => spr_color(3),
				active=> active(3));

	shifter4: vpd_sprite_shifter
	port map(clk	=> clk,
				x		=> x(7 downto 0),
				spr_x	=> spr_x(4),
				spr_d0=> spr_d0(4),
				spr_d1=> spr_d1(4),
				spr_d2=> spr_d2(4),
				spr_d3=> spr_d3(4),
				color => spr_color(4),
				active=> active(4));

	shifter5: vpd_sprite_shifter
	port map(clk	=> clk,
				x		=> x(7 downto 0),
				spr_x	=> spr_x(5),
				spr_d0=> spr_d0(5),
				spr_d1=> spr_d1(5),
				spr_d2=> spr_d2(5),
				spr_d3=> spr_d3(5),
				color => spr_color(5),
				active=> active(5));

	shifter6: vpd_sprite_shifter
	port map(clk	=> clk,
				x		=> x(7 downto 0),
				spr_x	=> spr_x(0),
				spr_d0=> spr_d0(6),
				spr_d1=> spr_d1(6),
				spr_d2=> spr_d2(6),
				spr_d3=> spr_d3(6),
				color => spr_color(6),
				active=> active(6));

	shifter7: vpd_sprite_shifter
	port map(clk	=> clk,
				x		=> x(7 downto 0),
				spr_x	=> spr_x(7),
				spr_d0=> spr_d0(7),
				spr_d1=> spr_d1(7),
				spr_d2=> spr_d2(7),
				spr_d3=> spr_d3(7),
				color => spr_color(7),
				active=> active(7));
				

	process (clk)
		variable i: integer range 0 to 7;
	begin
		if rising_edge(clk) then
			if x<256 then
			
			elsif x<320 then
				vram_a(13 downto 8) <= address;
				vram_a(7 downto 0) <= "00" & std_logic_vector(x(5 downto 0));
				
			elsif x<384 then
				i := to_integer(x(5 downto 3));
				if x(2)='0' then
					vram_a(13 downto 8) <= address;
					case x(2 downto 0) is
					when "000" => vram_a(7 downto 0) <=  "00" & index(i);
					when "001" => vram_a(7 downto 0) <= "1" & index(i) & "1";
					when "010" => vram_a(7 downto 0) <= "1" & index(i) & "0";
					when others=>
					end case;
				else
					vram_a(13) <= char_high_bit;
					vram_a(12 downto 6) <= spr_n(7 downto 1);
					if tall='1' then
						vram_a(5) <= std_logic(spr_y(3));
					else
						vram_a(5) <= spr_n(0);
					end if;
					vram_a(4 downto 2) <= spr_y(2 downto 0);
					vram_a(1 downto 0) <= std_logic_vector(x(1 downto 0));
				end if;
			end if;
		end if;
	end process;

	process (clk)
		variable i: integer range 0 to 7;
		variable y9 : unsigned(8 downto 0);
		variable d9 : unsigned(8 downto 0);
		variable delta : unsigned(8 downto 0);
		variable x2		: unsigned(8 downto 0);
	begin
		if rising_edge(clk) then
			y9 := "0"&y;
			d9 := "0"&unsigned(vram_D);
			delta := y9-d9;
			x2 := x-2;
			
			if x2<255 then

			elsif x2=255 then
				count <= 0;
				enable <= (others=>'0');
				
			elsif x2<320 then
				if 0<=delta and ((delta<8 and tall='0') or (delta<16 and tall='1')) then
					if count<8 then
						index(count) <= std_logic_vector(x2(5 downto 0));
						enable(count) <= '1';
						count <= count+1;
					end if;
				end if;
				
			elsif x2<384 then
				i := to_integer(x2(5 downto 3));
				case x2(2 downto 0) is
				when "000" => spr_y <= std_logic_vector(delta(3 downto 0));
				when "001" => spr_n <= vram_d;
				when "010" => spr_x(i)	<= unsigned(vram_d);
				when "100" => spr_d0(i)	<= vram_d;
				when "101" => spr_d1(i)	<= vram_d;
				when "110" => spr_d2(i)	<= vram_d;
				when "111" => spr_d3(i)	<= vram_d;
				when others=>
				end case;
			end if;
		end if;
	end process;

	process (clk)
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

