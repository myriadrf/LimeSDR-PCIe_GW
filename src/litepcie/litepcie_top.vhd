-- ----------------------------------------------------------------------------
-- FILE:          litepcie_top.vhd
-- DESCRIPTION:   Top module for litepcie core
-- DATE:          09:34 AM Thursday, June 27, 2019
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

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity litepcie_top is
   port (
      -- Internal clock
      clk50                : in std_logic;
      clk125               : in std_logic;
      reset_n              : in std_logic;
      -- PCIe 
      pcie_x4_rst_n        : in  std_logic;
      pcie_x4_refclk       : in  std_logic;
      pcie_x4_rx           : in  std_logic_vector(3 downto 0);
      pcie_x4_tx           : out std_logic_vector(3 downto 0);
      -- DMA endpoints
         -- dma_writer = HOST -> FPGA, dma_reader = FPGA->HOST
      to_dma_writer0       : in  t_TO_DMA_WRITER;
      from_dma_writer0     : out t_FROM_DMA_WRITER; 
      to_dma_reader0       : in  t_TO_DMA_READER;
      from_dma_reader0     : out t_FROM_DMA_READER;
--         -- dma_writer = HOST -> FPGA, dma_reader = FPGA->HOST
--      to_dma_writer1       : in  t_TO_DMA_WRITER;
--      from_dma_writer1     : out t_FROM_DMA_WRITER; 
--      to_dma_reader1       : in  t_TO_DMA_READER;
--      from_dma_reader1     : out t_FROM_DMA_READER;
--         -- dma_writer = HOST -> FPGA, dma_reader = FPGA->HOST
--      to_dma_writer2       : in  t_TO_DMA_WRITER;
--      from_dma_writer2     : out t_FROM_DMA_WRITER; 
--      to_dma_reader2       : in  t_TO_DMA_READER;
--      from_dma_reader2     : out t_FROM_DMA_READER;     
      -- Control registers
         -- cntrl_writer = HOST -> FPGA, cntrl_reader = FPGA->HOST
      cntrl_enable         : out std_logic;      
      cntrl_writer_data    : out std_logic_vector(511 downto 0);
      cntrl_writer_valid   : out std_logic;       
      cntrl_reader_data    : in  std_logic_vector(511 downto 0);
      cntrl_reader_valid   : in  std_logic
   );
end litepcie_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of litepcie_top is
--declare signals,  components here


   -- Verilog component declaration
   component litepcie_core
   port (
      clk50                : in  std_logic;
      clk125               : in  std_logic;
      reset_n              : in  std_logic;
      pcie_x4_rst_n        : in  std_logic;
      pcie_x4_refclk       : in  std_logic;
      pcie_x4_rx           : in  std_logic_vector(3 downto 0);
      pcie_x4_tx           : out std_logic_vector(3 downto 0);
      
      dma_writer0_valid    : out std_logic;
      dma_writer0_ready    : in  std_logic;
      dma_writer0_last     : out std_logic;
      dma_writer0_data     : out std_logic_vector(63 downto 0);
      dma_writer0_enable   : out std_logic;
      
      dma_reader0_valid    : in  std_logic;
      dma_reader0_ready    : out std_logic;
      dma_reader0_last     : in  std_logic;
      dma_reader0_data     : in  std_logic_vector(63 downto 0);
      dma_reader0_enable   : out std_logic;
      
--      dma_writer1_valid    : out std_logic;
--      dma_writer1_ready    : in  std_logic;
--      dma_writer1_last     : out std_logic;
--      dma_writer1_data     : out std_logic_vector(63 downto 0);
--      dma_writer1_enable   : out std_logic;
--      
--      dma_reader1_valid    : in  std_logic;
--      dma_reader1_ready    : out std_logic;
--      dma_reader1_last     : in  std_logic;
--      dma_reader1_data     : in  std_logic_vector(63 downto 0);
--      dma_reader1_enable   : out std_logic;
--      
--      dma_writer2_valid    : out std_logic;
--      dma_writer2_ready    : in  std_logic;
--      dma_writer2_last     : out std_logic;
--      dma_writer2_data     : out std_logic_vector(63 downto 0);
--      dma_writer2_enable   : out std_logic;
--      
--      dma_reader2_valid    : in  std_logic;
--      dma_reader2_ready    : out std_logic;
--      dma_reader2_last     : in  std_logic;
--      dma_reader2_data     : in  std_logic_vector(63 downto 0);
--      dma_reader2_enable   : out std_logic;
      
      cntrl_enable         : out std_logic;      
      cntrl_writer_data    : out std_logic_vector(511 downto 0);
      cntrl_writer_valid   : out std_logic;       
      cntrl_reader_data    : in  std_logic_vector(511 downto 0);
      cntrl_reader_valid   : in  std_logic     
   );
   end component;  

  
begin

-- ----------------------------------------------------------------------------
-- litepcie instance
-- ----------------------------------------------------------------------------
   inst0_litepcie_core : litepcie_core
   port map (
      clk50                => clk50, 
      clk125               => clk125,
      reset_n              => reset_n,
      pcie_x4_rst_n        => pcie_x4_rst_n,
      pcie_x4_refclk       => pcie_x4_refclk,
      pcie_x4_rx           => pcie_x4_rx,
      pcie_x4_tx           => pcie_x4_tx,
      
      -- HOST -> FPGA
      dma_writer0_valid    => from_dma_writer0.valid,
      dma_writer0_ready    => to_dma_writer0.ready,
      dma_writer0_last     => from_dma_writer0.last,
      dma_writer0_data     => from_dma_writer0.data,
      dma_writer0_enable   => from_dma_writer0.enable,
      -- FPGA -> HOST
      dma_reader0_valid    => to_dma_reader0.valid,
      dma_reader0_ready    => from_dma_reader0.ready,
      dma_reader0_last     => to_dma_reader0.last,
      dma_reader0_data     => to_dma_reader0.data,
      dma_reader0_enable   => from_dma_reader0.enable,     
      -- HOST -> FPGA
--      dma_writer1_valid    => from_dma_writer1.valid,
--      dma_writer1_ready    => to_dma_writer1.ready,
--      dma_writer1_last     => from_dma_writer1.last,
--      dma_writer1_data     => from_dma_writer1.data,
--      dma_writer1_enable   => from_dma_writer1.enable,
--      -- FPGA -> HOST
--      dma_reader1_valid    => to_dma_reader1.valid,
--      dma_reader1_ready    => from_dma_reader1.ready,
--      dma_reader1_last     => to_dma_reader1.last,
--      dma_reader1_data     => to_dma_reader1.data,
--      dma_reader1_enable   => from_dma_reader1.enable,     
--      -- HOST -> FPGA
--      dma_writer2_valid    => from_dma_writer2.valid,
--      dma_writer2_ready    => to_dma_writer2.ready,
--      dma_writer2_last     => from_dma_writer2.last,
--      dma_writer2_data     => from_dma_writer2.data,
--      dma_writer2_enable   => from_dma_writer2.enable,
--      -- FPGA -> HOST         
--      dma_reader2_valid    => to_dma_reader2.valid,
--      dma_reader2_ready    => from_dma_reader2.ready,
--      dma_reader2_last     => to_dma_reader2.last,
--      dma_reader2_data     => to_dma_reader2.data,
--      dma_reader2_enable   => from_dma_reader2.enable,
      
      cntrl_enable         => cntrl_enable, 
      -- HOST -> FPGA
      cntrl_writer_data    => cntrl_writer_data,
      cntrl_writer_valid   => cntrl_writer_valid,
      -- FPGA -> HOST
      cntrl_reader_data    => cntrl_reader_data,
      cntrl_reader_valid   => cntrl_reader_valid
   );
   
  
end arch;   


