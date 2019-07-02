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
-- File          : altpcierd_icm_txbridge.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This module is a bridge between the streaming interface protocol and 
-- the PCIExpress core TX interface signalling.  
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
ENTITY altpcierd_icm_txbridge IS
   PORT (
      clk                     : IN std_logic;   
      rstn                    : IN std_logic;   
      pri_data_valid          : IN std_logic;   --  means pri_data_in is current
      pri_data_in             : IN std_logic_vector(107 DOWNTO 0);   --  data from streaming interface
      pri_data_ack            : OUT std_logic;   --  accepts current data 
      ena_np_bypass           : IN std_logic;   
      req_npbypass_pkt        : IN std_logic;   
      np_data_valid           : IN std_logic;   
      np_data_in              : IN std_logic_vector(107 DOWNTO 0);   
      np_data_ack             : OUT std_logic;   
      sending_np              : OUT std_logic;   
      sending_npd             : OUT std_logic;   
      tx_ack                  : IN std_logic;   --  from core.  grants tx_req
      tx_ws                   : IN std_logic;   --  from core.  throttles dataphase
      tx_req                  : OUT std_logic;   --  to core. tx request
      tx_dfr                  : OUT std_logic;   --  to core. means there are more data cycles
      tx_dv                   : OUT std_logic;   --  to core. means tx_dv is valid
      tx_data                 : OUT std_logic_vector(63 DOWNTO 0);   --  to core. tx data
      tx_desc                 : OUT std_logic_vector(127 DOWNTO 0);   --  to core. tx descriptor
      tx_be                   : OUT std_logic_vector(7 DOWNTO 0);   --  not used
      tx_err                  : OUT std_logic;   --  to core. indicates an error in tx_data
      tx_cpl_pending          : OUT std_logic;   --  to core. indicates that there is a completion still in progress
      tx_bridge_idle          : OUT std_logic;   --  indicates that this bridge is not processing a pkt 
	  np_fifo_almostfull      : IN std_logic;
      msi_busy                : IN std_logic);   
END ENTITY altpcierd_icm_txbridge;
ARCHITECTURE translated OF altpcierd_icm_txbridge IS
   SIGNAL tx_desc_hi_r             :  std_logic_vector(63 DOWNTO 0);   --  registered version of high descriptor bytes
   SIGNAL tx_desc_lo_r             :  std_logic_vector(63 DOWNTO 0);   --  registered version of low descriptor bytes
   SIGNAL assert_req               :  std_logic;   --  asserts tx_req
   SIGNAL assert_dfr               :  std_logic;   --  asserts tx_dfr
   SIGNAL assert_dv                :  std_logic;   --  asserts tx_dv
   SIGNAL tx_dfr_last              :  std_logic;   --  memorize last cycle of tx_dfr 
   SIGNAL got_ack                  :  std_logic;   --  indicates an ack was received for the last request
   SIGNAL bridge_sm                :  std_logic_vector(2 DOWNTO 0);   --  bridge state machine
   SIGNAL np_bypass_mode           :  std_logic;   
   SIGNAL sel_npbypass_fifo_c      :  std_logic;   
   SIGNAL sel_npbypass_fifo_r      :  std_logic;   
   SIGNAL muxed_data_in            :  std_logic_vector(107 DOWNTO 0);   
   SIGNAL muxed_data_valid         :  std_logic;   
   SIGNAL muxed_sop_data_in        :  std_logic_vector(107 DOWNTO 0);   
   SIGNAL muxed_sop_data_valid     :  std_logic;   
   SIGNAL muxed_sop_data_in_del    :  std_logic_vector(107 DOWNTO 0);   
   ----------------------------------------------
   -- Generate Streaming interface ready signal
   -- for throttling streaming data
   ----------------------------------------------
   -- in data phase.  fetch as long as core does not throttle 
   SIGNAL temp_xhdl14              :  std_logic;   
   -- in data phase.  fetch as long as core does not throttle 
   SIGNAL temp_xhdl15              :  std_logic;   
   -----------------------------------------------------------
   -- Input Data Mux:  Primary Data Stream vs NPBypass Fifo 
   -----------------------------------------------------------     
   -- select data from either primary data stream or from npbypass
   -- fifo.  npbypass gets priority.  
   SIGNAL temp_xhdl16              :  std_logic;   
   -- for first descriptor phase, use sel_npbypass_fifo_c
   SIGNAL temp_xhdl17              :  std_logic_vector(107 DOWNTO 0);   
   SIGNAL temp_xhdl18              :  std_logic;   
   -- for subsequent descriptor/data phases, use delayed version 
   -- of sel_npbypass_fifo_c for performance
   SIGNAL temp_xhdl19              :  std_logic_vector(107 DOWNTO 0);   
   SIGNAL temp_xhdl20              :  std_logic;   
   SIGNAL temp_xhdl21              :  std_logic;   --  assert dfr until last cycle of data
   SIGNAL temp_xhdl22              :  std_logic;   
   SIGNAL temp_xhdl23              :  std_logic_vector(63 DOWNTO 0);   --  hold descriptor low bytes on desc bus
   SIGNAL temp_xhdl24              :  std_logic;   
   SIGNAL temp_xhdl25              :  std_logic;   --  indicate if last request was acked 
   SIGNAL temp_xhdl26              :  std_logic;   
   SIGNAL temp_xhdl27              :  std_logic;   --  hold tx_dfr until last packet cycle
   SIGNAL temp_xhdl28              :  std_logic_vector(2 DOWNTO 0);   --  use payload bit instead of EOP.  possible edge condition if fifo throttles in this state.  if no data phase, then wait for ack.  else start dataphase while waiting for ack. 
   SIGNAL temp_xhdl29              :  std_logic;   --  keep asserting request if not yet acked 
   SIGNAL temp_xhdl30              :  std_logic_vector(2 DOWNTO 0);   --  if end of data phase, and no ack yet, then wait for ack.  else, ok to start new pkt.
   SIGNAL temp_xhdl31              :  std_logic;   
   SIGNAL temp_xhdl32              :  std_logic;   
   SIGNAL temp_xhdl33              :  std_logic;   --  keep asserting request if not yet acked 
   SIGNAL temp_xhdl34              :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL temp_xhdl35              :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL np_data_ack_xhdl1        :  std_logic;   
   SIGNAL pri_data_ack_xhdl2       :  std_logic;   
   SIGNAL tx_req_xhdl3             :  std_logic;   
   SIGNAL tx_dfr_xhdl4             :  std_logic;   
   SIGNAL tx_dv_xhdl5              :  std_logic;   
   SIGNAL tx_data_xhdl6            :  std_logic_vector(63 DOWNTO 0);   
   SIGNAL tx_desc_xhdl7            :  std_logic_vector(127 DOWNTO 0);   
   SIGNAL tx_be_xhdl8              :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL tx_err_xhdl9             :  std_logic;   
   SIGNAL tx_cpl_pending_xhdl10    :  std_logic;   
   SIGNAL tx_bridge_idle_xhdl11    :  std_logic;   
   SIGNAL sending_np_xhdl12        :  std_logic;   
   SIGNAL sending_npd_xhdl13       :  std_logic;   

      constant DESC1                          :  std_logic_vector(2 DOWNTO 0) := "000";    --  hold desc1
      constant DESC2                          :  std_logic_vector(2 DOWNTO 0) := "001";    --  full tx_desc is valid, assert tx_req, tx_dfr
      constant DATA_PHASE                     :  std_logic_vector(2 DOWNTO 0) := "010";    --  first dataphase is valid, assert tx_dv.  advance data phase until end of pkt
      constant WAIT_FOR_ACK                   :  std_logic_vector(2 DOWNTO 0) := "011";    --  no dataphase.  waiting for ack.
      constant DROP_PKT                       :  std_logic_vector(2 DOWNTO 0) := "100";    --  follow pkt, but do not pass to core 
      constant WAIT_NP_SEL_UPDATE             :  std_logic_vector(2 DOWNTO 0) := "101";    --  when pkt is from npbypass fifo, wait for tx credits to update the np select signal


BEGIN
   np_data_ack <= np_data_ack_xhdl1;
   pri_data_ack <= pri_data_ack_xhdl2;
   tx_req <= tx_req_xhdl3;
   tx_dfr <= tx_dfr_xhdl4;
   tx_dv <= tx_dv_xhdl5;
   tx_data <= tx_data_xhdl6;
   tx_desc <= tx_desc_xhdl7;
   tx_be <= tx_be_xhdl8;
   tx_err <= tx_err_xhdl9;
   tx_cpl_pending <= tx_cpl_pending_xhdl10;
   tx_bridge_idle <= tx_bridge_idle_xhdl11;
   sending_np <= sending_np_xhdl12;
   sending_npd <= sending_npd_xhdl13;
   temp_xhdl14 <= '1' WHEN ((sel_npbypass_fifo_c = '0') AND NOT ( ((bridge_sm = DESC1) AND (pri_data_in(85) = '1') AND (ena_np_bypass = '1') AND (np_fifo_almostfull = '1')) OR ((bridge_sm = DATA_PHASE) AND (tx_ws = '1')) OR (bridge_sm = WAIT_FOR_ACK))) ELSE '0';
   pri_data_ack_xhdl2 <= temp_xhdl14 ;
   temp_xhdl15 <= '1' WHEN ((sel_npbypass_fifo_c = '1') AND NOT ( ((bridge_sm = DESC1) AND (msi_busy = '1')) OR ((bridge_sm = DATA_PHASE) AND (tx_ws = '1')) OR (bridge_sm = WAIT_FOR_ACK) OR (bridge_sm = WAIT_NP_SEL_UPDATE))) ELSE '0';
   np_data_ack_xhdl1 <= temp_xhdl15 ;
   temp_xhdl16 <= req_npbypass_pkt WHEN (bridge_sm = DESC1) ELSE sel_npbypass_fifo_r;
   sel_npbypass_fifo_c <= temp_xhdl16 ;
   temp_xhdl17 <= np_data_in WHEN sel_npbypass_fifo_c = '1' ELSE pri_data_in;
   muxed_sop_data_in <= temp_xhdl17 ;
   temp_xhdl18 <= np_data_valid WHEN sel_npbypass_fifo_c = '1' ELSE pri_data_valid;
   muxed_sop_data_valid <= temp_xhdl18 ;
   temp_xhdl19 <= np_data_in WHEN sel_npbypass_fifo_r = '1' ELSE pri_data_in;
   muxed_data_in <= temp_xhdl19 ;
   temp_xhdl20 <= np_data_valid WHEN sel_npbypass_fifo_r = '1' ELSE pri_data_valid;
   muxed_data_valid <= temp_xhdl20 ;
   --------------------------------------------------------- 
   -- Generate Core Interface TX signals
   --    - extract multiplexed streaming interface  
   --      data onto non-multiplexed Core interface.
   --    - generate TX interface control signals
   ---------------------------------------------------------  
   tx_req_xhdl3 <= assert_req ;
   temp_xhdl21 <= '1' WHEN assert_dfr = '1' ELSE tx_dfr_last;
   temp_xhdl22 <= '0' WHEN muxed_data_in(72) = '1' ELSE temp_xhdl21;
   tx_dfr_xhdl4 <= temp_xhdl22 ;
   tx_dv_xhdl5 <= assert_dv ;
   tx_data_xhdl6 <= muxed_data_in(63 DOWNTO 0) ;
   tx_be_xhdl8 <= "00000000" ;
   tx_err_xhdl9 <= muxed_data_in(74) AND muxed_data_valid ;
   tx_cpl_pending_xhdl10 <= '0' ;
   tx_desc_xhdl7(127 DOWNTO 64) <= tx_desc_hi_r ;
   temp_xhdl23 <= muxed_data_in(63 DOWNTO 0) WHEN (bridge_sm = DESC2) ELSE tx_desc_lo_r;
   tx_desc_xhdl7(63 DOWNTO 0) <= temp_xhdl23 ;
   temp_xhdl24 <= tx_dfr_xhdl4 WHEN pri_data_valid = '1' ELSE tx_dfr_last;
   temp_xhdl25 <= '0' WHEN tx_req_xhdl3 = '1' ELSE got_ack;
   temp_xhdl26 <= '1' WHEN tx_ack = '1' ELSE temp_xhdl25;
   temp_xhdl27 <= '0' WHEN muxed_data_in(72) = '1' ELSE assert_dfr;
   temp_xhdl28 <= WAIT_FOR_ACK WHEN NOT assert_dfr = '1' ELSE DATA_PHASE;
   temp_xhdl29 <= '0' WHEN tx_ack = '1' ELSE assert_req;
   temp_xhdl30 <= DESC1 WHEN (tx_ack OR got_ack) = '1' ELSE WAIT_FOR_ACK;
   temp_xhdl31 <= '0' WHEN muxed_data_in(72) = '1' ELSE assert_dfr;
   temp_xhdl32 <= '0' WHEN muxed_data_in(72) = '1' ELSE assert_dv;
   temp_xhdl33 <= '0' WHEN tx_ack = '1' ELSE assert_req;
   temp_xhdl34 <= WAIT_NP_SEL_UPDATE WHEN np_bypass_mode = '1' ELSE DESC1;
   temp_xhdl35 <= DESC1 WHEN muxed_data_in(72) = '1' ELSE bridge_sm;
   ------------------------------------------------
   -- State machine manages the Core TX protocol
   -- and generates signals for throttling data 
   -- on the streaming interface.
   ------------------------------------------------
   
   PROCESS (clk, rstn)
   BEGIN
      IF (NOT rstn = '1') THEN
         bridge_sm <= DESC1;    
         tx_dfr_last <= '0';    
         assert_req <= '0';    
         assert_dfr <= '0';    
         assert_dv <= '0';    
         assert_dv <= '0';    
         tx_desc_hi_r <= "0000000000000000000000000000000000000000000000000000000000000000";    
         tx_desc_lo_r <= "0000000000000000000000000000000000000000000000000000000000000000";    
         got_ack <= '0';    
         tx_bridge_idle_xhdl11 <= '1';    
         np_bypass_mode <= '0';    
         sel_npbypass_fifo_r <= '0';    
         np_bypass_mode <= '0';    
         sending_np_xhdl12 <= '0';    
         sending_npd_xhdl13 <= '0';    
         muxed_sop_data_in_del <= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";    
      ELSIF (clk'EVENT AND clk = '1') THEN
         sel_npbypass_fifo_r <= sel_npbypass_fifo_c;    
         tx_dfr_last <= temp_xhdl24;    
         got_ack <= temp_xhdl26;    
         muxed_sop_data_in_del <= muxed_sop_data_in;    
         CASE bridge_sm IS
            WHEN DESC1 =>
                     -- wait for a start-of-pkt flag from the
                     -- streaming interface
                     
                     tx_bridge_idle_xhdl11 <= '1';    
                     tx_desc_hi_r <= muxed_sop_data_in(63 DOWNTO 0);    --  save the 1st phase of the descriptor (high bytes)
                     np_bypass_mode <= '0';    --  default
                     IF ((muxed_sop_data_valid = '1') AND (msi_busy = '0')) THEN
                        IF (((pri_data_in(87) AND NOT req_npbypass_pkt) AND ena_np_bypass) = '1') THEN
						    IF (np_fifo_almostfull = '1') THEN
                               bridge_sm <= DESC1;    
                               tx_bridge_idle_xhdl11 <= '1';  							    
						    ELSE
                               bridge_sm <= DROP_PKT;    
                               tx_bridge_idle_xhdl11 <= '0';  
							END IF;
                        ELSE
                           IF (muxed_sop_data_in(73) = '1') THEN
                              assert_req <= '1';    --  assert tx_req when 2nd phase of descritor is fetched.
                              assert_dfr <= muxed_sop_data_in(62);    --  assert tx_dfr if the descriptor payload bit is set
                              bridge_sm <= DESC2;    
                              tx_bridge_idle_xhdl11 <= '0';    
                              np_bypass_mode <= sel_npbypass_fifo_c;    
                           END IF;
                        END IF;
                     END IF;
            WHEN DESC2 =>
                     -- receiving descriptor phase2.   
                     -- tx_req, tx_dfr are asserted.
                     -- fetch first data phase and assert tx_dv if there is a dataphase. 
                     
                     assert_req <= '1';    --  assert request for 2 cycles (desc phase 2 and first data cycle)                                       
                     assert_dfr <= temp_xhdl27;    
                     bridge_sm <= temp_xhdl28;    
                     sending_np_xhdl12 <= muxed_sop_data_in_del(87);    --  assert on 2nd cycle tx_req at latest
                     sending_npd_xhdl13 <= muxed_sop_data_in_del(86);    
                     tx_bridge_idle_xhdl11 <= '0';    
                     assert_dv <= assert_dfr;    --  fetch first data, and assert tx_dv on next cycle if there is a dataphase
                     tx_desc_lo_r <= muxed_data_in(63 DOWNTO 0);    --  hold desc phase 2 on non-multiplexed descriptor bus 
            WHEN DATA_PHASE =>
                     assert_req <= temp_xhdl29;    
                     IF (NOT tx_ws = '1') THEN
                        -- advance data phase on tx_ws
                        
                        IF (muxed_data_in(72) = '1') THEN
                           bridge_sm <= temp_xhdl30;    
                        ELSE
                           bridge_sm <= DATA_PHASE;    --  stay here until end of dataphase
                        END IF;
                        tx_bridge_idle_xhdl11 <= muxed_data_in(72) AND (tx_ack OR got_ack);    
                        assert_dfr <= temp_xhdl31;    
                        assert_dv <= temp_xhdl32;    
                     END IF;
            WHEN WAIT_FOR_ACK =>
                     assert_req <= temp_xhdl33;    
                     IF (tx_ack = '1') THEN
                        bridge_sm <= temp_xhdl34;    
                     END IF;
                     tx_bridge_idle_xhdl11 <= tx_ack AND NOT np_bypass_mode;    
            WHEN DROP_PKT =>
                     bridge_sm <= temp_xhdl35;    
                     tx_bridge_idle_xhdl11 <= muxed_data_in(72);    
            WHEN WAIT_NP_SEL_UPDATE =>
                     -- tx_credits are valid in this cycle 
                     -- let sel_npbypass_fifo signal update before
                     -- evaluating next pkt
                     
                     bridge_sm <= DESC1;    
                     tx_bridge_idle_xhdl11 <= '1';    
            WHEN OTHERS =>
                     NULL;
            
         END CASE;
      END IF;
   END PROCESS;
END ARCHITECTURE translated;
