library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vdp_cram is
	Port (clk	: in  STD_LOGIC;
			WE		: in  STD_LOGIC;
			A_in	: in  STD_LOGIC_VECTOR (4 downto 0);
			D_in	: in  STD_LOGIC_VECTOR (5 downto 0);
			A_out	: in  STD_LOGIC_VECTOR (4 downto 0);
			D_out	: out STD_LOGIC_VECTOR (5 downto 0));
end vdp_cram;

architecture Behavioral of vdp_cram is

	type t_ram is array (0 to 31) of std_logic_vector(5 downto 0);
	signal ram : t_ram := (others => "000000");
	
begin

	process (clk,WE,A_in)
		variable i : integer range 0 to 31;
	begin
		if rising_edge(clk) and WE='1'then
			i := to_integer(unsigned(A_in));
			ram(i) <= D_in;
		end if;
	end process;

	process (clk,A_out)
		variable i : integer range 0 to 31;
	begin
		if rising_edge(clk) then
			i := to_integer(unsigned(A_out));
			D_out <= ram(i);
		end if;
	end process;

end Behavioral;

