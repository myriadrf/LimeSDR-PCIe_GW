-- ----------------------------------------------------------------------------
-- FILE:          pcie_top.vhd
-- DESCRIPTION:   Top module for PCIe connection
-- DATE:          11:11 AM Thursday, June 28, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
-- altera vhdl_input_version vhdl_2008
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FIFO_PACK.all;
use work.litepcie_pkg.all;

LIBRARY altera_mf;
USE altera_mf.all;
-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pcie_top is
   generic(
      g_DEV_FAMILY               : string := "Cyclone V GX";
      g_S0_DATA_WIDTH            : integer := 32;
      g_S1_DATA_WIDTH            : integer := 32;
      g_S2_DATA_WIDTH            : integer := 32;
      g_C0_DATA_WIDTH            : integer := 8;
      -- Stream (Host->FPGA) 
      g_H2F_S0_0_RDUSEDW_WIDTH   : integer := 11;
      g_H2F_S0_0_RWIDTH          : integer := 32;
      g_H2F_S0_1_RDUSEDW_WIDTH   : integer := 11;
      g_H2F_S0_1_RWIDTH          : integer := 32;
      g_H2F_S1_0_RDUSEDW_WIDTH   : integer := 11;
      g_H2F_S1_0_RWIDTH          : integer := 32;
      g_H2F_S1_1_RDUSEDW_WIDTH   : integer := 11;
      g_H2F_S1_1_RWIDTH          : integer := 32;
      g_H2F_S2_0_RDUSEDW_WIDTH   : integer := 11;
      g_H2F_S2_0_RWIDTH          : integer := 32;
      g_H2F_S2_1_RDUSEDW_WIDTH   : integer := 11;
      g_H2F_S2_1_RWIDTH          : integer := 32;      
      -- Stream (FPGA->Host)
      g_F2H_S0_WRUSEDW_WIDTH     : integer := 10;
      g_F2H_S0_WWIDTH            : integer := 64;
      g_F2H_S1_WRUSEDW_WIDTH     : integer := 10;
      g_F2H_S1_WWIDTH            : integer := 64;
      g_F2H_S2_WRUSEDW_WIDTH     : integer := 10;
      g_F2H_S2_WWIDTH            : integer := 64;
      -- Control (Host->FPGA)
      g_H2F_C0_RDUSEDW_WIDTH     : integer := 11;
      g_H2F_C0_RWIDTH            : integer := 8;
      -- Control (FPGA->Host)
      g_F2H_C0_WRUSEDW_WIDTH     : integer := 11;
      g_F2H_C0_WWIDTH            : integer := 8
      
   );
   port (
      clk                  : in  std_logic;   -- Internal logic clock (125Mhz)
      reset_n              : in  std_logic;
      --PCIE external pins
      pcie_perstn          : in  std_logic;
      pcie_refclk          : in  std_logic;
      pcie_rx              : in  std_logic_vector(3 downto 0);
      pcie_tx              : out std_logic_vector(3 downto 0);
      pcie_bus_clk         : out std_logic;  -- PCIe data clock output
      -- FIFO buffers
      H2F_S0_sel           : in std_logic;   -- 0 - S0_0, 1 - S0_1

      --Stream 0 endpoint FIFO 0 (Host->FPGA) 
      H2F_S0_0_rdclk       : in std_logic;
      H2F_S0_0_aclrn       : in std_logic;
      H2F_S0_0_rd          : in std_logic;
      H2F_S0_0_rdata       : out std_logic_vector(g_H2F_S0_0_RWIDTH-1 downto 0);
      H2F_S0_0_rempty      : out std_logic;
      H2F_S0_0_rdusedw     : out std_logic_vector(g_H2F_S0_0_RDUSEDW_WIDTH-1 downto 0);
      --Stream 0 endpoint FIFO 1 (Host->FPGA) 
      H2F_S0_1_rdclk       : in std_logic;
      H2F_S0_1_aclrn       : in std_logic;
      H2F_S0_1_rd          : in std_logic;
      H2F_S0_1_rdata       : out std_logic_vector(g_H2F_S0_1_RWIDTH-1 downto 0);
      H2F_S0_1_rempty      : out std_logic;
      H2F_S0_1_rdusedw     : out std_logic_vector(g_H2F_S0_1_RDUSEDW_WIDTH-1 downto 0);
      --Stream 0 endpoint FIFO (FPGA->Host)
      F2H_S0_wclk          : in std_logic;
      F2H_S0_aclrn         : in std_logic;
      F2H_S0_wr            : in std_logic;
      F2H_S0_wdata         : in std_logic_vector(g_F2H_S0_WWIDTH-1 downto 0);
      F2H_S0_wfull         : out std_logic;
      F2H_S0_wrusedw       : out std_logic_vector(g_F2H_S0_WRUSEDW_WIDTH-1 downto 0);

      --Control endpoint FIFO (Host->FPGA)
      H2F_C0_rdclk         : in std_logic;
      H2F_C0_aclrn         : in std_logic;
      H2F_C0_rd            : in std_logic;
      H2F_C0_rdata         : out std_logic_vector(g_H2F_C0_RWIDTH-1 downto 0);
      H2F_C0_rempty        : out std_logic;
      --Control endpoint FIFO (FPGA->Host)
      F2H_C0_wclk          : in std_logic;
      F2H_C0_aclrn         : in std_logic;
      F2H_C0_wr            : in std_logic;
      F2H_C0_wdata         : in std_logic_vector(g_F2H_C0_WWIDTH-1 downto 0);
      F2H_C0_wfull         : out std_logic;
      
      F2H_S0_open          : out std_logic

      
   );
end pcie_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pcie_top is
--declare signals,  components here
   -- Module constants  
   constant c_H2F_S0_0_RDUSEDW_WIDTH   : integer := g_H2F_S0_0_RDUSEDW_WIDTH; 
   constant c_H2F_S0_1_RDUSEDW_WIDTH   : integer := g_H2F_S0_1_RDUSEDW_WIDTH;
  
   constant c_H2F_S1_0_RDUSEDW_WIDTH   : integer := g_H2F_S1_0_RDUSEDW_WIDTH; 
   constant c_H2F_S1_1_RDUSEDW_WIDTH   : integer := g_H2F_S1_1_RDUSEDW_WIDTH;
  
   constant c_H2F_S2_0_RDUSEDW_WIDTH   : integer := g_H2F_S2_0_RDUSEDW_WIDTH; 
   constant c_H2F_S2_1_RDUSEDW_WIDTH   : integer := g_H2F_S2_1_RDUSEDW_WIDTH; 

   constant c_H2F_C0_RDUSEDW_WIDTH     : integer := g_H2F_C0_RDUSEDW_WIDTH; 
   
   constant c_F2H_S0_WRUSEDW_WIDTH     : integer := g_F2H_S0_WRUSEDW_WIDTH;
   constant c_F2H_S1_WRUSEDW_WIDTH     : integer := g_F2H_S1_WRUSEDW_WIDTH;
   constant c_F2H_S2_WRUSEDW_WIDTH     : integer := g_F2H_S2_WRUSEDW_WIDTH;
   
   constant c_F2H_C0_WRUSEDW_WIDTH     : integer := g_F2H_C0_WRUSEDW_WIDTH;
  
   signal H2F_S0_sel_sync              : std_logic;
   signal H2F_S1_sel_sync              : std_logic;
   signal H2F_S2_sel_sync              : std_logic;
   
   signal H2F_S0_0_sclrn               : std_logic;
   signal H2F_S0_1_sclrn               : std_logic;
	signal H2F_S1_0_sclrn               : std_logic;
   signal H2F_S1_1_sclrn               : std_logic;
   signal H2F_S2_0_sclrn               : std_logic;
   signal H2F_S2_1_sclrn               : std_logic;
 
   --inst1   
   signal inst1_to_dma_writer0         : t_TO_DMA_WRITER;
   signal inst1_from_dma_writer0       : t_FROM_DMA_WRITER;
   signal inst1_to_dma_reader0         : t_TO_DMA_READER;
   signal inst1_from_dma_reader0       : t_FROM_DMA_READER;
   
   signal inst1_to_dma_writer1         : t_TO_DMA_WRITER;
   signal inst1_from_dma_writer1       : t_FROM_DMA_WRITER;
   signal inst1_to_dma_reader1         : t_TO_DMA_READER;
   signal inst1_from_dma_reader1       : t_FROM_DMA_READER;
   
   signal inst1_to_dma_writer2         : t_TO_DMA_WRITER;
   signal inst1_from_dma_writer2       : t_FROM_DMA_WRITER;
   signal inst1_to_dma_reader2         : t_TO_DMA_READER;
   signal inst1_from_dma_reader2       : t_FROM_DMA_READER;
   
   signal inst1_cntrl_enable           : std_logic;
   signal inst1_cntrl_writer_data      : std_logic_vector(511 downto 0); 
   signal inst1_cntrl_writer_valid     : std_logic := '0';  
   signal inst1_cntrl_reader_data      : std_logic_vector(511 downto 0); 
   signal inst1_cntrl_reader_valid     : std_logic;

   signal clk125                       : std_logic;
   signal clk50                        : std_logic;
   signal pll_locked                   : std_logic;
   
--   --------------- TEMPORARY PLACEHOLDERS -- NEED TO BE DELETED ----
--   --Stream 1 endpoint FIFO 0 (Host->FPGA) 
--   signal   H2F_S1_0_rdclk       : std_logic := '0';
--   signal   H2F_S1_0_aclrn       : std_logic := '0';
--   signal   H2F_S1_0_rd          : std_logic := '0';
--   signal   H2F_S1_0_rdata       : std_logic_vector(g_H2F_S1_0_RWIDTH-1 downto 0);
--   signal   H2F_S1_0_rempty      : std_logic := '0';
--   signal   H2F_S1_0_rdusedw     : std_logic_vector(g_H2F_S1_0_RDUSEDW_WIDTH-1 downto 0);
--   --Stream 1 endpoint FIFO 1 (Host->FPGA) 
--   signal   H2F_S1_1_rdclk       :  std_logic := '0';
--   signal   H2F_S1_1_aclrn       :  std_logic := '0';
--   signal   H2F_S1_1_rd          :  std_logic := '0';
--   signal   H2F_S1_1_rdata       :  std_logic_vector(g_H2F_S1_1_RWIDTH-1 downto 0);
--   signal   H2F_S1_1_rempty      :  std_logic := '0';
--   signal   H2F_S1_1_rdusedw     :  std_logic_vector(g_H2F_S1_1_RDUSEDW_WIDTH-1 downto 0);
--   --Stream 2 endpoint FIFO 0 (Host->FPGA) 
--   signal   H2F_S2_0_rdclk       :  std_logic := '0';
--   signal   H2F_S2_0_aclrn       :  std_logic := '0';
--   signal   H2F_S2_0_rd          :  std_logic := '0';
--   signal   H2F_S2_0_rdata       :  std_logic_vector(g_H2F_S2_0_RWIDTH-1 downto 0);
--   signal   H2F_S2_0_rempty      :  std_logic := '0';
--   signal   H2F_S2_0_rdusedw     :  std_logic_vector(g_H2F_S2_0_RDUSEDW_WIDTH-1 downto 0);
--   --Stream 2 endpoint FIFO 1 (Host->FPGA) 
--   signal   H2F_S2_1_rdclk       :  std_logic := '0';
--   signal   H2F_S2_1_aclrn       :  std_logic := '0';
--   signal   H2F_S2_1_rd          :  std_logic := '0';
--   signal   H2F_S2_1_rdata       :  std_logic_vector(g_H2F_S2_1_RWIDTH-1 downto 0);
--   signal   H2F_S2_1_rempty      :  std_logic := '0';
--   signal   H2F_S2_1_rdusedw     :  std_logic_vector(g_H2F_S2_1_RDUSEDW_WIDTH-1 downto 0);  
--   --Stream 1 endpoint FIFO (FPGA->Host)
--   signal   F2H_S1_wclk          :  std_logic := '0';
--   signal   F2H_S1_aclrn         :  std_logic := '0';
--   signal   F2H_S1_wr            :  std_logic := '0';
--   signal   F2H_S1_wdata         :  std_logic_vector(g_F2H_S1_WWIDTH-1 downto 0);
--   signal   F2H_S1_wfull         :  std_logic := '0';
--   signal   F2H_S1_wrusedw       :  std_logic_vector(g_F2H_S1_WRUSEDW_WIDTH-1 downto 0);      
--   --Stream 2 endpoint FIFO (FPGA->Host)
--   signal   F2H_S2_wclk          :  std_logic := '0';
--   signal   F2H_S2_aclrn         :  std_logic := '0';
--   signal   F2H_S2_wr            :  std_logic := '0';
--   signal   F2H_S2_wdata         :  std_logic_vector(g_F2H_S2_WWIDTH-1 downto 0);
--   signal   F2H_S2_wfull         :  std_logic := '0';
--   signal   F2H_S2_wrusedw       :  std_logic_vector(g_F2H_S2_WRUSEDW_WIDTH-1 downto 0);
--   
--   signal   F2H_S1_open          :  std_logic := '0';
--   signal   F2H_S2_open          :  std_logic := '0';
--   signal   H2F_S1_sel           :  std_logic := '0';   -- 0 - S1_0, 1 - S1_1
--   signal   H2F_S2_sel           :  std_logic := '0';   -- 0 - S2_0, 1 - S2_1

   -----------------------------------------------------------------

   component pll_pcie is 
   port (
      areset   : in  std_logic;
      inclk0   : in  std_logic;
      c0       : out std_logic;
      c1       : out std_logic;
      locked   : out std_logic
   );
   end component;
   
begin
-- ----------------------------------------------------------------------------
-- Reset logic
-- ----------------------------------------------------------------------------  
   -- Reset signal with synchronous removal to clk clock domain, 
   sync_reg0 : entity work.sync_reg 
   port map(clk125, H2F_S0_0_aclrn, '1', H2F_S0_0_sclrn);
   
   sync_reg1 : entity work.sync_reg 
   port map(clk125, H2F_S0_1_aclrn, '1', H2F_S0_1_sclrn); 
   
--   sync_reg2 : entity work.sync_reg 
--   port map(clk125, H2F_S1_0_aclrn, '1', H2F_S1_0_sclrn);
--   
--   sync_reg3 : entity work.sync_reg 
--   port map(clk125, H2F_S1_1_aclrn, '1', H2F_S1_1_sclrn);
--   
--   sync_reg4 : entity work.sync_reg 
--   port map(clk125, H2F_S2_0_aclrn, '1', H2F_S2_0_sclrn);
--   
--   sync_reg5 : entity work.sync_reg 
--   port map(clk125, H2F_S2_1_aclrn, '1', H2F_S2_1_sclrn);
     
-- ----------------------------------------------------------------------------
-- Sync registers
-- ----------------------------------------------------------------------------   
   sync_reg6 : entity work.sync_reg 
   port map(clk125, reset_n, H2F_S0_sel, H2F_S0_sel_sync);
   
--   sync_reg7 : entity work.sync_reg 
--   port map(clk125, reset_n, H2F_S1_sel, H2F_S1_sel_sync);
--   
--   sync_reg8 : entity work.sync_reg 
--   port map(clk125, reset_n, H2F_S2_sel, H2F_S2_sel_sync);

   inst0_pll_pcie : pll_pcie 
   port map (
      areset   => NOT reset_n,
      inclk0   => clk,
      c0       => clk125,
      c1       => clk50,
      locked   => pll_locked
   );


   
 ----------------------------------------------------------------------------
 --Litepcie core
 ---------------------------------------------------------------------------- 
   inst1_litepcie_top : entity work.litepcie_top
   port map (
      -- Internal clock
      clk50                => clk50, 
      clk125               => clk125,
      reset_n              => pll_locked, 
      -- PCIe 
      pcie_x4_rst_n        => pcie_perstn,
      pcie_x4_refclk       => pcie_refclk,
      pcie_x4_rx           => pcie_rx,
      pcie_x4_tx           => pcie_tx,
      -- DMA endpoints
         -- dma_writer = HOST -> FPGA, dma_reader = FPGA->HOST
      to_dma_writer0       => inst1_to_dma_writer0,
      from_dma_writer0     => inst1_from_dma_writer0, 
      to_dma_reader0       => inst1_to_dma_reader0,
      from_dma_reader0     => inst1_from_dma_reader0,
--         -- dma_writer = HOST -> FPGA, dma_reader = FPGA->HOST
--      to_dma_writer1       => inst1_to_dma_writer1,
--      from_dma_writer1     => inst1_from_dma_writer1, 
--      to_dma_reader1       => inst1_to_dma_reader1,
--      from_dma_reader1     => inst1_from_dma_reader1,
--         -- dma_writer = HOST -> FPGA, dma_reader = FPGA->HOST
--      to_dma_writer2       => inst1_to_dma_writer2,
--      from_dma_writer2     => inst1_from_dma_writer2,
--      to_dma_reader2       => inst1_to_dma_reader2,
--      from_dma_reader2     => inst1_from_dma_reader2,    
      -- Control registers
         -- cntrl_writer = HOST -> FPGA, cntrl_reader = FPGA->HOST
      cntrl_enable         => inst1_cntrl_enable,      
      cntrl_writer_data    => inst1_cntrl_writer_data,
      cntrl_writer_valid   => inst1_cntrl_writer_valid,      
      cntrl_reader_data    => inst1_cntrl_reader_data,
      cntrl_reader_valid   => inst1_cntrl_reader_valid
   );
   
  
   pcie_bus_clk <= clk125;

-- ----------------------------------------------------------------------------
-- For Stream S0 endpoint, Host->FPGA
-- There are two FIFO buffers for this endpoint. Buffer is selected with H2F_S0_0_sel
-- ----------------------------------------------------------------------------
   inst2_H2F_S0_FIFO : entity work.wr_stream_buff
   generic map (
      g_DEV_FAMILY            => g_DEV_FAMILY,
      g_BUFF_0_RWIDTH         => g_H2F_S0_0_RWIDTH,
      g_BUFF_0_RDUSEDW_WIDTH  => c_H2F_S0_0_RDUSEDW_WIDTH,
      g_BUFF_1_RWIDTH         => g_H2F_S0_1_RWIDTH,
      g_BUFF_1_RDUSEDW_WIDTH  => c_H2F_S0_1_RDUSEDW_WIDTH
   )
   port map(
      clk               => clk125,
      reset_n           => inst1_from_dma_writer0.enable,
      --DMA 
      to_dma_writer     => inst1_to_dma_writer0,
      from_dma_writer   => inst1_from_dma_writer0,
      -- FIFO Buffers
      buff_sel          => H2F_S0_sel_sync,
         --Buffer 0
      buff_0_rdclk      => H2F_S0_0_rdclk,
      buff_0_aclrn      => H2F_S0_0_sclrn,
      buff_0_rd         => H2F_S0_0_rd,
      buff_0_rdata      => H2F_S0_0_rdata,
      buff_0_rempty     => H2F_S0_0_rempty,
      buff_0_rdusedw    => H2F_S0_0_rdusedw,
         --Buffer 1
      buff_1_rdclk      => H2F_S0_1_rdclk,
      buff_1_aclrn      => H2F_S0_1_sclrn,
      buff_1_rd         => H2F_S0_1_rd,
      buff_1_rdata      => H2F_S0_1_rdata,
      buff_1_rempty     => H2F_S0_1_rempty,
      buff_1_rdusedw    => H2F_S0_1_rdusedw 
   );

-- ----------------------------------------------------------------------------
-- For Stream S1 endpoint, Host->FPGA
-- There are two FIFO buffers for this endpoint. Buffer is selected with H2F_S1_0_sel
-- ----------------------------------------------------------------------------   
--   inst3_H2F_S1_FIFO : entity work.wr_stream_buff
--   generic map (
--      g_DEV_FAMILY            => g_DEV_FAMILY,
--      g_BUFF_0_RWIDTH         => g_H2F_S1_0_RWIDTH,
--      g_BUFF_0_RDUSEDW_WIDTH  => c_H2F_S1_0_RDUSEDW_WIDTH,
--      g_BUFF_1_RWIDTH         => g_H2F_S1_1_RWIDTH,
--      g_BUFF_1_RDUSEDW_WIDTH  => c_H2F_S1_1_RDUSEDW_WIDTH
--   )
--   port map(
--      clk               => clk125,
--      reset_n           => inst1_from_dma_writer1.enable,
--      --DMA 
--      to_dma_writer     => inst1_to_dma_writer1,
--      from_dma_writer   => inst1_from_dma_writer1,
--      -- FIFO Buffers
--      buff_sel          => H2F_S1_sel_sync,
--         --Buffer 0
--      buff_0_rdclk      => H2F_S1_0_rdclk,
--      buff_0_aclrn      => H2F_S1_0_sclrn,
--      buff_0_rd         => H2F_S1_0_rd,
--      buff_0_rdata      => H2F_S1_0_rdata,
--      buff_0_rempty     => H2F_S1_0_rempty,
--      buff_0_rdusedw    => H2F_S1_0_rdusedw,
--         --Buffer 1
--      buff_1_rdclk      => H2F_S1_1_rdclk,
--      buff_1_aclrn      => H2F_S1_1_sclrn,
--      buff_1_rd         => H2F_S1_1_rd,
--      buff_1_rdata      => H2F_S1_1_rdata,
--      buff_1_rempty     => H2F_S1_1_rempty,
--      buff_1_rdusedw    => H2F_S1_1_rdusedw 
--   );
--   
-- ----------------------------------------------------------------------------
-- For Stream S2 endpoint, Host->FPGA
-- There are two FIFO buffers for this endpoint. Buffer is selected with H2F_S2_0_sel
-- ----------------------------------------------------------------------------   
--   inst4_H2F_S2_FIFO : entity work.wr_stream_buff
--   generic map (
--      g_DEV_FAMILY            => g_DEV_FAMILY,
--      g_BUFF_0_RWIDTH         => g_H2F_S2_0_RWIDTH,
--      g_BUFF_0_RDUSEDW_WIDTH  => c_H2F_S2_0_RDUSEDW_WIDTH,
--      g_BUFF_1_RWIDTH         => g_H2F_S2_1_RWIDTH,
--      g_BUFF_1_RDUSEDW_WIDTH  => c_H2F_S2_1_RDUSEDW_WIDTH
--   )
--   port map(
--      clk               => clk125,
--      reset_n           => inst1_from_dma_writer2.enable,
--      --DMA 
--      to_dma_writer     => inst1_to_dma_writer2,
--      from_dma_writer   => inst1_from_dma_writer2,
--      -- FIFO Buffers
--      buff_sel          => H2F_S2_sel_sync,
--         --Buffer 0
--      buff_0_rdclk      => H2F_S2_0_rdclk,
--      buff_0_aclrn      => H2F_S2_0_sclrn,
--      buff_0_rd         => H2F_S2_0_rd,
--      buff_0_rdata      => H2F_S2_0_rdata,
--      buff_0_rempty     => H2F_S2_0_rempty,
--      buff_0_rdusedw    => H2F_S2_0_rdusedw,
--         --Buffer 1
--      buff_1_rdclk      => H2F_S2_1_rdclk,
--      buff_1_aclrn      => H2F_S2_1_sclrn,
--      buff_1_rd         => H2F_S2_1_rd,
--      buff_1_rdata      => H2F_S2_1_rdata,
--      buff_1_rempty     => H2F_S2_1_rempty,
--      buff_1_rdusedw    => H2F_S2_1_rdusedw 
--   );
   
-- ----------------------------------------------------------------------------
-- For C0 Control endpoint, Host->FPGA
-- ----------------------------------------------------------------------------
   inst5_H2F_C0_FIFO : entity work.wr_control_buff
   generic map(
      g_DEV_FAMILY         => g_DEV_FAMILY,
      g_BUFF_RWIDTH        => g_H2F_C0_RWIDTH,
      g_BUFF_RDUSEDW_WIDTH => c_H2F_C0_RDUSEDW_WIDTH     
   )
   port map(
      clk            => clk125,
      reset_n        => reset_n,
      -- Control endpoint
      cntrl_valid    => inst1_cntrl_writer_valid,
      cntrl_data     => inst1_cntrl_writer_data,
      cntrl_ready    => open,
      -- Control Buffer FIFO
      buff_rdclk     => H2F_C0_rdclk,
      buff_rd        => H2F_C0_rd,
      buff_rdata     => H2F_C0_rdata,
      buff_rempty    => H2F_C0_rempty,
      buff_rdusedw   => open
   );
   
-- ----------------------------------------------------------------------------
-- For S0 stream endpoint, FPGA->Host
-- ----------------------------------------------------------------------------
   inst6_F2H_S0_FIFO : entity work.rd_stream_buff
   generic map(
      g_DEV_FAMILY         => g_DEV_FAMILY,
      g_BUFF_WRWIDTH       => g_F2H_S0_WWIDTH,
      g_BUFF_WRUSEDW_WIDTH => c_F2H_S0_WRUSEDW_WIDTH  
   )
   port map(
      clk               => clk125,
      reset_n           => inst1_from_dma_reader0.enable,
      --DMA 
      to_dma_reader     => inst1_to_dma_reader0,
      from_dma_reader   => inst1_from_dma_reader0,
      --Buffer
      buff_wrclk        => F2H_S0_wclk,
      buff_aclrn        => '1', 
      buff_wr           => F2H_S0_wr,
      buff_wrdata       => F2H_S0_wdata,
      buff_wrfull       => F2H_S0_wfull,
      buff_wrusedw      => F2H_S0_wrusedw
   );
   
---- ----------------------------------------------------------------------------
---- For S1 stream endpoint, FPGA->Host
---- ----------------------------------------------------------------------------
--   inst7_F2H_S1_FIFO : entity work.rd_stream_buff
--   generic map(
--      g_DEV_FAMILY         => g_DEV_FAMILY,
--      g_BUFF_WRWIDTH       => g_F2H_S1_WWIDTH,
--      g_BUFF_WRUSEDW_WIDTH => c_F2H_S1_WRUSEDW_WIDTH  
--   )
--   port map(
--      clk               => clk125,
--      reset_n           => inst1_from_dma_reader1.enable,
--      --DMA 
--      to_dma_reader     => inst1_to_dma_reader1,
--      from_dma_reader   => inst1_from_dma_reader1,
--      --Buffer
--      buff_wrclk        => F2H_S1_wclk,
--      buff_aclrn        => '1', 
--      buff_wr           => F2H_S1_wr,
--      buff_wrdata       => F2H_S1_wdata,
--      buff_wrfull       => F2H_S1_wfull,
--      buff_wrusedw      => F2H_S1_wrusedw
--   );
--   
---- ----------------------------------------------------------------------------
---- For S2 stream endpoint, FPGA->Host
---- ----------------------------------------------------------------------------
--   inst7_F2H_S2_FIFO : entity work.rd_stream_buff
--   generic map(
--      g_DEV_FAMILY         => g_DEV_FAMILY,
--      g_BUFF_WRWIDTH       => g_F2H_S2_WWIDTH,
--      g_BUFF_WRUSEDW_WIDTH => c_F2H_S2_WRUSEDW_WIDTH  
--   )
--   port map(
--      clk               => clk125,
--      reset_n           => inst1_from_dma_reader2.enable,
--      --DMA 
--      to_dma_reader     => inst1_to_dma_reader2,
--      from_dma_reader   => inst1_from_dma_reader2,
--      --Buffer
--      buff_wrclk        => F2H_S2_wclk,
--      buff_aclrn        => '1', 
--      buff_wr           => F2H_S2_wr,
--      buff_wrdata       => F2H_S2_wdata,
--      buff_wrfull       => F2H_S2_wfull,
--      buff_wrusedw      => F2H_S2_wrusedw
--   );
   
-- ----------------------------------------------------------------------------
-- For C0 control endpoint, FPGA->Host
-- ----------------------------------------------------------------------------
   inst15_rd_control_buff : entity work.rd_control_buff
   generic map(
      g_DEV_FAMILY         => g_DEV_FAMILY,
      g_BUFF_WRWIDTH       => g_F2H_C0_WWIDTH,
      g_BUFF_WRUSEDW_WIDTH => c_F2H_C0_WRUSEDW_WIDTH   
   )
   port map(
      clk            => clk125,
      reset_n        => reset_n,
      -- Control endpoint
      cntrl_valid    => inst1_cntrl_reader_valid,
      cntrl_data     => inst1_cntrl_reader_data,
      cntrl_ready    => '1', 
      -- Control Buffer FIFO
      buff_wrdclk    => F2H_C0_wclk,
      buff_wr        => F2H_C0_wr,
      buff_wrdata    => F2H_C0_wdata,
      buff_wrfull    => F2H_C0_wfull,
      buff_wrdusedw  => open
   );
 
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------    
   F2H_S0_open <= inst1_from_dma_reader0.enable;
--   F2H_S1_open <= inst1_from_dma_reader1.enable;
--   F2H_S2_open <= inst1_from_dma_reader2.enable;
   
end arch;





