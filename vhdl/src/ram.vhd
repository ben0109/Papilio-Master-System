library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

entity ram is
	port (
		clk:		in   STD_LOGIC;
		RD_n:		in   STD_LOGIC;
		WR_n:		in   STD_LOGIC;
		A:			in   STD_LOGIC_VECTOR (12 downto 0);
		D_in:		in   STD_LOGIC_VECTOR (7 downto 0);
		D_out:	out  STD_LOGIC_VECTOR (7 downto 0));
end entity;

architecture Behavioral of ram is
begin

   RAMB16_S2_inst0 : RAMB16_S2
   port map (
      CLK	=> clk,
      EN		=> '1',
      SSR	=> '0',
      WE		=> not WR_n,
      ADDR	=> a,
      DI		=> D_in(1 downto 0),
      DO		=> D_out(1 downto 0)
   );

   RAMB16_S2_inst1 : RAMB16_S2
   port map (
      CLK	=> clk,
      EN		=> '1',
      SSR	=> '0',
      WE		=> not WR_n,
      ADDR	=> a,
      DI		=> D_in(3 downto 2),
      DO		=> D_out(3 downto 2)
   );

   RAMB16_S2_inst2 : RAMB16_S2
   port map (
      CLK	=> clk,
      EN		=> '1',
      SSR	=> '0',
      WE		=> not WR_n,
      ADDR	=> a,
      DI		=> D_in(5 downto 4),
      DO		=> D_out(5 downto 4)
   );

   RAMB16_S2_inst3 : RAMB16_S2
   port map (
      CLK	=> clk,
      EN		=> '1',
      SSR	=> '0',
      WE		=> not WR_n,
      ADDR	=> a,
      DI		=> D_in(7 downto 6),
      DO		=> D_out(7 downto 6)
   );

end Behavioral;

