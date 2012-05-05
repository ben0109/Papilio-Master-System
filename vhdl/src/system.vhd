library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.all;

entity system is
	port (
		clk_cpu:		in		STD_LOGIC;
		clk_vdp:		in		STD_LOGIC;
		
		ram_cs_n:	out	STD_LOGIC;
		ram_we_n:	out	STD_LOGIC;
		ram_oe_n:	out	STD_LOGIC;
		ram_ble_n:	out	STD_LOGIC;
		ram_bhe_n:	out	STD_LOGIC;
		ram_a:		out	STD_LOGIC_VECTOR(18 downto 0);
		ram_d:		inout	STD_LOGIC_VECTOR(15 downto 0);

		j1_up:		in		STD_LOGIC;
		j1_down:		in		STD_LOGIC;
		j1_left:		in		STD_LOGIC;
		j1_right:	in		STD_LOGIC;
		j1_tl:		in		STD_LOGIC;
		j1_tr:		inout	STD_LOGIC;
		j2_up:		in		STD_LOGIC;
		j2_down:		in		STD_LOGIC;
		j2_left:		in		STD_LOGIC;
		j2_right:	in		STD_LOGIC;
		j2_tl:		in		STD_LOGIC;
		j2_tr:		inout	STD_LOGIC;
		reset:		in		STD_LOGIC;
		pause:		in		STD_LOGIC;

		x:				in		UNSIGNED(8 downto 0);
		y:				in		UNSIGNED(7 downto 0);
		vblank:		in		STD_LOGIC;
		hblank:		in		STD_LOGIC;
		color:		out	STD_LOGIC_VECTOR(5 downto 0);
		audio:		out	STD_LOGIC;

		spi_do:		in		STD_LOGIC;
		spi_sclk:	out	STD_LOGIC;
		spi_di:		out	STD_LOGIC;
		spi_cs_n:	out	STD_LOGIC;

		tx:			out	STD_LOGIC);
end system;

architecture Behavioral of system is
	
--	component dummy_z80 is
	component T80se is
	generic(
		Mode : integer := 0;	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
		T2Write : integer := 0;	-- 0 => WR_n active in T3, /=0 => WR_n active in T2
		IOWait : integer := 1	-- 0 => Single cycle I/O, 1 => Std I/O cycle
	);
	port(
		RESET_n:			in std_logic;
		CLK_n:			in std_logic;
		CLKEN:			in std_logic;
		WAIT_n:			in std_logic;
		INT_n:			in std_logic;
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
		vblank:			in  std_logic;
		hblank:			in  std_logic;
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
		clk:				in		STD_LOGIC;
		WR_n:				in		STD_LOGIC;
		RD_n:				in		STD_LOGIC;
		A:					in		STD_LOGIC_VECTOR (7 downto 0);
		D_in:				in		STD_LOGIC_VECTOR (7 downto 0);
		D_out:			out	STD_LOGIC_VECTOR (7 downto 0);
		J1_up:			in 	STD_LOGIC;
		J1_down:			in 	STD_LOGIC;
		J1_left:			in 	STD_LOGIC;
		J1_right:		in 	STD_LOGIC;
		J1_tl:			in 	STD_LOGIC;
		J1_tr:			inout STD_LOGIC;
		J2_up:			in 	STD_LOGIC;
		J2_down:			in 	STD_LOGIC;
		J2_left:			in 	STD_LOGIC;
		J2_right:		in 	STD_LOGIC;
		J2_tl:			in 	STD_LOGIC;
		J2_tr:			inout STD_LOGIC;
		RESET:			in 	STD_LOGIC);
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
		A:					in  STD_LOGIC_VECTOR(13 downto 0);
		D_out:			out STD_LOGIC_VECTOR(7 downto 0));
	end component;

	
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
	
	signal psg_WR_n:			std_logic;
	
	signal ctl_WR_n:			std_logic;
	
	signal io_RD_n:			std_logic;
	signal io_WR_n:			std_logic;
	signal io_D_out:			std_logic_vector(7 downto 0);
	
--	signal ram_RD_n:			std_logic;
	signal ram_WR_n:			std_logic;
	signal ram_D_out:			std_logic_vector(7 downto 0);
	
--	signal rom_RD_n:			std_logic;
	signal rom_WR_n:			std_logic;
	signal rom_D_out:			std_logic_vector(7 downto 0);
	
	signal spi_RD_n:			std_logic;
	signal spi_WR_n:			std_logic;
	signal spi_D_out:			std_logic_vector(7 downto 0);
	
--	signal boot_rom_RD_n:	std_logic;
	signal boot_rom_D_out:	std_logic_vector(7 downto 0);
	
	signal uart_WR_n:			std_logic;
	signal uart_D_out:		std_logic_vector(7 downto 0);

	signal reset_counter:	unsigned(3 downto 0) := "1111";
	signal bootloader:		std_logic := '0';
	signal irom_D_out:		std_logic_vector(7 downto 0);
	signal irom_RD_n:			std_logic := '1';

	signal bank0:				std_logic_vector(5 downto 0);
	signal bank1:				std_logic_vector(5 downto 0);
	signal bank2:				std_logic_vector(5 downto 0);
begin	
	
--	z80_inst: dummy_z80
	z80_inst: T80se
	port map(
		RESET_n		=> RESET_n,
		CLK_n			=> clk_cpu,
		CLKEN			=> '1',
		WAIT_n		=> '1',
		INT_n			=> IRQ_n,
		NMI_n			=> pause,
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

	vdp_inst: vdp
	port map (
		cpu_clk		=> clk_cpu,
		vdp_clk		=> clk_vdp,
		RD_n			=> vdp_RD_n,
		WR_n			=> vdp_WR_n,
		IRQ_n			=> IRQ_n,
		A				=> A(7 downto 0),
		D_in			=> D_in,
		D_out			=> vdp_D_out,
		x				=> x,
		y				=> y,
		vblank		=> vblank,
		hblank		=> hblank,
		color			=> color);
		
	psg_inst: psg
	port map (
		clk			=> clk_cpu,
		WR_n			=> psg_WR_n,
		D_in			=> D_in,
		output		=> audio);
	
	io_inst: io
   port map (
		clk			=> clk_cpu,
		WR_n			=> io_WR_n,
		RD_n			=> io_RD_n,
		A				=> A(7 downto 0),
		D_in			=> D_in,
		D_out			=> io_D_out,
		J1_up			=> j1_up,
		J1_down		=> j1_down,
		J1_left		=> j1_left,
		J1_right		=> j1_right,
		J1_tl			=> j1_tl,
		J1_tr			=> j1_tr,
		J2_up			=> j2_up,
		J2_down		=> j2_down,
		J2_left		=> j2_left,
		J2_right		=> j2_right,
		J2_tl			=> j2_tl,
		J2_tr			=> j2_tr,
		RESET			=> reset);
		
	ram_inst: ram
	port map(
		clk			=> clk_cpu,
		RD_n			=> '0',--ram_RD_n,
		WR_n			=> ram_WR_n,
		A				=> A(12 downto 0),
		D_in			=> D_in,
		D_out			=> ram_D_out);

	boot_rom_inst: boot_rom
	port map(
		clk			=> clk_cpu,
		RD_n			=> '0',--boot_rom_RD_n,
		A				=> A(13 downto 0),
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

	vdp_WR_n <= WR_n when io_n='0' and A(7 downto 6)="10" else '1';
					
	vdp_RD_n <= RD_n when io_n='0' and (A(7 downto 6)="01" or A(7 downto 6)="10") else '1';
	
	psg_WR_n <= WR_n when io_n='0' and A(7 downto 6)="01" else '1';

	ctl_WR_n <=	WR_n when io_n='0' and A(7 downto 6)="00" and A(0)='0' else '1';

	io_WR_n <=	WR_n when io_n='0' and A(7 downto 6)="00" and A(0)='1' else '1';
					
	io_RD_n <=	RD_n when io_n='0' and A(7 downto 6)="11" else '1';
					
	spi_RD_n <= bootloader or RD_n when io_n='0' and A(7 downto 5)="000" else '1';

	spi_WR_n <= bootloader or WR_n when io_n='0' and A(7 downto 5)="110" else '1';

	uart_WR_n<= bootloader or WR_n when io_n='0' and A(7 downto 5)="111" else '1';
	
	ram_WR_n <= WR_n when io_n='1' and A(15 downto 14)="11" else '1';
	
	rom_WR_n <= bootloader or WR_n when io_n='1' and A(15 downto 14)="10" else '1';
	
	process (clk_cpu)
	begin
		if rising_edge(clk_cpu) then
			-- memory control
			if reset_counter>0 then
				reset_counter <= reset_counter - 1;
			elsif ctl_WR_n='0' then
				if bootloader='0' then
					bootloader <= '1';
					reset_counter <= (others=>'1');
				end if;
			end if;
		end if;
	end process;
	reset_n <= '0' when reset_counter>0 else '1';
	
	irom_D_out <=	boot_rom_D_out when bootloader='0' and A(15 downto 14)="00" else rom_D_out;
	
	process (io_n,A,spi_D_out,uart_D_out,vdp_D_out,vdp_D_out,io_D_out,irom_D_out,irom_D_out,irom_D_out,ram_D_out)
	begin
		if io_n='0' then
			case A(7 downto 5) is
			when "000" =>
				D_out <= spi_D_out; 
			when "001" =>
				D_out <= uart_D_out;
			when "110"|"111" =>
				D_out <= io_D_out;
			when others =>
				D_out <= vdp_D_out;
			end case;
		else
			if A(15 downto 14)="11" then
				D_out <= ram_D_out;
			else
				D_out <= irom_D_out;
			end if;
		end if;
	end process;
				
				
	-- external ram control
	
	process (clk_cpu)
	begin
		if rising_edge(clk_cpu) then
			if WR_n='0' and A(15 downto 2)="11111111111111" then
				case A(1 downto 0) is
				when "01" => bank0 <= D_in(5 downto 0);
				when "10" => bank1 <= D_in(5 downto 0);
				when "11" => bank2 <= D_in(5 downto 0);
				when others =>
				end case;
			end if;
		end if;
	end process;
	
	ram_cs_n <= '0';
	ram_oe_n <= RD_n;
	ram_we_n <= rom_WR_n;
	
	ram_ble_n <= not A(0);
	ram_bhe_n <= A(0);
	
	ram_a(12 downto 0) <= A(13 downto 1);
	process (A,bank0,bank1,bank2)
	begin
		case A(15 downto 14) is
		when "00" =>
			-- first kilobyte is always from bank 0
			if A(13 downto 10)="0000" then
				ram_a(18 downto 13) <= (others=>'0');
			else
				ram_a(18 downto 13) <= bank0;
			end if;
		when "01" =>
			ram_a(18 downto 13) <= bank1;
			
		when others =>
			ram_a(18 downto 13) <= bank2;
		end case;
	end process;
	
	ram_d(7 downto 0) <= (others=>'Z') when RD_n='0' else D_in;
	ram_d(15 downto 8) <= (others=>'Z') when RD_n='0' else D_in;
				
	with A(0) select
	rom_D_out<= ram_d(7 downto 0)		when '1',
					ram_d(15 downto 8)	when others;

end Behavioral;

