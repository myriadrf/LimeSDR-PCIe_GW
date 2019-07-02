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
-- File          : avalon_legacy_bridge.v
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
ENTITY altpcierd_icm_msibridge IS
   PORT (
      clk                     : IN std_logic;   
      rstn                    : IN std_logic;   
      data_valid              : IN std_logic;   
      data_in                 : IN std_logic_vector(107 DOWNTO 0);   
      data_ack                : OUT std_logic;   
      msi_ack                 : IN std_logic;   
      msi_req                 : OUT std_logic;   
      msi_num                 : OUT std_logic_vector(4 DOWNTO 0);   
      msi_tc                  : OUT std_logic_vector(2 DOWNTO 0));   
END ENTITY altpcierd_icm_msibridge;
ARCHITECTURE translated OF altpcierd_icm_msibridge IS
   SIGNAL msi_req_r                :  std_logic;   
   SIGNAL throttle_data            :  std_logic;   
   SIGNAL temp_xhdl5               :  std_logic_vector(84 DOWNTO 80);   
   SIGNAL temp_xhdl6               :  std_logic_vector(79 DOWNTO 77);   
   SIGNAL temp_xhdl7               :  std_logic;   
   SIGNAL temp_xhdl8               :  std_logic;   
   SIGNAL data_ack_xhdl1           :  std_logic;   
   SIGNAL msi_req_xhdl2            :  std_logic;   
   SIGNAL msi_num_xhdl3            :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL msi_tc_xhdl4             :  std_logic_vector(2 DOWNTO 0);   
BEGIN
   data_ack <= data_ack_xhdl1;
   msi_req <= msi_req_xhdl2;
   msi_num <= msi_num_xhdl3;
   msi_tc <= msi_tc_xhdl4;
   ----------------------------------
   -- legacy output signals
   ----------------------------------   
   ----------------------------------
   -- avalon ready
   ----------------------------------
   data_ack_xhdl1 <= NOT (NOT msi_ack AND (msi_req_xhdl2 OR (data_valid AND data_in(76)))) ;
   temp_xhdl5 <= data_in(84 DOWNTO 80) WHEN (data_in(76)) = '1' ELSE msi_num_xhdl3;
   temp_xhdl6 <= data_in(79 DOWNTO 77) WHEN (data_in(76)) = '1' ELSE msi_tc_xhdl4;
   temp_xhdl7 <= '1' WHEN (data_valid AND data_in(76)) = '1' ELSE msi_req_xhdl2;
   temp_xhdl8 <= '0' WHEN msi_ack = '1' ELSE temp_xhdl7;
   PROCESS (clk, rstn)
   BEGIN
      IF (NOT rstn = '1') THEN
         msi_num_xhdl3 <= "00000";    
         msi_tc_xhdl4 <= "000";    
         msi_req_xhdl2 <= '0';    
      ELSIF (clk'EVENT AND clk = '1') THEN
         msi_num_xhdl3 <= temp_xhdl5;    
         msi_tc_xhdl4 <= temp_xhdl6;    
         msi_req_xhdl2 <= temp_xhdl8;    
      END IF;
   END PROCESS;
   -- 
   --    wire          msi_req; 
   --    wire [4:0]    msi_num;
   --    wire [2:0]    msi_tc;
   --    reg           msi_req_r;
   --    wire          throttle_data;
   --    reg [4:0]     msi_num_r;
   --    reg [2:0]     msi_tc_r;
   --    reg           msi_ack_r;
   --    //--------------------------------
   --    // legacy output signals
   --    //--------------------------------   
   --    assign msi_req  = msi_ack_r ? 1'b0 : (data_valid & data_in[`STREAM_MSI_VALID]) ? 1'b1 : msi_req_r;   
   --    assign msi_tc  = (data_in[`STREAM_MSI_VALID]) ? data_in[`STREAM_MSI_TC] : msi_tc_r; 
   --    assign msi_num = (data_in[`STREAM_MSI_VALID]) ? data_in[`STREAM_APP_MSI_NUM] : msi_num_r;
   --    //--------------------------------
   --    // avalon ready
   --    //--------------------------------
   --    assign data_ack  = ~msi_req;  
   --    always @ (posedge clk or negedge rstn) begin
   --        if (~rstn) begin 
   -- 	       msi_num_r <= 5'h0;
   -- 		   msi_tc_r  <= 3'h0;
   -- 		   msi_req_r <= 1'b0;
   -- 		   msi_ack_r <= 1'b0;
   -- 	   end
   -- 	   else begin 
   -- 	       msi_num_r <= msi_num;
   -- 		   msi_tc_r  <= msi_tc;
   -- 		   msi_req_r <= msi_req; 
   -- 		   msi_ack_r <= msi_ack;
   -- 	   end
   --    end
   -- 
END ARCHITECTURE translated;
