library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

entity vram is
	Port (clk	: in   STD_LOGIC;
         en		: in   STD_LOGIC;
			we		: in   STD_LOGIC;
			ain	: in   STD_LOGIC_VECTOR (13 downto 0);
			din	: in   STD_LOGIC_VECTOR (7 downto 0);
			aout	: in   STD_LOGIC_VECTOR (13 downto 0);
			dout	: out  STD_LOGIC_VECTOR (7 downto 0));
end vram;

architecture Behavioral of vram is
begin

   RAMB16_S1_inst0 : RAMB16_S1_S1
   port map (
      CLKA => not clk,
      ADDRA => ain,
      DIA => din(0 downto 0),
      DOA => open,
      ENA => '1',
      SSRA => '0',
      WEA => we,
		
      CLKB => not clk,
      ADDRB => aout,
      DIB => "0",
      DOB => dout(0 downto 0),
      ENB => en,
      SSRB => '0',
      WEB => '0'
   );

   RAMB16_S1_inst1 : RAMB16_S1_S1
   port map (
      CLKA => not clk,
      ADDRA => ain,
      DIA => din(1 downto 1),
      DOA => open,
      ENA => '1',
      SSRA => '0',
      WEA => we,
		
      CLKB => not clk,
      ADDRB => aout,
      DIB => "0",
      DOB => dout(1 downto 1),
      ENB => en,
      SSRB => '0',
      WEB => '0'
   );

   RAMB16_S1_inst2 : RAMB16_S1_S1
   port map (
      CLKA => not clk,
      ADDRA => ain,
      DIA => din(2 downto 2),
      DOA => open,
      ENA => '1',
      SSRA => '0',
      WEA => we,
		
      CLKB => not clk,
      ADDRB => aout,
      DIB => "0",
      DOB => dout(2 downto 2),
      ENB => en,
      SSRB => '0',
      WEB => '0'
   );

   RAMB16_S1_inst3 : RAMB16_S1_S1
   port map (
      CLKA => not clk,
      ADDRA => ain,
      DIA => din(3 downto 3),
      DOA => open,
      ENA => '1',
      SSRA => '0',
      WEA => we,
		
      CLKB => not clk,
      ADDRB => aout,
      DIB => "0",
      DOB => dout(3 downto 3),
      ENB => en,
      SSRB => '0',
      WEB => '0'
   );

   RAMB16_S1_inst4 : RAMB16_S1_S1
   port map (
      CLKA => not clk,
      ADDRA => ain,
      DIA => din(4 downto 4),
      DOA => open,
      ENA => '1',
      SSRA => '0',
      WEA => we,
		
      CLKB => not clk,
      ADDRB => aout,
      DIB => "0",
      DOB => dout(4 downto 4),
      ENB => en,
      SSRB => '0',
      WEB => '0'
   );

   RAMB16_S1_inst5 : RAMB16_S1_S1
   port map (
      CLKA => not clk,
      ADDRA => ain,
      DIA => din(5 downto 5),
      DOA => open,
      ENA => '1',
      SSRA => '0',
      WEA => we,
		
      CLKB => not clk,
      ADDRB => aout,
      DIB => "0",
      DOB => dout(5 downto 5),
      ENB => en,
      SSRB => '0',
      WEB => '0'
   );

   RAMB16_S1_inst6 : RAMB16_S1_S1
   port map (
      CLKA => not clk,
      ADDRA => ain,
      DIA => din(6 downto 6),
      DOA => open,
      ENA => '1',
      SSRA => '0',
      WEA => we,
		
      CLKB => not clk,
      ADDRB => aout,
      DIB => "0",
      DOB => dout(6 downto 6),
      ENB => en,
      SSRB => '0',
      WEB => '0'
   );

   RAMB16_S1_inst7 : RAMB16_S1_S1
   port map (
      CLKA => not clk,
      ADDRA => ain,
      DIA => din(7 downto 7),
      DOA => open,
      ENA => '1',
      SSRA => '0',
      WEA => we,
		
      CLKB => not clk,
      ADDRB => aout,
      DIB => "0",
      DOB => dout(7 downto 7),
      ENB => en,
      SSRB => '0',
      WEB => '0'
   );
end Behavioral;

