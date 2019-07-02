-------------------------------------------------------------------------------
-- Title         : PCI Express LTSSM monitor
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcietb_ltssm_mon.vhd
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This function interconnects two PIPE MAC interfaces for a single lane.
-- For now this uses a common PCLK for both interfaces, an enhancement woudl be
-- to support separate PCLK's for each interface with the requisite elastic
-- buffer.
-------------------------------------------------------------------------------
-- Copyright (c) 2005 Altera Corporation. All rights reserved.  Altera products are
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
library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use std.textio.all;
use ieee.numeric_std.all;
use work.altpcietb_bfm_constants.all;
use work.altpcietb_bfm_log.all;
use work.altpcietb_bfm_req_intf.all;
use work.altpcietb_bfm_shmem.all;
use work.altpcietb_bfm_rdwr.all;

entity altpcietb_ltssm_mon is
  port (
    signal rp_clk          : in std_logic;
    signal rstn            : in std_logic;
    signal rp_ltssm        : in std_logic_vector(4 downto 0);
    signal ep_ltssm          : in std_logic_vector(4 downto 0);
    signal dummy_out          : out std_logic
    );

end altpcietb_ltssm_mon;


architecture structural of altpcietb_ltssm_mon is

  -- purpose: decodes LTSSM to english
  procedure conv_ltssm (
    constant device : std_logic;
    constant ltssm : std_logic_vector(4 downto 0)
    ) is
    variable ltssm_str : string(23 downto 1);
  begin
    case ltssm is
      when "00000" => ltssm_str := "DETECT.QUIET           ";
      when "00001" => ltssm_str := "DETECT.ACTIVE          ";
      when "00010" => ltssm_str := "POLLING.ACTIVE         ";
      when "00011" => ltssm_str := "POLLING.COMPLIANCE     ";
      when "00100" => ltssm_str := "POLLING.CONFIG         ";
      when "00110" => ltssm_str := "CONFIG.LINKWIDTH.START ";
      when "00111" => ltssm_str := "CONFIG.LINKWIDTH.ACCEPT";
      when "01000" => ltssm_str := "CONFIG.LANENUM.ACCEPT  ";
      when "01001" => ltssm_str := "CONFIG.LANENUM.WAIT    ";
      when "01010" => ltssm_str := "CONFIG.COMPLETE        ";
      when "01011" => ltssm_str := "CONFIG.IDLE            ";
      when "01100" => ltssm_str := "RECOVERY.RCVRLOCK      ";
      when "01101" => ltssm_str := "RECOVERY.RCVRCFG       ";
      when "01110" => ltssm_str := "RECOVERY.IDLE          ";
      when "01111" => ltssm_str := "L0                     ";
      when "10000" => ltssm_str := "DISABLE                ";
      when "10001" => ltssm_str := "LOOPBACK.ENTRY         ";
      when "10010" => ltssm_str := "LOOPBACK.ACTIVE        ";
      when "10011" => ltssm_str := "LOOPBACK.EXIT          ";
      when "10100" => ltssm_str := "HOT RESET              ";
      when "10101" => ltssm_str := "L0s                    ";
      when "10110" => ltssm_str := "L1.ENTRY               ";
      when "10111" => ltssm_str := "L1.IDLE                ";
      when "11000" => ltssm_str := "L2.IDLE                ";
      when "11001" => ltssm_str := "L2.TRANSMITWAKE        ";
      when "11010" => ltssm_str := "RECOVERY.SPEED         ";
      when others => ltssm_str :=  "UNKNOWN                ";
    end case;
    if device = '0' then
      ebfm_display(EBFM_MSG_INFO," RP LTSSM State: " & ltssm_str);
    else
      ebfm_display(EBFM_MSG_INFO," EP LTSSM State: " & ltssm_str);
    end if;
  end  procedure conv_ltssm;

  signal rp_ltssm_r :  STD_LOGIC_VECTOR (4 DOWNTO 0);
  signal ep_ltssm_r :  STD_LOGIC_VECTOR (4 DOWNTO 0);
  signal detect_cnt :  STD_LOGIC_VECTOR (3 DOWNTO 0);

begin

  process(rp_clk)
  begin
    rp_ltssm_r <= rp_ltssm;
    ep_ltssm_r <= ep_ltssm;
    if rp_ltssm /= rp_ltssm_r then
      conv_ltssm('0',rp_ltssm);
    end if;
    if ep_ltssm /= ep_ltssm_r then
      conv_ltssm('1',ep_ltssm);
    end if;
  end process;

  -- Time-out if LTSSM goes back to detect.quiet more than 8 times without going to L0
  process (rstn, rp_clk)
  begin
     if (rstn = '0') then
        detect_cnt <= (others=>'0');
     elsif (rp_clk'event and rp_clk = '0') then
        if (rp_ltssm /= rp_ltssm_r)  then
           if (detect_cnt = "1000") then
              ebfm_display(EBFM_MSG_ERROR_FATAL," LTSSM does not change from DETECT.QUIET");
           elsif (rp_ltssm = "01111") then
              detect_cnt <= (others=>'0');
           elsif (rp_ltssm = "00000") then
              detect_cnt <= detect_cnt+"0001";
           end if;
        end if;
     end if;
  end process;

end structural;
