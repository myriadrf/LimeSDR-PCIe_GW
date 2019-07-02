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
-- File          : altpcierd_tl_cfg_sample.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This module extracts the configuration space register information from
-- the multiplexed tl_cfg_ctl interface from the Hard IP core.  And synchronizes
-- this info, as well as the tl_cfg_sts info to the Application clock.
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
ENTITY altpcierd_tl_cfg_sample IS
   GENERIC (
      HIP_SV           : INTEGER := 0
   );
   PORT (

      pld_clk        : IN STD_LOGIC;      -- 125Mhz or 250Mhz
      rstn           : IN STD_LOGIC;
      tl_cfg_add     : IN STD_LOGIC_VECTOR(3 DOWNTO 0);     -- from core_clk domain
      tl_cfg_ctl     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);    -- from core_clk domain
      tl_cfg_ctl_wr  : IN STD_LOGIC;      -- from core_clk domain
      tl_cfg_sts     : IN STD_LOGIC_VECTOR(52 DOWNTO 0);    -- from core_clk domain
      tl_cfg_sts_wr  : IN STD_LOGIC;      -- from core_clk domain
      cfg_busdev     : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);      -- synced to pld_clk
      cfg_devcsr     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);      -- synced to pld_clk
      cfg_linkcsr    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);      -- synced to pld_clk
      cfg_prmcsr     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

      cfg_io_bas     : OUT STD_LOGIC_VECTOR(19 DOWNTO 0);
      cfg_io_lim     : OUT STD_LOGIC_VECTOR(19 DOWNTO 0);
      cfg_np_bas     : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
      cfg_np_lim     : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
      cfg_pr_bas     : OUT STD_LOGIC_VECTOR(43 DOWNTO 0);
      cfg_pr_lim     : OUT STD_LOGIC_VECTOR(43 DOWNTO 0);

      cfg_tcvcmap    : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);

      cfg_msicsr     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
   );
END ENTITY altpcierd_tl_cfg_sample;
ARCHITECTURE altpcie OF altpcierd_tl_cfg_sample IS


   SIGNAL tl_cfg_ctl_wr_r   : STD_LOGIC;
   SIGNAL tl_cfg_ctl_wr_rr  : STD_LOGIC;
   SIGNAL tl_cfg_ctl_wr_rrr : STD_LOGIC;

   SIGNAL tl_cfg_sts_wr_r   : STD_LOGIC;
   SIGNAL tl_cfg_sts_wr_rr  : STD_LOGIC;
   SIGNAL tl_cfg_sts_wr_rrr : STD_LOGIC;
BEGIN

   G_SYNC_CFG : IF (HIP_SV = 0) GENERATE
      --Synchronise to pld side
      PROCESS (pld_clk, rstn)
      BEGIN
         IF (rstn = '0') THEN
            tl_cfg_ctl_wr_r <= '0';
            tl_cfg_ctl_wr_rr <= '0';
            tl_cfg_ctl_wr_rrr <= '0';
            tl_cfg_sts_wr_r <= '0';
            tl_cfg_sts_wr_rr <= '0';
            tl_cfg_sts_wr_rrr <= '0';
         ELSIF (pld_clk'EVENT AND pld_clk = '1') THEN
            tl_cfg_ctl_wr_r <= tl_cfg_ctl_wr;
            tl_cfg_ctl_wr_rr <= tl_cfg_ctl_wr_r;
            tl_cfg_ctl_wr_rrr <= tl_cfg_ctl_wr_rr;
            tl_cfg_sts_wr_r <= tl_cfg_sts_wr;
            tl_cfg_sts_wr_rr <= tl_cfg_sts_wr_r;
            tl_cfg_sts_wr_rrr <= tl_cfg_sts_wr_rr;
         END IF;
      END PROCESS;
   END GENERATE;

   G_NO_SYNC_CFG : IF (HIP_SV = 1) GENERATE
      tl_cfg_ctl_wr_r   <= '0';
      tl_cfg_ctl_wr_rr  <= '0';
      tl_cfg_ctl_wr_rrr <= '0';
      tl_cfg_sts_wr_r   <= '0';
      tl_cfg_sts_wr_rr  <= '0';
      tl_cfg_sts_wr_rrr <= '0';
   END GENERATE;

   --Configuration Demux logic
   PROCESS (pld_clk, rstn)
   BEGIN
      IF (rstn = '0') THEN
         cfg_busdev <= "0000000000000";
         cfg_devcsr <= "00000000000000000000000000000000";
         cfg_linkcsr <= "00000000000000000000000000000000";
         cfg_msicsr <= "0000000000000000";
         cfg_tcvcmap <= "000000000000000000000000";
         cfg_prmcsr <= "00000000000000000000000000000000";
         cfg_io_bas <= "00000000000000000000";
         cfg_io_lim <= "00000000000000000000";
         cfg_np_bas <= "000000000000";
         cfg_np_lim <= "000000000000";
         cfg_pr_bas <= "00000000000000000000000000000000000000000000";
         cfg_pr_lim <= "00000000000000000000000000000000000000000000";
      ELSIF (pld_clk'EVENT AND pld_clk = '1') THEN
         cfg_prmcsr(26 DOWNTO 25) <= "00";
         cfg_prmcsr(23 DOWNTO 16) <= "00000000";
         -- tl_cfg_sts sampling
         cfg_devcsr(31 DOWNTO 20) <= "000000000000";
         IF ((tl_cfg_sts_wr_rrr /= tl_cfg_sts_wr_rr) OR ( HIP_SV = 1 )) THEN
            cfg_devcsr(19 DOWNTO 16) <= tl_cfg_sts(52 DOWNTO 49);
            cfg_linkcsr(31 DOWNTO 16) <= tl_cfg_sts(46 DOWNTO 31);
            cfg_prmcsr(31 DOWNTO 27) <= tl_cfg_sts(29 DOWNTO 25);
            cfg_prmcsr(24) <= tl_cfg_sts(24);
         END IF;

         -- tl_cfg_ctl_sampling
         IF ((tl_cfg_ctl_wr_rrr /= tl_cfg_ctl_wr_rr) OR ( HIP_SV = 1 ))THEN
            IF (tl_cfg_add = "0000") THEN
               cfg_devcsr(15 DOWNTO 0) <= tl_cfg_ctl(31 DOWNTO 16);
            END IF;
            IF (tl_cfg_add = "0010") THEN
               cfg_linkcsr(15 DOWNTO 0) <= tl_cfg_ctl(31 DOWNTO 16);
            END IF;
            IF (tl_cfg_add = "0011") THEN
               cfg_prmcsr(15 DOWNTO 0) <= tl_cfg_ctl(23 DOWNTO 8);
            END IF;
            IF (tl_cfg_add = "0101") THEN
               cfg_io_bas <= tl_cfg_ctl(19 DOWNTO 0);
            END IF;
            IF (tl_cfg_add = "0110") THEN
               cfg_io_lim <= tl_cfg_ctl(19 DOWNTO 0);
            END IF;
            IF (tl_cfg_add = "0111") THEN
               cfg_np_bas <= tl_cfg_ctl(23 DOWNTO 12);
            END IF;
            IF (tl_cfg_add = "0111") THEN
               cfg_np_lim <= tl_cfg_ctl(11 DOWNTO 0);
            END IF;
            IF (tl_cfg_add = "1000") THEN
               cfg_pr_bas(31 DOWNTO 0) <= tl_cfg_ctl(31 DOWNTO 0);
            END IF;
            IF (tl_cfg_add = "1001") THEN
               cfg_pr_bas(43 DOWNTO 32) <= tl_cfg_ctl(11 DOWNTO 0);
            END IF;
            IF (tl_cfg_add = "1010") THEN
               cfg_pr_lim(31 DOWNTO 0) <= tl_cfg_ctl(31 DOWNTO 0);
            END IF;
            IF (tl_cfg_add = "1011") THEN
               cfg_pr_lim(43 DOWNTO 32) <= tl_cfg_ctl(11 DOWNTO 0);
            END IF;
            IF (tl_cfg_add = "1101") THEN
               cfg_msicsr(15 DOWNTO 0) <= tl_cfg_ctl(15 DOWNTO 0);
            END IF;
            IF (tl_cfg_add = "1110") THEN
               cfg_tcvcmap(23 DOWNTO 0) <= tl_cfg_ctl(23 DOWNTO 0);
            END IF;
            IF (tl_cfg_add = "1111") THEN
               cfg_busdev <= tl_cfg_ctl(12 DOWNTO 0);
            END IF;
         END IF;
      END IF;
   END PROCESS;

END ARCHITECTURE altpcie;
