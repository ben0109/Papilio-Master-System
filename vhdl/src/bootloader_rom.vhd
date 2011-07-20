library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

entity boot_rom is
	port (clk	: in   STD_LOGIC;
			RD_n	: in   STD_LOGIC;
			A		: in   STD_LOGIC_VECTOR (13 downto 0);
			D_in	: in   STD_LOGIC_VECTOR (7 downto 0);
			D_out	: out  STD_LOGIC_VECTOR (7 downto 0));
end entity;

architecture Behavioral of boot_rom is
begin
   RAMB16_S1_inst0 : RAMB16_S1
   port map (
      DO => D_out(0 downto 0),
      ADDR => A,
      CLK => not clk,
      DI => D_in(0 downto 0),
      EN => '1',
      SSR => '0',
      WE => '0'
   );

   RAMB16_S1_inst1 : RAMB16_S1
   port map (
      DO => D_out(1 downto 1),
      ADDR => A,
      CLK => not clk,
      DI => D_in(1 downto 1),
      EN => '1',
      SSR => '0',
      WE => '0'
   );

   RAMB16_S1_inst2 : RAMB16_S1
   port map (
      DO => D_out(2 downto 2),
      ADDR => A,
      CLK => not clk,
      DI => D_in(2 downto 2),
      EN => '1',
      SSR => '0',
      WE => '0'
   );

   RAMB16_S1_inst3 : RAMB16_S1
   port map (
      DO => D_out(3 downto 3),
      ADDR => A,
      CLK => not clk,
      DI => D_in(3 downto 3),
      EN => '1',
      SSR => '0',
      WE => '0'
   );

   RAMB16_S1_inst4 : RAMB16_S1
   port map (
      DO => D_out(4 downto 4),
      ADDR => A,
      CLK => not clk,
      DI => D_in(4 downto 4),
      EN => '1',
      SSR => '0',
      WE => '0'
   );

   RAMB16_S1_inst5 : RAMB16_S1
   port map (
      DO => D_out(5 downto 5),
      ADDR => A,
      CLK => not clk,
      DI => D_in(5 downto 5),
      EN => '1',
      SSR => '0',
      WE => '0'
   );

   RAMB16_S1_inst6 : RAMB16_S1
   port map (
      DO => D_out(6 downto 6),
      ADDR => A,
      CLK => not clk,
      DI => D_in(6 downto 6),
      EN => '1',
      SSR => '0',
      WE => '0'
   );

   RAMB16_S1_inst7 : RAMB16_S1
   port map (
      DO => D_out(7 downto 7),
      ADDR => A,
      CLK => not clk,
      DI => D_in(7 downto 7),
      EN => '1',
      SSR => '0',
      WE => '0'
   );

end Behavioral;
