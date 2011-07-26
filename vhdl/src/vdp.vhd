library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vdp is
	port (clk 				: in  STD_LOGIC;
			RD_n				: in  STD_LOGIC;
			WR_n				: in  STD_LOGIC;
			IRQ_n				: out STD_LOGIC;
			A					: in  STD_LOGIC_VECTOR (7 downto 0);
			D_in				: in  STD_LOGIC_VECTOR (7 downto 0);
			D_out				: out STD_LOGIC_VECTOR (7 downto 0);
			sync				: out STD_LOGIC;
			color				: out STD_LOGIC_VECTOR (5 downto 0);
			line_visible	: out STD_lOGIC;
			line_even		: out STD_lOGIC;
			pal				: in  STD_LOGIC);
end vdp;

architecture Behavioral of vdp is

	component vdp_control is
	port (clk			: in  STD_LOGIC;
	
			cpu_RD_n		: in  STD_LOGIC;
			cpu_WR_n		: in  STD_LOGIC;
			cpu_A			: in  STD_LOGIC_VECTOR (7 downto 0);
			cpu_D_in		: in  STD_LOGIC_VECTOR (7 downto 0);
			
			A				: out STD_LOGIC_VECTOR (13 downto 0);
			vram_WE		: out STD_LOGIC;
			cram_WE		: out STD_LOGIC;
			
			mask_column0: out STD_LOGIC;
			line_irq_en	: out STD_LOGIC;
			shift_spr	: out STD_LOGIC;			
			display_on	: out STD_LOGIC;
			frame_irq_en: out STD_LOGIC;
			big_sprites	: out STD_LOGIC;
			text_address: out STD_LOGIC_VECTOR (2 downto 0);
			spr_address	: out STD_LOGIC_VECTOR (5 downto 0);
			spr_high_bit: out STD_LOGIC;
			overscan		: out STD_LOGIC_VECTOR (3 downto 0);
			scroll_x		: out unsigned (7 downto 0);
			scroll_y		: out unsigned (7 downto 0);
			line_count	: out unsigned (7 downto 0));
	end component;

	component vdp_vram is
	port (clk		: in  STD_LOGIC;
			cpu_WE	: in  STD_LOGIC;
			cpu_A		: in  STD_LOGIC_VECTOR (13 downto 0);
			cpu_D_in	: in  STD_LOGIC_VECTOR (7 downto 0);
			cpu_D_out: out STD_LOGIC_VECTOR (7 downto 0);
			vdp_A		: in  STD_LOGIC_VECTOR (13 downto 0);
			vdp_D_out: out STD_LOGIC_VECTOR (7 downto 0));
	end component;
	
	component vdp_cram is
	port (clk	: in  std_logic;
			cpu_WE: in  std_logic;
			cpu_A	: in  std_logic_vector(4 downto 0);
			cpu_D	: in  std_logic_vector(5 downto 0);
			vdp_A	: in  std_logic_vector(4 downto 0);
			vdp_D	: out std_logic_vector(5 downto 0));
	end component;
	
	component vdp_background is
	port (clk		: in  std_logic;
			reset		: in  std_logic;
			map_base	: in  std_logic_vector(2 downto 0);
			scroll_x	: in  unsigned(7 downto 0);
			y			: in  unsigned(7 downto 0);
			vram_A	: out std_logic_vector(13 downto 0);
			vram_D	: in  std_logic_vector(7 downto 0);
			color		: out std_logic_vector(4 downto 0);
			priority	: out std_logic);
	end component;
	
	component vdp_sprites is
	port (clk				: in  std_logic;
			table_address	: in  std_logic_vector(5 downto 0);
			char_high_bit	: in  std_logic;
			big_sprites		: in  STD_LOGIC;
			x					: in  unsigned(8 downto 0);
			y					: in  unsigned(7 downto 0);
			vram_A			: out std_logic_vector(13 downto 0);
			vram_D			: in  std_logic_vector(7 downto 0);
			color				: out std_logic_vector(3 downto 0));
	end component;
	
	signal control_A		: std_logic_vector(13 downto 0);
	signal vram_cpu_WE	: std_logic;
	signal vram_vdp_A		: std_logic_vector(13 downto 0);
	signal vram_vdp_D		: std_logic_vector(7 downto 0);
	
	signal cram_cpu_WE	: std_logic;
	signal cram_vdp_A		: std_logic_vector(4 downto 0);
	signal cram_vdp_D		: std_logic_vector(5 downto 0);

	signal mask_column0	: std_logic;
	signal line_irq_en	: std_logic;
	signal shift_spr		: std_logic;			
	signal display_on		: std_logic;
	signal frame_irq_en	: std_logic;
	signal big_sprites	: std_logic;
	signal text_address	: std_logic_vector (2 downto 0);
	signal spr_address	: std_logic_vector (5 downto 0);
	signal spr_high_bit	: std_logic;
	signal overscan		: std_logic_vector (3 downto 0);
	signal scroll_x		: unsigned(7 downto 0);
	signal scroll_y		: unsigned(7 downto 0);
	signal line_count		: unsigned(7 downto 0);

	signal hcount			: unsigned(8 downto 0) := (others => '0');
	signal vcount			: unsigned(8 downto 0) := "000101000";

	signal x					: unsigned(8 downto 0);
	signal y					: unsigned(7 downto 0);
	signal line_reset		: std_logic;

	signal bg_address		: std_logic_vector(2 downto 0);
	signal bg_vram_A		: std_logic_vector(13 downto 0);
	signal bg_color		: std_logic_vector(4 downto 0);
	signal bg_priority	: std_logic;
	
	signal spr_vram_A		: std_logic_vector(13 downto 0);
	signal spr_color		: std_logic_vector(3 downto 0);

	signal irq_counter	: unsigned(3 downto 0) := (others=>'0');
	signal vbl_irq			: std_logic;
	signal hbl_irq			: std_logic;
	
begin

	vdp_control_inst: vdp_control
	port map (
		clk			=> clk,
		
		cpu_RD_n		=> RD_n,
		cpu_WR_n		=> WR_n,
		cpu_A			=> A,
		cpu_D_in		=> D_in,

		A				=> control_A,
		vram_WE		=> vram_cpu_WE,
		cram_WE		=> cram_cpu_WE,
			
		mask_column0=> mask_column0,
		line_irq_en	=> line_irq_en,
		shift_spr	=> shift_spr,
		display_on	=> display_on,
		frame_irq_en=> frame_irq_en,
		big_sprites	=> big_sprites,
		text_address=> bg_address,
		spr_address	=> spr_address,
		spr_high_bit=> spr_high_bit,
		overscan		=> overscan,
		scroll_x		=> scroll_x,
		scroll_y		=> scroll_y,
		line_count	=> line_count);

	vdp_vram_inst: vdp_vram
	port map (
		clk		=> clk,
		cpu_WE	=> vram_cpu_WE,
		cpu_A		=> control_A,
		cpu_D_in	=> D_in,
		cpu_D_out=> D_out,
		vdp_A		=> vram_vdp_A,
		vdp_D_out=> vram_vdp_D);

	vdp_cram_inst: vdp_cram
	port map (
		clk 		=> clk,
		cpu_WE	=> cram_cpu_WE,
		cpu_A 	=> control_A(4 downto 0),
		cpu_D		=> D_in(5 downto 0),
		vdp_A		=> cram_vdp_A,
		vdp_D		=> cram_vdp_D);
		
	vdp_bg_inst: vdp_background
	port map (
		clk		=> clk,
		map_base => bg_address,
		scroll_x => (others=>'0'),
		reset		=> line_reset,
		y			=> y,
		
		vram_A	=> bg_vram_A,
		vram_D	=> vram_vdp_D,		
		color		=> bg_color,
		priority	=> bg_priority);
		
	vdp_spr_inst: vdp_sprites
	port map (
		clk				=> clk,
		table_address	=> spr_address,
		char_high_bit	=> spr_high_bit,
		big_sprites		=> big_sprites,
		x					=> x,
		y					=> y,
		
		vram_A			=> spr_vram_A,
		vram_D			=> vram_vdp_D,		
		color				=> spr_color);
		

	process (clk)
	begin
		if rising_edge(clk) then
			if (pal='1' and hcount=511) or (pal='0' and hcount=509) then
				hcount <= (others => '0');
				if (pal='1' and vcount=311) or (pal='0' and vcount=261)  then
					vcount <= (others=>'0');
					if frame_irq_en='1' then
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
					color <= cram_vdp_D;
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
				cram_vdp_A <= "1"&spr_color;
			else
				cram_vdp_A <= bg_color;
			end if;
		else
			cram_vdp_A <= "1"&overscan;
		end if;
		
		if x>=256 and x<384 then
			vram_vdp_A <= spr_vram_A; -- sprite data
		else
			vram_vdp_A <= bg_vram_A; -- background data
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
