library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vdp_control is
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
end vdp_control;

architecture Behavioral of vdp_control is
	
	signal address_ff	: std_logic := '0';
	signal address		: unsigned(15 downto 0);
	
	signal vram_write	: std_logic := '0';

begin

	A <= std_logic_vector(address(13 downto 0));
	cram_WE <= not cpu_WR_n and not cpu_A(0) and address(15) and address(14);
	vram_WE <= not cpu_WR_n and not cpu_A(0) and not (address(15) and address(14));

	process (clk,cpu_RD_n,cpu_WR_n,cpu_A,cpu_D_in,address_ff)
	begin
		if rising_edge(clk) then
			if cpu_WR_n='1' then
				if vram_write='1' then
					vram_write <= '0';
					address <= address + 1;
				end if;
				
			elsif cpu_WR_n='0' then
				if cpu_A(0)='0' then
					vram_write <= '1';
				else
					if address_ff='0' then
						address(7 downto 0) <= unsigned(cpu_D_in);
					else
						address(15 downto 8) <= unsigned(cpu_D_in);
						
						if cpu_D_in(7)='1' and cpu_D_in(6)='0' then
							case cpu_D_in(5 downto 0) is
							when "000000" =>
								mask_column0 <= address(5);
								line_irq_en <= address(4);
								shift_spr <= address(3);
							when "000001" =>
								display_on <= address(6);
								frame_irq_en <= address(5);
								big_sprites <= address(1);
							when "000010" =>
								text_address <= std_logic_vector(address(3 downto 1));
							when "000101" =>
								spr_address <= std_logic_vector(address(6 downto 1));
							when "000110" =>
								spr_high_bit <= address(2);
							when "000111" =>
								overscan <= std_logic_vector(address(3 downto 0));
							when "001000" =>
								scroll_x <= address(7 downto 0);
							when "001001" =>
								scroll_y <= address(7 downto 0);
							when "001010" =>
								line_count <= address(7 downto 0);
							when others =>
							end case;
						end if;
					end if;
					address_ff <= not address_ff;
				end if;
			end if;
		end if;
	end process;


end Behavioral;

