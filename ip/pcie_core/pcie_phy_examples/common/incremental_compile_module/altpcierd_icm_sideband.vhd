LIBRARY ieee;                          
use IEEE.std_logic_1164.all;           
use IEEE.std_logic_arith.all;          
use IEEE.std_logic_unsigned.all;       
                                       
LIBRARY altera_mf;                     
USE altera_mf.altera_mf_components.all;
                                       
LIBRARY ieee;
   USE ieee.std_logic_1164.all;
-- synthesis verilog_version verilog_2001
-------------------------------------------------------------------------------
-- Title         : PCI Express Reference Design Example Application 
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcierd_icm_sideband.v
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
ENTITY altpcierd_icm_sideband IS
   PORT (
      
      clk                  : IN STD_LOGIC;
      rstn                 : IN STD_LOGIC;
      cfg_busdev           : IN STD_LOGIC_VECTOR(12 DOWNTO 0);		-- From core to app
      cfg_devcsr           : IN STD_LOGIC_VECTOR(31 DOWNTO 0);		-- From core to app
      cfg_linkcsr          : IN STD_LOGIC_VECTOR(31 DOWNTO 0);		-- From core to app
      cfg_prmcsr          : IN STD_LOGIC_VECTOR(31 DOWNTO 0);		-- From core to app      
      -- From core to app
      cfg_msicsr           : IN STD_LOGIC_VECTOR(15 DOWNTO 0);		-- From core to app
      cfg_tcvcmap          : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      -- From app to core
      app_int_sts          : IN STD_LOGIC;		-- From app to core
      app_int_sts_ack      : IN STD_LOGIC;		-- From core to app
      pex_msi_num          : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      cpl_err              : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      cpl_pending          : IN STD_LOGIC;
      
      cfg_busdev_del       : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
      cfg_devcsr_del       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_linkcsr_del      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_prmcsr_del      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);      
      cfg_msicsr_del       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      cfg_tcvcmap_del      : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
      app_int_sts_del      : OUT STD_LOGIC;
      app_int_sts_ack_del  : OUT STD_LOGIC;		-- To app
      pex_msi_num_del      : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      cpl_err_del          : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      cpl_pending_del      : OUT STD_LOGIC
   );
END ENTITY altpcierd_icm_sideband;
ARCHITECTURE altpcie OF altpcierd_icm_sideband IS
BEGIN
   
   -----------------------------------------------
   -- Incremental Compile Boundary registers
   -----------------------------------------------
   PROCESS (clk, rstn)
   BEGIN
      IF ((NOT(rstn)) = '1') THEN
         cfg_busdev_del <= "0000000000000";
         cfg_devcsr_del <= "00000000000000000000000000000000";
         cfg_linkcsr_del <= "00000000000000000000000000000000";
         cfg_prmcsr_del <= "00000000000000000000000000000000";         
         cfg_tcvcmap_del <= "000000000000000000000000";
         cfg_msicsr_del <= "0000000000000000";
         app_int_sts_del <= '0';
         app_int_sts_ack_del <= '0';
         pex_msi_num_del <= "00000";
         cpl_err_del <= "000";
         cpl_pending_del <= '0';
      ELSIF (clk'EVENT AND clk = '1') THEN
         cfg_busdev_del <= cfg_busdev;
         cfg_devcsr_del <= cfg_devcsr;
         cfg_linkcsr_del <= cfg_linkcsr;
         cfg_prmcsr_del <= cfg_prmcsr;         
         cfg_tcvcmap_del <= cfg_tcvcmap;
         cfg_msicsr_del <= cfg_msicsr;		-- From app to core.  NO COMBINATIONAL allowed on input
         app_int_sts_del <= app_int_sts;
         app_int_sts_ack_del <= app_int_sts_ack;		-- From app to core.  NO COMBINATIONAL allowed on input
         pex_msi_num_del <= pex_msi_num;		-- From app to core.  NO COMBINATIONAL allowed on input 
         cpl_err_del <= cpl_err;		-- From app to core.  NO COMBINATIONAL allowed on input
         cpl_pending_del <= cpl_pending;
      END IF;
   END PROCESS;
   
END ARCHITECTURE altpcie;
