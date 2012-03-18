library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main is
	port (
		clk:			in  STD_LOGIC;

		joy_1_gnd:	out STD_LOGIC;
		joy_1:		in	STD_LOGIC_VECTOR(5 downto 0);

--		tv_ground:	out STD_LOGIC;
--		video_out:	out STD_LOGIC_VECTOR(5 downto 0);
--		audio_out:	out STD_LOGIC;
		red:			out STD_LOGIC_VECTOR(1 downto 0);
		green:		out STD_LOGIC_VECTOR(1 downto 0);
		blue:			out STD_LOGIC_VECTOR(1 downto 0);
		hsync:		out STD_LOGIC;
		vsync:		out STD_LOGIC;

		spi_do:		in  STD_LOGIC;
		spi_sclk:	out STD_LOGIC;
		spi_di:		out STD_LOGIC;
		spi_cs_n:	out STD_LOGIC;

		tx:			out STD_LOGIC);
end main;

architecture Behavioral of main is

	component clock is
   port (
		CLKIN_IN			: in  std_logic; 
		CLKIN_IBUFG_OUT: out std_logic;         
		CLKFX_OUT 		: out std_logic;
		CLKFX180_OUT	: out std_logic;
		CLK2X_OUT		: out std_logic);
	end component;
	
--	component dummy_z80 is
	component T80s is
	generic(
		Mode : integer := 0;	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
		T2Write : integer := 0;	-- 0 => WR_n active in T3, /=0 => WR_n active in T2
		IOWait : integer := 1	-- 0 => Single cycle I/O, 1 => Std I/O cycle
	);
	port(
		RESET_n:		in std_logic;
		CLK_n:		in std_logic;
		WAIT_n:		in std_logic;
		INT_n	:		in std_logic;
		NMI_n:		in std_logic;
		BUSRQ_n:		in std_logic;
		M1_n:			out std_logic;
		MREQ_n:		out std_logic;
		IORQ_n:		out std_logic;
		RD_n:			out std_logic;
		WR_n:			out std_logic;
		RFSH_n:		out std_logic;
		HALT_n:		out std_logic;
		BUSAK_n:		out std_logic;
		A:				out std_logic_vector(15 downto 0);
		DI:			in std_logic_vector(7 downto 0);
		DO:			out std_logic_vector(7 downto 0)
	);
	end component;
		
	component vdp_vga_timing is
	port (
		clk_16:		in  std_logic;
		x: 			out unsigned(8 downto 0);
		y:				out unsigned(7 downto 0);
		line_reset:	out std_logic;
		frame_reset:out std_logic;
		color:		in std_logic_vector(5 downto 0);
		hsync:		out std_logic;
		vsync:		out std_logic;
		red:			out std_logic_vector(1 downto 0);
		green:		out std_logic_vector(1 downto 0);
		blue:			out std_logic_vector(1 downto 0));
	end component;

	component vdp is
	port (
		clk:			in  STD_LOGIC;
		RD_n:			in  STD_LOGIC;
		WR_n:			in  STD_LOGIC;
		IRQ_n:		out STD_LOGIC;
		A:				in  STD_LOGIC_VECTOR(7 downto 0);
		D_in:			in  STD_LOGIC_VECTOR(7 downto 0);
		D_out:		out STD_LOGIC_VECTOR(7 downto 0);			
		x:				in  unsigned(8 downto 0);
		y:				in  unsigned(7 downto 0);
		line_reset:	in  std_logic;
		frame_reset:in  std_logic;			
		color: 		out std_logic_vector (5 downto 0));
	end component;
	
	component psg is
   port (
		clk:			in  STD_LOGIC;
		WR_n:			in  STD_LOGIC;
		D_in:			in  STD_LOGIC_VECTOR (7 downto 0);
		output:		out STD_LOGIC);
	end component;
	
	component io is
   port (
		clk:			in  STD_LOGIC;
		WR_n:			in  STD_LOGIC;
		RD_n:			in  STD_LOGIC;
		A:				in  STD_LOGIC_VECTOR (7 downto 0);
		D_in:			in  STD_LOGIC_VECTOR (7 downto 0);
		D_out:		out STD_LOGIC_VECTOR (7 downto 0);
		J1_up:		in  STD_LOGIC;
		J1_down:		in  STD_LOGIC;
		J1_left:		in  STD_LOGIC;
		J1_right:	in  STD_LOGIC;
		J1_tl:		in  STD_LOGIC;
		J1_tr:		in  STD_LOGIC;
		J2_up:		in  STD_LOGIC;
		J2_down:		in  STD_LOGIC;
		J2_left:		in  STD_LOGIC;
		J2_right:	in  STD_LOGIC;
		J2_tl:		in  STD_LOGIC;
		J2_tr:		in  STD_LOGIC;
		RESET:		in  STD_LOGIC);
	end component;

	component ram is
	port (
		clk:			in  STD_LOGIC;
		RD_n:			in  STD_LOGIC;
		WR_n:			in  STD_LOGIC;
		A:				in  STD_LOGIC_VECTOR(12 downto 0);
		D_in:			in  STD_LOGIC_VECTOR(7 downto 0);
		D_out:		out STD_LOGIC_VECTOR(7 downto 0));
	end component;

	component boot_rom is
	port (
		clk:			in  STD_LOGIC;
		RD_n:			in  STD_LOGIC;
		A:				in  STD_LOGIC_VECTOR(12 downto 0);
		D_out:		out STD_LOGIC_VECTOR(7 downto 0));
	end component;

	
--	component dummy_spi is
	component spi is
	port (
		clk:			in  STD_LOGIC;
		RD_n:			in  STD_LOGIC;
		WR_n:			in  STD_LOGIC;
		A:				in  STD_LOGIC_VECTOR (7 downto 0);
		D_in:			in  STD_LOGIC_VECTOR (7 downto 0);
		D_out:		out STD_LOGIC_VECTOR (7 downto 0);
			
		cs_n:			out STD_LOGIC;
		sclk:			out STD_LOGIC;
		miso:			in  STD_LOGIC;
		mosi:			out STD_LOGIC);
	end component;

	component uart_tx is
	port (
		clk:  		in  std_logic;
		WR_n:			in  std_logic;
		D_in: 		in  std_logic_vector(7 downto 0);
		serial_out:	out std_logic;
		ready:		out std_logic);
	end component;
	
	signal clk32			: std_logic;
	signal clk8				: std_logic;
	signal clk8_n			: std_logic;
	signal clk16			: std_logic := '0';
	signal clk64			: std_logic;
	
	signal RESET_n			: std_logic;
	signal RD_n				: std_logic;
	signal WR_n				: std_logic;
	signal IRQ_n			: std_logic;
	signal IO_n				: std_logic;
	signal A					: std_logic_vector(15 downto 0);
	signal D_in				: std_logic_vector(7 downto 0);
	signal D_out			: std_logic_vector(7 downto 0);
	
	signal vdp_RD_n		: std_logic;
	signal vdp_WR_n		: std_logic;
	signal vdp_D_out		: std_logic_vector(7 downto 0);
	signal frame_reset	: std_logic;
	signal line_reset		: std_logic;
	signal color			: std_logic_vector(5 downto 0);
	
	signal psg_WR_n		: std_logic;
	
	signal io_RD_n			: std_logic;
	signal io_WR_n			: std_logic;
	signal io_D_out		: std_logic_vector(7 downto 0);
	
	signal ram_RD_n		: std_logic;
	signal ram_WR_n		: std_logic;
	signal ram_D_out		: std_logic_vector(7 downto 0);
	
	signal rom_RD_n		: std_logic;
	signal rom_D_out		: std_logic_vector(7 downto 0);
	
	signal spi_RD_n		: std_logic;
	signal spi_WR_n		: std_logic;
	signal spi_D_out		: std_logic_vector(7 downto 0);
	
	signal boot_rom_RD_n	: std_logic;
	signal boot_rom_D_out: std_logic_vector(7 downto 0);
	
	signal uart_WR_n		: std_logic;
	signal uart_D_out		: std_logic_vector(7 downto 0);
	
	signal pal				: std_logic := '0';

	signal x: unsigned(8 downto 0);
	signal y: unsigned(7 downto 0);
	
	
	
	

	signal reset_counter:	unsigned(3 downto 0) := "1111";
	signal bootloader:		std_logic := '0';
	signal irom_D_out:		std_logic_vector(7 downto 0);
	signal irom_RD_n:			std_logic := '1';
	
	signal RD_n_reg:			std_logic := '1';
	signal WR_n_reg:			std_logic := '1';
	signal RD_n_clk:			std_logic := '1';
	signal WR_n_clk:			std_logic := '1';

begin

	clock_inst: clock
	port map (
		clkin_in			=>clk,
		clkin_ibufg_out=>clk32,
		clk2x_out		=>clk64,
		clkfx_out		=>clk8,
		clkfx180_out	=>clk8_n);

	process (clk32)
	begin
		if rising_edge(clk32) then
			clk16 <= not clk16;
		end if;
	end process;
	
	
--	z80_inst: dummy_z80
	z80_inst: T80s
	port map(
		RESET_n		=> RESET_n,
		CLK_n			=> clk8_n,
		WAIT_n		=> '1',
		INT_n			=> '1',--IRQ_n,
		NMI_n			=> '1',
		BUSRQ_n		=> '1',
		M1_n			=> open,
		MREQ_n		=> open,
		IORQ_n		=> IO_n,
		RD_n			=> RD_n,
		WR_n			=> WR_n,
		RFSH_n		=> open,
		HALT_n		=> open,
		BUSAK_n		=> open,
		A				=> A,
		DI				=> D_out,
		DO				=> D_in
	);
	
	vdp_timing_inst: vdp_vga_timing
	port map (
		clk_16		=> clk16,
		x	 			=> x,
		y				=> y,
		line_reset	=> line_reset,
		frame_reset	=> frame_reset,
		color			=> color,
		hsync			=> hsync,
		vsync			=> vsync,
		red			=> red,
		green			=> green,
		blue			=> blue
	);

	vdp_inst: vdp
	port map (
		clk			=> clk16,
		RD_n			=> vdp_RD_n,
		WR_n			=> vdp_WR_n,
		IRQ_n			=> IRQ_n,
		A				=> A(7 downto 0),
		D_in			=> D_in,
		D_out			=> vdp_D_out,
		x				=> x,
		y				=> y,
		color			=> color,
		frame_reset	=> frame_reset,
		line_reset	=> line_reset);
		
--	psg_inst: psg
--	port map (
--		clk			=> clk8,
--		WR_n			=> psg_WR_n,
--		D_in			=> D_in,
--		output		=> audio_out);
	
	io_inst: io
   port map (
		clk			=> clk8,
		WR_n			=> io_WR_n,
		RD_n			=> io_RD_n,
		A				=> A(7 downto 0),
		D_in			=> D_in,
		D_out			=> io_D_out,
		J1_up			=> joy_1(0),
		J1_down		=> joy_1(1),
		J1_left		=> joy_1(2),
		J1_right		=> joy_1(3),
		RESET			=> '1',
		J1_tl			=> joy_1(4),
		J1_tr			=> joy_1(5),
		J2_up			=> '1',
		J2_down		=> '1',
		J2_left		=> '1',
		J2_right		=> '1',
		J2_tl			=> '1',
		J2_tr			=> '1');
		
	joy_1_gnd <= '0';
		
	ram_inst: ram
	port map(
		clk			=> clk8,
		RD_n			=> ram_RD_n,
		WR_n			=> ram_WR_n,
		A				=> A(12 downto 0),
		D_in			=> D_in,
		D_out			=> ram_D_out);

	boot_rom_inst: boot_rom
	port map(
		clk			=> clk8,
		RD_n			=> boot_rom_RD_n,
		A				=> A(12 downto 0),
		D_out			=> boot_rom_D_out);
	
--	spi_inst: dummy_spi
	spi_inst: spi
	port map (
		clk			=> clk16,
		RD_n			=> spi_RD_n,
		WR_n			=> spi_WR_n,
		A				=> A(7 downto 0),
		D_in			=> D_in,
		D_out			=> spi_D_out,
			
		cs_n			=> spi_cs_n,
		sclk			=> spi_sclk,
		miso			=> spi_do,
		mosi			=> spi_di);

	uart_tx_inst: uart_tx
	port map (
		clk			=> clk8,
		WR_n			=> uart_WR_n,
		D_in			=> D_in,
		serial_out	=> tx,
		ready			=> uart_D_out(0));
	
	uart_D_out(7 downto 1) <= (others=>'0');
	
	
	
	
	
	-- glue logic	

	reset_n <= '0' when reset_counter>0 else '1';

	process (clk8)
	begin
		if rising_edge(clk8) then
			if reset_counter>0 then
				reset_counter <= reset_counter - 1;
			end if;
		end if;
	end process;
	
	process (clk8)
	begin
		if rising_edge(clk8) then
			RD_n_clk <= RD_n or not RD_n_reg;
			WR_n_clk <= WR_n or not WR_n_reg;
			RD_n_reg <= RD_n;
			WR_n_reg <= WR_n;
		end if;
	end process;
	
	vdp_WR_n <= io_n or WR_n_clk or not A(7) or A(6);
	vdp_RD_n <= io_n or RD_n_clk or not (A(7) xor A(6));
	
	psg_WR_n <= io_n or WR_n_clk or A(7) or not A(6);

	io_WR_n <= io_n or WR_n_clk or A(7) or A(6) or not A(0);
	io_RD_n <= io_n or RD_n_clk or not (A(7) and A(6));

	spi_WR_n <= bootloader or io_n or WR_n_clk or not (A(7) and A(6));
	spi_RD_n <= bootloader or io_n or RD_n_clk or A(7) or A(6);
	
	ram_WR_n <= not io_n or WR_n_clk or not (A(15) and A(14));
	
	process (clk8)
	begin
		if rising_edge(clk8) then
			if WR_n_clk='0' then
				if io_n='0' and A(7)='0' and A(6)='0' and A(0)='0' then
					-- memory control
					if bootloader='0' then
						bootloader <= D_in(7);
					end if;
				end if;
			end if;
		end if;
	end process;
	
	irom_D_out <= boot_rom_D_out when bootloader='0' else rom_D_out;
	
	with io_n&A select
	D_out <= spi_D_out		when "0--------00------",
				vdp_D_out		when "0--------01------",
				vdp_D_out		when "0--------10------",
				io_D_out			when "0--------11------",
				irom_D_out		when "100--------------",
				irom_D_out		when "101--------------",
				irom_D_out		when "110--------------",
				ram_D_out		when "111--------------",
				(others=>'-')	when others;

end Behavioral;

