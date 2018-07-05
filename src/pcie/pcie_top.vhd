-- ----------------------------------------------------------------------------
-- FILE:          pcie_top.vhd
-- DESCRIPTION:   Top module for PCIe connection
-- DATE:          11:11 AM Thursday, June 28, 2018N
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

LIBRARY altera_mf;
USE altera_mf.all;
-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pcie_top is
   generic(
      dev_family           : string := "Cyclone IV GX";
      stream_data_width    : integer := 32;
      controll_data_width  : integer := 8;
      -- Stream (PC->FPGA) 
      EP01_0_rdusedw_width : integer := 11;
      EP01_0_rwidth        : integer := 32;
      EP01_1_rdusedw_width : integer := 11;
      EP01_1_rwidth        : integer := 32;
      -- Stream (FPGA->PC)
      EP81_wrusedw_width   : integer := 10;
      EP81_wwidth          : integer := 64;
      -- Control (PC->FPGA)
      EP0F_rdusedw_width   : integer := 11;
      EP0F_rwidth          : integer := 8;
      -- Control (FPGA->PC)
      EP8F_wrusedw_width   : integer := 11;
      EP8F_wwidth          : integer := 8
   );
   port (
      inclk_125            : in std_logic;   -- Input clock for PLL
      reset_n              : in std_logic;
      -- PCIe interface
      pcie_perstn          : in std_logic;
      pcie_refclk          : in std_logic;
      pcie_rx              : in std_logic_vector(3 downto 0);
      pcie_tx              : out std_logic_vector(3 downto 0);
      pcie_bus_clk         : out std_logic;  -- PCIe data clock output
      -- FIFO buffers
      EP01_sel             : in std_logic;      -- 0 - EP01_0,
     --Stream endpoint FIFO 0 (PC->FPGA) 
      EP01_0_rdclk         : in std_logic;
      EP01_0_aclrn         : in std_logic;
      EP01_0_rd            : in std_logic;
      EP01_0_rdata         : out std_logic_vector(EP01_0_rwidth-1 downto 0);
      EP01_0_rempty        : out std_logic;
      EP01_0_rdusedw       : out std_logic_vector(EP01_0_rdusedw_width-1 downto 0);
      --Stream endpoint FIFO 1 (PC->FPGA) 
      EP01_1_rdclk         : in std_logic;
      EP01_1_aclrn         : in std_logic;
      EP01_1_rd            : in std_logic;
      EP01_1_rdata         : out std_logic_vector(EP01_1_rwidth-1 downto 0);
      EP01_1_rempty        : out std_logic;
      EP01_1_rdusedw       : out std_logic_vector(EP01_1_rdusedw_width-1 downto 0);
      --Stream endpoint FIFO (FPGA->PC)
      EP81_wclk            : in std_logic;
      EP81_aclrn           : in std_logic;
      EP81_wr              : in std_logic;
      EP81_wdata           : in std_logic_vector(EP81_wwidth-1 downto 0);
      EP81_wfull           : out std_logic;
      EP81_wrusedw         : out std_logic_vector(EP81_wrusedw_width-1 downto 0);
      --Control endpoint FIFO (PC->FPGA)
      EP0F_rdclk           : in std_logic;
      EP0F_aclrn           : in std_logic;
      EP0F_rd              : in std_logic;
      EP0F_rdata           : out std_logic_vector(EP0F_rwidth-1 downto 0);
      EP0F_rempty          : out std_logic;
      --Control endpoint FIFO (FPGA->PC)
      EP8F_wclk            : in std_logic;
      EP8F_aclrn           : in std_logic;
      EP8F_wr              : in std_logic;
      EP8F_wdata           : in std_logic_vector(EP8F_wwidth-1 downto 0);
      EP8F_wfull           : out std_logic;

      stream_rx_en         : in std_logic;
      user_read_32_open    : out std_logic
   );
end pcie_top;
  
architecture sample_arch of pcie_top is
   -- Module constants
   constant C_EP01_0_WRUSEDW_WIDTH  : integer := FIFOWR_SIZE (stream_data_width, EP01_0_rwidth, EP01_0_rdusedw_width);
   constant C_EP01_0_RDUSEDW_WIDTH  : integer := EP01_0_rdusedw_width; 
   constant C_EP01_1_WRUSEDW_WIDTH  : integer := FIFOWR_SIZE (stream_data_width, EP01_1_rwidth, EP01_1_rdusedw_width);
   constant C_EP01_1_RDUSEDW_WIDTH  : integer := EP01_1_rdusedw_width; 

   constant C_EP0F_WRUSEDW_WIDTH    : integer := FIFOWR_SIZE (controll_data_width, EP0F_rwidth, EP0F_rdusedw_width);
   constant C_EP0F_RDUSEDW_WIDTH    : integer := EP0F_rdusedw_width; 
   
   constant C_EP81_WRUSEDW_WIDTH    : integer := EP81_wrusedw_width;
   constant C_EP81_RDUSEDW_WIDTH    : integer := FIFORD_SIZE (EP81_wwidth, stream_data_width, EP81_wrusedw_width);
   
   constant C_EP8F_WRUSEDW_WIDTH    : integer := EP8F_wrusedw_width;
   constant C_EP8F_RDUSEDW_WIDTH    : integer := FIFORD_SIZE (EP8F_wwidth, controll_data_width, EP8F_wrusedw_width);
  
   signal EP01_sel_sync             : std_logic;
   signal EP01_0_sclrn              : std_logic;
   signal EP01_1_sclrn              : std_logic;
   signal EP01_0_sclrn_reg          : std_logic;
   signal EP01_1_sclrn_reg          : std_logic;
   

   signal bus_clk                   : std_logic;
   signal quiesce                   : std_logic;
   
   signal reset_8                   : std_logic;
   signal reset_32                  : std_logic;

   signal ram_addr                  : integer range 0 to 31;
   
   signal inst1_user_r_mem_8_rden      : std_logic;
   signal inst1_user_r_mem_8_empty     : std_logic;
   signal inst1_user_r_mem_8_data      : std_logic_vector(7 DOWNTO 0);
   signal inst1_user_r_mem_8_eof       : std_logic;
   signal inst1_user_r_mem_8_open      : std_logic;
   signal inst1_user_w_mem_8_wren      : std_logic;
   signal inst1_user_w_mem_8_full      : std_logic;
   signal inst1_user_w_mem_8_data      : std_logic_vector(7 DOWNTO 0);
   signal inst1_user_w_mem_8_open      : std_logic;
   signal inst1_user_mem_8_addr        : std_logic_vector(4 DOWNTO 0);
   signal inst1_user_mem_8_addr_update : std_logic;
   signal inst1_user_r_read_32_rden    : std_logic;
   signal inst1_user_r_read_32_empty   : std_logic;
   signal inst1_user_r_read_32_rdusedw : std_logic_vector(12 downto 0);
   signal inst1_user_r_read_32_data    : std_logic_vector(31 DOWNTO 0);
   signal inst1_user_r_read_32_eof     : std_logic;
   signal inst1_user_r_read_32_open    : std_logic;
   signal inst1_user_r_read_32_cnt     : unsigned(15 downto 0);
   signal inst1_user_r_read_8_rden     : std_logic;
   signal inst1_user_r_read_8_empty    : std_logic;
   signal inst1_user_r_read_8_data     : std_logic_vector(7 DOWNTO 0);
   signal inst1_user_r_read_8_eof      : std_logic;
   signal inst1_user_r_read_8_open     : std_logic;
   signal inst1_user_w_write_32_wren   : std_logic;
   signal inst1_user_w_write_32_full   : std_logic;
   signal inst1_user_w_write_32_data   : std_logic_vector(31 DOWNTO 0);
   signal inst1_user_w_write_32_open   : std_logic;
   signal inst1_user_w_write_8_wren    : std_logic;
   signal inst1_user_w_write_8_full    : std_logic;
   signal inst1_user_w_write_8_data    : std_logic_vector(7 DOWNTO 0);
   signal inst1_user_w_write_8_open    : std_logic;

   --inst0
   signal inst0_areset           : std_logic;
   signal inst0_clk              : std_logic_vector(9 DOWNTO 0);
   signal inst0_inclk            : std_logic_vector(1 DOWNTO 0);
     
   --inst2
   signal inst2_reset_n          : std_logic;
   signal inst2_wrreq            : std_logic;
   signal inst2_wrfull           : std_logic;

   --inst3
   signal inst3_reset_n          : std_logic;
   signal inst3_pct_wr           : std_logic;
   signal inst3_pct_payload_data : std_logic_vector(stream_data_width-1 downto 0);
   signal inst3_pct_payload_valid: std_logic;
   
   --inst4
   signal inst4_reset_n          : std_logic;
   signal inst4_wrreq            : std_logic;
   signal inst4_wrfull           : std_logic;
   
   --inst5
   signal inst5_reset_n          : std_logic;
   signal inst5_wrfull           : std_logic;
   
   --inst6
   signal inst6_reset_n          : std_logic;
   signal inst6_rdempty          : std_logic;
   signal inst6_q                : std_logic_vector(stream_data_width-1 downto 0);
   
   --inst6
   signal inst7_reset_n          : std_logic;
   signal inst7_rdempty          : std_logic;
   signal inst7_q                : std_logic_vector(controll_data_width-1 downto 0);
   
   signal reconfig_clk_locked    : std_logic;
   signal clk_50                 : std_logic;
   signal clk_125                : std_logic;
  
   signal clr_rx_fifo            : std_logic;
   
   signal pct_rdy                : std_logic;

   type array_type is array (0 to 15) of std_logic_vector(31 downto 0);
   type array_type2 is array (0 to 7) of std_logic_vector(11 downto 0);
  
   signal fpga_outfifo_q         : std_logic_vector(31 downto 0);
   signal fpga_outfifo_empty     : std_logic;
   signal fpga_outfifo_empty_gen : std_logic;

   signal stream_rx_en_sync      : std_logic;
   signal stream_rx_en_reg0      : std_logic;
   signal stream_rx_en_reg1      : std_logic;
   signal stream_rx_en_reg2      : std_logic;
   
   signal EP01_1_rd_cnt          : unsigned(31 downto 0);
   
   attribute noprune : boolean;
   attribute noprune of EP01_1_rd_cnt : signal is true;
   
   component xillybus
      port (
         clk_125                 : IN std_logic;
         clk_50                  : IN std_logic;
         reconfig_clk_locked     : IN std_logic;
         pcie_perstn             : IN std_logic;
         pcie_refclk             : IN std_logic;
         pcie_rx                 : IN std_logic_vector(3 DOWNTO 0);
         bus_clk                 : OUT std_logic;
         pcie_tx                 : OUT std_logic_vector(3 DOWNTO 0);
         quiesce                 : OUT std_logic;
         user_led                : OUT std_logic_vector(3 DOWNTO 0);
         user_r_mem_8_rden       : OUT std_logic;
         user_r_mem_8_empty      : IN std_logic;
         user_r_mem_8_data       : IN std_logic_vector(7 DOWNTO 0);
         user_r_mem_8_eof        : IN std_logic;
         user_r_mem_8_open       : OUT std_logic;
         user_w_mem_8_wren       : OUT std_logic;
         user_w_mem_8_full       : IN std_logic;
         user_w_mem_8_data       : OUT std_logic_vector(7 DOWNTO 0);
         user_w_mem_8_open       : OUT std_logic;
         user_mem_8_addr         : OUT std_logic_vector(4 DOWNTO 0);
         user_mem_8_addr_update  : OUT std_logic;
         user_r_read_32_rden     : OUT std_logic;
         user_r_read_32_empty    : IN std_logic;
         user_r_read_32_data     : IN std_logic_vector(31 DOWNTO 0);
         user_r_read_32_eof      : IN std_logic;
         user_r_read_32_open     : OUT std_logic;
         user_r_read_8_rden      : OUT std_logic;
         user_r_read_8_empty     : IN std_logic;
         user_r_read_8_data      : IN std_logic_vector(7 DOWNTO 0);
         user_r_read_8_eof       : IN std_logic;
         user_r_read_8_open      : OUT std_logic;
         user_w_write_32_wren    : OUT std_logic;
         user_w_write_32_full    : IN std_logic;
         user_w_write_32_data    : OUT std_logic_vector(31 DOWNTO 0);
         user_w_write_32_open    : OUT std_logic;
         user_w_write_8_wren     : OUT std_logic;
         user_w_write_8_full     : IN std_logic;
         user_w_write_8_data     : OUT std_logic_vector(7 DOWNTO 0);
         user_w_write_8_open     : OUT std_logic);
  end component;

  COMPONENT altpll
    GENERIC (
      bandwidth_type          : STRING;
      clk0_divide_by          : NATURAL;
      clk0_duty_cycle         : NATURAL;
      clk0_multiply_by        : NATURAL;
      clk0_phase_shift        : STRING;
      clk1_divide_by          : NATURAL;
      clk1_duty_cycle         : NATURAL;
      clk1_multiply_by        : NATURAL;
      clk1_phase_shift        : STRING;
      inclk0_input_frequency  : NATURAL;
      intended_device_family  : STRING;
      lpm_hint                : STRING;
      lpm_type                : STRING;
      operation_mode          : STRING;
      pll_type                : STRING;
      port_activeclock        : STRING;
      port_areset             : STRING;
      port_clkbad0            : STRING;
      port_clkbad1            : STRING;
      port_clkloss            : STRING;
      port_clkswitch          : STRING;
      port_configupdate       : STRING;
      port_fbin               : STRING;
      port_fbout              : STRING;
      port_inclk0             : STRING;
      port_inclk1             : STRING;
      port_locked             : STRING;
      port_pfdena             : STRING;
      port_phasecounterselect : STRING;
      port_phasedone          : STRING;
      port_phasestep          : STRING;
      port_phaseupdown        : STRING;
      port_pllena             : STRING;
      port_scanaclr           : STRING;
      port_scanclk            : STRING;
      port_scanclkena         : STRING;
      port_scandata           : STRING;
      port_scandataout        : STRING;
      port_scandone           : STRING;
      port_scanread           : STRING;
      port_scanwrite          : STRING;
      port_clk0               : STRING;
      port_clk1               : STRING;
      port_clk2               : STRING;
      port_clk3               : STRING;
      port_clk4               : STRING;
      port_clk5               : STRING;
      port_clk6               : STRING;
      port_clk7               : STRING;
      port_clk8               : STRING;
      port_clk9               : STRING;
      port_clkena0            : STRING;
      port_clkena1            : STRING;
      port_clkena2            : STRING;
      port_clkena3            : STRING;
      port_clkena4            : STRING;
      port_clkena5            : STRING;
      self_reset_on_loss_lock : STRING;
      using_fbmimicbidir_port : STRING;
      width_clock             : NATURAL
      );
    PORT (
      areset   : IN STD_LOGIC ;
      clk      : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
      inclk    : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
      locked   : OUT STD_LOGIC 
      );
  END COMPONENT;

  
begin
-- ----------------------------------------------------------------------------
-- Reset logic
-- ----------------------------------------------------------------------------  
   -- Reset signal with synchronous removal to clk clock domain, 
   sync_reg0 : entity work.sync_reg 
   port map(bus_clk, EP01_0_aclrn, '1', EP01_0_sclrn);
   
   sync_reg1 : entity work.sync_reg 
   port map(bus_clk, EP01_1_aclrn, '1', EP01_1_sclrn); 
   
   
   inst2_reset_n <= EP01_0_sclrn;
   --For 01 Stream endpoint, Host->FPGA
   inst3_reset_n <= inst1_user_w_write_32_open OR EP01_1_sclrn;   
   inst4_reset_n <= inst3_reset_n;
   --For 0F Control endpoint, Host->FPGA
   inst5_reset_n <= inst1_user_w_write_8_open;
   --For 81 stream endpoint, FPGA->Host
   inst6_reset_n <= inst1_user_r_read_32_open;  
   --For 8F control endpoint, FPGA->Host
   inst7_reset_n <= inst1_user_r_read_8_open;

-- ----------------------------------------------------------------------------
-- Sync registers
-- ----------------------------------------------------------------------------   
   sync_reg3 : entity work.sync_reg 
   port map(bus_clk, reset_n, EP01_sel, EP01_sel_sync); 
   
   sync_reg4 : entity work.sync_reg 
   port map(bus_clk, '1', stream_rx_en, stream_rx_en_sync);

-- ----------------------------------------------------------------------------
-- For synchronising enable signal to bus_clk
-- ----------------------------------------------------------------------------	
   process(bus_clk, clr_rx_fifo)
   begin
      if clr_rx_fifo='1' then 
         stream_rx_en_reg0<='0';
         stream_rx_en_reg1<='0';
         stream_rx_en_reg2<='0';
      elsif (bus_clk'event and bus_clk='1') then
         stream_rx_en_reg0<=stream_rx_en_sync;
         stream_rx_en_reg1<=stream_rx_en_reg0;
         stream_rx_en_reg2<=stream_rx_en_reg1;
      end if;
   end process;


   --pcie bus clock for user needs
   pcie_bus_clk <= bus_clk;


-- ----------------------------------------------------------------------------
-- PLL inst for Xillybus 
-- ----------------------------------------------------------------------------	
   altpll_inst0 : altpll
   GENERIC MAP (
      bandwidth_type          => "AUTO",
      clk0_divide_by          => 1,
      clk0_duty_cycle         => 50,
      clk0_multiply_by        => 1,
      clk0_phase_shift        => "0",
      clk1_divide_by          => 5,
      clk1_duty_cycle         => 50,
      clk1_multiply_by        => 2,
      clk1_phase_shift        => "0",
      inclk0_input_frequency  => 8000,
      intended_device_family  => "Cyclone IV",
      lpm_hint                => "CBX_MODULE_PREFIX=pll_vhdl",
      lpm_type                => "altpll",
      operation_mode          => "NO_COMPENSATION",
      pll_type                => "AUTO",
      port_activeclock        => "PORT_UNUSED",
      port_areset             => "PORT_USED",
      port_clkbad0            => "PORT_UNUSED",
      port_clkbad1            => "PORT_UNUSED",
      port_clkloss            => "PORT_UNUSED",
      port_clkswitch          => "PORT_UNUSED",
      port_configupdate       => "PORT_UNUSED",
      port_fbin               => "PORT_UNUSED",
      port_fbout              => "PORT_UNUSED",
      port_inclk0             => "PORT_USED",
      port_inclk1             => "PORT_UNUSED",
      port_locked             => "PORT_USED",
      port_pfdena             => "PORT_UNUSED",
      port_phasecounterselect => "PORT_UNUSED",
      port_phasedone          => "PORT_UNUSED",
      port_phasestep          => "PORT_UNUSED",
      port_phaseupdown        => "PORT_UNUSED",
      port_pllena             => "PORT_UNUSED",
      port_scanaclr           => "PORT_UNUSED",
      port_scanclk            => "PORT_UNUSED",
      port_scanclkena         => "PORT_UNUSED",
      port_scandata           => "PORT_UNUSED",
      port_scandataout        => "PORT_UNUSED",
      port_scandone           => "PORT_UNUSED",
      port_scanread           => "PORT_UNUSED",
      port_scanwrite          => "PORT_UNUSED",
      port_clk0               => "PORT_USED",
      port_clk1               => "PORT_UNUSED",
      port_clk2               => "PORT_UNUSED",
      port_clk3               => "PORT_UNUSED",
      port_clk4               => "PORT_UNUSED",
      port_clk5               => "PORT_UNUSED",
      port_clk6               => "PORT_UNUSED",
      port_clk7               => "PORT_UNUSED",
      port_clk8               => "PORT_UNUSED",
      port_clk9               => "PORT_UNUSED",
      port_clkena0            => "PORT_UNUSED",
      port_clkena1            => "PORT_UNUSED",
      port_clkena2            => "PORT_UNUSED",
      port_clkena3            => "PORT_UNUSED",
      port_clkena4            => "PORT_UNUSED",
      port_clkena5            => "PORT_UNUSED",
      self_reset_on_loss_lock => "OFF",
      using_fbmimicbidir_port => "OFF",
      width_clock             => 10
   )
   PORT MAP (
      areset   => inst0_areset,
      inclk    => inst0_inclk,
      locked   => reconfig_clk_locked,
      clk      => inst0_clk
   );

  inst0_areset <= '0';
  inst0_inclk  <= '0' & inclk_125;
  clk_125      <= inst0_clk(0);
  clk_50       <= inst0_clk(1);
  
-- ----------------------------------------------------------------------------
-- Xillybus inst 
-- ----------------------------------------------------------------------------      
  xillybus_inst1 : xillybus
    port map (
      -- Ports related to /dev/xillybus_mem_8
      -- FPGA to CPU signals:
      user_r_mem_8_rden       => inst1_user_r_mem_8_rden,
      user_r_mem_8_empty      => inst1_user_r_mem_8_empty,
      user_r_mem_8_data       => inst1_user_r_mem_8_data,
      user_r_mem_8_eof        => inst1_user_r_mem_8_eof,
      user_r_mem_8_open       => inst1_user_r_mem_8_open,
      -- CPU to FPGA signals:
      user_w_mem_8_wren       => inst1_user_w_mem_8_wren,
      user_w_mem_8_full       => inst1_user_w_mem_8_full,
      user_w_mem_8_data       => inst1_user_w_mem_8_data,
      user_w_mem_8_open       => inst1_user_w_mem_8_open,
      -- Address signals:
      user_mem_8_addr         => inst1_user_mem_8_addr,
      user_mem_8_addr_update  => inst1_user_mem_8_addr_update,

      -- Ports related to /dev/xillybus_read_32
      -- FPGA to CPU signals:
      user_r_read_32_rden     => inst1_user_r_read_32_rden,
      user_r_read_32_empty    => inst6_rdempty,
      user_r_read_32_data     => inst6_q,
      user_r_read_32_eof      => inst1_user_r_read_32_eof,
      user_r_read_32_open     => inst1_user_r_read_32_open,

      -- Ports related to /dev/xillybus_read_8
      -- FPGA to CPU signals:
      user_r_read_8_rden      => inst1_user_r_read_8_rden,
      user_r_read_8_empty     => inst7_rdempty,
      user_r_read_8_data      => inst7_q,
      user_r_read_8_eof       => inst1_user_r_read_8_eof,
      user_r_read_8_open      => inst1_user_r_read_8_open,

      -- Ports related to /dev/xillybus_write_32
      -- CPU to FPGA signals:
      user_w_write_32_wren    => inst1_user_w_write_32_wren,
      user_w_write_32_full    => inst1_user_w_write_32_full,
      user_w_write_32_data    => inst1_user_w_write_32_data,
      user_w_write_32_open    => inst1_user_w_write_32_open,

      -- Ports related to /dev/xillybus_write_8
      -- CPU to FPGA signals:
      user_w_write_8_wren     => inst1_user_w_write_8_wren,
      user_w_write_8_full     => inst5_wrfull,
      user_w_write_8_data     => inst1_user_w_write_8_data,
      user_w_write_8_open     => inst1_user_w_write_8_open,

      -- General signals
      clk_125                 => clk_125,
      clk_50                  => clk_50,
      reconfig_clk_locked     => reconfig_clk_locked,
      pcie_perstn             => pcie_perstn,
      pcie_refclk             => pcie_refclk,
      pcie_rx                 => pcie_rx,
      bus_clk                 => bus_clk,
      pcie_tx                 => pcie_tx,
      quiesce                 => quiesce,
      user_led                => open
      );
   
      inst1_user_w_write_32_full <= inst2_wrfull when EP01_sel_sync = '0' else 
                                    inst4_wrfull;

                                    
-- ----------------------------------------------------------------------------
--  A simple inferred RAM for Xillybus
-- ---------------------------------------------------------------------------- 
  --ram_addr <= conv_integer(user_mem_8_addr);
  
--  process (bus_clk)
--  begin
--    if (bus_clk'event and bus_clk = '1') then
--      if (user_w_mem_8_wren = '1') then 
--        demoarray(ram_addr) <= user_w_mem_8_data;
--      end if;
--      if (user_r_mem_8_rden = '1') then
--        user_r_mem_8_data <= demoarray(ram_addr);
--      end if;
--    end if;
--  end process;

  inst1_user_r_mem_8_empty <= '0';
  inst1_user_r_mem_8_eof   <= '0';
  inst1_user_w_mem_8_full  <= '0';

-- ----------------------------------------------------------------------------
-- For 01 Stream endpoint, Host->FPGA
-- There are two FIFO buffers for this endpoint. Buffer is selected with EP01_sel
-- ----------------------------------------------------------------------------
   inst2_wrreq    <= inst1_user_w_write_32_wren when EP01_sel_sync = '0' else '0';
 
   -- First fifo, dedicated for TX stream
   inst2_EP01_0_FIFO : entity work.two_fifo_inst 
   generic map(
      dev_family     => dev_family,
      wrwidth        => stream_data_width,
      wrusedw_witdth => 10,  
      rdwidth        => EP01_0_rwidth,
      rdusedw_width  => C_EP01_0_RDUSEDW_WIDTH,
      show_ahead     => "OFF",
      TRNSF_SIZE     => 512, 
      TRNSF_N        => 8
   )
   port map(
      --input ports 
      reset_0_n   => inst1_user_w_write_32_open,
      reset_1_n   => inst2_reset_n,
      wrclk       => bus_clk,
      wrreq       => inst2_wrreq,
      data        => inst1_user_w_write_32_data,
      wrfull      => inst2_wrfull,
      wrempty     => open,
      wrusedw     => open,
      rdclk       => EP01_0_rdclk,
      rdreq       => EP01_0_rd,
      q           => EP01_0_rdata,
      rdempty     => EP01_0_rempty,
      rdusedw     => EP01_0_rdusedw   
   );
   
   inst3_pct_wr    <= inst1_user_w_write_32_wren when EP01_sel_sync = '1' else '0'; 
   -- This module takes only IQ data from packet, and discards packet header
   pct_payload_extrct_inst3 : entity work.pct_payload_extrct
   generic map(
      data_w			=> stream_data_width,
      header_size		=> 16, 
      pct_size			=> 4096
   ) 
   port map(
      clk					=> bus_clk,
      reset_n				=> inst3_reset_n,
      pct_data				=> inst1_user_w_write_32_data, 
      pct_wr				=> inst3_pct_wr,
      pct_payload_data	=> inst3_pct_payload_data,
      pct_payload_valid	=> inst3_pct_payload_valid,
      pct_payload_dest	=> open
   );
   
   -- Second FIFO, dedicated for WFM player
   inst4_EP01_1_FIFO : entity work.fifo_inst 
   generic map(
      dev_family     => dev_family,
      wrwidth        => stream_data_width,
      wrusedw_witdth => C_EP01_1_WRUSEDW_WIDTH,  
      rdwidth        => EP01_1_rwidth,
      rdusedw_width  => C_EP01_1_RDUSEDW_WIDTH,
      show_ahead     => "ON"
   )
   port map(
      --input ports 
      reset_n  => inst4_reset_n,
      wrclk    => bus_clk,
      wrreq    => inst3_pct_payload_valid,
      data     => inst3_pct_payload_data,
      wrfull   => inst4_wrfull,
      wrempty  => open,
      wrusedw  => open,
      rdclk    => EP01_1_rdclk,
      rdreq    => EP01_1_rd,
      q        => EP01_1_rdata,
      rdempty  => EP01_1_rempty,
      rdusedw  => EP01_1_rdusedw   
   );
   
-- ----------------------------------------------------------------------------
-- For 0F Control endpoint, Host->FPGA
-- ---------------------------------------------------------------------------- 
   inst5_EP0F_FIFO : entity work.fifo_inst 
   generic map(
      dev_family     => dev_family,
      wrwidth        => controll_data_width,
      wrusedw_witdth => C_EP0F_WRUSEDW_WIDTH,  
      rdwidth        => EP0F_rwidth,
      rdusedw_width  => C_EP0F_RDUSEDW_WIDTH,
      show_ahead     => "OFF"
   )
   port map(
      --input ports 
      reset_n  => inst5_reset_n,
      wrclk    => bus_clk,
      wrreq    => inst1_user_w_write_8_wren,
      data     => inst1_user_w_write_8_data,
      wrfull   => inst5_wrfull,
      wrempty  => open,
      wrusedw  => open,
      rdclk    => EP0F_rdclk,
      rdreq    => EP0F_rd,
      q        => EP0F_rdata,
      rdempty  => EP0F_rempty,
      rdusedw  => open     
   );  
-- ----------------------------------------------------------------------------
-- For 81 stream endpoint, FPGA->Host
-- ---------------------------------------------------------------------------- 
   inst6_EP81_FIFO : entity work.fifo_inst 
   generic map(
      dev_family     => dev_family,
      wrwidth        => EP81_wwidth,
      wrusedw_witdth => C_EP81_WRUSEDW_WIDTH,  
      rdwidth        => stream_data_width,
      rdusedw_width  => C_EP81_RDUSEDW_WIDTH,
      show_ahead     => "OFF"
   ) 
   port map(
      --input ports 
      reset_n  => inst6_reset_n,
      wrclk    => EP81_wclk,
      wrreq    => EP81_wr,
      data     => EP81_wdata,
      wrfull   => EP81_wfull,
      wrempty  => open,
      wrusedw  => EP81_wrusedw,
      rdclk    => bus_clk,
      rdreq    => inst1_user_r_read_32_rden,
      q        => inst6_q,
      rdempty  => inst6_rdempty,
      rdusedw  => open    
   );   
-- ----------------------------------------------------------------------------
-- For 8F control endpoint, FPGA->Host
-- ---------------------------------------------------------------------------- 
   inst7_EP8F_FIFO : entity work.fifo_inst 
   generic map(
      dev_family     => dev_family,
      wrwidth        => EP8F_wwidth,
      wrusedw_witdth => C_EP8F_WRUSEDW_WIDTH,  
      rdwidth        => controll_data_width,
      rdusedw_width  => C_EP8F_RDUSEDW_WIDTH,
      show_ahead     => "OFF"
   ) 
   port map(
      --input ports 
      reset_n  => inst7_reset_n,
      wrclk    => EP8F_wclk,
      wrreq    => EP8F_wr,
      data     => EP8F_wdata,
      wrfull   => EP8F_wfull,
      wrempty  => open,
      wrusedw  => open,
      rdclk    => bus_clk,
      rdreq    => inst1_user_r_read_8_rden,
      q        => inst7_q,
      rdempty  => inst7_rdempty,
      rdusedw  => open    
   );   

-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------    
   inst1_user_r_read_32_eof   <= '0';
  
   inst1_user_r_read_8_eof    <= '0';

   user_read_32_open          <= inst1_user_r_read_32_open;
  
end sample_arch;
