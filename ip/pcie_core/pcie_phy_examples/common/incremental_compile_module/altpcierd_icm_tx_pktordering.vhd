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
-- File          : altpcierd_icm_tx_pktordering.v
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
ENTITY altpcierd_icm_tx_pktordering IS
   GENERIC (
      TXCRED_WIDTH                   :  integer := 22;
	  NPBYPASSFIFO_NUMWORDS          :  integer := 32;
	  NPBYPASSFIFO_WIDTHU            :  integer := 5;
	  NPBYPASSFIFO_ALMOSTFULL        :  integer := 28
	  );    
   PORT (
      clk                     : IN std_logic;   
      rstn                    : IN std_logic;   
      data_ack                : OUT std_logic;   --  accepts data_in 
      data_valid              : IN std_logic;   --  indicates data_in is valid
      data_in                 : IN std_logic_vector(107 DOWNTO 0);   --  data from TX streaming fifo  
      tx_bridge_idle          : IN std_logic;   --  means no packet is being transferred to the core
      tx_cred                 : IN std_logic_vector(65 DOWNTO 0);   --  available credits from core.  this is a concatenation of info for 6 credit types
      tx_npcredh              : IN std_logic_vector(7 DOWNTO 0);   
      tx_npcredd              : IN std_logic_vector(11 DOWNTO 0);   
      tx_npcredh_infinite     : IN std_logic;   
      tx_npcredd_infinite     : IN std_logic;   
      pri_data_ack            : IN std_logic;   
      pri_data_valid          : OUT std_logic;   --  indicates data_in is valid
      pri_data                : OUT std_logic_vector(107 DOWNTO 0);   --  data from TX streaming interface    
      tx_mask                 : OUT std_logic;   --  masks nonposted requests from app 
      tx_ack                  : IN std_logic;   
      ena_np_bypass           : OUT std_logic;   
      sending_np              : IN std_logic;   
      sending_npd             : IN std_logic;   
      req_npbypass_pkt        : OUT std_logic;   
      np_data_valid           : OUT std_logic;   --  indicates data_in is valid
      np_data                 : OUT std_logic_vector(107 DOWNTO 0);   --  data from TX streaming interface  
      np_data_ack             : IN std_logic;   
	  msi_busy                : IN std_logic;   
	  tx_fifo_rd              : IN std_logic;  
	  np_fifo_almostfull      : OUT std_logic); 
END ENTITY altpcierd_icm_tx_pktordering;
ARCHITECTURE translated OF altpcierd_icm_tx_pktordering IS
   COMPONENT altpcierd_icm_fifo_lkahd
      GENERIC (
           RAMTYPE               :  string := "RAM_BLOCK_TYPE=M512";    
           USEEAB                :  string := "ON";
		   ALMOST_FULL_VAL       :  integer := NPBYPASSFIFO_ALMOSTFULL;
		   NUMWORDS              :  integer := NPBYPASSFIFO_NUMWORDS;
		   WIDTHU                :  integer := NPBYPASSFIFO_WIDTHU
		   );
      PORT (
         aclr                    : IN  std_logic;
         clock                   : IN  std_logic;
         data                    : IN  std_logic_vector(107 DOWNTO 0);
         rdreq                   : IN  std_logic;
         wrreq                   : IN  std_logic;
         almost_empty            : OUT std_logic;
         almost_full             : OUT std_logic;
         empty                   : OUT std_logic;
         full                    : OUT std_logic;
         q                       : OUT std_logic_vector(107 DOWNTO 0);
         usedw                   : OUT std_logic_vector(NPBYPASSFIFO_WIDTHU-1 DOWNTO 0));
   END COMPONENT;
   COMPONENT altpcierd_icm_npbypassctl
      GENERIC (
          TXCRED_WIDTH                   :  integer := 22);    
      PORT (
         clk                     : IN  std_logic;
         rstn                    : IN  std_logic;
         tx_cred                 : IN  std_logic_vector(65 DOWNTO 0);
         data_in                 : IN  std_logic_vector(107 DOWNTO 0);
         data_valid              : IN  std_logic;
         data_ack                : IN  std_logic;
         tx_bridge_idle          : IN  std_logic;
         tx_npcredh              : IN  std_logic_vector(7 DOWNTO 0);
         tx_npcredd              : IN  std_logic_vector(11 DOWNTO 0);
         tx_npcredh_infinite     : IN  std_logic;
         tx_npcredd_infinite     : IN  std_logic;
         np_data_in              : IN  std_logic_vector(107 DOWNTO 0);
         np_fifo_wrempty         : IN  std_logic;
         np_fifo_rdempty         : IN  std_logic;
         np_data_ack             : IN  std_logic;
         ena_np_bypass           : OUT std_logic;
         tx_mask                 : OUT std_logic;
         got_cred                : OUT std_logic;
         sending_np              : IN  std_logic;
         sending_npd             : IN  std_logic;
         tx_ack                  : IN  std_logic;
         req_npbypass_pkt        : OUT std_logic);
   END COMPONENT;
  -- SIGNAL np_fifo_almostfull_del   :  std_logic;   
   -- fifo
   SIGNAL np_fifo_rd               :  std_logic;   
   SIGNAL np_fifo_wr               :  std_logic;    
   SIGNAL np_fifo_empty            :  std_logic;   
   SIGNAL np_fifo_wrdata           :  std_logic_vector(107 DOWNTO 0);   
   SIGNAL npflags_fifo_wrdata      :  std_logic_vector(107 DOWNTO 0);   
   SIGNAL np_fifo_rddata           :  std_logic_vector(107 DOWNTO 0);   
   SIGNAL npflags_fifo_rddata      :  std_logic_vector(107 DOWNTO 0);   
   SIGNAL np_fifo_wrempty_r        :  std_logic;   
   SIGNAL np_fifo_wrempty          :  std_logic;   
   SIGNAL used_words               :  std_logic_vector(NPBYPASSFIFO_WIDTHU-1 DOWNTO 0);   
   SIGNAL ordered_pkt_start        :  std_logic;   
   SIGNAL np_fifo_wr_r             :  std_logic;   
   SIGNAL data_in_del              :  std_logic_vector(107 DOWNTO 0);   
   SIGNAL np_fifo_wr_del           :  std_logic;   
   SIGNAL dataindel_84_to_0        :  std_logic_vector(84 DOWNTO 0);   
   SIGNAL dataindel_87_to_85       :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL port_xhdl9               :  std_logic;   
   SIGNAL port_xhdl10              :  std_logic;   
   ------------------------------------------------------- 
   -- Streaming Interface Control
   -------------------------------------------------------
   -- throttle stream interface if the data from the stream interface is an NP request which needs to be bypassed, but 
   -- the npbypass fifo is full.  (Note:  if fifo is almost full, then NPs are being bypassed).
   -- otherwise, throttle the stream intf per the tx bridge.
   SIGNAL temp_xhdl11              :  std_logic;   
   SIGNAL data_ack_xhdl1           :  std_logic;   
   SIGNAL pri_data_valid_xhdl2     :  std_logic;   
   SIGNAL pri_data_xhdl3           :  std_logic_vector(107 DOWNTO 0);   
   SIGNAL tx_mask_xhdl4            :  std_logic;   
   SIGNAL req_npbypass_pkt_xhdl5   :  std_logic;   
   SIGNAL np_data_valid_xhdl6      :  std_logic;   
   SIGNAL np_data_xhdl7            :  std_logic_vector(107 DOWNTO 0);   
   SIGNAL ena_np_bypass_xhdl8      :  std_logic;   

   SIGNAL np_fifo_full             :  std_logic;
BEGIN
   data_ack <= data_ack_xhdl1;
   pri_data_valid <= pri_data_valid_xhdl2;
   pri_data <= pri_data_xhdl3;
   tx_mask <= tx_mask_xhdl4;
   req_npbypass_pkt <= req_npbypass_pkt_xhdl5;
   np_data_valid <= np_data_valid_xhdl6;
   np_data <= np_data_xhdl7;
   ena_np_bypass <= ena_np_bypass_xhdl8;
   PROCESS (clk, rstn)
   BEGIN
      IF (NOT rstn = '1') THEN
         data_in_del <= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";    
         np_fifo_wr_del <= '0';    
      ELSIF (clk'EVENT AND clk = '1') THEN
         data_in_del <= data_in;    
         np_fifo_wr_del <= np_fifo_wr;    
      END IF;
   END PROCESS;
   --------------------------------------------------------------
   -- 
   ---------------------------------------------------------------
   pri_data_valid_xhdl2 <= data_valid ;
   pri_data_xhdl3 <= data_in ;
   -- -----------------------------------------------------------
   -- Fifos for Bypassed NonPosted requests.
   -- Streaming NP data is deferred to this Fifo until the core 
   -- has enough credits to accept them
   --------------------------------------------------------------
   --///////////////////////////////////////////////////////
   -- NP BYPASS DATA FIFO
   --//////////////////////////////////////////////////////
   dataindel_84_to_0 <= data_in_del(84 DOWNTO 0) ;
   np_fifo_wrdata <= "00000000000000000000000" & dataindel_84_to_0 ;
   np_data_xhdl7(84 DOWNTO 0) <= np_fifo_rddata(84 DOWNTO 0) ;
   port_xhdl9 <= NOT rstn;
   npbypass_fifo_131x4 : altpcierd_icm_fifo_lkahd 
      GENERIC MAP (
         RAMTYPE     => "RAM_BLOCK_TYPE=AUTO",
		 USEEAB      => "ON",
		 ALMOST_FULL_VAL => NPBYPASSFIFO_ALMOSTFULL,
		 NUMWORDS    => NPBYPASSFIFO_NUMWORDS,
		 WIDTHU      => NPBYPASSFIFO_WIDTHU
		 )
      PORT MAP (
         clock => clk,
         aclr => port_xhdl9,
         data => np_fifo_wrdata,
         wrreq => np_fifo_wr_del,
         rdreq => np_fifo_rd,
         q => np_fifo_rddata,
         full => open,
         almost_full => open,
         almost_empty => open,
         empty => open,
         usedw => open);   
   
   --///////////////////////////////////////////////////////
   -- NP BYPASS FLAGS FIFO
   --//////////////////////////////////////////////////////

   dataindel_87_to_85 <= data_in_del(87 DOWNTO 85) ;
   npflags_fifo_wrdata <= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" & dataindel_87_to_85 ;
   np_data_xhdl7(87 DOWNTO 85) <= npflags_fifo_rddata(2 DOWNTO 0) ;
   port_xhdl10 <= NOT rstn;
   npbypassflags_fifo_131x4 : altpcierd_icm_fifo_lkahd 
      GENERIC MAP (
         RAMTYPE     => "RAM_BLOCK_TYPE=AUTO",
		 USEEAB      => "ON",
		 ALMOST_FULL_VAL => NPBYPASSFIFO_ALMOSTFULL,
		 NUMWORDS    => NPBYPASSFIFO_NUMWORDS,
		 WIDTHU      => NPBYPASSFIFO_WIDTHU 
		 )
      PORT MAP (
         clock => clk,
         aclr => port_xhdl10,
         data => npflags_fifo_wrdata,
         wrreq => np_fifo_wr_del,
         rdreq => np_fifo_rd,
         q => npflags_fifo_rddata,
         full => np_fifo_full,
         almost_full => np_fifo_almostfull,
         almost_empty => open,
         empty => np_fifo_empty,
         usedw => used_words);   
   
   np_data_valid_xhdl6 <= '1' ;
   PROCESS (clk, rstn)
   BEGIN
      IF (NOT rstn = '1') THEN
     --    np_fifo_almostfull_del <= '0';    
         np_fifo_wrempty_r <= '1';    
         np_fifo_wr_r <= '0';    
      ELSIF (clk'EVENT AND clk = '1') THEN
      --   np_fifo_almostfull_del <= np_fifo_almostfull;    
         np_fifo_wr_r <= np_fifo_wr;    
         IF ((np_fifo_wr AND NOT np_fifo_rd) = '1') THEN
            -- write, but no read
            
            np_fifo_wrempty_r <= '0';    
         ELSE
            IF (((((np_fifo_wr_del = '0') AND (np_fifo_wr = '0')) AND (np_fifo_wr_r = '0')) AND (np_fifo_rd = '1')) AND (used_words = "0001")) THEN
               -- no writes in progress, but reading last entry 
               
               np_fifo_wrempty_r <= '1';    
            ELSE
               np_fifo_wrempty_r <= np_fifo_wrempty;    --  else no change
            END IF;
         END IF;
      END IF;
   END PROCESS;
   np_fifo_wrempty <= np_fifo_wrempty_r ;
   -- np fifo controls
   np_fifo_wr <= (ena_np_bypass_xhdl8 AND data_in(87)) AND (tx_fifo_rd) ;
   np_fifo_rd <= np_data_ack AND NOT np_fifo_empty ;
   temp_xhdl11 <= pri_data_ack;
   data_ack_xhdl1 <= temp_xhdl11 ;
   
   -------------------------------------------------------
   -- NP Bypass Control
   -- Monitors core credits and determines if NP requests 
   -- need to be deferred.
   -------------------------------------------------------
   altpcierd_icm_npbypassctl_xhdl32 : altpcierd_icm_npbypassctl 
      GENERIC MAP (
         TXCRED_WIDTH => TXCRED_WIDTH)
      PORT MAP (
         clk => clk,
         rstn => rstn,
         tx_cred => tx_cred,
         data_in => data_in,
         data_valid => data_valid,
         data_ack => data_ack_xhdl1,
         tx_npcredh => tx_npcredh,
         tx_npcredd => tx_npcredd,
         tx_npcredh_infinite => tx_npcredh_infinite,
         tx_npcredd_infinite => tx_npcredd_infinite,
         tx_bridge_idle => tx_bridge_idle,
         np_fifo_wrempty => np_fifo_wrempty,
         np_fifo_rdempty => np_fifo_empty,
         np_data_in => np_data_xhdl7,
         tx_ack => tx_ack,
         np_data_ack => np_data_ack,
         sending_np => sending_np,
         sending_npd => sending_npd,
         ena_np_bypass => ena_np_bypass_xhdl8,
         tx_mask => tx_mask_xhdl4,
         got_cred => open,
         req_npbypass_pkt => req_npbypass_pkt_xhdl5);   
   
END ARCHITECTURE translated;
