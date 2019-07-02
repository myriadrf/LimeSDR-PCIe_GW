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
-- File          : altpcierd_cdma_ast_msi.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This module construct of the Avalon Streaming receive port for the
-- chaining DMA application MSI signals.
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
ENTITY altpcierd_cdma_ast_msi IS
   PORT (
      clk_in        : IN STD_LOGIC;
      rstn          : IN STD_LOGIC;
      app_msi_req   : IN STD_LOGIC;
      app_msi_ack   : OUT STD_LOGIC;
      app_msi_tc    : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      app_msi_num   : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      stream_ready  : IN STD_LOGIC;
      stream_data   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      stream_valid  : OUT STD_LOGIC
   );
END ENTITY altpcierd_cdma_ast_msi;
ARCHITECTURE altpcie OF altpcierd_cdma_ast_msi IS
   

   SIGNAL stream_ready_del : STD_LOGIC;
   SIGNAL app_msi_req_r    : STD_LOGIC;
   SIGNAL m_data           : STD_LOGIC_VECTOR(7 DOWNTO 0);
   -- X-HDL generated signals
   SIGNAL xhdl0 : STD_LOGIC;
BEGIN
   
   m_data(7 DOWNTO 5) <= app_msi_tc(2 DOWNTO 0);
   m_data(4 DOWNTO 0) <= app_msi_num(4 DOWNTO 0);
   --------------------------------------------------------------
   --    Input register boundary
   --------------------------------------------------------------
   
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         stream_ready_del <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         stream_ready_del <= stream_ready;
      END IF;
   END PROCESS;
   --------------------------------------------------------------
   --    Arbitration between master and target for transmission
   --------------------------------------------------------------
   
   -- tx_state SM states
   
   xhdl0 <= app_msi_req WHEN (stream_ready_del = '1') ELSE
                       app_msi_req_r;
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         app_msi_ack <= '0';
         stream_valid <= '0';
         stream_data <= "00000000";
         app_msi_req_r <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         app_msi_ack <= stream_ready_del AND app_msi_req;
         stream_valid <= stream_ready_del AND app_msi_req AND NOT(app_msi_req_r);
         stream_data <= m_data;
         app_msi_req_r <= xhdl0;
      END IF;
   END PROCESS;
   
END ARCHITECTURE altpcie;
