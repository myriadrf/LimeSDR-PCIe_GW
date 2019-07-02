-- ----------------------------------------------------------------------------
-- FILE:          shift_reg_tb.vhd
-- DESCRIPTION:   
-- DATE:          02:05 PM Wednesday, June 19, 2019
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity shift_reg_tb is
end shift_reg_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of shift_reg_tb is
   constant clk0_period    : time := 10 ns;
   constant clk1_period    : time := 10 ns; 
   --signals
   signal clk0,clk1        : std_logic;
   signal reset_n          : std_logic; 
   
   constant dut0_g_IN_WIDTH  : integer := 512;
   constant dut0_g_OUT_WIDTH : integer := 32;
   signal dut0_ld          : std_logic;
   signal dut0_d           : std_logic_vector(dut0_g_IN_WIDTH-1 downto 0);
   signal dut0_ready       : std_logic;
   signal dut0_valid       : std_logic;
   signal dut0_q           : std_logic_vector(dut0_g_OUT_WIDTH-1 downto 0);
   
  
begin 
  
      clock0: process is
   begin
      clk0 <= '0'; wait for clk0_period/2;
      clk0 <= '1'; wait for clk0_period/2;
   end process clock0;

      clock: process is
   begin
      clk1 <= '0'; wait for clk1_period/2;
      clk1 <= '1'; wait for clk1_period/2;
   end process clock;
   
      res: process is
   begin
      reset_n <= '0'; wait for 20 ns;
      reset_n <= '1'; wait;
   end process res;
   
   
   process is 
   begin 
      dut0_ld <= '0';
      dut0_d <= (others=>'0');
      wait until reset_n = '1' AND rising_edge(clk0);
      dut0_ld <= '1';
      dut0_d <= (others=>'1');
      wait until reset_n = '1' AND rising_edge(clk0);
      dut0_ld <= '0';
      wait;
   end process;
   
   process is 
   begin
      dut0_ready <= '0';
      wait until reset_n = '1' AND rising_edge(clk0);
      dut0_ready <= '1';
      wait until dut0_valid = '1' AND rising_edge(clk0);
      wait until rising_edge(clk0);
      dut0_ready <= '0';
      wait until rising_edge(clk0);
      dut0_ready <= '1';
      for i in 0 to 12 loop
         wait until rising_edge(clk0);
      end loop;
      dut0_ready <= '0';
      wait until rising_edge(clk0);
      dut0_ready <= '1';
      
      
      
      
      wait;
   end process;
   
      -- design under test  
   dut0 : entity work.shift_reg
   generic map(
      g_IN_WIDTH   => dut0_g_IN_WIDTH,
      g_OUT_WIDTH  => dut0_g_OUT_WIDTH
   )
   port map(
      clk      => clk0,
      reset_n  => reset_n,
      ld       => dut0_ld,
      d        => dut0_d,
      ready    => dut0_ready,
      valid    => dut0_valid,
      q        => dut0_q
   );

end tb_behave;

