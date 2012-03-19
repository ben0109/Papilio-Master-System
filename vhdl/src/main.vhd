library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main is
	port (
		clk:			in  STD_LOGIC;
		
		ram_ce:		out STD_LOGIC;
		ram_be:		out STD_LOGIC;
		ram_oe:		out STD_LOGIC;
		ram_we:		out STD_LOGIC;
		ram_a:		out STD_LOGIC_VECTOR(18 downto 0);
		ram_d:		inout STD_LOGIC_VECTOR(15 downto 0);

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
		clk_in:		in  std_logic;
		clk_cpu:		out std_logic;
		clk16:		out std_logic;
		clk32:		out std_logic;
		clk64:		out std_logic);
	end component;
	
--	component dummy_z80 is
	component T80s is
	generic(
		Mode : integer := 0;	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
		T2Write : integer := 0;	-- 0 => WR_n active in T3, /=0 => WR_n active in T2
		IOWait : integer := 1	-- 0 => Single cycle I/O, 1 => Std I/O cycle
	);
	port(
		RESET_n:			in std_logic;
		CLK_n:			in std_logic;
		WAIT_n:			in std_logic;
		INT_n:				in std_logic;
		NMI_n:			in std_logic;
		BUSRQ_n:			in std_logic;
		M1_n:				out std_logic;
		MREQ_n:			out std_logic;
		IORQ_n:			out std_logic;
		RD_n:				out std_logic;
		WR_n:				out std_logic;
		RFSH_n:			out std_logic;
		HALT_n:			out std_logic;
		BUSAK_n:			out std_logic;
		A:					out std_logic_vector(15 downto 0);
		DI:				in std_logic_vector(7 downto 0);
		DO:				out std_logic_vector(7 downto 0)
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
		cpu_clk:			in  STD_LOGIC;
		vdp_clk:			in  STD_LOGIC;
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
		color: 			out std_logic_vector (5 downto 0));
	end component;
	
	component psg is
   port (
		clk:				in  STD_LOGIC;
		WR_n:				in  STD_LOGIC;
		D_in:				in  STD_LOGIC_VECTOR (7 downto 0);
		output:			out STD_LOGIC);
	end component;
	
	component io is
   port (
		clk:				in  STD_LOGIC;
		WR_n:				in  STD_LOGIC;
		RD_n:				in  STD_LOGIC;
		A:					in  STD_LOGIC_VECTOR (7 downto 0);
		D_in:				in  STD_LOGIC_VECTOR (7 downto 0);
		D_out:			out STD_LOGIC_VECTOR (7 downto 0);
		J1_up:			in  STD_LOGIC;
		J1_down:			in  STD_LOGIC;
		J1_left:			in  STD_LOGIC;
		J1_right:		in  STD_LOGIC;
		J1_tl:			in  STD_LOGIC;
		J1_tr:			in  STD_LOGIC;
		J2_up:			in  STD_LOGIC;
		J2_down:			in  STD_LOGIC;
		J2_left:			in  STD_LOGIC;
		J2_right:		in  STD_LOGIC;
		J2_tl:			in  STD_LOGIC;
		J2_tr:			in  STD_LOGIC;
		RESET:			in  STD_LOGIC);
	end component;

	component ram is
	port (
		clk:				in  STD_LOGIC;
		RD_n:				in  STD_LOGIC;
		WR_n:				in  STD_LOGIC;
		A:					in  STD_LOGIC_VECTOR(12 downto 0);
		D_in:				in  STD_LOGIC_VECTOR(7 downto 0);
		D_out:			out STD_LOGIC_VECTOR(7 downto 0));
	end component;

	component boot_rom is
	port (
		clk:				in  STD_LOGIC;
		RD_n:				in  STD_LOGIC;
		A:					in  STD_LOGIC_VECTOR(12 downto 0);
		D_out:			out STD_LOGIC_VECTOR(7 downto 0));
	end component;

	
--	component dummy_spi is
	component spi is
	port (
		clk:				in  STD_LOGIC;
		RD_n:				in  STD_LOGIC;
		WR_n:				in  STD_LOGIC;
		A:					in  STD_LOGIC_VECTOR (7 downto 0);
		D_in:				in  STD_LOGIC_VECTOR (7 downto 0);
		D_out:			out STD_LOGIC_VECTOR (7 downto 0);
			
		cs_n:				out STD_LOGIC;
		sclk:				out STD_LOGIC;
		miso:				in  STD_LOGIC;
		mosi:				out STD_LOGIC);
	end component;

	component uart_tx is
	port (
		clk:  			in  std_logic;
		WR_n:				in  std_logic;
		D_in: 			in  std_logic_vector(7 downto 0);
		serial_out:		out std_logic;
		ready:			out std_logic);
	end component;
	
	signal clk_cpu:			std_logic;
	signal clk16:				std_logic;
	signal clk32:				std_logic;
	signal clk64:				std_logic;
	
	signal RESET_n:			std_logic;
	signal RD_n:				std_logic;
	signal WR_n:				std_logic;
	signal IRQ_n:				std_logic;
	signal IO_n:				std_logic;
	signal A:					std_logic_vector(15 downto 0);
	signal D_in:				std_logic_vector(7 downto 0);
	signal D_out:				std_logic_vector(7 downto 0);
	
	signal vdp_RD_n:			std_logic;
	signal vdp_WR_n:			std_logic;
	signal vdp_D_out:			std_logic_vector(7 downto 0);
	signal frame_reset:		std_logic;
	signal line_reset:		std_logic;
	signal color:				std_logic_vector(5 downto 0);
	
	signal psg_WR_n:			std_logic;
	
	signal ctl_WR_n:			std_logic;
	
	signal io_RD_n:			std_logic;
	signal io_WR_n:			std_logic;
	signal io_D_out:			std_logic_vector(7 downto 0);
	
	signal ram_RD_n:			std_logic;
	signal ram_WR_n:			std_logic;
	signal ram_D_out:			std_logic_vector(7 downto 0);
	
	signal rom_RD_n:			std_logic;
	signal rom_WR_n:			std_logic;
	signal rom_D_out:			std_logic_vector(7 downto 0);
	
	signal spi_RD_n:			std_logic;
	signal spi_WR_n:			std_logic;
	signal spi_D_out:			std_logic_vector(7 downto 0);
	
	signal boot_rom_RD_n:	std_logic;
	signal boot_rom_D_out:	std_logic_vector(7 downto 0);
	
	signal uart_WR_n:			std_logic;
	signal uart_D_out:		std_logic_vector(7 downto 0);
	
	signal pal:					std_logic := '0';

	signal x:					unsigned(8 downto 0);
	signal y:					unsigned(7 downto 0);
	
	
	
	

	signal reset_counter:	unsigned(3 downto 0) := "1111";
	signal bootloader:		std_logic := '0';
	signal irom_D_out:		std_logic_vector(7 downto 0);
	signal irom_RD_n:			std_logic := '1';

	signal bank0:				std_logic_vector(4 downto 0);
	signal bank1:				std_logic_vector(4 downto 0);
	signal bank2:				std_logic_vector(4 downto 0);
begin

	clock_inst: clock
	port map (
		clk_in		=> clk,
		clk_cpu		=> clk_cpu,
		clk16			=> clk16,
		clk32			=> clk32,
		clk64			=> clk64);
	
	
--	z80_inst: dummy_z80
	z80_inst: T80s
	port map(
		RESET_n		=> RESET_n,
		CLK_n			=> clk_cpu,
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
		cpu_clk		=> clk_cpu,
		vdp_clk		=> clk16,
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
		clk			=> clk_cpu,
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
		clk			=> clk_cpu,
		RD_n			=> ram_RD_n,
		WR_n			=> ram_WR_n,
		A				=> A(12 downto 0),
		D_in			=> D_in,
		D_out			=> ram_D_out);

	boot_rom_inst: boot_rom
	port map(
		clk			=> clk_cpu,
		RD_n			=> boot_rom_RD_n,
		A				=> A(12 downto 0),
		D_out			=> boot_rom_D_out);
	
--	spi_inst: dummy_spi
	spi_inst: spi
	port map (
		clk			=> clk_cpu,
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
		clk			=> clk_cpu,
		WR_n			=> uart_WR_n,
		D_in			=> D_in,
		serial_out	=> tx,
		ready			=> uart_D_out(0));
	
	uart_D_out(7 downto 1) <= (others=>'0');
	
	
	
	
	
	-- glue logic

	reset_n <= '0' when reset_counter>0 else '1';

	process (clk_cpu)
	begin
		if rising_edge(clk_cpu) then
			if reset_counter>0 then
				reset_counter <= reset_counter - 1;
			end if;
		end if;
	end process;
	
	with io_n&A select
	vdp_WR_n <= WR_n when "0--------10------",
					'1' when others;
					
	with io_n&A select
	vdp_RD_n <= RD_n when "0--------01------",
					RD_n when "0--------10------",
					'1' when others;
	
	with io_n&A select
	psg_WR_n <= WR_n when "0--------01------",
					'1' when others;

	with io_n&A select
	ctl_WR_n <=	WR_n when "0--------00-----0",
					'1' when others;

	with io_n&A select
	io_WR_n <=	WR_n when "0--------00-----1",
					'1' when others;
					
	with io_n&A select
	io_RD_n <=	RD_n when "0--------11------",
					'1' when others;
	
	with io_n&A select
	ram_WR_n <= WR_n when "111--------------",
					'1' when others;
					
	with io_n&A select
	spi_RD_n <= bootloader or RD_n when "0--------00------",
					'1' when others;

	with io_n&A select
	spi_WR_n <= bootloader or WR_n when "0--------110-----",
					'1' when others;

	with io_n&A select
	uart_WR_n<= bootloader or WR_n when "0--------111-----",
					'1' when others;
	
	with io_n&A select
	rom_WR_n <= bootloader or WR_n when "110--------------",
					'1' when others;
	
	process (clk_cpu)
	begin
		if rising_edge(clk_cpu) then
			if ctl_WR_n='0' then
				-- memory control
				if bootloader='0' then
					bootloader <= D_in(7);
				end if;
			end if;
		end if;
	end process;
	
	with bootloader select
	irom_D_out <=	boot_rom_D_out when '0',
						rom_D_out when others;
	
	with io_n&A select
	D_out <= spi_D_out		when "0--------000-----",
				uart_D_out		when "0--------001-----",
				vdp_D_out		when "0--------01------",
				vdp_D_out		when "0--------10------",
				io_D_out			when "0--------11------",
				irom_D_out		when "100--------------",
				irom_D_out		when "101--------------",
				irom_D_out		when "110--------------",
				ram_D_out		when "111--------------",
				(others=>'-')	when others;
				
				
	-- external ram control
	
	process (clk_cpu)
	begin
		if rising_edge(clk_cpu) then
			if WR_n='0' and A(15 downto 2)="11111111111111" then
				case A(1 downto 0) is
				when "01" => bank0 <= D_in(4 downto 0);
				when "10" => bank1 <= D_in(4 downto 0);
				when "11" => bank2 <= D_in(4 downto 0);
				when others =>
				end case;
			end if;
		end if;
	end process;
	
	ram_ce <= '1';
	ram_be <= '0';
	ram_oe <= RD_n;
	ram_we <= rom_WR_n;
	ram_a(13 downto 0) <= A(13 downto 0);
	process (A,bank0,bank1,bank2)
	begin
		case A(15 downto 14) is
		when "00" =>
			-- first kilobyte is always from bank 0
			if A(13 downto 10)="0000" then
				ram_a(18 downto 14) <= (others=>'0');
			else
				ram_a(18 downto 14) <= bank0;
			end if;
		when "01" =>
			ram_a(18 downto 14) <= bank1;
			
		when others =>
			ram_a(18 downto 14) <= bank2;
		end case;
	end process;
	
	with RD_n select
	ram_d(7 downto 0) <= (others=>'Z') when '0',
								D_in when others;
	ram_d(15 downto 8) <= (others=>'Z');
				
	rom_D_out <= ram_d(7 downto 0);

end Behavioral;

