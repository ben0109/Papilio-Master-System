library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity clock is
port (
	clk_in:		in  std_logic;
	clk_cpu:		out std_logic;
	clk_cpu_n:	out std_logic;
	clk32:		out std_logic;
	clk64:		out std_logic);
end clock;

architecture BEHAVIORAL of clock is

   signal CLKFB_IN:		std_logic;
   signal CLKFX_BUF:		std_logic;
   signal CLKFX180_BUF:	std_logic;
   signal CLKIN_IBUFG:	std_logic;
   signal CLK2X_BUF:		std_logic;
   signal GND_BIT:		std_logic;
	
begin
   GND_BIT <= '0';
   clk32 <= CLKIN_IBUFG;
   clk64 <= CLKFB_IN;
   CLKFX_BUFG_INST : BUFG
      port map (I=>CLKFX_BUF,
                O=>clk_cpu);
   
   CLKFX180_BUFG_INST : BUFG
      port map (I=>CLKFX180_BUF,
                O=>clk_cpu_n);
   
   CLKIN_IBUFG_INST : IBUFG
      port map (I=>clk_in,
                O=>CLKIN_IBUFG);
   
   CLK2X_BUFG_INST : BUFG
      port map (I=>CLK2X_BUF,
                O=>CLKFB_IN);
   
   DCM_SP_INST : DCM_SP
   generic map(
		CLK_FEEDBACK => "2X",
		CLKDV_DIVIDE => 4.0,
		CLKFX_DIVIDE => 32,
		CLKFX_MULTIPLY => 8,
		CLKIN_DIVIDE_BY_2 => FALSE,
		CLKIN_PERIOD => 31.250,
		CLKOUT_PHASE_SHIFT => "NONE",
		DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS",
		DFS_FREQUENCY_MODE => "LOW",
		DLL_FREQUENCY_MODE => "LOW",
		DUTY_CYCLE_CORRECTION => TRUE,
		FACTORY_JF => x"C080",
		PHASE_SHIFT => 0,
		STARTUP_WAIT => TRUE)
	port map (
		CLKIN		=> CLKIN_IBUFG,
		CLKFB		=> CLKFB_IN,
		
		DSSEN		=> GND_BIT,
		PSCLK		=> GND_BIT,
		PSEN		=> GND_BIT,
		PSINCDEC	=> GND_BIT,
		RST		=> GND_BIT,
		
		LOCKED	=> open,
		PSDONE	=> open,
		STATUS	=> open,
		
		CLK0		=> open,
		CLK90		=> open,
		CLK180	=> open,
		CLK270	=> open,
		CLKDV		=> open,
		CLKFX		=> CLKFX_BUF,
		CLKFX180	=> CLKFX180_BUF,
		CLK2X		=> CLK2X_BUF,
		CLK2X180	=> open);
   
end BEHAVIORAL;


