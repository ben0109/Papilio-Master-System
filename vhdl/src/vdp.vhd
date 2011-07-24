library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vdp is
	port (clk 				: in  STD_LOGIC;
			clk_n				: in  STD_LOGIC;
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
	port (clk				: in  STD_LOGIC;
			RD_n				: in  STD_LOGIC;
			WR_n				: in  STD_LOGIC;
			A					: in  STD_LOGIC_VECTOR (7 downto 0);
			D_in				: in  STD_LOGIC_VECTOR (7 downto 0);
			D_out				: out STD_LOGIC_VECTOR (7 downto 0);
			
			mask_column0	: out STD_LOGIC;
			line_irq_en		: out STD_LOGIC;
			shift_spr		: out STD_LOGIC;			
			display_on		: out STD_LOGIC;
			frame_irq_en	: out STD_LOGIC;
			big_sprites		: out STD_LOGIC;
			text_address	: out STD_LOGIC_VECTOR (2 downto 0);
			spr_address		: out STD_LOGIC_VECTOR (5 downto 0);
			spr_high_bit	: out STD_LOGIC;
			overscan			: out STD_LOGIC_VECTOR (3 downto 0);
			scroll_x			: out unsigned (7 downto 0);
			scroll_y			: out unsigned (7 downto 0);
			line_count		: out unsigned (7 downto 0);
			
			vram_A			: out STD_LOGIC_VECTOR (13 downto 0);
			vram_WE			: out STD_LOGIC;
			vram_D_in		: out STD_LOGIC_VECTOR (7 downto 0);
			vram_D_out		: in  STD_LOGIC_VECTOR (7 downto 0);
			
			cram_A			: out STD_LOGIC_VECTOR (4 downto 0);
			cram_WE			: out STD_LOGIC;
			cram_D_in		: out STD_LOGIC_VECTOR (5 downto 0);
			cram_D_out		: in  STD_LOGIC_VECTOR (5 downto 0));
	end component;


	component vdp_vram is
	port (clk	: in  STD_LOGIC;
			en		: in  STD_LOGIC;
			we		: in  STD_LOGIC;
			ain	: in  STD_LOGIC_VECTOR (13 downto 0);
			din	: in  STD_LOGIC_VECTOR (7 downto 0);
			aout	: in  STD_LOGIC_VECTOR (13 downto 0);
			dout	: out STD_LOGIC_VECTOR (7 downto 0));
	end component;
	
	component vdp_background is
	port (clk			:in std_logic;
			reset			:in std_logic;
			map_base		:in std_logic_vector(2 downto 0);
			scroll_x		:in unsigned(7 downto 0);
			y				:in unsigned(7 downto 0);

			vram_address:out std_logic_vector(13 downto 0);
			vram_read	:out std_logic;
			vram_data	:in std_logic_vector(7 downto 0);

			color			:out std_logic_vector(4 downto 0));
	end component;
	
	component vdp_cram is
	port (clk		: in  std_logic;
			cpu_we	: in  std_logic;
			cpu_a		: in  std_logic_vector(4 downto 0);
			cpu_d_in	: in  std_logic_vector(5 downto 0);
			cpu_d_out: out std_logic_vector(5 downto 0);
			vdp_a		: in  std_logic_vector(4 downto 0);
			vdp_d_out: out std_logic_vector(5 downto 0));
	end component;

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
	signal vcount			: unsigned(8 downto 0) := (others => '0');

	signal x					: unsigned(8 downto 0);
	signal y					: unsigned(7 downto 0);
	signal line_reset		: std_logic;
	
	signal address_ff		: std_logic := '0';
	signal address			: unsigned(15 downto 0);

	signal cram_A_in		: std_logic_vector(4 downto 0);
	signal cram_D_in		: std_logic_vector(5 downto 0);
	signal cram_A_out		: std_logic_vector(4 downto 0);
	signal cram_D_out		: std_logic_vector(5 downto 0);
	signal cram_WE			: std_logic;
	
	signal bg_address		: std_logic_vector(2 downto 0);
	signal bg_vram_A		: std_logic_vector(13 downto 0);
	signal bg_color		: std_logic_vector(4 downto 0);
	signal spr_reset		: std_logic;
	signal spr_vram_A		: std_logic_vector(13 downto 0);
	signal spr_color		: std_logic_vector(3 downto 0);
	
	signal vram_A_in		: std_logic_vector(13 downto 0);
	signal vram_D_in		: std_logic_vector(7 downto 0);
	signal vram_A_out		: std_logic_vector(13 downto 0);
	signal vram_D_out		: std_logic_vector(7 downto 0);
	signal vram_read		: std_logic;
	signal vram_WE			: std_logic;

	signal vram_bus_ctrl	: std_logic_vector(1 downto 0);

	signal irq_counter	: unsigned(3 downto 0) := (others=>'0');
	signal vbl_irq			: std_logic;
	signal hbl_irq			: std_logic;
begin

	vdp_control_inst: vdp_control
	port map (
		clk			=> clk,
		RD_n			=> RD_n,
		WR_n			=> WR_n,
		A				=> A,
		D_in			=> D_in,
		D_out			=> D_out,
			
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
		line_count	=> line_count,
			
		vram_A		=> vram_A_in,
		vram_WE		=> vram_WE,
		vram_D_in	=> vram_D_in,
		vram_D_out	=> vram_D_out,
			
		cram_A		=> cram_A_in,
		cram_WE		=> cram_WE,
		cram_D_in	=> cram_D_in,
		cram_D_out	=> cram_D_out);

	vdp_cram_inst: vdp_cram
	port map (
		clk 		=> clk,
		cpu_we	=> cram_WE,
		cpu_a		=> cram_A_in,
		cpu_d_in	=> cram_D_in,
		cpu_d_out=> open,
		vdp_a		=> cram_A_out,
		vdp_d_out=> cram_D_out);

	vdp_vram_inst: vdp_vram
	port map (
		clk	=> clk_n,
		ain	=> vram_A_in,
		din	=> vram_D_in,
		aout	=> vram_A_out,
		dout	=> vram_D_out,
		en		=> '1',
		we		=> vram_WE);
		
	vdp_background_inst: vdp_background
	port map (
		clk		=> clk,
		reset		=> line_reset,
		map_base => bg_address,
		scroll_x => (others=>'0'),
		y			=> y,
		
		vram_address => bg_vram_A,
		vram_data => vram_D_out,
		vram_read => vram_read,
		color => bg_color);
		

	process (clk, vcount, hcount)
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
				x <= "111111000";
				if pal='1' then
					y <= (vcount-64);
				else
					y <= (vcount-48);
				end if;
			else
				line_reset <= '0';
				x <= x+1;
			end if;
		end if;
	end process;
	
	process (vcount, hcount,cram_D_out)
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
					color <= cram_D_out;
				end if;
			end if;
		end if;
	end process;
	
	line_even <= vcount(0);

	process (x, y)
	begin
		if x<256 and y<192 then
			cram_A_out <= bg_color;
		else
			cram_A_out <= "1"&overscan;
		end if;
		
		if x>=256 and x<504 then
--			vram_A_out <= spr_vram_A; -- sprite data
		else
			vram_A_out <= bg_vram_A; -- background data
		end if;
	end process;
	
	process (clk,vbl_irq,hbl_irq)
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

--	IRQ_n <= vbl_irq;
	
end Behavioral;
