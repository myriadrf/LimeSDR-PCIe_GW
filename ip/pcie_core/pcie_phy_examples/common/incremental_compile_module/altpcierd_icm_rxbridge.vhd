LIBRARY ieee;                          
use IEEE.std_logic_1164.all;           
use IEEE.std_logic_arith.all;          
use IEEE.std_logic_unsigned.all;       
                                       
LIBRARY altera_mf;                     
USE altera_mf.altera_mf_components.all;
                                       
--
-- synthesis verilog_version verilog_2001
-------------------------------------------------------------------------------
-- Title         : PCI Express Reference Design Example Application 
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcierd_icm_rxbridge.v
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
-- first cycle of transfer. always descriptor_hi cycle.
-- last cycle of transfer
-- muxed be/bar bus. valid when data phase
-- muxed be/bar bus. valid when descriptor phase 
-- muxed data/descriptor bus
ENTITY altpcierd_icm_rxbridge IS
   PORT (
      clk                     : IN std_logic;   
      rstn                    : IN std_logic;   
      rx_req                  : IN std_logic;   --  core pkt request 
      rx_ack                  : OUT std_logic;   --  core rx_ack handshake
      rx_desc                 : IN std_logic_vector(135 DOWNTO 0);   --  core pkt descriptor
      rx_data                 : IN std_logic_vector(63 DOWNTO 0);   --  core payload data
      rx_be                   : IN std_logic_vector(7 DOWNTO 0);   --  core byte enable bits
      rx_ws                   : OUT std_logic;   --  core data throttling
      rx_dv                   : IN std_logic;   --  core rx_data is valid
      rx_dfr                  : IN std_logic;   --  core has more data cycles
      rx_abort                : OUT std_logic;   --  core rx_abort handshake 
      rx_retry                : OUT std_logic;   --  core rx_retry handshake
      rx_mask                 : OUT std_logic;   --  core rx_mask handshake
      stream_ready            : IN std_logic;   --  means streaming interface can accept more data
      stream_wr               : OUT std_logic;   --  means stream_wrdata is valid
      stream_wrdata           : OUT std_logic_vector(107 DOWNTO 0));   
END ENTITY altpcierd_icm_rxbridge;
ARCHITECTURE translated OF altpcierd_icm_rxbridge IS
   --USER DEFINED PARAMETER. 
   CONSTANT  DROP_MESSAGE          :  std_logic := '1';    --  when 1'b1, the bridge acks messages from the core, then drops them.  
   -- when 1'b0, the bridge acks messages from the core, and passes them to the streaming interface.
   -- bridge_sm states
   CONSTANT  STREAM_DESC1          :  std_logic_vector(1 DOWNTO 0) := "00";    --  write hi descriptor to streaming interface
   CONSTANT  STREAM_DESC2          :  std_logic_vector(1 DOWNTO 0) := "01";    --  write lo descriptor to streaming interface  
   CONSTANT  STREAM_DATA           :  std_logic_vector(1 DOWNTO 0) := "10";    --  write dataphase to streaming interface  
   CONSTANT  DEFERRED_CYCLE        :  std_logic_vector(1 DOWNTO 0) := "11";    --  write last data cycle to streaming interface if in deferred mode 
   SIGNAL start_of_pkt_flag        :  std_logic;   --  menas this cycle is the first of the transfer (always desc phase 1)
   SIGNAL end_of_pkt_flag          :  std_logic;   --  means this cycle is the last of the transfer
   SIGNAL has_payload              :  std_logic;   --  means this transfer contains data cycles
   SIGNAL muxed_stream_wrdata      :  std_logic_vector(63 DOWNTO 0);   --  mulitplexed desc/data bus data to be written to be transferred
   SIGNAL muxed_bar_bits           :  std_logic_vector(7 DOWNTO 0);   --  multiplexed desc/data bus byte_ena/bar field to be transferred 
   SIGNAL rx_be_last               :  std_logic_vector(7 DOWNTO 0);   --  byte enable bits from last cycle.  for deferred mode.  
   SIGNAL rx_data_last             :  std_logic_vector(63 DOWNTO 0);   --  payload data from last cycle.  for deferred mode.
   SIGNAL defer_data_cycle         :  std_logic;   --  when data phase coincides with descriptor phase, defer writing it to the fifo until after desc phase is written.
   SIGNAL muxed_rx_be              :  std_logic_vector(7 DOWNTO 0);   --  byte enable bits to be muxed onto muxed_bar_bits
   SIGNAL bridge_sm                :  std_logic_vector(1 DOWNTO 0);   --  bridge state machine. controls data throttling on both streaming and core interfaces
   SIGNAL enable_desc1             :  std_logic;   --  selects high descriptor bytes for streaming interface data
   SIGNAL enable_desc2             :  std_logic;   --  selects low descriptor bytes for streaming interface data 
   SIGNAL write_streaming_data     :  std_logic;   --  writes data to streaming interface
   SIGNAL stream_deferred_data     :  std_logic;   --  means data payload is streamed in deferred mode
   SIGNAL last_deferred_cycle      :  std_logic;   --  means current cycle is the last deferred data cycle
   SIGNAL enable_core_dataphase    :  std_logic;   --  allows bridge to accept payload data from core
   SIGNAL filter_out_msg           :  std_logic;   --  if tlp is a message, ack it, and drop it.  do not pass to streaming interface.  active only if user parameter DROP_MESSAGE is true.
   SIGNAL filter_out_msg_n         :  std_logic;   
   SIGNAL type_is_message          :  std_logic;   
   SIGNAL type_is_message_mem      :  std_logic;   
   SIGNAL type_is_message_mem_r    :  std_logic;   
   SIGNAL rxdesc_type_field        :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL temp_xhdl8               :  std_logic;   
   SIGNAL temp_xhdl9               :  std_logic;   
   -- data phase with cycle stealing - deferred cycle has priority over any new rx_req
   -- first descriptor phase
   -- second descriptor phase 
   SIGNAL temp_xhdl10              :  std_logic_vector(63 DOWNTO 0);   --  data phase without cycle stealing (write_streaming_data)
   SIGNAL temp_xhdl11              :  std_logic_vector(127 DOWNTO 64);   
   SIGNAL temp_xhdl12              :  std_logic_vector(63 DOWNTO 0);   
   -- data phase with cycle stealing
   SIGNAL temp_xhdl13              :  std_logic_vector(7 DOWNTO 0);   --  data phase without cycle stealing     
   SIGNAL temp_xhdl14              :  std_logic_vector(1 DOWNTO 0);   --  finish sending last data cycle on streaming interface if required.
   SIGNAL temp_xhdl15              :  std_logic;   --  next cycle is the last deferred data cycle
   SIGNAL temp_xhdl16              :  std_logic;   
   SIGNAL temp_xhdl17              :  std_logic;   --  if in deferred mode, write data on the next cycle to the streaming interface
   SIGNAL rx_ack_xhdl1             :  std_logic;   
   SIGNAL rx_abort_xhdl2           :  std_logic;   
   SIGNAL rx_retry_xhdl3           :  std_logic;   
   SIGNAL rx_ws_xhdl4              :  std_logic;   
   SIGNAL rx_mask_xhdl5            :  std_logic;   
   SIGNAL stream_wr_xhdl6          :  std_logic;   
   SIGNAL stream_wrdata_xhdl7      :  std_logic_vector(107 DOWNTO 0);   
BEGIN
   rx_ack <= rx_ack_xhdl1;
   rx_abort <= rx_abort_xhdl2;
   rx_retry <= rx_retry_xhdl3;
   rx_ws <= rx_ws_xhdl4;
   rx_mask <= rx_mask_xhdl5;
   stream_wr <= stream_wr_xhdl6;
   stream_wrdata <= stream_wrdata_xhdl7;
   -- core signals not supported 
   rx_abort_xhdl2 <= '0' ;
   rx_mask_xhdl5 <= '0' ;
   rx_retry_xhdl3 <= '0' ;
   ------------------------------------------------------------------------
   -- Generate streaming interface output signals
   ------------------------------------------------------------------------
   stream_wrdata_xhdl7(63 DOWNTO 0) <= muxed_stream_wrdata ;
   stream_wrdata_xhdl7(71 DOWNTO 64) <= muxed_bar_bits ;
   stream_wrdata_xhdl7(81 DOWNTO 74) <= muxed_rx_be ;
   stream_wrdata_xhdl7(73) <= start_of_pkt_flag ;
   stream_wrdata_xhdl7(72) <= end_of_pkt_flag ;
   -- write descriptor phase and data phase when streaming interface 
   -- can accept data (stream_ready), and if not filtering out a message.
   -- rx state machine advances on stream_ready
   rxdesc_type_field <= rx_desc(125 DOWNTO 123) ;
   temp_xhdl8 <= '1' WHEN (rxdesc_type_field = "110") ELSE '0';
   type_is_message <= temp_xhdl8 ;
   temp_xhdl9 <= type_is_message WHEN rx_req = '1' ELSE type_is_message_mem_r;
   type_is_message_mem <= temp_xhdl9 ;
   filter_out_msg_n <= type_is_message_mem AND DROP_MESSAGE ;
   stream_wr_xhdl6 <= (stream_ready AND (rx_req OR write_streaming_data)) AND NOT filter_out_msg_n ;
   start_of_pkt_flag <= rx_req AND enable_desc1 ;
   end_of_pkt_flag <= ((write_streaming_data AND NOT stream_deferred_data) AND NOT rx_dfr) OR last_deferred_cycle ;
   temp_xhdl10 <= rx_desc(63 DOWNTO 0) WHEN enable_desc2 = '1' ELSE rx_data;
   temp_xhdl11 <= rx_desc(127 DOWNTO 64) WHEN enable_desc1 = '1' ELSE temp_xhdl10;
   temp_xhdl12 <= rx_data_last WHEN stream_deferred_data = '1' ELSE temp_xhdl11;
   muxed_stream_wrdata <= temp_xhdl12 ;
   temp_xhdl13 <= rx_be_last WHEN stream_deferred_data = '1' ELSE rx_be;
   muxed_rx_be <= temp_xhdl13 ;
   -- assign muxed_bar_bits = (enable_desc1 | enable_desc2) ? rx_desc[135:128] : muxed_rx_be;  // bar bits are valid on desc2.  // UNMULTIPLEX THIS 
   muxed_bar_bits <= rx_desc(135 DOWNTO 128) ;
   --------------------------------------------------------------------------
   -- Generate Core handshaking/data-throttle signals
   -------------------------------------------------------------------------- 
   rx_ws_xhdl4 <= NOT ((enable_core_dataphase AND stream_ready) AND rx_dv) ;
   rx_ack_xhdl1 <= enable_desc2 AND stream_ready ;
   temp_xhdl14 <= DEFERRED_CYCLE WHEN defer_data_cycle = '1' ELSE STREAM_DESC1;
   temp_xhdl15 <= '1' WHEN defer_data_cycle = '1' ELSE '0';
   temp_xhdl16 <= '0' WHEN defer_data_cycle = '1' ELSE '1';
   temp_xhdl17 <= NOT filter_out_msg WHEN defer_data_cycle = '1' ELSE '0';
   --------------------------------------------------------------------------
   -- Generate control signals for
   --    - multiplexing desc/data from the core onto the streaming i/f
   --    - handshaking/throttling the core interface
   --
   -- Throttling of the core is driven by the streaming interface 'ready'
   -- signal.  Advance the core and the streaming interface on 'stream_ready'.
   --------------------------------------------------------------------------
   
   PROCESS (rstn, clk)
   BEGIN
      IF (rstn = '0') THEN
         bridge_sm <= STREAM_DESC1;    
         enable_desc1 <= '1';    
         enable_desc2 <= '0';    
         write_streaming_data <= '0';    
         stream_deferred_data <= '0';    
         has_payload <= '0';    
         last_deferred_cycle <= '0';    
         rx_data_last <= "0000000000000000000000000000000000000000000000000000000000000000";    
         rx_be_last <= "00000000";    
         enable_core_dataphase <= '0';    
         filter_out_msg <= '0';    
         type_is_message_mem_r <= '0';    
         defer_data_cycle <= '0';    
      ELSIF (clk'EVENT AND clk = '1') THEN
         type_is_message_mem_r <= type_is_message_mem;    
         IF (stream_ready = '1') THEN
            -- advance data transfer on stream_ready
            
            rx_data_last <= rx_data;    
            rx_be_last <= rx_be;    
            CASE bridge_sm IS
               WHEN STREAM_DESC1 =>
                        -- wait for rx_req from core
                        -- when received, put desc1 on streaming interface
                        
                        IF (rx_req = '1') THEN
                           enable_desc1 <= '0';    
                           enable_desc2 <= '1';    --  on next cycle, put desc2 on multiplexed streaming bus
                           has_payload <= rx_desc(126);    --  pkt has payload
                           bridge_sm <= STREAM_DESC2;    
                           last_deferred_cycle <= NOT rx_desc(126);    --  next cycle is last if there is no payload
                           enable_core_dataphase <= rx_desc(126);    --  allow core dataphase to advance
                           filter_out_msg <= filter_out_msg_n;    
                        END IF;
               WHEN STREAM_DESC2 =>
                        -- put desc2 on streaming interface
                        -- if first dataphase coincides with desc2, 
                        -- hold the core data and write to streaming i/f
                        -- on the next ready cycle.
                        
                        enable_desc2 <= '0';    
                        defer_data_cycle <= rx_dv;    --  if receiving data at the same time as desc phase 2, hold data to transmit on streaming on next clk
                        IF ((NOT rx_dfr AND rx_dv) = '1') THEN
                           -- single data phase pkt 
                           
                           last_deferred_cycle <= '1';    --  indicate that this is the last data cycle for the pkt
                           bridge_sm <= DEFERRED_CYCLE;    --  receiving last dataphase from core. finish sending last data cycle.
                           write_streaming_data <= NOT filter_out_msg;    --  write desc2 to        
                           stream_deferred_data <= '1';    --  hold rx_data and write to streaming i/f on next clk cycle.  currently writing desc2
                           enable_core_dataphase <= '0';    --  core dataphase is done.  do not read any more data from core while finishing transfer to streaming interface
                        ELSE
                           IF (has_payload = '1') THEN
                              -- multi-cycle data payload
                              
                              bridge_sm <= STREAM_DATA;    
                              write_streaming_data <= NOT filter_out_msg;    --  on next cycle, write dataphase to streaming interface
                              stream_deferred_data <= rx_dv;    --  hold rx_data and write to streaming i/f on next clk cycle.  currently writing desc2
                              enable_core_dataphase <= '1';    --  core dataphase is not done.  continue to accept data from core. 
                           ELSE
                              -- no payload in pkt
                              
                              bridge_sm <= STREAM_DESC1;    --  wait for new pkt
                              enable_desc1 <= '1';    
                              enable_core_dataphase <= '0';    
                              last_deferred_cycle <= '0';    
                           END IF;
                        END IF;
               WHEN STREAM_DATA =>
                        -- accept data from the core interface,
                        -- and transfer to the streaming interface 
                        -- until the end of the core dataphase is recieved. 
                        
                        IF ((NOT rx_dfr AND rx_dv) = '1') THEN
                           bridge_sm <= temp_xhdl14;    
                           last_deferred_cycle <= temp_xhdl15;    
                           enable_desc1 <= temp_xhdl16;    
                           enable_desc2 <= '0';    
                           write_streaming_data <= temp_xhdl17;    
                           enable_core_dataphase <= '0';    --  do not accept any more data from the core
                        END IF;
               WHEN DEFERRED_CYCLE =>
                        -- stream the last data cycle of deferred mode
                        
                        bridge_sm <= STREAM_DESC1;    
                        enable_desc1 <= '1';    
                        enable_desc2 <= '0';    
                        write_streaming_data <= '0';    
                        stream_deferred_data <= '0';    
                        last_deferred_cycle <= '0';    
                        enable_core_dataphase <= '0';    
               WHEN OTHERS =>
                        NULL;
               
            END CASE;
         END IF;
      END IF;
   END PROCESS;
END ARCHITECTURE translated;
