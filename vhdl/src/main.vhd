-- Module Name:    main - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main is
	port (clk		: in  STD_LOGIC;
	
			input_n	: in	STD_LOGIC_VECTOR(15 downto 0);
			
			tv_ground: out STD_LOGIC;
			video_out: out STD_LOGIC_VECTOR(5 downto 0);
			audio_out: out STD_LOGIC;
			
			color2: out STD_LOGIC_VECTOR(5 downto 0);
			sync2: out STD_LOGIC;
			
			spi_ss	: out STD_LOGIC;
			spi_sck	: out STD_LOGIC;
			spi_miso	: in  STD_LOGIC;
			spi_mosi	: out STD_LOGIC;
			spi_vcc	: out STD_LOGIC;
			spi_gnd	: out STD_LOGIC);
end main;

architecture Behavioral of main is

	component clock is
   port (CLKIN_IN		: in  std_logic;          
			CLKFX_OUT 	: out std_logic;
			CLKFX180_OUT: out std_logic;
			CLK2X_OUT	: out std_logic);
	end component;
	
	component glue is
	port (clk				: in  STD_LOGIC;
			IO_n				: in  STD_LOGIC;
			RD_n				: in  STD_LOGIC;
			WR_n				: in  STD_LOGIC;
			A					: in  STD_LOGIC_VECTOR(15 downto 0);
			D_in				: in  STD_LOGIC_VECTOR(7 downto 0);
			D_out				: out STD_LOGIC_VECTOR(7 downto 0);
			
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
	
	component dummy_z80 is
--	component T80s is
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
	
	component vdp is
	port (clk				: in  STD_LOGIC;
			RD_n				: in  STD_LOGIC;
			WR_n				: in  STD_LOGIC;
			IRQ_n				: out STD_LOGIC;
			A					: in  STD_LOGIC_VECTOR(7 downto 0);
			D_in				: in  STD_LOGIC_VECTOR(7 downto 0);
			D_out				: out STD_LOGIC_VECTOR(7 downto 0);
			sync				: out STD_LOGIC;
			color				: out STD_LOGIC_VECTOR (5 downto 0);
			line_visible	: out STD_lOGIC;
			line_even		: out STD_lOGIC;
			pal				: in  STD_LOGIC);
	end component;
	
	component color_encoder is
   port (clk			: in  STD_LOGIC;
			pal			: in  STD_LOGIC;
			sync			: in  STD_LOGIC;
			line_visible: in  STD_LOGIC;
			line_even	: in  STD_LOGIC;
			color			: in  STD_LOGIC_VECTOR (5 downto 0);
			output		: out STD_LOGIC_VECTOR (5 downto 0));
	end component;
	
	component psg is
   port (clk	: in  STD_LOGIC;
			WR_n	: in  STD_LOGIC;
			D_in	: in  STD_LOGIC_VECTOR (7 downto 0);
			output: out STD_LOGIC);
	end component;
	
	component io is
   port (clk		: in  STD_LOGIC;
			WR_n		: in  STD_LOGIC;
			RD_n		: in  STD_LOGIC;
			A			: in  STD_LOGIC_VECTOR (7 downto 0);
			D_in		: in  STD_LOGIC_VECTOR (7 downto 0);
			D_out		: out STD_LOGIC_VECTOR (7 downto 0);
			J1_up		: in 	STD_LOGIC;
			J1_down	: in 	STD_LOGIC;
			J1_left	: in 	STD_LOGIC;
			J1_right	: in 	STD_LOGIC;
			J1_tl		: in 	STD_LOGIC;
			J1_tr		: in 	STD_LOGIC;
			J2_up		: in 	STD_LOGIC;
			J2_down	: in 	STD_LOGIC;
			J2_left	: in 	STD_LOGIC;
			J2_right	: in 	STD_LOGIC;
			J2_tl		: in 	STD_LOGIC;
			J2_tr		: in 	STD_LOGIC;
			RESET		: in 	STD_LOGIC);
	end component;

	component ram is
	port (clk	: in  STD_LOGIC;
			RD_n	: in  STD_LOGIC;
			WR_n	: in  STD_LOGIC;
			A		: in  STD_LOGIC_VECTOR(12 downto 0);
			D_in	: in  STD_LOGIC_VECTOR(7 downto 0);
			D_out	: out STD_LOGIC_VECTOR(7 downto 0));
	end component;

	component boot_rom is
	port (clk	: in  STD_LOGIC;
			RD_n	: in  STD_LOGIC;
			A		: in  STD_LOGIC_VECTOR(13 downto 0);
			D_in	: in  STD_LOGIC_VECTOR(7 downto 0);
			D_out	: out STD_LOGIC_VECTOR(7 downto 0));
	end component;
	
	component spi is
	port (clk	: in  STD_LOGIC;
			RD_n	: in  STD_LOGIC;
			WR_n	: in  STD_LOGIC;
			A		: in  STD_LOGIC_VECTOR (7 downto 0);
			D_in	: in  STD_LOGIC_VECTOR (7 downto 0);
			D_out	: out STD_LOGIC_VECTOR (7 downto 0);
			
			ss		: out STD_LOGIC;
			sck	: out STD_LOGIC;
			miso	: in  STD_LOGIC;
			mosi	: out STD_LOGIC);
	end component;
	
	signal clk8				: std_logic;
	signal clk8_n			: std_logic;
	signal clk64			: std_logic;
	
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
	signal sync				: std_logic;
	signal color			: std_logic_vector(5 downto 0);
	signal line_visible	: std_logic;
	signal line_even		: std_logic;
	
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

begin

color2 <= color;
sync2 <= sync;

	clock_inst: clock
	port map (
		clkin_in		=>clk,
		clk2x_out	=>clk64,
		clkfx_out	=>clk8,
		clkfx180_out=>clk8_n);
	
	glue_inst: glue 
	port map(
		clk				=> clk8,
		IO_n				=> IO_n,
		RD_n				=> RD_n,
		WR_n				=> WR_n,
		A					=> A,
		D_in				=> D_in,
		D_out				=> D_out,
			
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
	
	
	z80_inst: dummy_z80
--	z80_inst: T80s
	port map(
		RESET_n	=> '1',--RESET_n,
		CLK_n		=> clk8_n,
		WAIT_n	=> '1',
		INT_n		=> IRQ_n,
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

	vdp_inst: vdp
	port map (
		clk				=> clk8,
		RD_n				=> vdp_RD_n,
		WR_n				=> vdp_WR_n,
		IRQ_n				=> IRQ_n,
		A					=> A(7 downto 0),
		D_in				=> D_in,
		D_out				=> vdp_D_out,
		sync				=> sync,
		color				=> color,
		line_visible	=> line_visible,
		line_even		=> line_even,
		
		pal				=> pal);
		
	color_encoder_inst: color_encoder
	port map (
		clk			=> clk64,
		pal			=> pal,
		sync			=> sync,
		color			=> color,
		line_visible=> line_visible,
		line_even	=> line_even,
		output		=> video_out);

	tv_ground <= '0';
	
	psg_inst: psg
	port map (
		clk	=> clk8,
		WR_n	=> psg_WR_n,
		D_in	=> D_in,
		output=> audio_out);
	
	io_inst: io
   port map (
		clk		=> clk8,
		WR_n		=> io_WR_n,
		RD_n		=> io_RD_n,
		A			=> A(7 downto 0),
		D_in		=> D_in,
		D_out		=> io_D_out,
		J1_up		=> input_n(0),
		J1_down	=> input_n(1),
		J1_left	=> input_n(2),
		J1_right	=> input_n(3),
		RESET		=> input_n(4),
		J1_tl		=> input_n(5),
		J1_tr		=> input_n(7),
		J2_up		=> input_n(8),
		J2_down	=> input_n(9),
		J2_left	=> input_n(10),
		J2_right	=> input_n(11),
		J2_tl		=> input_n(13),
		J2_tr		=> input_n(15));

	boot_rom_inst: boot_rom
	port map(
		clk	=> clk8,
		RD_n	=> boot_rom_RD_n,
		A		=> A(13 downto 0),
		D_in	=> D_in,
		D_out	=> boot_rom_D_out);
	
	spi_inst: spi
	port map (
		clk	=> clk8,
		RD_n	=> spi_RD_n,
		WR_n	=> spi_WR_n,
		A		=> A(7 downto 0),
		D_in	=> D_in,
		D_out	=> spi_D_out,
			
		ss		=> spi_ss,
		sck	=> spi_sck,
		miso	=> spi_miso,
		mosi	=> spi_mosi);
		
	spi_vcc <= '1';
	spi_gnd <= '0';

	ram_inst: ram
	port map(
		clk	=> clk8,
		RD_n	=> ram_RD_n,
		WR_n	=> ram_WR_n,
		A		=> A(12 downto 0),
		D_in	=> D_in,
		D_out	=> ram_D_out);

end Behavioral;

