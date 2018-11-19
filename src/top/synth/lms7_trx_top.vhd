-- ----------------------------------------------------------------------------
-- FILE:          lms7_trx_top.vhd
-- DESCRIPTION:   Top level file for LimeSDR-PCIe board
-- DATE:          10:06 AM Friday, May 11, 2018
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
use work.fpgacfg_pkg.all;
use work.pllcfg_pkg.all;
use work.tstcfg_pkg.all;
use work.periphcfg_pkg.all;
use work.FIFO_PACK.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity lms7_trx_top is
   generic(
      -- General parameters
      g_DEV_FAMILY            : string := "Cyclone IV GX";
      -- LMS7002 related 
      g_LMS_DIQ_WIDTH         : integer := 12;
      -- Host related
      g_HOST2FPGA_S0_0_SIZE   : integer := 4096;   -- Stream, Host->FPGA, TX FIFO size in bytes, 
      g_HOST2FPGA_S0_1_SIZE   : integer := 4096;   -- Stream, Host->FPGA, WFM FIFO size in bytes
      g_FPGA2HOST_S0_0_SIZE   : integer := 8192;   -- Stream, FPGA->Host, FIFO size in bytes
      g_HOST2FPGA_C0_0_SIZE   : integer := 1024;   -- Control, Host->FPGA, FIFO size in bytes
      g_FPGA2HOST_C0_0_SIZE   : integer := 1024;   -- Control, FPGA->Host, FIFO size in bytes
      -- TX interface 
      g_TX_N_BUFF             : integer := 2;      -- N 4KB buffers in TX interface (2 OR 4)
      g_TX_PCT_SIZE           : integer := 4096;   -- TX packet size in bytes
      g_TX_IN_PCT_HDR_SIZE    : integer := 16;
      g_WFM_INFIFO_SIZE       : integer := 4096;   -- WFM in FIFO buffer size in bytes 
      -- Internal configuration memory 
      g_FPGACFG_START_ADDR    : integer := 0;
      g_PLLCFG_START_ADDR     : integer := 32;
      g_TSTCFG_START_ADDR     : integer := 96;
      g_PERIPHCFG_START_ADDR  : integer := 192;
      -- External periphery
      g_GPIO_N                : integer := 16
   );
   port (
      -- ----------------------------------------------------------------------------
      -- External GND pin for reset
      EXT_GND           : in     std_logic;
      -- ----------------------------------------------------------------------------
      -- Clock sources
         -- Reference clock, coming from LMK clock buffer.
      LMK_CLK           : in     std_logic;
         -- On-board oscillators
      CLK50_FPGA        : in     std_logic;
      CLK100_FPGA       : in     std_logic;
      CLK125_FPGA       : in     std_logic;
         -- Clock generator si5351c
      SI_CLK0           : in     std_logic;
      SI_CLK1           : in     std_logic;
      SI_CLK2           : in     std_logic;
      SI_CLK3           : in     std_logic;
      SI_CLK5           : in     std_logic;
      SI_CLK6           : in     std_logic;
      SI_CLK7           : in     std_logic;
      -- ----------------------------------------------------------------------------
      -- LMS7002 Digital
         -- PORT1
      LMS_MCLK1         : in     std_logic;
      LMS_FCLK1         : out    std_logic;
      LMS_TXNRX1        : out    std_logic;
      LMS_DIQ1_IQSEL    : out    std_logic;
      LMS_DIQ1_D        : out    std_logic_vector(g_LMS_DIQ_WIDTH-1 downto 0);
         -- PORT2
      LMS_MCLK2         : in     std_logic;
      LMS_FCLK2         : out    std_logic;
      LMS_TXNRX2        : out    std_logic;
      LMS_DIQ2_IQSEL2   : in     std_logic;
      LMS_DIQ2_D        : in     std_logic_vector(g_LMS_DIQ_WIDTH-1 downto 0);
         --MISC
      LMS_RESET         : out    std_logic := '1';
      LMS_TXEN          : out    std_logic;
      LMS_RXEN          : out    std_logic;
      LMS_CORE_LDO_EN   : out    std_logic;
      -- ----------------------------------------------------------------------------
      -- PCIe
         -- Clock source
      PCIE_REFCLK       : in     std_logic;
         -- Control, flags
      PCIE_PERSTN       : in     std_logic;
         -- DATA
      PCIE_HSO          : in     std_logic_vector(3 downto 0);
      PCIE_HSI_IC       : out    std_logic_vector(3 downto 0);
      -- ----------------------------------------------------------------------------
      -- External memory (ddr2)
         -- DDR2_1
      DDR2_1_CLK        : inout  std_logic_vector(0 to 0);
      DDR2_1_CLK_N      : inout  std_logic_vector(0 to 0);
      DDR2_1_DQ         : inout  std_logic_vector(15 downto 0);
      DDR2_1_DQS        : inout  std_logic_vector(1 downto 0);
      DDR2_1_RAS_N      : out    std_logic;
      DDR2_1_CAS_N      : out    std_logic;
      DDR2_1_WE_N       : out    std_logic;
      DDR2_1_ADDR       : out    std_logic_vector(12 downto 0);
      DDR2_1_BA         : out    std_logic_vector(2 downto 0);
      DDR2_1_CKE        : out    std_logic_vector(0 to 0);
      DDR2_1_CS_N       : out    std_logic_vector(0 to 0);
      DDR2_1_DM         : out    std_logic_vector(1 downto 0);
      DDR2_1_ODT        : out    std_logic_vector(0 to 0);
         -- DDR2_2
      DDR2_2_CLK        : inout  std_logic_vector(0 to 0);
      DDR2_2_CLK_N      : inout  std_logic_vector(0 to 0);
      DDR2_2_DQ         : inout  std_logic_vector(15 downto 0);
      DDR2_2_DQS        : inout  std_logic_vector(1 downto 0); 
      DDR2_2_RAS_N      : out    std_logic;
      DDR2_2_CAS_N      : out    std_logic;
      DDR2_2_WE_N       : out    std_logic;
      DDR2_2_ADDR       : out    std_logic_vector(12 downto 0);
      DDR2_2_BA         : out    std_logic_vector(2 downto 0);
      DDR2_2_CKE        : out    std_logic_vector(0 to 0);
      DDR2_2_CS_N       : out    std_logic_vector(0 to 0);
      DDR2_2_DM         : out    std_logic_vector(1 downto 0);
      DDR2_2_ODT        : out    std_logic_vector(0 to 0);         
      -- ----------------------------------------------------------------------------
      -- External communication interfaces
         -- FPGA_SPI0
      FPGA_SPI0_SCLK    : out    std_logic;
      FPGA_SPI0_MOSI    : out    std_logic;
      FPGA_SPI0_MISO    : in     std_logic;      
      FPGA_SPI0_LMS_SS  : out    std_logic;
         -- FPGA_SPI1
      FPGA_SPI1_SCLK    : out    std_logic;
      FPGA_SPI1_MOSI    : out    std_logic;
      FPGA_SPI1_DAC_SS  : out    std_logic;
      FPGA_SPI1_ADF_SS  : out    std_logic;
         -- FPGA AS
      FPGA_AS_DCLK      : out    std_logic;
      FPGA_AS_ASDO      : out    std_logic;
      FPGA_AS_DATA0     : in     std_logic;
      FPGA_AS_NCSO      : out    std_logic;
         -- FPGA I2C
      FPGA_I2C_SCL      : inout  std_logic;
      FPGA_I2C_SDA      : inout  std_logic;
      -- ----------------------------------------------------------------------------
      -- General periphery
         -- Switch
      FPGA_SW           : in     std_logic_vector(3 downto 0);
         -- LEDs          
      FPGA_LED1_R       : out    std_logic;
      FPGA_LED1_G       : out    std_logic;
      FPGA_LED2_G       : out    std_logic;
      FPGA_LED2_R       : out    std_logic;
      FPGA_LED3         : out    std_logic;
      FPGA_LED4         : out    std_logic;
      FPGA_LED5         : out    std_logic;
      FPGA_LED6         : out    std_logic;
         -- GPIO 
      FPGA_GPIO         : inout  std_logic_vector(g_GPIO_N-1 downto 0);
         -- ADF lock status
      ADF_MUXOUT        : in     std_logic;
         -- Temperature sensor
      LM75_OS           : in     std_logic;
         -- Fan control 
      FAN_CTRL          : out    std_logic;
         -- RF loop back control 
      TX2_2_LB_L        : out    std_logic;
      TX2_2_LB_H        : out    std_logic;
      TX2_2_LB_SH       : out    std_logic;
      TX1_2_LB_L        : out    std_logic;
      TX1_2_LB_H        : out    std_logic;
      TX1_2_LB_SH       : out    std_logic;   
         -- Bill Of material and hardware version 
      BOM_VER           : in     std_logic_vector(3 downto 0);
      HW_VER            : in     std_logic_vector(3 downto 0)

   );
end lms7_trx_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of lms7_trx_top is
--declare signals,  components here

constant c_S0_DATA_WIDTH         : integer := 32;     -- Stream data width
constant c_C0_DATA_WIDTH         : integer := 8;      -- Control data width
constant c_H2F_S0_0_RWIDTH       : integer := 128;    -- Host->FPGA stream, FIFO rd width, FIFO number - 0
constant c_H2F_S0_1_RWIDTH       : integer := 32;     -- Host->FPGA stream, FIFO rd width, FIFO number - 1 
constant c_F2H_S0_WWIDTH         : integer := 64;     -- FPGA->Host stream, FIFO wr width
constant c_H2F_C0_RWIDTH         : integer := 8;      -- Host->FPGA control, rd width
constant c_F2H_C0_WWIDTH         : integer := 8;      -- FPGA->Host control, wr width 

signal reset_n                   : std_logic;
signal reset_n_lmk_clk           : std_logic;
signal reset_n_clk50_fpga        : std_logic; 
signal reset_n_clk100_fpga       : std_logic;
signal reset_n_si_clk0           : std_logic;

--inst0 (NIOS CPU instance)
signal inst0_exfifo_if_rd        : std_logic;
signal inst0_exfifo_of_d         : std_logic_vector(c_C0_DATA_WIDTH-1 downto 0);
signal inst0_exfifo_of_wr        : std_logic;
signal inst0_exfifo_of_rst       : std_logic;
signal inst0_gpo                 : std_logic_vector(7 downto 0);
signal inst0_lms_ctr_gpio        : std_logic_vector(3 downto 0);
signal inst0_spi_0_MISO          : std_logic;
signal inst0_spi_0_MOSI          : std_logic;
signal inst0_spi_0_SCLK          : std_logic;
signal inst0_spi_0_SS_n          : std_logic_vector(4 downto 0);
signal inst0_spi_1_MOSI          : std_logic;
signal inst0_spi_1_SCLK          : std_logic;
signal inst0_spi_1_SS_n          : std_logic_vector(1 downto 0);
signal inst0_spi_2_MISO          : std_logic;
signal inst0_spi_2_MOSI          : std_logic;
signal inst0_spi_2_SCLK          : std_logic;
signal inst0_spi_2_SS_n          : std_logic;
signal inst0_from_fpgacfg        : t_FROM_FPGACFG;
signal inst0_from_fpgacfg_mod    : t_FROM_FPGACFG;
signal inst0_to_fpgacfg          : t_TO_FPGACFG;
signal inst0_from_pllcfg         : t_FROM_PLLCFG;
signal inst0_to_pllcfg           : t_TO_PLLCFG;
signal inst0_from_tstcfg         : t_FROM_TSTCFG;
signal inst0_to_tstcfg           : t_TO_TSTCFG;
signal inst0_from_periphcfg      : t_FROM_PERIPHCFG;
signal inst0_to_periphcfg        : t_TO_PERIPHCFG;

--inst1 (pll_top instance)
signal inst1_txpll_c1            : std_logic;
signal inst1_txpll_locked        : std_logic;
signal inst1_txpll_smpl_cmp_en   : std_logic;
signal inst1_txpll_smpl_cmp_cnt  : std_logic_vector(15 downto 0);
signal inst1_rxpll_c1            : std_logic;
signal inst1_rxpll_locked        : std_logic;
signal inst1_rxpll_smpl_cmp_en   : std_logic;
signal inst1_rxpll_smpl_cmp_cnt  : std_logic_vector(15 downto 0);

--inst2
constant c_H2F_S0_0_RDUSEDW_WIDTH: integer := FIFO_WORDS_TO_Nbits(g_HOST2FPGA_S0_0_SIZE/(c_H2F_S0_0_RWIDTH/8),true);
constant c_H2F_S0_1_RDUSEDW_WIDTH: integer := FIFO_WORDS_TO_Nbits(g_HOST2FPGA_S0_1_SIZE/(c_H2F_S0_1_RWIDTH/8),true);
constant c_F2H_S0_WRUSEDW_WIDTH  : integer := FIFO_WORDS_TO_Nbits(g_FPGA2HOST_S0_0_SIZE/(c_F2H_S0_WWIDTH/8),true);
constant c_H2F_C0_RDUSEDW_WIDTH  : integer := FIFO_WORDS_TO_Nbits(g_HOST2FPGA_C0_0_SIZE/(c_H2F_C0_RWIDTH/8),true);
constant c_F2H_C0_WRUSEDW_WIDTH  : integer := FIFO_WORDS_TO_Nbits(g_FPGA2HOST_C0_0_SIZE/(c_F2H_C0_WWIDTH/8),true);
signal inst2_F2H_S0_wfull        : std_logic;
signal inst2_F2H_S0_wrusedw      : std_logic_vector(c_F2H_S0_WRUSEDW_WIDTH-1 downto 0);
signal inst2_H2F_C0_rdata        : std_logic_vector(c_H2F_C0_RWIDTH-1 downto 0);
signal inst2_H2F_C0_rempty       : std_logic;
signal inst2_F2H_C0_wfull        : std_logic;
signal inst2_H2F_S0_0_rdata      : std_logic_vector(c_H2F_S0_0_RWIDTH-1 downto 0);
signal inst2_H2F_S0_0_rempty     : std_logic;
signal inst2_H2F_S0_0_rdusedw    : std_logic_vector(c_H2F_S0_0_RDUSEDW_WIDTH-1 downto 0);
signal inst2_H2F_S0_1_rdata      : std_logic_vector(c_H2F_S0_1_RWIDTH-1 downto 0);
signal inst2_H2F_S0_1_rempty     : std_logic;
signal inst2_H2F_S0_1_rdusedw    : std_logic_vector(c_H2F_S0_1_RDUSEDW_WIDTH-1 downto 0);
signal inst2_user_read_32_open   : std_logic;
signal inst2_user_write_32_open  : std_logic;


--inst5
signal inst5_busy : std_logic;

--inst6
constant c_WFM_INFIFO_SIZE          : integer := FIFO_WORDS_TO_Nbits(g_WFM_INFIFO_SIZE/(c_S0_DATA_WIDTH/8),true);
signal inst6_tx_pct_loss_flg        : std_logic;
signal inst6_tx_txant_en            : std_logic;
signal inst6_tx_in_pct_full         : std_logic;
signal inst6_rx_pct_fifo_wrreq      : std_logic;
signal inst6_rx_pct_fifo_wdata      : std_logic_vector(63 downto 0);
signal inst6_rx_smpl_cmp_done       : std_logic;
signal inst6_rx_smpl_cmp_err        : std_logic;
signal inst6_to_tstcfg_from_rxtx    : t_TO_TSTCFG_FROM_RXTX;
signal inst6_rx_pct_fifo_aclrn_req  : std_logic;
signal inst6_tx_in_pct_rdreq        : std_logic;
signal inst6_tx_in_pct_reset_n_req  : std_logic;
signal inst6_wfm_in_pct_reset_n_req : std_logic;
signal inst6_wfm_in_pct_rdreq       : std_logic;
signal inst6_wfm_phy_clk            : std_logic;




begin
   
-- ----------------------------------------------------------------------------
-- Reset logic
-- ----------------------------------------------------------------------------  
   -- Reset from FPGA pin. 
   reset_n <= not EXT_GND;
   
   -- Reset signal with synchronous removal to CLK100_FPGA clock domain, 
   sync_reg0 : entity work.sync_reg 
   port map(CLK100_FPGA, reset_n, '1', reset_n_clk100_fpga);
   
   -- Reset signal with synchronous removal to SI_CLK0 clock domain, 
   sync_reg1 : entity work.sync_reg 
   port map(SI_CLK0, reset_n, '1', reset_n_si_clk0);
   
      -- Reset signal with synchronous removal to SI_CLK0 clock domain, 
   sync_reg2 : entity work.sync_reg 
   port map(CLK50_FPGA, reset_n, '1', reset_n_clk50_fpga);
   
      -- Reset signal with synchronous removal to LMK_CLK clock domain, 
   sync_reg3 : entity work.sync_reg 
   port map(LMK_CLK, reset_n, '1', reset_n_lmk_clk); 
   
     
-- ----------------------------------------------------------------------------
-- NIOS CPU instance.
-- CPU is responsible for communication interfaces and control logic
-- ----------------------------------------------------------------------------   
   inst0_nios_cpu : entity work.nios_cpu
   generic map (
      FPGACFG_START_ADDR   => g_FPGACFG_START_ADDR,
      PLLCFG_START_ADDR    => g_PLLCFG_START_ADDR,
      TSTCFG_START_ADDR    => g_TSTCFG_START_ADDR,
      PERIPHCFG_START_ADDR => g_PERIPHCFG_START_ADDR
   )
   port map(
      clk                        => CLK100_FPGA,
      reset_n                    => reset_n_clk100_fpga,
      -- Control data FIFO
      exfifo_if_d                => inst2_H2F_C0_rdata,
      exfifo_if_rd               => inst0_exfifo_if_rd, 
      exfifo_if_rdempty          => inst2_H2F_C0_rempty,
      exfifo_of_d                => inst0_exfifo_of_d, 
      exfifo_of_wr               => inst0_exfifo_of_wr, 
      exfifo_of_wrfull           => inst2_F2H_C0_wfull,
      exfifo_of_rst              => inst0_exfifo_of_rst, 
      -- SPI 0 
      spi_0_MISO                 => FPGA_SPI0_MISO,
      spi_0_MOSI                 => inst0_spi_0_MOSI,
      spi_0_SCLK                 => inst0_spi_0_SCLK,
      spi_0_SS_n                 => inst0_spi_0_SS_n,
      -- SPI 1
      spi_1_MISO                 => '0',
      spi_1_MOSI                 => inst0_spi_1_MOSI,
      spi_1_SCLK                 => inst0_spi_1_SCLK,
      spi_1_SS_n                 => inst0_spi_1_SS_n,
      -- SPI 1
      spi_2_MISO                 => FPGA_AS_DATA0,
      spi_2_MOSI                 => inst0_spi_2_MOSI,
      spi_2_SCLK                 => inst0_spi_2_SCLK,
      spi_2_SS_n                 => inst0_spi_2_SS_n,
      -- I2C
      i2c_scl                    => FPGA_I2C_SCL,
      i2c_sda                    => FPGA_I2C_SDA,
      -- Genral purpose I/O
      gpi                        => "0000" & FPGA_SW,
      gpo                        => inst0_gpo, 
      -- LMS7002 control 
      lms_ctr_gpio               => inst0_lms_ctr_gpio,
      -- Configuration registers
      from_fpgacfg               => inst0_from_fpgacfg,
      to_fpgacfg                 => inst0_to_fpgacfg,
      from_pllcfg                => inst0_from_pllcfg,
      to_pllcfg                  => inst0_to_pllcfg,
      from_tstcfg                => inst0_from_tstcfg,
      to_tstcfg                  => inst0_to_tstcfg,
      to_tstcfg_from_rxtx        => inst6_to_tstcfg_from_rxtx,
      from_periphcfg             => inst0_from_periphcfg,
      to_periphcfg               => inst0_to_periphcfg
   );
   
   inst0_to_fpgacfg.HW_VER    <= HW_VER;
   inst0_to_fpgacfg.BOM_VER   <= BOM_VER; 
   inst0_to_fpgacfg.PWR_SRC   <= '0';
   
-- ----------------------------------------------------------------------------
-- pll_top instance.
-- Clock source for LMS7002 RX and TX logic
-- ----------------------------------------------------------------------------   
   inst1_pll_top : entity work.pll_top
   generic map(
      N_PLL                         => 2,
      -- TX pll parameters          
      TXPLL_BANDWIDTH_TYPE          => "AUTO",
      TXPLL_CLK0_DIVIDE_BY          => 1,
      TXPLL_CLK0_DUTY_CYCLE         => 50,
      TXPLL_CLK0_MULTIPLY_BY        => 1,
      TXPLL_CLK0_PHASE_SHIFT        => "0",
      TXPLL_CLK1_DIVIDE_BY          => 1,
      TXPLL_CLK1_DUTY_CYCLE         => 50,
      TXPLL_CLK1_MULTIPLY_BY        => 1,
      TXPLL_CLK1_PHASE_SHIFT        => "0",
      TXPLL_COMPENSATE_CLOCK        => "CLK1",
      TXPLL_INCLK0_INPUT_FREQUENCY  => 6250,
      TXPLL_INTENDED_DEVICE_FAMILY  => "Cyclone IV E",
      TXPLL_OPERATION_MODE          => "SOURCE_SYNCHRONOUS",
      TXPLL_SCAN_CHAIN_MIF_FILE     => "ip/txpll/pll.mif",
      TXPLL_DRCT_C0_NDLY            => 1,
      TXPLL_DRCT_C1_NDLY            => 2,
      -- RX pll parameters         
      RXPLL_BANDWIDTH_TYPE          => "AUTO",
      RXPLL_CLK0_DIVIDE_BY          => 1,
      RXPLL_CLK0_DUTY_CYCLE         => 50,
      RXPLL_CLK0_MULTIPLY_BY        => 1,
      RXPLL_CLK0_PHASE_SHIFT        => "0",
      RXPLL_CLK1_DIVIDE_BY          => 1,
      RXPLL_CLK1_DUTY_CYCLE         => 50,
      RXPLL_CLK1_MULTIPLY_BY        => 1,
      RXPLL_CLK1_PHASE_SHIFT        => "0",
      RXPLL_COMPENSATE_CLOCK        => "CLK1",
      RXPLL_INCLK0_INPUT_FREQUENCY  => 6250,
      RXPLL_INTENDED_DEVICE_FAMILY  => "Cyclone IV E",
      RXPLL_OPERATION_MODE          => "SOURCE_SYNCHRONOUS",
      RXPLL_SCAN_CHAIN_MIF_FILE     => "ip/pll/pll.mif",
      RXPLL_DRCT_C0_NDLY            => 1,
      RXPLL_DRCT_C1_NDLY            => 2
   )
   port map(
      -- TX PLL ports
      txpll_inclk          => LMS_MCLK1,
      txpll_reconfig_clk   => LMK_CLK,
      txpll_logic_reset_n  => reset_n,
      txpll_clk_ena        => inst0_from_fpgacfg.CLK_ENA(1 downto 0),
      txpll_drct_clk_en    => inst0_from_fpgacfg.drct_clk_en(0) & inst0_from_fpgacfg.drct_clk_en(0),
      txpll_c0             => LMS_FCLK1,
      txpll_c1             => inst1_txpll_c1,
      txpll_locked         => inst1_txpll_locked,
      txpll_smpl_cmp_en    => inst1_txpll_smpl_cmp_en,
      txpll_smpl_cmp_done  => inst6_rx_smpl_cmp_done,
      txpll_smpl_cmp_error => inst6_rx_smpl_cmp_err,
      txpll_smpl_cmp_cnt   => inst1_txpll_smpl_cmp_cnt,

      -- RX pll ports
      rxpll_inclk          => LMS_MCLK2,
      rxpll_reconfig_clk   => LMK_CLK,
      rxpll_logic_reset_n  => reset_n,
      rxpll_clk_ena        => inst0_from_fpgacfg.CLK_ENA(3 downto 2),
      rxpll_drct_clk_en    => inst0_from_fpgacfg.drct_clk_en(1) & inst0_from_fpgacfg.drct_clk_en(1),
      rxpll_c0             => LMS_FCLK2,
      rxpll_c1             => inst1_rxpll_c1,
      rxpll_locked         => inst1_rxpll_locked,
      rxpll_smpl_cmp_en    => inst1_rxpll_smpl_cmp_en,      
      rxpll_smpl_cmp_done  => inst6_rx_smpl_cmp_done,
      rxpll_smpl_cmp_error => inst6_rx_smpl_cmp_err,
      rxpll_smpl_cmp_cnt   => inst1_rxpll_smpl_cmp_cnt,       
      -- pllcfg ports
      from_pllcfg          => inst0_from_pllcfg,
      to_pllcfg            => inst0_to_pllcfg
   );
      
-- ----------------------------------------------------------------------------
-- pcie_top instance.
-- PCIe interface 
-- ----------------------------------------------------------------------------
   inst2_pcie_top : entity work.pcie_top
   generic map(
      g_DEV_FAMILY               => g_DEV_FAMILY,
      g_S0_DATA_WIDTH            => c_S0_DATA_WIDTH,
      g_C0_DATA_WIDTH            => c_C0_DATA_WIDTH,
      -- Stream (Host->FPGA) 
      g_H2F_S0_0_RDUSEDW_WIDTH   => c_H2F_S0_0_RDUSEDW_WIDTH,
      g_H2F_S0_0_RWIDTH          => c_H2F_S0_0_RWIDTH,
      g_H2F_S0_1_RDUSEDW_WIDTH   => c_H2F_S0_1_RDUSEDW_WIDTH,
      g_H2F_S0_1_RWIDTH          => c_H2F_S0_1_RWIDTH,
      -- Stream (FPGA->Host)
      g_F2H_S0_WRUSEDW_WIDTH     => c_F2H_S0_WRUSEDW_WIDTH,
      g_F2H_S0_WWIDTH            => c_F2H_S0_WWIDTH,
      -- Control (Host->FPGA)
      g_H2F_C0_RDUSEDW_WIDTH     => c_H2F_C0_RDUSEDW_WIDTH,
      g_H2F_C0_RWIDTH            => c_H2F_C0_RWIDTH,
      -- Control (FPGA->Host)
      g_F2H_C0_WRUSEDW_WIDTH     => c_F2H_C0_WRUSEDW_WIDTH,
      g_F2H_C0_WWIDTH            => c_F2H_C0_WWIDTH 
   )
   port map(
      inclk_125            => CLK125_FPGA,    -- Input clock for PLL
      reset_n              => reset_n,
      -- PCIe interface
      pcie_perstn          => PCIE_PERSTN, 
      pcie_refclk          => PCIE_REFCLK, 
      pcie_rx              => PCIE_HSO,
      pcie_tx              => PCIE_HSI_IC,
      pcie_bus_clk         => open,  -- PCIe data clock output
      
      H2F_S0_0_sel         => inst0_from_fpgacfg.wfm_load,
      --Stream endpoint FIFO (Host->FPGA) 
      H2F_S0_0_rdclk       => inst1_txpll_c1,
      H2F_S0_0_aclrn       => inst6_tx_in_pct_reset_n_req,
      H2F_S0_0_rd          => inst6_tx_in_pct_rdreq,
      H2F_S0_0_rdata       => inst2_H2F_S0_0_rdata,
      H2F_S0_0_rempty      => inst2_H2F_S0_0_rempty,
      H2F_S0_0_rdusedw     => inst2_H2F_S0_0_rdusedw,
     
      H2F_S0_1_rdclk       => inst1_txpll_c1,
      H2F_S0_1_aclrn       => inst0_from_fpgacfg.wfm_load,
      H2F_S0_1_rd          => inst6_wfm_in_pct_rdreq,
      H2F_S0_1_rdata       => inst2_H2F_S0_1_rdata,
      H2F_S0_1_rempty      => inst2_H2F_S0_1_rempty,
      H2F_S0_1_rdusedw     => inst2_H2F_S0_1_rdusedw,      
      --Stream endpoint FIFO (FPGA->Host)
      F2H_S0_wclk          => inst1_rxpll_c1,
      F2H_S0_aclrn         => inst6_rx_pct_fifo_aclrn_req,
      F2H_S0_wr            => inst6_rx_pct_fifo_wrreq,
      F2H_S0_wdata         => inst6_rx_pct_fifo_wdata,
      F2H_S0_wfull         => inst2_F2H_S0_wfull,
      F2H_S0_wrusedw       => inst2_F2H_S0_wrusedw,
      --Control endpoint FIFO (Host->FPGA)
      H2F_C0_rdclk         => CLK100_FPGA,
      H2F_C0_aclrn         => reset_n,
      H2F_C0_rd            => inst0_exfifo_if_rd,
      H2F_C0_rdata         => inst2_H2F_C0_rdata,
      H2F_C0_rempty        => inst2_H2F_C0_rempty,
      --Control endpoint FIFO (FPGA->Host)
      F2H_C0_wclk          => CLK100_FPGA,
      F2H_C0_aclrn         => not inst0_exfifo_of_rst,
      F2H_C0_wr            => inst0_exfifo_of_wr,
      F2H_C0_wdata         => inst0_exfifo_of_d,
      F2H_C0_wfull         => inst2_F2H_C0_wfull,
      stream_rx_en         => inst0_from_fpgacfg.rx_en,
      user_read_32_open    => inst2_user_read_32_open,
      user_write_32_open   => inst2_user_write_32_open
      );
      
-- ----------------------------------------------------------------------------
-- tst_top instance.
-- Clock and External DDR2 memroy test logic
-- ----------------------------------------------------------------------------
   inst3_tst_top : entity work.tst_top
   port map(
      --input ports 
      FX3_clk           => CLK100_FPGA,
      reset_n           => reset_n_clk100_fpga,    
      Si5351C_clk_0     => SI_CLK0,
      Si5351C_clk_1     => SI_CLK1,
      Si5351C_clk_2     => SI_CLK2,
      Si5351C_clk_3     => SI_CLK3,
      Si5351C_clk_5     => SI_CLK5,
      Si5351C_clk_6     => SI_CLK6,
      Si5351C_clk_7     => SI_CLK7,
      LMK_CLK           => LMK_CLK,
      ADF_MUXOUT        => ADF_MUXOUT,    
      --DDR2 external memory signals
      mem_pllref_clk    => SI_CLK1,
      mem_odt           => DDR2_2_ODT,
      mem_cs_n          => DDR2_2_CS_N,
      mem_cke           => DDR2_2_CKE,
      mem_addr          => DDR2_2_ADDR,
      mem_ba            => DDR2_2_BA,
      mem_ras_n         => DDR2_2_RAS_N,
      mem_cas_n         => DDR2_2_CAS_N,
      mem_we_n          => DDR2_2_WE_N,
      mem_dm            => DDR2_2_DM,
      mem_clk           => DDR2_2_CLK,
      mem_clk_n         => DDR2_2_CLK_N,
      mem_dq            => DDR2_2_DQ,
      mem_dqs           => DDR2_2_DQS,     
      -- To configuration memory
      to_tstcfg         => inst0_to_tstcfg,
      from_tstcfg       => inst0_from_tstcfg
   );    
   
-- ----------------------------------------------------------------------------
-- general_periph_top instance.
-- Control module for external periphery
-- ----------------------------------------------------------------------------
   inst4_general_periph_top : entity work.general_periph_top
   generic map(
      DEV_FAMILY  => g_DEV_FAMILY,
      N_GPIO      => g_GPIO_N
   )
   port map(
      -- General ports
      clk                  => LMK_CLK,
      reset_n              => reset_n_lmk_clk,
      -- configuration memory
      from_fpgacfg         => inst0_from_fpgacfg,
      to_periphcfg         => inst0_to_periphcfg,
      from_periphcfg       => inst0_from_periphcfg,     
      -- Dual colour LEDs
      -- LED1 (Clock and PLL lock status)
      led1_pll1_locked     => inst1_txpll_locked,
      led1_pll2_locked     => inst1_rxpll_locked,
      led1_ctrl            => inst0_from_fpgacfg.FPGA_LED1_CTRL,
      led1_g               => FPGA_LED1_G,
      led1_r               => FPGA_LED1_R,      
      --LED2 (TCXO control status)
      led2_clk             => inst0_spi_1_SCLK,
      led2_adf_muxout      => ADF_MUXOUT,
      led2_dac_ss          => inst0_spi_1_SS_n(0),
      led2_adf_ss          => inst0_spi_1_SS_n(1),
      led2_ctrl            => inst0_from_fpgacfg.FPGA_LED2_CTRL,
      led2_g               => FPGA_LED2_G,
      led2_r               => FPGA_LED2_R,     
      --LED3 - LED6
      led3_in              => inst1_rxpll_locked,
      led4_in              => inst1_txpll_locked,
      led5_in              => inst2_user_read_32_open OR inst2_user_write_32_open,
      led6_in              => '0',
      led3_out             => FPGA_LED3,
      led4_out             => FPGA_LED4,
      led5_out             => FPGA_LED5,
      led6_out             => FPGA_LED6,    
      --GPIO
      gpio_dir             => (others=>'1'),
      gpio_out_val         => "000000000000" & inst6_tx_pct_loss_flg & inst1_txpll_locked & inst1_rxpll_locked & inst6_tx_txant_en,
      gpio_rd_val          => open,
      gpio                 => FPGA_GPIO,      
      --Fan control
      fan_sens_in          => LM75_OS,
      fan_ctrl_out         => FAN_CTRL
   );
   
   inst5_busy_delay : entity work.busy_delay
   generic map(
      clock_period   => 10,
      delay_time     => 200  -- delay time in ms
      --counter_value=delay_time*1000/clock_period<2^32
      --delay counter is 32bit wide, 
   )
   port map(
      --input ports 
      clk      => CLK100_FPGA,
      reset_n  => reset_n_clk100_fpga,
      busy_in  => inst0_gpo(0),
      busy_out => inst5_busy
   );
    
-- ----------------------------------------------------------------------------
-- rxtx_top instance.
-- Receive and transmit interface for LMS7002
-- ----------------------------------------------------------------------------
   -- Rx interface is enabled only when user_read_32 port is opened from Host. 
   process(inst0_from_fpgacfg, inst2_user_read_32_open)
   begin 
      inst0_from_fpgacfg_mod        <= inst0_from_fpgacfg;
      inst0_from_fpgacfg_mod.rx_en  <= inst0_from_fpgacfg.rx_en AND 
                                       (inst2_user_read_32_open OR inst2_user_write_32_open);
   end process;
   
   inst6_rxtx_top : entity work.rxtx_top
   generic map(
      DEV_FAMILY              => g_DEV_FAMILY,
      -- TX parameters
      TX_IQ_WIDTH             => g_LMS_DIQ_WIDTH,
      TX_N_BUFF               => g_TX_N_BUFF,              -- 2,4 valid values
      TX_IN_PCT_SIZE          => g_TX_PCT_SIZE,
      TX_IN_PCT_HDR_SIZE      => g_TX_IN_PCT_HDR_SIZE,
      TX_IN_PCT_DATA_W        => c_H2F_S0_0_RWIDTH,      -- 
      TX_IN_PCT_RDUSEDW_W     => c_H2F_S0_0_RDUSEDW_WIDTH,
      
      -- RX parameters
      RX_IQ_WIDTH             => g_LMS_DIQ_WIDTH,
      RX_INVERT_INPUT_CLOCKS  => "ON",
      RX_PCT_BUFF_WRUSEDW_W   => c_F2H_S0_WRUSEDW_WIDTH, --bus width in bits 
      
      -- WFM
      --DDR2 controller parameters
      WFM_CNTRL_RATE          => 1, --1 - full rate, 2 - half rate
      WFM_CNTRL_BUS_SIZE      => 16,
      WFM_ADDR_SIZE           => 25,
      WFM_LCL_BUS_SIZE        => 64,
      WFM_LCL_BURST_LENGTH    => 2,
      --WFM player parameters
      WFM_WFM_INFIFO_SIZE     => c_WFM_INFIFO_SIZE,
      WFM_DATA_WIDTH          => c_S0_DATA_WIDTH,
      WFM_IQ_WIDTH            => g_LMS_DIQ_WIDTH
   )
   port map(                                             
      from_fpgacfg            => inst0_from_fpgacfg_mod,
      to_tstcfg_from_rxtx     => inst6_to_tstcfg_from_rxtx,
      from_tstcfg             => inst0_from_tstcfg,
      
      -- TX module signals
      tx_clk                  => inst1_txpll_c1,
      tx_clk_reset_n          => inst1_txpll_locked,     
      tx_pct_loss_flg         => inst6_tx_pct_loss_flg,
      tx_txant_en             => inst6_tx_txant_en,  
      --Tx interface data 
      tx_DIQ                  => LMS_DIQ1_D,
      tx_fsync                => LMS_DIQ1_IQSEL,
      --fifo ports
      tx_in_pct_reset_n_req   => inst6_tx_in_pct_reset_n_req,
      tx_in_pct_rdreq         => inst6_tx_in_pct_rdreq,
      tx_in_pct_data          => inst2_H2F_S0_0_rdata,
      tx_in_pct_rdempty       => inst2_H2F_S0_0_rempty,
      tx_in_pct_rdusedw       => inst2_H2F_S0_0_rdusedw,
      
      -- WFM Player
      wfm_pll_ref_clk         => CLK50_FPGA,
      wfm_pll_ref_clk_reset_n => reset_n_clk50_fpga,    
      wfm_phy_clk             => inst6_wfm_phy_clk,
         -- WFM FIFO read ports
      wfm_in_pct_reset_n_req  => inst6_wfm_in_pct_reset_n_req,
      wfm_in_pct_rdreq        => inst6_wfm_in_pct_rdreq, 
      wfm_in_pct_data         => inst2_H2F_S0_1_rdata,
      wfm_in_pct_rdempty      => inst2_H2F_S0_1_rempty,
      wfm_in_pct_rdusedw      => inst2_H2F_S0_1_rdusedw,

      --DDR2 external memory signals
      wfm_mem_odt             => DDR2_1_ODT,
      wfm_mem_cs_n            => DDR2_1_CS_N,
      wfm_mem_cke             => DDR2_1_CKE,
      wfm_mem_addr            => DDR2_1_ADDR,
      wfm_mem_ba              => DDR2_1_BA,
      wfm_mem_ras_n           => DDR2_1_RAS_N,
      wfm_mem_cas_n           => DDR2_1_CAS_N,
      wfm_mem_we_n            => DDR2_1_WE_N,
      wfm_mem_dm              => DDR2_1_DM,
      wfm_mem_clk             => DDR2_1_CLK,
      wfm_mem_clk_n           => DDR2_1_CLK_N,
      wfm_mem_dq              => DDR2_1_DQ,
      wfm_mem_dqs             => DDR2_1_DQS,
      
      -- RX path
      rx_clk                  => inst1_rxpll_c1,
      rx_clk_reset_n          => inst1_rxpll_locked,
      --Rx interface data 
      rx_DIQ                  => LMS_DIQ2_D,
      rx_fsync                => LMS_DIQ2_IQSEL2,
      --Packet fifo ports
      rx_pct_fifo_aclrn_req   => inst6_rx_pct_fifo_aclrn_req,
      rx_pct_fifo_wusedw      => inst2_F2H_S0_wrusedw,
      rx_pct_fifo_wrreq       => inst6_rx_pct_fifo_wrreq,
      rx_pct_fifo_wdata       => inst6_rx_pct_fifo_wdata,
      --sample compare
      rx_smpl_cmp_start       => inst1_txpll_smpl_cmp_en OR inst1_rxpll_smpl_cmp_en,
      rx_smpl_cmp_length      => inst1_rxpll_smpl_cmp_cnt,
      rx_smpl_cmp_done        => inst6_rx_smpl_cmp_done,
      rx_smpl_cmp_err         => inst6_rx_smpl_cmp_err     
   );
   
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------
   
   FPGA_SPI0_MOSI    <= inst0_spi_0_MOSI;
   FPGA_SPI0_SCLK    <= inst0_spi_0_SCLK;
   FPGA_SPI0_LMS_SS  <= inst0_spi_0_SS_n(0);
   
   LMS_RESET         <= inst0_from_fpgacfg.LMS1_RESET AND inst0_lms_ctr_gpio(0);
   LMS_TXEN          <= inst0_from_fpgacfg.LMS1_TXEN;
   LMS_RXEN          <= inst0_from_fpgacfg.LMS1_RXEN;
   LMS_CORE_LDO_EN   <= inst0_from_fpgacfg.LMS1_CORE_LDO_EN;
   LMS_TXNRX1        <= inst0_from_fpgacfg.LMS1_TXNRX1;
   LMS_TXNRX2        <= inst0_from_fpgacfg.LMS1_TXNRX2;
   
   TX1_2_LB_L        <= not inst0_from_fpgacfg.GPIO(0);
   TX1_2_LB_H        <= inst0_from_fpgacfg.GPIO(0);
   TX1_2_LB_SH       <= inst0_from_fpgacfg.GPIO(2);
   
   TX2_2_LB_L        <= not inst0_from_fpgacfg.GPIO(4);
   TX2_2_LB_H        <= inst0_from_fpgacfg.GPIO(4);
   TX2_2_LB_SH       <= inst0_from_fpgacfg.GPIO(6);
   
   FPGA_SPI1_MOSI    <= inst0_spi_1_MOSI;
   FPGA_SPI1_SCLK    <= inst0_spi_1_SCLK;
   FPGA_SPI1_DAC_SS  <= inst0_spi_1_SS_n(0);
   FPGA_SPI1_ADF_SS  <= inst0_spi_1_SS_n(1);
   
   FPGA_AS_DCLK      <= inst0_spi_2_SCLK;
   FPGA_AS_ASDO      <= inst0_spi_2_MOSI;
   FPGA_AS_NCSO      <= inst0_spi_2_SS_n;


end arch;   



