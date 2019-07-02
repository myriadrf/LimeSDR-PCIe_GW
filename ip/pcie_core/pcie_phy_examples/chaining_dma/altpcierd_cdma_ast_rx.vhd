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
-- File          : altpcierd_cdma_ast_rx.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This module construct of the Avalon Streaming receive port for the
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
ENTITY altpcierd_cdma_ast_rx IS
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
END ENTITY altpcierd_cdma_ast_rx;
ARCHITECTURE altpcie OF altpcierd_cdma_ast_rx IS
   

   SIGNAL rx_sop             : STD_LOGIC;
   SIGNAL rx_sop_reg         : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL rx_eop             : STD_LOGIC;
   SIGNAL rx_eop_reg         : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL rx_eop_done        : STD_LOGIC;
   SIGNAL rx_eop_2dw         : STD_LOGIC;
   SIGNAL rx_eop_2dw_reg     : STD_LOGIC;
   SIGNAL has_payload        : STD_LOGIC;
   SIGNAL dw3_desc_w_payload : STD_LOGIC;
   SIGNAL qword_aligned      : STD_LOGIC;
   SIGNAL qword_aligned_reg  : STD_LOGIC;
   SIGNAL rx_data0_3dwna     : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL srst               : STD_LOGIC;
BEGIN
   
   --   always @(posedge clk_in) begin
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         srst <= '1';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         srst <= '0';
      END IF;
   END PROCESS;
   ecrc_bad_cnt <= "0000000000000000";
   
   --------------------------------------------------------------
   --    Avalon ST Control signals
   --------------------------------------------------------------
   -- SOP
   rx_sop <= '1' WHEN ((rx_stream_data0(73) = '1') AND (rx_stream_valid0 = '1')) ELSE
             '0';
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (TL_SELECTION = 0) THEN
            IF (rx_stream_valid0 = '1') THEN
               rx_sop_reg(0) <= rx_sop;
               rx_sop_reg(1) <= rx_sop_reg(0);
            END IF;
            IF ((rx_stream_valid0 = '1') OR (rx_eop_reg(0) = '1')) THEN
               rx_sop_reg(2) <= rx_sop_reg(1);
            END IF;
         ELSE
            IF (rx_stream_valid0 = '1') THEN
               rx_sop_reg(0) <= rx_sop;
            END IF;
            IF ((rx_stream_valid0 = '1') OR (rx_eop_reg(0) = '1')) THEN
               rx_sop_reg(2) <= rx_sop_reg(1);
            END IF;
            IF (rx_stream_valid0 = '1') THEN
               rx_sop_reg(1) <= rx_sop_reg(0);
            ELSIF (rx_eop_2dw = '1') THEN
               rx_sop_reg(1) <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   -- EOP
   rx_eop <= '1' WHEN ((rx_stream_data0(72) = '1') AND (rx_stream_valid0 = '1')) ELSE
             '0';
   rx_eop_done <= '1' WHEN ((rx_stream_data0(72) = '0') AND (rx_eop_reg(0) = '1')) ELSE
                  '0';
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         rx_eop_reg(0) <= rx_eop;
         rx_eop_reg(1) <= rx_eop_reg(0);
         rx_eop_reg(2) <= rx_eop_reg(1);
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (TL_SELECTION = 0) THEN
            rx_eop_2dw <= '0';
         ELSIF ((rx_sop_reg(0) = '1') AND (rx_eop = '1')) THEN
            rx_eop_2dw <= '1';
         ELSE
            rx_eop_2dw <= '0';
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         rx_eop_2dw_reg <= rx_eop_2dw;
      END IF;
   END PROCESS;
   
   -- Payload
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         has_payload <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         IF (rx_stream_data0(73) = '1') THEN
            IF (TL_SELECTION = 0) THEN
               has_payload <= rx_stream_data0(62);
            ELSE
               has_payload <= rx_stream_data0(30);
            END IF;
         ELSIF (rx_eop_done = '1') THEN
            has_payload <= '0';
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (TL_SELECTION = 0) THEN     --TODO Update dw3_desc_w_payload for desc/data interface
            dw3_desc_w_payload <= '0';
         ELSIF (rx_sop_reg(0) = '1') THEN
            IF ((rx_stream_data0(30) = '1') AND (rx_stream_data0(29) = '0')) THEN
               dw3_desc_w_payload <= '1';
            ELSE
               dw3_desc_w_payload <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   qword_aligned <= '1' WHEN ((rx_sop_reg(0) = '1') AND (rx_stream_data0(2 DOWNTO 0) = "000")) ELSE
                    qword_aligned_reg;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (TL_SELECTION = 0) THEN     --TODO Update qword_aligned_reg for desc/data interface
            qword_aligned_reg <= '0';
         ELSIF (srst = '1') THEN
            qword_aligned_reg <= '0';
         ELSIF (rx_sop_reg(0) = '1') THEN
            IF (rx_stream_data0(2 DOWNTO 0) = "000") THEN
               qword_aligned_reg <= '1';
            ELSE
               qword_aligned_reg <= '0';
            END IF;
         ELSIF (rx_eop = '1') THEN
            qword_aligned_reg <= '0';
         END IF;
      END IF;
   END PROCESS;
   
   -- TODO if no rx_ack de-assert rx_stream_ready0 on cycle rx_sop_reg
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (TL_SELECTION = 0) THEN
            rx_stream_ready0 <= NOT(rx_ws0);
         ELSE
            IF (rx_ws0 = '1') THEN
               rx_stream_ready0 <= '0';
            ELSIF ((rx_sop = '1') AND (rx_stream_data0(9 DOWNTO 0) < "0000000011")) THEN
               rx_stream_ready0 <= '0';
            ELSE
               rx_stream_ready0 <= '1';
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   --------------------------------------------------------------
   --    Constructing Descriptor  && rx_req
   --------------------------------------------------------------
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rx_req0 <= '0';
         ELSE
            IF ((rx_sop_reg(0) = '1') AND (rx_stream_valid0 = '1')) THEN
               rx_req0 <= '1';
            ELSIF (TL_SELECTION = 0) THEN
               IF (rx_sop_reg(2) = '1') THEN
                  rx_req0 <= '0';
               END IF;
            ELSE
               IF (rx_ack0 = '1') THEN
                  rx_req0 <= '0';
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (rx_sop = '1') THEN
            IF (TL_SELECTION = 0) THEN
               rx_desc0(127 DOWNTO 64) <= rx_stream_data0(63 DOWNTO 0);
            ELSE
               rx_desc0(127 DOWNTO 64) <= (rx_stream_data0(31 DOWNTO 0) & rx_stream_data0(63 DOWNTO 32));
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (rx_sop_reg(0) = '1') THEN
            rx_desc0(135 DOWNTO 128) <= rx_stream_data0(71 DOWNTO 64);
            IF (TL_SELECTION = 0) THEN
               rx_desc0(63 DOWNTO 0) <= rx_stream_data0(63 DOWNTO 0);
            ELSE
               rx_desc0(63 DOWNTO 0) <= (rx_stream_data0(31 DOWNTO 0) & rx_stream_data0(63 DOWNTO 32));
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   --------------------------------------------------------------
   --    Constructing Data, rx_dv, rx_dfr
   --------------------------------------------------------------
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         rx_data0_3dwna(63 DOWNTO 0) <= rx_stream_data0(63 DOWNTO 0);
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (TL_SELECTION = 0) THEN
            rx_data0(63 DOWNTO 0) <= rx_stream_data0(63 DOWNTO 0);
            rx_be0(7 DOWNTO 0) <= rx_stream_data0(81 DOWNTO 74);
         ELSE
            IF ((dw3_desc_w_payload = '1') AND (qword_aligned = '0')) THEN
               rx_data0(63 DOWNTO 0) <= rx_data0_3dwna(63 DOWNTO 0);
            ELSE
               rx_data0(63 DOWNTO 0) <= rx_stream_data0(63 DOWNTO 0);
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rx_dv0 <= '0';
         ELSIF ((rx_sop_reg(1) = '1') AND (has_payload = '1') AND ((rx_stream_valid0 = '1') OR (rx_eop_2dw = '1'))) THEN
            rx_dv0 <= '1';
         ELSIF ((rx_eop_reg(0) = '1') AND (rx_eop_2dw = '0')) THEN
            rx_dv0 <= '0';
         ELSIF (rx_eop_2dw_reg = '1') THEN
            rx_dv0 <= '0';
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rx_dfr0 <= '0';
         ELSIF ((rx_sop_reg(0) = '1') AND (has_payload = '1') AND (rx_stream_valid0 = '1')) THEN
            rx_dfr0 <= '1';
         ELSIF ((rx_eop = '1') OR (rx_eop_2dw = '1')) THEN
            rx_dfr0 <= '0';
         END IF;
      END IF;
   END PROCESS;
   
END ARCHITECTURE altpcie;
