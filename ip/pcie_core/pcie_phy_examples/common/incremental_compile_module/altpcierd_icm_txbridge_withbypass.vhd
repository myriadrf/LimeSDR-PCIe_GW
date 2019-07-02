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
ENTITY altpcierd_icm_txbridge_withbypass IS
   GENERIC (
      TXCRED_WIDTH                   :  integer := 22);    
   PORT (
      clk                     : IN std_logic;   
      rstn                    : IN std_logic;   
      tx_req                  : OUT std_logic;   --  to core.  TX request
      tx_ack                  : IN std_logic;   --  from core.  TX request ack
      tx_desc                 : OUT std_logic_vector(127 DOWNTO 0);   --  to core.  TX pkt descriptor
      tx_data                 : OUT std_logic_vector(63 DOWNTO 0);   --  to core.  TX pkt payload data
      tx_ws                   : IN std_logic;   --  from core.  TX dataphase throttle
      tx_dv                   : OUT std_logic;   --  to core.  TX dv contol
      tx_dfr                  : OUT std_logic;   --  to core.  TX dfr contol
      tx_be                   : OUT std_logic_vector(7 DOWNTO 0);   --  to core.  TX byte enabel -- not used
      tx_err                  : OUT std_logic;   --  to core.  TX error status
      tx_cpl_pending          : OUT std_logic;   --  to core.  TX completion pending status
      tx_cred                 : IN std_logic_vector(65 DOWNTO 0);   --  from core.  available credits.  this is a concatenation of info for 6 credit types
      tx_npcredh              : IN std_logic_vector(7 DOWNTO 0);   
      tx_npcredd              : IN std_logic_vector(11 DOWNTO 0);   
      tx_npcredh_infinite     : IN std_logic;   
      tx_npcredd_infinite     : IN std_logic;   
      data_ack                : OUT std_logic;   --  throttles data on TX streaming interface   
      data_valid              : IN std_logic;   --  indicates data_in is valid
      data_in                 : IN std_logic_vector(107 DOWNTO 0);   --  data from TX streaming interface   
      tx_bridge_idle          : OUT std_logic;   
      tx_mask                 : OUT std_logic;   --  to app.  throttles nonposted requests
	  msi_busy                : IN std_logic;   
	  tx_fifo_rd              : IN std_logic);    
END ENTITY altpcierd_icm_txbridge_withbypass;
ARCHITECTURE translated OF altpcierd_icm_txbridge_withbypass IS
   COMPONENT altpcierd_icm_tx_pktordering
      GENERIC (
          TXCRED_WIDTH                   :  integer := 22);    
      PORT (
         clk                     : IN  std_logic;
         rstn                    : IN  std_logic;
         data_ack                : OUT std_logic;
         data_valid              : IN  std_logic;
         data_in                 : IN  std_logic_vector(107 DOWNTO 0);
         tx_bridge_idle          : IN  std_logic;
         tx_cred                 : IN  std_logic_vector(65 DOWNTO 0);
         tx_npcredh              : IN  std_logic_vector(7 DOWNTO 0);
         tx_npcredd              : IN  std_logic_vector(11 DOWNTO 0);
         tx_npcredh_infinite     : IN  std_logic;
         tx_npcredd_infinite     : IN  std_logic;
         pri_data_ack            : IN  std_logic;
         pri_data_valid          : OUT std_logic;
         pri_data                : OUT std_logic_vector(107 DOWNTO 0);
         tx_mask                 : OUT std_logic;
         tx_ack                  : IN  std_logic;
         ena_np_bypass           : OUT std_logic;
         sending_np              : IN  std_logic;
         sending_npd             : IN  std_logic;
         req_npbypass_pkt        : OUT std_logic;
         np_data_valid           : OUT std_logic;
         np_data                 : OUT std_logic_vector(107 DOWNTO 0);
         np_data_ack             : IN  std_logic;
		 msi_busy                : IN  std_logic;
		 tx_fifo_rd              : IN  std_logic;
		 np_fifo_almostfull      : OUT std_logic);
   END COMPONENT;
   COMPONENT altpcierd_icm_txbridge
      PORT (
         clk                     : IN  std_logic;
         rstn                    : IN  std_logic;
         pri_data_valid          : IN  std_logic;
         pri_data_in             : IN  std_logic_vector(107 DOWNTO 0);
         pri_data_ack            : OUT std_logic;
         ena_np_bypass           : IN  std_logic;
         req_npbypass_pkt        : IN  std_logic;
         np_data_valid           : IN  std_logic;
         np_data_in              : IN  std_logic_vector(107 DOWNTO 0);
         np_data_ack             : OUT std_logic;
         sending_np              : OUT std_logic;
         sending_npd             : OUT std_logic;
         tx_ack                  : IN  std_logic;
         tx_ws                   : IN  std_logic;
         tx_req                  : OUT std_logic;
         tx_dfr                  : OUT std_logic;
         tx_dv                   : OUT std_logic;
         tx_data                 : OUT std_logic_vector(63 DOWNTO 0);
         tx_desc                 : OUT std_logic_vector(127 DOWNTO 0);
         tx_be                   : OUT std_logic_vector(7 DOWNTO 0);
         tx_err                  : OUT std_logic;
         tx_cpl_pending          : OUT std_logic;
         tx_bridge_idle          : OUT std_logic;
		 msi_busy                : IN  std_logic;
		 np_fifo_almostfull      : IN  std_logic);
   END COMPONENT;
   SIGNAL np_data_valid            :  std_logic;   --  indicates data_in is valid
   SIGNAL np_data                  :  std_logic_vector(107 DOWNTO 0);   --  data from the np bypass fifo   
   SIGNAL np_data_ack              :  std_logic;   
   SIGNAL fifo_rd                  :  std_logic;   --  fifo read control
   SIGNAL fifo_rddata              :  std_logic_vector(107 DOWNTO 0);   --  fifo read data
   SIGNAL fifo_data_valid          :  std_logic;   --  menas fifo_rddata is valid 
   SIGNAL pri_data_valid           :  std_logic;   
   SIGNAL pri_data                 :  std_logic_vector(107 DOWNTO 0);   
   SIGNAL pri_data_ack             :  std_logic;   
   SIGNAL ena_np_bypass            :  std_logic;   
   SIGNAL sending_np               :  std_logic;   
   SIGNAL sending_npd              :  std_logic;   
   SIGNAL tx_req_xhdl1             :  std_logic;   
   SIGNAL tx_desc_xhdl2            :  std_logic_vector(127 DOWNTO 0);   
   SIGNAL tx_data_xhdl3            :  std_logic_vector(63 DOWNTO 0);   
   SIGNAL tx_dv_xhdl4              :  std_logic;   
   SIGNAL tx_dfr_xhdl5             :  std_logic;   
   SIGNAL tx_be_xhdl6              :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL tx_cpl_pending_xhdl7     :  std_logic;   
   SIGNAL tx_err_xhdl8             :  std_logic;   
   SIGNAL tx_bridge_idle_xhdl9     :  std_logic;   
   SIGNAL tx_mask_xhdl10           :  std_logic;   
   SIGNAL data_ack_xhdl11          :  std_logic;   
   SIGNAL req_npbypass_pkt         :  std_logic;   
   SIGNAL np_fifo_almostfull       :  std_logic;
BEGIN
   tx_req <= tx_req_xhdl1;
   tx_desc <= tx_desc_xhdl2;
   tx_data <= tx_data_xhdl3;
   tx_dv <= tx_dv_xhdl4;
   tx_dfr <= tx_dfr_xhdl5;
   tx_be <= tx_be_xhdl6;
   tx_cpl_pending <= tx_cpl_pending_xhdl7;
   tx_err <= tx_err_xhdl8;
   tx_bridge_idle <= tx_bridge_idle_xhdl9;
   tx_mask <= tx_mask_xhdl10;
   data_ack <= data_ack_xhdl11;
   
   -- Data from the avalon interface gets reordered
   -- as required for NP bypassing before it is 
   -- translated to the Core Interface
   altpcierd_icm_tx_pktordering_xhdl35 : altpcierd_icm_tx_pktordering 
      GENERIC MAP (
         TXCRED_WIDTH => TXCRED_WIDTH)
      PORT MAP (
         clk => clk,
         rstn => rstn,
         data_valid => data_valid,
         data_in => data_in,
         data_ack => data_ack_xhdl11,
         tx_bridge_idle => tx_bridge_idle_xhdl9,
         tx_cred => tx_cred,
         tx_npcredh => tx_npcredh,
         tx_npcredd => tx_npcredd,
         tx_npcredh_infinite => tx_npcredh_infinite,
         tx_npcredd_infinite => tx_npcredd_infinite,
         tx_mask => tx_mask_xhdl10,
         req_npbypass_pkt => req_npbypass_pkt,
         tx_ack => tx_ack,
         ena_np_bypass => ena_np_bypass,
         sending_np => sending_np,
         sending_npd => sending_npd,
         pri_data_valid => pri_data_valid,
         pri_data => pri_data,
         pri_data_ack => pri_data_ack,
         np_data_valid => np_data_valid,
         np_data => np_data,
         np_data_ack => np_data_ack, 
		 np_fifo_almostfull => np_fifo_almostfull,
		 msi_busy => msi_busy,
		 tx_fifo_rd => tx_fifo_rd);   
   
   
   -- Bridge to the Core TX Interface  
   -- Reordered packets are passed to the Core interface  
   altpcierd_icm_txbridge_xhdl57 : altpcierd_icm_txbridge 
      PORT MAP (
         clk => clk,
         rstn => rstn,
         pri_data_valid => pri_data_valid,
         pri_data_in => pri_data,
         pri_data_ack => pri_data_ack,
         ena_np_bypass => ena_np_bypass,
         np_data_valid => np_data_valid,
         np_data_in => np_data,
         np_data_ack => np_data_ack,
         tx_ack => tx_ack,
         tx_ws => tx_ws,
         sending_np => sending_np,
         sending_npd => sending_npd,
         tx_req => tx_req_xhdl1,
         tx_dfr => tx_dfr_xhdl5,
         tx_dv => tx_dv_xhdl4,
         tx_data => tx_data_xhdl3,
         tx_desc => tx_desc_xhdl2,
         tx_be => tx_be_xhdl6,
         tx_err => tx_err_xhdl8,
         tx_cpl_pending => tx_cpl_pending_xhdl7,
         tx_bridge_idle => tx_bridge_idle_xhdl9,
         req_npbypass_pkt => req_npbypass_pkt,
		 msi_busy => msi_busy,
		 np_fifo_almostfull => np_fifo_almostfull);   
   
END ARCHITECTURE translated;
