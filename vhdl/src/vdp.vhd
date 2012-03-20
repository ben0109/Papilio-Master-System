library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vdp is
	port (
		cpu_clk:			in  STD_LOGIC;
		vdp_clk:			in  STD_LOGIC;
		RD_n:				in  STD_LOGIC;
		WR_n:				in  STD_LOGIC;
		IRQ_n:			out STD_LOGIC;
		A:					in  STD_LOGIC_VECTOR (7 downto 0);
		D_in:				in  STD_LOGIC_VECTOR (7 downto 0);
		D_out:			out STD_LOGIC_VECTOR (7 downto 0);
		x:					unsigned(8 downto 0);
		y:					unsigned(7 downto 0);
		line_reset:		std_logic;
		frame_reset:	std_logic;
		color:			out std_logic_vector (5 downto 0));
end vdp;

architecture Behavioral of vdp is

	component vdp_control is
	port (
		cpu_clk:			in  STD_LOGIC;	
		cpu_RD_n:		in  STD_LOGIC;
		cpu_WR_n:		in  STD_LOGIC;
		cpu_A:			in  STD_LOGIC_VECTOR (7 downto 0);
		cpu_D_in:		in  STD_LOGIC_VECTOR (7 downto 0);
			
		A:					out STD_LOGIC_VECTOR (13 downto 0);
		vram_WE:			out STD_LOGIC;
		cram_WE:			out STD_LOGIC;
			
		display_on:		out STD_LOGIC;
		mask_column0:	out STD_LOGIC;
		overscan:		out STD_LOGIC_VECTOR (3 downto 0);
			
		irq_frame_en:	out STD_LOGIC;
		irq_line_en:	out STD_LOGIC;
		irq_line_count:out unsigned (7 downto 0);
			
		bg_address:		out STD_LOGIC_VECTOR (2 downto 0);
		bg_scroll_x:	out unsigned (7 downto 0);
		bg_scroll_y:	out unsigned (7 downto 0);

		spr_address:	out STD_LOGIC_VECTOR (5 downto 0);
		spr_shift:	 	out STD_LOGIC;
		spr_high_bit:	out STD_LOGIC;
		spr_tall:		out STD_LOGIC);
	end component;
	
	component vdp_main is
	port (
		clk:				in  std_logic;			
		vram_A:			out std_logic_vector(13 downto 0);
		vram_D:			in  std_logic_vector(7 downto 0);
		cram_A:			out std_logic_vector(4 downto 0);
		cram_D:			in  std_logic_vector(5 downto 0);
			
		x:					unsigned(8 downto 0);
		y:					unsigned(7 downto 0);
		line_reset:		std_logic;
		frame_reset:	std_logic;
			
		color:			out std_logic_vector (5 downto 0);
		irq_n:			out std_logic;
					
		display_on:		in  std_logic;
		mask_column0:	in  std_logic;
		overscan:		in  std_logic_vector (3 downto 0);

		bg_address:		in  std_logic_vector (2 downto 0);
		bg_scroll_x:	in  unsigned(7 downto 0);
		bg_scroll_y:	in  unsigned(7 downto 0);
			
		irq_frame_en:	in  std_logic;
		irq_line_en:	in  std_logic;
		irq_line_count:in  unsigned(7 downto 0);
			
		spr_address:	in  std_logic_vector (5 downto 0);
		spr_high_bit:	in  std_logic;
		spr_shift:		in  std_logic;	
		spr_tall:		in  std_logic);	
	end component;

	component vdp_vram is
	port (
		cpu_clk:			in  STD_LOGIC;
		cpu_WE:			in  STD_LOGIC;
		cpu_A:			in  STD_LOGIC_VECTOR (13 downto 0);
		cpu_D_in:		in  STD_LOGIC_VECTOR (7 downto 0);
		cpu_D_out:		out STD_LOGIC_VECTOR (7 downto 0);
		vdp_clk:			in  STD_LOGIC;
		vdp_A:			in  STD_LOGIC_VECTOR (13 downto 0);
		vdp_D_out:		out STD_LOGIC_VECTOR (7 downto 0));
	end component;
	
	component vdp_cram is
	port (
		cpu_clk:			in  STD_LOGIC;
		cpu_WE:			in  std_logic;
		cpu_A:			in  std_logic_vector(4 downto 0);
		cpu_D:			in  std_logic_vector(5 downto 0);
		vdp_clk:			in  STD_LOGIC;
		vdp_A:			in  std_logic_vector(4 downto 0);
		vdp_D:			out std_logic_vector(5 downto 0));
	end component;
	
	signal vram_write: 		std_logic := '0';
	signal address:			unsigned(15 downto 0);
	signal address_ff:		std_logic := '0';
	
	signal control_A:			std_logic_vector(13 downto 0);
	signal vram_cpu_WE:		std_logic;
	signal vram_vdp_A:		std_logic_vector(13 downto 0);
	signal vram_vdp_D:		std_logic_vector(7 downto 0);
	
	signal cram_cpu_WE:		std_logic;
	signal cram_vdp_A:		std_logic_vector(4 downto 0);
	signal cram_vdp_D:		std_logic_vector(5 downto 0);
			
	signal display_on:		std_logic := '1';
	signal mask_column0:		std_logic := '0';
	signal overscan:			std_logic_vector (3 downto 0) := "0000";
	
	signal irq_frame_en:		std_logic := '0';
	signal irq_line_en:		std_logic := '0';
	signal irq_line_count:	unsigned(7 downto 0) := (others=>'1');
	
	signal bg_address:		std_logic_vector (2 downto 0) := (others=>'0');
	signal bg_scroll_x:		unsigned(7 downto 0) := (others=>'0');
	signal bg_scroll_y:		unsigned(7 downto 0) := (others=>'0');
	signal spr_address:		std_logic_vector (5 downto 0) := (others=>'0');
	signal spr_shift:			std_logic := '0';
	signal spr_tall:			std_logic := '0';
	signal spr_high_bit:		std_logic := '0';

	signal hcount:				unsigned(8 downto 0) := (others=>'0');
	signal vcount:				unsigned(8 downto 0) := "000101000";

	signal bg_vram_A:			std_logic_vector(13 downto 0);
	signal bg_color:			std_logic_vector(4 downto 0);
	signal bg_priority:		std_logic;
	
	signal spr_vram_A:		std_logic_vector(13 downto 0);
	signal spr_color:			std_logic_vector(3 downto 0);

	signal irq_counter:		unsigned(3 downto 0) := (others=>'0');
	signal vbl_irq:			std_logic;
	signal hbl_irq:			std_logic;
	
begin
		
	vdp_main_inst: vdp_main
	port map(
		clk				=> vdp_clk,
		vram_A			=> vram_vdp_A,
		vram_D			=> vram_vdp_D,
		cram_A			=> cram_vdp_A,
		cram_D			=> cram_vdp_D,
				
		x					=> x,
		y					=> y,
		line_reset		=> line_reset,
		frame_reset		=> frame_reset,
		color				=> color,
		irq_n				=> irq_n,
						
		display_on		=> '1',--display_on,
		mask_column0	=> mask_column0,
		overscan			=> overscan,
				
		irq_frame_en	=> irq_frame_en,
		irq_line_en		=> irq_line_en,
		irq_line_count	=> irq_line_count,

		bg_address		=> bg_address,
		bg_scroll_x		=> bg_scroll_x,
		bg_scroll_y		=> bg_scroll_y,
				
		spr_address		=> spr_address,
		spr_high_bit	=> spr_high_bit,
		spr_shift		=> spr_shift,
		spr_tall			=> spr_tall);

	vdp_vram_inst: vdp_vram
	port map (
		cpu_clk			=> cpu_clk,
		cpu_WE			=> vram_cpu_WE,
		cpu_A				=> control_A,
		cpu_D_in			=> D_in,
		cpu_D_out		=> D_out,
		vdp_clk			=> vdp_clk,
		vdp_A				=> vram_vdp_A,
		vdp_D_out		=> vram_vdp_D);

	vdp_cram_inst: vdp_cram
	port map (
		cpu_clk			=> cpu_clk,
		cpu_WE			=> cram_cpu_WE,
		cpu_A 			=> control_A(4 downto 0),
		cpu_D				=> D_in(5 downto 0),
		vdp_clk			=> vdp_clk,
		vdp_A				=> cram_vdp_A,
		vdp_D				=> cram_vdp_D);
		
		
		

	control_A <= std_logic_vector(address(13 downto 0));
	cram_cpu_WE <= not WR_n and not A(0) and address(15) and address(14);
	vram_cpu_WE <= not WR_n and not A(0) and not (address(15) and address(14));

	process (cpu_clk)
	begin
		if rising_edge(cpu_clk) then
			if WR_n='1' then
				if vram_write='1' then
					vram_write <= '0';
					address <= address + 1;
				end if;
				
			elsif WR_n='0' then
				if A(0)='0' then
					vram_write <= '1';
				else
					if address_ff='0' then
						address(7 downto 0) <= unsigned(D_in);
					else
						address(15 downto 8) <= unsigned(D_in);
						
						if D_in(7)='1' and D_in(6)='0' then
							case D_in(5 downto 0) is
							when "000000" =>
								mask_column0 <= address(5);
								irq_line_en <= address(4);
								spr_shift <= address(3);
							when "000001" =>
								display_on <= address(6);
								irq_frame_en <= address(5);
								spr_tall <= control_A(1);
							when "000010" =>
								bg_address <= std_logic_vector(address(3 downto 1));
							when "000101" =>
								spr_address <= std_logic_vector(address(6 downto 1));
							when "000110" =>
								spr_high_bit <= address(2);
							when "000111" =>
								overscan <= std_logic_vector(address(3 downto 0));
							when "001000" =>
								bg_scroll_x <= unsigned(address(7 downto 0));
							when "001001" =>
								bg_scroll_y <= unsigned(address(7 downto 0));
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
	
end Behavioral;
