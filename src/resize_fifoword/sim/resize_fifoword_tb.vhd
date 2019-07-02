-- ----------------------------------------------------------------------------
-- FILE:          resize_fifoword_tb.vhd
-- DESCRIPTION:   
-- DATE:          Feb 13, 2014
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
entity resize_fifoword_tb is
end resize_fifoword_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of resize_fifoword_tb is
   constant clk0_period    : time := 100 ns;
   constant clk1_period    : time := 10 ns; 
   --signals
   signal clk0,clk1        : std_logic;
   signal reset_n          : std_logic; 
   
   constant c_IN_WORD_WIDTH   : integer := 32;
   constant c_OUT_WORD_WIDTH  : integer := 512;
   
   --inst0
   signal inst0_wrreq      : std_logic;
   signal inst0_data       : std_logic_vector(c_IN_WORD_WIDTH-1 downto 0);
   signal inst0_wrfull     : std_logic;
   signal inst0_q          : std_logic_vector(c_IN_WORD_WIDTH-1 downto 0);
   signal inst0_rdempty    : std_logic;
   
   
   --dut0
   signal dut0_in_rdreq    : std_logic;
   
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
   
   
   process(clk0, reset_n)
   begin
      if reset_n = '0' then 
         inst0_wrreq <= '0';
         inst0_data  <= (others=>'0');
      elsif (clk0'event AND clk0='1') then 
         if inst0_wrfull = '0' then 
            inst0_wrreq <= '1';
         else 
            inst0_wrreq <= '0';
         end if;
         
         if inst0_wrreq = '1' then
            inst0_data  <= std_logic_vector(unsigned(inst0_data)+1);
         else 
            inst0_data  <= inst0_data;
         end if;
      end if;
   end process;
   
   fifo_inst0 : entity work.fifo_inst
   generic map (
      dev_family     => "Cyclone IV E",
      wrwidth        => 32,
      wrusedw_witdth => 9, 
      rdwidth        => 32,
      rdusedw_width  => 9,
      show_ahead     => "OFF"
   )  
   port map(
      --input ports 
      reset_n       => reset_n,
      wrclk         => clk0,
      wrreq         => inst0_wrreq,
      data          => inst0_data,
      wrfull        => inst0_wrfull,
		wrempty		  => open,
      wrusedw       => open,
      rdclk 	     => clk1,
      rdreq         => dut0_in_rdreq,
      q             => inst0_q,
      rdempty       => inst0_rdempty,
      rdusedw       => open 
   );
   
   
   dut0_resize_fifoword : entity work.resize_fifoword
   generic map(
      g_IN_WORD_WIDTH   => c_IN_WORD_WIDTH,
      g_OUT_WORD_WIDTH  => c_OUT_WORD_WIDTH
   )
   port map(
      clk         => clk1,
      reset_n     => reset_n,
      in_rdempty  => inst0_rdempty,
      in_rdreq    => dut0_in_rdreq,
      in_data     => inst0_q,
      out_wrfull  => '0',
      out_wrreq   => open,
      out_data    => open 
   );
   
   
   
end tb_behave;

