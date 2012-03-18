library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vdp_main is
	port (
		clk:					in  std_logic;			
		vram_A:				out std_logic_vector(13 downto 0);
		vram_D:				in  std_logic_vector(7 downto 0);
		cram_A:				out std_logic_vector(4 downto 0);
		cram_D:				in  std_logic_vector(5 downto 0);
			
		x:						unsigned(8 downto 0);
		y:						unsigned(7 downto 0);
		line_reset:			std_logic;
		frame_reset:		std_logic;
			
		color:				out std_logic_vector (5 downto 0);
		irq_n:				out std_logic;
					
		display_on:			in  std_logic;
		mask_column0:		in  std_logic;
		overscan:			in  std_logic_vector (3 downto 0);

		bg_address:			in  std_logic_vector (2 downto 0);
		bg_scroll_x:		in  unsigned(7 downto 0);
		bg_scroll_y:		in  unsigned(7 downto 0);
			
		irq_frame_en:		in  std_logic;
		irq_line_en:		in  std_logic;
		irq_line_count:	in  unsigned(7 downto 0);
			
		spr_address:		in  std_logic_vector (5 downto 0);
		spr_high_bit:		in  std_logic;
		spr_shift:			in  std_logic;	
		spr_tall:			in  std_logic);	
end vdp_main;

architecture Behavioral of vdp_main is
	
	component vdp_background is
	port (
		clk:				in  std_logic;
		reset:			in  std_logic;
		address:			in  std_logic_vector(2 downto 0);
		scroll_x:		in  unsigned(7 downto 0);
		y:					in  unsigned(7 downto 0);
		vram_A:			out std_logic_vector(13 downto 0);
		vram_D:			in  std_logic_vector(7 downto 0);
		color:			out std_logic_vector(4 downto 0);
		priority:		out std_logic);
	end component;
	
	component vdp_sprites is
	port (
		clk:				in  std_logic;
		address:			in  std_logic_vector(5 downto 0);
		char_high_bit:	in  std_logic;
		tall:				in  STD_LOGIC;
		x:					in  unsigned(8 downto 0);
		y:					in  unsigned(7 downto 0);
		vram_A:			out std_logic_vector(13 downto 0);
		vram_D:			in  std_logic_vector(7 downto 0);
		color:			out std_logic_vector(3 downto 0));
	end component;

	signal bg_vram_A:		std_logic_vector(13 downto 0);
	signal bg_color:		std_logic_vector(4 downto 0);
	signal bg_priority:	std_logic;
	
	signal spr_vram_A:	std_logic_vector(13 downto 0);
	signal spr_color:		std_logic_vector(3 downto 0);

	signal irq_counter:	unsigned(5 downto 0) := (others=>'0');
	signal vbl_irq:		std_logic;
	signal hbl_irq:		std_logic;

begin
		
	vdp_bg_inst: vdp_background
	port map (
		clk				=> clk,
		address			=> bg_address,
		scroll_x 		=> (others=>'0'),
		reset				=> line_reset,
		y					=> y,
		
		vram_A			=> bg_vram_A,
		vram_D			=> vram_D,		
		color				=> bg_color,
		priority			=> bg_priority);
		
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
		

	vbl_irq <= frame_reset or irq_frame_en;
	hbl_irq <= '0';
	
	color <= cram_D;

	process (x, y, spr_color, bg_color, overscan)
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
	end process;
	
	vram_A <= spr_vram_A when x>=256 and x<384 else bg_vram_A;
	
	process (clk)
	begin
		if rising_edge(clk) then
			if vbl_irq='1' or hbl_irq='1' then
				irq_counter <= (others=>'1');
			elsif irq_counter>0 then
				irq_counter <= irq_counter-1;
			end if;
		end if;
	end process;
	IRQ_n <= '0' when irq_counter>0 else '1';

end Behavioral;

