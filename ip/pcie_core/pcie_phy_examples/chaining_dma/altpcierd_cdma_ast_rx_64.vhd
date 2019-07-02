LIBRARY ieee;                          
use IEEE.std_logic_1164.all;           
use IEEE.std_logic_arith.all;          
use IEEE.std_logic_unsigned.all;       
                                       
LIBRARY altera_mf;                     
USE altera_mf.altera_mf_components.all;
                                       
LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
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
ENTITY altpcierd_cdma_ast_rx_64 IS
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
END ENTITY altpcierd_cdma_ast_rx_64;
ARCHITECTURE altpcie OF altpcierd_cdma_ast_rx_64 IS


                                                
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
                                                                       
      CONSTANT RXFIFO_WIDTH         : INTEGER := 156;
      CONSTANT RXFIFO_DEPTH         : INTEGER := 64;        -- WAS 1024 
      CONSTANT RXFIFO_DEPTH_HALF    : INTEGER := 32;        -- WAS 1024 
      CONSTANT RXFIFO_WIDTHU        : INTEGER := 6;     -- WAS 10 
                                                                       
   COMPONENT altpcierd_cdma_ecrc_check_64 IS
      GENERIC (
         RAM_DATA_WIDTH       : INTEGER := 140;
         RAM_ADDR_WIDTH       : INTEGER := 8;
         PIPELINE_DEPTH       : INTEGER := 4
      );
      PORT (
         clk_in               : IN STD_LOGIC;
         srst                 : IN STD_LOGIC;
         rxdata               : IN STD_LOGIC_VECTOR(139 DOWNTO 0);
         rxdata_be            : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         rx_stream_valid0     : IN STD_LOGIC;
         rx_stream_ready0_ecrc : OUT STD_LOGIC;
         rxdata_ecrc          : OUT STD_LOGIC_VECTOR(139 DOWNTO 0);
         rxdata_be_ecrc       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
         rx_stream_valid0_ecrc : OUT STD_LOGIC;
         rx_stream_ready0     : IN STD_LOGIC;
         rx_ecrc_check_valid  : OUT STD_LOGIC;
         ecrc_bad_cnt         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
      );
   END COMPONENT;
   
   

   SIGNAL rxfifo_usedw                  : STD_LOGIC_VECTOR(RXFIFO_WIDTHU - 1 DOWNTO 0);
   SIGNAL rxfifo_d                      : STD_LOGIC_VECTOR(RXFIFO_WIDTH - 1 DOWNTO 0);
   SIGNAL rxfifo_full                   : STD_LOGIC;
   SIGNAL rxfifo_empty                  : STD_LOGIC;
   SIGNAL rxfifo_rreq                   : STD_LOGIC;
   SIGNAL rxfifo_rreq_reg               : STD_LOGIC;
   SIGNAL rxfifo_wrreq                  : STD_LOGIC;
   SIGNAL rxfifo_q                      : STD_LOGIC_VECTOR(RXFIFO_WIDTH - 1 DOWNTO 0);
   SIGNAL rxfifo_q_reg                  : STD_LOGIC_VECTOR(RXFIFO_WIDTH - 1 DOWNTO 0);
   
   SIGNAL rx_stream_ready0_reg          : STD_LOGIC;
   -- ECRC Check
   SIGNAL rxdata_ecrc                   : STD_LOGIC_VECTOR(139 DOWNTO 0);
   SIGNAL rxdata_be_ecrc                : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL rx_stream_valid0_ecrc         : STD_LOGIC;
   SIGNAL rx_stream_ready0_ecrc         : STD_LOGIC;
   SIGNAL rx_ack_pending_del            : STD_LOGIC;
   SIGNAL rx_ack_pending                : STD_LOGIC;
   
   SIGNAL ctrlrx_single_cycle           : STD_LOGIC;
   SIGNAL rx_rd_req                     : STD_LOGIC;
   SIGNAL rx_rd_req_del                 : STD_LOGIC;
   
   SIGNAL rx_dfr_reg                    : STD_LOGIC;
   SIGNAL rx_dfr_digest                 : STD_LOGIC;
   
   -- TLP start of packet
   SIGNAL rx_sop                        : STD_LOGIC;
   SIGNAL rx_sop_next                   : STD_LOGIC;
   -- TLP start of packet single pulse
   SIGNAL rx_sop_p0                     : STD_LOGIC;
   SIGNAL rx_sop_p1                     : STD_LOGIC;
   
   -- TLP end of packet
   SIGNAL rx_eop                        : STD_LOGIC;
   SIGNAL rx_eop_next                   : STD_LOGIC;
   -- TLP end of packet single puclse
   SIGNAL rx_eop_p0                     : STD_LOGIC;
   SIGNAL rx_eop_p1                     : STD_LOGIC;
   
   -- Set when TLP is 3 DW header 
   SIGNAL ctrlrx_3dw                    : STD_LOGIC;
   SIGNAL ctrlrx_3dw_reg                : STD_LOGIC;
   
   -- Set TLP length 
   SIGNAL ctrlrx_length                 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL ctrlrx_length_reg             : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL ctrlrx_count_length_dqword    : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL ctrlrx_count_length_dword     : STD_LOGIC_VECTOR(9 DOWNTO 0);
   
   -- Set when TLP is 3 DW header 
   SIGNAL ctrlrx_payload                : STD_LOGIC;
   SIGNAL ctrlrx_payload_reg            : STD_LOGIC;
   
   -- Set when TLP are qword aligned
   SIGNAL ctrlrx_qword_aligned          : STD_LOGIC;
   SIGNAL ctrlrx_qword_aligned_reg      : STD_LOGIC;
   
   -- Set when the TD digest bit is set in the descriptor
   SIGNAL ctrlrx_digest                 : STD_LOGIC;
   SIGNAL ctrlrx_digest_reg             : STD_LOGIC;
   SIGNAL ctrl_next_rx_req              : STD_LOGIC_VECTOR(2 DOWNTO 0);
   
   -- Counter track the number of RX TLP in the RXFIFO 
   SIGNAL count_eop_in_rxfifo           : STD_LOGIC_VECTOR(RXFIFO_WIDTHU - 1 DOWNTO 0);
   SIGNAL count_eop_nop                 : STD_LOGIC;
   SIGNAL last_eop_in_fifo              : STD_LOGIC;
   -- set when there is a complete RX TLP in rxfifo
   SIGNAL tlp_in_rxfifo                 : STD_LOGIC;
   
   SIGNAL wait_rdreq_reg                : STD_LOGIC;
   SIGNAL wait_rdreq                    : STD_LOGIC;
   SIGNAL rx_req_cycle                  : STD_LOGIC;
   
   SIGNAL ctrlrx_single_cycle_reg       : STD_LOGIC;
   SIGNAL rx_req_del                    : STD_LOGIC;
   SIGNAL rx_req_phase2                 : STD_LOGIC;
   SIGNAL rx_sop_last                   : STD_LOGIC;        -- means last data chunk was sop
   SIGNAL rx_sop2_last                  : STD_LOGIC;        -- means last data chunk was a 2nd cycle of pkt
   SIGNAL rx_sop_hold2                  : STD_LOGIC;        -- remember if rx_sop was received for 2 clks after the sop was popped.
   
   SIGNAL count_eop_in_rxfifo_is_one    : STD_LOGIC;
   SIGNAL count_eop_in_rxfifo_is_zero   : STD_LOGIC;
   
   SIGNAL debug_3dw_aligned_dataless    : STD_LOGIC;
   SIGNAL debug_3dw_nonaligned_dataless : STD_LOGIC;
   SIGNAL debug_4dw_aligned_dataless    : STD_LOGIC;
   SIGNAL debug_4dw_nonaligned_dataless : STD_LOGIC;
   SIGNAL debug_3dw_aligned_withdata    : STD_LOGIC;
   SIGNAL debug_3dw_nonaligned_withdata : STD_LOGIC;
   SIGNAL debug_4dw_aligned_withdata    : STD_LOGIC;
   SIGNAL debug_4dw_nonaligned_withdata : STD_LOGIC;
   
   SIGNAL rx_data_fifo_almostfull       : STD_LOGIC;
   
   -- xhdl
   SIGNAL zeros_4                       : STD_LOGIC_VECTOR(3 DOWNTO 0);
   -- X-HDL generated signals
   SIGNAL xhdl7 : STD_LOGIC;
   SIGNAL xhdl8 : STD_LOGIC;
   SIGNAL xhdl9 : STD_LOGIC;
   SIGNAL xhdl10 : STD_LOGIC;
   SIGNAL xhdl11 : STD_LOGIC;
   SIGNAL xhdl12 : STD_LOGIC;
   SIGNAL xhdl13 : STD_LOGIC;
   SIGNAL xhdl14 : STD_LOGIC;
   SIGNAL xhdl15 : STD_LOGIC;
   SIGNAL xhdl16 : STD_LOGIC;
   SIGNAL xhdl17 : STD_LOGIC;
   SIGNAL xhdl18 : STD_LOGIC;
   SIGNAL xhdl19 : STD_LOGIC;
   
   -- Declare intermediate signals for referenced outputs
   SIGNAL rx_stream_ready0_xhdl6        : STD_LOGIC;
   SIGNAL rx_req0_xhdl5                 : STD_LOGIC;
   SIGNAL rx_desc0_xhdl1                : STD_LOGIC_VECTOR(135 DOWNTO 0);
   SIGNAL rx_dv0_xhdl3                  : STD_LOGIC;
   SIGNAL rx_dfr0_xhdl2                 : STD_LOGIC;
   SIGNAL rx_ecrc_check_valid_xhdl4     : STD_LOGIC;
   SIGNAL ecrc_bad_cnt_xhdl0            : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
   -- Drive referenced outputs
   rx_stream_ready0 <= rx_stream_ready0_xhdl6;
   rx_req0 <= rx_req0_xhdl5;
   rx_desc0 <= rx_desc0_xhdl1;
   rx_dv0 <= rx_dv0_xhdl3;
   rx_dfr0 <= rx_dfr0_xhdl2;
   rx_ecrc_check_valid <= rx_ecrc_check_valid_xhdl4;
   ecrc_bad_cnt <= ecrc_bad_cnt_xhdl0;
   zeros_4 <= "0000";
   
   
   --------------------------------------------------------------
   --    Avalon ST Control Signlas 
   --------------------------------------------------------------
   -- rx_stream_ready0 
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rx_stream_ready0_reg <= '1';
         ELSE
            IF (rxfifo_usedw > to_stdlogicvector((RXFIFO_DEPTH_HALF), 6)) THEN      -- ||(rx_ws0==1'b1))   
               rx_stream_ready0_reg <= '0';
            ELSE
               rx_stream_ready0_reg <= '1';
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   --------------------------------------------------------------
   --    Avalon ST RX FIFO
   --------------------------------------------------------------
   
   rx_data_fifo_128 : scfifo
      GENERIC MAP (
         add_ram_output_register  => "ON",
         intended_device_family   => "Stratix II GX",
         lpm_numwords             => RXFIFO_DEPTH,
         lpm_showahead            => "OFF",
         lpm_type                 => "scfifo",
         lpm_width                => RXFIFO_WIDTH,
         lpm_widthu               => RXFIFO_WIDTHU,
         overflow_checking        => "ON",
         underflow_checking       => "ON",
         almost_full_value        => RXFIFO_DEPTH_HALF,
         use_eab                  => "ON"
      )
      PORT MAP (
         clock  => clk_in,
         sclr   => srst,
         
         -- RX push TAGs into TAG_FIFO
         data   => rxfifo_d,
         wrreq  => rxfifo_wrreq,
         
         -- TX pop TAGs from TAG_FIFO
         rdreq  => rxfifo_rreq,
         q      => rxfifo_q,
         
         empty  => rxfifo_empty,
         full   => rxfifo_full,
         usedw  => rxfifo_usedw,
         almost_full => rx_data_fifo_almostfull
      );
   
   rx_stream_ready0_xhdl6 <= rx_stream_ready0_reg WHEN (ECRC_FORWARD_CHECK = 0) ELSE
                             rx_stream_ready0_ecrc;
   rxfifo_wrreq <= rx_stream_valid0 WHEN (ECRC_FORWARD_CHECK = 0) ELSE
                   rx_stream_valid0_ecrc;
   rxfifo_d(155 downto 0) <= (rxdata_be & rxdata) WHEN (ECRC_FORWARD_CHECK = 0) ELSE
               (rxdata_be_ecrc & rxdata_ecrc);
   
   rx_rd_req <= '1' WHEN ((rx_ack_pending = '0') AND ((rx_dv0_xhdl3 = '0') OR (rx_ws0 = '0'))) ELSE
                '0';
   
   rxfifo_rreq <= '1' WHEN ((rxfifo_empty = '0') AND (tlp_in_rxfifo = '1') AND (rx_rd_req = '1') AND (wait_rdreq = '0')) ELSE
                  '0';
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         rxfifo_q_reg <= rxfifo_q;
         IF (srst = '1') THEN
            rx_rd_req_del <= '0';
            rxfifo_rreq_reg <= '0';
         ELSE
            rx_rd_req_del <= rx_rd_req;
            rxfifo_rreq_reg <= rxfifo_rreq;
         END IF;
      END IF;
   END PROCESS;
   
   --------------------------------------------------------------
   --    Constructing Desc/ Data, rx_dv, rx_dfr
   --------------------------------------------------------------
   -- rxdata[73]        rx_sop0 [139]
   -- rxdata[72]        rx_eop0 [138]
   -- rxdata[73]        rx_sop1 [137]
   -- rxdata[72]        rx_eop1 [136]
   -- rxdata[135:128]   bar     [135:128]
   --                  Header |  Aligned |        Un-aligned 
   --                         |          | 3 Dwords    | 4 Dwords 
   -- rxdata[127:96]    H0    |   D0     |  -  -> D1   |     -> D3   
   -- rxdata[95:64 ]    H1    |   D1     |  -  -> D2   |  D0 -> D4    
   -- rxdata[63:32 ]    H2    |   D2     |  -  -> D3   |  D1 -> D5 
   -- rxdata[31:0  ]    H4    |   D3     |  D0 -> D4   |  D2 -> D6
   
   rx_sop <= '1' WHEN ((rxfifo_q(139) = '1') AND (rxfifo_rreq_reg = '1')) ELSE
             '0';
   rx_eop <= '1' WHEN ((rxfifo_q(138) = '1') AND (rxfifo_rreq_reg = '1')) ELSE
             '0';
   
   xhdl8 <= rx_sop WHEN (rxfifo_rreq_reg = '1') ELSE        -- remember if last data chunk was an SOP
             rx_sop_last;
   xhdl9 <= rx_sop_last WHEN (rxfifo_rreq_reg = '1') ELSE
             rx_sop2_last;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         rx_sop_last <= xhdl8;
         rx_sop2_last <= xhdl9;
      END IF;
   END PROCESS;
   
   -- RX_DESC
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rx_desc0_xhdl1 <=(others=>'0'); 
         ELSE
            IF (rx_sop_p0 = '1') THEN
               
               rx_desc0_xhdl1(127 DOWNTO 64) <= rxfifo_q(127 DOWNTO 64);
            END IF;
            IF (rx_sop_p1 = '1') THEN
               rx_desc0_xhdl1(63 DOWNTO 0) <= rxfifo_q(127 DOWNTO 64);
               rx_desc0_xhdl1(135 DOWNTO 128) <= rxfifo_q(135 DOWNTO 128);
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   -- RX_DATA
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((rx_sop2_last = '1') AND (ctrlrx_3dw = '1') AND (ctrlrx_qword_aligned = '0')) THEN
            rx_be0 <= (rxfifo_q_reg(151 DOWNTO 148) & zeros_4);
         ELSIF ((rx_sop2_last = '1') AND (ctrlrx_3dw = '0') AND (ctrlrx_qword_aligned = '0')) THEN
            rx_be0 <= (rxfifo_q(151 DOWNTO 148) & zeros_4);
         ELSIF ((ctrlrx_3dw = '1') AND (ctrlrx_qword_aligned = '0')) THEN
            IF (ctrlrx_count_length_dqword(9 DOWNTO 1) = "000000000") THEN
               if (ctrlrx_count_length_dqword(0) = '0' ) then
                     rx_be0 <= "00000000";
               else     
                     rx_be0 <= (zeros_4 & rxfifo_q_reg(155 DOWNTO 152));
               end if;      
            ELSE
               rx_be0 <= (rxfifo_q_reg(151 DOWNTO 148) & rxfifo_q_reg(155 DOWNTO 152));
            END IF;
         ELSE
            -- 3DW/4DW aligned: full data cycles
            IF (ctrlrx_count_length_dqword(9 DOWNTO 1) = "000000000") THEN
               if (ctrlrx_count_length_dqword(0) = '0') then
                 rx_be0 <= "00000000";
               else      
                 rx_be0 <= (zeros_4 & rxfifo_q(155 DOWNTO 152));
               end if;
            ELSE
               rx_be0 <= (rxfifo_q(151 DOWNTO 148) & rxfifo_q(155 DOWNTO 152));
            END IF;
         END IF;
         
         IF ((ctrlrx_3dw = '1') AND (ctrlrx_qword_aligned = '0')) THEN
            rx_data0 <= (rxfifo_q_reg(95 DOWNTO 64) & rxfifo_q_reg(127 DOWNTO 96));     -- delay data 
         ELSE
            rx_data0 <= (rxfifo_q(95 DOWNTO 64) & rxfifo_q(127 DOWNTO 96));
         END IF;
      END IF;
   END PROCESS;
   
   --
   --   RX_REQ
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rx_req0_xhdl5 <= '0';
         ELSIF (rx_ack0 = '1') THEN
            rx_req0_xhdl5 <= '0';
         ELSIF (rx_sop_p1 = '1') THEN
            rx_req0_xhdl5 <= '1';
         END IF;
      END IF;
   END PROCESS;
   
   xhdl10 <= '1' WHEN ((rx_req_del = '0') AND (rx_req0_xhdl5 = '1')) ELSE       -- assert while in phase 2 (waiting for ack) of descriptor
                    rx_req_phase2;
   xhdl11 <= '0' WHEN (rx_ack0 = '1') ELSE
                    xhdl10;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rx_ack_pending_del <= '0';
            rx_req_del <= '0';
            rx_req_phase2 <= '0';
         ELSE
            rx_req_del <= rx_req0_xhdl5;
            rx_req_phase2 <= xhdl11;
            rx_ack_pending_del <= rx_ack_pending;
         END IF;
      END IF;
   END PROCESS;
   
   rx_ack_pending <= '0' WHEN (rx_ack0 = '1') ELSE      -- means rx_ack is delayed, hold off on fifo reads until ack is received.
                     '1' WHEN (rx_req_phase2 = '1') ELSE
                     rx_ack_pending_del;
   
   --
   --   RX_DFR
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            ctrlrx_count_length_dqword <= "0000000000";
         ELSE
            -- DW unit remaining count
            IF (rx_sop_last = '1') THEN
               ctrlrx_count_length_dword <= ctrlrx_length;      -- update when data is valid 
            ELSIF ((ctrlrx_count_length_dword > "0000000001") AND (rx_rd_req_del = '1')) THEN
               
               -- 64 bit unit remaining count  
               ctrlrx_count_length_dword <= ctrlrx_count_length_dword - "0000000010";
            END IF;
            IF (rx_sop_p1 = '1') THEN
               IF (ctrlrx_payload = '1') THEN
                  IF (ctrlrx_qword_aligned = '1') THEN      -- address aligned     
                     ctrlrx_count_length_dqword <= ctrlrx_length;       -- payload length in DWs
                  ELSE
                     ctrlrx_count_length_dqword <= ctrlrx_length + "0000000001";        -- add 1 DW to account for empty DW in first data cycle
                  END IF;
               ELSE
                  ctrlrx_count_length_dqword <= "0000000000";
               END IF;
            ELSIF ((ctrlrx_count_length_dqword > "0000000001") AND (rx_rd_req_del = '1')) THEN      -- decrement only when data is popped    
               ctrlrx_count_length_dqword <= ctrlrx_count_length_dqword - "0000000010";
            ELSIF (rx_rd_req_del = '1') THEN
               ctrlrx_count_length_dqword <= "0000000000";
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   rx_dfr_digest <= '1' WHEN ((rx_dfr_reg = '1') AND (ctrlrx_count_length_dqword > "0000000000")) ELSE
                    '0';
   rx_dfr0_xhdl2 <= '1' when  (ctrlrx_count_length_dqword > "0000000000") else '0';
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rx_dfr_reg <= '0';
         ELSIF (ctrlrx_payload = '1') THEN
            IF (ctrlrx_single_cycle = '1') THEN
               rx_dfr_reg <= rx_sop_p1;
            ELSIF (rx_sop_p1 = '1') THEN
               rx_dfr_reg <= '1';
            ELSIF (rx_eop_p0 = '1') THEN
               rx_dfr_reg <= '0';
            END IF;
         ELSE
            rx_dfr_reg <= '0';
         END IF;
      END IF;
   END PROCESS;
   
   --   RX_DV
   xhdl12 <= rx_dfr0_xhdl2 WHEN (rx_rd_req_del = '1') ELSE      -- update when data (corresponding to rx_ws) is valid at dfr/dv interface
                 rx_dv0_xhdl3;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         rx_dv0_xhdl3 <= xhdl12;
      END IF;
   END PROCESS;
   
   --------------------------------------------------------------
   --   Misc control signla to convert Avalon-ST to Desc/Data
   --------------------------------------------------------------
   wait_rdreq <= '1' WHEN ((rx_eop_p0 = '1') AND (rx_req_cycle = '1')) ELSE
                 '1' WHEN ((wait_rdreq_reg = '1') AND (rx_req_cycle = '1')) ELSE
                 '0';
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            wait_rdreq_reg <= '0';
         ELSIF (rx_eop_p0 = '1') THEN
            IF (rx_req_cycle = '1') THEN
               wait_rdreq_reg <= '1';
            ELSE
               wait_rdreq_reg <= '0';
            END IF;
         ELSIF ((wait_rdreq_reg = '1') AND (rx_req_cycle = '0')) THEN
            wait_rdreq_reg <= '0';
         END IF;
      END IF;
   END PROCESS;
   
   -- rx_req_cycle with current application 3 cycle required from rx_sop 
   -- this signal holds off on popping the next descriptor phase while the rx_req/
   -- rx_desc is being transferred to the application.
   
   -- (rx_sop_p0==1'b1) ||                       // in 64-bit mode, rx_req_cycle not required in sop cycle 
   rx_req_cycle <= '1' WHEN (rx_sop_hold2 = '1') ELSE
                   '0';
   
   xhdl13 <= '1' WHEN ((rx_sop_p0 = '1') OR (ctrl_next_rx_req(0) = '1')) ELSE
                   '0';
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            ctrl_next_rx_req <= "000";
            rx_sop_hold2 <= '0';
         ELSE
            ctrl_next_rx_req(0) <= rx_sop_p0;
            ctrl_next_rx_req(1) <= ctrl_next_rx_req(0);
            ctrl_next_rx_req(2) <= ctrl_next_rx_req(1);
            rx_sop_hold2 <= xhdl13;
         END IF;
      END IF;
   END PROCESS;
   
   -- Avalon-ST control signals
   
   rx_sop_p0 <= '1' WHEN (rx_sop = '1') ELSE        -- generating pulse rx_sop_p0, p1 
                '0';
   rx_eop_p0 <= '1' WHEN (rx_eop = '1') ELSE        -- generating pulse rx_eop_p0, p1 
                '0';
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rx_sop_next <= '0';
            rx_eop_next <= '0';
         ELSE
            rx_sop_next <= rx_sop;
            rx_eop_next <= rx_eop;
         END IF;
      END IF;
   END PROCESS;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         rx_sop_p1 <= rx_sop_p0;
         rx_eop_p1 <= rx_eop_p0;
      END IF;
   END PROCESS;
   
   ctrlrx_single_cycle <= ctrlrx_single_cycle_reg when (rx_sop='0') else
                          '1' when   (rxfifo_q(105 DOWNTO 96) = "0000000001") else '0';

   -- ctrlrx_payload is set when the TLP has payload 
   ctrlrx_payload <= '1' WHEN ((rx_sop = '1') AND (rxfifo_q(126) = '1')) ELSE
                     ctrlrx_payload_reg;

   -- ctrlrx_3dw is set when the TLP has 3 DWORD header 
   ctrlrx_3dw <= '1' WHEN ((rx_sop = '1') AND (rxfifo_q(125) = '0')) ELSE
                 ctrlrx_3dw_reg;
   -- ctrlrx_qword_aligned is set when the data are address aligned 
   ctrlrx_qword_aligned <= '1' WHEN ((rx_sop_p1 = '1') AND (((ctrlrx_3dw = '1') AND (rxfifo_q(98) = '0')) OR ((ctrlrx_3dw = '0') AND (rxfifo_q(66) = '0')))) ELSE
                           ctrlrx_qword_aligned_reg;

   ctrlrx_digest <=   ctrlrx_digest_reg when (rx_sop='0') else
                      '1' when (rxfifo_q(111) = '1') else '0';

   ctrlrx_length(9 DOWNTO 0) <=  ctrlrx_length_reg(9 DOWNTO 0) when (rx_sop='0') else 
                                 rxfifo_q(105 DOWNTO 96)       WHEN (rxfifo_q(126) = '1') else (others=>'0') ;
   
   xhdl14 <= '1' WHEN (rxfifo_q(126) = '1') ELSE
                                '0';
   xhdl15 <= '1' WHEN (rxfifo_q(125) = '0') ELSE
                                '0';
   
   xhdl16 <= '1' WHEN (((ctrlrx_3dw = '1') AND (rxfifo_q(98) = '0')) OR ((ctrlrx_3dw = '0') AND (rxfifo_q(66) = '0'))) ELSE
                                '0';
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            ctrlrx_single_cycle_reg <= '0';
            ctrlrx_3dw_reg <= '0';
            ctrlrx_qword_aligned_reg <= '0';
            ctrlrx_digest_reg <= '0';
            ctrlrx_length_reg <= "0000000000";
         ELSE
            ctrlrx_single_cycle_reg <= ctrlrx_single_cycle;
            ctrlrx_length_reg <= ctrlrx_length;
            ctrlrx_digest_reg <= ctrlrx_digest;
            IF (rx_sop_p0 = '1') THEN
               ctrlrx_payload_reg <= xhdl14;
               ctrlrx_3dw_reg <= xhdl15;
            ELSIF (((ctrlrx_single_cycle = '1') AND (ctrl_next_rx_req(2) = '1')) OR ((ctrlrx_single_cycle = '0') AND (rx_eop_p0 = '1'))) THEN
               ctrlrx_payload_reg <= '0';
               ctrlrx_3dw_reg <= '0';
            END IF;
            IF (rx_sop_p1 = '1') THEN
               ctrlrx_qword_aligned_reg <= xhdl16;
            ELSIF (((ctrlrx_single_cycle = '1') AND (ctrl_next_rx_req(2) = '1')) OR ((ctrlrx_single_cycle = '0') AND (rx_eop_p0 = '1'))) THEN
               ctrlrx_qword_aligned_reg <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   count_eop_nop <= '1' WHEN (((rxfifo_wrreq = '1') AND (rxfifo_d(138) = '1')) AND ((rxfifo_rreq_reg = '1') AND (rxfifo_q(138) = '1'))) ELSE
                    '0';
   
   last_eop_in_fifo <= '1' WHEN ((count_eop_in_rxfifo_is_one = '1') AND (count_eop_nop = '0') AND (rxfifo_rreq_reg = '1') AND (rxfifo_q(138) = '1')) ELSE
                       '0';
   
   tlp_in_rxfifo <= '1' WHEN ((rx_data_fifo_almostfull = '1') OR ((count_eop_in_rxfifo_is_zero = '0') AND (last_eop_in_fifo = '0'))) ELSE       -- Reduced-sized Fifo. Pop Fifo when TLP EOP is received (if FIFO is not filled), or when FIFO is almost full.
                    '0';
   
   xhdl17 <= '1' WHEN (count_eop_in_rxfifo = "000000") ELSE
                    '0';
   xhdl18 <= '1' WHEN (count_eop_in_rxfifo = "000010") ELSE
                    '0';
   xhdl19 <= '1' WHEN (count_eop_in_rxfifo = "000001") ELSE
                    '0';
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            count_eop_in_rxfifo <= "000000";
            count_eop_in_rxfifo_is_one <= '0';
            count_eop_in_rxfifo_is_zero <= '1';
         ELSIF (count_eop_nop = '0') THEN
            IF ((rxfifo_wrreq = '1') AND (rxfifo_d(138) = '1')) THEN
               count_eop_in_rxfifo <= count_eop_in_rxfifo + "000001";
               count_eop_in_rxfifo_is_one <= xhdl17;
               count_eop_in_rxfifo_is_zero <= '0';
            ELSIF ((rxfifo_rreq_reg = '1') AND (rxfifo_q(138) = '1')) THEN
               count_eop_in_rxfifo <= count_eop_in_rxfifo - "000001";
               count_eop_in_rxfifo_is_one <= xhdl18;
               count_eop_in_rxfifo_is_zero <= xhdl19;
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   xhdl20 : IF (ECRC_FORWARD_CHECK = 1) GENERATE
      
      
      altpcierd_cdma_ecrc_check_64_i : altpcierd_cdma_ecrc_check_64
         PORT MAP (
            -- Input Avalon-ST prior to check ecrc 
            rxdata                 => rxdata,
            rxdata_be              => rxdata_be,
            rx_stream_ready0       => rx_stream_ready0_reg,
            rx_stream_valid0       => rx_stream_valid0,
            
            -- Output Avalon-ST afetr checkeing ECRC 
            rxdata_ecrc            => rxdata_ecrc,
            rxdata_be_ecrc         => rxdata_be_ecrc,
            rx_stream_ready0_ecrc  => rx_stream_ready0_ecrc,
            rx_stream_valid0_ecrc  => rx_stream_valid0_ecrc,
            
            rx_ecrc_check_valid    => rx_ecrc_check_valid_xhdl4,
            ecrc_bad_cnt           => ecrc_bad_cnt_xhdl0,
            clk_in                 => clk_in,
            srst                   => srst
         );
   END GENERATE;
   xhdl21 : IF (NOT(ECRC_FORWARD_CHECK = 1)) GENERATE
      rxdata_ecrc <= rxdata;
      rxdata_be_ecrc <= rxdata_be;
      rx_stream_ready0_ecrc <= rx_stream_ready0_xhdl6;
      rx_ecrc_check_valid_xhdl4 <= '1';
      ecrc_bad_cnt_xhdl0 <= "0000000000000000";
   END GENERATE;
   
   
END ARCHITECTURE altpcie;
