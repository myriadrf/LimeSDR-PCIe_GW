-- ----------------------------------------------------------------------------
-- FILE:          rd_stream_buff.vhd
-- DESCRIPTION:   Buffer for FPGA->HOST stream 
-- DATE:          05:04 PM Thursday, June 27, 2019
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
entity rd_stream_buff is
   generic(
      g_DEV_FAMILY         : string := "Cyclone V GX";
      g_BUFF_WRWIDTH       : integer := 32;
      g_BUFF_WRUSEDW_WIDTH : integer := 8  
   );
   port (
      clk               : in std_logic;
      reset_n           : in std_logic;
      --DMA 
      to_dma_reader     : out t_TO_DMA_READER;
      from_dma_reader   : in  t_FROM_DMA_READER;
      --Buffer
      buff_wrclk        : in  std_logic;
      buff_aclrn        : in  std_logic;
      buff_wr           : in  std_logic;
      buff_wrdata       : in  std_logic_vector(g_BUFF_WRWIDTH-1 downto 0);
      buff_wrfull       : out std_logic;
      buff_wrusedw      : out std_logic_vector(g_BUFF_WRUSEDW_WIDTH-1 downto 0)
   );
end rd_stream_buff;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of rd_stream_buff is
--declare signals,  components here
   constant c_INST0_RDUSEDW_WIDTH : integer := FIFORD_SIZE (g_BUFF_WRWIDTH, c_DMA_DATA_WIDTH, g_BUFF_WRUSEDW_WIDTH);
   --inst0
   signal inst0_rdempty : std_logic;

begin

-- ----------------------------------------------------------------------------
-- FIFO Buffer
-- ----------------------------------------------------------------------------
   inst0_fifo_inst : entity work.fifo_inst 
   generic map(
      dev_family     => g_DEV_FAMILY,
      wrwidth        => g_BUFF_WRWIDTH,
      wrusedw_witdth => g_BUFF_WRUSEDW_WIDTH,  
      rdwidth        => c_DMA_DATA_WIDTH,
      rdusedw_width  => c_INST0_RDUSEDW_WIDTH,
      show_ahead     => "ON"
   ) 
   port map(
      --input ports 
      reset_n  => reset_n AND buff_aclrn,
      wrclk    => buff_wrclk,
      wrreq    => buff_wr,
      data     => buff_wrdata,
      wrfull   => buff_wrfull,
      wrempty  => open,
      wrusedw  => buff_wrusedw,
      rdclk    => clk,
      rdreq    => NOT inst0_rdempty AND from_dma_reader.ready,
      q        => to_dma_reader.data,
      rdempty  => inst0_rdempty,
      rdusedw  => open    
   ); 

-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------
   to_dma_reader.valid <= NOT inst0_rdempty AND from_dma_reader.ready;
   to_dma_reader.last  <= '0';
  
end arch;   


