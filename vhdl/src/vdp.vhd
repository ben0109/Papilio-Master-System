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
	
	component vdp_main is
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
	
	signal control_A		: std_logic_vector(13 downto 0);
	signal vram_cpu_WE	: std_logic;
	signal vram_vdp_A		: std_logic_vector(13 downto 0);
	signal vram_vdp_D		: std_logic_vector(7 downto 0);
	
	signal cram_cpu_WE	: std_logic;
	signal cram_vdp_A		: std_logic_vector(4 downto 0);
	signal cram_vdp_D		: std_logic_vector(5 downto 0);
			
	signal display_on		: std_logic;
	signal mask_column0	: std_logic;
	signal overscan		: std_logic_vector (3 downto 0);
	
	signal irq_frame_en	: std_logic;
	signal irq_line_en	: std_logic;
	signal irq_line_count: unsigned(7 downto 0);
	
	signal bg_address		: std_logic_vector (2 downto 0);
	signal bg_scroll_x	: unsigned(7 downto 0);
	signal bg_scroll_y	: unsigned(7 downto 0);
	signal spr_address	: std_logic_vector (5 downto 0);
	signal spr_shift		: std_logic;
	signal spr_tall		: std_logic;
	signal spr_high_bit	: std_logic;

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
			
		display_on	=> display_on,
		mask_column0=> mask_column0,
		overscan		=> overscan,
		
		frame_irq_en=> irq_frame_en,
		line_irq_en	=> irq_line_en,
		line_count	=> irq_line_count,
		
		text_address=> bg_address,
		scroll_x		=> bg_scroll_x,
		scroll_y		=> bg_scroll_y,
		spr_address	=> spr_address,
		spr_high_bit=> spr_high_bit,
		shift_spr	=> spr_shift,
		big_sprites	=> spr_tall);
		
	vdp_main_inst: vdp_main
	port map(clk				=> clk,
				vram_A			=> vram_vdp_A,
				vram_D			=> vram_vdp_D,
				cram_A			=> cram_vdp_A,
				cram_D			=> cram_vdp_D,
				sync				=> sync,
				color				=> color,
				line_visible	=> line_visible,
				line_even		=> line_even,
				irq_n				=> irq_n,
						
				pal				=> pal,
				display_on		=> display_on,
				mask_column0	=> mask_column0,
				overscan			=> overscan,
				
				irq_frame_en	=> irq_frame_en,
				irq_line_en		=> irq_line_en,
				irq_line_count	=> irq_line_count,

				bg_address		=> bg_address,
				bg_scroll_x		=> bg_scroll_x,
				bg_scroll_y		=> bg_scroll_y,
				
				spr_address		=> spr_address,
				spr_high_bit	=> spr_high_bit,
				spr_shift		=> spr_shift,
				spr_tall			=> spr_tall);

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
	
end Behavioral;
