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
    Port(
		clk:		in		STD_LOGIC;
		WR_n:		in		STD_LOGIC;
		RD_n:		in		STD_LOGIC;
		A:			in		STD_LOGIC_VECTOR (7 downto 0);
		D_in:		in		STD_LOGIC_VECTOR (7 downto 0);
		D_out:	out	STD_LOGIC_VECTOR (7 downto 0);
		J1_up:	in 	STD_LOGIC;
		J1_down:	in 	STD_LOGIC;
		J1_left:	in 	STD_LOGIC;
		J1_right:in 	STD_LOGIC;
		J1_tl:	in 	STD_LOGIC;
		J1_tr:	inout STD_LOGIC;
		J2_up:	in 	STD_LOGIC;
		J2_down:	in 	STD_LOGIC;
		J2_left:	in 	STD_LOGIC;
		J2_right:in 	STD_LOGIC;
		J2_tl:	in 	STD_LOGIC;
		J2_tr:	inout STD_LOGIC;
		RESET:	in 	STD_LOGIC);
end io;

architecture rtl of io is

	signal j1_th:	std_logic := '0';
	signal j2_th:	std_logic := '0';

begin

	process (clk)
	begin
		if rising_edge(clk) then
			if WR_n='0'  and A(0)='0' then
				if D_in(0)='1' then J1_tr <= 'Z'; else J1_tr <= D_in(4); end if;
				if D_in(1)='1' then J1_th <= '0'; else J1_th <= D_in(5); end if;
				if D_in(2)='1' then J2_tr <= 'Z'; else J2_tr <= D_in(6); end if;
				if D_in(3)='1' then J2_th <= '0'; else J2_th <= D_in(7); end if;
			end if;
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			if RD_n='0' then
				if A(0)='0' then
					D_out <= J2_down&J2_up&J1_tr&J1_tl&J1_right&J1_left&J1_down&J1_up;
				else
					D_out <= J2_th&J1_th&"1"&RESET&J2_tr&J2_tl&J2_right&J2_left;
				end if;
			end if;
		end if;
	end process;
	
end rtl;

