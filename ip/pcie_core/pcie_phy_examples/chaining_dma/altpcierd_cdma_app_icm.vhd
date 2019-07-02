LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

-- /**
--  * This Verilog HDL file is used for simulation and synthesis in
--  * the chaining DMA design example. It arbitrates PCI Express packets for
--  * the modules altpcierd_dma_dt (read or write) and altpcierd_rc_slave. It
--  * instantiates the Endpoint memory used for the DMA read and write transfer.
--  */
-- synthesis translate_on
-------------------------------------------------------------------------------
-- Title         : PCI Express Reference Design Example Application
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcierd_cdma_app_icm.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This is the complete example application for the PCI Express Reference
-- Design. This has all of the application logic for the example.
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
-- Module parameters:
--   USE_RCSLAVE     : When USE_RCSLAVE is set an additionnal module (~1000 LE) is added to
--   the design to provide instrumentation to the PCI Express Chained DMA design
--   such as Performance counter, debug register and EP memory Write a Read by
--   bypasssing the DMA engine.
--

ENTITY altpcierd_cdma_app_icm IS
   GENERIC (
      CHECK_BUS_MASTER_ENA   : INTEGER := 0;
      USE_RCSLAVE            : INTEGER := 0;
      MAX_NUMTAG             : INTEGER := 32;
      AVALON_WADDR           : INTEGER := 12;
      AVALON_WDATA           : INTEGER := 64;
      AVALON_BYTE_WIDTH      : INTEGER := 8;
      MAX_PAYLOAD_SIZE_BYTE  : INTEGER := 256;
      BOARD_DEMO             : INTEGER := 0;
      USE_CREDIT_CTRL        : INTEGER := 0;
      CLK_250_APP            : INTEGER := 0;
      TL_SELECTION           : INTEGER := 0;
      TXCRED_WIDTH           : INTEGER := 36;
      RC_64BITS_ADDR         : INTEGER := 0;        --When 1 use 64 bit tx_desc address and not 32
      USE_MSI                : INTEGER := 1;        -- When 1, tx_arbitration uses tx_cred
      AVALON_ST_128          : INTEGER := 0;
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
END ENTITY altpcierd_cdma_app_icm;
ARCHITECTURE altpcie OF altpcierd_cdma_app_icm IS


   FUNCTION get_numwords (
      val      : integer) RETURN integer IS

      VARIABLE rtn      : integer:=1;
   BEGIN
        rtn:=1    ;
        FOR i IN 1 TO val LOOP
            rtn := 2*rtn;
        END loop;
        RETURN rtn;
   END get_numwords;

   FUNCTION to_stdlogic (
   val      : IN boolean) RETURN std_logic IS
   BEGIN
      IF (val) THEN
         RETURN('1');
      ELSE
         RETURN('0');
      END IF;
   END to_stdlogic;


   FUNCTION TO_STDLOGICVECTOR (
      val      : IN integer;
      len      : IN integer) RETURN std_logic_vector IS

      VARIABLE rtn : std_logic_vector(len-1 DOWNTO 0):=(OTHERS => '0');
      VARIABLE num : integer := val;
      VARIABLE r   : integer;
   BEGIN
      FOR index IN 0 TO len-1 LOOP
         r := num rem 2;
         num := num/2;
         IF (r = 1) THEN
            rtn(index) := '1';
         ELSE
            rtn(index) := '0';
         END IF;
      END LOOP;
      RETURN(rtn);
   END TO_STDLOGICVECTOR;

   CONSTANT NUMWORDS_AVALON_WADDR  : INTEGER := get_numwords(AVALON_WADDR);
   CONSTANT FIFO_WIDTHU            : INTEGER := 6;
   CONSTANT FIFO_DEPTH             : INTEGER := 64;
   CONSTANT RC_SLAVE_USETAG        : INTEGER := 0;
   CONSTANT DMA_READ_PRIORITY      : INTEGER := 1;
   CONSTANT DMA_WRITE_PRIORITY     : INTEGER := 1;
   CONSTANT TIME_2                 : INTEGER :=CLK_250_APP+1;
   CONSTANT CNT_50MS               : STD_LOGIC_VECTOR(23 DOWNTO 0) := TO_STDLOGICVECTOR( (6250000 * (CLK_250_APP+1)),24);
   CONSTANT ONE_24B                : STD_LOGIC_VECTOR(23 DOWNTO 0) := TO_STDLOGICVECTOR(1,24);

   COMPONENT altpcierd_rc_slave IS
      GENERIC (
         AVALON_WDATA           : INTEGER := 128;
         AVALON_WADDR           : INTEGER := 12;
         AVALON_ST_128          : INTEGER := 0;
         AVALON_BYTE_WIDTH      : INTEGER := 16
      );
      PORT (
      clk_in                   : IN STD_LOGIC;
      rstn                     : IN STD_LOGIC;
      dma_rd_prg_rddata        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      dma_wr_prg_rddata        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      dma_prg_addr             : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      dma_prg_wrdata           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      dma_wr_prg_wrena         : OUT STD_LOGIC;
      dma_rd_prg_wrena         : OUT STD_LOGIC;

      mem_wr_ena               : OUT STD_LOGIC;     -- rename this to write_downstream
      mem_rd_ena               : OUT STD_LOGIC;

      rx_ecrc_bad_cnt          : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      read_dma_status          : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      write_dma_status         : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      cfg_busdev               : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
      rx_req                   : IN STD_LOGIC;
      rx_desc                  : IN STD_LOGIC_VECTOR(135 DOWNTO 0);
      rx_data                  : IN STD_LOGIC_VECTOR(AVALON_WDATA-1 DOWNTO 0);
      rx_be                    : IN STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH-1 DOWNTO 0);
      rx_dv                    : IN STD_LOGIC;
      rx_dfr                   : IN STD_LOGIC;
      rx_ack                   : OUT STD_LOGIC;
      rx_ws                    : OUT STD_LOGIC;
      tx_ws                    : IN STD_LOGIC;
      tx_ack                   : IN STD_LOGIC;
      tx_data                  : OUT STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      tx_desc                  : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      tx_dfr                   : OUT STD_LOGIC;
      tx_dv                    : OUT STD_LOGIC;
      tx_req                   : OUT STD_LOGIC;
      tx_busy                  : OUT STD_LOGIC;
      tx_ready                 : OUT STD_LOGIC;
      tx_sel                   : IN STD_LOGIC;
      mem_rd_data_valid        : IN STD_LOGIC;
      mem_rd_addr              : OUT STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
      mem_rd_data              : IN STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      mem_wr_addr              : OUT STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
      mem_wr_data              : OUT STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      sel_epmem                : OUT STD_LOGIC;
      mem_wr_be                : OUT STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0)
      );
   END COMPONENT;


   COMPONENT altpcierd_rxtx_pipe IS
      GENERIC (
         TXCRED_WIDTH           : INTEGER := 22
      );
      PORT (
      clk_in                   : IN STD_LOGIC;
      rstn                     : IN STD_LOGIC;
      cfg_maxpload             : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      cfg_maxrdreq             : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      cfg_busdev               : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
      cfg_devcsr               : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_tcvcmap              : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      cfg_linkcsr              : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_msicsr               : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      cfg_link_negociated      : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      ko_cpl_spc_vc0           : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
      tx_cred0                 : IN STD_LOGIC_VECTOR(TXCRED_WIDTH - 1 DOWNTO 0);
      tx_mask0                 : IN STD_LOGIC;
      tx_stream_ready0         : IN STD_LOGIC;
      cfg_maxpload_reg         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      cfg_maxrdreq_reg         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      cfg_link_negociated_reg  : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      cfg_busdev_reg           : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
      cfg_devcsr_reg           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_tcvcmap_reg          : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
      cfg_linkcsr_reg          : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_msicsr_reg           : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      ko_cpl_spc_vc0_reg       : OUT STD_LOGIC_VECTOR(19 DOWNTO 0);
      tx_mask_reg              : OUT STD_LOGIC;
      tx_stream_ready0_reg     : OUT STD_LOGIC;
      tx_cred0_reg             : OUT STD_LOGIC_VECTOR(TXCRED_WIDTH - 1 DOWNTO 0)
      );
   END COMPONENT;

   COMPONENT altpcierd_dma_dt IS
      GENERIC (
         DIRECTION              : INTEGER := 1;
         MAX_NUMTAG             : INTEGER := 32;
         FIFO_WIDTHU            : INTEGER := 8;
         FIFO_DEPTH             : INTEGER := 256;
         TXCRED_WIDTH           : INTEGER := 36;
         RC_SLAVE_USETAG        : INTEGER := 0;
         USE_RCSLAVE            : INTEGER := 0;
         MAX_PAYLOAD            : INTEGER := 256;
         AVALON_WADDR           : INTEGER := 12;
         AVALON_WDATA           : INTEGER := 64;
         AVALON_ST_128          : INTEGER := 0;
         BOARD_DEMO             : INTEGER := 0;
         USE_MSI                : INTEGER := 1;
         USE_CREDIT_CTRL        : INTEGER := 1;
         RC_64BITS_ADDR         : INTEGER := 0;
         TL_SELECTION           : INTEGER := 0;
         DISPLAY_SM             : INTEGER := 1;
         DT_EP_ADDR_SPEC        : INTEGER := 0;
         AVALON_BYTE_WIDTH      : INTEGER := 8;
         CDMA_AST_RXWS_LATENCY  : INTEGER := 2
      );
      PORT (
         clk_in                 : IN STD_LOGIC;
         rstn                   : IN STD_LOGIC;

         dma_prg_wrdata         : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
         dma_prg_addr           : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
         dma_prg_wrena          : IN STD_LOGIC;
         dma_prg_rddata         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
         dma_status             : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);

         rx_req                 : IN STD_LOGIC;
         rx_req_p0              : IN STD_LOGIC;
         rx_req_p1              : IN STD_LOGIC;
         rx_ack                 : OUT STD_LOGIC;
         rx_ws                  : OUT STD_LOGIC;
         rx_desc                : IN STD_LOGIC_VECTOR(135 DOWNTO 0);
         rx_data                : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
         rx_be                  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         rx_dv                  : IN STD_LOGIC;
         rx_dfr                 : IN STD_LOGIC;
         rx_buffer_cpl_max_dw   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         tx_req                 : OUT STD_LOGIC;
         tx_ack                 : IN STD_LOGIC;
         tx_desc                : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
         tx_ws                  : IN STD_LOGIC;
         tx_err                 : OUT STD_LOGIC;
         tx_dv                  : OUT STD_LOGIC;
         tx_dfr                 : OUT STD_LOGIC;
         tx_data                : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
         tx_sel_descriptor      : IN STD_LOGIC;
         tx_busy_descriptor     : OUT STD_LOGIC;
         tx_ready_descriptor    : OUT STD_LOGIC;
         tx_sel_requester       : IN STD_LOGIC;
         tx_busy_requester      : OUT STD_LOGIC;
         tx_ready_requester     : OUT STD_LOGIC;
         tx_ready_other_dma     : IN STD_LOGIC;
         tx_cred                : IN STD_LOGIC_VECTOR(TXCRED_WIDTH - 1 DOWNTO 0);
         app_msi_ack            : IN STD_LOGIC;
         app_msi_req            : OUT STD_LOGIC;
         app_msi_tc             : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
         app_msi_num            : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
         msi_sel                : IN STD_LOGIC;
         msi_ready              : OUT STD_LOGIC;
         msi_busy               : OUT STD_LOGIC;
         cfg_maxpload           : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
         cfg_maxrdreq           : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
         cfg_maxpload_dw        : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         cfg_maxrdreq_dw        : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         cfg_busdev             : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
         cfg_link_negociated    : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
         write_data             : OUT STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
         write_address          : OUT STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
         write                  : OUT STD_LOGIC;
         write_wait             : OUT STD_LOGIC;
         write_byteena          : OUT STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0);
         read_data              : IN STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
         read_address           : OUT STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
         read                   : OUT STD_LOGIC;
         read_wait              : OUT STD_LOGIC;
         dma_sm                 : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
         cpl_pending            : OUT STD_LOGIC;
         descriptor_mrd_cycle   : OUT STD_LOGIC;
         requester_mrdmwr_cycle : OUT STD_LOGIC;
         init                   : OUT STD_LOGIC
      );
   END COMPONENT;


   -- Legacy interrupt signals
   SIGNAL app_int_req                    : STD_LOGIC;       -- legacy interrupt request
   SIGNAL app_int_ack_reg                : STD_LOGIC;       -- boundary reg on legacy interrupt ack input
   SIGNAL interrupt_ack_int              : STD_LOGIC;       -- internal interrupt acknowledge (to interrupt requestor)
   SIGNAL msi_enable                     : STD_LOGIC;       -- 1'b1 means MSI is enabled.  1'b0 means Legacy interrupt is enabled.
   SIGNAL int_deassert                   : STD_LOGIC;       -- State of Legacy interrupt:  1'b1 means issuing Interrupt DEASSERT message, 1'b0 means issuing Interrupt ASSERT message.

   -- AVALON SIGNALS
   SIGNAL writedata_dmard                : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   SIGNAL address_dmard                  : STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
   SIGNAL write_dmard                    : STD_LOGIC;
   SIGNAL waitrequest_dmard              : STD_LOGIC;
   SIGNAL write_byteena_dmard            : STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0);        -- From DMA Read

   SIGNAL open_read_data                 : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   SIGNAL readdata_dmawr                 : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   SIGNAL address_dmawr                  : STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
   SIGNAL read_dmawr                     : STD_LOGIC;
   SIGNAL waitrequest_dmawr              : STD_LOGIC;
   SIGNAL write_byteena_dmawr            : STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0);        -- From DMA Write

   SIGNAL ctl_wr_req                     : STD_LOGIC;
   SIGNAL ctl_wr_data                    : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL ctl_addr                       : STD_LOGIC_VECTOR(2 DOWNTO 0);

   -- Max Payload, Max Read
   SIGNAL cfg_maxpload_dw                : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL cfg_maxrdreq_dw                : STD_LOGIC_VECTOR(15 DOWNTO 0);       -- max lenght of PCIe read in DWORDS
   SIGNAL cfg_maxrdreq_rxbuffer          : STD_LOGIC_VECTOR(2 DOWNTO 0);        -- max lenght of PCIe read in DWORDS based on rx_buffer size
   SIGNAL koh_cfg_maxrdreq               : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL kod_cfg_maxrdreq               : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL koh_cfg_compare                : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL kod_cfg_compare                : STD_LOGIC_VECTOR(4 DOWNTO 0);


   SIGNAL cfg_maxrdreq                   : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL cfg_maxpload                   : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL cfg_link_negociated            : STD_LOGIC_VECTOR(4 DOWNTO 0);

   SIGNAL cfg_maxpload_reg               : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL cfg_maxrdreq_reg               : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL cfg_link_negociated_reg        : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL cfg_busdev_reg                 : STD_LOGIC_VECTOR(12 DOWNTO 0);
   SIGNAL cfg_devcsr_reg                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL cfg_tcvcmap_reg                : STD_LOGIC_VECTOR(23 DOWNTO 0);
   SIGNAL cfg_linkcsr_reg                : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL cfg_msicsr_reg                 : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL ko_cpl_spc_vc0_reg             : STD_LOGIC_VECTOR(19 DOWNTO 0);

   SIGNAL tx_cred0_reg                   : STD_LOGIC_VECTOR(TXCRED_WIDTH - 1 DOWNTO 0);
   SIGNAL tx_mask_reg                    : STD_LOGIC;
   SIGNAL tx_stream_ready0_reg           : STD_LOGIC;

   SIGNAL dma_prg_wrdata                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL dma_prg_addr                   : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL dma_rd_prg_wrena               : STD_LOGIC;
   SIGNAL dma_wr_prg_wrena               : STD_LOGIC;

   SIGNAL mem_rd_data_valid              : STD_LOGIC;
   SIGNAL read_epmem_del                 : STD_LOGIC;
   SIGNAL read_epmem_del2                : STD_LOGIC;
   SIGNAL read_epmem_del3                : STD_LOGIC;

   SIGNAL read_dma_status                : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL write_dma_status               : STD_LOGIC_VECTOR(63 DOWNTO 0);

   SIGNAL  sel_ep_reg                    : STD_LOGIC;
   SIGNAL  reg_wr_addr                   : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL  reg_rd_addr                   : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL  reg_wr_data                   : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL  reg_rd_data                   : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL  dma_wr_prg_rddata             : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL  dma_rd_prg_rddata             : STD_LOGIC_VECTOR(31 DOWNTO 0);

   -- Constant carrying width type for VHDL translation
   SIGNAL cst_one                        : STD_LOGIC;
   SIGNAL cst_zero                       : STD_LOGIC;
   SIGNAL cst_std_logic_vector_type_one  : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL cst_std_logic_vector_type_zero : STD_LOGIC_VECTOR(63 DOWNTO 0);

   SIGNAL rx_req_reg                     : STD_LOGIC;
   SIGNAL rx_req_p1                      : STD_LOGIC;
   SIGNAL rx_req_p0                      : STD_LOGIC;

   SIGNAL tx_sel_slave                   : STD_LOGIC;
   SIGNAL cpl_pending_dmawr              : STD_LOGIC;
   SIGNAL cpl_pending_dmard              : STD_LOGIC;
   SIGNAL cpl_err0_r                     : STD_LOGIC;

   SIGNAL cpl_cnt_50ms                   : STD_LOGIC_VECTOR(23 DOWNTO 0);
   --------------------------------------------------------------
   -- Static side-band signals
   --------------------------------------------------------------

   -- 32    ->  128B
   -- 64    ->  256B
   -- 128   ->  512B
   -- 256   -> 1024B
   -- 512   -> 2048B
   -- 1024  -> 4096B

   -- 32    ->  128 Bytes
   -- 64    ->  256 Bytes
   -- 128   ->  512 Bytes
   -- 256   -> 1024 Bytes
   -- 512   -> 2048 Bytes
   -- 1024  -> 4096 Bytes

   -- Based on ko_cpl_spc_vc0, adjust the size of max read request
   -- 1 MRd consume 1 credit header 4 DWORDs
   -- Max Read Request should be smaller than
   -- cfg_maxrdreq_rxbuffer assume that
   --  - each cpld header consumes 1 credit (4 DWORDS)
   --  - each cpld can be broken down into 64 byte using a total of

   --
   -- Set the max rd req size based on buffer allocation

   -- Set the max rd req size based on data buffer allocation

   -- unused
   -- cpl section

   --------------------------------------------------------------
   --    DMA Write SECTION
   --       - suffix _dmard
   --------------------------------------------------------------
   -- rx
   SIGNAL rx_ack_dmawr                   : STD_LOGIC;
   SIGNAL rx_ws_dmawr                    : STD_LOGIC;

   -- tx
   SIGNAL tx_req_dmawr                   : STD_LOGIC;
   SIGNAL tx_desc_dmawr                  : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL tx_err_dmawr                   : STD_LOGIC;
   SIGNAL tx_dv_dmawr                    : STD_LOGIC;
   SIGNAL tx_dfr_dmawr                   : STD_LOGIC;
   SIGNAL tx_data_dmawr                  : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL tx_desc_fmt_type               : STD_LOGIC_VECTOR(6 DOWNTO 0);

   SIGNAL tx_sel_descriptor_dmawr        : STD_LOGIC;
   SIGNAL tx_busy_descriptor_dmawr       : STD_LOGIC;
   SIGNAL tx_ready_descriptor_dmawr      : STD_LOGIC;

   SIGNAL tx_sel_requester_dmawr         : STD_LOGIC;
   SIGNAL tx_busy_requester_dmawr        : STD_LOGIC;
   SIGNAL tx_ready_requester_dmawr       : STD_LOGIC;

   SIGNAL tx_sel_dmawr                   : STD_LOGIC;
   SIGNAL tx_ready_dmawr                 : STD_LOGIC;
   SIGNAL tx_sel_dmard                   : STD_LOGIC;
   SIGNAL tx_ready_dmard                 : STD_LOGIC;
   SIGNAL tx_stop_dma_write              : STD_LOGIC;

   SIGNAL requester_mrdmwr_cycle_dmawr   : STD_LOGIC;
   SIGNAL descriptor_mrd_cycle_dmawr     : STD_LOGIC;
   SIGNAL init_dmawr                     : STD_LOGIC;
   SIGNAL sm_dmawr                       : STD_LOGIC_VECTOR(10 DOWNTO 0);

   SIGNAL app_msi_req_dmawr              : STD_LOGIC;
   SIGNAL app_msi_tc_dmawr               : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL app_msi_num_dmawr              : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL msi_ready_dmawr                : STD_LOGIC;
   SIGNAL msi_busy_dmawr                 : STD_LOGIC;
   SIGNAL msi_sel_dmawr                  : STD_LOGIC;

   -- Avalon Read Master port

   --------------------------------------------------------------
   -- AVALON DP MEMORY SECTION
   --------------------------------------------------------------

   SIGNAL writedata_epmem                : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   SIGNAL addresswr_epmem                : STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
   SIGNAL write_epmem                    : STD_LOGIC;
   SIGNAL readdata_epmem                 : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   SIGNAL addressrd_epmem                : STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
   SIGNAL read_epmem                     : STD_LOGIC;
   SIGNAL sel_epmem                      : STD_LOGIC;
   SIGNAL write_byteena_epmem            : STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0);        -- From RCSlave

   SIGNAL writedata_epmem_del            : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   SIGNAL addresswr_epmem_del            : STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
   SIGNAL write_epmem_del                : STD_LOGIC;
   SIGNAL mem_rd_data_del                : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   SIGNAL addressrd_epmem_del            : STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
   SIGNAL mem_rd_data_valid_del          : STD_LOGIC;
   SIGNAL sel_epmem_del                  : STD_LOGIC;
   SIGNAL write_byteena_epmem_del        : STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0);

   SIGNAL data_a                         : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   SIGNAL address_b                      : STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
   SIGNAL wren_a                         : STD_LOGIC;
   SIGNAL q_b                            : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   SIGNAL address_a                      : STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
   SIGNAL rden_b                         : STD_LOGIC;

   SIGNAL data_a_reg                     : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   SIGNAL address_b_reg                  : STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
   SIGNAL wren_a_reg                     : STD_LOGIC;
   SIGNAL address_a_reg                  : STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
   SIGNAL rden_b_reg                     : STD_LOGIC;
   SIGNAL byteena_a_reg                  : STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0);
   SIGNAL byteena_b_reg                  : STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0);
   SIGNAL byteena_a                      : STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0);
   SIGNAL byteena_b                      : STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0);

   SIGNAL gnd_data_b                     : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   SIGNAL open_q_a                       : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);

   -- Registered EPMEM
   -- Port B only used for reading
   -- Port B only used for reading

   --------------------------------------------------------------
   --    DMA READ SECTION
   --       - suffix _dmard
   --------------------------------------------------------------
   -- RX
   SIGNAL rx_ack_dmard                   : STD_LOGIC;
   SIGNAL rx_ws_dmard                    : STD_LOGIC;

   -- TX
   SIGNAL tx_req_dmard                   : STD_LOGIC;
   SIGNAL tx_desc_dmard                  : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL tx_err_dmard                   : STD_LOGIC;
   SIGNAL tx_dv_dmard                    : STD_LOGIC;
   SIGNAL tx_dfr_dmard                   : STD_LOGIC;
   SIGNAL tx_data_dmard                  : STD_LOGIC_VECTOR(127 DOWNTO 0);

   SIGNAL tx_sel_descriptor_dmard        : STD_LOGIC;
   SIGNAL tx_busy_descriptor_dmard       : STD_LOGIC;
   SIGNAL tx_ready_descriptor_dmard      : STD_LOGIC;

   SIGNAL tx_sel_requester_dmard         : STD_LOGIC;
   SIGNAL tx_busy_requester_dmard        : STD_LOGIC;
   SIGNAL tx_ready_requester_dmard       : STD_LOGIC;

   --MSI
   SIGNAL app_msi_req_dmard              : STD_LOGIC;
   SIGNAL app_msi_tc_dmard               : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL app_msi_num_dmard              : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL msi_ready_dmard                : STD_LOGIC;
   SIGNAL msi_busy_dmard                 : STD_LOGIC;
   SIGNAL msi_sel_dmard                  : STD_LOGIC;

   -- control signal
   SIGNAL requester_mrdmwr_cycle_dmard   : STD_LOGIC;
   SIGNAL descriptor_mrd_cycle_dmard     : STD_LOGIC;
   SIGNAL init_dmard                     : STD_LOGIC;
   SIGNAL sm_dmard                       : STD_LOGIC_VECTOR(10 DOWNTO 0);

   -- Avalon Write Master port

   --------------------------------------------------------------
   --RC Slave Section
   --       - suffix _pcnt
   --------------------------------------------------------------
   SIGNAL rx_req_pcnt                    : STD_LOGIC;
   SIGNAL rx_ack_pcnt                    : STD_LOGIC;
   SIGNAL rx_desc_pcnt                   : STD_LOGIC_VECTOR(135 DOWNTO 0);
   SIGNAL rx_data_pcnt                   : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL rx_ws_pcnt                     : STD_LOGIC;
   SIGNAL rx_dv_pcnt                     : STD_LOGIC;
   SIGNAL rx_dfr_pcnt                    : STD_LOGIC;

   -- TX
   SIGNAL tx_req_pcnt                    : STD_LOGIC;
   SIGNAL tx_ack_pcnt                    : STD_LOGIC;
   SIGNAL tx_desc_pcnt                   : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL tx_ws_pcnt                     : STD_LOGIC;
   SIGNAL tx_err_pcnt                    : STD_LOGIC;
   SIGNAL tx_dv_pcnt                     : STD_LOGIC;
   SIGNAL tx_dfr_pcnt                    : STD_LOGIC;
   SIGNAL tx_data_pcnt                   : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL tx_sel_pcnt                    : STD_LOGIC;
   SIGNAL tx_busy_pcnt                   : STD_LOGIC;
   SIGNAL tx_ready_pcnt                  : STD_LOGIC;

   SIGNAL tx_dv_dmard_mux                : STD_LOGIC;
   SIGNAL tx_dfr_dmard_mux               : STD_LOGIC;
   SIGNAL tx_req_dmard_mux               : STD_LOGIC;
   SIGNAL tx_err_dmard_mux               : STD_LOGIC;
   SIGNAL tx_desc_dmard_mux              : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL tx_data_dmard_mux              : STD_LOGIC_VECTOR(127 DOWNTO 0);

   -- memory access

   --------------------------------------------------------------
   -- RX signal controls
   --------------------------------------------------------------

   --------------------------------------------------------------
   -- TX signal controls and data stream mux
   --------------------------------------------------------------
   -- TLP_FMT
   -- TLP_TYPE

   -- length
   -- requester id

   -- tag
   -- byte enable
   -- address

   --------------------------------------------------------------
   -- Arbitration of TX- RX Stream
   --------------------------------------------------------------

   SIGNAL dma_tx_idle                    : STD_LOGIC;
   SIGNAL dma_tx_idle_p0_tx_sel          : STD_LOGIC;
   SIGNAL write_priority_over_read       : STD_LOGIC;
   SIGNAL tx_sel_descriptor_dmawr_p0     : STD_LOGIC;
   SIGNAL tx_sel_descriptor_dmard_p0     : STD_LOGIC;
   SIGNAL tx_sel_requester_dmawr_p0      : STD_LOGIC;
   SIGNAL tx_sel_requester_dmard_p0      : STD_LOGIC;
   SIGNAL tx_sel_pcnt_p0                 : STD_LOGIC;
   SIGNAL tx_sel_reg_descriptor_dmawr    : STD_LOGIC;
   SIGNAL tx_sel_reg_descriptor_dmard    : STD_LOGIC;
   SIGNAL tx_sel_reg_requester_dmawr     : STD_LOGIC;
   SIGNAL tx_sel_reg_requester_dmard     : STD_LOGIC;
   SIGNAL tx_sel_reg_pcnt                : STD_LOGIC;

   SIGNAL rx_ecrc_failure                : STD_LOGIC;

   --------------------------------------------------------------
   -- Arbitration of MSI Stream
   --------------------------------------------------------------

   -- MSI Generation
   SIGNAL app_msi_req_reg                : STD_LOGIC;
   SIGNAL app_msi_num_reg                : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL app_msi_tc_reg                 : STD_LOGIC_VECTOR(2 DOWNTO 0);
   -- X-HDL generated signals
   SIGNAL xhdl0 : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL xhdl1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL xhdl4 : STD_LOGIC;
BEGIN
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         rx_req_reg <= rx_req0;
         rx_req_p1 <= rx_req_p0;
      END IF;
   END PROCESS;
   rx_req_p0 <= rx_req0 AND NOT(rx_req_reg);
   cfg_maxpload(2 DOWNTO 0) <= cfg_devcsr_reg(7 DOWNTO 5);
   cfg_link_negociated(4 DOWNTO 0) <= cfg_linkcsr_reg(24 DOWNTO 20);
   cst_one <= '1';
   cst_zero <= '0';
   cst_std_logic_vector_type_one <= (others=>'1') ;
   cst_std_logic_vector_type_zero <= (others=>'0') ;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         cfg_maxpload_dw(4 DOWNTO 0) <= "00000";
         CASE cfg_maxpload_reg IS
            WHEN "000" =>
               cfg_maxpload_dw(10 DOWNTO 5) <= "000001";
            WHEN "001" =>
               cfg_maxpload_dw(10 DOWNTO 5) <= "000010";
            WHEN "010" =>
               cfg_maxpload_dw(10 DOWNTO 5) <= "000100";
            WHEN "011" =>
               cfg_maxpload_dw(10 DOWNTO 5) <= "001000";
            WHEN "100" =>
               cfg_maxpload_dw(10 DOWNTO 5) <= "010000";
            WHEN OTHERS =>
               cfg_maxpload_dw(10 DOWNTO 5) <= "100000";
         END CASE;
         cfg_maxpload_dw(15 DOWNTO 11) <= "00000";
      END IF;
   END PROCESS;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         cfg_maxrdreq_dw(4 DOWNTO 0) <= "00000";
         CASE cfg_maxrdreq_reg IS
            WHEN "000" =>
               cfg_maxrdreq_dw(10 DOWNTO 5) <= "000001";
            WHEN "001" =>
               cfg_maxrdreq_dw(10 DOWNTO 5) <= "000010";
            WHEN "010" =>
               cfg_maxrdreq_dw(10 DOWNTO 5) <= "000100";
            WHEN "011" =>
               cfg_maxrdreq_dw(10 DOWNTO 5) <= "001000";
            WHEN "100" =>
               cfg_maxrdreq_dw(10 DOWNTO 5) <= "010000";
            WHEN OTHERS =>
               cfg_maxrdreq_dw(10 DOWNTO 5) <= "100000";
         END CASE;
         cfg_maxrdreq_dw(15 DOWNTO 11) <= "00000";
      END IF;
   END PROCESS;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (ko_cpl_spc_vc0_reg(7 DOWNTO 0) > "01000000") THEN
            koh_cfg_compare(4) <= '1';
         ELSE
            koh_cfg_compare(4) <= '0';
         END IF;
         IF (ko_cpl_spc_vc0_reg(7 DOWNTO 0) > "00100000") THEN
            koh_cfg_compare(3) <= '1';
         ELSE
            koh_cfg_compare(3) <= '0';
         END IF;
         IF (ko_cpl_spc_vc0_reg(7 DOWNTO 0) > "00010000") THEN
            koh_cfg_compare(2) <= '1';
         ELSE
            koh_cfg_compare(2) <= '0';
         END IF;
         IF (ko_cpl_spc_vc0_reg(7 DOWNTO 0) > "00001000") THEN
            koh_cfg_compare(1) <= '1';
         ELSE
            koh_cfg_compare(1) <= '0';
         END IF;
         IF (ko_cpl_spc_vc0_reg(7 DOWNTO 0) > "00000100") THEN
            koh_cfg_compare(0) <= '1';
         ELSE
            koh_cfg_compare(0) <= '0';
         END IF;
      END IF;
   END PROCESS;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (ko_cpl_spc_vc0_reg(19 DOWNTO 8) > "010000000000") THEN
            kod_cfg_compare(4) <= '1';
         ELSE
            kod_cfg_compare(4) <= '0';
         END IF;
         IF (ko_cpl_spc_vc0_reg(19 DOWNTO 8) > "001000000000") THEN
            kod_cfg_compare(3) <= '1';
         ELSE
            kod_cfg_compare(3) <= '0';
         END IF;
         IF (ko_cpl_spc_vc0_reg(19 DOWNTO 8) > "000100000000") THEN
            kod_cfg_compare(2) <= '1';
         ELSE
            kod_cfg_compare(2) <= '0';
         END IF;
         IF (ko_cpl_spc_vc0_reg(19 DOWNTO 8) > "000010000000") THEN
            kod_cfg_compare(1) <= '1';
         ELSE
            kod_cfg_compare(1) <= '0';
         END IF;
         IF (ko_cpl_spc_vc0_reg(19 DOWNTO 8) > "000001000000") THEN
            kod_cfg_compare(0) <= '1';
         ELSE
            kod_cfg_compare(0) <= '0';
         END IF;
      END IF;
   END PROCESS;

   xhdl0 <= kod_cfg_maxrdreq WHEN (koh_cfg_maxrdreq > kod_cfg_maxrdreq) ELSE
                                    koh_cfg_maxrdreq;
   xhdl1 <= cfg_devcsr_reg(14 DOWNTO 12) WHEN (cfg_maxrdreq_rxbuffer > cfg_devcsr_reg(14 DOWNTO 12)) ELSE
                                    cfg_maxrdreq_rxbuffer;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((koh_cfg_compare(4)) = '1') THEN
            koh_cfg_maxrdreq <= "101";
         ELSIF ((koh_cfg_compare(3)) = '1') THEN
            koh_cfg_maxrdreq <= "100";
         ELSIF ((koh_cfg_compare(2)) = '1') THEN
            koh_cfg_maxrdreq <= "011";
         ELSIF ((koh_cfg_compare(1)) = '1') THEN
            koh_cfg_maxrdreq <= "010";
         ELSIF ((koh_cfg_compare(0)) = '1') THEN
            koh_cfg_maxrdreq <= "001";
         ELSE
            koh_cfg_maxrdreq <= "000";
         END IF;
         IF ((kod_cfg_compare(4)) = '1') THEN
            kod_cfg_maxrdreq <= "101";
         ELSIF ((kod_cfg_compare(3)) = '1') THEN
            kod_cfg_maxrdreq <= "100";
         ELSIF ((kod_cfg_compare(2)) = '1') THEN
            kod_cfg_maxrdreq <= "011";
         ELSIF ((kod_cfg_compare(1)) = '1') THEN
            kod_cfg_maxrdreq <= "010";
         ELSIF ((kod_cfg_compare(0)) = '1') THEN
            kod_cfg_maxrdreq <= "001";
         ELSE
            kod_cfg_maxrdreq <= "000";
         END IF;
         cfg_maxrdreq_rxbuffer <= xhdl0;
         cfg_maxrdreq <= xhdl1;
      END IF;
   END PROCESS;
   rx_mask0 <= '0';

   dma_write : altpcierd_dma_dt
      GENERIC MAP (
         DIRECTION              => 1,
         FIFO_WIDTHU            => FIFO_WIDTHU,
         FIFO_DEPTH             => FIFO_DEPTH,
         USE_CREDIT_CTRL        => USE_CREDIT_CTRL,
         USE_MSI                => USE_MSI,
         RC_SLAVE_USETAG        => RC_SLAVE_USETAG,
         USE_RCSLAVE            => USE_RCSLAVE,
         TXCRED_WIDTH           => TXCRED_WIDTH,
         BOARD_DEMO             => BOARD_DEMO,
         MAX_PAYLOAD            => MAX_PAYLOAD_SIZE_BYTE,
         RC_64BITS_ADDR         => RC_64BITS_ADDR,
         MAX_NUMTAG             => MAX_NUMTAG,
         AVALON_WADDR           => AVALON_WADDR,
         TL_SELECTION           => TL_SELECTION,
         AVALON_ST_128          => AVALON_ST_128,
         AVALON_BYTE_WIDTH      => AVALON_BYTE_WIDTH,
         AVALON_WDATA           => AVALON_WDATA,
         CDMA_AST_RXWS_LATENCY  => CDMA_AST_RXWS_LATENCY
      )
      PORT MAP (
         clk_in                  => clk_in,
         rstn                    => rstn,


         rx_be                   => rx_be0,
         rx_req                  => rx_req0,
         rx_req_p0               => rx_req_p0,
         rx_req_p1               => rx_req_p1,
         rx_ack                  => rx_ack_dmawr,
         rx_desc                 => rx_desc0,
         rx_data                 => rx_data0,
         rx_ws                   => rx_ws_dmawr,
         rx_dv                   => rx_dv0,
         rx_dfr                  => rx_dfr0,
         tx_sel_descriptor       => tx_sel_descriptor_dmawr,
         tx_busy_descriptor      => tx_busy_descriptor_dmawr,
         tx_ready_descriptor     => tx_ready_descriptor_dmawr,
         tx_sel_requester        => tx_sel_requester_dmawr,
         tx_busy_requester       => tx_busy_requester_dmawr,
         tx_ready_requester      => tx_ready_requester_dmawr,
         tx_ready_other_dma      => tx_ready_dmard,
         tx_req                  => tx_req_dmawr,
         tx_ack                  => tx_ack0,
         tx_desc                 => tx_desc_dmawr,
         tx_ws                   => tx_ws0,
         tx_err                  => tx_err_dmawr,
         tx_dv                   => tx_dv_dmawr,
         tx_dfr                  => tx_dfr_dmawr,
         tx_data                 => tx_data_dmawr,
         rx_buffer_cpl_max_dw    => rx_buffer_cpl_max_dw,
         app_msi_ack             => interrupt_ack_int,
         app_msi_req             => app_msi_req_dmawr,
         app_msi_tc              => app_msi_tc_dmawr,
         app_msi_num             => app_msi_num_dmawr,
         msi_ready               => msi_ready_dmawr,
         msi_busy                => msi_busy_dmawr,
         msi_sel                 => msi_sel_dmawr,
         tx_cred                 => tx_cred0_reg,
         cfg_maxpload_dw         => cfg_maxpload_dw,
         cfg_maxrdreq_dw         => cfg_maxrdreq_dw,
         cfg_maxpload            => cfg_maxpload_reg,
         cfg_maxrdreq            => cfg_maxrdreq_reg,
         cfg_busdev              => cfg_busdev_reg,
         cfg_link_negociated     => cfg_link_negociated_reg,
         requester_mrdmwr_cycle  => requester_mrdmwr_cycle_dmawr,
         descriptor_mrd_cycle    => descriptor_mrd_cycle_dmawr,
         init                    => init_dmawr,
         dma_sm                  => sm_dmawr,
         cpl_pending             => cpl_pending_dmawr,

         dma_prg_wrdata          => dma_prg_wrdata,
         dma_prg_addr            => dma_prg_addr,
         dma_prg_wrena           => dma_wr_prg_wrena,
         dma_prg_rddata          => dma_wr_prg_rddata,

         dma_status              => write_dma_status,

         read_address            => address_dmawr,
         read_wait               => waitrequest_dmawr,
         read                    => read_dmawr,
         read_data               => readdata_dmawr,
         write_byteena           => write_byteena_dmawr
      );
   gnd_data_b <= (others=>'0');
   byteena_a <= byteena_a_reg;
   byteena_b <= byteena_b_reg;
   data_a <= data_a_reg;
   address_a <= address_a_reg;
   wren_a <= wren_a_reg;
   address_b <= address_b_reg;
   rden_b <= rden_b_reg;
   PROCESS (clk_in, rstn)
   BEGIN
      IF (rstn = '0') THEN
         writedata_epmem_del   <= TO_STDLOGICVECTOR (0, AVALON_WDATA);
         addresswr_epmem_del   <= TO_STDLOGICVECTOR (0, AVALON_WADDR);
         write_epmem_del       <= '0';
         addressrd_epmem_del   <= TO_STDLOGICVECTOR (0, AVALON_WADDR);
         read_epmem_del        <= '0';
         mem_rd_data_del       <= TO_STDLOGICVECTOR (0, AVALON_WDATA);
         mem_rd_data_valid_del <= '0';
         sel_epmem_del         <= '0';
       write_byteena_epmem_del <= (OTHERS => '0');
         data_a_reg            <= TO_STDLOGICVECTOR (0, AVALON_WDATA);
         address_a_reg         <= TO_STDLOGICVECTOR (0, AVALON_WADDR);
         wren_a_reg            <= '0';
         address_b_reg         <=  TO_STDLOGICVECTOR (0, AVALON_WADDR);
         rden_b_reg            <= '0';
         byteena_a_reg         <= TO_STDLOGICVECTOR (0, AVALON_BYTE_WIDTH);
         byteena_b_reg         <= TO_STDLOGICVECTOR (0, AVALON_BYTE_WIDTH);  --Port B only used for reading
         read_epmem_del        <= '0';
         read_epmem_del2       <= '0';
         read_epmem_del3       <= '0';
         mem_rd_data_valid     <= '0';
      ELSIF (rising_edge (clk_in)) THEN
          writedata_epmem_del   <= writedata_epmem;
          addresswr_epmem_del   <= addresswr_epmem;
          write_epmem_del       <= write_epmem;
          addressrd_epmem_del   <= addressrd_epmem;
          read_epmem_del        <= read_epmem;
          mem_rd_data_del       <= q_b;
          mem_rd_data_valid_del <= mem_rd_data_valid;
          sel_epmem_del         <= sel_epmem;

          write_byteena_epmem_del <= write_byteena_epmem;

         IF (sel_epmem_del = '1') THEN
            data_a_reg <= writedata_epmem_del;
            address_a_reg <= addresswr_epmem_del;
            wren_a_reg <= write_epmem_del;
            address_b_reg <= addressrd_epmem_del;
            rden_b_reg <= read_epmem_del;
            byteena_a_reg <= write_byteena_epmem_del;
            byteena_b_reg <= (others=>'0');
            read_epmem_del    <= read_epmem;
            read_epmem_del2    <= read_epmem_del;
            read_epmem_del3    <= read_epmem_del2;
            mem_rd_data_valid <= read_epmem_del3;
         ELSE
            data_a_reg <= writedata_dmard;
            address_a_reg <= address_dmard;
            wren_a_reg <= write_dmard AND NOT(waitrequest_dmard);
            address_b_reg <= address_dmawr;
            rden_b_reg <= read_dmawr AND NOT(waitrequest_dmawr);
            byteena_a_reg <= write_byteena_dmard;
            byteena_b_reg <= (others=>'0');
            read_epmem_del    <= '0';
            read_epmem_del2   <= '0';
            read_epmem_del3   <= '0';
            mem_rd_data_valid <= '0';
         END IF;
      END IF;
   END PROCESS;
   readdata_epmem <= q_b;
   readdata_dmawr <= q_b;


   ep_dpram : altsyncram
      GENERIC MAP (
         address_reg_b                       => "CLOCK0",
         indata_reg_b                        => "CLOCK0",
         wrcontrol_wraddress_reg_b           => "CLOCK0",
         intended_device_family              => "Stratix II",
         lpm_type                            => "altsyncram",
         numwords_a                          => NUMWORDS_AVALON_WADDR,
         numwords_b                          => NUMWORDS_AVALON_WADDR,
         operation_mode                      => "BIDIR_DUAL_PORT",
         outdata_aclr_a                      => "NONE",
         outdata_aclr_b                      => "NONE",
         outdata_reg_a                       => "CLOCK0",
         outdata_reg_b                       => "CLOCK0",
         power_up_uninitialized              => "FALSE",
         read_during_write_mode_mixed_ports  => "DONT_CARE",
         widthad_a                           => AVALON_WADDR,
         widthad_b                           => AVALON_WADDR,
         width_a                             => AVALON_WDATA,
         width_b                             => AVALON_WDATA,
         width_byteena_a                     => AVALON_BYTE_WIDTH,
         width_byteena_b                     => AVALON_BYTE_WIDTH,
         byteena_reg_b                       => "CLOCK0"
      )
      PORT MAP (
         clock0          => clk_in,
         wren_a          => wren_a,
         address_a       => address_a,
         rden_b          => rden_b,
         data_a          => data_a,
         address_b       => address_b,
         q_b             => q_b,
         aclr0           => cst_zero,
         aclr1           => cst_zero,
         addressstall_a  => cst_zero,
         addressstall_b  => cst_zero,
         byteena_a       => byteena_a,
         byteena_b       => byteena_b,
         clock1          => cst_one,
         clocken0        => cst_one,
         clocken1        => cst_one,
         data_b          => gnd_data_b,
         q_a             => open_q_a,
         wren_b          => cst_zero
      );


   dma_read : altpcierd_dma_dt
      GENERIC MAP (
         DIRECTION              => 0,
         RC_64BITS_ADDR         => RC_64BITS_ADDR,
         MAX_NUMTAG             => MAX_NUMTAG,
         FIFO_WIDTHU            => FIFO_WIDTHU,
         FIFO_DEPTH             => FIFO_DEPTH,
         USE_CREDIT_CTRL        => USE_CREDIT_CTRL,
         BOARD_DEMO             => BOARD_DEMO,
         USE_MSI                => USE_MSI,
         RC_SLAVE_USETAG        => RC_SLAVE_USETAG,
         TXCRED_WIDTH           => TXCRED_WIDTH,
         AVALON_WADDR           => AVALON_WADDR,
         AVALON_ST_128          => AVALON_ST_128,
         AVALON_WDATA           => AVALON_WDATA,
         AVALON_BYTE_WIDTH      => AVALON_BYTE_WIDTH,
         CDMA_AST_RXWS_LATENCY  => CDMA_AST_RXWS_LATENCY
      )
      PORT MAP (
         clk_in                  => clk_in,
         rstn                    => rstn,

         rx_req                  => rx_req0,
         rx_req_p0               => rx_req_p0,
         rx_req_p1               => rx_req_p1,
         rx_ack                  => rx_ack_dmard,
         rx_desc                 => rx_desc0,
         rx_data                 => rx_data0,
         rx_be                   => rx_be0,
         rx_ws                   => rx_ws_dmard,
         rx_dv                   => rx_dv0,
         rx_dfr                  => rx_dfr0,
         tx_sel_descriptor       => tx_sel_descriptor_dmard,
         tx_busy_descriptor      => tx_busy_descriptor_dmard,
         tx_ready_descriptor     => tx_ready_descriptor_dmard,
         tx_sel_requester        => tx_sel_requester_dmard,
         tx_busy_requester       => tx_busy_requester_dmard,
         tx_ready_requester      => tx_ready_requester_dmard,
         tx_ready_other_dma      => tx_ready_dmawr,
         rx_buffer_cpl_max_dw    => rx_buffer_cpl_max_dw,
         tx_cred                 => tx_cred0_reg,
         tx_req                  => tx_req_dmard,
         tx_ack                  => tx_ack0,
         tx_desc                 => tx_desc_dmard,
         tx_ws                   => tx_ws0,
         tx_err                  => tx_err_dmard,
         tx_dv                   => tx_dv_dmard,
         tx_dfr                  => tx_dfr_dmard,
         tx_data                 => tx_data_dmard,
         cfg_maxpload_dw         => cfg_maxpload_dw,
         cfg_maxpload            => cfg_maxpload_reg,
         cfg_maxrdreq_dw         => cfg_maxrdreq_dw,
         cfg_maxrdreq            => cfg_maxrdreq_reg,
         cfg_busdev              => cfg_busdev_reg,
         cfg_link_negociated     => cfg_link_negociated_reg,
         requester_mrdmwr_cycle  => requester_mrdmwr_cycle_dmard,
         descriptor_mrd_cycle    => descriptor_mrd_cycle_dmard,
         init                    => init_dmard,
         app_msi_ack             => interrupt_ack_int,
         app_msi_req             => app_msi_req_dmard,
         app_msi_tc              => app_msi_tc_dmard,
         app_msi_num             => app_msi_num_dmard,
         msi_ready               => msi_ready_dmard,
         msi_busy                => msi_busy_dmard,
         msi_sel                 => msi_sel_dmard,
         dma_sm                  => sm_dmard,
         cpl_pending             => cpl_pending_dmard,

         dma_prg_wrdata          => dma_prg_wrdata,
         dma_prg_addr            => dma_prg_addr,
         dma_prg_wrena           => dma_rd_prg_wrena,
         dma_prg_rddata          => dma_rd_prg_rddata,

         dma_status              => read_dma_status,

         read_data               => open_read_data,
         write_address           => address_dmard,
         write_wait              => waitrequest_dmard,
         write                   => write_dmard,
         write_data              => writedata_dmard,
         write_byteena           => write_byteena_dmard
      );



   tx_sel_slave <= tx_sel_pcnt;

   tx_err_pcnt     <= '0';

   tx_dv_dmard_mux <= tx_dv_dmard WHEN (tx_sel_slave = '0') ELSE
                      tx_dv_pcnt;
   tx_dfr_dmard_mux <= tx_dfr_dmard WHEN (tx_sel_slave = '0') ELSE
                       tx_dfr_pcnt;
   tx_req_dmard_mux <= tx_req_dmard WHEN (tx_sel_slave = '0') ELSE
                       tx_req_pcnt;
   tx_err_dmard_mux <= tx_err_dmard WHEN (tx_sel_slave = '0') ELSE
                       tx_err_pcnt;
   tx_data_dmard_mux <= tx_data_dmard WHEN (tx_sel_slave = '0') ELSE
                        tx_data_pcnt;
   tx_desc_dmard_mux <= tx_desc_dmard WHEN (tx_sel_slave = '0') ELSE
                        tx_desc_pcnt;


      rc_slave : altpcierd_rc_slave
       GENERIC MAP(
            AVALON_WDATA           => AVALON_WDATA,
            AVALON_WADDR           => AVALON_WADDR,
            AVALON_ST_128          => AVALON_ST_128,
            AVALON_BYTE_WIDTH      => AVALON_BYTE_WIDTH
      )  PORT MAP(
           clk_in     =>  clk_in,
           rstn       =>  rstn,
           cfg_busdev =>  cfg_devcsr_reg(12 DOWNTO 0),

           rx_req     =>  rx_req0,
           rx_desc    =>  rx_desc0,
           rx_data    =>  rx_data0(AVALON_WDATA-1 DOWNTO 0),
           rx_be      =>  rx_be0(AVALON_BYTE_WIDTH-1 DOWNTO 0),
           rx_dv      =>  rx_dv0,
           rx_dfr     =>  rx_dfr0,
           rx_ack     =>  rx_ack_pcnt,
           rx_ws      =>  rx_ws_pcnt,

           tx_ws      =>  tx_ws0,
           tx_ack     =>  tx_ack0,
           tx_desc    =>  tx_desc_pcnt,
           tx_data    =>  tx_data_pcnt(AVALON_WDATA-1 DOWNTO 0),
           tx_dfr     =>  tx_dfr_pcnt,
           tx_dv      =>  tx_dv_pcnt,
           tx_req     =>  tx_req_pcnt,
           tx_busy    =>  tx_busy_pcnt ,
           tx_ready   =>  tx_ready_pcnt,
           tx_sel     =>  tx_sel_pcnt  ,

           mem_rd_data_valid =>  mem_rd_data_valid_del,
           mem_rd_addr       =>  addressrd_epmem,
           mem_rd_data       =>  mem_rd_data_del,
           mem_rd_ena        =>  read_epmem,
           mem_wr_ena        =>  write_epmem,
           mem_wr_addr       =>  addresswr_epmem,
           mem_wr_data       =>  writedata_epmem,
           mem_wr_be         =>  write_byteena_epmem,
           sel_epmem         =>  sel_epmem,

           dma_rd_prg_rddata =>  dma_rd_prg_rddata,
           dma_wr_prg_rddata =>  dma_wr_prg_rddata,
           dma_prg_wrdata    =>  dma_prg_wrdata,
           dma_prg_addr      =>  dma_prg_addr,
           dma_rd_prg_wrena  =>  dma_rd_prg_wrena,
           dma_wr_prg_wrena  =>  dma_wr_prg_wrena,

           rx_ecrc_bad_cnt   =>  rx_ecrc_bad_cnt,
           read_dma_status   =>  read_dma_status,
           write_dma_status  =>  write_dma_status
        );

   rx_ack0 <= rx_ack_dmawr OR rx_ack_dmard OR rx_ack_pcnt;
   rx_ws0 <= rx_ws_dmawr OR rx_ws_dmard OR rx_ws_pcnt;
   tx_dv0 <= tx_dv_dmawr WHEN (tx_sel_dmawr = '1') ELSE
             tx_dv_dmard_mux;
   tx_dfr0 <= tx_dfr_dmawr WHEN (tx_sel_dmawr = '1') ELSE
              tx_dfr_dmard_mux;
   tx_data0 <= tx_data_dmawr WHEN (tx_sel_dmawr = '1') ELSE
               tx_data_dmard_mux;
   tx_req0 <= tx_req_dmawr WHEN (tx_sel_dmawr = '1') ELSE
              tx_req_dmard_mux;
   tx_err0 <= tx_err_dmawr WHEN (tx_sel_dmawr = '1') ELSE
              tx_err_dmard_mux;
   tx_desc0(127) <= '0';
   tx_desc0(126 DOWNTO 120) <= tx_desc_dmawr(126 DOWNTO 120) WHEN (tx_sel_dmawr = '1') ELSE
                               tx_desc_dmard_mux(126 DOWNTO 120);
   tx_desc0(119) <= '0';
   tx_desc0(118 DOWNTO 116) <= "000";
   tx_desc0(115 DOWNTO 112) <= "0000";
   tx_desc0(111) <= '0';
   tx_desc0(110) <= '0';
   tx_desc0(109 DOWNTO 108) <= "00";
   tx_desc0(107 DOWNTO 106) <= "00";
   tx_desc0(105 DOWNTO 96) <= tx_desc_dmawr(105 DOWNTO 96) WHEN (tx_sel_dmawr = '1') ELSE
                              tx_desc_dmard_mux(105 DOWNTO 96);
   tx_desc0(95 DOWNTO 83) <= cfg_busdev_reg;
   tx_desc0(82 DOWNTO 80) <= "000";
   tx_desc0(79 DOWNTO 72) <= tx_desc_dmawr(79 DOWNTO 72) WHEN (tx_sel_dmawr = '1') ELSE
                             tx_desc_dmard_mux(79 DOWNTO 72);
   tx_desc0(71 DOWNTO 64) <= tx_desc_dmawr(71 DOWNTO 64) WHEN (tx_sel_dmawr = '1') ELSE
                             tx_desc_dmard_mux(71 DOWNTO 64);
   tx_desc0(63 DOWNTO 0) <= tx_desc_dmawr(63 DOWNTO 0) WHEN (tx_sel_dmawr = '1') ELSE
                            tx_desc_dmard_mux(63 DOWNTO 0);
   write_priority_over_read <= '1' WHEN (DMA_WRITE_PRIORITY > DMA_READ_PRIORITY) ELSE
                               '0';
   tx_ready_dmawr <= '1' WHEN ((write_priority_over_read = '1') AND ((tx_ready_descriptor_dmawr = '1') OR (tx_ready_requester_dmawr = '1'))) ELSE
                     '0';
   tx_sel_dmard <= '1' WHEN ((tx_sel_descriptor_dmard = '1') OR (tx_sel_requester_dmard = '1')) ELSE
                   '0';
   tx_stop_dma_write <= '1' WHEN ((tx_mask_reg = '1') OR (tx_stream_ready0_reg = '0')) ELSE
                        '0';
   tx_ready_dmard <= '1' WHEN ((tx_stop_dma_write = '1') OR ((write_priority_over_read = '0') AND ((tx_ready_descriptor_dmard = '1') OR (tx_ready_requester_dmard = '1')))) ELSE
                     '0';
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         tx_sel_reg_descriptor_dmawr <= tx_sel_descriptor_dmawr;
         tx_sel_reg_descriptor_dmard <= tx_sel_descriptor_dmard;
         tx_sel_reg_requester_dmawr <= tx_sel_requester_dmawr;
         tx_sel_reg_requester_dmard <= tx_sel_requester_dmard;
         tx_sel_reg_pcnt <= tx_sel_pcnt;
      END IF;
   END PROCESS;
   tx_sel_descriptor_dmawr_p0 <= tx_sel_descriptor_dmawr AND NOT(tx_sel_reg_descriptor_dmawr);
   tx_sel_descriptor_dmard_p0 <= tx_sel_descriptor_dmard AND NOT(tx_sel_reg_descriptor_dmard);
   tx_sel_requester_dmawr_p0 <= tx_sel_requester_dmawr AND NOT(tx_sel_reg_requester_dmawr);
   tx_sel_requester_dmard_p0 <= tx_sel_requester_dmard AND NOT(tx_sel_reg_requester_dmard);
   tx_sel_pcnt_p0 <= tx_sel_pcnt AND NOT(tx_sel_reg_pcnt);
   dma_tx_idle_p0_tx_sel <= '1' WHEN ((tx_sel_pcnt_p0 = '0') AND (tx_sel_descriptor_dmawr_p0 = '0') AND (tx_sel_requester_dmawr_p0 = '0') AND (tx_sel_descriptor_dmard_p0 = '0') AND (tx_sel_requester_dmard_p0 = '0')) ELSE
                            '0';
   dma_tx_idle <= '1' WHEN ((tx_busy_pcnt = '0') AND (tx_busy_descriptor_dmawr = '0') AND (tx_busy_requester_dmawr = '0') AND (tx_busy_descriptor_dmard = '0') AND (tx_busy_requester_dmard = '0')) ELSE
                  '0';
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         rx_ecrc_failure <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         IF (rx_ecrc_bad_cnt > "0000000000000000") THEN
            rx_ecrc_failure <= '1';
         END IF;
      END IF;
   END PROCESS;

   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         tx_sel_descriptor_dmawr <= '0';
         tx_sel_requester_dmawr <= '0';
         tx_sel_dmawr <= '0';
         tx_sel_descriptor_dmard <= '0';
         tx_sel_requester_dmard <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         IF (cfg_prmcsr(2) = '0') THEN -- Bus master enable PCI control
            tx_sel_descriptor_dmawr <= '0';
            tx_sel_requester_dmawr <= '0';
            tx_sel_dmawr <= '0';
            tx_sel_descriptor_dmard <= '0';
            tx_sel_requester_dmard <= '0';
         ELSIF ((dma_tx_idle = '1') AND (dma_tx_idle_p0_tx_sel = '1')) THEN
            IF (DMA_WRITE_PRIORITY > DMA_READ_PRIORITY) THEN
               IF ((tx_mask_reg = '1') OR (tx_stream_ready0_reg = '0')) THEN
                  tx_sel_descriptor_dmawr <= '0';
                  tx_sel_requester_dmawr <= '0';
                  tx_sel_dmawr <= '0';
                  tx_sel_descriptor_dmard <= '0';
                  tx_sel_requester_dmard <= '0';
               ELSIF ((tx_ready_descriptor_dmawr = '1') AND (cpld_rx_buffer_ready = '1')) THEN
                  tx_sel_descriptor_dmawr <= '1';
                  tx_sel_requester_dmawr <= '0';
                  tx_sel_dmawr <= '1';
                  tx_sel_descriptor_dmard <= '0';
                  tx_sel_requester_dmard <= '0';
               ELSIF ((tx_ready_descriptor_dmard = '1') AND (cpld_rx_buffer_ready = '1')) THEN
                  tx_sel_descriptor_dmawr <= '0';
                  tx_sel_requester_dmawr <= '0';
                  tx_sel_dmawr <= '0';
                  tx_sel_descriptor_dmard <= '1';
                  tx_sel_requester_dmard <= '0';
               ELSIF (tx_ready_requester_dmawr = '1') THEN
                  tx_sel_descriptor_dmawr <= '0';
                  tx_sel_requester_dmawr <= '1';
                  tx_sel_dmawr <= '1';
                  tx_sel_descriptor_dmard <= '0';
                  tx_sel_requester_dmard <= '0';
               ELSIF ((tx_ready_requester_dmard = '1') AND (cpld_rx_buffer_ready = '1')) THEN
                  tx_sel_descriptor_dmawr <= '0';
                  tx_sel_requester_dmawr <= '0';
                  tx_sel_dmawr <= '0';
                  tx_sel_descriptor_dmard <= '0';
                  tx_sel_requester_dmard <= '1';
               ELSIF ((tx_ready_pcnt = '1') AND (cpld_rx_buffer_ready = '1')) THEN
                  tx_sel_descriptor_dmawr <= '0';
                  tx_sel_requester_dmawr <= '0';
                  tx_sel_dmawr <= '0';
                  tx_sel_descriptor_dmard <= '0';
                  tx_sel_requester_dmard <= '0';
               ELSE
                  tx_sel_descriptor_dmawr <= '0';
                  tx_sel_requester_dmawr <= '0';
                  tx_sel_dmawr <= '0';
                  tx_sel_descriptor_dmard <= '0';
                  tx_sel_requester_dmard <= '0';
               END IF;
            ELSE
               IF ((tx_mask_reg = '1') OR (tx_stream_ready0_reg = '0')) THEN
                  tx_sel_descriptor_dmawr <= '0';
                  tx_sel_requester_dmawr <= '0';
                  tx_sel_dmawr <= '0';
                  tx_sel_descriptor_dmard <= '0';
                  tx_sel_requester_dmard <= '0';
               ELSIF ((tx_ready_descriptor_dmard = '1') AND (cpld_rx_buffer_ready = '1')) THEN
                  tx_sel_descriptor_dmawr <= '0';
                  tx_sel_requester_dmawr <= '0';
                  tx_sel_dmawr <= '0';
                  tx_sel_descriptor_dmard <= '1';
                  tx_sel_requester_dmard <= '0';
               ELSIF ((tx_ready_descriptor_dmawr = '1') AND (cpld_rx_buffer_ready = '1')) THEN
                  tx_sel_descriptor_dmawr <= '1';
                  tx_sel_requester_dmawr <= '0';
                  tx_sel_dmawr <= '1';
                  tx_sel_descriptor_dmard <= '0';
                  tx_sel_requester_dmard <= '0';
               ELSIF ((tx_ready_requester_dmard = '1') AND (cpld_rx_buffer_ready = '1')) THEN
                  tx_sel_descriptor_dmawr <= '0';
                  tx_sel_requester_dmawr <= '0';
                  tx_sel_dmawr <= '0';
                  tx_sel_descriptor_dmard <= '0';
                  tx_sel_requester_dmard <= '1';
               ELSIF (tx_ready_requester_dmawr = '1') THEN
                  tx_sel_descriptor_dmawr <= '0';
                  tx_sel_requester_dmawr <= '1';
                  tx_sel_dmawr <= '1';
                  tx_sel_descriptor_dmard <= '0';
                  tx_sel_requester_dmard <= '0';
               ELSIF ((tx_ready_pcnt = '1') AND (cpld_rx_buffer_ready = '1')) THEN
                  tx_sel_descriptor_dmawr <= '0';
                  tx_sel_requester_dmawr <= '0';
                  tx_sel_dmawr <= '0';
                  tx_sel_descriptor_dmard <= '0';
                  tx_sel_requester_dmard <= '0';
               ELSE
                  tx_sel_descriptor_dmawr <= '0';
                  tx_sel_requester_dmawr <= '0';
                  tx_sel_dmawr <= '0';
                  tx_sel_descriptor_dmard <= '0';
                  tx_sel_requester_dmard <= '0';
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         tx_sel_pcnt <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         IF (cfg_prmcsr(2) = '0') THEN -- Bus master enable PCI control
            tx_sel_pcnt <= '1';
         ELSIF ((dma_tx_idle = '1') AND (dma_tx_idle_p0_tx_sel = '1')) THEN
            IF (DMA_WRITE_PRIORITY > DMA_READ_PRIORITY) THEN
               IF ((tx_mask_reg = '1') OR (tx_stream_ready0_reg = '0')) THEN
                  tx_sel_pcnt <= '0';
               ELSIF ((tx_ready_descriptor_dmawr = '1') AND (cpld_rx_buffer_ready = '1')) THEN
                  tx_sel_pcnt <= '0';
               ELSIF ((tx_ready_descriptor_dmard = '1') AND (cpld_rx_buffer_ready = '1')) THEN
                  tx_sel_pcnt <= '0';
               ELSIF (tx_ready_requester_dmawr = '1') THEN
                  tx_sel_pcnt <= '0';
               ELSIF ((tx_ready_requester_dmard = '1') AND (cpld_rx_buffer_ready = '1')) THEN
                  tx_sel_pcnt <= '0';
               ELSIF ((tx_ready_pcnt = '1') AND (cpld_rx_buffer_ready = '1')) THEN
                  tx_sel_pcnt <= '1';
               ELSE
                  tx_sel_pcnt <= '0';
               END IF;
            ELSE
               IF ((tx_mask_reg = '1') OR (tx_stream_ready0_reg = '0')) THEN
                  tx_sel_pcnt <= '0';
               ELSIF ((tx_ready_descriptor_dmard = '1') AND (cpld_rx_buffer_ready = '1')) THEN
                  tx_sel_pcnt <= '0';
               ELSIF ((tx_ready_descriptor_dmawr = '1') AND (cpld_rx_buffer_ready = '1')) THEN
                  tx_sel_pcnt <= '0';
               ELSIF ((tx_ready_requester_dmard = '1') AND (cpld_rx_buffer_ready = '1')) THEN
                  tx_sel_pcnt <= '0';
               ELSIF (tx_ready_requester_dmawr = '1') THEN
                  tx_sel_pcnt <= '0';
               ELSIF ((tx_ready_pcnt = '1') AND (cpld_rx_buffer_ready = '1')) THEN
                  tx_sel_pcnt <= '1';
               ELSE
                  tx_sel_pcnt <= '0';
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   -- MSI Generation
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         app_msi_req_reg <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         IF (msi_enable = '1') THEN
            IF (app_msi_ack = '1') THEN
               app_msi_req_reg <= '0';
            ELSIF (msi_sel_dmawr = '1') THEN
               app_msi_req_reg <= app_msi_req_dmawr;
            ELSE
               app_msi_req_reg <= app_msi_req_dmard;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (msi_sel_dmawr = '1') THEN
            app_msi_num_reg <= app_msi_num_dmawr;
         ELSE
            app_msi_num_reg <= app_msi_num_dmard;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (msi_sel_dmawr = '1') THEN
            app_msi_tc_reg <= app_msi_tc_dmawr;
         ELSE
            app_msi_tc_reg <= app_msi_tc_dmard;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         msi_sel_dmawr <= '0';
         msi_sel_dmard <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((msi_busy_dmard = '0') AND (msi_busy_dmawr = '0')) THEN
            IF (msi_ready_dmawr = '1') THEN
               msi_sel_dmawr <= '1';
               msi_sel_dmard <= '0';
         ELSIF (msi_ready_dmard = '1') THEN
            msi_sel_dmawr <= '0';
            msi_sel_dmard <= '1';
         ELSE
            msi_sel_dmawr <= '1';
            msi_sel_dmard <= '0';
         END IF;
      END IF;
      END IF;
   END PROCESS;

   ----------------------------------------------------------------
   -- Interrupt/MSI IO signalling
   -- Route arbitrated interrupt request to MSI if msi is enabled,
   -- or to Legacy app_int_sts otherwise.
   ----------------------------------------------------------------

   msi_enable <= cfg_msicsr_reg(0);

   -- MSI REQUEST
   app_msi_req <= app_msi_req_reg;
   app_msi_num <= app_msi_num_reg;
   app_msi_tc <= app_msi_tc_reg;

   -- LEGACY INT REQUEST
   app_int_sts <= app_int_req;

   -- input boundary reg
   xhdl4 <= NOT(int_deassert) WHEN (app_int_ack_reg = '1') ELSE     -- track whether core is sending interrupt ASSERTION message or DEASSERTION message.
                  int_deassert;
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         app_int_req <= '0';
         app_int_ack_reg <= '0';
         int_deassert <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         app_int_ack_reg <= app_int_ack;

         int_deassert <= xhdl4;     -- deassert request when Interrupt ASSERTION is ack-ed
         IF (app_int_ack_reg = '1') THEN
            app_int_req <= '0';
         ELSIF (((NOT(msi_enable) AND NOT(int_deassert))) = '1' AND (((msi_sel_dmawr = '1') AND (app_msi_req_dmawr = '1')) OR ((msi_sel_dmawr = '0') AND (app_msi_req_dmard = '1')))) THEN      -- assert if there is a request, and not waiting for the DEASSERTION ack for this request
            app_int_req <= '1';
         ELSE
            app_int_req <= app_int_req;
         END IF;
      END IF;
   END PROCESS;

   -- MSI & LEGACY ACKNOWLEDGE - sent to the internal interrupt requestor

   interrupt_ack_int <= (app_msi_ack AND msi_enable) OR (app_int_ack_reg AND NOT(int_deassert) AND NOT(msi_enable));        -- Ack from MSI
   -- INT ASSERT Message Ack from Legacy

   --------------------------------------------------------------
   -- Registering module for static side band signals
   --------------------------------------------------------------


   rxtx_pipe : altpcierd_rxtx_pipe
      GENERIC MAP (
         TXCRED_WIDTH  => TXCRED_WIDTH
      )
      PORT MAP (

         clk_in                   => clk_in,
         rstn                     => rstn,

         tx_mask0                 => tx_mask0,
         tx_cred0                 => tx_cred0,
         tx_stream_ready0         => tx_stream_ready0,
         cfg_maxpload             => cfg_maxpload,
         cfg_maxrdreq             => cfg_maxrdreq,
         cfg_busdev               => cfg_busdev,
         cfg_link_negociated      => cfg_link_negociated,
         cfg_devcsr               =>cfg_devcsr,
         cfg_tcvcmap              =>cfg_tcvcmap,
         cfg_linkcsr              =>cfg_linkcsr,
         cfg_msicsr               =>cfg_msicsr,
         ko_cpl_spc_vc0               =>ko_cpl_spc_vc0,

         tx_mask_reg              => tx_mask_reg,
         tx_cred0_reg             => tx_cred0_reg,
         tx_stream_ready0_reg     => tx_stream_ready0_reg,
         cfg_maxpload_reg         => cfg_maxpload_reg,
         cfg_maxrdreq_reg         => cfg_maxrdreq_reg,
         cfg_busdev_reg           => cfg_busdev_reg,
         cfg_devcsr_reg           => cfg_devcsr_reg,
         cfg_tcvcmap_reg          => cfg_tcvcmap_reg,
         cfg_linkcsr_reg          => cfg_linkcsr_reg,
         cfg_msicsr_reg           => cfg_msicsr_reg,
         ko_cpl_spc_vc0_reg       => ko_cpl_spc_vc0_reg,
         cfg_link_negociated_reg  => cfg_link_negociated_reg
      );
------------------------------------------------------------
--  cpl_pending cpl_err checking
------------------------------------------------------------


   cpl_err(6 DOWNTO 1) <= (OTHERS=>'0');
   cpl_err(0)          <= cpl_err0_r;
   err_desc            <= (OTHERS=>'0');

   tx_desc_fmt_type(6 DOWNTO 0) <= tx_desc_dmawr(126 DOWNTO 120) WHEN (tx_sel_dmawr = '1') ELSE
                                       tx_desc_dmard_mux(126 DOWNTO 120);

   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         cpl_cnt_50ms <= (OTHERS=>'0');
         cpl_pending  <= '0';
         cpl_err0_r   <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         cpl_pending         <= cpl_pending_dmawr OR cpl_pending_dmard;
         IF (cpl_cnt_50ms = CNT_50MS ) THEN
            cpl_err0_r <= '1';
         ELSE
            cpl_err0_r <= '0';
         END IF;
         IF (((cpl_pending_dmawr='0') AND (cpl_pending_dmard='0')) OR
               ((tx_ack0='1') AND (tx_desc_fmt_type(4 DOWNTO 0) = "00000") AND (tx_desc_fmt_type(6)='0'))) THEN
            cpl_cnt_50ms <= (OTHERS=>'0');
         ELSIF (cpl_cnt_50ms < CNT_50MS) THEN
            cpl_cnt_50ms <= cpl_cnt_50ms+ONE_24B;
         END IF;
      END IF;
   END PROCESS;


END ARCHITECTURE altpcie;



LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
-- synthesis translate_off
-- synthesis translate_on
-------------------------------------------------------------------------------
-- Title         : PCI Express Reference Design Example Application
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcierd_tx_pipe.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This is the complete example application for the PCI Express Reference
-- Design. This has all of the application logic for the example.
-------------------------------------------------------------------------------
-- Copyright (c) 2006 Altera Corporation. All rights reserved.  Altera products are
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
ENTITY altpcierd_rxtx_pipe IS
   GENERIC (
      TXCRED_WIDTH             : INTEGER := 22
   );
   PORT (
      clk_in                   : IN STD_LOGIC;
      rstn                     : IN STD_LOGIC;

      cfg_maxpload             : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      cfg_maxrdreq             : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      cfg_busdev               : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
      cfg_devcsr               : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_tcvcmap              : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      cfg_linkcsr              : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_msicsr               : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      ko_cpl_spc_vc0           : IN STD_LOGIC_VECTOR(19 DOWNTO 0);

      cfg_link_negociated      : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      tx_cred0                 : IN STD_LOGIC_VECTOR(TXCRED_WIDTH - 1 DOWNTO 0);
      tx_mask0                 : IN STD_LOGIC;
      tx_stream_ready0         : IN STD_LOGIC;

      cfg_maxpload_reg         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      cfg_maxrdreq_reg         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      cfg_link_negociated_reg  : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      cfg_busdev_reg           : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
      cfg_devcsr_reg           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_tcvcmap_reg          : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
      cfg_linkcsr_reg          : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_msicsr_reg           : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      ko_cpl_spc_vc0_reg       : OUT STD_LOGIC_VECTOR(19 DOWNTO 0);
      tx_mask_reg              : OUT STD_LOGIC;
      tx_stream_ready0_reg     : OUT STD_LOGIC;
      tx_cred0_reg             : OUT STD_LOGIC_VECTOR(TXCRED_WIDTH - 1 DOWNTO 0)
   );
END ENTITY altpcierd_rxtx_pipe;
ARCHITECTURE altpcie OF altpcierd_rxtx_pipe IS


   FUNCTION get_numwords (
      val      : integer) RETURN integer IS

      VARIABLE rtn      : integer:=1;
   BEGIN
        rtn:=1    ;
        FOR i IN 1 TO val LOOP
            rtn := 2*rtn;
        END loop;
        RETURN rtn;
   END get_numwords;




BEGIN

   -- RX
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         tx_mask_reg             <= tx_mask0;
         tx_stream_ready0_reg    <= tx_stream_ready0;
         tx_cred0_reg            <= tx_cred0;
         cfg_maxpload_reg        <= cfg_maxpload;
         cfg_maxrdreq_reg        <= cfg_maxrdreq;
         cfg_link_negociated_reg <= cfg_link_negociated;
         cfg_busdev_reg          <= cfg_busdev;
         cfg_devcsr_reg          <=cfg_devcsr;
         cfg_tcvcmap_reg         <=cfg_tcvcmap;
         cfg_linkcsr_reg         <=cfg_linkcsr;
         cfg_msicsr_reg          <=cfg_msicsr;
         ko_cpl_spc_vc0_reg      <=ko_cpl_spc_vc0;
      END IF;
   END PROCESS;

END ARCHITECTURE altpcie;
