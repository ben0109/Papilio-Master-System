----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:59:35 01/22/2012 
-- Design Name: 
-- Module Name:    vdp_vga_timing - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vdp_vga_timing is
port (
	clk_16:			in  std_logic;
	x: 				out unsigned(8 downto 0);
	y:					out unsigned(7 downto 0);
	line_reset:		out std_logic;
	frame_reset:	out std_logic;
	color:			in std_logic_vector(5 downto 0);
	hsync:			out std_logic;
	vsync:			out std_logic;
	red:				out std_logic_vector(1 downto 0);
	green:			out std_logic_vector(1 downto 0);
	blue:				out std_logic_vector(1 downto 0));
end vdp_vga_timing;

architecture Behavioral of vdp_vga_timing is

	signal hcount:		unsigned (8 downto 0);
	signal vcount:		unsigned (8 downto 0);
	signal visible:	boolean;
	
begin
	
	process (clk_16)
	begin
		if rising_edge(clk_16) then
			if hcount=507 then
				hcount <= (others => '0');
				if vcount=524 then
					vcount <= (others=>'0');
				else
					vcount <= vcount + 1;
				end if;
			else
				hcount <= hcount + 1;
			end if;
		end if;
	end process;
	
	frame_reset	<= '1' when vcount=0 and hcount=0 else '0';
	line_reset	<= '1' when hcount=156 else '0';
	
	x				<= hcount-(91+75);
	y				<= vcount(8 downto 1)-(17+20);
	
	hsync			<= '0' when hcount<61 else '1';
	vsync			<= '0' when vcount<2 else '1';
	
	visible		<= vcount>=35 and vcount<35+480 and hcount>=91 and hcount<91+406;
	red			<= color(1 downto 0) when visible else "00";
	green			<= color(3 downto 2) when visible else "00";
	blue			<= color(5 downto 4) when visible else "00";

end Behavioral;

