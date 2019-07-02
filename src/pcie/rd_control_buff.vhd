-- ----------------------------------------------------------------------------
-- FILE:          rd_control_buff.vhd
-- DESCRIPTION:   Control buffer for FPGA->HOST
-- DATE:          05:07 PM Thursday, June 27, 2019
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.litepcie_pkg.all;
use work.FIFO_PACK.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity rd_control_buff is
   generic(
      g_DEV_FAMILY         : string := "Cyclone V GX";
      g_BUFF_WRWIDTH       : integer := 32;
      g_BUFF_WRUSEDW_WIDTH : integer := 8      
   );
   port (
      clk            : in  std_logic;
      reset_n        : in  std_logic;
      -- Control endpoint
      cntrl_valid    : out std_logic;
      cntrl_data     : out std_logic_vector(c_CNTRL_DATA_WIDTH-1 downto 0);
      cntrl_ready    : in  std_logic;
      -- Control Buffer FIFO
      buff_wrdclk    : in  std_logic;
      buff_wr        : in  std_logic;
      buff_wrdata    : in  std_logic_vector(g_BUFF_WRWIDTH-1 downto 0);
      buff_wrfull    : out std_logic;
      buff_wrdusedw  : out std_logic_vector(g_BUFF_WRUSEDW_WIDTH-1 downto 0)
   );
end rd_control_buff;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of rd_control_buff is
--declare signals,  components here
constant c_INST0_RDWIDTH         : integer := 32;
constant c_INST0_RDUSEDW_WIDTH   : integer := FIFORD_SIZE (g_BUFF_WRWIDTH, c_INST0_RDWIDTH, g_BUFF_WRUSEDW_WIDTH);
   -- inst0 
   signal inst0_q          : std_logic_vector(c_INST0_RDWIDTH-1 downto 0);
   signal inst0_rdempty    : std_logic;
   
   --inst1
   signal inst1_in_rdreq   : std_logic;


  
begin

-- ----------------------------------------------------------------------------
-- FIFO buffer
-- ----------------------------------------------------------------------------
   inst0_fifo_inst : entity work.fifo_inst 
   generic map(
      dev_family     => g_DEV_FAMILY,
      wrwidth        => g_BUFF_WRWIDTH,
      wrusedw_witdth => g_BUFF_WRUSEDW_WIDTH,  
      rdwidth        => c_INST0_RDWIDTH,
      rdusedw_width  => c_INST0_RDUSEDW_WIDTH,
      show_ahead     => "OFF"
   ) 
   port map(
      --input ports 
      reset_n  => reset_n,
      wrclk    => buff_wrdclk,
      wrreq    => buff_wr,
      data     => buff_wrdata,
      wrfull   => buff_wrfull,
      wrempty  => open,
      wrusedw  => buff_wrdusedw,
      rdclk    => clk,
      rdreq    => inst1_in_rdreq,
      q        => inst0_q,
      rdempty  => inst0_rdempty,
      rdusedw  => open    
   ); 
   
   inst1_resize_fifoword : entity work.resize_fifoword
   generic map(
      g_IN_WORD_WIDTH   => c_INST0_RDWIDTH,
      g_OUT_WORD_WIDTH  => c_CNTRL_DATA_WIDTH
   )
   port map(
      clk         => clk,
      reset_n     => reset_n,
      in_rdempty  => inst0_rdempty,
      in_rdreq    => inst1_in_rdreq,
      in_data     => inst0_q,
      out_wrfull  => NOT cntrl_ready,
      out_wrreq   => cntrl_valid,
      out_data    => cntrl_data
   ); 
  
end arch;   


