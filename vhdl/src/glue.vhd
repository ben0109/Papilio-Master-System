library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity glue is
	port (
		clk:					in  STD_LOGIC;
		IO_n:					in  STD_LOGIC;
		RD_n:					in  STD_LOGIC;
		WR_n:					in  STD_LOGIC;
		A:						in  STD_LOGIC_VECTOR(15 downto 0);
		D_in:					in  STD_LOGIC_VECTOR(7 downto 0);
		D_out:				out STD_LOGIC_VECTOR(7 downto 0);
		RESET_n:				out STD_LOGIC;
			
		vdp_RD_n:			out STD_LOGIC;
		vdp_WR_n:			out STD_LOGIC;
		vdp_D_out:			in  STD_LOGIC_VECTOR(7 downto 0);
		psg_WR_n:			out STD_LOGIC;
		io_RD_n:				out STD_LOGIC;
		io_WR_n:				out STD_LOGIC;
		io_D_out:			in  STD_LOGIC_VECTOR(7 downto 0);
		ram_RD_n:			out STD_LOGIC;
		ram_WR_n:			out STD_LOGIC;
		ram_D_out:			in  STD_LOGIC_VECTOR(7 downto 0);
		rom_RD_n:			out STD_LOGIC;
		rom_WR_n:			out STD_LOGIC;
		rom_D_out:			in  STD_LOGIC_VECTOR(7 downto 0);
			
		boot_rom_RD_n:		out STD_LOGIC;
		boot_rom_D_out:	in  STD_LOGIC_VECTOR(7 downto 0);
		spi_RD_n:			out STD_LOGIC;
		spi_WR_n:			out STD_LOGIC;
		spi_D_out:			in  STD_LOGIC_VECTOR(7 downto 0));
end glue;

architecture Behavioral of glue is

	signal reset_counter : unsigned(3 downto 0) := "1111";
	signal bootloader : std_logic := '0';
	signal internal_D_out : std_logic_vector(7 downto 0);
	signal irom_RD_n : std_logic := '1';
	
	signal RD_n_reg	: std_logic := '1';
	signal WR_n_reg	: std_logic := '1';
	signal RD_n_clk	: std_logic := '1';
	signal WR_n_clk	: std_logic := '1';
	
begin

	reset_n <= '0' when reset_counter>0 else '1';

	process (clk)
	begin
		if rising_edge(clk) then
			if reset_counter>0 then
				reset_counter <= reset_counter - 1;
			end if;
		end if;
	end process;
	
	process (clk,RD_n_clk,WR_n_clk)
	begin
		if rising_edge(clk) then
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
	
	rom_WR_n <= not io_n or WR_n_clk or (A(15) and A(14));
	irom_RD_n <= not io_n or RD_n_clk or (A(15) and A(14));
	
	ram_WR_n <= not io_n or WR_n_clk or not (A(15) and A(14));
	ram_RD_n <= not io_n or RD_n_clk or not (A(15) and A(14));
	
	boot_rom_RD_n <= bootloader or irom_RD_n;
	rom_RD_n <= not bootloader or irom_RD_n;
	
	process (clk,io_n,WR_n,A,D_in)
	begin
		if rising_edge(clk) and WR_n_clk='0' then
			if io_n='0' and A(7)='0' and A(6)='0' and A(0)='0' then
				-- memory control
				if bootloader='0' then
					bootloader <= D_in(7);
				end if;
			end if;
		end if;
	end process;
	
	process (bootloader,io_n,A,vdp_D_out,io_D_out,ram_D_out,rom_D_out,boot_rom_D_out,spi_D_out)
	begin
		if io_n='0' then
			case A(7 downto 6) is
			when "00" =>
				if bootloader='0' then
					D_out <= spi_D_out;
				end if;
			when "01" => D_out <= vdp_D_out;
			when "10" => D_out <= vdp_D_out;
			when "11" => D_out <= io_D_out;
			when others =>
			end case;
			
		else
			case A(15 downto 14) is
			when "11" => D_out <= ram_D_out;
			when others =>
				if bootloader='0' then
					D_out <= boot_rom_D_out;
				else
					D_out <= rom_D_out;
				end if;
			end case;
		end if;
	end process;

end Behavioral;

