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
-- File          : altpcierd_icm_rx.v
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
ENTITY altpcierd_icm_rx IS
   PORT (
      clk                     : IN std_logic;   
      rstn                    : IN std_logic;   
      rx_req                  : IN std_logic;   --  from core.  pkt request
      rx_ack                  : OUT std_logic;   --  to core.  rx request handshake
      rx_desc                 : IN std_logic_vector(135 DOWNTO 0);   --  from core.  pkt descriptor
      rx_data                 : IN std_logic_vector(63 DOWNTO 0);   --  from core.  pkt payload
      rx_be                   : IN std_logic_vector(7 DOWNTO 0);   --  from core.  byte enable bits
      rx_ws                   : OUT std_logic;   --  to core.  NP pkt mask control
      rx_dv                   : IN std_logic;   --  from core.  rx_data is valid
      rx_dfr                  : IN std_logic;   --  from core.  pkt has more data cycles
      rx_abort                : OUT std_logic;   --  to core.  Abort handshake
      rx_retry                : OUT std_logic;   --  to core.  Retry NP pkt handshake
      rx_mask                 : OUT std_logic;   --  to core.  NP pkt mask control
      rx_stream_ready         : IN std_logic;   --  indicates streaming interface can accept more data
      rx_stream_valid         : OUT std_logic;   --  writes rx_stream_data to streaming interface
      rx_stream_data          : OUT std_logic_vector(107 DOWNTO 0);   --  streaming interface data
      rx_stream_mask          : IN std_logic);   
END ENTITY altpcierd_icm_rx;
ARCHITECTURE translated OF altpcierd_icm_rx IS
   COMPONENT altpcierd_icm_fifo
      GENERIC (
          USEEAB                         :  string := "ON";    
          RAMTYPE                        :  string := "RAM_BLOCK_TYPE=M512");  
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
         q                       : OUT std_logic_vector(107 DOWNTO 0));
   END COMPONENT;
   COMPONENT altpcierd_icm_rxbridge
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
         stream_ready            : IN  std_logic;
         stream_wr               : OUT std_logic;
         stream_wrdata           : OUT std_logic_vector(107 DOWNTO 0));
   END COMPONENT;
   -- Fifo          
   SIGNAL fifo_empty               :  std_logic;   
   SIGNAL fifo_almostfull          :  std_logic;   
   SIGNAL fifo_wr                  :  std_logic;   
   SIGNAL fifo_rd                  :  std_logic;   
   SIGNAL fifo_wrdata              :  std_logic_vector(107 DOWNTO 0);   
   SIGNAL fifo_rddata              :  std_logic_vector(107 DOWNTO 0);   
   SIGNAL stream_ready_del         :  std_logic;   
   SIGNAL not_fifo_almost_full_del :  std_logic;   --  for performance
   SIGNAL fifo_rd_del              :  std_logic;   --  fifo output is valid one cycle after fifo_rd   
   -------------------------------------
   -- isolation fifo
   ------------------------------------- 
   SIGNAL xhdl_21                  :  std_logic;   
   SIGNAL port_xhdl22              :  std_logic;   
   SIGNAL rx_ack_xhdl1             :  std_logic;   
   SIGNAL rx_abort_xhdl2           :  std_logic;   
   SIGNAL rx_retry_xhdl3           :  std_logic;   
   SIGNAL rx_ws_xhdl4              :  std_logic;   
   SIGNAL rx_mask_xhdl5            :  std_logic;   
   SIGNAL rx_stream_valid_xhdl6    :  std_logic;   
   SIGNAL rx_stream_data_xhdl7     :  std_logic_vector(107 DOWNTO 0);   
BEGIN
   rx_ack <= rx_ack_xhdl1;
   rx_abort <= rx_abort_xhdl2;
   rx_retry <= rx_retry_xhdl3;
   rx_ws <= rx_ws_xhdl4;
   rx_mask <= rx_mask_xhdl5;
   rx_stream_valid <= rx_stream_valid_xhdl6;
   rx_stream_data <= rx_stream_data_xhdl7;
   
   --------------------------------------------------
   -- Core Interface
   --------------------------------------------------
   -- Bridge from Core RX port to Streaming I/F
   rx_altpcierd_icm_rxbridge : altpcierd_icm_rxbridge 
      PORT MAP (
         clk => clk,
         rstn => rstn,
         rx_req => rx_req,
         rx_desc => rx_desc,
         rx_dv => rx_dv,
         rx_dfr => rx_dfr,
         rx_data => rx_data,
         rx_be => rx_be,
         rx_ws => rx_ws_xhdl4,
         rx_ack => rx_ack_xhdl1,
         rx_abort => rx_abort_xhdl2,
         rx_retry => rx_retry_xhdl3,
         rx_mask => open,
         stream_ready => not_fifo_almost_full_del,
         stream_wr => fifo_wr,
         stream_wrdata => fifo_wrdata);   
   
   -- Throttle data from bridge
   
   PROCESS (clk, rstn)
   BEGIN
      IF (NOT rstn = '1') THEN
         not_fifo_almost_full_del <= '1';    
      ELSIF (clk'EVENT AND clk = '1') THEN
         not_fifo_almost_full_del <= NOT fifo_almostfull;    
      END IF;
   END PROCESS;
   xhdl_21 <= (fifo_rd AND NOT fifo_empty);
   port_xhdl22 <= NOT rstn;
   fifo_131x4 : altpcierd_icm_fifo 
      GENERIC MAP (
         RAMTYPE => "RAM_BLOCK_TYPE=AUTO")
      PORT MAP (
         clock => clk,
         aclr => port_xhdl22,
         data => fifo_wrdata,
         wrreq => fifo_wr,
         rdreq => xhdl_21,
         q => fifo_rddata,
         full => open,
         almost_full => fifo_almostfull,
         almost_empty => open,
         empty => fifo_empty);   
   
   --------------------------------------------
   -- Streaming interface.  Input pipe stage.
   --------------------------------------------
   
   PROCESS (clk, rstn)
   BEGIN
      IF (NOT rstn = '1') THEN
         stream_ready_del <= '0';    
         rx_mask_xhdl5 <= '0';    
      ELSIF (clk'EVENT AND clk = '1') THEN
         stream_ready_del <= rx_stream_ready;    
         rx_mask_xhdl5 <= rx_stream_mask;    
      END IF;
   END PROCESS;
   --------------------------------------------
   -- Streaming interface.  Output pipe stage.
   --------------------------------------------
   fifo_rd <= stream_ready_del AND NOT fifo_empty ;
   PROCESS (clk, rstn)
   BEGIN
      IF (NOT rstn = '1') THEN
         rx_stream_data_xhdl7 <= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";    
         fifo_rd_del <= '0';    
         rx_stream_valid_xhdl6 <= '0';    
      ELSIF (clk'EVENT AND clk = '1') THEN
         rx_stream_data_xhdl7 <= fifo_rddata;    
         fifo_rd_del <= fifo_rd AND NOT fifo_empty;    
         rx_stream_valid_xhdl6 <= fifo_rd_del;    --  push fifo data onto streaming interface
      END IF;
   END PROCESS;
END ARCHITECTURE translated;
