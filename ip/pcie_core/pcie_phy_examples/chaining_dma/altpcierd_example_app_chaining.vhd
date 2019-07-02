LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

-- /**
--  * This Verilog HDL file is used for simulation and synthesis in
--  * the chaining DMA design example. It manage the interface between the
--  * chaining DMA and the Avalon Streaming ports
--  */
-- synthesis translate_on
-------------------------------------------------------------------------------
-- Title         : PCI Express Reference Design Example Application
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcierd_example_app_chaining.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Copyright (c) 2009 Altera Corporation. All rights reserved.  Altera products are
-- protected under numerous U.S. and foreign patents, maskwork rights, copyrights and
-- other intellectual property laws.
--
-- This reference design file, and your use thereof, is subject to and governed by
-- the terms and conditions of the applicable Altera Reference Design License Agreement.
-- By using this reference design file, you indicate your acceptance of such terms and
-- conditions between you and Altera Corporation.  In the event that you do not agree with
-- such terms and conditions, you may not use the reference design file. Please promptly
-- destroy any copies you have made.
--
-- This reference design file being provided on an "as-is" basis and as an accommodation
-- and therefore all warranties, representations or guarantees of any kind
-- (whether express, implied or statutory) including, without limitation, warranties of
-- merchantability, non-infringement, or fitness for a particular purpose, are
-- specifically disclaimed.  By making this reference design file available, Altera
-- expressly does not recommend, suggest or require that this reference design file be
-- used in combination with any other product not provided by Altera.
-------------------------------------------------------------------------------
-- Parameters
--
-- AVALON_WDATA    : Width of the data port of the on chip Avalon memory
-- AVALON_WADDR    : Width of the address port of the on chip Avalon memory
-- MAX_NUMTAG      : Indicates the maximum number of PCIe tags
-- BOARD_DEMO      : Indicates to the software application which board is being
--                   used
--                    0 - Altera Stratix II GX  x1
--                    1 - Altera Stratix II GX  x4
--                    2 - Altera Stratix II GX  x8
--                    3 - Cyclone II            x1
--                    4 - Arria GX              x1
--                    5 - Arria GX              x4
--                    6 - Custom PHY            x1
--                    7 - Custom PHY            x4
-- USE_RCSLAVE     : When USE_RCSLAVE is set an additional module (~1000 LE)
--                   is added to the design to provide instrumentation to the
--                   PCI Express Chained DMA design such as Performance
--                   counter, debug register and EP memory Write a Read by
--                   bypassing the DMA engine.
-- TXCRED_WIDTH    : Width of the PCIe tx_cred back bus
-- TL_SELECTION    : Interface type
--                    0 : Descriptor data interface (in use with ICM)
--                    6 : Avalon-ST interface
-- MAX_PAYLOAD_SIZE_BYTE : Indicates the Maxpayload parameter specified in the
--                         PCIe MegaWizzard
--
ENTITY altpcierd_example_app_chaining IS
   GENERIC (
      AVALON_WADDR           : INTEGER := 12;
      MAX_NUMTAG             : INTEGER := 64;
      MAX_PAYLOAD_SIZE_BYTE  : INTEGER := 512;
      BOARD_DEMO             : INTEGER := 1;
      USE_RCSLAVE            : INTEGER := 1;
      TL_SELECTION           : INTEGER := 6;
      CLK_250_APP            : INTEGER := 0;
      ECRC_FORWARD_CHECK     : INTEGER := 1;
      ECRC_FORWARD_GENER     : INTEGER := 1;
      CHECK_RX_BUFFER_CPL    : INTEGER := 0;
      CHECK_BUS_MASTER_ENA   : INTEGER := 0;
      USE_CREDIT_CTRL        : INTEGER := 0;
      RC_64BITS_ADDR         : INTEGER := 0;
      USE_MSI                : INTEGER := 1;
      USE_DMAWRITE           : INTEGER := 1;
      USE_DMAREAD            : INTEGER := 1;
      INTENDED_DEVICE_FAMILY : STRING := "Stratix II";
      TXCRED_WIDTH           : INTEGER := 22
   );
   PORT (
      tx_stream_ready0       : IN STD_LOGIC;
      tx_stream_data0_0      : OUT STD_LOGIC_VECTOR(74 DOWNTO 0);
      tx_stream_data0_1      : OUT STD_LOGIC_VECTOR(74 DOWNTO 0);
      tx_stream_valid0       : OUT STD_LOGIC;
      tx_stream_fifo_empty0  : IN STD_LOGIC;
      rx_stream_data0_0      : IN STD_LOGIC_VECTOR(81 DOWNTO 0);
      rx_stream_data0_1      : IN STD_LOGIC_VECTOR(81 DOWNTO 0);
      rx_stream_valid0       : IN STD_LOGIC;
      rx_stream_ready0       : OUT STD_LOGIC;
      rx_stream_mask0        : OUT STD_LOGIC;
      msi_stream_ready0      : IN STD_LOGIC;
      msi_stream_data0       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      msi_stream_valid0      : OUT STD_LOGIC;
      aer_msi_num            : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      pex_msi_num            : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      app_msi_req            : OUT STD_LOGIC;
      app_msi_ack            : IN STD_LOGIC;
      app_msi_tc             : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      app_msi_num            : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      app_int_sts            : OUT STD_LOGIC;
      app_int_ack            : IN STD_LOGIC;
      tx_stream_mask0        : IN STD_LOGIC;
      tx_stream_cred0        : IN STD_LOGIC_VECTOR(TXCRED_WIDTH - 1 DOWNTO 0);
      cfg_busdev             : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
      cfg_devcsr             : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_tcvcmap            : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      cfg_linkcsr            : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_prmcsr            : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_msicsr             : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      cpl_pending            : OUT STD_LOGIC;
      cpl_err                : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      err_desc               : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      ko_cpl_spc_vc0         : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
      pm_data                : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
      test_sim               : IN STD_LOGIC;
      clk_in                 : IN STD_LOGIC;
      rstn                   : IN STD_LOGIC
   );
END ENTITY altpcierd_example_app_chaining;
ARCHITECTURE altpcie OF altpcierd_example_app_chaining IS



   FUNCTION to_stdlogic (
   val      : IN integer) RETURN std_logic IS
   BEGIN
      IF (val=1) THEN
         RETURN('1');
      ELSE
         RETURN('0');
      END IF;
   END to_stdlogic;
   FUNCTION to_stdlogic (
   val      : IN boolean) RETURN std_logic IS
   BEGIN
      IF (val) THEN
         RETURN('1');
      ELSE
         RETURN('0');
      END IF;
   END to_stdlogic;

FUNCTION get_CDMA_AST_RXWS_LATENCY (
val      : IN integer) RETURN integer IS
BEGIN
   IF (val=0) THEN
      RETURN(4);
   ELSE
      RETURN(2);
   END IF;
END get_CDMA_AST_RXWS_LATENCY;
FUNCTION get_AVALON_ST_128 (
val      : IN integer) RETURN integer IS
BEGIN
   IF (val=7) THEN
      RETURN(1);
   ELSE
      RETURN(0);
   END IF;
END get_AVALON_ST_128;
FUNCTION get_AVALON_BYTE_WIDTH (
val      : IN integer) RETURN integer IS
BEGIN
   IF (val=7) THEN
      RETURN(16);
   ELSE
      RETURN(8);
   END IF;
END get_AVALON_BYTE_WIDTH;

FUNCTION get_AVALON_WDATA (
val      : IN integer) RETURN integer IS
BEGIN
   IF (val=7) THEN
      RETURN(128);
   ELSE
      RETURN(64);
   END IF;
END get_AVALON_WDATA;

CONSTANT AVALON_WDATA           : INTEGER := get_AVALON_WDATA(TL_SELECTION);
CONSTANT CDMA_AST_RXWS_LATENCY  : INTEGER := get_CDMA_AST_RXWS_LATENCY(TL_SELECTION);
CONSTANT AVALON_ST_128          : INTEGER := get_AVALON_ST_128(TL_SELECTION);
CONSTANT AVALON_BYTE_WIDTH      : INTEGER := get_AVALON_BYTE_WIDTH(TL_SELECTION);
CONSTANT ZERO_INTEGER           : INTEGER := 0 ;

CONSTANT MSI_MON_IDLE         : std_logic_vector(3-1 downto 0):= "000";
CONSTANT MSI_WAIT_LOCAL_EMPTY : std_logic_vector(3-1 downto 0):= "001";
CONSTANT MSI_WAIT_LATENCY     : std_logic_vector(3-1 downto 0):= "010";
CONSTANT MSI_WAIT_CORE_EMPTY  : std_logic_vector(3-1 downto 0):= "011";
CONSTANT MSI_WAIT_CORE_ACK    : std_logic_vector(3-1 downto 0):= "100";

COMPONENT altpcierd_cdma_ast_tx
GENERIC (
   TL_SELECTION      : INTEGER := 0
);
PORT (
   clk_in            : IN STD_LOGIC;
   rstn              : IN STD_LOGIC;
   tx_stream_ready0  : IN STD_LOGIC;
   tx_stream_data0   : OUT STD_LOGIC_VECTOR(74 DOWNTO 0);
   tx_stream_valid0  : OUT STD_LOGIC;
   tx_req0           : IN STD_LOGIC;
   tx_ack0           : OUT STD_LOGIC;
   tx_desc0          : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
   tx_ws0            : OUT STD_LOGIC;
   tx_err0           : IN STD_LOGIC;
   tx_dv0            : IN STD_LOGIC;
   tx_dfr0           : IN STD_LOGIC;
   tx_data0          : IN STD_LOGIC_VECTOR(63 DOWNTO 0)
);
END COMPONENT;

COMPONENT altpcierd_cdma_ast_tx_128
GENERIC (
   ECRC_FORWARD_GENER  : INTEGER := 0
);
PORT (
   clk_in              : IN STD_LOGIC;
   srst                : IN STD_LOGIC;
   tx_stream_ready0    : IN STD_LOGIC;
   txdata              : OUT STD_LOGIC_VECTOR(132 DOWNTO 0);
   tx_stream_valid0    : OUT STD_LOGIC;
   tx_req0             : IN STD_LOGIC;
   tx_ack0             : OUT STD_LOGIC;
   tx_desc0            : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
   tx_ws0              : OUT STD_LOGIC;
   tx_err0             : IN STD_LOGIC;
   tx_dv0              : IN STD_LOGIC;
   tx_dfr0             : IN STD_LOGIC;
   tx_data0            : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
   tx_fifo_empty       : OUT STD_LOGIC
);
END COMPONENT;

COMPONENT altpcierd_cdma_ast_rx_128
GENERIC (
   ECRC_FORWARD_CHECK   : INTEGER := 0
);
PORT (
   clk_in               : IN STD_LOGIC;
   srst                 : IN STD_LOGIC;
   rxdata               : IN STD_LOGIC_VECTOR(139 DOWNTO 0);
   rxdata_be            : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
   rx_stream_valid0     : IN STD_LOGIC;
   rx_stream_ready0     : OUT STD_LOGIC;
   rx_ack0              : IN STD_LOGIC;
   rx_ws0               : IN STD_LOGIC;
   rx_req0              : OUT STD_LOGIC;
   rx_desc0             : OUT STD_LOGIC_VECTOR(135 DOWNTO 0);
   rx_data0             : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
   rx_be0               : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
   rx_dv0               : OUT STD_LOGIC;
   rx_dfr0              : OUT STD_LOGIC;
   rx_ecrc_check_valid  : OUT STD_LOGIC;
   ecrc_bad_cnt         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
);
END COMPONENT;

COMPONENT altpcierd_cdma_ast_rx
GENERIC (
   TL_SELECTION      : INTEGER := 0
);
PORT (
   clk_in            : IN STD_LOGIC;
   rstn              : IN STD_LOGIC;

   rx_stream_data0   : IN STD_LOGIC_VECTOR(81 DOWNTO 0);
   rx_stream_valid0  : IN STD_LOGIC;
   rx_stream_ready0  : OUT STD_LOGIC;

   rx_ack0           : IN STD_LOGIC;
   rx_ws0            : IN STD_LOGIC;
   rx_req0           : OUT STD_LOGIC;
   rx_desc0          : OUT STD_LOGIC_VECTOR(135 DOWNTO 0);
   rx_data0          : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
   rx_dv0            : OUT STD_LOGIC;
   rx_dfr0           : OUT STD_LOGIC;
   rx_be0            : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
   ecrc_bad_cnt      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
);
END COMPONENT;

COMPONENT altpcierd_cdma_ast_msi
PORT (
   clk_in        : IN STD_LOGIC;
   rstn          : IN STD_LOGIC;
   app_msi_req   : IN STD_LOGIC;
   app_msi_ack   : OUT STD_LOGIC;
   app_msi_tc    : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
   app_msi_num   : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
   stream_ready  : IN STD_LOGIC;
   stream_data   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
   stream_valid  : OUT STD_LOGIC
);
END COMPONENT;

COMPONENT altpcierd_cdma_ast_tx_64 IS
GENERIC (
   ECRC_FORWARD_GENER  : INTEGER := 0
);
PORT (
   clk_in              : IN STD_LOGIC;
   srst                : IN STD_LOGIC;
   tx_stream_ready0    : IN STD_LOGIC;
   txdata              : OUT STD_LOGIC_VECTOR(132 DOWNTO 0);
   tx_stream_valid0    : OUT STD_LOGIC;
   tx_req0             : IN STD_LOGIC;
   tx_ack0             : OUT STD_LOGIC;
   tx_desc0            : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
   tx_ws0              : OUT STD_LOGIC;
   tx_err0             : IN STD_LOGIC;
   tx_dv0              : IN STD_LOGIC;
   tx_dfr0             : IN STD_LOGIC;
   tx_data0            : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
   tx_fifo_empty       : OUT STD_LOGIC
);
END COMPONENT;

COMPONENT altpcierd_cdma_ast_rx_64
GENERIC (
   ECRC_FORWARD_CHECK   : INTEGER := 0
);
PORT (
   clk_in               : IN STD_LOGIC;
   srst                 : IN STD_LOGIC;
   rxdata               : IN STD_LOGIC_VECTOR(139 DOWNTO 0);
   rxdata_be            : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
   rx_stream_valid0     : IN STD_LOGIC;
   rx_stream_ready0     : OUT STD_LOGIC;
   rx_ack0              : IN STD_LOGIC;
   rx_ws0               : IN STD_LOGIC;
   rx_req0              : OUT STD_LOGIC;
   rx_desc0             : OUT STD_LOGIC_VECTOR(135 DOWNTO 0);
   rx_data0             : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
   rx_be0               : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
   rx_dv0               : OUT STD_LOGIC;
   rx_dfr0              : OUT STD_LOGIC;
   rx_ecrc_check_valid  : OUT STD_LOGIC;
   ecrc_bad_cnt         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
);
END COMPONENT;

COMPONENT altpcierd_cpld_rx_buffer IS
   GENERIC (
      MAX_NUMTAG             : INTEGER := 32;
      CHECK_RX_BUFFER_CPL    : INTEGER := 1
   );
   PORT (
      clk_in                 : IN STD_LOGIC;
      srst                   : IN STD_LOGIC;
      rx_ack0                : IN STD_LOGIC;
      rx_req0                : IN STD_LOGIC;
      rx_desc0               : IN STD_LOGIC_VECTOR(135 DOWNTO 0);
      tx_req0                : IN STD_LOGIC;
      tx_ack0                : IN STD_LOGIC;
      tx_desc0               : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      ko_cpl_spc_vc0         : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
      rx_buffer_cpl_max_dw   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      cpld_rx_buffer_ready   : OUT STD_LOGIC
   );
END COMPONENT;

COMPONENT altpcierd_cdma_app_icm IS
   GENERIC (
      USE_RCSLAVE            : INTEGER := 0;
      MAX_NUMTAG             : INTEGER := 32;
      AVALON_WADDR           : INTEGER := 12;
      AVALON_WDATA           : INTEGER := 64;
      MAX_PAYLOAD_SIZE_BYTE  : INTEGER := 256;
      BOARD_DEMO             : INTEGER := 0;
      USE_CREDIT_CTRL        : INTEGER := 0;
      CHECK_BUS_MASTER_ENA   : INTEGER := 0;
      CLK_250_APP            : INTEGER := 0;
      TL_SELECTION           : INTEGER := 0;
      TXCRED_WIDTH           : INTEGER := 36;
      RC_64BITS_ADDR         : INTEGER := 0;
      USE_MSI                : INTEGER := 1;
      AVALON_ST_128          : INTEGER := 0;
      AVALON_BYTE_WIDTH      : INTEGER := 8;
      CDMA_AST_RXWS_LATENCY  : INTEGER := 2
   );
   PORT (
      clk_in                 : IN STD_LOGIC;
      rstn                   : IN STD_LOGIC;
      cfg_busdev             : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
      cfg_devcsr             : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_prmcsr             : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_tcvcmap            : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      cfg_linkcsr            : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_msicsr             : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      ko_cpl_spc_vc0         : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
      cpl_pending            : OUT STD_LOGIC;
      cpl_err                : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      err_desc               : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      app_msi_ack            : IN STD_LOGIC;
      app_msi_req            : OUT STD_LOGIC;
      app_msi_tc             : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      app_msi_num            : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      app_int_sts            : OUT STD_LOGIC;
      app_int_ack            : IN STD_LOGIC;
      rx_ack0                : OUT STD_LOGIC;
      rx_mask0               : OUT STD_LOGIC;
      rx_ws0                 : OUT STD_LOGIC;
      rx_req0                : IN STD_LOGIC;
      rx_desc0               : IN STD_LOGIC_VECTOR(135 DOWNTO 0);
      rx_data0               : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      rx_be0                 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      rx_dv0                 : IN STD_LOGIC;
      rx_dfr0                : IN STD_LOGIC;
      rx_ecrc_bad_cnt        : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      tx_req0                : OUT STD_LOGIC;
      tx_ack0                : IN STD_LOGIC;
      tx_desc0               : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      tx_dv0                 : OUT STD_LOGIC;
      tx_dfr0                : OUT STD_LOGIC;
      tx_ws0                 : IN STD_LOGIC;
      tx_data0               : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      tx_err0                : OUT STD_LOGIC;
      tx_mask0               : IN STD_LOGIC;
      cpld_rx_buffer_ready   : IN STD_LOGIC;
      tx_cred0               : IN STD_LOGIC_VECTOR(TXCRED_WIDTH - 1 DOWNTO 0);
      rx_buffer_cpl_max_dw   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      tx_stream_ready0       : IN STD_LOGIC
   );
END COMPONENT;

   -- Receive section channel 0

   SIGNAL open_rx_retry0          : STD_LOGIC;
   SIGNAL open_rx_mask0           : STD_LOGIC;
   SIGNAL open_rx_be0             : STD_LOGIC_VECTOR(7 DOWNTO 0);

   SIGNAL rx_ack0                 : STD_LOGIC;
   SIGNAL rx_ws0                  : STD_LOGIC;
   SIGNAL rx_req0                 : STD_LOGIC;
   SIGNAL rx_desc0                : STD_LOGIC_VECTOR(135 DOWNTO 0);
   SIGNAL rx_data0                : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL rx_be0                  : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL rx_dv0                  : STD_LOGIC;
   SIGNAL rx_dfr0                 : STD_LOGIC;
   SIGNAL rx_ecrc_bad_cnt         : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL rxdata                  : STD_LOGIC_VECTOR(139 DOWNTO 0);
   SIGNAL rxdata_be               : STD_LOGIC_VECTOR(15 DOWNTO 0);      -- rx byte enables

   --transmit section channel 0
   SIGNAL tx_req0                 : STD_LOGIC;
   SIGNAL tx_mask0                : STD_LOGIC;
   SIGNAL tx_ack0                 : STD_LOGIC;
   SIGNAL tx_desc0                : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL tx_ws0                  : STD_LOGIC;
   SIGNAL tx_err0                 : STD_LOGIC;
   SIGNAL tx_dv0                  : STD_LOGIC;
   SIGNAL tx_dfr0                 : STD_LOGIC;
   SIGNAL tx_data0                : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL txdata                  : STD_LOGIC_VECTOR(132 DOWNTO 0);

   SIGNAL app_msi_req_int         : STD_LOGIC;
   SIGNAL app_msi_tc_int          : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL app_msi_num_int         : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL app_msi_ack_int         : STD_LOGIC;

   SIGNAL app_msi_req_synced      : STD_LOGIC;
   SIGNAL tx_fifo_empty_timer     : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL tx_local_fifo_empty     : STD_LOGIC;
   SIGNAL app_msi_req_synced_n    : STD_LOGIC;
   SIGNAL tx_fifo_empty_timer_n   : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL msi_req_state           : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL msi_req_state_n         : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL app_msi_ack_reg         : STD_LOGIC;

   --------------------------------------------------------------
   --    XHDL signal for translation
   --------------------------------------------------------------
   SIGNAL xhdl_zero_byte          : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL xhdl_zero_word          : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL xhdl_zero_dword         : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL xhdl_zero_qword         : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL xhdl_zero_dqword        : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL xhdl_one_byte           : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL xhdl_one_word           : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL xhdl_one_dword          : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL xhdl_one_qword          : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL xhdl_one_dqword         : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL xhdl_open_dqword        : STD_LOGIC_VECTOR(127 DOWNTO 0);

   --------------------------------------------------------------
   --    MSI Streaming Interface
   --       - generates streaming interface signals
   --------------------------------------------------------------
   SIGNAL app_msi_ack_dd          : STD_LOGIC;

   SIGNAL srst                    : STD_LOGIC;

   --------------------------------------------------------------
   --    RX buffer cpld credit tracking
   --------------------------------------------------------------
   SIGNAL cpld_rx_buffer_ready    : STD_LOGIC;
   SIGNAL rx_buffer_cpl_max_dw    : STD_LOGIC_VECTOR(15 DOWNTO 0);

   -- Declare intermediate signals for referenced outputs
   SIGNAL tx_stream_data0_0_xhdl8 : STD_LOGIC_VECTOR(74 DOWNTO 0);
   SIGNAL tx_stream_valid0_xhdl9  : STD_LOGIC;
   SIGNAL rx_stream_ready0_xhdl7  : STD_LOGIC;
   SIGNAL rx_stream_mask0_xhdl6   : STD_LOGIC;
   SIGNAL msi_stream_data0_xhdl4  : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL msi_stream_valid0_xhdl5 : STD_LOGIC;
   SIGNAL app_int_sts_xhdl0       : STD_LOGIC;
   SIGNAL cpl_pending_xhdl2       : STD_LOGIC;
   SIGNAL cpl_err_xhdl1           : STD_LOGIC_VECTOR(6 DOWNTO 0);
   SIGNAL err_desc_xhdl3          : STD_LOGIC_VECTOR(127 DOWNTO 0);

   SIGNAL tx_stream_ready0_reg       : STD_LOGIC;
   SIGNAL rx_stream_data0_0_reg      : STD_LOGIC_VECTOR(81 DOWNTO 0);
   SIGNAL rx_stream_data0_1_reg      : STD_LOGIC_VECTOR(81 DOWNTO 0);
   SIGNAL rx_stream_valid0_reg       : STD_LOGIC;

   SIGNAL rx_stream_data0_0_reg2      : STD_LOGIC_VECTOR(81 DOWNTO 0);
   SIGNAL rx_stream_data0_1_reg2      : STD_LOGIC_VECTOR(81 DOWNTO 0);
   SIGNAL rx_stream_valid0_reg2       : STD_LOGIC;


BEGIN
   -- Drive referenced outputs
   tx_stream_data0_0 <= tx_stream_data0_0_xhdl8;
   tx_stream_valid0 <= tx_stream_valid0_xhdl9;
   rx_stream_ready0 <= rx_stream_ready0_xhdl7;
   rx_stream_mask0 <= rx_stream_mask0_xhdl6;
   msi_stream_data0 <= msi_stream_data0_xhdl4;
   msi_stream_valid0 <= msi_stream_valid0_xhdl5;
   app_int_sts       <= app_int_sts_xhdl0;
   cpl_pending       <= cpl_pending_xhdl2;
   cpl_err           <= cpl_err_xhdl1;
   err_desc          <= err_desc_xhdl3;

   xhdl_zero_byte    <= (others=>'0');
   xhdl_zero_word    <= (others=>'0');
   xhdl_zero_dword   <= (others=>'0');
   xhdl_zero_qword   <= (others=>'0');
   xhdl_zero_dqword  <= (others=>'0');
   xhdl_one_byte     <= xhdl_zero_byte   (7 downto 1)   & '1';
   xhdl_one_word     <= xhdl_zero_word   (15 downto 1)  & '1';
   xhdl_one_dword    <= xhdl_zero_dword  (31 downto 1)  & '1';
   xhdl_one_qword    <= xhdl_zero_qword  (63 downto 1)  & '1';
   xhdl_one_dqword   <= xhdl_zero_dqword (127 downto 1) & '1';

   PROCESS (clk_in, rstn)
   BEGIN
      IF (rstn = '0') THEN
         srst <= '1';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         srst <= '0';
      END IF;
   END PROCESS;


   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         tx_stream_ready0_reg      <= tx_stream_ready0      ;
         rx_stream_data0_0_reg2     <= rx_stream_data0_0     ;
         rx_stream_data0_1_reg2     <= rx_stream_data0_1     ;
         rx_stream_valid0_reg2      <= rx_stream_valid0      ;
      END IF;

   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         rx_stream_data0_0_reg     <= rx_stream_data0_0_reg2     ;
         rx_stream_data0_1_reg     <= rx_stream_data0_1_reg2     ;
         rx_stream_valid0_reg      <= rx_stream_valid0_reg2      ;
      END IF;

   END PROCESS;

   altpcierd_cpld_rx_buffer_i : altpcierd_cpld_rx_buffer
      GENERIC MAP (
         CHECK_RX_BUFFER_CPL  => CHECK_RX_BUFFER_CPL,
         MAX_NUMTAG           => MAX_NUMTAG
      )
      PORT MAP (
         clk_in                => clk_in,
         srst                  => srst,
         rx_req0               => rx_req0,
         rx_ack0               => rx_ack0,
         rx_desc0              => rx_desc0,
         tx_req0               => tx_req0,
         tx_ack0               => tx_ack0,
         tx_desc0              => tx_desc0,
         ko_cpl_spc_vc0        => ko_cpl_spc_vc0,
         rx_buffer_cpl_max_dw  => rx_buffer_cpl_max_dw,
         cpld_rx_buffer_ready  => cpld_rx_buffer_ready
      );

   altpcierd_cdma_ast_msi_i : altpcierd_cdma_ast_msi
      PORT MAP (
         clk_in        => clk_in,
         rstn          => rstn,
         app_msi_req   => app_msi_req_int,
         app_msi_ack   => app_msi_ack_dd,
         app_msi_tc    => app_msi_tc_int,
         app_msi_num   => app_msi_num_int,
         stream_ready  => msi_stream_ready0,
         stream_data   => msi_stream_data0_xhdl4,
         stream_valid  => msi_stream_valid0_xhdl5
      );

   xhdl10 : IF ((AVALON_ST_128 = 0) AND (TL_SELECTION = 6)) GENERATE

      --------------------------------------------------------------
      --    TX Streaming Interface
      --       - generates streaming interface signals
      --       - arbitrates between master and slave requests
      --------------------------------------------------------------

      tx_stream_data0_0_xhdl8(74) <= txdata(132);       --err
      tx_stream_data0_0_xhdl8(73) <= txdata(131);       --sop
      tx_stream_data0_0_xhdl8(72) <= txdata(128);       --eop
      tx_stream_data0_0_xhdl8(71 DOWNTO 64) <= "00000000";

      tx_stream_data0_1(74) <= txdata(132);
      tx_stream_data0_1(73) <= txdata(131);
      tx_stream_data0_1(72) <= txdata(128);
      tx_stream_data0_1(71 DOWNTO 64) <= "00000000";

      tx_stream_data0_0_xhdl8(63 DOWNTO 0) <= (txdata(95 DOWNTO 64) & txdata(127 DOWNTO 96));
      tx_stream_data0_1(63 DOWNTO 0) <= (txdata(95 DOWNTO 64) & txdata(127 DOWNTO 96));



      altpcierd_cdma_ast_tx_i_64 : altpcierd_cdma_ast_tx_64
         GENERIC MAP (
            ecrc_forward_gener  => ECRC_FORWARD_GENER
         )
         PORT MAP (
            clk_in            => clk_in,
            srst              => srst,
            -- Avalon-ST
            txdata            => txdata,
            tx_stream_ready0  => tx_stream_ready0_reg,
            tx_stream_valid0  => tx_stream_valid0_xhdl9,
            -- Application iterface
            tx_req0           => tx_req0,
            tx_ack0           => tx_ack0,
            tx_desc0          => tx_desc0,
            tx_data0          => tx_data0,
            tx_dfr0           => tx_dfr0,
            tx_dv0            => tx_dv0,
            tx_err0           => tx_err0,
            tx_ws0            => tx_ws0,
            tx_fifo_empty     => tx_local_fifo_empty
         );

      --------------------------------------------------------------
      --    RX Streaming Interface
      --       - generates streaming interface signals
      --       - routes data to master/slave
      --------------------------------------------------------------
      rxdata_be <= (rx_stream_data0_0_reg(77 DOWNTO 74) & rx_stream_data0_0_reg(81 DOWNTO 78) & rx_stream_data0_1_reg(77 DOWNTO 74) & rx_stream_data0_1_reg(81 DOWNTO 78));

      --rx_sop0 [139]
      --rx_eop0 [138]
      --rx_eop1 [137]
      --rx_eop1 [136]
      --bar     [135:128]          |  Aligned | Un-aligned 3 DW | UN-aligned 4 DW
      -- rx_desc[127:96]  aka H0  |   D0     |  -  -> D1       |     -> D3
      -- rx_desc[95:64 ]  aka H1  |   D1     |  -  -> D2       |  D0 -> D4
      rxdata <= (rx_stream_data0_0_reg(73) & rx_stream_data0_0_reg(72) & rx_stream_data0_1_reg(73) & rx_stream_data0_1_reg(72) & rx_stream_data0_0_reg(71 DOWNTO 64) & rx_stream_data0_0_reg(31 DOWNTO 0) & rx_stream_data0_0_reg(63 DOWNTO 32) & rx_stream_data0_1_reg(31 DOWNTO 0) & rx_stream_data0_1_reg(63 DOWNTO 32));        -- rx_desc[63:32 ]  aka H2  |   D2     |  -  -> D3       |  D1 -> D5
      -- rx_desc[31:0  ]  aka H4  |   D3     |  D0 -> D4       |  D2 -> D6


      altpcierd_cdma_ast_rx_i_64 : altpcierd_cdma_ast_rx_64
         GENERIC MAP (
            ecrc_forward_check  => ECRC_FORWARD_CHECK
         )
         PORT MAP (
            clk_in            => clk_in,
            srst              => srst,

            rx_stream_ready0  => rx_stream_ready0_xhdl7,
            rx_stream_valid0  => rx_stream_valid0_reg,
            rxdata            => rxdata,
            rxdata_be         => rxdata_be(15 downto 0),

            rx_req0           => rx_req0,
            rx_ack0           => rx_ack0,
            rx_data0          => rx_data0(63 DOWNTO 0),
            rx_be0            => rx_be0(7 DOWNTO 0),
            rx_desc0          => rx_desc0,
            rx_dfr0           => rx_dfr0,
            rx_dv0            => rx_dv0,
            rx_ws0            => rx_ws0,
            ecrc_bad_cnt      => rx_ecrc_bad_cnt
         );

   END GENERATE;

   xhdl11 : IF (TL_SELECTION = 0) GENERATE

      --------------------------------------------------------------
      --    TX Streaming Interface
      --       - generates streaming interface signals
      --       - arbitrates between master and slave requests
      --------------------------------------------------------------
      -- rx_req is generated one clk cycle ahead of
      -- other control signals.
      -- re-align here.


      altpcierd_cdma_ast_tx_i : altpcierd_cdma_ast_tx
         GENERIC MAP (
            tl_selection  => TL_SELECTION
         )
         PORT MAP (
            clk_in            => clk_in,        --TODO Use srst
            rstn              => rstn,
            tx_stream_data0   => tx_stream_data0_0_xhdl8,
            tx_stream_ready0  => tx_stream_ready0,
            tx_stream_valid0  => tx_stream_valid0_xhdl9,

            tx_req0           => tx_req0,
            tx_ack0           => tx_ack0,
            tx_desc0          => tx_desc0,
            tx_data0          => tx_data0(63 DOWNTO 0),
            tx_dfr0           => tx_dfr0,
            tx_dv0            => tx_dv0,
            tx_err0           => tx_err0,
            tx_ws0            => tx_ws0
         );

      --------------------------------------------------------------
      --    RX Streaming Interface
      --       - generates streaming interface signals
      --       - routes data to master/slave
      --------------------------------------------------------------


      altpcierd_cdma_ast_rx_i : altpcierd_cdma_ast_rx
         GENERIC MAP (
            tl_selection  => TL_SELECTION
         )
         PORT MAP (
            clk_in            => clk_in,
            rstn              => rstn,      --TODO Use srst

            rx_stream_ready0  => rx_stream_ready0_xhdl7,
            rx_stream_valid0  => rx_stream_valid0,
            rx_stream_data0   => rx_stream_data0_0,

            rx_req0           => rx_req0,
            rx_ack0           => rx_ack0,
            rx_data0          => rx_data0(63 DOWNTO 0),
            rx_desc0          => rx_desc0,
            rx_dfr0           => rx_dfr0,
            rx_dv0            => rx_dv0,
            rx_ws0            => rx_ws0,
            rx_be0            => rx_be0(7 DOWNTO 0),
            ecrc_bad_cnt      => rx_ecrc_bad_cnt
         );

   END GENERATE;

   xhdl12 : IF (AVALON_ST_128 = 1) GENERATE
      --------------------------------------------------------------
      --    TX Streaming Interface
      --       - generates streaming interface signals
      --       - arbitrates between master and slave requests
      --------------------------------------------------------------
      -- rx_req is generated one clk cycle ahead of
      -- other control signals.
      -- re-align here.

      tx_stream_data0_0_xhdl8(74) <= txdata(132);       --err
      tx_stream_data0_0_xhdl8(73) <= txdata(131);       --sop
      tx_stream_data0_0_xhdl8(72) <= txdata(130);       --eop
      tx_stream_data0_0_xhdl8(71 DOWNTO 64) <= "00000000";

      tx_stream_data0_1(74) <= txdata(132);     --err
      tx_stream_data0_1(73) <= txdata(129);     --sop
      tx_stream_data0_1(72) <= txdata(128);     --eop
      tx_stream_data0_1(71 DOWNTO 64) <= "00000000";

      tx_stream_data0_0_xhdl8(63 DOWNTO 0) <= (txdata(95 DOWNTO 64) & txdata(127 DOWNTO 96));
      tx_stream_data0_1(63 DOWNTO 0) <= (txdata(31 DOWNTO 0) & txdata(63 DOWNTO 32));



      altpcierd_cdma_ast_tx_i_128 : altpcierd_cdma_ast_tx_128
         GENERIC MAP (
            ecrc_forward_gener  => ECRC_FORWARD_GENER
         )
         PORT MAP (
            clk_in            => clk_in,
            srst              => srst,
            -- Avalon-ST
            txdata            => txdata,
            tx_stream_ready0  => tx_stream_ready0_reg,
            tx_stream_valid0  => tx_stream_valid0_xhdl9,
            -- Application iterface
            tx_req0           => tx_req0,
            tx_ack0           => tx_ack0,
            tx_desc0          => tx_desc0,
            tx_data0          => tx_data0,
            tx_dfr0           => tx_dfr0,
            tx_dv0            => tx_dv0,
            tx_err0           => tx_err0,
            tx_ws0            => tx_ws0,
            tx_fifo_empty     => tx_local_fifo_empty
         );

      --------------------------------------------------------------
      --    RX Streaming Interface
      --       - generates streaming interface signals
      --       - routes data to master/slave
      --------------------------------------------------------------
      rxdata_be <= (rx_stream_data0_0_reg(77 DOWNTO 74) & rx_stream_data0_0_reg(81 DOWNTO 78) & rx_stream_data0_1_reg(77 DOWNTO 74) & rx_stream_data0_1_reg(81 DOWNTO 78));
      --rx_sop0 [139]
      --rx_eop0 [138]
      --rx_eop1 [137]
      --rx_eop1 [136]
      --bar     [135:128]          |  Aligned | Un-aligned 3 DW | UN-aligned 4 DW
      -- rx_desc[127:96]  aka H0  |   D0     |  -  -> D1       |     -> D3
      -- rx_desc[95:64 ]  aka H1  |   D1     |  -  -> D2       |  D0 -> D4
      rxdata <= (rx_stream_data0_0_reg(73) & rx_stream_data0_0_reg(72) & rx_stream_data0_1_reg(73) & rx_stream_data0_1_reg(72) & rx_stream_data0_0_reg(71 DOWNTO 64) & rx_stream_data0_0_reg(31 DOWNTO 0) & rx_stream_data0_0_reg(63 DOWNTO 32) & rx_stream_data0_1_reg(31 DOWNTO 0) & rx_stream_data0_1_reg(63 DOWNTO 32));        -- rx_desc[63:32 ]  aka H2  |   D2     |  -  -> D3       |  D1 -> D5
      -- rx_desc[31:0  ]  aka H4  |   D3     |  D0 -> D4       |  D2 -> D6


      altpcierd_cdma_ast_rx_i_128 : altpcierd_cdma_ast_rx_128
         GENERIC MAP (
            ecrc_forward_check  => ECRC_FORWARD_CHECK
         )
         PORT MAP (
            clk_in            => clk_in,
            srst              => srst,

            rx_stream_ready0  => rx_stream_ready0_xhdl7,
            rx_stream_valid0  => rx_stream_valid0_reg,
            rxdata            => rxdata,
            rxdata_be         => rxdata_be,

            rx_req0           => rx_req0,
            rx_ack0           => rx_ack0,
            rx_data0          => rx_data0,
            rx_be0            => rx_be0,
            rx_desc0          => rx_desc0,
            rx_dfr0           => rx_dfr0,
            rx_dv0            => rx_dv0,
            rx_ws0            => rx_ws0,
            ecrc_bad_cnt      => rx_ecrc_bad_cnt
         );
   END GENERATE;
   --------------------------------------------------------------
   --    Chaining DMA application interface
   --------------------------------------------------------------
   -- This parameter is specific to the implementation of the
   -- Avalon streaming interface in the Chaining DMA design example.
   -- It specifies the cdma_ast_rx's response time to an rx_ws assertion.
   -- i.e. rx_data responds "CDMA_AST_RXWS_LATENCY" clock cycles after rx_ws asserts.

   aer_msi_num <= "00000";
   pm_data <= "0000000000";
   pex_msi_num <= "00000";

   app_msi_ack_int <= app_msi_ack_dd WHEN (TL_SELECTION = 0) ELSE
                      app_msi_ack;
   app_msi_req <= '0' WHEN (TL_SELECTION = 0) ELSE
                  app_msi_req_synced;
   app_msi_tc <= "000" WHEN (TL_SELECTION = 0) ELSE
                 app_msi_tc_int;
   app_msi_num <= "00000" WHEN (TL_SELECTION = 0) ELSE
                  app_msi_num_int;
   tx_mask0 <= tx_stream_mask0 WHEN (TL_SELECTION = 0) ELSE
               '0';


   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            app_msi_req_synced <= '0';
            tx_fifo_empty_timer <= "0000";
            msi_req_state <= MSI_MON_IDLE;
            app_msi_ack_reg <= '0';
         ELSE
            app_msi_req_synced <= app_msi_req_synced_n;
            tx_fifo_empty_timer <= tx_fifo_empty_timer_n;
            msi_req_state <= msi_req_state_n;
            app_msi_ack_reg <= app_msi_ack;
         END IF;
      END IF;
   END PROCESS;
   PROCESS (msi_req_state,  app_msi_req_int, tx_local_fifo_empty,  tx_fifo_empty_timer, tx_stream_fifo_empty0,  app_msi_req_synced, app_msi_ack_reg)
   BEGIN
      CASE msi_req_state IS
         WHEN MSI_MON_IDLE =>
            app_msi_req_synced_n <= '0';
            IF (app_msi_req_int = '1') THEN
               msi_req_state_n <= MSI_WAIT_LOCAL_EMPTY;
            ELSE
               msi_req_state_n <= msi_req_state;
            END IF;
            tx_fifo_empty_timer_n <= tx_fifo_empty_timer;
         WHEN MSI_WAIT_LOCAL_EMPTY =>
            tx_fifo_empty_timer_n <= "0000";
            IF (tx_local_fifo_empty = '1') THEN
               msi_req_state_n <= MSI_WAIT_LATENCY;
            ELSE
               msi_req_state_n <= msi_req_state;
            END IF;
            app_msi_req_synced_n <= app_msi_req_synced;
         WHEN MSI_WAIT_LATENCY =>
            tx_fifo_empty_timer_n <= tx_fifo_empty_timer + "0001";
            IF (tx_fifo_empty_timer(3) = '1') THEN
               msi_req_state_n <= MSI_WAIT_CORE_EMPTY;
            ELSE
               msi_req_state_n <= msi_req_state;
            END IF;
            app_msi_req_synced_n <= app_msi_req_synced;
         WHEN MSI_WAIT_CORE_EMPTY =>
           tx_fifo_empty_timer_n <= tx_fifo_empty_timer;
            IF (tx_stream_fifo_empty0 = '1') THEN
               app_msi_req_synced_n <= '1';
               msi_req_state_n <= MSI_WAIT_CORE_ACK;
            ELSE
               app_msi_req_synced_n <= app_msi_req_synced;
               msi_req_state_n <= msi_req_state;
            END IF;
           tx_fifo_empty_timer_n <= tx_fifo_empty_timer;
         WHEN MSI_WAIT_CORE_ACK =>
            IF (app_msi_ack_reg = '1') THEN
               msi_req_state_n <= MSI_MON_IDLE;
               app_msi_req_synced_n <= '0';
            ELSE
               msi_req_state_n <= msi_req_state;
               app_msi_req_synced_n <= app_msi_req_synced;
            END IF;
            tx_fifo_empty_timer_n <= tx_fifo_empty_timer;
         WHEN OTHERS =>
            app_msi_req_synced_n <= app_msi_req_synced;
            msi_req_state_n <= msi_req_state;
            tx_fifo_empty_timer_n <= tx_fifo_empty_timer;
      END CASE;
   END PROCESS;

   xhdl13 : IF (AVALON_ST_128 = 0) GENERATE
      rx_data0(127 DOWNTO 64) <= (others=>'0');
      rx_be0(15 DOWNTO 8) <= "00000000";
   END GENERATE;

   chaining_dma_arb : altpcierd_cdma_app_icm
      GENERIC MAP (
         AVALON_WADDR           => AVALON_WADDR,
         AVALON_WDATA           => AVALON_WDATA,
         MAX_NUMTAG             => MAX_NUMTAG,
         MAX_PAYLOAD_SIZE_BYTE  => MAX_PAYLOAD_SIZE_BYTE,
         BOARD_DEMO             => BOARD_DEMO,
         USE_CREDIT_CTRL        => USE_CREDIT_CTRL,
         USE_RCSLAVE            => USE_RCSLAVE,
         USE_MSI                => USE_MSI,
         CLK_250_APP            => CLK_250_APP,
         RC_64BITS_ADDR         => RC_64BITS_ADDR,
         CHECK_BUS_MASTER_ENA   => CHECK_BUS_MASTER_ENA,
         TL_SELECTION           => TL_SELECTION,
         AVALON_ST_128          => AVALON_ST_128,
         AVALON_BYTE_WIDTH      => AVALON_BYTE_WIDTH ,
         TXCRED_WIDTH           => TXCRED_WIDTH,
         CDMA_AST_RXWS_LATENCY  => CDMA_AST_RXWS_LATENCY
      )
      PORT MAP (
         app_msi_ack           => app_msi_ack_int,
         app_msi_req           => app_msi_req_int,
         app_msi_num           => app_msi_num_int,
         app_msi_tc            => app_msi_tc_int,

         app_int_sts           => app_int_sts_xhdl0,
         app_int_ack           => app_int_ack,

         cfg_busdev            => cfg_busdev,
         cfg_devcsr            => cfg_devcsr,
         cfg_prmcsr            => cfg_prmcsr,
         cfg_linkcsr           => cfg_linkcsr,
         cfg_tcvcmap           => cfg_tcvcmap,
         cfg_msicsr            => cfg_msicsr,

         cpl_err               => cpl_err_xhdl1,
         err_desc              => err_desc_xhdl3,
         cpl_pending           => cpl_pending_xhdl2,
         ko_cpl_spc_vc0        => ko_cpl_spc_vc0,
         tx_mask0              => tx_mask0,
         cpld_rx_buffer_ready  => cpld_rx_buffer_ready,
         tx_cred0              => tx_stream_cred0,
         tx_stream_ready0      => tx_stream_ready0,

         clk_in                => clk_in,
         rstn                  => rstn,

         rx_req0               => rx_req0,
         rx_ack0               => rx_ack0,
         rx_data0              => rx_data0,
         rx_be0                => rx_be0,
         rx_desc0              => rx_desc0,
         rx_dfr0               => rx_dfr0,
         rx_dv0                => rx_dv0,
         rx_ws0                => rx_ws0,
         rx_mask0              => rx_stream_mask0_xhdl6,
         rx_ecrc_bad_cnt       => rx_ecrc_bad_cnt,

         rx_buffer_cpl_max_dw  => rx_buffer_cpl_max_dw,
         tx_req0               => tx_req0,
         tx_ack0               => tx_ack0,
         tx_desc0              => tx_desc0,
         tx_data0              => tx_data0,
         tx_dfr0               => tx_dfr0,
         tx_dv0                => tx_dv0,
         tx_err0               => tx_err0,
         tx_ws0                => tx_ws0
      );

END ARCHITECTURE altpcie;
