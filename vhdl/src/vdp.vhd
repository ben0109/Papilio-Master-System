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
			line_even		: out STD_lOGIC);
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


	component vram is
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
	
	component color_ram is
	port (clk	: in  std_logic;
			a		: in  std_logic_vector(4 downto 0);
			we		: in  std_logic;
			d		: in  std_logic_vector(5 downto 0);
			spo	: out std_logic_vector(5 downto 0);
			dpra	: in  std_logic_vector(4 downto 0);
			dpo	: out std_logic_vector(5 downto 0));
	end component;


	signal hcount			: unsigned(8 downto 0) := (others => '0');
	signal vcount			: unsigned(8 downto 0) := (others => '0');
	
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

	signal y					: unsigned(7 downto 0);
	
	signal in_vbl			: std_logic;
	signal screen_sync	: std_logic;
	signal vbl_sync		: std_logic;
	
	signal address_ff		: std_logic := '0';
	signal address			: unsigned(15 downto 0);

	signal cram_A_in		: std_logic_vector(4 downto 0);
	signal cram_D_in		: std_logic_vector(5 downto 0);
	signal cram_A_out		: std_logic_vector(4 downto 0);
	signal cram_D_out		: std_logic_vector(5 downto 0);
	signal cram_WE			: std_logic;
	
	signal bg_address		: std_logic_vector(2 downto 0);
	signal bg_reset		: std_logic;
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

	cram: color_ram
	port map (
		clk => clk,
		we	 => cram_WE,
		a	 => cram_A_in,
		d	 => cram_D_in,
		spo => open,
		dpra=> cram_A_out,
		dpo => cram_D_out);

	vram_inst: vram
	port map (
		clk	=> clk,
		ain	=> vram_A_in,
		din	=> vram_D_in,
		aout	=> vram_A_out,
		dout	=> vram_D_out,
		en		=> '1',
		we		=> vram_WE);
		
	vdp_background_inst: vdp_background
	port map (
		clk => clk,
		reset => bg_reset,
		map_base => bg_address,
		scroll_x => (others=>'0'),
		y => y,
		
		vram_address => bg_vram_A,
		vram_data => vram_D_out,
		vram_read => vram_read,
		color => bg_color);
		

	process (clk, vcount, hcount)
	begin
		if rising_edge(clk) then
			if hcount=511 then
				hcount <= (others => '0');
				if vcount=311 then
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
		end if;
	end process;
	
	process (hcount,vcount)
	begin
--		x <= std_logic_vector(hcount-(37+47+80));
		y <= (vcount-64);
		if hcount=248+(37+47+80) then
			bg_reset <= '1';
		else
			bg_reset <= '0';
		end if;
	end process;
	
	process (display_on, hcount, vcount)
	begin
		if display_on='0' then
			vram_bus_ctrl <= "00";
		else
			if hcount>=(37+47+80) and hcount<(37+47+80+256) then
				vram_bus_ctrl <= "10";
			else
				vram_bus_ctrl <= "11";
			end if;
		end if;
	end process;

	vram_A_out <= bg_vram_A;

	process (hcount, bg_color)
	begin
		if hcount>=(37+47+80) and hcount<(37+47+80+256) then
			cram_A_out <= bg_color;
		else
			cram_A_out <= "10000";
		end if;
	end process;
	
	process(in_vbl,hcount,cram_D_out)
	begin
		if in_vbl='1' or hcount<(37+47) or hcount>=(37+47+416) then
			color <= "000000";
		else
			color <= cram_D_out(1 downto 0)&cram_D_out(3 downto 2)&cram_D_out(5 downto 4); -- swap rgb
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
	
	line_visible <= not in_vbl;
	line_even <= vcount(0);
	
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
