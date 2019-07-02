LIBRARY ieee;                          
use IEEE.std_logic_1164.all;           
use IEEE.std_logic_arith.all;          
use IEEE.std_logic_unsigned.all;       
                                       
LIBRARY altera_mf;                     
USE altera_mf.altera_mf_components.all;
                                       
LIBRARY ieee;
   USE ieee.std_logic_1164.all;
-- synthesis translate_off
-- synthesis translate_on
-------------------------------------------------------------------------------
-- Title         : PCI Express Reference Design Example Application
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcierd_cdma_ast_tx.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This module construct of the Avalon Streaming transmit port for the
-- chaining DMA application DATA/Descriptor signals.
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
ENTITY altpcierd_cdma_ast_tx IS
   GENERIC (
      TL_SELECTION      : INTEGER := 0
   );
   PORT (
      clk_in            : IN STD_LOGIC;
      rstn              : IN STD_LOGIC;
      tx_stream_ready0  : IN STD_LOGIC;
      tx_stream_data0   : OUT STD_LOGIC_VECTOR(74 DOWNTO 0);
      tx_stream_valid0  : OUT STD_LOGIC;
      
      --transmit section channel 0
      tx_req0           : IN STD_LOGIC;
      tx_ack0           : OUT STD_LOGIC;
      tx_desc0          : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      tx_ws0            : OUT STD_LOGIC;
      tx_err0           : IN STD_LOGIC;
      
      tx_dv0            : IN STD_LOGIC;
      tx_dfr0           : IN STD_LOGIC;
      tx_data0          : IN STD_LOGIC_VECTOR(63 DOWNTO 0)
   );
END ENTITY altpcierd_cdma_ast_tx;
ARCHITECTURE altpcie OF altpcierd_cdma_ast_tx IS
   
   -- misc control signal for desc/data bus from application
   -- TL packet has payload

   SIGNAL has_payload             : STD_LOGIC;
   SIGNAL has_payload_stream      : STD_LOGIC;
   -- TL packet has a payload of a single DWORD
   SIGNAL single_dword            : STD_LOGIC;
   SIGNAL single_dword_stream     : STD_LOGIC;
   -- 3dword header
   SIGNAL tx_3dw                  : STD_LOGIC;
   -- qword aligned address descriptor header
   SIGNAL qword_aligned           : STD_LOGIC;
   SIGNAL qword_3dw_nonaligned    : STD_LOGIC;
   -- tx_req sub-signals
   SIGNAL tx_req_delay            : STD_LOGIC;
   SIGNAL tx_req_p0               : STD_LOGIC;
   SIGNAL tx_req_p1               : STD_LOGIC;
   SIGNAL tx_stream_ready_for_sop : STD_LOGIC;
   SIGNAL tx_req_delay_from_apps  : STD_LOGIC;
   SIGNAL tx_req_p0_from_apps     : STD_LOGIC;
   SIGNAL tx_req_p1_from_apps     : STD_LOGIC;
   SIGNAL tx_stream_ready_p1      : STD_LOGIC;
   SIGNAL tx_stream_ready_p2      : STD_LOGIC;
   SIGNAL tx_req_p0_apps_stream   : STD_LOGIC;
   SIGNAL tx_req_distance         : STD_LOGIC;
   
   -- Avalon-st interbal control signal
   SIGNAL sop_valid_eop_cycle     : STD_LOGIC;
   SIGNAL tx_stream_busy          : STD_LOGIC;
   
   --Avalon-ST Start of packet
   SIGNAL tx_sop                  : STD_LOGIC;
   -- Avalon-ST end of packet
   SIGNAL tx_eop                  : STD_LOGIC;
   -- Avalon-ST  registered data
   SIGNAL tx_stream_data0_r       : STD_LOGIC_VECTOR(63 DOWNTO 0);
   
   -- Application desc/.data registered interface
   SIGNAL tx_data_reg             : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL tx_dv_reg               : STD_LOGIC;
   SIGNAL tx_dfr_reg              : STD_LOGIC;
   SIGNAL tx_ws0_reg              : STD_LOGIC;
   
   SIGNAL tx_req_txready          : STD_LOGIC;
   SIGNAL tx_dfr_txready          : STD_LOGIC;
   SIGNAL tx_dv_txready           : STD_LOGIC;
   SIGNAL tx_data_txready         : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL tx_desc_txready         : STD_LOGIC_VECTOR(127 DOWNTO 0);
   
   -- synchronized reset
   SIGNAL srst                    : STD_LOGIC;
BEGIN
   
   --------------------------------------------------------------
   --    Application Control signals
   --------------------------------------------------------------
   
   -- always @(posedge clk_in) begin
   PROCESS (rstn, clk_in)
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
         IF ((tx_stream_ready0 = '1') AND (tx_req0 = '1') AND (tx_stream_busy = '0')) THEN
            tx_req_txready <= '1';
         ELSIF (tx_req0 = '0') THEN
            tx_req_txready <= '0';
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         tx_req_p1 <= tx_req_p0;
         tx_req_delay <= tx_req_txready;
      END IF;
   END PROCESS;
   tx_req_p0 <= tx_req_txready AND NOT(tx_req_delay);
   tx_stream_ready_for_sop <= tx_req_p0;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (has_payload = '1') THEN
            IF (tx_req_p1_from_apps = '1') THEN
               IF (tx_dfr0 = '0') THEN
                  single_dword <= '1';
               ELSE
                  single_dword <= '0';
               END IF;
            END IF;
         ELSE
            single_dword <= '0';
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            single_dword_stream <= '0';
         ELSE
            IF ((tx_req_p1 = '1') AND (single_dword = '1')) THEN
               single_dword_stream <= '1';
            ELSIF ((tx_stream_ready_p2 = '1') AND (single_dword_stream = '1')) THEN
               single_dword_stream <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         tx_ack0 <= tx_stream_ready_for_sop;
      END IF;
   END PROCESS;
   
   --------------------------------------------------------------
   --    tx_req signal realted to application
   --------------------------------------------------------------
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            has_payload <= '0';
         ELSIF ((tx_req_p0_from_apps = '1') AND (tx_dfr0 = '1')) THEN
            has_payload <= '1';
         ELSIF ((tx_req_p0_from_apps = '1') AND (tx_dfr0 = '0')) THEN
            has_payload <= '0';
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            tx_3dw <= '0';
         ELSIF (tx_req_p0_from_apps = '1') THEN
            IF (tx_desc0(125) = '0') THEN
               tx_3dw <= '1';
            ELSE
               tx_3dw <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            qword_aligned <= '0';
         ELSIF (tx_req_p1_from_apps = '1') THEN
            IF (tx_3dw = '1') THEN
               IF (tx_desc0(34 DOWNTO 32) = "000") THEN
                  qword_aligned <= '1';
               ELSE
                  qword_aligned <= '0';
               END IF;
            ELSE
               IF (tx_desc0(2 DOWNTO 0) = "000") THEN
                  qword_aligned <= '1';
               ELSE
                  qword_aligned <= '0';
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            tx_req_delay_from_apps <= '0';
         ELSE
            tx_req_delay_from_apps <= tx_req0;
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         tx_req_p1_from_apps <= tx_req_p0_from_apps;
      END IF;
   END PROCESS;
   
   tx_req_p0_from_apps <= tx_req0 AND NOT(tx_req_delay_from_apps);
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (tx_stream_ready_for_sop = '1') THEN
            has_payload_stream <= has_payload;
         END IF;
      END IF;
   END PROCESS;
   
   tx_req_distance <= '1' WHEN ((tx_req_p0_apps_stream = '1') AND (tx_stream_ready_for_sop = '0')) ELSE
                      '0';
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (tx_req0 = '0') THEN
            tx_req_p0_apps_stream <= '0';
         ELSE
            IF ((tx_req_p0_from_apps = '1') AND (tx_dfr0 = '1')) THEN
               tx_req_p0_apps_stream <= '1';
            ELSIF (tx_stream_ready_for_sop = '1') THEN
               tx_req_p0_apps_stream <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   --------------------------------------------------------------
   --    Avalon ST tx_ready back pressure on tx_ws of
   --------------------------------------------------------------
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         tx_stream_ready_p1 <= tx_stream_ready0;
         tx_stream_ready_p2 <= tx_stream_ready_p1;
      END IF;
   END PROCESS;
   
   tx_ws0 <= '1' WHEN ((tx_ws0_reg = '1') OR (tx_req_distance = '1')) ELSE
             '0';
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (has_payload = '0') THEN
            tx_ws0_reg <= '0';
         ELSE
            IF (tx_stream_ready0 = '0') THEN
               tx_ws0_reg <= '1';
            ELSE
               tx_ws0_reg <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (tx_stream_ready0 = '1') THEN
            tx_desc_txready <= tx_desc0;
         END IF;
      END IF;
   END PROCESS;
   
   -- tx_dfr
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (tx_stream_ready_p1 = '1') THEN
            tx_data_txready <= tx_data0;
            tx_dfr_txready <= tx_dfr0;
            tx_dv_txready <= tx_dv0;
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (tx_stream_ready_p2 = '1') THEN
            tx_data_reg <= tx_data_txready;
            tx_dv_reg <= tx_dv_txready;
            tx_dfr_reg <= tx_dfr_txready;
         END IF;
      END IF;
   END PROCESS;
   
   --------------------------------------------------------------
   --    Avalon ST DATA , valid
   --------------------------------------------------------------
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (TL_SELECTION = 0) THEN
            IF (tx_stream_ready_for_sop = '1') THEN
               tx_stream_data0_r(63 DOWNTO 0) <= tx_desc_txready(127 DOWNTO 64);
            ELSIF (tx_req_p1 = '1') THEN
               tx_stream_data0_r(63 DOWNTO 0) <= tx_desc_txready(63 DOWNTO 0);
            ELSIF (tx_stream_ready_p2 = '1') THEN
               tx_stream_data0_r(63 DOWNTO 0) <= tx_data_reg(63 DOWNTO 0);
            END IF;
         ELSE
            IF (tx_stream_ready_for_sop = '1') THEN
               tx_stream_data0_r(63 DOWNTO 0) <= (tx_desc_txready(95 DOWNTO 64) & tx_desc_txready(127 DOWNTO 96));
            ELSIF (tx_req_p1 = '1') THEN
               IF ((qword_aligned = '0') AND (tx_3dw = '1')) THEN
                  tx_stream_data0_r(63 DOWNTO 0) <= (tx_data_txready(63 DOWNTO 32) & tx_desc_txready(63 DOWNTO 32));
               ELSE
                  tx_stream_data0_r(63 DOWNTO 0) <= (tx_desc_txready(31 DOWNTO 0) & tx_desc_txready(63 DOWNTO 32));
               END IF;
            ELSIF (tx_stream_ready_p2 = '1') THEN
               IF ((qword_aligned = '0') AND (tx_3dw = '1')) THEN
                  tx_stream_data0_r(63 DOWNTO 0) <= tx_data_txready(63 DOWNTO 0);
               ELSE
                  tx_stream_data0_r(63 DOWNTO 0) <= tx_data_reg(63 DOWNTO 0);
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   -- CPL_PENDING - TX_ERR (Unused in reference design)
   tx_stream_data0(74) <= '0';
   tx_stream_data0(73) <= tx_sop;
   tx_stream_data0(72) <= tx_eop;
   -- BAR on TX // TODO check if need to be removed
   tx_stream_data0(71 DOWNTO 64) <= "00000000";
   tx_stream_data0(63 DOWNTO 0) <= tx_stream_data0_r(63 DOWNTO 0);
   
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         tx_stream_valid0 <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((tx_stream_ready_for_sop = '1') OR (tx_req_p1 = '1')) THEN
            tx_stream_valid0 <= '1';
         ELSE
            IF ((tx_stream_ready_p2 = '0') OR (tx_eop = '1')) THEN
               tx_stream_valid0 <= '0';
            ELSIF (sop_valid_eop_cycle = '1') THEN
               tx_stream_valid0 <= '1';
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   --------------------------------------------------------------
   --    Avalon ST Control Signals
   --------------------------------------------------------------
   
   -- SOP
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         tx_sop <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         tx_sop <= tx_stream_ready_for_sop;
      END IF;
   END PROCESS;
   
   qword_3dw_nonaligned <= '0' WHEN (tx_3dw = '0') ELSE
                           '0' WHEN (qword_aligned = '1') ELSE
                           '1';
   -- EOP
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            tx_eop <= '0';
         ELSIF (has_payload_stream = '0') THEN
            tx_eop <= tx_req_p1;
         ELSE
            IF ((TL_SELECTION = 0) OR (qword_3dw_nonaligned = '0')) THEN
               IF (tx_stream_ready_p2 = '1') THEN
                  IF ((tx_req_p1 = '1') OR (tx_stream_ready_for_sop = '1')) THEN
                     tx_eop <= '0';
                  ELSIF (single_dword_stream = '1') THEN
                     tx_eop <= '1';
                  ELSIF ((tx_dfr_reg = '0') AND (tx_dv_reg = '1')) THEN
                     tx_eop <= '1';
                  ELSE
                     tx_eop <= '0';
                  END IF;
               ELSE
                  tx_eop <= '0';
               END IF;
            ELSE
               IF (tx_stream_ready_p2 = '1') THEN
                  IF ((tx_req_p0 = '1') OR (tx_stream_ready_for_sop = '1')) THEN
                     tx_eop <= '0';
                  ELSIF ((tx_req_p1 = '1') AND (single_dword = '1')) THEN
                     tx_eop <= '1';
                  ELSIF ((tx_dfr_txready = '0') AND (tx_dv_txready = '1')) THEN
                     tx_eop <= '1';
                  ELSE
                     tx_eop <= '0';
                  END IF;
               ELSE
                  tx_eop <= '0';
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   tx_stream_busy <= '1' WHEN ((sop_valid_eop_cycle = '1') AND (tx_eop = '0')) ELSE
                     '0';
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            sop_valid_eop_cycle <= '0';
         ELSE
            IF (tx_sop = '1') THEN
               sop_valid_eop_cycle <= '1';
            ELSIF (tx_eop = '1') THEN
               sop_valid_eop_cycle <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
END ARCHITECTURE altpcie;
