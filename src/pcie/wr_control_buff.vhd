-- ----------------------------------------------------------------------------
-- FILE:          wr_control_buff.vhd
-- DESCRIPTION:   Control buffer for HOST->FPGA
-- DATE:          03:54 PM Thursday, June 27, 2019
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
entity wr_control_buff is
   generic(
      g_DEV_FAMILY         : string := "Cyclone V GX";
      g_BUFF_RWIDTH        : integer := 32;
      g_BUFF_RDUSEDW_WIDTH : integer := 8      
   );
   port (
      clk            : in std_logic;
      reset_n        : in std_logic;
      -- Control endpoint
      cntrl_valid    : in  std_logic;
      cntrl_data     : in  std_logic_vector(c_CNTRL_DATA_WIDTH-1 downto 0);
      cntrl_ready    : out std_logic;
      -- Control Buffer FIFO
      buff_rdclk     : in  std_logic;
      buff_rd        : in  std_logic;
      buff_rdata     : out std_logic_vector(g_BUFF_RWIDTH-1 downto 0);
      buff_rempty    : out std_logic;
      buff_rdusedw   : out std_logic_vector(g_BUFF_RDUSEDW_WIDTH-1 downto 0)
   );
end wr_control_buff;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of wr_control_buff is
--declare signals,  components here
constant c_INST1_WRUSEDW_WITDTH   : integer := FIFOWR_SIZE (g_BUFF_RWIDTH, g_BUFF_RWIDTH, g_BUFF_RDUSEDW_WIDTH);


   --inst0 
   signal inst0_valid      : std_logic;
   signal inst0_q          : std_logic_vector(g_BUFF_RWIDTH-1 downto 0);
   --inst1 
   signal  inst1_wrfull    : std_logic;


  
begin

-- ----------------------------------------------------------------------------
-- Shift register 
-- ----------------------------------------------------------------------------
   inst0_shift_reg : entity work.shift_reg
   generic map(
      g_IN_WIDTH   => c_CNTRL_DATA_WIDTH,
      g_OUT_WIDTH  => g_BUFF_RWIDTH
   )
   port map(
      clk      => clk,
      reset_n  => reset_n,
      ld       => cntrl_valid,
      d        => cntrl_data,
      ready    => not inst1_wrfull,
      valid    => inst0_valid,
      q        => inst0_q
   );
   
-- ----------------------------------------------------------------------------
-- FIFO BUFFER
-- ----------------------------------------------------------------------------   
   inst1_fifo_inst : entity work.fifo_inst 
   generic map(
      dev_family     => g_DEV_FAMILY,
      wrwidth        => g_BUFF_RWIDTH,
      wrusedw_witdth => c_INST1_WRUSEDW_WITDTH,  
      rdwidth        => g_BUFF_RWIDTH,
      rdusedw_width  => g_BUFF_RDUSEDW_WIDTH,
      show_ahead     => "OFF"
   )
   port map(
      --input ports 
      reset_n  => reset_n,
      wrclk    => clk,
      wrreq    => inst0_valid,
      data     => inst0_q,
      wrfull   => inst1_wrfull,
      wrempty  => open,
      wrusedw  => open,
      rdclk    => buff_rdclk,
      rdreq    => buff_rd,
      q        => buff_rdata,
      rdempty  => buff_rempty,
      rdusedw  => buff_rdusedw     
   );  
   
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------    
   cntrl_ready <= not inst1_wrfull;
  
end arch;   


