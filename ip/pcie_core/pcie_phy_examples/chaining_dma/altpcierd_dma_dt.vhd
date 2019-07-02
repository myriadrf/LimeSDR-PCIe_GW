LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
-- /**
--  * This Verilog HDL file is used for simulation and synthesis in
--  * the chaining DMA design example. It arbitrates PCI Express packets issued
--  * by the submodules the modules altpcierd_dma_prg_reg, altpcierd_read_dma_requester,
--  * altpcierd_write_dma_requester and altpcierd_dma_descriptor.
--  */
-- synthesis translate_on
-------------------------------------------------------------------------------
-- Title         : DMA Module using descriptor table for PCIe backend
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcierd_dma_dt.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Abbreviation :
--
--   EP      : End Point
--   RC      : Root complex
--   DT      : Descriptor Table
--   MWr     : Memory write
--   MRd     : Memory read
--   CPLD    : Completion with data
--   MSI     : PCIe Message Signaled Interrupt
--   BDT     : Base address of the descriptor header table in RC memory
--   BDT_LSB : Base address of the descriptor header table in RC memory
--   BDT_MSB : Base address of the descriptor header table in RC memory
--   BRC     : [BDT_MSB:BDT_LSB]
--   DW0     : First DWORD of the descriptor table header
--   DW1     : Second DWORD of the descriptor table header
--   DW2     : Third DWORD of the descriptor table header
--   RCLAST  : RC MWr RCLAST in EP memeory to reflects the number
--             of DMA transfers ready to start
--   EPLAST  : EP MWr EPLAST in shared memeory to reflects the number
--             of completed DMA transfers
--
-------------------------------------------------------------------------------
--  Suffix   :
--
--   tx      : PCIe Transmit signals
--   rx      : PCIe Receive signals
--   dt      : descriptor table
--
-------------------------------------------------------------------------------
--  Overview  chaining DMA operation:
--
--   The chaining DMA consist of a DMA Write and a DMA Read sub-module
--   Each DMA use a separate descriptor table mapped in the share memeory
--   The descriptor table contains a header with 3 DWORDs (DW0, DW1, DW2)
--
--       |31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16|15 .................0
--   ----|---------------------------------------------------------------------
--       | R|        |         |              |  | E|M| D |
--   DW0 | E| MSI    |         |              |  | P|S| I |
--       | S|TRAFFIC |         |              |  | L|I| R |
--       | E|CLASS   | RESERVED|  MSI         |1 | A| | E |      SIZE:Number
--       | R|        |         |  NUMBER      |  | S| | C |   of DMA descriptor
--       | V|        |         |              |  | T| | T |
--       | E|        |         |              |  |  | | I |
--       | D|        |         |              |  |  | | O |
--       |  |        |         |              |  |  | | N |
--   ----|---------------------------------------------------------------------
--   DW1 |                     BDT_MSB
--   ----|---------------------------------------------------------------------
--   DW2 |                   DT_LSB
--   ----|---------------------------------------------------------------------
--
-------------------------------------------------------------------------------
-- Module Description :
--
-- This is the section of descriptor table (dt) based DMA
-- This assume that the root complex (rc) writes the descriptor table
--
-- altpcierd_dma_dt consists of 3 modules :
--
--  - altpcierd_dma_prg_reg    : Application (RC) program the DMA
--                             RC issues 4 MWr : DW0, DW1, DW2, RCLAST
--
--  - altpcierd_dma_descriptor : EP DMA retrieve descriptor table into FIFO
--
--  - altpcierd_write_dma_requester/altpcierd_read_dma_requester : The EP DMA
--          retrieve descriptor info from FIFO and run DMA
--
-- altpcierd_dma_prg_reg : is re-used for the read DMA and the write DMA.
--                       the static parameter DIRECTION differentiates the
--                       two modes: RC issues 4 Mwr32 at BAR 2 or 3 at
--                       EP ADDR :
--                       |----------------------------------------------
--                       | DMA Write (direction = "write")
--                       |----------------------------------------------
--                       | 0h     | DW0
--                       |--------|-------------------------------------
--                       | 04h    | DW1
--                       |--------|-------------------------------------
--                       | 08h    | DW2
--                       |--------|-------------------------------------
--                       | 0ch    | RCLast
--                       |        | RC MWr RCLast : Available DMA number
--                       |----------------------------------------------
--                       | DMA Read  (direction = "read")
--                       |----------------------------------------------
--                       |10h     | DW0
--                       |--------|-------------------------------------
--                       |14h     | DW1
--                       |--------|-------------------------------------
--                       |18h     | DW2
--                       |--------|-------------------------------------
--                       |1ch     | RCLast
--                       |        | RC MWr RCLast : Available DMA number
--
--
-- altpcierd_dma_descriptor: is re-used for the read DMA and the write DMA.
--                       the static parameter DIRECTION differentiates the
--                       two modes for tag management such as when EP issues
--                       MRd
--                       TAG 8'h00            : Descriptor read
--                       TAG 8'h01            : Descriptor write
--                       TAG 8'h02 -> MAX TAG : Requester read
--
-- altpcierd_write_dma_requester : DMA Write transfer on a given descriptor
--
-- altpcierd_read_dma_requester : DMA Read transfer on a given descriptor
--
-------------------------------------------------------------------------------
--
-- altpcierd_dma_dt Parameters
--
--  DIRECTION       :  "Write" or "Read"
--  MAX_NUMTAG      :  Number of TAG available
--  FIFO_WIDTH      :  Descriptor FIFO width
--  FIFO_DEPTH      :  Descriptor FIFO depth
--  TXCRED_WIDTH    :  tx_dredit bus width
--  RC_SLAVE_USETAG :  Number of TAG used by RC Slave module
--  USE_RCSLAVE     :  When set, indicate that RC slave is being used
--  MAX_PAYLOAD     :  MAX Write payload
--  AVALON_WADDR    :  Avalon buffer address width
--  AVALON_WDATA    :  Avalon buffer data width
--  BOARD_DEMO      :  Specify which board is being used
--  USE_MSI         :  When set add MSI state machine
--  USE_CREDIT_CTRL :  When set check credit prior to MRd/MWr
--  RC_64BITS_ADDR  :  When set use 64 bits RC address
--  DISPLAY_SM      :  When set set bring State machine register to RC Slave
--
-------------------------------------------------------------------------------
-- Copyright (c) 2008 Altera Corporation. All rights reserved.  Altera products are
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
ENTITY altpcierd_dma_dt IS
   GENERIC (
      DIRECTION               : INTEGER := 1;
      MAX_NUMTAG              : INTEGER := 32;
      FIFO_WIDTHU             : INTEGER := 8;
      FIFO_DEPTH              : INTEGER := 256;
      TXCRED_WIDTH            : INTEGER := 36;
      RC_SLAVE_USETAG         : INTEGER := 0;
      USE_RCSLAVE             : INTEGER := 0;
      MAX_PAYLOAD             : INTEGER := 256;
      AVALON_WADDR            : INTEGER := 12;
      AVALON_WDATA            : INTEGER := 64;
      AVALON_ST_128           : INTEGER := 0;
      BOARD_DEMO              : INTEGER := 0;
      USE_MSI                 : INTEGER := 1;
      USE_CREDIT_CTRL         : INTEGER := 1;
      RC_64BITS_ADDR          : INTEGER := 0;
      TL_SELECTION            : INTEGER := 0;
      DISPLAY_SM              : INTEGER := 1;
      DT_EP_ADDR_SPEC         : INTEGER := 0;
      AVALON_BYTE_WIDTH       : INTEGER := 8;
      CDMA_AST_RXWS_LATENCY   : INTEGER := 2
   );
   PORT (
      clk_in                  : IN STD_LOGIC;
      rstn                    : IN STD_LOGIC;
      rx_req                  : IN STD_LOGIC;
      rx_req_p0               : IN STD_LOGIC;
      rx_req_p1               : IN STD_LOGIC;
      rx_ack                  : OUT STD_LOGIC;
      rx_ws                   : OUT STD_LOGIC;
      rx_desc                 : IN STD_LOGIC_VECTOR(135 DOWNTO 0);
      rx_data                 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      rx_be                   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      rx_dv                   : IN STD_LOGIC;
      rx_dfr                  : IN STD_LOGIC;
      rx_buffer_cpl_max_dw    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      tx_req                  : OUT STD_LOGIC;
      tx_ack                  : IN STD_LOGIC;
      tx_desc                 : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      tx_ws                   : IN STD_LOGIC;
      tx_err                  : OUT STD_LOGIC;
      tx_dv                   : OUT STD_LOGIC;
      tx_dfr                  : OUT STD_LOGIC;
      tx_data                 : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      tx_sel_descriptor       : IN STD_LOGIC;
      tx_busy_descriptor      : OUT STD_LOGIC;
      tx_ready_descriptor     : OUT STD_LOGIC;
      tx_sel_requester        : IN STD_LOGIC;
      tx_busy_requester       : OUT STD_LOGIC;
      tx_ready_requester      : OUT STD_LOGIC;
      tx_ready_other_dma      : IN STD_LOGIC;
      tx_cred                 : IN STD_LOGIC_VECTOR(TXCRED_WIDTH - 1 DOWNTO 0);
      app_msi_ack             : IN STD_LOGIC;
      app_msi_req             : OUT STD_LOGIC;
      app_msi_tc              : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      app_msi_num             : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      msi_sel                 : IN STD_LOGIC;
      msi_ready               : OUT STD_LOGIC;
      msi_busy                : OUT STD_LOGIC;
      cfg_maxpload            : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      cfg_maxrdreq            : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      cfg_maxpload_dw         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      cfg_maxrdreq_dw         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      cfg_busdev              : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
      cfg_link_negociated     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      write_data              : OUT STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      write_address           : OUT STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
      write                   : OUT STD_LOGIC;
      write_wait              : OUT STD_LOGIC;
      write_byteena           : OUT STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0);
      read_data               : IN STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      read_address            : OUT STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
      read                    : OUT STD_LOGIC;
      read_wait               : OUT STD_LOGIC;
      dma_sm                  : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
      cpl_pending             : OUT STD_LOGIC;
      descriptor_mrd_cycle    : OUT STD_LOGIC;
      requester_mrdmwr_cycle  : OUT STD_LOGIC;
      dma_prg_wrdata          : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      dma_prg_addr            : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      dma_prg_wrena           : IN STD_LOGIC;
      dma_prg_rddata          : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      dma_status              : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      init                    : OUT STD_LOGIC
   );
END ENTITY altpcierd_dma_dt;
ARCHITECTURE altpcie OF altpcierd_dma_dt IS

CONSTANT MAX_NUMTAG_LIMIT        : INTEGER := MAX_NUMTAG;
CONSTANT FIFO_WIDTH              : INTEGER := 64 * (AVALON_ST_128 + 1);

   COMPONENT altpcierd_dma_descriptor IS
      GENERIC (
         RC_64BITS_ADDR          : INTEGER := 0;
         MAX_NUMTAG              : INTEGER := 32;
         DIRECTION               : INTEGER := 1;
         FIFO_DEPTH              : INTEGER := 256;
         FIFO_WIDTHU             : INTEGER := 8;
         FIFO_WIDTH              : INTEGER := 64;
         TXCRED_WIDTH            : INTEGER := 22;
         AVALON_ST_128           : INTEGER := 0;
         USE_CREDIT_CTRL         : INTEGER := 1;
         CDMA_AST_RXWS_LATENCY   : INTEGER := 2
      );
      PORT (
         dt_rc_last              : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         dt_rc_last_sync         : IN STD_LOGIC;
         dt_size                 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         dt_base_rc              : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
         dt_3dw_rcadd            : IN STD_LOGIC;
         dt_fifo_rdreq           : IN STD_LOGIC;
         dt_fifo_empty           : OUT STD_LOGIC;
         dt_fifo_q               : OUT STD_LOGIC_VECTOR(FIFO_WIDTH - 1 DOWNTO 0);
         dt_fifo_q_4K_bound      : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
         cfg_maxrdreq_dw         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         tx_sel                  : IN STD_LOGIC;
         tx_ready                : OUT STD_LOGIC;
         tx_busy                 : OUT STD_LOGIC;
         tx_cred                 : IN STD_LOGIC_VECTOR(TXCRED_WIDTH - 1 DOWNTO 0);
         tx_req                  : OUT STD_LOGIC;
         tx_ack                  : IN STD_LOGIC;
         tx_desc                 : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
         tx_ws                   : IN STD_LOGIC;
         rx_buffer_cpl_max_dw    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         rx_req                  : IN STD_LOGIC;
         rx_ack                  : OUT STD_LOGIC;
         rx_desc                 : IN STD_LOGIC_VECTOR(135 DOWNTO 0);
         rx_data                 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
         rx_dv                   : IN STD_LOGIC;
         rx_dfr                  : IN STD_LOGIC;
         init                    : IN STD_LOGIC;
         descriptor_mrd_cycle    : OUT STD_LOGIC;
         dma_sm                  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
         cpl_pending             : OUT STD_LOGIC;
         clk_in                  : IN STD_LOGIC;
         rstn                    : IN STD_LOGIC
      );
   END COMPONENT;

   COMPONENT altpcierd_read_dma_requester IS
      GENERIC (
         MAX_NUMTAG              : INTEGER := 32;
         USE_RCSLAVE             : INTEGER := 1;
         RC_SLAVE_USETAG         : INTEGER := 0;
         FIFO_WIDTH              : INTEGER := 64;
         TXCRED_WIDTH            : INTEGER := 22;
         AVALON_WADDR            : INTEGER := 12;
         AVALON_WDATA            : INTEGER := 64;
         BOARD_DEMO              : INTEGER := 0;
         USE_MSI                 : INTEGER := 1;
         USE_CREDIT_CTRL         : INTEGER := 1;
         RC_64BITS_ADDR          : INTEGER := 0;
         AVALON_BYTE_WIDTH       : INTEGER := 8;
         DT_EP_ADDR_SPEC         : INTEGER := 2;
         CDMA_AST_RXWS_LATENCY   : INTEGER := 2
      );
      PORT (
         dt_fifo_rdreq           : OUT STD_LOGIC;
         dt_fifo_empty           : IN STD_LOGIC;
         dt_fifo_q               : IN STD_LOGIC_VECTOR(FIFO_WIDTH - 1 DOWNTO 0);
         cfg_maxrdreq_dw         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         cfg_maxrdreq            : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
         cfg_link_negociated     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
         dt_base_rc              : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
         dt_3dw_rcadd            : IN STD_LOGIC;
         dt_eplast_ena           : IN STD_LOGIC;
         dt_msi                  : IN STD_LOGIC;
         dt_size                 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         tx_ready                : OUT STD_LOGIC;
         tx_busy                 : OUT STD_LOGIC;
         tx_sel                  : IN STD_LOGIC;
         tx_cred                 : IN STD_LOGIC_VECTOR(TXCRED_WIDTH - 1 DOWNTO 0);
         tx_ack                  : IN STD_LOGIC;
         tx_ws                   : IN STD_LOGIC;
         tx_req                  : OUT STD_LOGIC;
         tx_dv                   : OUT STD_LOGIC;
         tx_dfr                  : OUT STD_LOGIC;
         tx_desc                 : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
         tx_data                 : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
         rx_buffer_cpl_max_dw    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         rx_req                  : IN STD_LOGIC;
         rx_ack                  : OUT STD_LOGIC;
         rx_desc                 : IN STD_LOGIC_VECTOR(135 DOWNTO 0);
         rx_data                 : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
         rx_be                   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         rx_dv                   : IN STD_LOGIC;
         rx_dfr                  : IN STD_LOGIC;
         rx_ws                   : OUT STD_LOGIC;
         app_msi_ack             : IN STD_LOGIC;
         app_msi_req             : OUT STD_LOGIC;
         msi_sel                 : IN STD_LOGIC;
         msi_ready               : OUT STD_LOGIC;
         msi_busy                : OUT STD_LOGIC;
         writedata               : OUT STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
         address                 : OUT STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
         write                   : OUT STD_LOGIC;
         waitrequest             : OUT STD_LOGIC;
         write_byteena           : OUT STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0);
         descriptor_mrd_cycle    : IN STD_LOGIC;
         requester_mrdmwr_cycle  : OUT STD_LOGIC;
         dma_sm_tx               : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
         dma_sm_rx               : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
         dma_sm_rx_data          : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
         dma_status              : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
         cpl_pending             : OUT STD_LOGIC;
         init                    : IN STD_LOGIC;
         clk_in                  : IN STD_LOGIC;
         rstn                    : IN STD_LOGIC
      );
   END COMPONENT;

   COMPONENT altpcierd_dma_prg_reg IS
      GENERIC (
         RC_64BITS_ADDR          : INTEGER := 0;
         AVALON_ST_128           : INTEGER := 0
      );
      PORT (
         dma_prg_wrena           : IN STD_LOGIC;
         dma_prg_wrdata          : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
         dma_prg_addr            : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
         dma_prg_rddata          : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

         dt_rc_last              : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
         dt_rc_last_sync         : OUT STD_LOGIC;
         dt_size                 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
         dt_base_rc              : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
         dt_eplast_ena           : OUT STD_LOGIC;
         dt_msi                  : OUT STD_LOGIC;
         dt_3dw_rcadd            : OUT STD_LOGIC;
         app_msi_num             : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
         app_msi_tc              : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
         init                    : OUT STD_LOGIC;
         clk_in                  : IN STD_LOGIC;
         rstn                    : IN STD_LOGIC
      );
   END COMPONENT;

   COMPONENT altpcierd_write_dma_requester IS
      GENERIC (
         MAX_PAYLOAD             : INTEGER := 256;
         MAX_NUMTAG              : INTEGER := 32;
         USE_RCSLAVE             : INTEGER := 0;
         FIFO_WIDTH              : INTEGER := 64;
         AVALON_WADDR            : INTEGER := 12;
         AVALON_WDATA            : INTEGER := 64;
         BOARD_DEMO              : INTEGER := 0;
         USE_MSI                 : INTEGER := 1;
         TXCRED_WIDTH            : INTEGER := 22;
         DMA_QWORD_ALIGN         : INTEGER := 0;
         RC_64BITS_ADDR          : INTEGER := 0;
         TL_SELECTION            : INTEGER := 0;
         USE_CREDIT_CTRL         : INTEGER := 1;
         DT_EP_ADDR_SPEC         : INTEGER := 2
      );
      PORT (
         dt_fifo_rdreq           : OUT STD_LOGIC;
         dt_fifo_empty           : IN STD_LOGIC;
         dt_fifo_q               : IN STD_LOGIC_VECTOR(FIFO_WIDTH - 1 DOWNTO 0);
         dt_fifo_q_4K_bound      : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
         cfg_maxpload_dw         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         cfg_maxpload            : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
         cfg_link_negociated     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
         dt_base_rc              : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
         dt_3dw_rcadd            : IN STD_LOGIC;
         dt_eplast_ena           : IN STD_LOGIC;
         dt_msi                  : IN STD_LOGIC;
         dt_size                 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         tx_ready_dmard          : IN STD_LOGIC;
         tx_ready                : OUT STD_LOGIC;
         tx_busy                 : OUT STD_LOGIC;
         tx_sel                  : IN STD_LOGIC;
         tx_cred                 : IN STD_LOGIC_VECTOR(TXCRED_WIDTH - 1 DOWNTO 0);
         tx_req                  : OUT STD_LOGIC;
         tx_dv                   : OUT STD_LOGIC;
         tx_dfr                  : OUT STD_LOGIC;
         tx_ack                  : IN STD_LOGIC;
         tx_desc                 : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
         tx_data                 : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
         tx_ws                   : IN STD_LOGIC;
         app_msi_ack             : IN STD_LOGIC;
         app_msi_req             : OUT STD_LOGIC;
         msi_sel                 : IN STD_LOGIC;
         msi_ready               : OUT STD_LOGIC;
         msi_busy                : OUT STD_LOGIC;
         address                 : OUT STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
         waitrequest             : OUT STD_LOGIC;
         read                    : OUT STD_LOGIC;
         readdata                : IN STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
         descriptor_mrd_cycle    : IN STD_LOGIC;
         requester_mrdmwr_cycle  : OUT STD_LOGIC;
         dma_sm                  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
         dma_status              : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
         init                    : IN STD_LOGIC;
         clk_in                  : IN STD_LOGIC;
         rstn                    : IN STD_LOGIC
      );
   END COMPONENT;

   COMPONENT altpcierd_write_dma_requester_128 IS
      GENERIC (
         MAX_PAYLOAD             : INTEGER := 256;
         MAX_NUMTAG              : INTEGER := 32;
         USE_RCSLAVE             : INTEGER := 0;
         FIFO_WIDTH              : INTEGER := 128;
         AVALON_WADDR            : INTEGER := 12;
         AVALON_WDATA            : INTEGER := 128;
         BOARD_DEMO              : INTEGER := 0;
         USE_MSI                 : INTEGER := 1;
         TXCRED_WIDTH            : INTEGER := 22;
         DMA_QWORD_ALIGN         : INTEGER := 0;
         RC_64BITS_ADDR          : INTEGER := 0;
         TL_SELECTION            : INTEGER := 0;
         USE_CREDIT_CTRL         : INTEGER := 1;
         DT_EP_ADDR_SPEC         : INTEGER := 2
      );
      PORT (
         dt_fifo_rdreq           : OUT STD_LOGIC;
         dt_fifo_empty           : IN STD_LOGIC;
         dt_fifo_q               : IN STD_LOGIC_VECTOR(FIFO_WIDTH - 1 DOWNTO 0);
         dt_fifo_q_4K_bound      : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
         cfg_maxpload_dw         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         cfg_maxpload            : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
         cfg_link_negociated     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
         dt_base_rc              : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
         dt_3dw_rcadd            : IN STD_LOGIC;
         dt_eplast_ena           : IN STD_LOGIC;
         dt_msi                  : IN STD_LOGIC;
         dt_size                 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         tx_ready_dmard          : IN STD_LOGIC;
         tx_ready                : OUT STD_LOGIC;
         tx_busy                 : OUT STD_LOGIC;
         tx_sel                  : IN STD_LOGIC;
         tx_cred                 : IN STD_LOGIC_VECTOR(TXCRED_WIDTH - 1 DOWNTO 0);
         tx_req                  : OUT STD_LOGIC;
         tx_dv                   : OUT STD_LOGIC;
         tx_dfr                  : OUT STD_LOGIC;
         tx_ack                  : IN STD_LOGIC;
         tx_desc                 : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
         tx_data                 : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
         tx_ws                   : IN STD_LOGIC;
         app_msi_ack             : IN STD_LOGIC;
         app_msi_req             : OUT STD_LOGIC;
         msi_sel                 : IN STD_LOGIC;
         msi_ready               : OUT STD_LOGIC;
         msi_busy                : OUT STD_LOGIC;
         address                 : OUT STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
         waitrequest             : OUT STD_LOGIC;
         read                    : OUT STD_LOGIC;
         readdata                : IN STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
         descriptor_mrd_cycle    : IN STD_LOGIC;
         requester_mrdmwr_cycle  : OUT STD_LOGIC;
         dma_sm                  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
         dma_status              : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
         init                    : IN STD_LOGIC;
         clk_in                  : IN STD_LOGIC;
         rstn                    : IN STD_LOGIC
      );
   END COMPONENT;

   COMPONENT altpcierd_read_dma_requester_128 IS
      GENERIC (
         MAX_NUMTAG              : INTEGER := 32;
         USE_RCSLAVE             : INTEGER := 1;
         RC_SLAVE_USETAG         : INTEGER := 0;
         FIFO_WIDTH              : INTEGER := 128;
         TXCRED_WIDTH            : INTEGER := 36;
         AVALON_WADDR            : INTEGER := 12;
         AVALON_WDATA            : INTEGER := 128;
         BOARD_DEMO              : INTEGER := 0;
         USE_MSI                 : INTEGER := 1;
         USE_CREDIT_CTRL         : INTEGER := 1;
         RC_64BITS_ADDR          : INTEGER := 0;
         AVALON_BYTE_WIDTH       : INTEGER := 16;
         DT_EP_ADDR_SPEC         : INTEGER := 2;
         CDMA_AST_RXWS_LATENCY   : INTEGER := 2
      );
      PORT (
         dt_fifo_rdreq           : OUT STD_LOGIC;
         dt_fifo_empty           : IN STD_LOGIC;
         dt_fifo_q               : IN STD_LOGIC_VECTOR(FIFO_WIDTH - 1 DOWNTO 0);
         cfg_maxrdreq_dw         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         cfg_maxrdreq            : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
         cfg_link_negociated     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
         dt_base_rc              : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
         dt_3dw_rcadd            : IN STD_LOGIC;
         dt_eplast_ena           : IN STD_LOGIC;
         dt_msi                  : IN STD_LOGIC;
         dt_size                 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         tx_ready                : OUT STD_LOGIC;
         tx_busy                 : OUT STD_LOGIC;
         tx_sel                  : IN STD_LOGIC;
         tx_cred                 : IN STD_LOGIC_VECTOR(TXCRED_WIDTH - 1 DOWNTO 0);
         tx_ack                  : IN STD_LOGIC;
         tx_ws                   : IN STD_LOGIC;
         tx_req                  : OUT STD_LOGIC;
         tx_dv                   : OUT STD_LOGIC;
         tx_dfr                  : OUT STD_LOGIC;
         tx_desc                 : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
         tx_data                 : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
         rx_buffer_cpl_max_dw    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         rx_req                  : IN STD_LOGIC;
         rx_ack                  : OUT STD_LOGIC;
         rx_desc                 : IN STD_LOGIC_VECTOR(135 DOWNTO 0);
         rx_data                 : IN STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
         rx_be                   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         rx_dv                   : IN STD_LOGIC;
         rx_dfr                  : IN STD_LOGIC;
         rx_ws                   : OUT STD_LOGIC;
         app_msi_ack             : IN STD_LOGIC;
         app_msi_req             : OUT STD_LOGIC;
         msi_sel                 : IN STD_LOGIC;
         msi_ready               : OUT STD_LOGIC;
         msi_busy                : OUT STD_LOGIC;
         writedata               : OUT STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
         address                 : OUT STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
         write                   : OUT STD_LOGIC;
         waitrequest             : OUT STD_LOGIC;
         write_byteena           : OUT STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0);
         descriptor_mrd_cycle    : IN STD_LOGIC;
         requester_mrdmwr_cycle  : OUT STD_LOGIC;
         dma_sm_tx               : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
         dma_sm_rx               : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
         dma_sm_rx_data          : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
         dma_status              : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
         cpl_pending             : OUT STD_LOGIC;
         init                    : IN STD_LOGIC;
         clk_in                  : IN STD_LOGIC;
         rstn                    : IN STD_LOGIC
      );
   END COMPONENT;


   --////////////////////////////////////////////////////////////////////////////
   -- DMA Program Register specific signals  (module altpcierd_dma_prg_reg)
   --
   -- specify the # of the last descripor upadted by RC host/application

   SIGNAL dt_rc_last                    : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL dt_rc_last_sync               : STD_LOGIC;
   SIGNAL dt_3dw_rcadd                  : STD_LOGIC;

   --// specify the size of the descripor table in RC memeory (how many descriptors)
   SIGNAL dt_size                       : STD_LOGIC_VECTOR(15 DOWNTO 0);
   --// Base address of the descriptor table
   SIGNAL dt_base_rc                    : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL dt_eplast_ena                 : STD_LOGIC;
   SIGNAL dt_msi                        : STD_LOGIC;
   SIGNAL ep_last_sent_to_rc            : STD_LOGIC;
   SIGNAL dt_fifo_empty                 : STD_LOGIC;

   -- Descriptor control signals
   SIGNAL tx_req_descriptor             : STD_LOGIC;
   SIGNAL tx_desc_descriptor            : STD_LOGIC_VECTOR(127 DOWNTO 0);

   -- Requester control signals
   SIGNAL tx_req_requester              : STD_LOGIC;
   SIGNAL tx_desc_requester             : STD_LOGIC_VECTOR(127 DOWNTO 0);

   -- Rx signals from the 3 modules
   SIGNAL rx_ack_dma_prg                : STD_LOGIC;
   SIGNAL rx_ack_descriptor             : STD_LOGIC;
   SIGNAL rx_ack_requester              : STD_LOGIC;
   SIGNAL rx_ws_requester               : STD_LOGIC;

   SIGNAL dt_fifo_rdreq                 : STD_LOGIC;
   SIGNAL dt_fifo_q                     : STD_LOGIC_VECTOR(FIFO_WIDTH - 1 DOWNTO 0);
   SIGNAL dt_fifo_q_4K_bound            : STD_LOGIC_VECTOR(12 DOWNTO 0);
   -- rx ctrl outputs

   -- Debug output

   SIGNAL dma_sm_req                    : STD_LOGIC_VECTOR(6 DOWNTO 0);     -- read   wire [3:0]  dma_sm_tx_rd;
   --        wire [2:0]  dma_sm_rx_rd; // read
   -- read   wire [3:0]
   SIGNAL dma_sm_desc                   : STD_LOGIC_VECTOR(3 DOWNTO 0);

   -- Declare intermediate signals for referenced outputs
   SIGNAL tx_dv_xhdl15                  : STD_LOGIC;
   SIGNAL tx_dfr_xhdl14                 : STD_LOGIC;
   SIGNAL tx_data_xhdl13                : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL tx_busy_descriptor_xhdl11     : STD_LOGIC;
   SIGNAL tx_ready_descriptor_xhdl16    : STD_LOGIC;
   SIGNAL tx_busy_requester_xhdl12      : STD_LOGIC;
   SIGNAL tx_ready_requester_xhdl17     : STD_LOGIC;
   SIGNAL app_msi_req_xhdl1             : STD_LOGIC;
   SIGNAL app_msi_tc_xhdl2              : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL app_msi_num_xhdl0             : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL msi_ready_xhdl6               : STD_LOGIC;
   SIGNAL msi_busy_xhdl5                : STD_LOGIC;
   SIGNAL write_data_xhdl21             : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   SIGNAL write_address_xhdl19          : STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
   SIGNAL write_xhdl18                  : STD_LOGIC;
   SIGNAL write_wait_xhdl22             : STD_LOGIC;
   SIGNAL write_byteena_xhdl20          : STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0);
   SIGNAL read_address_xhdl8            : STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
   SIGNAL read_xhdl7                    : STD_LOGIC;
   SIGNAL read_wait_xhdl9               : STD_LOGIC;
   SIGNAL descriptor_mrd_cycle_xhdl3    : STD_LOGIC;
   SIGNAL requester_mrdmwr_cycle_xhdl10 : STD_LOGIC;
   SIGNAL init_xhdl4                    : STD_LOGIC;

   SIGNAL cpl_pending_descriptor        : STD_LOGIC;
   SIGNAL cpl_pending_requestor         : STD_LOGIC;

BEGIN
   -- Drive referenced outputs
   tx_dv <= tx_dv_xhdl15;
   tx_dfr <= tx_dfr_xhdl14;
   tx_data <= tx_data_xhdl13;
   tx_busy_descriptor <= tx_busy_descriptor_xhdl11;
   tx_ready_descriptor <= tx_ready_descriptor_xhdl16;
   tx_busy_requester <= tx_busy_requester_xhdl12;
   tx_ready_requester <= tx_ready_requester_xhdl17;
   app_msi_req <= app_msi_req_xhdl1;
   app_msi_tc <= app_msi_tc_xhdl2;
   app_msi_num <= app_msi_num_xhdl0;
   msi_ready <= msi_ready_xhdl6;
   msi_busy <= msi_busy_xhdl5;
   write_data <= write_data_xhdl21;
   write_address <= write_address_xhdl19;
   write <= write_xhdl18;
   write_wait <= write_wait_xhdl22;
   write_byteena <= write_byteena_xhdl20;
   read_address <= read_address_xhdl8;
   read <= read_xhdl7;
   read_wait <= read_wait_xhdl9;
   descriptor_mrd_cycle <= descriptor_mrd_cycle_xhdl3;
   requester_mrdmwr_cycle <= requester_mrdmwr_cycle_xhdl10;
   init <= init_xhdl4;
   rx_ack <= rx_ack_descriptor OR rx_ack_requester;
   tx_err <= '0';
   rx_ws <= rx_ws_requester;
   cpl_pending <= cpl_pending_requestor OR cpl_pending_descriptor;

   --////////////////////////////////////////////////////////////////////////////
   --
   -- TX Arbitration between descriptor and requester modules
   -- tx_busy  : when 1; the module is driving tx_req, tx_desc, tx_data
   -- tx_ready : when 1; the module is ready to drive tx_req, tx_desc, tx_data
   -- tx_sel   : when 1; enable the module state to drive tx_req, tx_desc, tx_data
   tx_req <= tx_req_descriptor WHEN (tx_sel_descriptor = '1') ELSE
             tx_req_requester;
   tx_desc <= tx_desc_descriptor WHEN (tx_sel_descriptor = '1') ELSE
              tx_desc_requester;

   -- RC program EP DT issuning mwr (32 bits)


   dma_prg : altpcierd_dma_prg_reg
      GENERIC MAP (
         RC_64BITS_ADDR         => RC_64BITS_ADDR,
         AVALON_ST_128          => AVALON_ST_128
      )
      PORT MAP (
         dma_prg_wrena    => dma_prg_wrena,
         dma_prg_wrdata   => dma_prg_wrdata,
         dma_prg_addr     => dma_prg_addr,
         dma_prg_rddata   => dma_prg_rddata,

         dt_rc_last       => dt_rc_last,
         dt_rc_last_sync  => dt_rc_last_sync,
         dt_size          => dt_size,
         dt_base_rc       => dt_base_rc,
         dt_eplast_ena    => dt_eplast_ena,
         dt_msi           => dt_msi,
         dt_3dw_rcadd     => dt_3dw_rcadd,
         app_msi_tc       => app_msi_tc_xhdl2,
         app_msi_num      => app_msi_num_xhdl0,

         init             => init_xhdl4,

         clk_in           => clk_in,
         rstn             => rstn
      );

   -- EP retrieve descriptor from RC
   -- if direction write
   -- tag : 0--> MAX_NUMTAG=1, MAX_NUMTAG-1=1, [TAG used for DMA]
   -- if direction read
   -- tag : 0--> MAX_NUMTAG=0, MAX_NUMTAG-1=1, [TAG used for DMA]


   descriptor : altpcierd_dma_descriptor
      GENERIC MAP (
         RC_64BITS_ADDR         => RC_64BITS_ADDR,
         MAX_NUMTAG             => MAX_NUMTAG_LIMIT,
         DIRECTION              => DIRECTION,
         USE_CREDIT_CTRL        => USE_CREDIT_CTRL,
         TXCRED_WIDTH           => TXCRED_WIDTH,
         FIFO_DEPTH             => FIFO_DEPTH,
         FIFO_WIDTHU            => FIFO_WIDTHU,
         AVALON_ST_128          => AVALON_ST_128,
         FIFO_WIDTH             => FIFO_WIDTH,
         CDMA_AST_RXWS_LATENCY  => CDMA_AST_RXWS_LATENCY
      )
      PORT MAP (
         init                  => init_xhdl4,
         dt_rc_last            => dt_rc_last,
         dt_rc_last_sync       => dt_rc_last_sync,
         dt_base_rc            => dt_base_rc,
         dt_size               => dt_size,

         dt_fifo_rdreq         => dt_fifo_rdreq,
         dt_fifo_empty         => dt_fifo_empty,
         dt_fifo_q             => dt_fifo_q,
         dt_fifo_q_4K_bound    => dt_fifo_q_4K_bound,
         dt_3dw_rcadd          => dt_3dw_rcadd,

         -- PCIe config info
         cfg_maxrdreq_dw       => cfg_maxrdreq_dw,

         -- PCIe backend Transmit section
         tx_ready              => tx_ready_descriptor_xhdl16,
         tx_sel                => tx_sel_descriptor,
         tx_busy               => tx_busy_descriptor_xhdl11,
         tx_cred               => tx_cred,
         tx_req                => tx_req_descriptor,
         tx_ack                => tx_ack,
         tx_desc               => tx_desc_descriptor,
         tx_ws                 => tx_ws,
         rx_buffer_cpl_max_dw  => rx_buffer_cpl_max_dw,

         cpl_pending          => cpl_pending_descriptor,

         -- PCIe backend Receive section
         rx_req                => rx_req,
         rx_ack                => rx_ack_descriptor,
         rx_desc               => rx_desc,
         rx_data               => rx_data,
         rx_dv                 => rx_dv,
         rx_dfr                => rx_dfr,
         dma_sm                => dma_sm_desc,
         descriptor_mrd_cycle  => descriptor_mrd_cycle_xhdl3,
         clk_in                => clk_in,
         rstn                  => rstn
      );

   -- Instanciation of DMA Requestor (Read or Write)
   xhdl23 : IF ((DIRECTION = 1) AND (AVALON_ST_128 = 0)) GENERATE
      -- altpcierd_write_dma_requester
      -- Transfer data from EP memory to RC memory


      write_requester : altpcierd_write_dma_requester
         GENERIC MAP (
            RC_64BITS_ADDR   => RC_64BITS_ADDR,
            FIFO_WIDTH       => FIFO_WIDTH,
            USE_CREDIT_CTRL  => USE_CREDIT_CTRL,
            TXCRED_WIDTH     => TXCRED_WIDTH,
            USE_MSI          => USE_MSI,
            USE_RCSLAVE      => USE_RCSLAVE,
            BOARD_DEMO       => BOARD_DEMO,
            MAX_NUMTAG       => MAX_NUMTAG_LIMIT,
            TL_SELECTION     => TL_SELECTION,
            MAX_PAYLOAD      => MAX_PAYLOAD,
            AVALON_WADDR     => AVALON_WADDR,
            AVALON_WDATA     => 64,
            DT_EP_ADDR_SPEC  => DT_EP_ADDR_SPEC
         )
         PORT MAP (
            dt_fifo_rdreq           => dt_fifo_rdreq,
            dt_fifo_empty           => dt_fifo_empty,
            dt_fifo_q               => dt_fifo_q,
            dt_fifo_q_4K_bound      => dt_fifo_q_4K_bound,

            -- PCIe config info
            cfg_maxpload_dw         => cfg_maxpload_dw,
            cfg_maxpload            => cfg_maxpload,
            cfg_link_negociated     => cfg_link_negociated,

            -- DMA Prg signals register
            dt_base_rc              => dt_base_rc,
            dt_3dw_rcadd            => dt_3dw_rcadd,
            dt_eplast_ena           => dt_eplast_ena,
            dt_msi                  => dt_msi,
            dt_size                 => dt_size,

            -- PCIe backend Transmit section
            tx_ready                => tx_ready_requester_xhdl17,
            tx_sel                  => tx_sel_requester,
            tx_busy                 => tx_busy_requester_xhdl12,
            tx_ready_dmard          => tx_ready_other_dma,
            tx_cred                 => tx_cred,
            tx_req                  => tx_req_requester,
            tx_ack                  => tx_ack,
            tx_desc                 => tx_desc_requester,
            tx_data                 => tx_data_xhdl13(63 DOWNTO 0),
            tx_dfr                  => tx_dfr_xhdl14,
            tx_dv                   => tx_dv_xhdl15,
            tx_ws                   => tx_ws,

            --MSI
            app_msi_ack             => app_msi_ack,
            app_msi_req             => app_msi_req_xhdl1,
            msi_sel                 => msi_sel,
            msi_ready               => msi_ready_xhdl6,
            msi_busy                => msi_busy_xhdl5,

            -- Avalon back end
            address                 => read_address_xhdl8,
            waitrequest             => read_wait_xhdl9,
            read                    => read_xhdl7,
            readdata                => read_data(63 downto 0),

            dma_sm                  => dma_sm_req(3 DOWNTO 0),
            descriptor_mrd_cycle    => descriptor_mrd_cycle_xhdl3,
            requester_mrdmwr_cycle  => requester_mrdmwr_cycle_xhdl10,
            init                    => init_xhdl4,
            clk_in                  => clk_in,
            rstn                    => rstn
         );
      tx_data_xhdl13(127 DOWNTO 64) <= "0000000000000000000000000000000000000000000000000000000000000000";
      write_xhdl18 <= '0';
      write_wait_xhdl22 <= '0';
      rx_ack_requester <= '0';
      rx_ws_requester <= '0';
      dma_sm_req(6 DOWNTO 4) <= "000";
      write_byteena_xhdl20 <= (others=>'0');
      cpl_pending_requestor <= '0';

   END GENERATE;
   xhdl24 : IF (NOT((DIRECTION = 1) AND (AVALON_ST_128 = 0))) GENERATE
      xhdl25 : IF ((DIRECTION = 1) AND (AVALON_ST_128 = 1)) GENERATE
         -- altpcierd_write_dma_requester
         -- Transfer data from EP memory to RC memory


         write_requester_128 : altpcierd_write_dma_requester_128
            GENERIC MAP (
               RC_64BITS_ADDR   => RC_64BITS_ADDR,
               FIFO_WIDTH       => FIFO_WIDTH,
               USE_CREDIT_CTRL  => USE_CREDIT_CTRL,
               TXCRED_WIDTH     => TXCRED_WIDTH,
               USE_MSI          => USE_MSI,
               USE_RCSLAVE      => USE_RCSLAVE,
               BOARD_DEMO       => BOARD_DEMO,
               MAX_NUMTAG       => MAX_NUMTAG_LIMIT,
               TL_SELECTION     => TL_SELECTION,
               MAX_PAYLOAD      => MAX_PAYLOAD,
               AVALON_WADDR     => AVALON_WADDR,
               AVALON_WDATA     => AVALON_WDATA,
               DT_EP_ADDR_SPEC  => DT_EP_ADDR_SPEC
            )
            PORT MAP (
               dt_fifo_rdreq           => dt_fifo_rdreq,
               dt_fifo_empty           => dt_fifo_empty,
               dt_fifo_q               => dt_fifo_q,
               dt_fifo_q_4K_bound      => dt_fifo_q_4K_bound,

               -- PCIe config info
               cfg_maxpload_dw         => cfg_maxpload_dw,
               cfg_maxpload            => cfg_maxpload,
               cfg_link_negociated     => cfg_link_negociated,

               -- DMA Prg signals register
               dt_base_rc              => dt_base_rc,
               dt_3dw_rcadd            => dt_3dw_rcadd,
               dt_eplast_ena           => dt_eplast_ena,
               dt_msi                  => dt_msi,
               dt_size                 => dt_size,

               -- PCIe backend Transmit section
               tx_ready                => tx_ready_requester_xhdl17,
               tx_sel                  => tx_sel_requester,
               tx_busy                 => tx_busy_requester_xhdl12,
               tx_ready_dmard          => tx_ready_other_dma,
               tx_cred                 => tx_cred,
               tx_req                  => tx_req_requester,
               tx_ack                  => tx_ack,
               tx_desc                 => tx_desc_requester,
               tx_data                 => tx_data_xhdl13(127 DOWNTO 0),
               tx_dfr                  => tx_dfr_xhdl14,
               tx_dv                   => tx_dv_xhdl15,
               tx_ws                   => tx_ws,

               --MSI
               app_msi_ack             => app_msi_ack,
               app_msi_req             => app_msi_req_xhdl1,
               msi_sel                 => msi_sel,
               msi_ready               => msi_ready_xhdl6,
               msi_busy                => msi_busy_xhdl5,

               -- Avalon back end
               address                 => read_address_xhdl8,
               waitrequest             => read_wait_xhdl9,
               read                    => read_xhdl7,
               readdata                => read_data,

               dma_sm                  => dma_sm_req(3 DOWNTO 0),
               descriptor_mrd_cycle    => descriptor_mrd_cycle_xhdl3,
               requester_mrdmwr_cycle  => requester_mrdmwr_cycle_xhdl10,

               dma_status              => dma_status,
               init                    => init_xhdl4,
               clk_in                  => clk_in,
               rstn                    => rstn
            );
         write_xhdl18 <= '0';
         write_wait_xhdl22 <= '0';
         rx_ack_requester <= '0';
         rx_ws_requester <= '0';
         dma_sm_req(6 DOWNTO 4) <= "000";
         write_byteena_xhdl20 <= (others=>'0');
         cpl_pending_requestor <= '0';

      END GENERATE;
      xhdl26 : IF (NOT((DIRECTION = 1) AND (AVALON_ST_128 = 1))) GENERATE
         xhdl27 : IF (AVALON_ST_128 = 1) GENERATE
            -- altpcierd_read_dma_requester
            -- Transfer data RC memory to EP memeory


            read_requester_128 : altpcierd_read_dma_requester_128
               GENERIC MAP (
                  RC_64BITS_ADDR         => RC_64BITS_ADDR,
                  FIFO_WIDTH             => FIFO_WIDTH,
                  MAX_NUMTAG             => MAX_NUMTAG_LIMIT,
                  USE_CREDIT_CTRL        => USE_CREDIT_CTRL,
                  TXCRED_WIDTH           => TXCRED_WIDTH,
                  BOARD_DEMO             => BOARD_DEMO,
                  USE_MSI                => USE_MSI,
                  AVALON_WADDR           => AVALON_WADDR,
                  AVALON_WDATA           => AVALON_WDATA,
                  USE_RCSLAVE            => USE_RCSLAVE,
                  RC_SLAVE_USETAG        => RC_SLAVE_USETAG,
                  DT_EP_ADDR_SPEC        => DT_EP_ADDR_SPEC,
                  CDMA_AST_RXWS_LATENCY  => CDMA_AST_RXWS_LATENCY
               )
               PORT MAP (
                  dt_fifo_rdreq           => dt_fifo_rdreq,
                  dt_fifo_empty           => dt_fifo_empty,
                  dt_fifo_q               => dt_fifo_q,

                  -- PCIe config info
                  cfg_maxrdreq_dw         => cfg_maxrdreq_dw,
                  cfg_maxrdreq            => cfg_maxrdreq,
                  cfg_link_negociated     => cfg_link_negociated,

                  -- DMA Prg signals register
                  dt_base_rc              => dt_base_rc,
                  dt_3dw_rcadd            => dt_3dw_rcadd,
                  dt_eplast_ena           => dt_eplast_ena,
                  dt_msi                  => dt_msi,
                  dt_size                 => dt_size,

                  -- PCIe backend Transmit section
                  tx_ready                => tx_ready_requester_xhdl17,
                  tx_sel                  => tx_sel_requester,
                  tx_busy                 => tx_busy_requester_xhdl12,
                  tx_cred                 => tx_cred,
                  tx_req                  => tx_req_requester,
                  tx_ack                  => tx_ack,
                  tx_desc                 => tx_desc_requester,
                  tx_data                 => tx_data_xhdl13,
                  tx_dfr                  => tx_dfr_xhdl14,
                  tx_dv                   => tx_dv_xhdl15,
                  tx_ws                   => tx_ws,
                  rx_buffer_cpl_max_dw    => rx_buffer_cpl_max_dw,

                  rx_req                  => rx_req,
                  rx_ack                  => rx_ack_requester,
                  rx_desc                 => rx_desc,
                  rx_data                 => rx_data(127 DOWNTO 0),
                  rx_be                   => rx_be(15 DOWNTO 0),
                  rx_dv                   => rx_dv,
                  rx_dfr                  => rx_dfr,
                  rx_ws                   => rx_ws_requester,

                  --MSI
                  app_msi_ack             => app_msi_ack,
                  app_msi_req             => app_msi_req_xhdl1,
                  msi_sel                 => msi_sel,
                  msi_ready               => msi_ready_xhdl6,
                  msi_busy                => msi_busy_xhdl5,

                  -- Avalon back end
                  address                 => write_address_xhdl19,
                  waitrequest             => write_wait_xhdl22,
                  write                   => write_xhdl18,
                  writedata               => write_data_xhdl21,
                  write_byteena           => write_byteena_xhdl20,

                  dma_sm_tx               => dma_sm_req(3 DOWNTO 0),
                  dma_sm_rx               => dma_sm_req(6 DOWNTO 4),

                  descriptor_mrd_cycle    => descriptor_mrd_cycle_xhdl3,
                  requester_mrdmwr_cycle  => requester_mrdmwr_cycle_xhdl10,
                  dma_status              => dma_status,
                  cpl_pending             => cpl_pending_requestor,

                  init                    => init_xhdl4,
                  clk_in                  => clk_in,
                  rstn                    => rstn
               );
            read_xhdl7 <= '0';
            read_wait_xhdl9 <= '0';
         END GENERATE;
         xhdl28 : IF (NOT(AVALON_ST_128 = 1)) GENERATE
            -- altpcierd_read_dma_requester
            -- Transfer data RC memory to EP memeory


            read_requester : altpcierd_read_dma_requester
               GENERIC MAP (
                  RC_64BITS_ADDR         => RC_64BITS_ADDR,
                  FIFO_WIDTH             => FIFO_WIDTH,
                  MAX_NUMTAG             => MAX_NUMTAG_LIMIT,
                  USE_CREDIT_CTRL        => USE_CREDIT_CTRL,
                  TXCRED_WIDTH           => TXCRED_WIDTH,
                  BOARD_DEMO             => BOARD_DEMO,
                  USE_MSI                => USE_MSI,
                  AVALON_WADDR           => AVALON_WADDR,
                  AVALON_WDATA           => AVALON_WDATA,
                  USE_RCSLAVE            => USE_RCSLAVE,
                  RC_SLAVE_USETAG        => RC_SLAVE_USETAG,
                  DT_EP_ADDR_SPEC        => DT_EP_ADDR_SPEC,
                  CDMA_AST_RXWS_LATENCY  => CDMA_AST_RXWS_LATENCY
               )
               PORT MAP (
                  dt_fifo_rdreq           => dt_fifo_rdreq,
                  dt_fifo_empty           => dt_fifo_empty,
                  dt_fifo_q               => dt_fifo_q,

                  -- PCIe config info
                  cfg_maxrdreq_dw         => cfg_maxrdreq_dw,
                  cfg_maxrdreq            => cfg_maxrdreq,
                  cfg_link_negociated     => cfg_link_negociated,

                  -- DMA Prg signals register
                  dt_base_rc              => dt_base_rc,
                  dt_3dw_rcadd            => dt_3dw_rcadd,
                  dt_eplast_ena           => dt_eplast_ena,
                  dt_msi                  => dt_msi,
                  dt_size                 => dt_size,

                  -- PCIe backend Transmit section
                  tx_ready                => tx_ready_requester_xhdl17,
                  tx_sel                  => tx_sel_requester,
                  tx_busy                 => tx_busy_requester_xhdl12,
                  tx_cred                 => tx_cred,
                  tx_req                  => tx_req_requester,
                  tx_ack                  => tx_ack,
                  tx_desc                 => tx_desc_requester,
                  tx_data                 => tx_data_xhdl13(63 DOWNTO 0),
                  tx_dfr                  => tx_dfr_xhdl14,
                  tx_dv                   => tx_dv_xhdl15,
                  tx_ws                   => tx_ws,
                  rx_buffer_cpl_max_dw    => rx_buffer_cpl_max_dw,

                  rx_req                  => rx_req,
                  rx_ack                  => rx_ack_requester,
                  rx_desc                 => rx_desc,
                  rx_data                 => rx_data(63 DOWNTO 0),
                  rx_be                   => rx_be(7 DOWNTO 0),
                  rx_dv                   => rx_dv,
                  rx_dfr                  => rx_dfr,
                  rx_ws                   => rx_ws_requester,

                  --MSI
                  app_msi_ack             => app_msi_ack,
                  app_msi_req             => app_msi_req_xhdl1,
                  msi_sel                 => msi_sel,
                  msi_ready               => msi_ready_xhdl6,
                  msi_busy                => msi_busy_xhdl5,

                  -- Avalon back end
                  address                 => write_address_xhdl19,
                  waitrequest             => write_wait_xhdl22,
                  write                   => write_xhdl18,
                  writedata               => write_data_xhdl21,
                  write_byteena           => write_byteena_xhdl20,

                  dma_sm_tx               => dma_sm_req(3 DOWNTO 0),
                  dma_sm_rx               => dma_sm_req(6 DOWNTO 4),

                  descriptor_mrd_cycle    => descriptor_mrd_cycle_xhdl3,
                  requester_mrdmwr_cycle  => requester_mrdmwr_cycle_xhdl10,
                  dma_status              => dma_status,
                  cpl_pending             => cpl_pending_requestor,

                  init                    => init_xhdl4,
                  clk_in                  => clk_in,
                  rstn                    => rstn
               );
            tx_data_xhdl13(127 DOWNTO 64) <= "0000000000000000000000000000000000000000000000000000000000000000";
            read_xhdl7 <= '0';
            read_wait_xhdl9 <= '0';
         END GENERATE;
      END GENERATE;
   END GENERATE;

   dma_sm(6 DOWNTO 0) <= "0000000" WHEN (DISPLAY_SM = 0) ELSE
                         dma_sm_req;
   dma_sm(10 DOWNTO 7) <= "0000" WHEN (DISPLAY_SM = 0) ELSE
                          dma_sm_desc;

END ARCHITECTURE altpcie;
