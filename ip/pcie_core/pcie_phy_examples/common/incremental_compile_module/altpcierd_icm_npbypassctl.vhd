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
-- File          : core_wrapper_tx.v
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
ENTITY altpcierd_icm_npbypassctl IS
   GENERIC (
      TXCRED_WIDTH                   :  integer := 22);    
   PORT (
      clk                     : IN std_logic;   
      rstn                    : IN std_logic;   
      tx_cred                 : IN std_logic_vector(65 DOWNTO 0);   --  from core.  available credits.  this is a concatenation of info for 6 credit types   
      -- bit 10 = means no NP header credits avail
-- bit 11 = means no NP data credits avail
      data_in                 : IN std_logic_vector(107 DOWNTO 0);   --  indicates data_in is valid
      data_valid              : IN std_logic;   --  indicates data_in is valid
      data_ack                : IN std_logic;   
      tx_bridge_idle          : IN std_logic;   --  means tx avalon-to-legacy bridge is not transferring a pkt. okay to switch data source.
      tx_npcredh              : IN std_logic_vector(7 DOWNTO 0);   
      tx_npcredd              : IN std_logic_vector(11 DOWNTO 0);   
      tx_npcredh_infinite     : IN std_logic;   
      tx_npcredd_infinite     : IN std_logic;   
      np_data_in              : IN std_logic_vector(107 DOWNTO 0);   --  data output from npbypass fifo 
      np_fifo_wrempty         : IN std_logic;   --  npbypass fifo is empty
      np_fifo_rdempty         : IN std_logic;   
      np_data_ack             : IN std_logic;   
      ena_np_bypass           : OUT std_logic;   --  Control to route NP requests to npbypass fifo 
      tx_mask                 : OUT std_logic;   --  tells app to mask out nonposted requests
      got_cred                : OUT std_logic;   
      sending_np              : IN std_logic;   
      sending_npd             : IN std_logic;   
      tx_ack                  : IN std_logic;   
      req_npbypass_pkt        : OUT std_logic);   
END ENTITY altpcierd_icm_npbypassctl;
ARCHITECTURE translated OF altpcierd_icm_npbypassctl IS


    FUNCTION or_br (                                        
         val : std_logic_vector) RETURN std_logic IS        
                                                            
         VARIABLE rtn : std_logic := '0';                   
      BEGIN                                                 
         FOR index IN val'RANGE LOOP                        
            rtn := rtn OR val(index);                       
         END LOOP;                                          
         RETURN(rtn);                                       
      END or_br;                                            
                                                            
   SIGNAL ena_np_bypass_r          :  std_logic;   
   SIGNAL sim_npreq                :  std_logic;   --  for simulation only
   SIGNAL got_nph_cred             :  std_logic;   
   SIGNAL got_npd_cred             :  std_logic;   
   SIGNAL sim_count                :  std_logic_vector(10 DOWNTO 0);   
   SIGNAL sim_sop_del              :  std_logic;   
   SIGNAL got_nph_cred_c           :  std_logic;   
   SIGNAL got_npd_cred_c           :  std_logic;   
   SIGNAL flush_np_bypass          :  std_logic;   
   SIGNAL np_tx_ack_del            :  std_logic;
   
   --------------------------------------------------------
   -- Credit Check
   -- Bypass NP requests if core has no header credits,
   -- FOR NOW .. MAINTAIN STRICT ORDERING ON NP's
   -- NP Read requests require 1 header credit.
   -- NP Write requests require 1 data credit.
   ---------------------------------------------------------
   -- assert bypass whenever there are no header credits, or whenever
   -- a write request is received and there are no data credits.
   -- release after there are enough credits to accept the next NP
   -- packet, and all deferred NP packets have been flushed.
   -- should be able to release ena_np_bypass  before fifo is flushed - but leave like this for now.
   SIGNAL temp_xhdl5               :  std_logic;   --  need to account for latency in np_fifo_empty
   SIGNAL temp_xhdl6               :  std_logic;   
   --///////////////////////////////////////////////////////////////////
   -- For x4/x1 core (TXCRED_WIDTH == 22), use only the LSB
   -- For x8 core    (TXCRED_WIDTH == 66), use registered equation 
   --//////////////////////////////////////////////////////////////////
   SIGNAL temp_xhdl7               :  std_logic;   
   SIGNAL temp_xhdl8               :  std_logic;   
   --//////////////////// FOR SIMULATION ONLY ////////////////////////////////
   -- COUNT # NP REQUESTS
   SIGNAL temp_xhdl9               :  std_logic;   
   --/////////////////////////////////////////////////////////////////////////
   -- assert tx_mask as soon as the first nonposted
   -- request requires bypassing.  
   -- deassert when bypass fifo is empty (for now)
   SIGNAL temp_xhdl10              :  std_logic;   
   SIGNAL temp_xhdl11              :  std_logic;   
   SIGNAL req_npbypass_pkt_xhdl1   :  std_logic;   
   SIGNAL tx_mask_xhdl2            :  std_logic;   
   SIGNAL ena_np_bypass_xhdl3      :  std_logic;   
   SIGNAL got_cred_xhdl4           :  std_logic;   
BEGIN
   req_npbypass_pkt <= req_npbypass_pkt_xhdl1;
   tx_mask <= tx_mask_xhdl2;
   ena_np_bypass <= ena_np_bypass_xhdl3;
   got_cred <= got_cred_xhdl4;
   sim_npreq <= data_in(87) ;
   temp_xhdl5 <= '0' WHEN np_fifo_wrempty = '1' ELSE ena_np_bypass_r;
   temp_xhdl6 <= '1' WHEN (data_in(85) AND (NOT got_nph_cred_c OR (NOT got_npd_cred_c AND data_in(86)))) = '1' ELSE temp_xhdl5;
   ena_np_bypass_xhdl3 <= temp_xhdl6 ;
   req_npbypass_pkt_xhdl1 <= flush_np_bypass ;
   
   temp_xhdl7 <= (tx_npcredh(0) AND NOT(np_tx_ack_del))   WHEN (TXCRED_WIDTH = 22) ELSE got_nph_cred;
   got_nph_cred_c <= temp_xhdl7 ;
   
   temp_xhdl8 <= (tx_npcredd(0) AND NOT(np_tx_ack_del)) WHEN (TXCRED_WIDTH = 22) ELSE got_npd_cred;
   got_npd_cred_c <= temp_xhdl8 ;
   got_cred_xhdl4 <= '0' ;
   temp_xhdl9 <= data_in(73) WHEN data_valid = '1' ELSE sim_sop_del;
   temp_xhdl10 <= '0' WHEN np_fifo_wrempty = '1' ELSE tx_mask_xhdl2;
   temp_xhdl11 <= '1' WHEN (NOT got_nph_cred_c OR (NOT got_npd_cred_c AND data_in(86))) = '1' ELSE temp_xhdl10;

   PROCESS (clk, rstn)
   BEGIN
      IF (NOT rstn = '1') THEN
         np_tx_ack_del <= '0';
      ELSIF (clk'EVENT AND clk = '1') THEN
       np_tx_ack_del   <= tx_ack AND sending_np;       
      END IF;
   END PROCESS;   

   PROCESS (clk, rstn)
   BEGIN
      IF (NOT rstn = '1') THEN
         ena_np_bypass_r <= '0';    
         tx_mask_xhdl2 <= '0';    
         sim_sop_del <= '0';    
         sim_count <= "00000000000";    
         got_nph_cred <= '0';    
         got_npd_cred <= '0';    
         flush_np_bypass <= '0';    
      ELSIF (clk'EVENT AND clk = '1') THEN
         ena_np_bypass_r <= ena_np_bypass_xhdl3;    
         IF (tx_npcredh_infinite = '1') THEN
            got_nph_cred <= '1';    
         ELSE
            IF ((tx_ack AND sending_np) = '1') THEN
               got_nph_cred <= or_br(tx_npcredh(7 DOWNTO 1));    --  if credits=1 on this cycle, assume it is zero on next.
            ELSE
               got_nph_cred <= or_br(tx_npcredh);    --  okay to evaluate on any non-tx_ack cycle
            END IF;
         END IF;
         IF (tx_npcredd_infinite = '1') THEN
            got_npd_cred <= '1';    
         ELSE
            IF ((tx_ack AND sending_npd) = '1') THEN
               got_npd_cred <= or_br(tx_npcredd(11 DOWNTO 1));    --  if credits=1 on this cycle, assume it is zero on next.
            ELSE
               got_npd_cred <= or_br(tx_npcredd);    --  okay to evaluate on any non-tx_ack cycle  
            END IF;
         END IF;
         IF (np_fifo_rdempty = '1') THEN
            flush_np_bypass <= '0';    
         ELSIF (np_data_in(85) = '1') THEN
               flush_np_bypass <= got_nph_cred_c AND (got_npd_cred_c OR NOT np_data_in(86));    
		 ELSE
		       flush_np_bypass <= '0';
         END IF;
         sim_sop_del <= temp_xhdl9;    
         IF (((data_in(87) AND data_in(73)) AND NOT sim_sop_del) = '1') THEN
            sim_count <= sim_count + "00000000001";    
         END IF;
         tx_mask_xhdl2 <= temp_xhdl11;    
      END IF;
   END PROCESS;
END ARCHITECTURE translated;
