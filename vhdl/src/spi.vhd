library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi is
	Port (
		clk	: in  STD_LOGIC;
		RD_n	: in  STD_LOGIC;
		WR_n	: in  STD_LOGIC;
		A		: in  STD_LOGIC_VECTOR (7 downto 0);
		D_in	: in  STD_LOGIC_VECTOR (7 downto 0);
		D_out	: out STD_LOGIC_VECTOR (7 downto 0);
		
		ss		: out STD_LOGIC;
		sck	: out STD_LOGIC;
		miso	: in  STD_LOGIC;
		mosi	: out STD_LOGIC);
end spi;

architecture Behavioral of spi is
	signal ready	: std_logic := '1';
	signal div_rst	: std_logic_vector(6 downto 0) := "0000000";
	signal clk_div	: std_logic_vector(6 downto 0) := "0000000";
	signal in_ss	: std_logic := '1';
	signal in_sck	: std_logic := '0';
	signal in_mosi	: std_logic := '0';
	signal shift	: std_logic_vector(7 downto 0);
	signal count	: integer := 0;
	signal ff		: std_logic := '0';
begin
	process (clk,A,WR_n,RD_n,D_in,miso)
	begin
		if rising_edge(clk) then
			if count>0 then
				case clk_div is
				when "0000000" =>
					in_sck <= ff;
					if ff='1' then
						in_mosi <= shift(7);
					else
						shift <= shift(6 downto 0)&miso;
					end if;
					ff <= not ff;
					count <= count-1;
					clk_div <= div_rst;
				when others =>
					clk_div <= std_logic_vector(unsigned(clk_div)-1);
				end case;
				
			elsif WR_n='0' then
				if A(0)='0' then
					in_ss <= D_in(7);
					div_rst <= D_in(6 downto 0);
				elsif ready='1' then
					shift <= D_in;
					in_mosi <= D_in(7);
					count <= 16;
					ff <= '0';
					clk_div <= div_rst;
				end if;
			end if;
		end if;
	end process;
	
	process (count)
	begin
		if count=0 then
			ready <= '1';
		else
			ready <= '0';
		end if;
	end process;
	
	
	process (clk,A,WR_n,RD_n,D_in,miso)
	begin
		if rising_edge(clk) and RD_n='0' then
			if A(0)='0' then
				D_out <= ready&div_rst;
			else
				D_out <= shift;
			end if;
		end if;
	end process;
	
	ss <= in_ss;
	sck <= ff;
	mosi <= in_mosi;

end Behavioral;

