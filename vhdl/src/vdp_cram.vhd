library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vdp_cram is
	Port (clk		: in  STD_LOGIC;
			cpu_we	: in  STD_LOGIC;
			cpu_a		: in  STD_LOGIC_VECTOR (4 downto 0);
			cpu_d_in	: in  STD_LOGIC_VECTOR (5 downto 0);
			cpu_d_out: out STD_LOGIC_VECTOR (5 downto 0);
			vdp_a		: in  STD_LOGIC_VECTOR (4 downto 0);
			vdp_d_out: out STD_LOGIC_VECTOR (5 downto 0));
end vdp_cram;

architecture Behavioral of vdp_cram is

	type t_ram is array (0 to 31) of std_logic_vector(5 downto 0);
	signal ram : t_ram := (others => "000000");
	
begin

	process (clk,cpu_a,cpu_we)
		variable i : integer range 0 to 31;
	begin
		if rising_edge(clk) then
			i := to_integer(unsigned(cpu_a));
			if cpu_we='1' then
				ram(i) <= cpu_d_in;
			end if;
			cpu_d_out <= ram(i);
		end if;
	end process;

	process (clk,vdp_a)
		variable i : integer range 0 to 31;
	begin
		if rising_edge(clk) then
			i := to_integer(unsigned(vdp_a));
			vdp_d_out <= ram(i);
		end if;
	end process;

end Behavioral;

