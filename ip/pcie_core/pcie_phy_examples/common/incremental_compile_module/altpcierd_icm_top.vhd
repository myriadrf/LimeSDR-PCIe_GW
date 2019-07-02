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
-- File          : altpcierd_icm_top.v
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
ENTITY altpcierd_icm_top IS
   GENERIC (
      TXCRED_WIDTH                   :  integer := 22);    
   PORT (
      clk                     : IN std_logic;   
      rstn                    : IN std_logic;   
      -- RX IO
      rx_req0                 : IN std_logic;   
      rx_ack0                 : OUT std_logic;   
      rx_desc0                : IN std_logic_vector(135 DOWNTO 0);   
      rx_data0                : IN std_logic_vector(63 DOWNTO 0);   
      rx_be0                  : IN std_logic_vector(7 DOWNTO 0);   
      rx_ws0                  : OUT std_logic;   
      rx_dv0                  : IN std_logic;   
      rx_dfr0                 : IN std_logic;   
      rx_abort0               : OUT std_logic;   
      rx_retry0               : OUT std_logic;   
      rx_mask0                : OUT std_logic;   
      rx_stream_ready0        : IN std_logic;   
      rx_stream_valid0        : OUT std_logic;   
      rx_stream_data0         : OUT std_logic_vector(81 DOWNTO 0);   
      rx_stream_mask0         : IN std_logic;   
      tx_req0                 : OUT std_logic;   
      -- TX  IO
      tx_ack0                 : IN std_logic;   
      tx_desc0                : OUT std_logic_vector(127 DOWNTO 0);   
      tx_data0                : OUT std_logic_vector(63 DOWNTO 0);   
      tx_ws0                  : IN std_logic;   
      tx_dv0                  : OUT std_logic;   
      tx_dfr0                 : OUT std_logic;   
      tx_err0                 : OUT std_logic;   
      tx_cred0                : IN std_logic_vector(TXCRED_WIDTH - 1 DOWNTO 0);   
      tx_stream_cred0         : OUT std_logic_vector(TXCRED_WIDTH - 1 DOWNTO 0);   
      tx_npcredh0             : IN std_logic_vector(7 DOWNTO 0);   
      tx_npcredd0             : IN std_logic_vector(11 DOWNTO 0);   
      tx_npcredh_inf0         : IN std_logic;   
      tx_npcredd_inf0         : IN std_logic;   
      -- MSI IO
      app_msi_ack             : IN std_logic;   
      app_msi_req             : OUT std_logic;   
      app_msi_num             : OUT std_logic_vector(4 DOWNTO 0);   
      app_msi_tc              : OUT std_logic_vector(2 DOWNTO 0);   
      tx_stream_ready0        : OUT std_logic;   
      tx_stream_valid0        : IN std_logic;   
      tx_stream_data0         : IN std_logic_vector(74 DOWNTO 0);   
      msi_stream_ready0       : OUT std_logic;   
      msi_stream_valid0       : IN std_logic;   
      msi_stream_data0        : IN std_logic_vector(7 DOWNTO 0);   
      tx_stream_mask0         : OUT std_logic;   
      cpl_pending_icm         : IN std_logic;   
      cpl_pending             : OUT std_logic;   
      cfg_busdev_icm          : OUT std_logic_vector(12 DOWNTO 0);   
      cfg_devcsr_icm          : OUT std_logic_vector(31 DOWNTO 0);   
      cfg_linkcsr_icm         : OUT std_logic_vector(31 DOWNTO 0);
      cfg_prmcsr_icm         : OUT std_logic_vector(31 DOWNTO 0);   
      cfg_tcvcmap_icm         : OUT std_logic_vector(23 DOWNTO 0);  
      cfg_msicsr_icm          : OUT std_logic_vector(15 DOWNTO 0); 
      app_int_sts_icm         : IN std_logic;   
      pex_msi_num_icm         : IN std_logic_vector(4 DOWNTO 0);   
      cpl_err_icm             : IN std_logic_vector(2 DOWNTO 0);   
      -- CONFIG SIDEBAND
      app_int_sts_ack         : IN std_logic;
      app_int_sts_ack_icm     : OUT std_logic;
      cfg_busdev              : IN std_logic_vector(12 DOWNTO 0);   
      cfg_devcsr              : IN std_logic_vector(31 DOWNTO 0);   
      cfg_linkcsr             : IN std_logic_vector(31 DOWNTO 0);
      cfg_prmcsr             : IN std_logic_vector(31 DOWNTO 0);         
      cfg_tcvcmap             : IN std_logic_vector(23 DOWNTO 0); 
      cfg_msicsr              : IN std_logic_vector(15 DOWNTO 0);
      app_int_sts             : OUT std_logic;   
      pex_msi_num             : OUT std_logic_vector(4 DOWNTO 0);   
      cpl_err                 : OUT std_logic_vector(2 DOWNTO 0);   
      -- TEST SIGNALS   
      test_out                : IN std_logic_vector(8 DOWNTO 0);   
      test_out_icm            : OUT std_logic_vector(8 DOWNTO 0));   
END ENTITY altpcierd_icm_top;
ARCHITECTURE translated OF altpcierd_icm_top IS
   COMPONENT altpcierd_icm_rx
      PORT (
         clk                     : IN  std_logic;
         rstn                    : IN  std_logic;
         rx_req                  : IN  std_logic;
         rx_ack                  : OUT std_logic;
         rx_desc                 : IN  std_logic_vector(135 DOWNTO 0);
         rx_data                 : IN  std_logic_vector(63 DOWNTO 0);
         rx_be                   : IN  std_logic_vector(7 DOWNTO 0);
         rx_ws                   : OUT std_logic;
         rx_dv                   : IN  std_logic;
         rx_dfr                  : IN  std_logic;
         rx_abort                : OUT std_logic;
         rx_retry                : OUT std_logic;
         rx_mask                 : OUT std_logic;
         rx_stream_ready         : IN  std_logic;
         rx_stream_valid         : OUT std_logic;
         rx_stream_data          : OUT std_logic_vector(107 DOWNTO 0);
         rx_stream_mask          : IN  std_logic);
   END COMPONENT;
   COMPONENT altpcierd_icm_sideband
      PORT (
         clk                     : IN  std_logic;
         rstn                    : IN  std_logic;
         cfg_busdev              : IN  std_logic_vector(12 DOWNTO 0);
         cfg_devcsr              : IN  std_logic_vector(31 DOWNTO 0);
         cfg_linkcsr             : IN  std_logic_vector(31 DOWNTO 0);
         cfg_prmcsr             : IN  std_logic_vector(31 DOWNTO 0);         
         cfg_tcvcmap             : IN  std_logic_vector(23 DOWNTO 0);
         cfg_msicsr              : IN  std_logic_vector(15 DOWNTO 0);
         app_int_sts             : IN  std_logic;
         app_int_sts_ack         : IN  std_logic;
         pex_msi_num             : IN  std_logic_vector(4 DOWNTO 0);
         cpl_err                 : IN  std_logic_vector(2 DOWNTO 0);
         cpl_pending             : IN  std_logic;
         cfg_busdev_del          : OUT std_logic_vector(12 DOWNTO 0);
         cfg_devcsr_del          : OUT std_logic_vector(31 DOWNTO 0);
         cfg_linkcsr_del         : OUT std_logic_vector(31 DOWNTO 0);
         cfg_prmcsr_del         : OUT std_logic_vector(31 DOWNTO 0);         
         cfg_tcvcmap_del         : OUT std_logic_vector(23 DOWNTO 0);
         cfg_msicsr_del          : OUT std_logic_vector(15 DOWNTO 0);
         app_int_sts_del         : OUT std_logic;
         app_int_sts_ack_del     : OUT std_logic;
         pex_msi_num_del         : OUT std_logic_vector(4 DOWNTO 0);
         cpl_err_del             : OUT std_logic_vector(2 DOWNTO 0);
         cpl_pending_del         : OUT std_logic);
   END COMPONENT;
   COMPONENT altpcierd_icm_tx
      GENERIC (
          TXCRED_WIDTH                   :  integer := 22);    
      PORT (
         clk                     : IN  std_logic;
         rstn                    : IN  std_logic;
         tx_req                  : OUT std_logic;
         tx_ack                  : IN  std_logic;
         tx_desc                 : OUT std_logic_vector(127 DOWNTO 0);
         tx_data                 : OUT std_logic_vector(63 DOWNTO 0);
         tx_ws                   : IN  std_logic;
         tx_dv                   : OUT std_logic;
         tx_dfr                  : OUT std_logic;
         tx_be                   : OUT std_logic_vector(7 DOWNTO 0);
         tx_err                  : OUT std_logic;
         tx_cpl_pending          : OUT std_logic;
         tx_cred_int             : IN  std_logic_vector(TXCRED_WIDTH - 1 DOWNTO 0);
         tx_npcredh              : IN  std_logic_vector(7 DOWNTO 0);
         tx_npcredd              : IN  std_logic_vector(11 DOWNTO 0);
         tx_npcredh_infinite     : IN  std_logic;
         tx_npcredd_infinite     : IN  std_logic;
         app_msi_ack             : IN  std_logic;
         app_msi_req             : OUT std_logic;
         app_msi_num             : OUT std_logic_vector(4 DOWNTO 0);
         app_msi_tc              : OUT std_logic_vector(2 DOWNTO 0);
         stream_ready            : OUT std_logic;
         stream_valid            : IN  std_logic;
         stream_data_in          : IN  std_logic_vector(107 DOWNTO 0);
         stream_msi_ready        : OUT std_logic;
         stream_msi_valid        : IN  std_logic;
         stream_msi_data_in      : IN  std_logic_vector(7 DOWNTO 0);
         tx_mask                 : OUT std_logic;
         tx_cred                 : OUT std_logic_vector(TXCRED_WIDTH - 1 DOWNTO 0));
   END COMPONENT;
   SIGNAL rx_stream_data0_int      :  std_logic_vector(107 DOWNTO 0);   
   SIGNAL tx_stream_data0_int      :  std_logic_vector(107 DOWNTO 0);   
   SIGNAL rx_ack0_xhdl1            :  std_logic;   
   SIGNAL rx_abort0_xhdl2          :  std_logic;   
   SIGNAL rx_retry0_xhdl3          :  std_logic;   
   SIGNAL rx_ws0_xhdl4             :  std_logic;   
   SIGNAL rx_mask0_xhdl5           :  std_logic;   
   SIGNAL rx_stream_valid0_xhdl6   :  std_logic;   
   SIGNAL rx_stream_data0_xhdl7    :  std_logic_vector(81 DOWNTO 0);   
   SIGNAL tx_req0_xhdl8            :  std_logic;   
   SIGNAL tx_desc0_xhdl9           :  std_logic_vector(127 DOWNTO 0);   
   SIGNAL tx_data0_xhdl10          :  std_logic_vector(63 DOWNTO 0);   
   SIGNAL tx_dv0_xhdl11            :  std_logic;   
   SIGNAL tx_dfr0_xhdl12           :  std_logic;   
   SIGNAL tx_err0_xhdl13           :  std_logic;   
   SIGNAL tx_stream_cred0_xhdl14   :  std_logic_vector(TXCRED_WIDTH - 1 DOWNTO 0);   
   SIGNAL tx_stream_ready0_xhdl15  :  std_logic;   
   SIGNAL tx_stream_mask0_xhdl16   :  std_logic;   
   SIGNAL app_msi_req_xhdl17       :  std_logic;   
   SIGNAL app_msi_num_xhdl18       :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL app_msi_tc_xhdl19        :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL msi_stream_ready0_xhdl20 :  std_logic;   
   SIGNAL cfg_busdev_icm_xhdl21    :  std_logic_vector(12 DOWNTO 0);   
   SIGNAL cfg_devcsr_icm_xhdl22    :  std_logic_vector(31 DOWNTO 0);   
   SIGNAL cfg_linkcsr_icm_xhdl23   :  std_logic_vector(31 DOWNTO 0);
   SIGNAL cfg_prmcsr_icm_xhdl23   :  std_logic_vector(31 DOWNTO 0);      
   SIGNAL cfg_tcvcmap_icm_xhdl24   :  std_logic_vector(23 DOWNTO 0); 
   SIGNAL cfg_msicsr_icm_xhdl131   :  std_logic_vector(15 DOWNTO 0);
   SIGNAL app_int_sts_xhdl25       :  std_logic; 
   SIGNAL  app_int_sts_ack_icm_xhdl130      :  std_logic;
   SIGNAL pex_msi_num_xhdl26       :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL cpl_err_xhdl27           :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL cpl_pending_xhdl28       :  std_logic;   
   SIGNAL test_out_icm_xhdl29      :  std_logic_vector(8 DOWNTO 0);   
BEGIN
   rx_ack0 <= rx_ack0_xhdl1;
   rx_abort0 <= rx_abort0_xhdl2;
   rx_retry0 <= rx_retry0_xhdl3;
   rx_ws0 <= rx_ws0_xhdl4;
   rx_mask0 <= rx_mask0_xhdl5;
   rx_stream_valid0 <= rx_stream_valid0_xhdl6;
   rx_stream_data0 <= rx_stream_data0_xhdl7;
   tx_req0 <= tx_req0_xhdl8;
   tx_desc0 <= tx_desc0_xhdl9;
   tx_data0 <= tx_data0_xhdl10;
   tx_dv0 <= tx_dv0_xhdl11;
   tx_dfr0 <= tx_dfr0_xhdl12;
   tx_err0 <= tx_err0_xhdl13;
   tx_stream_cred0 <= tx_stream_cred0_xhdl14;
   tx_stream_ready0 <= tx_stream_ready0_xhdl15;
   tx_stream_mask0 <= tx_stream_mask0_xhdl16;
   app_msi_req <= app_msi_req_xhdl17;
   app_msi_num <= app_msi_num_xhdl18;
   app_msi_tc <= app_msi_tc_xhdl19;
   msi_stream_ready0 <= msi_stream_ready0_xhdl20;
   cfg_busdev_icm <= cfg_busdev_icm_xhdl21;
   cfg_devcsr_icm <= cfg_devcsr_icm_xhdl22;
   cfg_prmcsr_icm <= cfg_prmcsr_icm_xhdl23;
   cfg_linkcsr_icm <= cfg_linkcsr_icm_xhdl23;
   cfg_tcvcmap_icm <= cfg_tcvcmap_icm_xhdl24;
   cfg_msicsr_icm <= cfg_msicsr_icm_xhdl131;
   app_int_sts <= app_int_sts_xhdl25;
   app_int_sts_ack_icm <= app_int_sts_ack_icm_xhdl130;
   pex_msi_num <= pex_msi_num_xhdl26;
   cpl_err <= cpl_err_xhdl27;
   cpl_pending <= cpl_pending_xhdl28;
   test_out_icm <= test_out_icm_xhdl29;
   rx_stream_data0_xhdl7 <= rx_stream_data0_int(81 DOWNTO 0) ;
   tx_stream_data0_int <= "000000000000000000000000000000000" & tx_stream_data0 ;
   
   -- Bridge from Core RX port to RX Streaming port
   altpcierd_icm_rx_xhdl32 : altpcierd_icm_rx 
      PORT MAP (
         clk => clk,
         rstn => rstn,
         rx_req => rx_req0,
         rx_ack => rx_ack0_xhdl1,
         rx_desc => rx_desc0,
         rx_data => rx_data0,
         rx_be => rx_be0,
         rx_ws => rx_ws0_xhdl4,
         rx_dv => rx_dv0,
         rx_dfr => rx_dfr0,
         rx_abort => rx_abort0_xhdl2,
         rx_retry => rx_retry0_xhdl3,
         rx_mask => rx_mask0_xhdl5,
         rx_stream_ready => rx_stream_ready0,
         rx_stream_valid => rx_stream_valid0_xhdl6,
         rx_stream_data => rx_stream_data0_int,
         rx_stream_mask => rx_stream_mask0);   
   
   
   -- Contains 2 Bridges:  Core TX port to TX Streaming Port 
   --                      Core MSI port to MSI Streaming Port
   -- Data from the TX and MSI ports are kept synchronized thru this bridge.
   altpcierd_icm_tx_xhdl40 : altpcierd_icm_tx 
      GENERIC MAP (
         TXCRED_WIDTH => TXCRED_WIDTH)
      PORT MAP (
         clk => clk,
         rstn => rstn,
         tx_req => tx_req0_xhdl8,
         tx_ack => tx_ack0,
         tx_desc => tx_desc0_xhdl9,
         tx_data => tx_data0_xhdl10,
         tx_ws => tx_ws0,
         tx_dv => tx_dv0_xhdl11,
         tx_dfr => tx_dfr0_xhdl12,
         tx_be => open,
         tx_err => tx_err0_xhdl13,
         tx_cpl_pending => open,
         tx_cred_int => tx_cred0,
         tx_npcredh => tx_npcredh0,
         tx_npcredd => tx_npcredd0,
         tx_npcredh_infinite => tx_npcredh_inf0,
         tx_npcredd_infinite => tx_npcredd_inf0,
         stream_ready => tx_stream_ready0_xhdl15,
         stream_valid => tx_stream_valid0,
         stream_data_in => tx_stream_data0_int,
         app_msi_ack => app_msi_ack,
         app_msi_req => app_msi_req_xhdl17,
         app_msi_num => app_msi_num_xhdl18,
         app_msi_tc => app_msi_tc_xhdl19,
         stream_msi_ready => msi_stream_ready0_xhdl20,
         stream_msi_valid => msi_stream_valid0,
         stream_msi_data_in => msi_stream_data0,
         tx_mask => tx_stream_mask0_xhdl16,
         tx_cred => open);   
   
   
   -- Configuration sideband signals
   altpcierd_icm_sideband_xhdl51 : altpcierd_icm_sideband 
      PORT MAP (
         clk => clk,
         rstn => rstn,
         cfg_busdev => cfg_busdev,
         cfg_devcsr => cfg_devcsr,
         cfg_linkcsr => cfg_linkcsr,
         cfg_prmcsr => cfg_prmcsr,         
         cfg_tcvcmap => cfg_tcvcmap,
         cfg_msicsr  => cfg_msicsr,
         app_int_sts => app_int_sts_icm,
         app_int_sts_ack => app_int_sts_ack,
         app_int_sts_ack_del => app_int_sts_ack_icm_xhdl130,
         pex_msi_num => pex_msi_num_icm,
         cpl_err => cpl_err_icm,
         cpl_pending => cpl_pending_icm,
         cfg_busdev_del => cfg_busdev_icm_xhdl21,
         cfg_devcsr_del => cfg_devcsr_icm_xhdl22,
         cfg_linkcsr_del => cfg_linkcsr_icm_xhdl23,
         cfg_prmcsr_del => cfg_prmcsr_icm_xhdl23,         
         cfg_tcvcmap_del => cfg_tcvcmap_icm_xhdl24,
         cfg_msicsr_del  => cfg_msicsr_icm_xhdl131,
         app_int_sts_del => app_int_sts_xhdl25,
         pex_msi_num_del => pex_msi_num_xhdl26,
         cpl_err_del => cpl_err_xhdl27,
         cpl_pending_del => cpl_pending_xhdl28);   
   
   --/////////////////////////////////////////////////////
   -- Incremental Compile registers for
   -- Test Out signals
   --/////////////////////////////////////////////////////
   
   PROCESS (clk, rstn)
   BEGIN
      IF (NOT rstn = '1') THEN
         test_out_icm_xhdl29 <= "000000000";   
         tx_stream_cred0_xhdl14 <= (OTHERS => '0');
      ELSIF (clk'EVENT AND clk = '1') THEN
         test_out_icm_xhdl29 <= test_out;  
         tx_stream_cred0_xhdl14 <= tx_cred0;
      END IF;
   END PROCESS;
END ARCHITECTURE translated;
