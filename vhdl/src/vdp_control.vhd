library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vdp_control is
	port (cpu_clk			: in  STD_LOGIC;
			cpu_RD_n		: in  STD_LOGIC;
			cpu_WR_n		: in  STD_LOGIC;
			cpu_A			: in  STD_LOGIC_VECTOR (7 downto 0);
			cpu_D_in		: in  STD_LOGIC_VECTOR (7 downto 0);
			
			A				: out STD_LOGIC_VECTOR (13 downto 0);
			vram_WE		: out STD_LOGIC;
			cram_WE		: out STD_LOGIC;
			
			display_on	: out STD_LOGIC;
			mask_column0: out STD_LOGIC;
			overscan		: out STD_LOGIC_VECTOR (3 downto 0);
			
			irq_frame_en: out STD_LOGIC;
			irq_line_en	: out STD_LOGIC;
			irq_line_count	: out unsigned (7 downto 0);
			
			bg_address	: out STD_LOGIC_VECTOR (2 downto 0);
			bg_scroll_x	: out unsigned (7 downto 0);
			bg_scroll_y	: out unsigned (7 downto 0);

			spr_address	: out STD_LOGIC_VECTOR (5 downto 0);
			spr_shift	: out STD_LOGIC;
			spr_high_bit: out STD_LOGIC;
			spr_tall		: out STD_LOGIC);
end vdp_control;

architecture Behavioral of vdp_control is
	
	signal address_ff	: std_logic := '0';
	signal address		: unsigned(15 downto 0);
	
	signal vram_write	: std_logic := '0';
	
	signal irq_frame_en_in : std_logic := '0';
	signal irq_line_en_in : std_logic := '0';

begin

	A <= std_logic_vector(address(13 downto 0));
	cram_WE <= not cpu_WR_n and not cpu_A(0) and address(15) and address(14);
	vram_WE <= not cpu_WR_n and not cpu_A(0) and not (address(15) and address(14));

	process (cpu_clk)
	begin
		if rising_edge(cpu_clk) then
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
								irq_line_en_in <= address(4);
								spr_shift <= address(3);
							when "000001" =>
								display_on <= address(6);
								irq_frame_en_in <= address(5);
								spr_tall <= address(1);
							when "000010" =>
								bg_address <= std_logic_vector(address(3 downto 1));
							when "000101" =>
								spr_address <= std_logic_vector(address(6 downto 1));
							when "000110" =>
								spr_high_bit <= address(2);
							when "000111" =>
								overscan <= std_logic_vector(address(3 downto 0));
							when "001000" =>
								bg_scroll_x <= address(7 downto 0);
							when "001001" =>
								bg_scroll_y <= address(7 downto 0);
							when "001010" =>
								irq_line_count <= address(7 downto 0);
							when others =>
							end case;
						end if;
					end if;
					address_ff <= not address_ff;
				end if;
			end if;
		end if;
	end process;

	irq_frame_en <= irq_frame_en_in;
	irq_line_en <= irq_line_en_in;

end Behavioral;

