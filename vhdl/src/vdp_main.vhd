library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vdp_main is
	port (clk				: in  std_logic;			
			vram_A			: out std_logic_vector(13 downto 0);
			vram_D			: in  std_logic_vector(7 downto 0);
			cram_A			: out std_logic_vector(4 downto 0);
			cram_D			: in  std_logic_vector(5 downto 0);
			sync				: out std_logic;
			color				: out std_logic_vector (5 downto 0);
			line_visible	: out STD_lOGIC;
			line_even		: out STD_lOGIC;
			irq_n				: out std_logic;
					
			pal				: in  std_logic;
			display_on		: in  std_logic;
			mask_column0	: in  std_logic;
			overscan			: in  std_logic_vector (3 downto 0);

			bg_address		: in  std_logic_vector (2 downto 0);
			bg_scroll_x		: in  unsigned(7 downto 0);
			bg_scroll_y		: in  unsigned(7 downto 0);
			
			irq_frame_en	: in  std_logic;
			irq_line_en		: in  std_logic;
			irq_line_count	: in  unsigned(7 downto 0);
			
			spr_address		: in  std_logic_vector (5 downto 0);
			spr_high_bit	: in  std_logic;
			spr_shift		: in  std_logic;	
			spr_tall			: in  std_logic);	
end vdp_main;

architecture Behavioral of vdp_main is
	
	component vdp_background is
	port (clk				: in  std_logic;
			reset				: in  std_logic;
			address			: in  std_logic_vector(2 downto 0);
			scroll_x			: in  unsigned(7 downto 0);
			y					: in  unsigned(7 downto 0);
			vram_A			: out std_logic_vector(13 downto 0);
			vram_D			: in  std_logic_vector(7 downto 0);
			color				: out std_logic_vector(4 downto 0);
			priority			: out std_logic);
	end component;
	
	component vdp_sprites is
	port (clk				: in  std_logic;
			address			: in  std_logic_vector(5 downto 0);
			char_high_bit	: in  std_logic;
			tall				: in  STD_LOGIC;
			x					: in  unsigned(8 downto 0);
			y					: in  unsigned(7 downto 0);
			vram_A			: out std_logic_vector(13 downto 0);
			vram_D			: in  std_logic_vector(7 downto 0);
			color				: out std_logic_vector(3 downto 0));
	end component;

	signal hcount			: unsigned(8 downto 0) := (others => '0');
	signal vcount			: unsigned(8 downto 0) := "000101000";

	signal x					: unsigned(8 downto 0);
	signal y					: unsigned(7 downto 0);
	signal line_reset		: std_logic;
	
	signal bg_vram_A		: std_logic_vector(13 downto 0);
	signal bg_color		: std_logic_vector(4 downto 0);
	signal bg_priority	: std_logic;
	
	signal spr_vram_A		: std_logic_vector(13 downto 0);
	signal spr_color		: std_logic_vector(3 downto 0);

	signal irq_counter	: unsigned(3 downto 0) := (others=>'0');
	signal vbl_irq			: std_logic;
	signal hbl_irq			: std_logic;

begin
		
	vdp_bg_inst: vdp_background
	port map (
		clk			=> clk,
		address		=> bg_address,
		scroll_x 	=> (others=>'0'),
		reset			=> line_reset,
		y				=> y,
		
		vram_A		=> bg_vram_A,
		vram_D		=> vram_D,		
		color			=> bg_color,
		priority		=> bg_priority);
		
	vdp_spr_inst: vdp_sprites
	port map (
		clk				=> clk,
		address			=> spr_address,
		char_high_bit	=> spr_high_bit,
		tall				=> spr_tall,
		x					=> x,
		y					=> y,
		
		vram_A			=> spr_vram_A,
		vram_D			=> vram_D,		
		color				=> spr_color);
		

	process (clk)
	begin
		if rising_edge(clk) then
			if (pal='1' and hcount=511) or (pal='0' and hcount=509) then
				hcount <= (others => '0');
				if (pal='1' and vcount=311) or (pal='0' and vcount=261)  then
					vcount <= (others=>'0');
					if irq_frame_en='1' then
						vbl_irq <= '1';
					end if;
				else
					vcount <= vcount + 1;
				end if;
			else
				hcount <= hcount + 1;
				vbl_irq <= '0';
				hbl_irq <= '0';
			end if;

			if hcount=156 then
				line_reset <= '1';
				x <= "111110000";
				if pal='1' then
					y <= (vcount(7 downto 0)-64);
				else
					y <= (vcount(7 downto 0)-48);
				end if;
			else
				line_reset <= '0';
				x <= x+1;
			end if;
		end if;
	end process;
	
	process (clk)
	begin
		if rising_edge(clk) then
			if vcount<7 then
				if vcount<3 then
					if hcount<19 or (hcount>=256 and hcount<275) then
						sync <= '0';
					else
						sync <= '1';
					end if;
				elsif vcount<5 then
					if hcount<219 or (hcount>=256 and hcount<475) then
						sync <= '0';
					else
						sync <= '1';
					end if;
				elsif vcount=5 then
					if hcount<219 or (hcount>=256 and hcount<275) then
						sync <= '0';
					else
						sync <= '1';
					end if;
				elsif vcount<7 then
					if hcount<19 or (hcount>=256 and hcount<275) then
						sync <= '0';
					else
						sync <= '1';
					end if;
				end if;
				line_visible <= '0';
				color <= "000000";
				
			else
				if hcount<37 then
					sync <= '0';
				else
					sync <= '1';
				end if;
				line_visible <= '1';
				
				if vcount<25 or hcount<84 or hcount>=500 then
					color <= "000000";
				else
					color <= cram_D;
				end if;
			end if;
		end if;
	end process;
	
	line_even <= vcount(0);

	process (x, y)
		variable spr_active : std_logic;
		variable bg_active : std_logic;
	begin
		if x<256 and y<192 then
			spr_active := spr_color(0) or spr_color(1) or spr_color(2) or spr_color(3);
			bg_active := bg_color(0) or bg_color(1) or bg_color(2) or bg_color(3);
			if (bg_priority='0' and spr_active='1') or (bg_priority='1' and bg_active='0') then
				cram_A <= "1"&spr_color;
			else
				cram_A <= bg_color;
			end if;
		else
			cram_A <= "1"&overscan;
		end if;
		
		if x>=256 and x<384 then
			vram_A <= spr_vram_A; -- sprite data
		else
			vram_A <= bg_vram_A; -- background data
		end if;
	end process;
	
	process (clk)
	begin
		if rising_edge(clk) then
			if vbl_irq='1' or hbl_irq='1' then
				irq_counter <= to_unsigned(15,4);
				IRQ_n <= '0';
			elsif irq_counter=0 then
				IRQ_n <= '1';
			else
				irq_counter <= irq_counter-1;
				IRQ_n <= '0';
			end if;
		end if;
	end process;


end Behavioral;

