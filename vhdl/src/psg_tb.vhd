--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:25:36 04/17/2011
-- Design Name:   
-- Module Name:   /home/ben/prog/vhdl/svga/psg_tb.vhd
-- Project Name:  svga
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: psg
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY psg_tb IS
END psg_tb;
 
ARCHITECTURE behavior OF psg_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT psg
    PORT(
         clk	: IN  std_logic;
         WR_n	: IN  std_logic;
         D_in	: IN  std_logic_vector(7 downto 0);
         output: OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal WR_n : std_logic := '0';
   signal D_in : std_logic_vector(7 downto 0);

 	--Outputs
   signal output : std_logic;

   -- Clock period definitions
   constant clk_period : time := 125 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: psg PORT MAP (
          clk => clk,
          WR_n => WR_n,
          D_in => D_in,
          output => output
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
