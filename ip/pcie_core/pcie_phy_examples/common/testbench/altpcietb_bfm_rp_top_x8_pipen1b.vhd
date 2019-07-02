-------------------------------------------------------------------------------
-- Title         : PCI Express BFM with Root Port 
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcietb_bfm_rp_top_x8_pipen1b.vhd
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This entity is the entire PCI Ecpress Root Port BFM
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.altpcietb_bfm_shmem.all;

entity altpcietb_bfm_rp_top_x8_pipen1b is

  port (
    clk250_in        : in  std_logic;
    clk500_in        : in  std_logic;      
    local_rstn       : in  std_logic;
    pcie_rstn        : in  std_logic;
    swdn_out         : out std_logic_vector(5 downto 0);
    -- serdes interface
    rx_in0           : in  std_logic := '0';
    tx_out0          : out std_logic;
    rx_in1           : in  std_logic := '0';
    tx_out1          : out std_logic;
    rx_in2           : in  std_logic := '0';
    tx_out2          : out std_logic;
    rx_in3           : in  std_logic := '0';
    tx_out3          : out std_logic;
    rx_in4           : in  std_logic := '0';
    tx_out4          : out std_logic;
    rx_in5           : in  std_logic := '0';
    tx_out5          : out std_logic;
    rx_in6           : in  std_logic := '0';
    tx_out6          : out std_logic;
    rx_in7           : in  std_logic := '0';
    tx_out7          : out std_logic;
    -- PIPE not SERDES select signal
    pipe_mode        : in  std_logic;
    -- Debug Signals 
    test_in          : in  std_logic_vector(31 downto 0);
    test_out         : out std_logic_vector(511 downto 0);
    -- Pipe Interface Lane 0
    rate_ext      : out std_logic;
    txdata0_ext      : out std_logic_vector(7 downto 0);
    txdatak0_ext     : out std_logic;
    txdetectrx0_ext  : out std_logic;
    txelecidle0_ext  : out std_logic;
    txcompl0_ext     : out std_logic;
    rxpolarity0_ext  : out std_logic;
    powerdown0_ext   : out std_logic_vector(1 downto 0);
    rxdata0_ext      : in  std_logic_vector(7 downto 0);
    rxdatak0_ext     : in  std_logic;
    rxvalid0_ext     : in  std_logic;
    phystatus0_ext   : in  std_logic;
    rxelecidle0_ext  : in  std_logic;
    rxstatus0_ext    : in  std_logic_vector(2 downto 0);
    -- Pipe Interface Lane 1
    txdata1_ext      : out std_logic_vector(7 downto 0);
    txdatak1_ext     : out std_logic;
    txdetectrx1_ext  : out std_logic;
    txelecidle1_ext  : out std_logic;
    txcompl1_ext     : out std_logic;
    rxpolarity1_ext  : out std_logic;
    powerdown1_ext   : out std_logic_vector(1 downto 0);
    rxdata1_ext      : in  std_logic_vector(7 downto 0);
    rxdatak1_ext     : in  std_logic;
    rxvalid1_ext     : in  std_logic;
    phystatus1_ext   : in  std_logic;
    rxelecidle1_ext  : in  std_logic;
    rxstatus1_ext    : in  std_logic_vector(2 downto 0);
    -- Pipe Interface Lane 2
    txdata2_ext      : out std_logic_vector(7 downto 0);
    txdatak2_ext     : out std_logic;
    txdetectrx2_ext  : out std_logic;
    txelecidle2_ext  : out std_logic;
    txcompl2_ext     : out std_logic;
    rxpolarity2_ext  : out std_logic;
    powerdown2_ext   : out std_logic_vector(1 downto 0);
    rxdata2_ext      : in  std_logic_vector(7 downto 0);
    rxdatak2_ext     : in  std_logic;
    rxvalid2_ext     : in  std_logic;
    phystatus2_ext   : in  std_logic;
    rxelecidle2_ext  : in  std_logic;
    rxstatus2_ext    : in  std_logic_vector(2 downto 0);
    -- Pipe Interface Lane 3
    txdata3_ext      : out std_logic_vector(7 downto 0);
    txdatak3_ext     : out std_logic;
    txdetectrx3_ext  : out std_logic;
    txelecidle3_ext  : out std_logic;
    txcompl3_ext     : out std_logic;
    rxpolarity3_ext  : out std_logic;
    powerdown3_ext   : out std_logic_vector(1 downto 0);
    rxdata3_ext      : in  std_logic_vector(7 downto 0);
    rxdatak3_ext     : in  std_logic;
    rxvalid3_ext     : in  std_logic;
    phystatus3_ext   : in  std_logic;
    rxelecidle3_ext  : in  std_logic;
    rxstatus3_ext    : in  std_logic_vector(2 downto 0);
    -- Pipe Interface Lane 4
    txdata4_ext      : out std_logic_vector(7 downto 0);
    txdatak4_ext     : out std_logic;
    txdetectrx4_ext  : out std_logic;
    txelecidle4_ext  : out std_logic;
    txcompl4_ext     : out std_logic;
    rxpolarity4_ext  : out std_logic;
    powerdown4_ext   : out std_logic_vector(1 downto 0);
    rxdata4_ext      : in  std_logic_vector(7 downto 0);
    rxdatak4_ext     : in  std_logic;
    rxvalid4_ext     : in  std_logic;
    phystatus4_ext   : in  std_logic;
    rxelecidle4_ext  : in  std_logic;
    rxstatus4_ext    : in  std_logic_vector(2 downto 0);
    -- Pipe Interface Lane 5
    txdata5_ext      : out std_logic_vector(7 downto 0);
    txdatak5_ext     : out std_logic;
    txdetectrx5_ext  : out std_logic;
    txelecidle5_ext  : out std_logic;
    txcompl5_ext     : out std_logic;
    rxpolarity5_ext  : out std_logic;
    powerdown5_ext   : out std_logic_vector(1 downto 0);
    rxdata5_ext      : in  std_logic_vector(7 downto 0);
    rxdatak5_ext     : in  std_logic;
    rxvalid5_ext     : in  std_logic;
    phystatus5_ext   : in  std_logic;
    rxelecidle5_ext  : in  std_logic;
    rxstatus5_ext    : in  std_logic_vector(2 downto 0);
    -- Pipe Interface Lane 6
    txdata6_ext      : out std_logic_vector(7 downto 0);
    txdatak6_ext     : out std_logic;
    txdetectrx6_ext  : out std_logic;
    txelecidle6_ext  : out std_logic;
    txcompl6_ext     : out std_logic;
    rxpolarity6_ext  : out std_logic;
    powerdown6_ext   : out std_logic_vector(1 downto 0);
    rxdata6_ext      : in  std_logic_vector(7 downto 0);
    rxdatak6_ext     : in  std_logic;
    rxvalid6_ext     : in  std_logic;
    phystatus6_ext   : in  std_logic;
    rxelecidle6_ext  : in  std_logic;
    rxstatus6_ext    : in  std_logic_vector(2 downto 0);
    -- Pipe Interface Lane 7
    txdata7_ext      : out std_logic_vector(7 downto 0);
    txdatak7_ext     : out std_logic;
    txdetectrx7_ext  : out std_logic;
    txelecidle7_ext  : out std_logic;
    txcompl7_ext     : out std_logic;
    rxpolarity7_ext  : out std_logic;
    powerdown7_ext   : out std_logic_vector(1 downto 0);
    rxdata7_ext      : in  std_logic_vector(7 downto 0);
    rxdatak7_ext     : in  std_logic;
    rxvalid7_ext     : in  std_logic;
    phystatus7_ext   : in  std_logic;
    rxelecidle7_ext  : in  std_logic;
    rxstatus7_ext    : in  std_logic_vector(2 downto 0)
    );

end altpcietb_bfm_rp_top_x8_pipen1b;

architecture structural of altpcietb_bfm_rp_top_x8_pipen1b is

  component altpcietb_bfm_rpvar_64b_x8_pipen1b
  port (
    ep_clk250_in        : in  std_logic;
    pclk_in        : in  std_logic;
    coreclk_out        : out  std_logic;      
    npor             : in  std_logic;
    crst             : in  std_logic;
    srst             : in  std_logic;
    -- serdes interface
    rx_in0           : in  std_logic := '0';
    tx_out0          : out std_logic;
    rx_in1           : in  std_logic := '0';
    tx_out1          : out std_logic;
    rx_in2           : in  std_logic := '0';
    tx_out2          : out std_logic;
    rx_in3           : in  std_logic := '0';
    tx_out3          : out std_logic;
    rx_in4           : in  std_logic := '0';
    tx_out4          : out std_logic;
    rx_in5           : in  std_logic := '0';
    tx_out5          : out std_logic;
    rx_in6           : in  std_logic := '0';
    tx_out6          : out std_logic;
    rx_in7           : in  std_logic := '0';
    tx_out7          : out std_logic;

    -- PIPE not SERDES select signal
    pipe_mode        : in  std_logic;
    rate_ext        : out  std_logic;    
    -- Pipe Interface Lane 0 
    txdata0_ext      : out std_logic_vector(7 downto 0);
    txdatak0_ext     : out std_logic;
    txdetectrx0_ext  : out std_logic;
    txelecidle0_ext  : out std_logic;
    txcompl0_ext     : out std_logic;
    rxpolarity0_ext  : out std_logic;
    powerdown0_ext   : out std_logic_vector(1 downto 0);
    rxdata0_ext      : in  std_logic_vector(7 downto 0);
    rxdatak0_ext     : in  std_logic;
    rxvalid0_ext     : in  std_logic;
    phystatus0_ext   : in  std_logic;
    rxelecidle0_ext  : in  std_logic;
    rxstatus0_ext    : in  std_logic_vector(2 downto 0);
    -- Pipe Interface Lane 1
    txdata1_ext      : out std_logic_vector(7 downto 0);
    txdatak1_ext     : out std_logic;
    txdetectrx1_ext  : out std_logic;
    txelecidle1_ext  : out std_logic;
    txcompl1_ext     : out std_logic;
    rxpolarity1_ext  : out std_logic;
    powerdown1_ext   : out std_logic_vector(1 downto 0);
    rxdata1_ext      : in  std_logic_vector(7 downto 0);
    rxdatak1_ext     : in  std_logic;
    rxvalid1_ext     : in  std_logic;
    phystatus1_ext   : in  std_logic;
    rxelecidle1_ext  : in  std_logic;
    rxstatus1_ext    : in  std_logic_vector(2 downto 0);
    -- Pipe Interface Lane 2
    txdata2_ext      : out std_logic_vector(7 downto 0);
    txdatak2_ext     : out std_logic;
    txdetectrx2_ext  : out std_logic;
    txelecidle2_ext  : out std_logic;
    txcompl2_ext     : out std_logic;
    rxpolarity2_ext  : out std_logic;
    powerdown2_ext   : out std_logic_vector(1 downto 0);
    rxdata2_ext      : in  std_logic_vector(7 downto 0);
    rxdatak2_ext     : in  std_logic;
    rxvalid2_ext     : in  std_logic;
    phystatus2_ext   : in  std_logic;
    rxelecidle2_ext  : in  std_logic;
    rxstatus2_ext    : in  std_logic_vector(2 downto 0);
    -- Pipe Interface Lane 3
    txdata3_ext      : out std_logic_vector(7 downto 0);
    txdatak3_ext     : out std_logic;
    txdetectrx3_ext  : out std_logic;
    txelecidle3_ext  : out std_logic;
    txcompl3_ext     : out std_logic;
    rxpolarity3_ext  : out std_logic;
    powerdown3_ext   : out std_logic_vector(1 downto 0);
    rxdata3_ext      : in  std_logic_vector(7 downto 0);
    rxdatak3_ext     : in  std_logic;
    rxvalid3_ext     : in  std_logic;
    phystatus3_ext   : in  std_logic;
    rxelecidle3_ext  : in  std_logic;
    rxstatus3_ext    : in  std_logic_vector(2 downto 0);
    -- Pipe Interface Lane 4
    txdata4_ext      : out std_logic_vector(7 downto 0);
    txdatak4_ext     : out std_logic;
    txdetectrx4_ext  : out std_logic;
    txelecidle4_ext  : out std_logic;
    txcompl4_ext     : out std_logic;
    rxpolarity4_ext  : out std_logic;
    powerdown4_ext   : out std_logic_vector(1 downto 0);
    rxdata4_ext      : in  std_logic_vector(7 downto 0);
    rxdatak4_ext     : in  std_logic;
    rxvalid4_ext     : in  std_logic;
    phystatus4_ext   : in  std_logic;
    rxelecidle4_ext  : in  std_logic;
    rxstatus4_ext    : in  std_logic_vector(2 downto 0);
    -- Pipe Interface Lane 5
    txdata5_ext      : out std_logic_vector(7 downto 0);
    txdatak5_ext     : out std_logic;
    txdetectrx5_ext  : out std_logic;
    txelecidle5_ext  : out std_logic;
    txcompl5_ext     : out std_logic;
    rxpolarity5_ext  : out std_logic;
    powerdown5_ext   : out std_logic_vector(1 downto 0);
    rxdata5_ext      : in  std_logic_vector(7 downto 0);
    rxdatak5_ext     : in  std_logic;
    rxvalid5_ext     : in  std_logic;
    phystatus5_ext   : in  std_logic;
    rxelecidle5_ext  : in  std_logic;
    rxstatus5_ext    : in  std_logic_vector(2 downto 0);
    -- Pipe Interface Lane 6
    txdata6_ext      : out std_logic_vector(7 downto 0);
    txdatak6_ext     : out std_logic;
    txdetectrx6_ext  : out std_logic;
    txelecidle6_ext  : out std_logic;
    txcompl6_ext     : out std_logic;
    rxpolarity6_ext  : out std_logic;
    powerdown6_ext   : out std_logic_vector(1 downto 0);
    rxdata6_ext      : in  std_logic_vector(7 downto 0);
    rxdatak6_ext     : in  std_logic;
    rxvalid6_ext     : in  std_logic;
    phystatus6_ext   : in  std_logic;
    rxelecidle6_ext  : in  std_logic;
    rxstatus6_ext    : in  std_logic_vector(2 downto 0);
    -- Pipe Interface Lane 7
    txdata7_ext      : out std_logic_vector(7 downto 0);
    txdatak7_ext     : out std_logic;
    txdetectrx7_ext  : out std_logic;
    txelecidle7_ext  : out std_logic;
    txcompl7_ext     : out std_logic;
    rxpolarity7_ext  : out std_logic;
    powerdown7_ext   : out std_logic_vector(1 downto 0);
    rxdata7_ext      : in  std_logic_vector(7 downto 0);
    rxdatak7_ext     : in  std_logic;
    rxvalid7_ext     : in  std_logic;
    phystatus7_ext   : in  std_logic;
    rxelecidle7_ext  : in  std_logic;
    rxstatus7_ext    : in  std_logic_vector(2 downto 0);
    -- misc. signals
    test_in          : in  std_logic_vector(31 downto 0);
    test_out         : out std_logic_vector(511 downto 0);
    l2_exit          : out std_logic;
    hotrst_exit      : out std_logic;
    dlup_exit        : out std_logic;
    cpl_pending      : in  std_logic;
    cpl_err          : in  std_logic_vector(2 downto 0);
    pme_to_cr        : in  std_logic;
    pme_to_sr        : out std_logic;
    pm_auxpwr        : in  std_logic;
    slotcap_in       : in  std_logic_vector(6 downto 0);
    slotnum_in       : in  std_logic_vector(12 downto 0);  
    serr_out         : out std_logic;
    swdn_out         : out std_logic_vector(5 downto 0);
    app_int_sts      : in  std_logic;
    app_msi_req      : in  std_logic;
    app_msi_ack      : out std_logic;
    app_msi_tc       : in  std_logic_vector(2 downto 0);
    cfg_busdev       : out std_logic_vector(12 downto 0);
    cfg_prmcsr       : out std_logic_vector(31 downto 0);
    cfg_pmcsr        : out std_logic_vector(31 downto 0);
    cfg_msicsr       : out std_logic_vector(15 downto 0);
    cfg_devcsr       : out std_logic_vector(31 downto 0);
    cfg_linkcsr      : out std_logic_vector(31 downto 0);
    cfg_slotcsr      : out std_logic_vector(31 downto 0);
    cfg_rootcsr      : out std_logic_vector(31 downto 0);
    cfg_seccsr       : out std_logic_vector(31 downto 0);
    cfg_secbus       : out std_logic_vector(7 downto 0);
    cfg_subbus       : out std_logic_vector(7 downto 0);
    cfg_io_bas       : out std_logic_vector(19 downto 0);
    cfg_io_lim       : out std_logic_vector(19 downto 0);
    cfg_np_bas       : out std_logic_vector(11 downto 0);
    cfg_np_lim       : out std_logic_vector(11 downto 0);
    cfg_pr_bas       : out std_logic_vector(43 downto 0);
    cfg_pr_lim       : out std_logic_vector(43 downto 0);
    cfg_tcvcmap      : out std_logic_vector(23 downto 0);
    tx_cred0         : out std_logic_vector(21 downto 0);
    tx_cred1         : out std_logic_vector(21 downto 0);
    tx_cred2         : out std_logic_vector(21 downto 0);
    tx_cred3         : out std_logic_vector(21 downto 0);
    -- interface with the backend user's logic vc0
    rx_req0          : out std_logic;
    rx_ack0          : in  std_logic;
    rx_abort0        : in  std_logic;
    rx_retry0        : in  std_logic;
    rx_mask0         : in  std_logic;
    rx_desc0         : out std_logic_vector(135 downto 0);
    rx_ws0           : in  std_logic;
    rx_data0         : out std_logic_vector(63 downto 0);
    rx_be0           : out std_logic_vector(7 downto 0);
    rx_dv0           : out std_logic;
    rx_dfr0          : out std_logic;
    tx_req0          : in  std_logic;
    tx_desc0         : in  std_logic_vector(127 downto 0);
    tx_ack0          : out std_logic;
    tx_dfr0          : in  std_logic;
    tx_data0         : in  std_logic_vector(63 downto 0);
    tx_dv0           : in  std_logic;
    tx_err0          : in  std_logic;
    tx_ws0           : out std_logic;
    -- interface with the backend user's logic vc1
    rx_req1          : out std_logic;
    rx_ack1          : in  std_logic;
    rx_abort1        : in  std_logic;
    rx_retry1        : in  std_logic;
    rx_mask1         : in  std_logic;
    rx_desc1         : out std_logic_vector(135 downto 0);
    rx_ws1           : in  std_logic;
    rx_data1         : out std_logic_vector(63 downto 0);
    rx_be1           : out std_logic_vector(7 downto 0);
    rx_dv1           : out std_logic;
    rx_dfr1          : out std_logic;
    tx_req1          : in  std_logic;
    tx_desc1         : in  std_logic_vector(127 downto 0);
    tx_ack1          : out std_logic;
    tx_dfr1          : in  std_logic;
    tx_data1         : in  std_logic_vector(63 downto 0);
    tx_dv1           : in  std_logic;
    tx_err1          : in  std_logic;
    tx_ws1           : out std_logic;
    -- interface with the backend user's logic vc2
    rx_req2          : out std_logic;
    rx_ack2          : in  std_logic;
    rx_abort2        : in  std_logic;
    rx_retry2        : in  std_logic;
    rx_mask2         : in  std_logic;
    rx_desc2         : out std_logic_vector(135 downto 0);
    rx_ws2           : in  std_logic;
    rx_data2         : out std_logic_vector(63 downto 0);
    rx_be2           : out std_logic_vector(7 downto 0);
    rx_dv2           : out std_logic;
    rx_dfr2          : out std_logic;
    tx_req2          : in  std_logic;
    tx_desc2         : in  std_logic_vector(127 downto 0);
    tx_ack2          : out std_logic;
    tx_dfr2          : in  std_logic;
    tx_data2         : in  std_logic_vector(63 downto 0);
    tx_dv2           : in  std_logic;
    tx_err2          : in  std_logic;
    tx_ws2           : out std_logic;
    -- interface with the backend user's logic vc3
    rx_req3          : out std_logic;
    rx_ack3          : in  std_logic;
    rx_abort3        : in  std_logic;
    rx_retry3        : in  std_logic;
    rx_mask3         : in  std_logic;
    rx_desc3         : out std_logic_vector(135 downto 0);
    rx_ws3           : in  std_logic;
    rx_data3         : out std_logic_vector(63 downto 0);
    rx_be3           : out std_logic_vector(7 downto 0);
    rx_dv3           : out std_logic;
    rx_dfr3          : out std_logic;
    tx_req3          : in  std_logic;
    tx_desc3         : in  std_logic_vector(127 downto 0);
    tx_ack3          : out std_logic;
    tx_dfr3          : in  std_logic;
    tx_data3         : in  std_logic_vector(63 downto 0);
    tx_dv3           : in  std_logic;
    tx_err3          : in  std_logic;
    tx_ws3           : out std_logic );
  end component;

  component altpcietb_bfm_vc_intf
  generic (
      VC_NUM : natural);
  port (
    -- Interface signals with Root Port Model
    -- General 
    clk_in        : in  std_logic;
    rstn          : in  std_logic;
    -- Rx Interface
    rx_req        : in  std_logic;
    rx_ack        : out std_logic;
    rx_abort      : out std_logic;
    rx_retry      : out std_logic;
    rx_mask       : out std_logic;
    rx_desc       : in  std_logic_vector(135 downto 0);
    rx_ws         : out std_logic;
    rx_data       : in  std_logic_vector(63 downto 0);
    rx_be         : in  std_logic_vector(7 downto 0);
    rx_dv         : in  std_logic;
    rx_dfr        : in  std_logic;
    -- Tx Interface
    tx_cred       : in  std_logic_vector(21 downto 0);
    tx_req        : out std_logic;
    tx_desc       : out std_logic_vector(127 downto 0);
    tx_ack        : in  std_logic;
    tx_dfr        : out std_logic;
    tx_data       : out std_logic_vector(63 downto 0);
    tx_dv         : out std_logic;
    tx_err        : out std_logic;
    tx_ws         : in  std_logic;
    -- Config space interface
    cfg_io_bas    : in  std_logic_vector(19 downto 0);
    cfg_np_bas    : in  std_logic_vector(11 downto 0);
    cfg_pr_bas    : in  std_logic_vector(43 downto 0)
    );
  end component;

  -- Signal tied to 0
  signal GND_BUS         : std_logic_vector(127 downto 0) ;

  -- Internal Interface Signals
  -- misc. signals
  signal l2_exit          : std_logic;
  signal hotrst_exit      : std_logic;
  signal dlup_exit        : std_logic;
  signal cpl_pending      : std_logic;
  signal cpl_err          : std_logic_vector(2 downto 0);
  signal pme_to_cr        : std_logic;
  signal pme_to_sr        : std_logic;
  signal pm_auxpwr        : std_logic;
  signal slotcap_in       : std_logic_vector(6 downto 0);
  signal slotnum_in       : std_logic_vector(12 downto 0);  
  signal serr_out         : std_logic;
  signal app_int_sts      : std_logic;
  signal app_msi_req      : std_logic;
  signal app_msi_ack      : std_logic;
  signal app_msi_tc       : std_logic_vector(2 downto 0);
  signal cfg_busdev       : std_logic_vector(12 downto 0);
  signal cfg_prmcsr       : std_logic_vector(31 downto 0);
  signal cfg_pmcsr        : std_logic_vector(31 downto 0);
  signal cfg_msicsr       : std_logic_vector(15 downto 0);
  signal cfg_devcsr       : std_logic_vector(31 downto 0);
  signal cfg_linkcsr      : std_logic_vector(31 downto 0);
  signal cfg_slotcsr      : std_logic_vector(31 downto 0);
  signal cfg_rootcsr      : std_logic_vector(31 downto 0);
  signal cfg_seccsr       : std_logic_vector(31 downto 0);
  signal cfg_secbus       : std_logic_vector(7 downto 0);
  signal cfg_subbus       : std_logic_vector(7 downto 0);
  signal cfg_io_bas       : std_logic_vector(19 downto 0);
  signal cfg_io_lim       : std_logic_vector(19 downto 0);
  signal cfg_np_bas       : std_logic_vector(11 downto 0);
  signal cfg_np_lim       : std_logic_vector(11 downto 0);
  signal cfg_pr_bas       : std_logic_vector(43 downto 0);
  signal cfg_pr_lim       : std_logic_vector(43 downto 0);
  signal cfg_tcvcmap      : std_logic_vector(23 downto 0);
  signal tx_cred0         : std_logic_vector(21 downto 0);
  signal tx_cred1         : std_logic_vector(21 downto 0);
  signal tx_cred2         : std_logic_vector(21 downto 0);
  signal tx_cred3         : std_logic_vector(21 downto 0);
  -- interface with the backend user's logic vc0
  signal rx_req0          : std_logic;
  signal rx_ack0          : std_logic;
  signal rx_abort0        : std_logic;
  signal rx_retry0        : std_logic;
  signal rx_mask0         : std_logic;
  signal rx_desc0         : std_logic_vector(135 downto 0);
  signal rx_ws0           : std_logic;
  signal rx_data0         : std_logic_vector(63 downto 0);
  signal rx_be0           : std_logic_vector(7 downto 0);
  signal rx_dv0           : std_logic;
  signal rx_dfr0          : std_logic;
  signal tx_req0          : std_logic;
  signal tx_desc0         : std_logic_vector(127 downto 0);
  signal tx_ack0          : std_logic;
  signal tx_dfr0          : std_logic;
  signal tx_data0         : std_logic_vector(63 downto 0);
  signal tx_dv0           : std_logic;
  signal tx_err0          : std_logic;
  signal tx_ws0           : std_logic;
  -- interface with the backend user's logic vc1
  signal rx_req1          : std_logic;
  signal rx_ack1          : std_logic;
  signal rx_abort1        : std_logic;
  signal rx_retry1        : std_logic;
  signal rx_mask1         : std_logic;
  signal rx_desc1         : std_logic_vector(135 downto 0);
  signal rx_ws1           : std_logic;
  signal rx_data1         : std_logic_vector(63 downto 0);
  signal rx_be1           : std_logic_vector(7 downto 0);
  signal rx_dv1           : std_logic;
  signal rx_dfr1          : std_logic;
  signal tx_req1          : std_logic;
  signal tx_desc1         : std_logic_vector(127 downto 0);
  signal tx_ack1          : std_logic;
  signal tx_dfr1          : std_logic;
  signal tx_data1         : std_logic_vector(63 downto 0);
  signal tx_dv1           : std_logic;
  signal tx_err1          : std_logic;
  signal tx_ws1           : std_logic;
  -- interface with the backend user's logic vc2
  signal rx_req2          : std_logic;
  signal rx_ack2          : std_logic;
  signal rx_abort2        : std_logic;
  signal rx_retry2        : std_logic;
  signal rx_mask2         : std_logic;
  signal rx_desc2         : std_logic_vector(135 downto 0);
  signal rx_ws2           : std_logic;
  signal rx_data2         : std_logic_vector(63 downto 0);
  signal rx_be2           : std_logic_vector(7 downto 0);
  signal rx_dv2           : std_logic;
  signal rx_dfr2          : std_logic;
  signal tx_req2          : std_logic;
  signal tx_desc2         : std_logic_vector(127 downto 0);
  signal tx_ack2          : std_logic;
  signal tx_dfr2          : std_logic;
  signal tx_data2         : std_logic_vector(63 downto 0);
  signal tx_dv2           : std_logic;
  signal tx_err2          : std_logic;
  signal tx_ws2           : std_logic;
  -- interface with the backend user's logic vc3
  signal rx_req3          : std_logic;
  signal rx_ack3          : std_logic;
  signal rx_abort3        : std_logic;
  signal rx_retry3        : std_logic;
  signal rx_mask3         : std_logic;
  signal rx_desc3         : std_logic_vector(135 downto 0);
  signal rx_ws3           : std_logic;
  signal rx_data3         : std_logic_vector(63 downto 0);
  signal rx_be3           : std_logic_vector(7 downto 0);
  signal rx_dv3           : std_logic;
  signal rx_dfr3          : std_logic;
  signal tx_req3          : std_logic;
  signal tx_desc3         : std_logic_vector(127 downto 0);
  signal tx_ack3          : std_logic;
  signal tx_dfr3          : std_logic;
  signal tx_data3         : std_logic_vector(63 downto 0);
  signal tx_dv3           : std_logic;
  signal tx_err3          : std_logic;
  signal tx_ws3           : std_logic;

  -- Resets
  signal rsnt_cnt         : std_logic_vector (24 downto 0);
  signal rstn             : std_logic;
  signal npor             : std_logic;
  signal crst             : std_logic;
  signal srst             : std_logic;
  signal coreclk_out             : std_logic;

  signal clk_in             : std_logic;
  signal rate_internal       : std_logic;  
 
begin  -- structural

  GND_BUS <= (others => '0') ;
  clk_in <= coreclk_out when (pipe_mode = '0') else
          clk500_in when (rate_internal = '1') else clk250_in;
  rate_ext <= rate_internal;

  
  -------------------------------------------------------------------------------
  --  Reset and POR management
  -------------------------------------------------------------------------------  
  process (clk250_in, pcie_rstn)
  begin
    if pcie_rstn = '0' then
      rsnt_cnt <= (others => '0');
      rstn     <= '0';
    elsif rising_edge (clk250_in) then
      if rsnt_cnt /= "1110111001101011001010000" then
        rsnt_cnt <= rsnt_cnt + 1;
      end if;
      if local_rstn = '0' or l2_exit = '0' or hotrst_exit = '0'or dlup_exit = '0' then
        rstn <= '0';
        -- synthesis translate_off
      elsif (test_in(0) = '1' and rsnt_cnt = "0000000000000000000100000") then
        rstn <= '1';
        -- synthesis translate_on       
      elsif rsnt_cnt = "1110111001101011001010000" then
        rstn <= '1';
      end if;
    end if;
  end process;

  npor <= pcie_rstn and local_rstn;
  srst <= not(hotrst_exit and l2_exit and dlup_exit and rstn);
  -- Root Port Mode doesn't do a configuration reset on a dlup_exit
  crst <= not(hotrst_exit and l2_exit and rstn);

  cpl_pending <= '0' ;
  cpl_err     <= "000" ;
  pm_auxpwr   <= '0' ;
  slotcap_in  <= "0000000" ;
  slotnum_in  <= "0000000000000" ;
  app_int_sts <= '0' ;
  app_msi_req <= '0' ;  
  app_msi_tc  <= "000" ;

  rp : altpcietb_bfm_rpvar_64b_x8_pipen1b
  port map (
    pclk_in => clk_in,
    ep_clk250_in        => clk250_in,
    coreclk_out        => coreclk_out,    
    npor             => npor,
    crst             => crst,
    srst             => srst,
    -- serdes interface
    rx_in0           => rx_in0,
    tx_out0          => tx_out0,
    rx_in1           => rx_in1,
    tx_out1          => tx_out1,
    rx_in2           => rx_in2,
    tx_out2          => tx_out2,
    rx_in3           => rx_in3,
    tx_out3          => tx_out3,
    rx_in4           => rx_in4,
    tx_out4          => tx_out4,
    rx_in5           => rx_in5,
    tx_out5          => tx_out5,
    rx_in6           => rx_in6,
    tx_out6          => tx_out6,
    rx_in7           => rx_in7,
    tx_out7          => tx_out7,
    -- PIPE not SERDES select signal
    pipe_mode        => pipe_mode,
    rate_ext        => rate_internal,    
    -- Pipe Interface Lane 0 
    txdata0_ext      => txdata0_ext,
    txdatak0_ext     => txdatak0_ext,
    txdetectrx0_ext  => txdetectrx0_ext,
    txelecidle0_ext  => txelecidle0_ext,
    txcompl0_ext     => txcompl0_ext,
    rxpolarity0_ext  => rxpolarity0_ext,
    powerdown0_ext   => powerdown0_ext,
    rxdata0_ext      => rxdata0_ext,
    rxdatak0_ext     => rxdatak0_ext,
    rxvalid0_ext     => rxvalid0_ext,
    phystatus0_ext   => phystatus0_ext,
    rxelecidle0_ext  => rxelecidle0_ext,
    rxstatus0_ext    => rxstatus0_ext,
    -- Pipe Interface Lane 1
    txdata1_ext      => txdata1_ext,
    txdatak1_ext     => txdatak1_ext,
    txdetectrx1_ext  => txdetectrx1_ext,
    txelecidle1_ext  => txelecidle1_ext,
    txcompl1_ext     => txcompl1_ext,
    rxpolarity1_ext  => rxpolarity1_ext,
    powerdown1_ext   => powerdown1_ext,
    rxdata1_ext      => rxdata1_ext,
    rxdatak1_ext     => rxdatak1_ext,
    rxvalid1_ext     => rxvalid1_ext,
    phystatus1_ext   => phystatus1_ext,
    rxelecidle1_ext  => rxelecidle1_ext,
    rxstatus1_ext    => rxstatus1_ext,
    -- Pipe Interface Lane 2
    txdata2_ext      => txdata2_ext,
    txdatak2_ext     => txdatak2_ext,
    txdetectrx2_ext  => txdetectrx2_ext,
    txelecidle2_ext  => txelecidle2_ext,
    txcompl2_ext     => txcompl2_ext,
    rxpolarity2_ext  => rxpolarity2_ext,
    powerdown2_ext   => powerdown2_ext,
    rxdata2_ext      => rxdata2_ext,
    rxdatak2_ext     => rxdatak2_ext,
    rxvalid2_ext     => rxvalid2_ext,
    phystatus2_ext   => phystatus2_ext,
    rxelecidle2_ext  => rxelecidle2_ext,
    rxstatus2_ext    => rxstatus2_ext,
    -- Pipe Interface Lane 3
    txdata3_ext      => txdata3_ext,
    txdatak3_ext     => txdatak3_ext,
    txdetectrx3_ext  => txdetectrx3_ext,
    txelecidle3_ext  => txelecidle3_ext,
    txcompl3_ext     => txcompl3_ext,
    rxpolarity3_ext  => rxpolarity3_ext,
    powerdown3_ext   => powerdown3_ext,
    rxdata3_ext      => rxdata3_ext,
    rxdatak3_ext     => rxdatak3_ext,
    rxvalid3_ext     => rxvalid3_ext,
    phystatus3_ext   => phystatus3_ext,
    rxelecidle3_ext  => rxelecidle3_ext,
    rxstatus3_ext    => rxstatus3_ext,
    -- Pipe Interface Lane 4
    txdata4_ext      => txdata4_ext,
    txdatak4_ext     => txdatak4_ext,
    txdetectrx4_ext  => txdetectrx4_ext,
    txelecidle4_ext  => txelecidle4_ext,
    txcompl4_ext     => txcompl4_ext,
    rxpolarity4_ext  => rxpolarity4_ext,
    powerdown4_ext   => powerdown4_ext,
    rxdata4_ext      => rxdata4_ext,
    rxdatak4_ext     => rxdatak4_ext,
    rxvalid4_ext     => rxvalid4_ext,
    phystatus4_ext   => phystatus4_ext,
    rxelecidle4_ext  => rxelecidle4_ext,
    rxstatus4_ext    => rxstatus4_ext,
    -- Pipe Interface Lane 5
    txdata5_ext      => txdata5_ext,
    txdatak5_ext     => txdatak5_ext,
    txdetectrx5_ext  => txdetectrx5_ext,
    txelecidle5_ext  => txelecidle5_ext,
    txcompl5_ext     => txcompl5_ext,
    rxpolarity5_ext  => rxpolarity5_ext,
    powerdown5_ext   => powerdown5_ext,
    rxdata5_ext      => rxdata5_ext,
    rxdatak5_ext     => rxdatak5_ext,
    rxvalid5_ext     => rxvalid5_ext,
    phystatus5_ext   => phystatus5_ext,
    rxelecidle5_ext  => rxelecidle5_ext,
    rxstatus5_ext    => rxstatus5_ext,
    -- Pipe Interface Lane 6
    txdata6_ext      => txdata6_ext,
    txdatak6_ext     => txdatak6_ext,
    txdetectrx6_ext  => txdetectrx6_ext,
    txelecidle6_ext  => txelecidle6_ext,
    txcompl6_ext     => txcompl6_ext,
    rxpolarity6_ext  => rxpolarity6_ext,
    powerdown6_ext   => powerdown6_ext,
    rxdata6_ext      => rxdata6_ext,
    rxdatak6_ext     => rxdatak6_ext,
    rxvalid6_ext     => rxvalid6_ext,
    phystatus6_ext   => phystatus6_ext,
    rxelecidle6_ext  => rxelecidle6_ext,
    rxstatus6_ext    => rxstatus6_ext,
    -- Pipe Interface Lane 7
    txdata7_ext      => txdata7_ext,
    txdatak7_ext     => txdatak7_ext,
    txdetectrx7_ext  => txdetectrx7_ext,
    txelecidle7_ext  => txelecidle7_ext,
    txcompl7_ext     => txcompl7_ext,
    rxpolarity7_ext  => rxpolarity7_ext,
    powerdown7_ext   => powerdown7_ext,
    rxdata7_ext      => rxdata7_ext,
    rxdatak7_ext     => rxdatak7_ext,
    rxvalid7_ext     => rxvalid7_ext,
    phystatus7_ext   => phystatus7_ext,
    rxelecidle7_ext  => rxelecidle7_ext,
    rxstatus7_ext    => rxstatus7_ext,
    -- misc. signals
    test_in          => test_in,
    test_out         => test_out,
    l2_exit          => l2_exit,
    hotrst_exit      => hotrst_exit,
    dlup_exit        => dlup_exit,
    cpl_pending      => cpl_pending,
    cpl_err          => cpl_err,
    pme_to_cr        => pme_to_cr,
    pme_to_sr        => pme_to_cr,
    pm_auxpwr        => pm_auxpwr,
    slotcap_in       => slotcap_in,
    slotnum_in       => slotnum_in,
    serr_out         => serr_out,
    swdn_out         => swdn_out,
    app_int_sts      => app_int_sts,
    app_msi_req      => app_msi_req,
    app_msi_ack      => app_msi_ack,
    app_msi_tc       => app_msi_tc,
    cfg_busdev       => cfg_busdev,
    cfg_prmcsr       => cfg_prmcsr,
    cfg_pmcsr        => cfg_pmcsr,
    cfg_msicsr       => cfg_msicsr,
    cfg_devcsr       => cfg_devcsr,
    cfg_linkcsr      => cfg_linkcsr,
    cfg_slotcsr      => cfg_slotcsr,
    cfg_rootcsr      => cfg_rootcsr,
    cfg_seccsr       => cfg_seccsr,
    cfg_secbus       => cfg_secbus,
    cfg_subbus       => cfg_subbus,
    cfg_io_bas       => cfg_io_bas,
    cfg_io_lim       => cfg_io_lim,
    cfg_np_bas       => cfg_np_bas,
    cfg_np_lim       => cfg_np_lim,
    cfg_pr_bas       => cfg_pr_bas,
    cfg_pr_lim       => cfg_pr_lim,
    cfg_tcvcmap      => cfg_tcvcmap,
    tx_cred0         => tx_cred0,
    tx_cred1         => tx_cred1,
    tx_cred2         => tx_cred2,
    tx_cred3         => tx_cred3,
    -- interface with the backend user's logic vc0
    rx_req0          => rx_req0,
    rx_ack0          => rx_ack0,
    rx_abort0        => rx_abort0,
    rx_retry0        => rx_retry0,
    rx_mask0         => rx_mask0,
    rx_desc0         => rx_desc0,
    rx_ws0           => rx_ws0,
    rx_data0         => rx_data0,
    rx_be0           => rx_be0,
    rx_dv0           => rx_dv0,
    rx_dfr0          => rx_dfr0,
    tx_req0          => tx_req0,
    tx_desc0         => tx_desc0,
    tx_ack0          => tx_ack0,
    tx_dfr0          => tx_dfr0,
    tx_data0         => tx_data0,
    tx_dv0           => tx_dv0,
    tx_err0          => tx_err0,
    tx_ws0           => tx_ws0,
    -- interface with the backend user's logic vc1
    rx_req1          => rx_req1,
    rx_ack1          => rx_ack1,
    rx_abort1        => rx_abort1,
    rx_retry1        => rx_retry1,
    rx_mask1         => rx_mask1,
    rx_desc1         => rx_desc1,
    rx_ws1           => rx_ws1,
    rx_data1         => rx_data1,
    rx_be1           => rx_be1,
    rx_dv1           => rx_dv1,
    rx_dfr1          => rx_dfr1,
    tx_req1          => tx_req1,
    tx_desc1         => tx_desc1,
    tx_ack1          => tx_ack1,
    tx_dfr1          => tx_dfr1,
    tx_data1         => tx_data1,
    tx_dv1           => tx_dv1,
    tx_err1          => tx_err1,
    tx_ws1           => tx_ws1,
    -- interface with the backend user's logic vc2
    rx_req2          => rx_req2,
    rx_ack2          => rx_ack2,
    rx_abort2        => rx_abort2,
    rx_retry2        => rx_retry2,
    rx_mask2         => rx_mask2,
    rx_desc2         => rx_desc2,
    rx_ws2           => rx_ws2,
    rx_data2         => rx_data2,
    rx_be2           => rx_be2,
    rx_dv2           => rx_dv2,
    rx_dfr2          => rx_dfr2,
    tx_req2          => tx_req2,
    tx_desc2         => tx_desc2,
    tx_ack2          => tx_ack2,
    tx_dfr2          => tx_dfr2,
    tx_data2         => tx_data2,
    tx_dv2           => tx_dv2,
    tx_err2          => tx_err2,
    tx_ws2           => tx_ws2,
    -- interface with the backend user's logic vc3
    rx_req3          => rx_req3,
    rx_ack3          => rx_ack3,
    rx_abort3        => rx_abort3,
    rx_retry3        => rx_retry3,
    rx_mask3         => rx_mask3,
    rx_desc3         => rx_desc3,
    rx_ws3           => rx_ws3,
    rx_data3         => rx_data3,
    rx_be3           => rx_be3,
    rx_dv3           => rx_dv3,
    rx_dfr3          => rx_dfr3,
    tx_req3          => tx_req3,
    tx_desc3         => tx_desc3,
    tx_ack3          => tx_ack3,
    tx_dfr3          => tx_dfr3,
    tx_data3         => tx_data3,
    tx_dv3           => tx_dv3,
    tx_err3          => tx_err3,
    tx_ws3           => tx_ws3 );


  vc0 : altpcietb_bfm_vc_intf
    generic map (
      VC_NUM => 0)
    
  port map (
    -- Interface signals with Root Port Model
    -- General 
    clk_in        => clk_in,
    rstn          => rstn,
    -- Rx Interface
    rx_req        => rx_req0,
    rx_ack        => rx_ack0,
    rx_abort      => rx_abort0,
    rx_retry      => rx_retry0,
    rx_mask       => rx_mask0,
    rx_desc       => rx_desc0,
    rx_ws         => rx_ws0,
    rx_data       => rx_data0,
    rx_be         => rx_be0,
    rx_dv         => rx_dv0,
    rx_dfr        => rx_dfr0,
    -- Tx Interface
    tx_cred       => tx_cred0,
    tx_req        => tx_req0,
    tx_desc       => tx_desc0,
    tx_ack        => tx_ack0,
    tx_dfr        => tx_dfr0,
    tx_data       => tx_data0,
    tx_dv         => tx_dv0,
    tx_err        => tx_err0,
    tx_ws         => tx_ws0,
    -- Config space interface
    cfg_io_bas    => cfg_io_bas,
    cfg_np_bas    => cfg_np_bas,
    cfg_pr_bas    => cfg_pr_bas
    );

  vc1 : altpcietb_bfm_vc_intf
    generic map (
      VC_NUM => 1)
    
  port map (
    -- Interface signals with Root Port Model
    -- General 
    clk_in        => clk_in,
    rstn          => rstn,
    -- Rx Interface
    rx_req        => rx_req1,
    rx_ack        => rx_ack1,
    rx_abort      => rx_abort1,
    rx_retry      => rx_retry1,
    rx_mask       => rx_mask1,
    rx_desc       => rx_desc1,
    rx_ws         => rx_ws1,
    rx_data       => rx_data1,
    rx_be         => rx_be1,
    rx_dv         => rx_dv1,
    rx_dfr        => rx_dfr1,
    -- Tx Interface
    tx_cred       => tx_cred1,
    tx_req        => tx_req1,
    tx_desc       => tx_desc1,
    tx_ack        => tx_ack1,
    tx_dfr        => tx_dfr1,
    tx_data       => tx_data1,
    tx_dv         => tx_dv1,
    tx_err        => tx_err1,
    tx_ws         => tx_ws1,
    -- Config space interface
    cfg_io_bas    => cfg_io_bas,
    cfg_np_bas    => cfg_np_bas,
    cfg_pr_bas    => cfg_pr_bas
    );

  vc2 : altpcietb_bfm_vc_intf
    generic map (
      VC_NUM => 2)
    
  port map (
    -- Interface signals with Root Port Model
    -- General 
    clk_in        => clk_in,
    rstn          => rstn,
    -- Rx Interface
    rx_req        => rx_req2,
    rx_ack        => rx_ack2,
    rx_abort      => rx_abort2,
    rx_retry      => rx_retry2,
    rx_mask       => rx_mask2,
    rx_desc       => rx_desc2,
    rx_ws         => rx_ws2,
    rx_data       => rx_data2,
    rx_be         => rx_be2,
    rx_dv         => rx_dv2,
    rx_dfr        => rx_dfr2,
    -- Tx Interface
    tx_cred       => tx_cred2,
    tx_req        => tx_req2,
    tx_desc       => tx_desc2,
    tx_ack        => tx_ack2,
    tx_dfr        => tx_dfr2,
    tx_data       => tx_data2,
    tx_dv         => tx_dv2,
    tx_err        => tx_err2,
    tx_ws         => tx_ws2,
    -- Config space interface
    cfg_io_bas    => cfg_io_bas,
    cfg_np_bas    => cfg_np_bas,
    cfg_pr_bas    => cfg_pr_bas
    );

  vc3 : altpcietb_bfm_vc_intf
    generic map (
      VC_NUM => 3)
    
  port map (
    -- Interface signals with Root Port Model
    -- General 
    clk_in        => clk_in,
    rstn          => rstn,
    -- Rx Interface
    rx_req        => rx_req3,
    rx_ack        => rx_ack3,
    rx_abort      => rx_abort3,
    rx_retry      => rx_retry3,
    rx_mask       => rx_mask3,
    rx_desc       => rx_desc3,
    rx_ws         => rx_ws3,
    rx_data       => rx_data3,
    rx_be         => rx_be3,
    rx_dv         => rx_dv3,
    rx_dfr        => rx_dfr3,
    -- Tx Interface
    tx_cred       => tx_cred3,
    tx_req        => tx_req3,
    tx_desc       => tx_desc3,
    tx_ack        => tx_ack3,
    tx_dfr        => tx_dfr3,
    tx_data       => tx_data3,
    tx_dv         => tx_dv3,
    tx_err        => tx_err3,
    tx_ws         => tx_ws3,
    -- Config space interface
    cfg_io_bas    => cfg_io_bas,
    cfg_np_bas    => cfg_np_bas,
    cfg_pr_bas    => cfg_pr_bas
    );


end structural;
