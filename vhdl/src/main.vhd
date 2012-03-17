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
   port (CLKIN_IN			: in  std_logic; 
			CLKIN_IBUFG_OUT: out std_logic;         
			CLKFX_OUT 		: out std_logic;
			CLKFX180_OUT	: out std_logic;
			CLK2X_OUT		: out std_logic);
	end component;
	
	component glue is
	port (clk				: in  STD_LOGIC;
			IO_n				: in  STD_LOGIC;
			RD_n				: in  STD_LOGIC;
			WR_n				: in  STD_LOGIC;
			A					: in  STD_LOGIC_VECTOR(15 downto 0);
			D_in				: in  STD_LOGIC_VECTOR(7 downto 0);
			D_out				: out STD_LOGIC_VECTOR(7 downto 0);
			RESET_n			: out STD_LOGIC;
			
			vdp_RD_n			: out STD_LOGIC;
			vdp_WR_n			: out STD_LOGIC;
			vdp_D_out		: in  STD_LOGIC_VECTOR(7 downto 0);
			psg_WR_n			: out STD_LOGIC;
			io_RD_n			: out STD_LOGIC;
			io_WR_n			: out STD_LOGIC;
			io_D_out			: in  STD_LOGIC_VECTOR(7 downto 0);
			ram_RD_n			: out STD_LOGIC;
			ram_WR_n			: out STD_LOGIC;
			ram_D_out		: in  STD_LOGIC_VECTOR(7 downto 0);
			rom_RD_n			: out STD_LOGIC;
			rom_WR_n			: out STD_LOGIC;
			rom_D_out		: in  STD_LOGIC_VECTOR(7 downto 0);
			
			boot_rom_RD_n	: out STD_LOGIC;
			boot_rom_D_out	: in  STD_LOGIC_VECTOR(7 downto 0);
			spi_RD_n			: out STD_LOGIC;
			spi_WR_n			: out STD_LOGIC;
			spi_D_out		: in  STD_LOGIC_VECTOR(7 downto 0));
	end component;
	
--	component dummy_z80 is
	component T80s is
	generic(
		Mode : integer := 0;	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
		T2Write : integer := 0;	-- 0 => WR_n active in T3, /=0 => WR_n active in T2
		IOWait : integer := 1	-- 0 => Single cycle I/O, 1 => Std I/O cycle
	);
	port(
		RESET_n	: in std_logic;
		CLK_n		: in std_logic;
		WAIT_n	: in std_logic;
		INT_n		: in std_logic;
		NMI_n		: in std_logic;
		BUSRQ_n	: in std_logic;
		M1_n		: out std_logic;
		MREQ_n	: out std_logic;
		IORQ_n	: out std_logic;
		RD_n		: out std_logic;
		WR_n		: out std_logic;
		RFSH_n	: out std_logic;
		HALT_n	: out std_logic;
		BUSAK_n	: out std_logic;
		A			: out std_logic_vector(15 downto 0);
		DI			: in std_logic_vector(7 downto 0);
		DO			: out std_logic_vector(7 downto 0)
	);
	end component;
		
	component vdp_vga_timing is
	port (
		clk_16:			in  std_logic;
		x: 				out unsigned(8 downto 0);
		y:					out unsigned(7 downto 0);
		line_reset:		out std_logic;
		frame_reset:	out std_logic;
		color:			in std_logic_vector(5 downto 0);
		hsync:			out std_logic;
		vsync:			out std_logic;
		red:				out std_logic_vector(1 downto 0);
		green:			out std_logic_vector(1 downto 0);
		blue:				out std_logic_vector(1 downto 0));
	end component;

	component vdp is
	port (
		clk:				in  STD_LOGIC;
		RD_n:				in  STD_LOGIC;
		WR_n:				in  STD_LOGIC;
		IRQ_n:			out STD_LOGIC;
		A:					in  STD_LOGIC_VECTOR(7 downto 0);
		D_in:				in  STD_LOGIC_VECTOR(7 downto 0);
		D_out:			out STD_LOGIC_VECTOR(7 downto 0);			
		x:					in  unsigned(8 downto 0);
		y:					in  unsigned(7 downto 0);
		line_reset:		in  std_logic;
		frame_reset:	in  std_logic;			
		color: out std_logic_vector (5 downto 0));
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
	port (clk:		in  STD_LOGIC;
			RD_n:		in  STD_LOGIC;
			WR_n:		in  STD_LOGIC;
			A:			in  STD_LOGIC_VECTOR(12 downto 0);
			D_in:		in  STD_LOGIC_VECTOR(7 downto 0);
			D_out:	out STD_LOGIC_VECTOR(7 downto 0));
	end component;

	component boot_rom is
	port (
		clk:			in  STD_LOGIC;
		RD_n:			in  STD_LOGIC;
		A:				in  STD_LOGIC_VECTOR(12 downto 0);
		D_in:			in  STD_LOGIC_VECTOR(7 downto 0);
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
	signal rom_WR_n		: std_logic;
	signal rom_D_out		: std_logic_vector(7 downto 0);
	
	signal spi_RD_n		: std_logic;
	signal spi_WR_n		: std_logic;
	signal spi_D_out		: std_logic_vector(7 downto 0);
	
	signal boot_rom_RD_n	: std_logic;
	signal boot_rom_D_out: std_logic_vector(7 downto 0);
	
	signal pal				: std_logic := '0';

	signal x: unsigned(8 downto 0);
	signal y: unsigned(7 downto 0);

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
	
	glue_inst: glue 
	port map(
		clk				=> clk8,
		IO_n				=> IO_n,
		RD_n				=> RD_n,
		WR_n				=> WR_n,
		A					=> A,
		D_in				=> D_in,
		D_out				=> D_out,
		RESET_n			=> RESET_n,
			
		vdp_RD_n			=> vdp_RD_n,
		vdp_WR_n			=> vdp_WR_n,
		vdp_D_out		=> vdp_D_out,
		psg_WR_n			=> psg_WR_n,
		io_RD_n			=> io_RD_n,
		io_WR_n			=> io_WR_n,
		io_D_out			=> io_D_out,
		ram_RD_n			=> ram_RD_n,
		ram_WR_n			=> ram_WR_n,
		ram_D_out		=> ram_D_out,
		rom_RD_n			=> rom_RD_n,
		rom_WR_n			=> rom_WR_n,
		rom_D_out		=> rom_D_out,
			
		boot_rom_RD_n	=> boot_rom_RD_n,
		boot_rom_D_out	=> boot_rom_D_out,
		spi_RD_n			=> spi_RD_n,
		spi_WR_n			=> spi_WR_n,
		spi_D_out		=> spi_D_out);
	
	
--	z80_inst: dummy_z80
	z80_inst: T80s
	port map(
		RESET_n	=> RESET_n,
		CLK_n		=> clk8_n,
		WAIT_n	=> '1',
		INT_n		=> '1',--IRQ_n,
		NMI_n		=> '1',
		BUSRQ_n	=> '1',
		M1_n		=> open,
		MREQ_n	=> open,
		IORQ_n	=> IO_n,
		RD_n		=> RD_n,
		WR_n		=> WR_n,
		RFSH_n	=> open,
		HALT_n	=> open,
		BUSAK_n	=> open,
		A			=> A,
		DI			=> D_out,
		DO			=> D_in
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
		clk				=> clk16,
		RD_n				=> vdp_RD_n,
		WR_n				=> vdp_WR_n,
		IRQ_n				=> IRQ_n,
		A					=> A(7 downto 0),
		D_in				=> D_in,
		D_out				=> vdp_D_out,
		x					=> x,
		y					=> y,
		color				=> color,
		frame_reset		=> frame_reset,
		line_reset		=> line_reset);
		
--	psg_inst: psg
--	port map (
--		clk	=> clk8,
--		WR_n	=> psg_WR_n,
--		D_in	=> D_in,
--		output=> audio_out);
	
	io_inst: io
   port map (
		clk		=> clk8,
		WR_n		=> io_WR_n,
		RD_n		=> io_RD_n,
		A			=> A(7 downto 0),
		D_in		=> D_in,
		D_out		=> io_D_out,
		J1_up		=> joy_1(0),
		J1_down	=> joy_1(1),
		J1_left	=> joy_1(2),
		J1_right	=> joy_1(3),
		RESET		=> '1',
		J1_tl		=> joy_1(4),
		J1_tr		=> joy_1(5),
		J2_up		=> '1',
		J2_down	=> '1',
		J2_left	=> '1',
		J2_right	=> '1',
		J2_tl		=> '1',
		J2_tr		=> '1');
		
	joy_1_gnd <= '0';

	boot_rom_inst: boot_rom
	port map(
		clk	=> clk8,
		RD_n	=> boot_rom_RD_n,
		A		=> A(12 downto 0),
		D_in	=> D_in,
		D_out	=> boot_rom_D_out);
	
--	spi_inst: dummy_spi
	spi_inst: spi
	port map (
		clk	=> clk16,
		RD_n	=> spi_RD_n,
		WR_n	=> spi_WR_n,
		A		=> A(7 downto 0),
		D_in	=> D_in,
		D_out	=> spi_D_out,
			
		cs_n	=> spi_cs_n,
		sclk	=> spi_sclk,
		miso	=> spi_do,
		mosi	=> spi_di);
		
	ram_inst: ram
	port map(
		clk	=> clk8,
		RD_n	=> ram_RD_n,
		WR_n	=> ram_WR_n,
		A		=> A(12 downto 0),
		D_in	=> D_in,
		D_out	=> ram_D_out);

end Behavioral;

