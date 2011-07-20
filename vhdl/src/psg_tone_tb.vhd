LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY psg_tone_tb IS
END psg_tone_tb;
 
ARCHITECTURE behavior OF psg_tone_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT psg_tone
    PORT(
         clk : IN  std_logic;
         tone : IN  std_logic_vector(9 downto 0);
         volume : IN  std_logic_vector(3 downto 0);
         output : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal tone : std_logic_vector(9 downto 0) := (others => '0');
   signal volume : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal output : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: psg_tone PORT MAP (
          clk => clk,
          tone => tone,
          volume => volume,
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
		tone <= "0000000000";
		volume <= "1000";
		wait for clk_period*3000;
		
		tone <= "0000001000";
		volume <= "1000";
		wait for clk_period*3000;
		
		tone <= "0000001000";
		volume <= "1111";
		wait for clk_period*3000;
		
		tone <= "0000001000";
		volume <= "0000";
		wait for clk_period*3000;
   end process;

END;
