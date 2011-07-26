library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

entity ram is
	Port (clk	: in   STD_LOGIC;
			RD_n	: in   STD_LOGIC;
			WR_n	: in   STD_LOGIC;
			A		: in   STD_LOGIC_VECTOR (12 downto 0);
			D_in	: in   STD_LOGIC_VECTOR (7 downto 0);
			D_out	: out  STD_LOGIC_VECTOR (7 downto 0));
end entity;

architecture Behavioral of ram is
begin

   RAMB16_S2_inst0 : RAMB16_S2
   port map (
      DO => D_out(1 downto 0),
      ADDR => a,
      CLK => not clk,
      DI => D_in(1 downto 0),
      EN => '1',
      SSR => '0',
      WE => not WR_n
   );

   RAMB16_S2_inst1 : RAMB16_S2
   port map (
      DO => D_out(3 downto 2),
      ADDR => a,
      CLK => not clk,
      DI => D_in(3 downto 2),
      EN => '1',
      SSR => '0',
      WE => not WR_n
   );

   RAMB16_S2_inst2 : RAMB16_S2
   port map (
      DO => D_out(5 downto 4),
      ADDR => a,
      CLK => not clk,
      DI => D_in(5 downto 4),
      EN => '1',
      SSR => '0',
      WE => not WR_n
   );

   RAMB16_S2_inst3 : RAMB16_S2
   port map (
      DO => D_out(7 downto 6),
      ADDR => a,
      CLK => not clk,
      DI => D_in(7 downto 6),
      EN => '1',
      SSR => '0',
      WE => not WR_n
   );

end Behavioral;
