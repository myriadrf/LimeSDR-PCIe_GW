-------------------------------------------------------------------------------
-- Title         : PCI Express PIPE PHY connector
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcietb_rst_clk.vhd
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

entity altpcietb_rst_clk is
  port (
    signal ref_clk_sel_code : in  std_logic_vector(3 downto 0);
    signal ref_clk_out      : out std_logic;
    signal ep_core_clk_out      : in std_logic;
    signal pcie_rstn        : out std_logic;
    signal rp_rstn          : out std_logic
    );

end altpcietb_rst_clk;


architecture structural of altpcietb_rst_clk is

  -- purpose: computes the half period for difference freq selection
  function cal_half_period (
    constant ref_clk_sel_code : std_logic_vector(3 downto 0))
    return time is
    variable half_period : time;
  begin  -- payload_code
    case ref_clk_sel_code is
      when "0000" => half_period := 5000 ps;  -- 100    MHz
      when "0001" => half_period := 4000 ps;  -- 125    MHz
      when "0010" => half_period := 3200 ps;  -- 156.25 MHz
      when "0011" => half_period := 2000 ps;  -- 250    MHz
      when others => half_period := 5000 ps;  -- 100 MHz
    end case;
    return half_period;
  end function cal_half_period;

  signal ref_clk : std_logic;
  
  
begin
  ref_clk_out <= ref_clk;
  process
  begin
    ref_clk <= '0';
    loop
      wait for cal_half_period(ref_clk_sel_code);
      ref_clk <= not ref_clk;
    end loop;
  end process;
  PROCESS
  BEGIN
    pcie_rstn <= '1';
    rp_rstn <= '0';    
    wait for 1 ns;
    pcie_rstn <= '0';
    rp_rstn <= '0';    
    wait for 200 ns;    
    pcie_rstn <= '1';
    wait for 100 ns;
    rp_rstn <= '1';
    WAIT;
  END PROCESS;

end structural;
