library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tv_video is
	Port (
		clk8:				in  STD_LOGIC;
		clk64:			in  STD_LOGIC;
		x:					out unsigned(8 downto 0);
		y:					out unsigned(7 downto 0);
		vblank:			out STD_LOGIC;
		hblank:			out STD_LOGIC;
		color:			in  STD_LOGIC_VECTOR(5 downto 0);
		video:			out STD_LOGIC_VECTOR(6 downto 1));
end tv_video;

architecture Behavioral of tv_video is
	
	component color_encoder is
	Port (
		clk:				in  STD_LOGIC;
		pal:				in  STD_LOGIC;
		sync:				in  STD_LOGIC;
		line_visible:	in  STD_LOGIC;
		line_even:		in  STD_LOGIC;
		color:			in  STD_LOGIC_VECTOR (5 downto 0);
		output:			out STD_LOGIC_VECTOR (5 downto 0));
	end component;

	signal hcount:			unsigned(8 downto 0) := (others => '0');
	signal vcount:			unsigned(8 downto 0) := (others => '0');
	signal y9:				unsigned(8 downto 0);
	
	signal in_vbl:			std_logic;
	signal screen_sync:	std_logic;
	signal vbl_sync:		std_logic;
	
	signal sync:			std_logic;
	signal line_visible:	std_logic;
	signal line_even:		std_logic;

begin

	process (clk8)
	begin
		if rising_edge(clk8) then
			if hcount=511 then
				hcount <= (others => '0');
				if vcount=311 then
					vcount <= (others=>'0');
				else
					vcount <= vcount + 1;
				end if;
			else
				hcount <= hcount + 1;
			end if;
		end if;
	end process;
	
	process (hcount)
	begin
		if hcount<37 then
			screen_sync <= '0';
		else
			screen_sync <= '1';
		end if;
	end process;
	
	process (vcount)
	begin
		if vcount>=5 and vcount<309 then
			in_vbl <= '0';
		else
			in_vbl <= '1';
		end if;
	end process;
	
	x					<= hcount-(37+12+18+17+80);
	y9					<= vcount-64 when vcount<256 else (others=>'1');
	y					<= y9(7 downto 0);
	vblank			<= '1' when hcount=0 and vcount=0 else '0';
	hblank			<= '1' when hcount=0 else '0';
	line_visible	<= not in_vbl;
	line_even		<= not vcount(0);
	
	process (vcount,hcount)
	begin
		if vcount<2 then
			if hcount<240 or (hcount>=256 and hcount<496) then
				vbl_sync <= '0';
			else
				vbl_sync <= '1';
			end if;
		elsif vcount=2 then
			if hcount<240 or (hcount>=256 and hcount<272) then
				vbl_sync <= '0';
			else
				vbl_sync <= '1';
			end if;
		else
			if hcount<16 or (hcount>=256 and hcount<272) then
				vbl_sync <= '0';
			else
				vbl_sync <= '1';
			end if;
		end if;
	end process;
	
	process (in_vbl,screen_sync,vbl_sync)
	begin
		if in_vbl='1' then
			sync <= vbl_sync;
		else
			sync <= screen_sync;
		end if;
	end process;
	
	encode_inst: color_encoder
	port map (
		clk				=> clk64,
		pal				=> '1',
		sync				=> sync,
		line_visible	=> line_visible,
		line_even		=> line_even,
		color				=> color,
		output			=> video);
	
end Behavioral;

