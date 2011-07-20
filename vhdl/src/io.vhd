library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity io is
    Port(clk		: in  STD_LOGIC;
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
end io;

architecture rtl of io is
begin

	process (clk, A,
				RD_n, J1_up, J1_down, J1_left, J1_right, J1_tl, J1_tr,
				J2_up, J2_down, J2_left, J2_right, J2_tl, J2_tr, RESET)
	begin
		if rising_edge(clk) and RD_n='0' then
			if A(0)='0' then
				D_out <= J2_down&J2_up&J1_tr&J1_tl&J1_right&J1_left&J1_down&J1_up;
			else
				D_out <= "111"&RESET&J2_tr&J2_tl&J2_right&J2_left;
			end if;
		end if;
	end process;
	
end rtl;

