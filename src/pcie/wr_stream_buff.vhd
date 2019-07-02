-- ----------------------------------------------------------------------------
-- FILE:          wr_stream_buff.vhd
-- DESCRIPTION:   Buffer for HOST->FPGA stream 
-- DATE:          10:58 AM Thursday, June 27, 2019
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
entity wr_stream_buff is
   generic(
      g_DEV_FAMILY            : string := "Cyclone V GX";
      g_BUFF_0_RWIDTH         : integer := 64;
      g_BUFF_0_RDUSEDW_WIDTH  : integer := 10;
      g_BUFF_1_RWIDTH         : integer := 64;
      g_BUFF_1_RDUSEDW_WIDTH  : integer := 10
   );
   port (
      clk               : in  std_logic;
      reset_n           : in  std_logic;
      --DMA 
      to_dma_writer     : out t_TO_DMA_WRITER;
      from_dma_writer   : in  t_FROM_DMA_WRITER;
      -- FIFO Buffers
      buff_sel          : in  std_logic;
         --Buffer 0
      buff_0_rdclk      : in  std_logic;
      buff_0_aclrn      : in  std_logic;
      buff_0_rd         : in  std_logic;
      buff_0_rdata      : out std_logic_vector(g_BUFF_0_RWIDTH-1 downto 0);
      buff_0_rempty     : out std_logic;
      buff_0_rdusedw    : out std_logic_vector(g_BUFF_0_RDUSEDW_WIDTH-1 downto 0);
         --Buffer 1
      buff_1_rdclk      : in  std_logic;
      buff_1_aclrn      : in  std_logic;
      buff_1_rd         : in  std_logic;
      buff_1_rdata      : out std_logic_vector(g_BUFF_1_RWIDTH-1 downto 0);
      buff_1_rempty     : out std_logic;
      buff_1_rdusedw    : out std_logic_vector(g_BUFF_1_RDUSEDW_WIDTH-1 downto 0)
   );
end wr_stream_buff;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of wr_stream_buff is
--declare signals,  components here
   constant c_INST0_WRUSEDW_WIDTH   : integer := FIFOWR_SIZE (c_DMA_DATA_WIDTH, g_BUFF_0_RWIDTH, g_BUFF_0_RDUSEDW_WIDTH);
   
   constant c_INST2_WRUSEDW_WIDTH   : integer := FIFOWR_SIZE (c_DMA_DATA_WIDTH, g_BUFF_1_RWIDTH, g_BUFF_1_RDUSEDW_WIDTH);
   
   signal dma_writer_en_reg      : std_logic;
   
   signal reset_n_pulse          : std_logic;
   
   --inst0
   signal inst0_wrreq            : std_logic;
   signal inst0_wrfull           : std_logic;
   
   --inst1
   signal inst1_reset_n          : std_logic;
   signal inst1_pct_wr           : std_logic;
   signal inst1_pct_payload_data : std_logic_vector(c_DMA_DATA_WIDTH-1 downto 0);
   signal inst1_pct_payload_valid: std_logic;
   
   --inst2
   signal inst2_reset_n          : std_logic;
   signal inst2_wrfull           : std_logic;
   
begin
   
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         dma_writer_en_reg    <= '0';
         reset_n_pulse        <= '0';
      elsif (clk'event AND clk='1') then 
         dma_writer_en_reg <= from_dma_writer.enable;
         
         -- Reset pulse for one clk cycle after DMA is enabled
         if dma_writer_en_reg = '0' AND  from_dma_writer.enable = '1' then 
            reset_n_pulse <= '0';
         else 
            reset_n_pulse <= '1';
         end if;
         
      end if;
   end process;

-- ----------------------------------------------------------------------------
-- First FIFO, dedicated for TX stream
-- ----------------------------------------------------------------------------
   inst0_wrreq <= from_dma_writer.valid when buff_sel = '0' else '0';

   inst0_0_FIFO : entity work.two_fifo_inst 
   generic map(
      dev_family     => g_DEV_FAMILY,
      wrwidth        => c_DMA_DATA_WIDTH,
      wrusedw_witdth => c_INST0_WRUSEDW_WIDTH,  
      rdwidth        => g_BUFF_0_RWIDTH,
      rdusedw_width  => g_BUFF_0_RDUSEDW_WIDTH,
      show_ahead     => "OFF",
      TRNSF_SIZE     => 512, 
      TRNSF_N        => 8
   )
   port map(
      --input ports 
      reset_0_n   => from_dma_writer.enable AND reset_n,
      reset_1_n   => buff_0_aclrn,
      wrclk       => clk,
      wrreq       => inst0_wrreq,
      data        => from_dma_writer.data,
      wrfull      => inst0_wrfull,
      wrempty     => open,
      wrusedw     => open,
      rdclk       => buff_0_rdclk,
      rdreq       => buff_0_rd,
      q           => buff_0_rdata,
      rdempty     => buff_0_rempty,
      rdusedw     => buff_0_rdusedw   
   );
   
-- ----------------------------------------------------------------------------
-- Second FIFO, dedicated for WFM player
-- ----------------------------------------------------------------------------
   inst1_pct_wr <= from_dma_writer.valid when buff_sel = '1' else '0';
   
   -- This module takes only IQ data from packet, and discards packet header
   inst1_pct_payload_extrct : entity work.pct_payload_extrct
   generic map(
      data_w         => c_DMA_DATA_WIDTH,
      header_size    => 16, 
      pct_size       => 4096
   ) 
   port map(
      clk               => clk,
      reset_n           => reset_n_pulse,
      pct_data          => from_dma_writer.data, 
      pct_wr            => inst1_pct_wr,
      pct_payload_data  => inst1_pct_payload_data,
      pct_payload_valid => inst1_pct_payload_valid,
      pct_payload_dest  => open
   );  
   
   inst2_1_FIFO : entity work.fifo_inst 
   generic map(
      dev_family     => g_DEV_FAMILY,
      wrwidth        => c_DMA_DATA_WIDTH,
      wrusedw_witdth => c_INST2_WRUSEDW_WIDTH,  
      rdwidth        => g_BUFF_1_RWIDTH,
      rdusedw_width  => g_BUFF_1_RDUSEDW_WIDTH,
      show_ahead     => "ON"
   )
   port map(
      --input ports 
      reset_n  => reset_n_pulse,
      wrclk    => clk,
      wrreq    => inst1_pct_payload_valid,
      data     => inst1_pct_payload_data,
      wrfull   => inst2_wrfull,
      wrempty  => open,
      wrusedw  => open,
      rdclk    => buff_1_rdclk,
      rdreq    => buff_1_rd,
      q        => buff_1_rdata,
      rdempty  => buff_1_rempty,
      rdusedw  => buff_1_rdusedw   
   );
   
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------
to_dma_writer.ready <= NOT inst0_wrfull when buff_sel = '0' else NOT inst2_wrfull;

end arch;   


