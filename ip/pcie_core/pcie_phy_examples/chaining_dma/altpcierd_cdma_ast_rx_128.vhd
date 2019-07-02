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
-- File          : altpcierd_cdma_ast_rx_128.v
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
ENTITY altpcierd_cdma_ast_rx_128 IS
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
END ENTITY altpcierd_cdma_ast_rx_128;
ARCHITECTURE altpcie OF altpcierd_cdma_ast_rx_128 IS


                                                
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
                                                                       
      
      CONSTANT  RXFIFO_WIDTH         : INTEGER := 156;      -- WAS: 140
      CONSTANT RXFIFO_DEPTH         : INTEGER := 1024;
      CONSTANT RXFIFO_DEPTH_HALF         : INTEGER := 512;
      CONSTANT RXFIFO_WIDTHU        : INTEGER := 10;
                                                                       
   COMPONENT altpcierd_cdma_ecrc_check_128 IS
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
   
   

   SIGNAL rxfifo_usedw                      : STD_LOGIC_VECTOR(RXFIFO_WIDTHU - 1 DOWNTO 0);
   SIGNAL rxfifo_d                          : STD_LOGIC_VECTOR(155 DOWNTO 0);
   SIGNAL rxfifo_full                       : STD_LOGIC;
   SIGNAL rxfifo_empty                      : STD_LOGIC;
   SIGNAL rxfifo_rreq                       : STD_LOGIC;
   SIGNAL rxfifo_rreq_reg                   : STD_LOGIC;
   SIGNAL rxfifo_wrreq                      : STD_LOGIC;
   SIGNAL rxfifo_q                          : STD_LOGIC_VECTOR(155 DOWNTO 0);
   SIGNAL rxfifo_q_reg                      : STD_LOGIC_VECTOR(155 DOWNTO 0);
   
   SIGNAL rx_stream_ready0_reg              : STD_LOGIC;
   -- ECRC Check
   SIGNAL rxdata_ecrc                       : STD_LOGIC_VECTOR(139 DOWNTO 0);
   SIGNAL rxdata_be_ecrc                    : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL rx_stream_valid0_ecrc             : STD_LOGIC;
   SIGNAL rx_stream_ready0_ecrc             : STD_LOGIC;
   SIGNAL ctrlrx_single_cycle               : STD_LOGIC;
   SIGNAL rx_dfr_reg                        : STD_LOGIC;
   SIGNAL rx_dfr_digest                     : STD_LOGIC;
   SIGNAL rx_sop                            : STD_LOGIC;        -- TLP start of packet
   SIGNAL rx_sop_next                       : STD_LOGIC;
   SIGNAL rx_sop_p0                         : STD_LOGIC;        -- TLP start of packet single pulse
   SIGNAL rx_sop_p1                         : STD_LOGIC;
   SIGNAL rx_eop                            : STD_LOGIC;        -- TLP end of packet
   SIGNAL rx_eop_next                       : STD_LOGIC;
   SIGNAL rx_eop_p0                         : STD_LOGIC;        -- TLP end of packet single puclse
   SIGNAL rx_eop_p1                         : STD_LOGIC;
   SIGNAL ctrlrx_3dw                        : STD_LOGIC;        -- Set when TLP is 3 DW header 
   SIGNAL ctrlrx_3dw_reg                    : STD_LOGIC;
   SIGNAL ctrlrx_3dw_del                    : STD_LOGIC;
   SIGNAL ctrlrx_3dw_nonaligned             : STD_LOGIC;
   SIGNAL ctrlrx_3dw_nonaligned_reg         : STD_LOGIC;
   SIGNAL ctrlrx_dw_addroffeset             : STD_LOGIC_VECTOR(1 DOWNTO 0);     -- address offset (in DW) from 128-bit address boundary
   SIGNAL ctrlrx_dw_addroffeset_reg         : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL ctrlrx_length                     : STD_LOGIC_VECTOR(9 DOWNTO 0);     -- Set TLP length 
   SIGNAL ctrlrx_length_reg                 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL ctrlrx_count_length_dqword        : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL ctrlrx_count_length_dword         : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL ctrlrx_payload                    : STD_LOGIC;
   SIGNAL ctrlrx_payload_reg                : STD_LOGIC;
   SIGNAL ctrlrx_qword_aligned              : STD_LOGIC;        -- Set when TLP are qword aligned
   SIGNAL ctrlrx_qword_aligned_reg          : STD_LOGIC;
   SIGNAL ctrlrx_digest                     : STD_LOGIC;        -- Set when the TD digest bit is set in the descriptor
   SIGNAL ctrlrx_digest_reg                 : STD_LOGIC;
   SIGNAL ctrl_next_rx_req                  : STD_LOGIC_VECTOR(2 DOWNTO 0);
   
   SIGNAL count_eop_in_rxfifo               : STD_LOGIC_VECTOR(RXFIFO_WIDTHU - 1 DOWNTO 0);     -- Counter track the number of RX TLP in the RXFIFO 
   SIGNAL count_eop_nop                     : STD_LOGIC;
   SIGNAL last_eop_in_fifo                  : STD_LOGIC;
   SIGNAL tlp_in_rxfifo                     : STD_LOGIC;        -- set when there is a complete RX TLP in rxfifo
   SIGNAL wait_rdreq_reg                    : STD_LOGIC;
   SIGNAL wait_rdreq                        : STD_LOGIC;
   SIGNAL rx_req_cycle                      : STD_LOGIC;
   SIGNAL rx_ack_pending_del                : STD_LOGIC;
   SIGNAL rx_ack_pending                    : STD_LOGIC;
   SIGNAL rx_req_del                        : STD_LOGIC;
   SIGNAL rx_req_phase2                     : STD_LOGIC;
   SIGNAL ctrlrx_single_cycle_reg           : STD_LOGIC;
   SIGNAL rx_rd_req                         : STD_LOGIC;
   SIGNAL rx_rd_req_del                     : STD_LOGIC;
   SIGNAL rx_sop_last                       : STD_LOGIC;        -- means last data chunk was a SOP
   SIGNAL data_tail_be_mask                 : STD_LOGIC_VECTOR(15 DOWNTO 0);        -- mask out ECRC fields, and delineate end of rx_data0 DW 
   SIGNAL ctrlrx_count_length_dqword_zero   : STD_LOGIC;
   SIGNAL insert_extra_dfr_cycle            : STD_LOGIC;
   SIGNAL need_extra_dfr_cycle              : STD_LOGIC;
   SIGNAL got_eop                           : STD_LOGIC;
   
   --xhdl
   SIGNAL zeros_4                           : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL zeros_8                           : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL zeros_12                          : STD_LOGIC_VECTOR(11 DOWNTO 0);
   
   SIGNAL debug_3dw_aligned_dataless        : STD_LOGIC;
   SIGNAL debug_3dw_nonaligned_dataless     : STD_LOGIC;
   SIGNAL debug_4dw_aligned_dataless        : STD_LOGIC;
   SIGNAL debug_4dw_nonaligned_dataless     : STD_LOGIC;
   SIGNAL debug_3dw_aligned_withdata        : STD_LOGIC;
   SIGNAL debug_3dw_nonaligned_withdata     : STD_LOGIC;
   SIGNAL debug_4dw_aligned_withdata        : STD_LOGIC;
   SIGNAL debug_4dw_nonaligned_withdata     : STD_LOGIC;
   
   SIGNAL debug_3dw_dqw_nonaligned_withdata : STD_LOGIC;
   SIGNAL debug_4dw_dqw_nonaligned_withdata : STD_LOGIC;
   SIGNAL debug_3dw_dqw_aligned_withdata    : STD_LOGIC;
   SIGNAL debug_4dw_dqw_aligned_withdata    : STD_LOGIC;
   -- X-HDL generated signals
   SIGNAL xhdl7 : STD_LOGIC;
   SIGNAL xhdl8 : STD_LOGIC;
   SIGNAL xhdl9 : STD_LOGIC;
   SIGNAL xhdl10 : STD_LOGIC;
   SIGNAL xhdl11 : STD_LOGIC;
   SIGNAL xhdl12 : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL xhdl13 : STD_LOGIC;
   SIGNAL xhdl14 : STD_LOGIC;
   SIGNAL xhdl15 : STD_LOGIC;
   SIGNAL xhdl16 : STD_LOGIC;
   
   -- Declare intermediate signals for referenced outputs
   SIGNAL rx_stream_ready0_xhdl6            : STD_LOGIC;
   SIGNAL rx_req0_xhdl5                     : STD_LOGIC;
   SIGNAL rx_desc0_xhdl1                    : STD_LOGIC_VECTOR(135 DOWNTO 0);
   SIGNAL rx_dv0_xhdl3                      : STD_LOGIC;
   SIGNAL rx_dfr0_xhdl2                     : STD_LOGIC;
   SIGNAL rx_ecrc_check_valid_xhdl4         : STD_LOGIC;
   SIGNAL ecrc_bad_cnt_xhdl0                : STD_LOGIC_VECTOR(15 DOWNTO 0);
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
   zeros_8 <= "00000000";
   zeros_12 <= "000000000000";
   
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
            IF (rxfifo_usedw > to_stdlogicvector(RXFIFO_DEPTH_HALF, 10)) THEN       -- ||(rx_ws0==1'b1))
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
         usedw  => rxfifo_usedw
      );
   
   rx_stream_ready0_xhdl6 <= rx_stream_ready0_reg WHEN (ECRC_FORWARD_CHECK = 0) ELSE
                             rx_stream_ready0_ecrc;
   rxfifo_wrreq <= rx_stream_valid0 WHEN (ECRC_FORWARD_CHECK = 0) ELSE
                   rx_stream_valid0_ecrc;
   rxfifo_d <= (rxdata_be & rxdata) WHEN (ECRC_FORWARD_CHECK = 0) ELSE
               (rxdata_be_ecrc & rxdata_ecrc);
   
   rx_rd_req <= '1' WHEN ((rx_ack_pending = '0') AND ((rx_dv0_xhdl3 = '0') OR (rx_ws0 = '0'))) ELSE
                '0';
   
   rxfifo_rreq <= '1' WHEN ((rxfifo_empty = '0') AND (tlp_in_rxfifo = '1') AND (rx_rd_req = '1') AND (wait_rdreq = '0')) ELSE
                  '0';
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rx_rd_req_del <= '0';
            rxfifo_rreq_reg <= '0';
         ELSE
            rx_rd_req_del <= rx_rd_req;
            rxfifo_rreq_reg <= rxfifo_rreq;
         END IF;
      END IF;
   END PROCESS;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         rxfifo_q_reg <= rxfifo_q;
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
   rx_eop <= '1' WHEN ((rxfifo_q(136) = '1') AND (rxfifo_rreq_reg = '1')) ELSE
             '0';
   
   xhdl7 <= rx_sop WHEN (rxfifo_rreq_reg = '1') ELSE        -- remember if last data chunk was an SOP
             rx_sop_last;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         rx_sop_last <= xhdl7;
      END IF;
   END PROCESS;
   
   xhdl8 <= '1' WHEN (rx_eop = '1') ELSE
                  got_eop;
   xhdl9 <= '0' WHEN ((rx_sop = '1') AND (rx_eop = '0')) ELSE
                  xhdl8;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            got_eop <= '0';
         ELSE
            got_eop <= xhdl9;
         END IF;
      END IF;
   END PROCESS;
   
   -- RX_DESC
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rx_desc0_xhdl1 <= "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
         ELSIF (rx_sop_p0 = '1') THEN
            rx_desc0_xhdl1(135 DOWNTO 0) <= rxfifo_q(135 DOWNTO 0);
         END IF;
      END IF;
   END PROCESS;
   
   -- 128-bit address realignment.
   -- stream data is 64-bit address aligned.  
   -- need to shift QW based on address alignment, and need to 
   -- un-flip the DWs (IS:  stream comes in wiht DW0 on left, S/B: rx_data presents DW0 on right)
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (ctrlrx_3dw_del = '1') THEN     -- 3DW header pkts pack desc and data into same stream cycle, depending on address alignment.  
            CASE ctrlrx_dw_addroffeset_reg IS       -- start addr is on 128-bit addr boundary
               WHEN "00" =>     -- start addr is 1DW offset from 128-bit addr boundary  (first QW is saved from desc phase, and appended to next QW))
                  rx_data0 <= (rxfifo_q(31 DOWNTO 0) & rxfifo_q(63 DOWNTO 32) & rxfifo_q(95 DOWNTO 64) & rxfifo_q(127 DOWNTO 96));
               WHEN "01" =>     -- first QW is shifted left by a QW
                  rx_data0 <= (rxfifo_q(95 DOWNTO 64) & rxfifo_q(127 DOWNTO 96) & rxfifo_q_reg(31 DOWNTO 0) & rxfifo_q_reg(63 DOWNTO 32));
               WHEN "10" =>     -- start addr is 1DW + 1QW offset from 128-bit addr boundary  (first QW is saved from desc phase, and placed in high QW of next phase.  all other dataphases are delayed 1 clk.) 
                  rx_data0 <= (rxfifo_q(95 DOWNTO 64) & rxfifo_q(127 DOWNTO 96) & rxfifo_q_reg(31 DOWNTO 0) & rxfifo_q_reg(63 DOWNTO 32));
               WHEN "11" =>
                  rx_data0 <= (rxfifo_q_reg(31 DOWNTO 0) & rxfifo_q_reg(63 DOWNTO 32) & rxfifo_q_reg(95 DOWNTO 64) & rxfifo_q_reg(127 DOWNTO 96));
               WHEN OTHERS =>
                  NULL;
            END CASE;
         ELSE
            -- for 4DW header pkts, only QW alignment adjustment is required
            CASE ctrlrx_dw_addroffeset_reg IS       -- start addr is on 128-bit addr boundary
               WHEN "00" =>     -- start addr is 1DW offset from 128-bit addr boundary  
                  rx_data0 <= (rxfifo_q(31 DOWNTO 0) & rxfifo_q(63 DOWNTO 32) & rxfifo_q(95 DOWNTO 64) & rxfifo_q(127 DOWNTO 96));
               WHEN "01" =>     -- first QW is shifted left by a QW
                  rx_data0 <= (rxfifo_q(31 DOWNTO 0) & rxfifo_q(63 DOWNTO 32) & rxfifo_q(95 DOWNTO 64) & rxfifo_q(127 DOWNTO 96));
               WHEN "10" =>     -- start addr is 1DW + 1QW offset from 128-bit addr boundary  (first QW is saved from desc phase, and placed in high QW of next phase.  all other dataphases are delayed 1 clk.) 
                  rx_data0 <= (rxfifo_q(95 DOWNTO 64) & rxfifo_q(127 DOWNTO 96) & rxfifo_q_reg(31 DOWNTO 0) & rxfifo_q_reg(63 DOWNTO 32));
               WHEN "11" =>
                  rx_data0 <= (rxfifo_q(95 DOWNTO 64) & rxfifo_q(127 DOWNTO 96) & rxfifo_q_reg(31 DOWNTO 0) & rxfifo_q_reg(63 DOWNTO 32));
               WHEN OTHERS =>
                  NULL;
            END CASE;
         END IF;
         
         -- BYTE ENABLES
         
         IF ((rx_sop_last = '1') AND (ctrlrx_3dw_del = '1')) THEN       -- 3DW non-aligned:  Mask out address offset.
            -- First Data Phase for 3DW header
            CASE ctrlrx_dw_addroffeset_reg IS       -- No data offset     
               WHEN "00" =>     -- 1 DW offset
                  rx_be0 <= (rxfifo_q(143 DOWNTO 140) & rxfifo_q(147 DOWNTO 144) & rxfifo_q(151 DOWNTO 148) & rxfifo_q(155 DOWNTO 152)) AND data_tail_be_mask;
               WHEN "01" =>     -- QW offset (first QW is shifted left by a QW)
                  rx_be0 <= (rxfifo_q(151 DOWNTO 148) & rxfifo_q(155 DOWNTO 152) & rxfifo_q_reg(143 DOWNTO 140) & zeros_4) AND data_tail_be_mask;
               WHEN "10" =>     -- start addr is 1DW + 1QW offset from 128-bit addr boundary  (first QW is saved from desc phase, and placed in high QW of next phase.  all other dataphases are delayed 1 clk.)  
                  rx_be0 <= (rxfifo_q(151 DOWNTO 148) & rxfifo_q(155 DOWNTO 152) & zeros_8) AND data_tail_be_mask;
               WHEN "11" =>
                  rx_be0 <= (rxfifo_q_reg(143 DOWNTO 140) & zeros_4 & zeros_8) AND data_tail_be_mask;
               WHEN OTHERS =>
                  NULL;
            END CASE;
         ELSIF (ctrlrx_3dw_del = '1') THEN      -- Subsequent data phases for 3DW header                                                                           
            CASE ctrlrx_dw_addroffeset_reg IS       -- No data offset     
               WHEN "00" =>     -- 1 DW offset
                  rx_be0 <= (rxfifo_q(143 DOWNTO 140) & rxfifo_q(147 DOWNTO 144) & rxfifo_q(151 DOWNTO 148) & rxfifo_q(155 DOWNTO 152)) AND data_tail_be_mask;
               WHEN "01" =>     -- QW offset (first QW is shifted left by a QW)
                  rx_be0 <= (rxfifo_q(151 DOWNTO 148) & rxfifo_q(155 DOWNTO 152) & rxfifo_q_reg(143 DOWNTO 140) & rxfifo_q_reg(147 DOWNTO 144)) AND data_tail_be_mask;
               WHEN "10" =>     -- start addr is 1DW + 1QW offset from 128-bit addr boundary  (first QW is saved from desc phase, and placed in high QW of next phase.  all other dataphases are delayed 1 clk.)  
                  rx_be0 <= (rxfifo_q(151 DOWNTO 148) & rxfifo_q(155 DOWNTO 152) & rxfifo_q_reg(143 DOWNTO 140) & rxfifo_q_reg(147 DOWNTO 144)) AND data_tail_be_mask;
               WHEN "11" =>
                  rx_be0 <= (rxfifo_q_reg(143 DOWNTO 140) & rxfifo_q_reg(147 DOWNTO 144) & rxfifo_q_reg(151 DOWNTO 148) & rxfifo_q_reg(155 DOWNTO 152)) AND data_tail_be_mask;
               WHEN OTHERS =>
                  NULL;
            END CASE;
         ELSIF ((rx_sop_last = '1') AND (ctrlrx_3dw_del = '0')) THEN        --  First Data Phase for 4DW header
            CASE ctrlrx_dw_addroffeset_reg IS
               WHEN "00" =>     -- Mask out DW offset (actually, already taken care of by core)
                  rx_be0 <= (rxfifo_q(143 DOWNTO 140) & rxfifo_q(147 DOWNTO 144) & rxfifo_q(151 DOWNTO 148) & rxfifo_q(155 DOWNTO 152)) AND data_tail_be_mask;
               WHEN "01" =>
                  rx_be0 <= (rxfifo_q(143 DOWNTO 140) & rxfifo_q(147 DOWNTO 144) & rxfifo_q(151 DOWNTO 148) & zeros_4) AND data_tail_be_mask;
               WHEN "10" =>
                  rx_be0 <= (rxfifo_q(151 DOWNTO 148) & rxfifo_q(155 DOWNTO 152) & zeros_8) AND data_tail_be_mask;
               WHEN "11" =>
                  rx_be0 <= (rxfifo_q(151 DOWNTO 148) & zeros_4 & zeros_8) AND data_tail_be_mask;
               WHEN OTHERS =>
                  NULL;
            END CASE;
         ELSIF (ctrlrx_3dw_del = '0') THEN      --  Subsequent Data Phase for 4DW header
            CASE ctrlrx_dw_addroffeset_reg IS
               WHEN "00" =>
                  rx_be0 <= (rxfifo_q(143 DOWNTO 140) & rxfifo_q(147 DOWNTO 144) & rxfifo_q(151 DOWNTO 148) & rxfifo_q(155 DOWNTO 152)) AND data_tail_be_mask;
               WHEN "01" =>
                  rx_be0 <= (rxfifo_q(143 DOWNTO 140) & rxfifo_q(147 DOWNTO 144) & rxfifo_q(151 DOWNTO 148) & rxfifo_q(155 DOWNTO 152)) AND data_tail_be_mask;
               WHEN "10" =>
                  rx_be0 <= (rxfifo_q(151 DOWNTO 148) & rxfifo_q(155 DOWNTO 152) & rxfifo_q_reg(143 DOWNTO 140) & rxfifo_q_reg(147 DOWNTO 144)) AND data_tail_be_mask;
               WHEN "11" =>
                  rx_be0 <= (rxfifo_q(151 DOWNTO 148) & rxfifo_q(155 DOWNTO 152) & rxfifo_q_reg(143 DOWNTO 140) & rxfifo_q_reg(147 DOWNTO 144)) AND data_tail_be_mask;
               WHEN OTHERS =>
                  NULL;
            END CASE;
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (ctrlrx_count_length_dword)
   BEGIN
      -- create bit significant vector to mask the end of payload data. 
      -- this includes masking out ECRC fields.
      
      IF (ctrlrx_count_length_dword(9 DOWNTO 2) > "00000000") THEN      -- # of payload DWs left to pass to rx_data0 including this cycle is >4 DWs.  This count is already adjusted for addr offsets.
         data_tail_be_mask <= "1111111111111111";
      ELSE
         -- this is the last payload cycle.  mask out non-Payload bytes.
         CASE ctrlrx_count_length_dword(1 DOWNTO 0) IS
            WHEN "00" =>
               data_tail_be_mask <= "0000000000000000";
            WHEN "01" =>
               data_tail_be_mask <= "0000000000001111";
            WHEN "10" =>
               data_tail_be_mask <= "0000000011111111";
            WHEN "11" =>
               data_tail_be_mask <= "0000111111111111";
            WHEN OTHERS =>
               NULL;
         END CASE;
      END IF;
   END PROCESS;
   
   --   RX_REQ
   
   
   xhdl10 <= '1' WHEN ((rx_req_del = '0') AND (rx_req0_xhdl5 = '1')) ELSE       -- assert while in phase 2 (waiting for ack) of descriptor
                        rx_req_phase2;
   xhdl11 <= '0' WHEN (rx_ack0 = '1') ELSE
                        xhdl10;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rx_ack_pending_del <= '0';
            rx_req0_xhdl5 <= '0';
            rx_req_del <= '0';
            rx_req_phase2 <= '0';
         ELSE
            IF (rx_ack0 = '1') THEN
               rx_req0_xhdl5 <= '0';
            ELSIF (rx_sop_p0 = '1') THEN
               rx_req0_xhdl5 <= '1';
            END IF;
            rx_req_del <= rx_req0_xhdl5;
            rx_req_phase2 <= xhdl11;
            rx_ack_pending_del <= rx_ack_pending;
         END IF;
      END IF;
   END PROCESS;
   
   rx_ack_pending <= '0' WHEN (rx_ack0 = '1') ELSE      -- means rx_ack is delayed, hold off on fifo reads until ack is received.
                     '1' WHEN (rx_req_phase2 = '1') ELSE
                     rx_ack_pending_del;
   
   --   RX_DFR
   -- Calculate # of rx_data DWs to be passed to rx_data0, including empty DWs (due to address offset)
   -- Construct rx_dfr/dv based on this payload count.
   -- NOTE:  This desc/data interface has a 2 clk cycle response to rx_ws (and not 1) 
   --        rx_ws pops the rx fifo
   --        1 clk cycle later, inputs to rx_dfr/dv/data are all updated on rx_rd_req_del (coinciding with rxfifo_q being valid) 
   --        1 clk cycle later, rx_dfr/dv/data register outputs are updated.
   
   -- DW unit remaining count
   -- represents payload length (in DWs) not yet passed on rx_data0/rx_dv0 
   -- update when new data is valid 
   
   -- 128-bit unit remaining count (payload                              remaining to be popped from fifo)
   xhdl12 <= ctrlrx_dw_addroffeset & ctrlrx_length(1 DOWNTO 0);
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            ctrlrx_count_length_dqword <= "00000000";
            ctrlrx_count_length_dword <= "0000000000";
            ctrlrx_count_length_dqword_zero <= '1';
         ELSE
            IF (rx_sop_p0 = '1') THEN
               IF (ctrlrx_payload = '1') THEN
                  CASE ctrlrx_dw_addroffeset IS
                     WHEN "00" =>
                        ctrlrx_count_length_dword <= ctrlrx_length;
                     WHEN "01" =>
                        ctrlrx_count_length_dword <= ctrlrx_length + "0000000001";
                     WHEN "10" =>
                        ctrlrx_count_length_dword <= ctrlrx_length + "0000000010";
                     WHEN "11" =>
                        ctrlrx_count_length_dword <= ctrlrx_length + "0000000011";
                     WHEN OTHERS =>
                        NULL;
                  END CASE;
               ELSE
                  ctrlrx_count_length_dword <= "0000000000";
               END IF;
            ELSIF ((ctrlrx_count_length_dword > "0000000011") AND (rx_rd_req_del = '1')) THEN
               ctrlrx_count_length_dword <= ctrlrx_count_length_dword - "0000000100";
            END IF;
            IF ((ctrlrx_single_cycle = '1') AND (rx_sop_p0 = '1')) THEN
               ctrlrx_count_length_dqword <= "00000001";
            ELSIF ((rx_sop_p0 = '1') AND (ctrlrx_payload = '1')) THEN
               CASE xhdl12 IS       -- data is 128-bit aligned and modulo-128 
                  WHEN "0000" =>        -- data is 128-bit aligned       
                     ctrlrx_count_length_dqword(7 DOWNTO 0) <= ctrlrx_length(9 DOWNTO 2);
                  WHEN "0001" =>        -- data is 128-bit aligned   
                     ctrlrx_count_length_dqword(7 DOWNTO 0) <= ctrlrx_length(9 DOWNTO 2) + "00000001";
                  WHEN "0010" =>        -- data is 128-bit aligned   
                     ctrlrx_count_length_dqword(7 DOWNTO 0) <= ctrlrx_length(9 DOWNTO 2) + "00000001";
                  WHEN "0011" =>
                     ctrlrx_count_length_dqword(7 DOWNTO 0) <= ctrlrx_length(9 DOWNTO 2) + "00000001";
                  WHEN "0100" =>
                     ctrlrx_count_length_dqword(7 DOWNTO 0) <= ctrlrx_length(9 DOWNTO 2) + "00000001";
                  WHEN "0101" =>
                     ctrlrx_count_length_dqword(7 DOWNTO 0) <= ctrlrx_length(9 DOWNTO 2) + "00000001";
                  WHEN "0110" =>
                     ctrlrx_count_length_dqword(7 DOWNTO 0) <= ctrlrx_length(9 DOWNTO 2) + "00000001";
                  WHEN "0111" =>
                     ctrlrx_count_length_dqword(7 DOWNTO 0) <= ctrlrx_length(9 DOWNTO 2) + "00000001";
                  WHEN "1000" =>
                     ctrlrx_count_length_dqword(7 DOWNTO 0) <= ctrlrx_length(9 DOWNTO 2) + "00000001";
                  WHEN "1001" =>
                     ctrlrx_count_length_dqword(7 DOWNTO 0) <= ctrlrx_length(9 DOWNTO 2) + "00000001";
                  WHEN "1010" =>
                     ctrlrx_count_length_dqword(7 DOWNTO 0) <= ctrlrx_length(9 DOWNTO 2) + "00000001";
                  WHEN "1011" =>
                     ctrlrx_count_length_dqword(7 DOWNTO 0) <= ctrlrx_length(9 DOWNTO 2) + "00000010";
                  WHEN "1100" =>
                     ctrlrx_count_length_dqword(7 DOWNTO 0) <= ctrlrx_length(9 DOWNTO 2) + "00000001";
                  WHEN "1101" =>
                     ctrlrx_count_length_dqword(7 DOWNTO 0) <= ctrlrx_length(9 DOWNTO 2) + "00000001";
                  WHEN "1110" =>
                     ctrlrx_count_length_dqword(7 DOWNTO 0) <= ctrlrx_length(9 DOWNTO 2) + "00000010";
                  WHEN "1111" =>
                     ctrlrx_count_length_dqword(7 DOWNTO 0) <= ctrlrx_length(9 DOWNTO 2) + "00000010";
                  WHEN OTHERS =>
                     NULL;
               END CASE;
            ELSIF ((ctrlrx_count_length_dqword > "00000000") AND (rx_rd_req_del = '1')) THEN        -- update when new data is valid
               ctrlrx_count_length_dqword <= ctrlrx_count_length_dqword - "00000001";
            END IF;
            
            IF ((ctrlrx_count_length_dqword = "00000001") AND (rx_rd_req_del = '1')) THEN       -- update when new data is valid
               ctrlrx_count_length_dqword_zero <= '1';
            ELSIF ((rx_sop_p0 = '1') AND (ctrlrx_payload = '1')) THEN
               ctrlrx_count_length_dqword_zero <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   rx_dfr_digest <= '1' WHEN ((rx_dfr_reg = '1') AND (ctrlrx_count_length_dqword > "00000000")) ELSE
                    '0';
   -- assign rx_dfr0       = (ctrlrx_count_length_dqword>0);
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rx_dfr0_xhdl2 <= '0';
         ELSE
            IF ((rx_sop_p0 = '1') AND (rxfifo_q(126) = '1')) THEN       -- assert on sop, if there is payload
               rx_dfr0_xhdl2 <= '1';        -- deassert when counter is about to roll over to 0.
            ELSIF ((ctrlrx_count_length_dqword = "00000001") AND (rx_rd_req_del = '1')) THEN
               rx_dfr0_xhdl2 <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rx_dfr_reg <= '0';
         ELSIF (ctrlrx_payload = '1') THEN
            IF (ctrlrx_single_cycle = '1') THEN
               rx_dfr_reg <= rx_sop_p0;
            ELSIF (rx_sop_p0 = '1') THEN
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
   xhdl13 <= rx_dfr0_xhdl2 WHEN (rx_rd_req_del = '1') ELSE      -- update rx_dv0 only on rx_ws
                 rx_dv0_xhdl3;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         rx_dv0_xhdl3 <= xhdl13;
      END IF;
   END PROCESS;
   
   --------------------------------------------------------------
   --   Misc control signla to convert Avalon-ST to Desc/Data
   --------------------------------------------------------------
   wait_rdreq <= '1' WHEN (((rx_eop_p0 = '1') AND (rx_req_cycle = '1')) OR (((rx_eop_p0 = '1') OR (got_eop = '1')) AND (ctrlrx_count_length_dqword_zero = '0'))) ELSE       --(rx_dfr0==1'b1))) ?1'b1:  // throttle fetch of next stream data if there is an eop, and within a few cycles of last rx_sop, or rx_dfr is still asserted (means an extra cycle is needed to transfer offset data)
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
   rx_req_cycle <= '1' WHEN ((rx_sop_p0 = '1') OR (ctrl_next_rx_req(0) = '1') OR (ctrl_next_rx_req(1) = '1')) ELSE
                   '0';
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            ctrl_next_rx_req <= "000";
         ELSE
            ctrl_next_rx_req(0) <= rx_sop_p0;
            ctrl_next_rx_req(1) <= ctrl_next_rx_req(0);
            ctrl_next_rx_req(2) <= ctrl_next_rx_req(1);
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
   
   ctrlrx_single_cycle <= ctrlrx_single_cycle_reg WHEN (rx_sop = '0') ELSE
                          '1' WHEN (rx_eop = '1') ELSE
                          '0' ;
                          
   -- ctrlrx_payload is set when the TLP has payload 
   ctrlrx_payload <= '1' WHEN ((rx_sop = '1') AND (rxfifo_q(126) = '1')) ELSE
                     ctrlrx_payload_reg;
   -- ctrlrx_3dw is set when the TLP has 3 DWORD header 
   ctrlrx_3dw <= '1' WHEN ((rx_sop = '1') AND (rxfifo_q(125) = '0')) ELSE
                 ctrlrx_3dw_reg;
   ctrlrx_3dw_nonaligned <= '1' WHEN ((rx_sop = '1') AND (rxfifo_q(125) = '0') AND (rxfifo_q(34) = '1')) ELSE
                            ctrlrx_3dw_nonaligned_reg;
   ctrlrx_dw_addroffeset <= ctrlrx_dw_addroffeset_reg WHEN (rx_sop = '0') ELSE
                            rxfifo_q(35 DOWNTO 34) WHEN (rxfifo_q(125) = '0') ELSE
                            rxfifo_q(3 DOWNTO 2) ;
   
   -- ctrlrx_qword_aligned is set when the data are address aligned 
   ctrlrx_qword_aligned <= '1' WHEN ((rx_sop = '1') AND (((ctrlrx_3dw = '1') AND (rxfifo_q(34 DOWNTO 32) = "000")) OR ((ctrlrx_3dw = '0') AND (rxfifo_q(2 DOWNTO 0) = "000")))) ELSE
                           ctrlrx_qword_aligned_reg;
   ctrlrx_digest <= ctrlrx_digest_reg WHEN (rx_sop = '0') ELSE
                    '1' WHEN (rxfifo_q(111) = '1') ELSE
                    '0';
   ctrlrx_length(9 DOWNTO 0) <=  ctrlrx_length_reg(9 DOWNTO 0) WHEN (rx_sop = '0') ELSE 
                                 rxfifo_q(105 DOWNTO 96) WHEN (rxfifo_q(126) = '1') ELSE
                                "0000000000";
   
   
   xhdl14 <= '1' WHEN (rxfifo_q(125) = '0') ELSE
                                '0';
   xhdl15 <= '1' WHEN (rxfifo_q(126) = '1') ELSE
                                '0';
   xhdl16 <= '1' WHEN (((ctrlrx_3dw = '1') AND (rxfifo_q(34 DOWNTO 32) = "000")) OR ((ctrlrx_3dw = '0') AND (rxfifo_q(2 DOWNTO 0) = "000"))) ELSE
                                '0';
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            ctrlrx_single_cycle_reg <= '0';
            ctrlrx_payload_reg <= '0';
            ctrlrx_3dw_reg <= '0';
            ctrlrx_3dw_del <= '0';
            ctrlrx_dw_addroffeset_reg <= "00";
            ctrlrx_3dw_nonaligned_reg <= '0';
            ctrlrx_qword_aligned_reg <= '0';
            ctrlrx_digest_reg <= '0';
            ctrlrx_length_reg <= "0000000000";
            ctrlrx_length_reg <= "0000000000";
         ELSE
            ctrlrx_single_cycle_reg <= ctrlrx_single_cycle;
            ctrlrx_dw_addroffeset_reg <= ctrlrx_dw_addroffeset;
            ctrlrx_3dw_nonaligned_reg <= ctrlrx_3dw_nonaligned;
            ctrlrx_3dw_del <= ctrlrx_3dw;
            ctrlrx_digest_reg <= ctrlrx_digest;
            ctrlrx_length_reg <= ctrlrx_length; 
           IF (rx_sop_p0 = '1') THEN
               ctrlrx_3dw_reg <= xhdl14;
               ctrlrx_payload_reg <= xhdl15;
              ctrlrx_qword_aligned_reg <= xhdl16;
           ELSIF (((ctrlrx_single_cycle = '1') AND (ctrl_next_rx_req(2) = '1')) OR ((ctrlrx_single_cycle = '0') AND (rx_eop_p0 = '1'))) THEN
               ctrlrx_3dw_reg <= '0';
               ctrlrx_payload_reg <= '0';
               ctrlrx_qword_aligned_reg <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   count_eop_nop <= '1' WHEN (((rxfifo_wrreq = '1') AND (rxfifo_d(136) = '1')) AND ((rxfifo_rreq_reg = '1') AND (rxfifo_q(136) = '1'))) ELSE
                    '0';
   
   last_eop_in_fifo <= '1' WHEN ((count_eop_in_rxfifo = "0000000001") AND (count_eop_nop = '0') AND (rxfifo_rreq_reg = '1') AND (rxfifo_q(136) = '1')) ELSE
                       '0';
   
   tlp_in_rxfifo <= '0' WHEN ((count_eop_in_rxfifo = "0000000000") OR (last_eop_in_fifo = '1')) ELSE
                    '1';
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            count_eop_in_rxfifo <= "0000000000";
         ELSIF (count_eop_nop = '0') THEN
            IF ((rxfifo_wrreq = '1') AND (rxfifo_d(136) = '1')) THEN
               count_eop_in_rxfifo <= count_eop_in_rxfifo + "0000000001";
            ELSIF ((rxfifo_rreq_reg = '1') AND (rxfifo_q(136) = '1')) THEN
               count_eop_in_rxfifo <= count_eop_in_rxfifo - "0000000001";
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   xhdl17 : IF (ECRC_FORWARD_CHECK = 1) GENERATE
      
      
      altpcierd_cdma_ecrc_check_128_i : altpcierd_cdma_ecrc_check_128  
         PORT MAP (
            -- Input Avalon-ST prior to check ECRC 
            rxdata                 => rxdata,
            rxdata_be              => rxdata_be,
            rx_stream_ready0       => rx_stream_ready0_reg,
            rx_stream_valid0       => rx_stream_valid0,
            
            -- Output Avalon-ST after checking ECRC 
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
   xhdl18 : IF (NOT(ECRC_FORWARD_CHECK = 1)) GENERATE
      rxdata_ecrc <= rxdata;
      rxdata_be_ecrc <= rxdata_be;
      rx_stream_ready0_ecrc <= rx_stream_ready0_xhdl6;
      rx_ecrc_check_valid_xhdl4 <= '1';
      ecrc_bad_cnt_xhdl0 <= "0000000000000000";
   END GENERATE;
   
   
END ARCHITECTURE altpcie;
