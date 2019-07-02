--Legal Notice: (C)2019 Altera Corporation. All rights reserved.  Your
--use of Altera Corporation's design tools, logic functions and other
--software and tools, and its AMPP partner logic functions, and any
--output files any of the foregoing (including device programming or
--simulation files), and any associated documentation or information are
--expressly subject to the terms and conditions of the Altera Program
--License Subscription Agreement or other applicable license agreement,
--including, without limitation, that your use is for the sole purpose
--of programming logic devices manufactured by Altera and sold by Altera
--or its authorized distributors.  Please refer to the applicable
--agreement for further details.


-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--/** This VHDL file is used for simulation in chaining DMA design example
--*
--* This file is the top level of the testbench
--*/
entity pcie_phy_chaining_testbench is 
        generic (
                 FAST_COUNTERS : std_logic := '1';
                 NUM_CONNECTED_LANES : std_logic_vector := "1000";
                 PIPE_MODE_SIM : std_logic := '1';
                 TEST_LEVEL : natural := 1
                 );
end entity pcie_phy_chaining_testbench;


architecture europa of pcie_phy_chaining_testbench is
  component altpcietb_bfm_rp_top_x8_pipen1b is
PORT (
    signal tx_out6 : OUT STD_LOGIC;
        signal tx_out4 : OUT STD_LOGIC;
        signal txdatak4_ext : OUT STD_LOGIC;
        signal txelecidle0_ext : OUT STD_LOGIC;
        signal txdatak1_ext : OUT STD_LOGIC;
        signal test_out : OUT STD_LOGIC_VECTOR (511 DOWNTO 0);
        signal txelecidle2_ext : OUT STD_LOGIC;
        signal txdatak7_ext : OUT STD_LOGIC;
        signal txdatak2_ext : OUT STD_LOGIC;
        signal txcompl4_ext : OUT STD_LOGIC;
        signal rxpolarity5_ext : OUT STD_LOGIC;
        signal rxpolarity4_ext : OUT STD_LOGIC;
        signal powerdown7_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal txdetectrx7_ext : OUT STD_LOGIC;
        signal txelecidle1_ext : OUT STD_LOGIC;
        signal tx_out3 : OUT STD_LOGIC;
        signal rxpolarity3_ext : OUT STD_LOGIC;
        signal txdata0_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal txdetectrx1_ext : OUT STD_LOGIC;
        signal powerdown0_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal txdata1_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal txdatak6_ext : OUT STD_LOGIC;
        signal txdata3_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal txcompl7_ext : OUT STD_LOGIC;
        signal txdata4_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal powerdown3_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal txcompl5_ext : OUT STD_LOGIC;
        signal txcompl0_ext : OUT STD_LOGIC;
        signal txdetectrx5_ext : OUT STD_LOGIC;
        signal txcompl1_ext : OUT STD_LOGIC;
        signal powerdown1_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal txelecidle7_ext : OUT STD_LOGIC;
        signal swdn_out : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
        signal txelecidle6_ext : OUT STD_LOGIC;
        signal tx_out0 : OUT STD_LOGIC;
        signal powerdown6_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal rxpolarity0_ext : OUT STD_LOGIC;
        signal tx_out2 : OUT STD_LOGIC;
        signal txdetectrx2_ext : OUT STD_LOGIC;
        signal txdata5_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal txelecidle3_ext : OUT STD_LOGIC;
        signal txdatak3_ext : OUT STD_LOGIC;
        signal txdetectrx0_ext : OUT STD_LOGIC;
        signal rxpolarity6_ext : OUT STD_LOGIC;
        signal powerdown2_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal rate_ext : OUT STD_LOGIC;
        signal txcompl3_ext : OUT STD_LOGIC;
        signal txdetectrx6_ext : OUT STD_LOGIC;
        signal tx_out5 : OUT STD_LOGIC;
        signal rxpolarity2_ext : OUT STD_LOGIC;
        signal tx_out7 : OUT STD_LOGIC;
        signal tx_out1 : OUT STD_LOGIC;
        signal txdetectrx3_ext : OUT STD_LOGIC;
        signal txdata6_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal txcompl2_ext : OUT STD_LOGIC;
        signal rxpolarity1_ext : OUT STD_LOGIC;
        signal txelecidle4_ext : OUT STD_LOGIC;
        signal txdata2_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal powerdown4_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal txcompl6_ext : OUT STD_LOGIC;
        signal txdatak5_ext : OUT STD_LOGIC;
        signal txdata7_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal txdatak0_ext : OUT STD_LOGIC;
        signal rxpolarity7_ext : OUT STD_LOGIC;
        signal powerdown5_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal txdetectrx4_ext : OUT STD_LOGIC;
        signal txelecidle5_ext : OUT STD_LOGIC;
        signal rxdata4_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rx_in7 : IN STD_LOGIC;
        signal phystatus5_ext : IN STD_LOGIC;
        signal rxdata5_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal phystatus1_ext : IN STD_LOGIC;
        signal pipe_mode : IN STD_LOGIC;
        signal rxstatus3_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal pcie_rstn : IN STD_LOGIC;
        signal rxelecidle7_ext : IN STD_LOGIC;
        signal rxelecidle0_ext : IN STD_LOGIC;
        signal clk500_in : IN STD_LOGIC;
        signal rxelecidle3_ext : IN STD_LOGIC;
        signal rxdatak1_ext : IN STD_LOGIC;
        signal phystatus0_ext : IN STD_LOGIC;
        signal rx_in0 : IN STD_LOGIC;
        signal rx_in5 : IN STD_LOGIC;
        signal rxelecidle5_ext : IN STD_LOGIC;
        signal rxvalid1_ext : IN STD_LOGIC;
        signal rx_in2 : IN STD_LOGIC;
        signal rx_in3 : IN STD_LOGIC;
        signal rxdatak3_ext : IN STD_LOGIC;
        signal clk250_in : IN STD_LOGIC;
        signal phystatus6_ext : IN STD_LOGIC;
        signal rxdata6_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rxdata3_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rxstatus5_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal rxstatus1_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal rxdata0_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rxvalid7_ext : IN STD_LOGIC;
        signal phystatus7_ext : IN STD_LOGIC;
        signal rxdata2_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rxvalid5_ext : IN STD_LOGIC;
        signal rxvalid0_ext : IN STD_LOGIC;
        signal rxdatak2_ext : IN STD_LOGIC;
        signal rxstatus4_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal rxdatak7_ext : IN STD_LOGIC;
        signal rxstatus0_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal phystatus3_ext : IN STD_LOGIC;
        signal rxelecidle4_ext : IN STD_LOGIC;
        signal phystatus2_ext : IN STD_LOGIC;
        signal rxvalid4_ext : IN STD_LOGIC;
        signal rx_in6 : IN STD_LOGIC;
        signal rx_in1 : IN STD_LOGIC;
        signal rxstatus2_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal rxdata7_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rxdatak0_ext : IN STD_LOGIC;
        signal rxelecidle1_ext : IN STD_LOGIC;
        signal rxdata1_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rxstatus6_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal test_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal rx_in4 : IN STD_LOGIC;
        signal rxdatak4_ext : IN STD_LOGIC;
        signal rxelecidle2_ext : IN STD_LOGIC;
        signal rxdatak5_ext : IN STD_LOGIC;
        signal rxstatus7_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal rxelecidle6_ext : IN STD_LOGIC;
        signal rxvalid3_ext : IN STD_LOGIC;
        signal rxvalid2_ext : IN STD_LOGIC;
        signal phystatus4_ext : IN STD_LOGIC;
        signal rxvalid6_ext : IN STD_LOGIC;
        signal local_rstn : IN STD_LOGIC;
        signal rxdatak6_ext : IN STD_LOGIC
      );
  end component altpcietb_bfm_rp_top_x8_pipen1b;
  component altpcietb_bfm_driver_chaining is
GENERIC (
      TEST_LEVEL : NATURAL
      );
    PORT (
    signal dummy_out : OUT STD_LOGIC;
        signal INTB : IN STD_LOGIC;
        signal INTA : IN STD_LOGIC;
        signal clk_in : IN STD_LOGIC;
        signal INTC : IN STD_LOGIC;
        signal INTD : IN STD_LOGIC;
        signal rstn : IN STD_LOGIC
      );
  end component altpcietb_bfm_driver_chaining;
  component altpcietb_ltssm_mon is
PORT (
    signal dummy_out : OUT STD_LOGIC;
        signal rp_clk : IN STD_LOGIC;
        signal ep_ltssm : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal rstn : IN STD_LOGIC;
        signal rp_ltssm : IN STD_LOGIC_VECTOR (4 DOWNTO 0)
      );
  end component altpcietb_ltssm_mon;
  component pcie_phy_example_chaining_pipen1b is
PORT (
    signal lane_width_code : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal txcompl1_ext : OUT STD_LOGIC;
        signal clk500_out : OUT STD_LOGIC;
        signal txelecidle0_ext : OUT STD_LOGIC;
        signal txdatak1_ext : OUT STD_LOGIC;
        signal ref_clk_sel_code : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal txelecidle2_ext : OUT STD_LOGIC;
        signal txdatak2_ext : OUT STD_LOGIC;
        signal tx_out0 : OUT STD_LOGIC;
        signal rxpolarity0_ext : OUT STD_LOGIC;
        signal clk250_out : OUT STD_LOGIC;
        signal tx_out2 : OUT STD_LOGIC;
        signal txelecidle3_ext : OUT STD_LOGIC;
        signal txdatak3_ext : OUT STD_LOGIC;
        signal rate_ext : OUT STD_LOGIC;
        signal txcompl3_ext : OUT STD_LOGIC;
        signal txelecidle1_ext : OUT STD_LOGIC;
        signal powerdown_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal tx_out3 : OUT STD_LOGIC;
        signal core_clk_out : OUT STD_LOGIC;
        signal rxpolarity2_ext : OUT STD_LOGIC;
        signal tx_out1 : OUT STD_LOGIC;
        signal rxpolarity3_ext : OUT STD_LOGIC;
        signal txdata0_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal txcompl2_ext : OUT STD_LOGIC;
        signal phy_sel_code : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal rxpolarity1_ext : OUT STD_LOGIC;
        signal txdata1_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal txdata2_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal txdata3_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal txdatak0_ext : OUT STD_LOGIC;
        signal txdetectrx_ext : OUT STD_LOGIC;
        signal test_out_icm : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
        signal txcompl0_ext : OUT STD_LOGIC;
        signal rxdatak2_ext : IN STD_LOGIC;
        signal pipe_mode : IN STD_LOGIC;
        signal rxstatus3_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal pcie_rstn : IN STD_LOGIC;
        signal refclk : IN STD_LOGIC;
        signal rxstatus0_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal rxelecidle0_ext : IN STD_LOGIC;
        signal pld_clk : IN STD_LOGIC;
        signal rxelecidle3_ext : IN STD_LOGIC;
        signal rx_in1 : IN STD_LOGIC;
        signal rxstatus2_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal rxdatak1_ext : IN STD_LOGIC;
        signal rx_in0 : IN STD_LOGIC;
        signal pclk_in : IN STD_LOGIC;
        signal rxdatak0_ext : IN STD_LOGIC;
        signal rxelecidle1_ext : IN STD_LOGIC;
        signal rxdata1_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rxvalid1_ext : IN STD_LOGIC;
        signal rx_in2 : IN STD_LOGIC;
        signal rx_in3 : IN STD_LOGIC;
        signal rxdatak3_ext : IN STD_LOGIC;
        signal test_in : IN STD_LOGIC_VECTOR (39 DOWNTO 0);
        signal phystatus_ext : IN STD_LOGIC;
        signal rxdata3_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rxelecidle2_ext : IN STD_LOGIC;
        signal rxstatus1_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal rxdata0_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rxvalid3_ext : IN STD_LOGIC;
        signal rxvalid2_ext : IN STD_LOGIC;
        signal free_100MHz : IN STD_LOGIC;
        signal rxdata2_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal local_rstn : IN STD_LOGIC;
        signal rxvalid0_ext : IN STD_LOGIC
      );
  end component pcie_phy_example_chaining_pipen1b;
  component altpcietb_bfm_log_common is
PORT (
    signal dummy_out : OUT STD_LOGIC
      );
  end component altpcietb_bfm_log_common;
  component altpcietb_bfm_req_intf_common is
PORT (
    signal dummy_out : OUT STD_LOGIC
      );
  end component altpcietb_bfm_req_intf_common;
  component altpcietb_bfm_shmem_common is
PORT (
    signal dummy_out : OUT STD_LOGIC
      );
  end component altpcietb_bfm_shmem_common;
  component altpcietb_pipe_phy is
GENERIC (
      APIPE_WIDTH : NATURAL;
        BPIPE_WIDTH : NATURAL;
        LANE_NUM : NATURAL
      );
    PORT (
    signal A_rxvalid : OUT STD_LOGIC;
        signal A_rxstatus : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal B_phystatus : OUT STD_LOGIC;
        signal B_rxvalid : OUT STD_LOGIC;
        signal A_rxdatak : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal B_rxelecidle : OUT STD_LOGIC;
        signal B_rxdatak : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal A_rxdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal B_rxdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal A_rxelecidle : OUT STD_LOGIC;
        signal A_phystatus : OUT STD_LOGIC;
        signal B_rxstatus : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal B_powerdown : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal A_txdatak : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal pipe_mode : IN STD_LOGIC;
        signal A_powerdown : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal B_txcompl : IN STD_LOGIC;
        signal B_lane_conn : IN STD_LOGIC;
        signal B_txdetectrx : IN STD_LOGIC;
        signal pclk_a : IN STD_LOGIC;
        signal B_txelecidle : IN STD_LOGIC;
        signal A_lane_conn : IN STD_LOGIC;
        signal resetn : IN STD_LOGIC;
        signal A_txdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal B_rate : IN STD_LOGIC;
        signal A_txcompl : IN STD_LOGIC;
        signal pclk_b : IN STD_LOGIC;
        signal A_txelecidle : IN STD_LOGIC;
        signal A_txdetectrx : IN STD_LOGIC;
        signal A_rxpolarity : IN STD_LOGIC;
        signal B_txdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal B_rxpolarity : IN STD_LOGIC;
        signal B_txdatak : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
        signal A_rate : IN STD_LOGIC
      );
  end component altpcietb_pipe_phy;
  component altpcietb_rst_clk is
PORT (
    signal rp_rstn : OUT STD_LOGIC;
        signal pcie_rstn : OUT STD_LOGIC;
        signal ref_clk_out : OUT STD_LOGIC;
        signal ep_core_clk_out : IN STD_LOGIC;
        signal ref_clk_sel_code : IN STD_LOGIC_VECTOR (3 DOWNTO 0)
      );
  end component altpcietb_rst_clk;
                signal bfm_log_common_dummy_out :  STD_LOGIC;
                signal bfm_req_intf_common_dummy_out :  STD_LOGIC;
                signal bfm_shmem_common_dummy_out :  STD_LOGIC;
                signal connected_bits :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal connected_lanes :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal dummy_out :  STD_LOGIC;
                signal ep_clk250_out :  STD_LOGIC;
                signal ep_clk500_out :  STD_LOGIC;
                signal ep_clk_out :  STD_LOGIC;
                signal ep_core_clk_out :  STD_LOGIC;
                signal ep_ltssm :  STD_LOGIC_VECTOR (4 DOWNTO 0);
                signal ep_pclk_in :  STD_LOGIC;
                signal ep_pld_clk :  STD_LOGIC;
                signal gnd_powerdown4_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal gnd_powerdown5_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal gnd_powerdown6_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal gnd_powerdown7_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal gnd_rp_rx_in4 :  STD_LOGIC;
                signal gnd_rp_rx_in5 :  STD_LOGIC;
                signal gnd_rp_rx_in6 :  STD_LOGIC;
                signal gnd_rp_rx_in7 :  STD_LOGIC;
                signal gnd_rxpolarity4_ext :  STD_LOGIC;
                signal gnd_rxpolarity5_ext :  STD_LOGIC;
                signal gnd_rxpolarity6_ext :  STD_LOGIC;
                signal gnd_rxpolarity7_ext :  STD_LOGIC;
                signal gnd_txcompl4_ext :  STD_LOGIC;
                signal gnd_txcompl5_ext :  STD_LOGIC;
                signal gnd_txcompl6_ext :  STD_LOGIC;
                signal gnd_txcompl7_ext :  STD_LOGIC;
                signal gnd_txdata4_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal gnd_txdata5_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal gnd_txdata6_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal gnd_txdata7_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal gnd_txdatak4_ext :  STD_LOGIC;
                signal gnd_txdatak5_ext :  STD_LOGIC;
                signal gnd_txdatak6_ext :  STD_LOGIC;
                signal gnd_txdatak7_ext :  STD_LOGIC;
                signal gnd_txdetectrx4_ext :  STD_LOGIC;
                signal gnd_txdetectrx5_ext :  STD_LOGIC;
                signal gnd_txdetectrx6_ext :  STD_LOGIC;
                signal gnd_txdetectrx7_ext :  STD_LOGIC;
                signal gnd_txelecidle4_ext :  STD_LOGIC;
                signal gnd_txelecidle5_ext :  STD_LOGIC;
                signal gnd_txelecidle6_ext :  STD_LOGIC;
                signal gnd_txelecidle7_ext :  STD_LOGIC;
                signal lane_width_code :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal local_rstn :  STD_LOGIC;
                signal ltssm_dummy_out :  STD_LOGIC;
                signal open_phystatus4_ext :  STD_LOGIC;
                signal open_phystatus5_ext :  STD_LOGIC;
                signal open_phystatus6_ext :  STD_LOGIC;
                signal open_phystatus7_ext :  STD_LOGIC;
                signal open_rp_tx_out4 :  STD_LOGIC;
                signal open_rp_tx_out5 :  STD_LOGIC;
                signal open_rp_tx_out6 :  STD_LOGIC;
                signal open_rp_tx_out7 :  STD_LOGIC;
                signal open_rxdata4_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal open_rxdata5_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal open_rxdata6_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal open_rxdata7_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal open_rxdatak4_ext :  STD_LOGIC;
                signal open_rxdatak5_ext :  STD_LOGIC;
                signal open_rxdatak6_ext :  STD_LOGIC;
                signal open_rxdatak7_ext :  STD_LOGIC;
                signal open_rxelecidle4_ext :  STD_LOGIC;
                signal open_rxelecidle5_ext :  STD_LOGIC;
                signal open_rxelecidle6_ext :  STD_LOGIC;
                signal open_rxelecidle7_ext :  STD_LOGIC;
                signal open_rxstatus4_ext :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal open_rxstatus5_ext :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal open_rxstatus6_ext :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal open_rxstatus7_ext :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal open_rxvalid4_ext :  STD_LOGIC;
                signal open_rxvalid5_ext :  STD_LOGIC;
                signal open_rxvalid6_ext :  STD_LOGIC;
                signal open_rxvalid7_ext :  STD_LOGIC;
                signal pcie_rstn :  STD_LOGIC;
                signal phy_sel_code :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal phystatus0_ext :  STD_LOGIC;
                signal phystatus1_ext :  STD_LOGIC;
                signal phystatus2_ext :  STD_LOGIC;
                signal phystatus3_ext :  STD_LOGIC;
                signal pipe_mode :  STD_LOGIC;
                signal pipe_mode_sig2 :  STD_LOGIC;
                signal powerdown0_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerdown1_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerdown2_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerdown3_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal rate_ext :  STD_LOGIC;
                signal ref_clk_sel_code :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal refclk :  STD_LOGIC;
                signal rp_ltssm :  STD_LOGIC_VECTOR (4 DOWNTO 0);
                signal rp_pclk :  STD_LOGIC;
                signal rp_phystatus0_ext :  STD_LOGIC;
                signal rp_phystatus1_ext :  STD_LOGIC;
                signal rp_phystatus2_ext :  STD_LOGIC;
                signal rp_phystatus3_ext :  STD_LOGIC;
                signal rp_phystatus4_ext :  STD_LOGIC;
                signal rp_phystatus5_ext :  STD_LOGIC;
                signal rp_phystatus6_ext :  STD_LOGIC;
                signal rp_phystatus7_ext :  STD_LOGIC;
                signal rp_powerdown0_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal rp_powerdown1_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal rp_powerdown2_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal rp_powerdown3_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal rp_powerdown4_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal rp_powerdown5_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal rp_powerdown6_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal rp_powerdown7_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal rp_rate :  STD_LOGIC;
                signal rp_rstn :  STD_LOGIC;
                signal rp_rx_in0 :  STD_LOGIC;
                signal rp_rx_in1 :  STD_LOGIC;
                signal rp_rx_in2 :  STD_LOGIC;
                signal rp_rx_in3 :  STD_LOGIC;
                signal rp_rxdata0_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rp_rxdata1_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rp_rxdata2_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rp_rxdata3_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rp_rxdata4_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rp_rxdata5_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rp_rxdata6_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rp_rxdata7_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rp_rxdatak0_ext :  STD_LOGIC;
                signal rp_rxdatak1_ext :  STD_LOGIC;
                signal rp_rxdatak2_ext :  STD_LOGIC;
                signal rp_rxdatak3_ext :  STD_LOGIC;
                signal rp_rxdatak4_ext :  STD_LOGIC;
                signal rp_rxdatak5_ext :  STD_LOGIC;
                signal rp_rxdatak6_ext :  STD_LOGIC;
                signal rp_rxdatak7_ext :  STD_LOGIC;
                signal rp_rxelecidle0_ext :  STD_LOGIC;
                signal rp_rxelecidle1_ext :  STD_LOGIC;
                signal rp_rxelecidle2_ext :  STD_LOGIC;
                signal rp_rxelecidle3_ext :  STD_LOGIC;
                signal rp_rxelecidle4_ext :  STD_LOGIC;
                signal rp_rxelecidle5_ext :  STD_LOGIC;
                signal rp_rxelecidle6_ext :  STD_LOGIC;
                signal rp_rxelecidle7_ext :  STD_LOGIC;
                signal rp_rxpolarity0_ext :  STD_LOGIC;
                signal rp_rxpolarity1_ext :  STD_LOGIC;
                signal rp_rxpolarity2_ext :  STD_LOGIC;
                signal rp_rxpolarity3_ext :  STD_LOGIC;
                signal rp_rxpolarity4_ext :  STD_LOGIC;
                signal rp_rxpolarity5_ext :  STD_LOGIC;
                signal rp_rxpolarity6_ext :  STD_LOGIC;
                signal rp_rxpolarity7_ext :  STD_LOGIC;
                signal rp_rxstatus0_ext :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal rp_rxstatus1_ext :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal rp_rxstatus2_ext :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal rp_rxstatus3_ext :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal rp_rxstatus4_ext :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal rp_rxstatus5_ext :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal rp_rxstatus6_ext :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal rp_rxstatus7_ext :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal rp_rxvalid0_ext :  STD_LOGIC;
                signal rp_rxvalid1_ext :  STD_LOGIC;
                signal rp_rxvalid2_ext :  STD_LOGIC;
                signal rp_rxvalid3_ext :  STD_LOGIC;
                signal rp_rxvalid4_ext :  STD_LOGIC;
                signal rp_rxvalid5_ext :  STD_LOGIC;
                signal rp_rxvalid6_ext :  STD_LOGIC;
                signal rp_rxvalid7_ext :  STD_LOGIC;
                signal rp_test_in :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal rp_test_out :  STD_LOGIC_VECTOR (511 DOWNTO 0);
                signal rp_tx_out0 :  STD_LOGIC;
                signal rp_tx_out1 :  STD_LOGIC;
                signal rp_tx_out2 :  STD_LOGIC;
                signal rp_tx_out3 :  STD_LOGIC;
                signal rp_txcompl0_ext :  STD_LOGIC;
                signal rp_txcompl1_ext :  STD_LOGIC;
                signal rp_txcompl2_ext :  STD_LOGIC;
                signal rp_txcompl3_ext :  STD_LOGIC;
                signal rp_txcompl4_ext :  STD_LOGIC;
                signal rp_txcompl5_ext :  STD_LOGIC;
                signal rp_txcompl6_ext :  STD_LOGIC;
                signal rp_txcompl7_ext :  STD_LOGIC;
                signal rp_txdata0_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rp_txdata1_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rp_txdata2_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rp_txdata3_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rp_txdata4_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rp_txdata5_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rp_txdata6_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rp_txdata7_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rp_txdatak0_ext :  STD_LOGIC;
                signal rp_txdatak1_ext :  STD_LOGIC;
                signal rp_txdatak2_ext :  STD_LOGIC;
                signal rp_txdatak3_ext :  STD_LOGIC;
                signal rp_txdatak4_ext :  STD_LOGIC;
                signal rp_txdatak5_ext :  STD_LOGIC;
                signal rp_txdatak6_ext :  STD_LOGIC;
                signal rp_txdatak7_ext :  STD_LOGIC;
                signal rp_txdetectrx0_ext :  STD_LOGIC;
                signal rp_txdetectrx1_ext :  STD_LOGIC;
                signal rp_txdetectrx2_ext :  STD_LOGIC;
                signal rp_txdetectrx3_ext :  STD_LOGIC;
                signal rp_txdetectrx4_ext :  STD_LOGIC;
                signal rp_txdetectrx5_ext :  STD_LOGIC;
                signal rp_txdetectrx6_ext :  STD_LOGIC;
                signal rp_txdetectrx7_ext :  STD_LOGIC;
                signal rp_txelecidle0_ext :  STD_LOGIC;
                signal rp_txelecidle1_ext :  STD_LOGIC;
                signal rp_txelecidle2_ext :  STD_LOGIC;
                signal rp_txelecidle3_ext :  STD_LOGIC;
                signal rp_txelecidle4_ext :  STD_LOGIC;
                signal rp_txelecidle5_ext :  STD_LOGIC;
                signal rp_txelecidle6_ext :  STD_LOGIC;
                signal rp_txelecidle7_ext :  STD_LOGIC;
                signal rx_in0 :  STD_LOGIC;
                signal rx_in1 :  STD_LOGIC;
                signal rx_in2 :  STD_LOGIC;
                signal rx_in3 :  STD_LOGIC;
                signal rxdata0_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rxdata1_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rxdata2_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rxdata3_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rxdatak0_ext :  STD_LOGIC;
                signal rxdatak1_ext :  STD_LOGIC;
                signal rxdatak2_ext :  STD_LOGIC;
                signal rxdatak3_ext :  STD_LOGIC;
                signal rxelecidle0_ext :  STD_LOGIC;
                signal rxelecidle1_ext :  STD_LOGIC;
                signal rxelecidle2_ext :  STD_LOGIC;
                signal rxelecidle3_ext :  STD_LOGIC;
                signal rxpolarity0_ext :  STD_LOGIC;
                signal rxpolarity1_ext :  STD_LOGIC;
                signal rxpolarity2_ext :  STD_LOGIC;
                signal rxpolarity3_ext :  STD_LOGIC;
                signal rxstatus0_ext :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal rxstatus1_ext :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal rxstatus2_ext :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal rxstatus3_ext :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal rxvalid0_ext :  STD_LOGIC;
                signal rxvalid1_ext :  STD_LOGIC;
                signal rxvalid2_ext :  STD_LOGIC;
                signal rxvalid3_ext :  STD_LOGIC;
                signal swdn_out :  STD_LOGIC_VECTOR (5 DOWNTO 0);
                signal test_in :  STD_LOGIC_VECTOR (39 DOWNTO 0);
                signal test_out :  STD_LOGIC_VECTOR (8 DOWNTO 0);
                signal tx_out0 :  STD_LOGIC;
                signal tx_out1 :  STD_LOGIC;
                signal tx_out2 :  STD_LOGIC;
                signal tx_out3 :  STD_LOGIC;
                signal txcompl0_ext :  STD_LOGIC;
                signal txcompl1_ext :  STD_LOGIC;
                signal txcompl2_ext :  STD_LOGIC;
                signal txcompl3_ext :  STD_LOGIC;
                signal txdata0_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal txdata1_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal txdata2_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal txdata3_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal txdatak0_ext :  STD_LOGIC;
                signal txdatak1_ext :  STD_LOGIC;
                signal txdatak2_ext :  STD_LOGIC;
                signal txdatak3_ext :  STD_LOGIC;
                signal txdetectrx0_ext :  STD_LOGIC;
                signal txdetectrx1_ext :  STD_LOGIC;
                signal txdetectrx2_ext :  STD_LOGIC;
                signal txdetectrx3_ext :  STD_LOGIC;
                signal txelecidle0_ext :  STD_LOGIC;
                signal txelecidle1_ext :  STD_LOGIC;
                signal txelecidle2_ext :  STD_LOGIC;
                signal txelecidle3_ext :  STD_LOGIC;

begin

  gnd_rp_rx_in4 <= std_logic'('1');
  gnd_rp_rx_in5 <= std_logic'('1');
  gnd_rp_rx_in6 <= std_logic'('1');
  gnd_rp_rx_in7 <= std_logic'('1');
  ep_ltssm <= test_out(4 DOWNTO 0);
  rp_ltssm <= rp_test_out(324 DOWNTO 320);
  gnd_txdata4_ext <= std_logic_vector'("00000000");
  gnd_txdatak4_ext <= std_logic'('0');
  gnd_txdetectrx4_ext <= std_logic'('0');
  gnd_txelecidle4_ext <= std_logic'('0');
  gnd_rxpolarity4_ext <= std_logic'('0');
  gnd_txcompl4_ext <= std_logic'('0');
  gnd_powerdown4_ext <= std_logic_vector'("00");
  gnd_txdata5_ext <= std_logic_vector'("00000000");
  gnd_txdatak5_ext <= std_logic'('0');
  gnd_txdetectrx5_ext <= std_logic'('0');
  gnd_txelecidle5_ext <= std_logic'('0');
  gnd_rxpolarity5_ext <= std_logic'('0');
  gnd_txcompl5_ext <= std_logic'('0');
  gnd_powerdown5_ext <= std_logic_vector'("00");
  gnd_txdata6_ext <= std_logic_vector'("00000000");
  gnd_txdatak6_ext <= std_logic'('0');
  gnd_txdetectrx6_ext <= std_logic'('0');
  gnd_txelecidle6_ext <= std_logic'('0');
  gnd_rxpolarity6_ext <= std_logic'('0');
  gnd_txcompl6_ext <= std_logic'('0');
  gnd_powerdown6_ext <= std_logic_vector'("00");
  gnd_txdata7_ext <= std_logic_vector'("00000000");
  gnd_txdatak7_ext <= std_logic'('0');
  gnd_txdetectrx7_ext <= std_logic'('0');
  gnd_txelecidle7_ext <= std_logic'('0');
  gnd_rxpolarity7_ext <= std_logic'('0');
  gnd_txcompl7_ext <= std_logic'('0');
  gnd_powerdown7_ext <= std_logic_vector'("00");
  txdetectrx1_ext <= txdetectrx0_ext;
  powerdown1_ext <= powerdown0_ext;
  txdetectrx2_ext <= txdetectrx0_ext;
  powerdown2_ext <= powerdown0_ext;
  txdetectrx3_ext <= txdetectrx0_ext;
  powerdown3_ext <= powerdown0_ext;
  ep_pld_clk <= ep_core_clk_out;
  ep_clk_out <= ep_pclk_in;
  ep_pclk_in <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(rate_ext))) = std_logic_vector'("00000000000000000000000000000001"))), ep_clk500_out, ep_clk250_out);
  rp_pclk <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(rp_rate))) = std_logic_vector'("00000000000000000000000000000001"))), ep_clk500_out, ep_clk250_out);
  rx_in0 <= Vector_To_Std_Logic(A_WE_StdLogicVector(((std_logic'(connected_bits(0)) = std_logic'(std_logic'('1')))), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(rp_tx_out0))), std_logic_vector'("00000000000000000000000000000001")));
  rp_rx_in0 <= tx_out0;
  rx_in1 <= Vector_To_Std_Logic(A_WE_StdLogicVector(((std_logic'(connected_bits(1)) = std_logic'(std_logic'('1')))), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(rp_tx_out1))), std_logic_vector'("00000000000000000000000000000001")));
  rp_rx_in1 <= tx_out1;
  rx_in2 <= Vector_To_Std_Logic(A_WE_StdLogicVector(((std_logic'(connected_bits(2)) = std_logic'(std_logic'('1')))), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(rp_tx_out2))), std_logic_vector'("00000000000000000000000000000001")));
  rp_rx_in2 <= tx_out2;
  rx_in3 <= Vector_To_Std_Logic(A_WE_StdLogicVector(((std_logic'(connected_bits(3)) = std_logic'(std_logic'('1')))), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(rp_tx_out3))), std_logic_vector'("00000000000000000000000000000001")));
  rp_rx_in3 <= tx_out3;
  local_rstn <= std_logic'('1');
  test_in(2 DOWNTO 1) <= std_logic_vector'("00");
  test_in(8 DOWNTO 4) <= std_logic_vector'("00000");
  test_in(9) <= std_logic'('1');
  test_in(39 DOWNTO 10) <= std_logic_vector'("000000000000000000000000000000");
  --Bit 3: Work around simulation Reciever Detect issue for Stratix IV GX
  test_in(3) <= NOT pipe_mode;
  --Bit 0: Speed up the simulation but making counters faster than normal
  test_in(0) <= std_logic(FAST_COUNTERS);
  --Compute number of lanes to hookup
  connected_lanes <= std_logic_vector(NUM_CONNECTED_LANES);
  connected_bits <= A_WE_StdLogicVector((std_logic'(connected_lanes(3)) = '1'), std_logic_vector'("11111111"), A_WE_StdLogicVector((std_logic'(connected_lanes(2)) = '1'), std_logic_vector'("00001111"), A_WE_StdLogicVector((std_logic'(connected_lanes(1)) = '1'), std_logic_vector'("00000011"), std_logic_vector'("00000001"))));
  rp_test_in(31 DOWNTO 8) <= std_logic_vector'("000000000000000000000000");
  rp_test_in(6) <= std_logic'('0');
  rp_test_in(4) <= std_logic'('0');
  rp_test_in(2 DOWNTO 1) <= std_logic_vector'("00");
  --Bit 0: Speed up the simulation but making counters faster than normal
  rp_test_in(0) <= std_logic'('1');
  --Bit 3: Forces all lanes to detect the receiver
  --For Stratix GX we must force but can use Rx Detect for
  --the generic PIPE interface
  rp_test_in(3) <= NOT pipe_mode;
  --Bit 5: Disable polling.compliance
  rp_test_in(5) <= std_logic'('1');
  --Bit 7: Disable any entrance to low power link states (for Stratix GX)
  --For Stratix GX we must disable but can use Low Power for
  --the generic PIPE interface
  rp_test_in(7) <= NOT pipe_mode;
  --When the phy is Stratix GX we can allow the pipe_mode to be disabled 
  --otherwise we need to force pipe_mode on
  pipe_mode_sig2 <= std_logic(PIPE_MODE_SIM);
  pipe_mode <= A_WE_StdLogic(((((((phy_sel_code = std_logic_vector'("0000"))) OR ((phy_sel_code = std_logic_vector'("0010")))) OR ((phy_sel_code = std_logic_vector'("0110")))) OR ((phy_sel_code = std_logic_vector'("0111"))))), pipe_mode_sig2, std_logic'('1'));
  rp : altpcietb_bfm_rp_top_x8_pipen1b
    port map(
            clk250_in => ep_clk250_out,
            clk500_in => ep_clk500_out,
            local_rstn => local_rstn,
            pcie_rstn => rp_rstn,
            phystatus0_ext => rp_phystatus0_ext,
            phystatus1_ext => rp_phystatus1_ext,
            phystatus2_ext => rp_phystatus2_ext,
            phystatus3_ext => rp_phystatus3_ext,
            phystatus4_ext => rp_phystatus4_ext,
            phystatus5_ext => rp_phystatus5_ext,
            phystatus6_ext => rp_phystatus6_ext,
            phystatus7_ext => rp_phystatus7_ext,
            pipe_mode => pipe_mode,
            powerdown0_ext => rp_powerdown0_ext,
            powerdown1_ext => rp_powerdown1_ext,
            powerdown2_ext => rp_powerdown2_ext,
            powerdown3_ext => rp_powerdown3_ext,
            powerdown4_ext => rp_powerdown4_ext,
            powerdown5_ext => rp_powerdown5_ext,
            powerdown6_ext => rp_powerdown6_ext,
            powerdown7_ext => rp_powerdown7_ext,
            rate_ext => rp_rate,
            rx_in0 => rp_rx_in0,
            rx_in1 => rp_rx_in1,
            rx_in2 => rp_rx_in2,
            rx_in3 => rp_rx_in3,
            rx_in4 => gnd_rp_rx_in4,
            rx_in5 => gnd_rp_rx_in5,
            rx_in6 => gnd_rp_rx_in6,
            rx_in7 => gnd_rp_rx_in7,
            rxdata0_ext => rp_rxdata0_ext,
            rxdata1_ext => rp_rxdata1_ext,
            rxdata2_ext => rp_rxdata2_ext,
            rxdata3_ext => rp_rxdata3_ext,
            rxdata4_ext => rp_rxdata4_ext,
            rxdata5_ext => rp_rxdata5_ext,
            rxdata6_ext => rp_rxdata6_ext,
            rxdata7_ext => rp_rxdata7_ext,
            rxdatak0_ext => rp_rxdatak0_ext,
            rxdatak1_ext => rp_rxdatak1_ext,
            rxdatak2_ext => rp_rxdatak2_ext,
            rxdatak3_ext => rp_rxdatak3_ext,
            rxdatak4_ext => rp_rxdatak4_ext,
            rxdatak5_ext => rp_rxdatak5_ext,
            rxdatak6_ext => rp_rxdatak6_ext,
            rxdatak7_ext => rp_rxdatak7_ext,
            rxelecidle0_ext => rp_rxelecidle0_ext,
            rxelecidle1_ext => rp_rxelecidle1_ext,
            rxelecidle2_ext => rp_rxelecidle2_ext,
            rxelecidle3_ext => rp_rxelecidle3_ext,
            rxelecidle4_ext => rp_rxelecidle4_ext,
            rxelecidle5_ext => rp_rxelecidle5_ext,
            rxelecidle6_ext => rp_rxelecidle6_ext,
            rxelecidle7_ext => rp_rxelecidle7_ext,
            rxpolarity0_ext => rp_rxpolarity0_ext,
            rxpolarity1_ext => rp_rxpolarity1_ext,
            rxpolarity2_ext => rp_rxpolarity2_ext,
            rxpolarity3_ext => rp_rxpolarity3_ext,
            rxpolarity4_ext => rp_rxpolarity4_ext,
            rxpolarity5_ext => rp_rxpolarity5_ext,
            rxpolarity6_ext => rp_rxpolarity6_ext,
            rxpolarity7_ext => rp_rxpolarity7_ext,
            rxstatus0_ext => rp_rxstatus0_ext,
            rxstatus1_ext => rp_rxstatus1_ext,
            rxstatus2_ext => rp_rxstatus2_ext,
            rxstatus3_ext => rp_rxstatus3_ext,
            rxstatus4_ext => rp_rxstatus4_ext,
            rxstatus5_ext => rp_rxstatus5_ext,
            rxstatus6_ext => rp_rxstatus6_ext,
            rxstatus7_ext => rp_rxstatus7_ext,
            rxvalid0_ext => rp_rxvalid0_ext,
            rxvalid1_ext => rp_rxvalid1_ext,
            rxvalid2_ext => rp_rxvalid2_ext,
            rxvalid3_ext => rp_rxvalid3_ext,
            rxvalid4_ext => rp_rxvalid4_ext,
            rxvalid5_ext => rp_rxvalid5_ext,
            rxvalid6_ext => rp_rxvalid6_ext,
            rxvalid7_ext => rp_rxvalid7_ext,
            swdn_out => swdn_out,
            test_in => rp_test_in,
            test_out => rp_test_out,
            tx_out0 => rp_tx_out0,
            tx_out1 => rp_tx_out1,
            tx_out2 => rp_tx_out2,
            tx_out3 => rp_tx_out3,
            tx_out4 => open_rp_tx_out4,
            tx_out5 => open_rp_tx_out5,
            tx_out6 => open_rp_tx_out6,
            tx_out7 => open_rp_tx_out7,
            txcompl0_ext => rp_txcompl0_ext,
            txcompl1_ext => rp_txcompl1_ext,
            txcompl2_ext => rp_txcompl2_ext,
            txcompl3_ext => rp_txcompl3_ext,
            txcompl4_ext => rp_txcompl4_ext,
            txcompl5_ext => rp_txcompl5_ext,
            txcompl6_ext => rp_txcompl6_ext,
            txcompl7_ext => rp_txcompl7_ext,
            txdata0_ext => rp_txdata0_ext,
            txdata1_ext => rp_txdata1_ext,
            txdata2_ext => rp_txdata2_ext,
            txdata3_ext => rp_txdata3_ext,
            txdata4_ext => rp_txdata4_ext,
            txdata5_ext => rp_txdata5_ext,
            txdata6_ext => rp_txdata6_ext,
            txdata7_ext => rp_txdata7_ext,
            txdatak0_ext => rp_txdatak0_ext,
            txdatak1_ext => rp_txdatak1_ext,
            txdatak2_ext => rp_txdatak2_ext,
            txdatak3_ext => rp_txdatak3_ext,
            txdatak4_ext => rp_txdatak4_ext,
            txdatak5_ext => rp_txdatak5_ext,
            txdatak6_ext => rp_txdatak6_ext,
            txdatak7_ext => rp_txdatak7_ext,
            txdetectrx0_ext => rp_txdetectrx0_ext,
            txdetectrx1_ext => rp_txdetectrx1_ext,
            txdetectrx2_ext => rp_txdetectrx2_ext,
            txdetectrx3_ext => rp_txdetectrx3_ext,
            txdetectrx4_ext => rp_txdetectrx4_ext,
            txdetectrx5_ext => rp_txdetectrx5_ext,
            txdetectrx6_ext => rp_txdetectrx6_ext,
            txdetectrx7_ext => rp_txdetectrx7_ext,
            txelecidle0_ext => rp_txelecidle0_ext,
            txelecidle1_ext => rp_txelecidle1_ext,
            txelecidle2_ext => rp_txelecidle2_ext,
            txelecidle3_ext => rp_txelecidle3_ext,
            txelecidle4_ext => rp_txelecidle4_ext,
            txelecidle5_ext => rp_txelecidle5_ext,
            txelecidle6_ext => rp_txelecidle6_ext,
            txelecidle7_ext => rp_txelecidle7_ext
    );

  drvr : altpcietb_bfm_driver_chaining
    generic map(
      TEST_LEVEL => 1
    )
    port map(
            INTA => swdn_out(0),
            INTB => swdn_out(1),
            INTC => swdn_out(2),
            INTD => swdn_out(3),
            clk_in => rp_pclk,
            dummy_out => dummy_out,
            rstn => pcie_rstn
    );

  ltssm_mon : altpcietb_ltssm_mon
    port map(
            dummy_out => ltssm_dummy_out,
            ep_ltssm => ep_ltssm,
            rp_clk => rp_pclk,
            rp_ltssm => rp_ltssm,
            rstn => pcie_rstn
    );

  ep : pcie_phy_example_chaining_pipen1b
    port map(
            clk250_out => ep_clk250_out,
            clk500_out => ep_clk500_out,
            core_clk_out => ep_core_clk_out,
            free_100MHz => refclk,
            lane_width_code => lane_width_code,
            local_rstn => local_rstn,
            pcie_rstn => pcie_rstn,
            pclk_in => ep_pclk_in,
            phy_sel_code => phy_sel_code,
            phystatus_ext => phystatus0_ext,
            pipe_mode => pipe_mode,
            pld_clk => ep_pld_clk,
            powerdown_ext => powerdown0_ext,
            rate_ext => rate_ext,
            ref_clk_sel_code => ref_clk_sel_code,
            refclk => refclk,
            rx_in0 => rx_in0,
            rx_in1 => rx_in1,
            rx_in2 => rx_in2,
            rx_in3 => rx_in3,
            rxdata0_ext => rxdata0_ext,
            rxdata1_ext => rxdata1_ext,
            rxdata2_ext => rxdata2_ext,
            rxdata3_ext => rxdata3_ext,
            rxdatak0_ext => rxdatak0_ext,
            rxdatak1_ext => rxdatak1_ext,
            rxdatak2_ext => rxdatak2_ext,
            rxdatak3_ext => rxdatak3_ext,
            rxelecidle0_ext => rxelecidle0_ext,
            rxelecidle1_ext => rxelecidle1_ext,
            rxelecidle2_ext => rxelecidle2_ext,
            rxelecidle3_ext => rxelecidle3_ext,
            rxpolarity0_ext => rxpolarity0_ext,
            rxpolarity1_ext => rxpolarity1_ext,
            rxpolarity2_ext => rxpolarity2_ext,
            rxpolarity3_ext => rxpolarity3_ext,
            rxstatus0_ext => rxstatus0_ext,
            rxstatus1_ext => rxstatus1_ext,
            rxstatus2_ext => rxstatus2_ext,
            rxstatus3_ext => rxstatus3_ext,
            rxvalid0_ext => rxvalid0_ext,
            rxvalid1_ext => rxvalid1_ext,
            rxvalid2_ext => rxvalid2_ext,
            rxvalid3_ext => rxvalid3_ext,
            test_in => test_in,
            test_out_icm => test_out,
            tx_out0 => tx_out0,
            tx_out1 => tx_out1,
            tx_out2 => tx_out2,
            tx_out3 => tx_out3,
            txcompl0_ext => txcompl0_ext,
            txcompl1_ext => txcompl1_ext,
            txcompl2_ext => txcompl2_ext,
            txcompl3_ext => txcompl3_ext,
            txdata0_ext => txdata0_ext,
            txdata1_ext => txdata1_ext,
            txdata2_ext => txdata2_ext,
            txdata3_ext => txdata3_ext,
            txdatak0_ext => txdatak0_ext,
            txdatak1_ext => txdatak1_ext,
            txdatak2_ext => txdatak2_ext,
            txdatak3_ext => txdatak3_ext,
            txdetectrx_ext => txdetectrx0_ext,
            txelecidle0_ext => txelecidle0_ext,
            txelecidle1_ext => txelecidle1_ext,
            txelecidle2_ext => txelecidle2_ext,
            txelecidle3_ext => txelecidle3_ext
    );

  bfm_log_common : altpcietb_bfm_log_common
    port map(
            dummy_out => bfm_log_common_dummy_out
    );

  bfm_req_intf_common : altpcietb_bfm_req_intf_common
    port map(
            dummy_out => bfm_req_intf_common_dummy_out
    );

  bfm_shmem_common : altpcietb_bfm_shmem_common
    port map(
            dummy_out => bfm_shmem_common_dummy_out
    );

  lane0 : altpcietb_pipe_phy
    generic map(
      APIPE_WIDTH => 8,
      BPIPE_WIDTH => 8,
      LANE_NUM => 0
    )
    port map(
            A_lane_conn => connected_bits(0),
            A_phystatus => phystatus0_ext,
            A_powerdown => powerdown0_ext,
            A_rate => rate_ext,
            A_rxdata => rxdata0_ext,
            A_rxdatak(0) => rxdatak0_ext,
            A_rxelecidle => rxelecidle0_ext,
            A_rxpolarity => rxpolarity0_ext,
            A_rxstatus => rxstatus0_ext,
            A_rxvalid => rxvalid0_ext,
            A_txcompl => txcompl0_ext,
            A_txdata => txdata0_ext,
            A_txdatak => A_TOSTDLOGICVECTOR(txdatak0_ext),
            A_txdetectrx => txdetectrx0_ext,
            A_txelecidle => txelecidle0_ext,
            B_lane_conn => std_logic'('1'),
            B_phystatus => rp_phystatus0_ext,
            B_powerdown => rp_powerdown0_ext,
            B_rate => rp_rate,
            B_rxdata => rp_rxdata0_ext,
            B_rxdatak(0) => rp_rxdatak0_ext,
            B_rxelecidle => rp_rxelecidle0_ext,
            B_rxpolarity => rp_rxpolarity0_ext,
            B_rxstatus => rp_rxstatus0_ext,
            B_rxvalid => rp_rxvalid0_ext,
            B_txcompl => rp_txcompl0_ext,
            B_txdata => rp_txdata0_ext,
            B_txdatak => A_TOSTDLOGICVECTOR(rp_txdatak0_ext),
            B_txdetectrx => rp_txdetectrx0_ext,
            B_txelecidle => rp_txelecidle0_ext,
            pclk_a => ep_clk_out,
            pclk_b => rp_pclk,
            pipe_mode => pipe_mode,
            resetn => pcie_rstn
    );

  lane1 : altpcietb_pipe_phy
    generic map(
      APIPE_WIDTH => 8,
      BPIPE_WIDTH => 8,
      LANE_NUM => 1
    )
    port map(
            A_lane_conn => connected_bits(1),
            A_phystatus => phystatus1_ext,
            A_powerdown => powerdown1_ext,
            A_rate => rate_ext,
            A_rxdata => rxdata1_ext,
            A_rxdatak(0) => rxdatak1_ext,
            A_rxelecidle => rxelecidle1_ext,
            A_rxpolarity => rxpolarity1_ext,
            A_rxstatus => rxstatus1_ext,
            A_rxvalid => rxvalid1_ext,
            A_txcompl => txcompl1_ext,
            A_txdata => txdata1_ext,
            A_txdatak => A_TOSTDLOGICVECTOR(txdatak1_ext),
            A_txdetectrx => txdetectrx1_ext,
            A_txelecidle => txelecidle1_ext,
            B_lane_conn => std_logic'('1'),
            B_phystatus => rp_phystatus1_ext,
            B_powerdown => rp_powerdown1_ext,
            B_rate => rp_rate,
            B_rxdata => rp_rxdata1_ext,
            B_rxdatak(0) => rp_rxdatak1_ext,
            B_rxelecidle => rp_rxelecidle1_ext,
            B_rxpolarity => rp_rxpolarity1_ext,
            B_rxstatus => rp_rxstatus1_ext,
            B_rxvalid => rp_rxvalid1_ext,
            B_txcompl => rp_txcompl1_ext,
            B_txdata => rp_txdata1_ext,
            B_txdatak => A_TOSTDLOGICVECTOR(rp_txdatak1_ext),
            B_txdetectrx => rp_txdetectrx1_ext,
            B_txelecidle => rp_txelecidle1_ext,
            pclk_a => ep_clk_out,
            pclk_b => rp_pclk,
            pipe_mode => pipe_mode,
            resetn => pcie_rstn
    );

  lane2 : altpcietb_pipe_phy
    generic map(
      APIPE_WIDTH => 8,
      BPIPE_WIDTH => 8,
      LANE_NUM => 2
    )
    port map(
            A_lane_conn => connected_bits(2),
            A_phystatus => phystatus2_ext,
            A_powerdown => powerdown2_ext,
            A_rate => rate_ext,
            A_rxdata => rxdata2_ext,
            A_rxdatak(0) => rxdatak2_ext,
            A_rxelecidle => rxelecidle2_ext,
            A_rxpolarity => rxpolarity2_ext,
            A_rxstatus => rxstatus2_ext,
            A_rxvalid => rxvalid2_ext,
            A_txcompl => txcompl2_ext,
            A_txdata => txdata2_ext,
            A_txdatak => A_TOSTDLOGICVECTOR(txdatak2_ext),
            A_txdetectrx => txdetectrx2_ext,
            A_txelecidle => txelecidle2_ext,
            B_lane_conn => std_logic'('1'),
            B_phystatus => rp_phystatus2_ext,
            B_powerdown => rp_powerdown2_ext,
            B_rate => rp_rate,
            B_rxdata => rp_rxdata2_ext,
            B_rxdatak(0) => rp_rxdatak2_ext,
            B_rxelecidle => rp_rxelecidle2_ext,
            B_rxpolarity => rp_rxpolarity2_ext,
            B_rxstatus => rp_rxstatus2_ext,
            B_rxvalid => rp_rxvalid2_ext,
            B_txcompl => rp_txcompl2_ext,
            B_txdata => rp_txdata2_ext,
            B_txdatak => A_TOSTDLOGICVECTOR(rp_txdatak2_ext),
            B_txdetectrx => rp_txdetectrx2_ext,
            B_txelecidle => rp_txelecidle2_ext,
            pclk_a => ep_clk_out,
            pclk_b => rp_pclk,
            pipe_mode => pipe_mode,
            resetn => pcie_rstn
    );

  lane3 : altpcietb_pipe_phy
    generic map(
      APIPE_WIDTH => 8,
      BPIPE_WIDTH => 8,
      LANE_NUM => 3
    )
    port map(
            A_lane_conn => connected_bits(3),
            A_phystatus => phystatus3_ext,
            A_powerdown => powerdown3_ext,
            A_rate => rate_ext,
            A_rxdata => rxdata3_ext,
            A_rxdatak(0) => rxdatak3_ext,
            A_rxelecidle => rxelecidle3_ext,
            A_rxpolarity => rxpolarity3_ext,
            A_rxstatus => rxstatus3_ext,
            A_rxvalid => rxvalid3_ext,
            A_txcompl => txcompl3_ext,
            A_txdata => txdata3_ext,
            A_txdatak => A_TOSTDLOGICVECTOR(txdatak3_ext),
            A_txdetectrx => txdetectrx3_ext,
            A_txelecidle => txelecidle3_ext,
            B_lane_conn => std_logic'('1'),
            B_phystatus => rp_phystatus3_ext,
            B_powerdown => rp_powerdown3_ext,
            B_rate => rp_rate,
            B_rxdata => rp_rxdata3_ext,
            B_rxdatak(0) => rp_rxdatak3_ext,
            B_rxelecidle => rp_rxelecidle3_ext,
            B_rxpolarity => rp_rxpolarity3_ext,
            B_rxstatus => rp_rxstatus3_ext,
            B_rxvalid => rp_rxvalid3_ext,
            B_txcompl => rp_txcompl3_ext,
            B_txdata => rp_txdata3_ext,
            B_txdatak => A_TOSTDLOGICVECTOR(rp_txdatak3_ext),
            B_txdetectrx => rp_txdetectrx3_ext,
            B_txelecidle => rp_txelecidle3_ext,
            pclk_a => ep_clk_out,
            pclk_b => rp_pclk,
            pipe_mode => pipe_mode,
            resetn => pcie_rstn
    );

  lane4 : altpcietb_pipe_phy
    generic map(
      APIPE_WIDTH => 8,
      BPIPE_WIDTH => 8,
      LANE_NUM => 4
    )
    port map(
            A_lane_conn => std_logic'('0'),
            A_phystatus => open_phystatus4_ext,
            A_powerdown => gnd_powerdown4_ext,
            A_rate => rate_ext,
            A_rxdata => open_rxdata4_ext,
            A_rxdatak(0) => open_rxdatak4_ext,
            A_rxelecidle => open_rxelecidle4_ext,
            A_rxpolarity => gnd_rxpolarity4_ext,
            A_rxstatus => open_rxstatus4_ext,
            A_rxvalid => open_rxvalid4_ext,
            A_txcompl => gnd_txcompl4_ext,
            A_txdata => gnd_txdata4_ext,
            A_txdatak => A_TOSTDLOGICVECTOR(gnd_txdatak4_ext),
            A_txdetectrx => gnd_txdetectrx4_ext,
            A_txelecidle => gnd_txelecidle4_ext,
            B_lane_conn => std_logic'('1'),
            B_phystatus => rp_phystatus4_ext,
            B_powerdown => rp_powerdown4_ext,
            B_rate => rp_rate,
            B_rxdata => rp_rxdata4_ext,
            B_rxdatak(0) => rp_rxdatak4_ext,
            B_rxelecidle => rp_rxelecidle4_ext,
            B_rxpolarity => rp_rxpolarity4_ext,
            B_rxstatus => rp_rxstatus4_ext,
            B_rxvalid => rp_rxvalid4_ext,
            B_txcompl => rp_txcompl4_ext,
            B_txdata => rp_txdata4_ext,
            B_txdatak => A_TOSTDLOGICVECTOR(rp_txdatak4_ext),
            B_txdetectrx => rp_txdetectrx4_ext,
            B_txelecidle => rp_txelecidle4_ext,
            pclk_a => ep_clk_out,
            pclk_b => rp_pclk,
            pipe_mode => pipe_mode,
            resetn => pcie_rstn
    );

  lane5 : altpcietb_pipe_phy
    generic map(
      APIPE_WIDTH => 8,
      BPIPE_WIDTH => 8,
      LANE_NUM => 5
    )
    port map(
            A_lane_conn => std_logic'('0'),
            A_phystatus => open_phystatus5_ext,
            A_powerdown => gnd_powerdown5_ext,
            A_rate => rate_ext,
            A_rxdata => open_rxdata5_ext,
            A_rxdatak(0) => open_rxdatak5_ext,
            A_rxelecidle => open_rxelecidle5_ext,
            A_rxpolarity => gnd_rxpolarity5_ext,
            A_rxstatus => open_rxstatus5_ext,
            A_rxvalid => open_rxvalid5_ext,
            A_txcompl => gnd_txcompl5_ext,
            A_txdata => gnd_txdata5_ext,
            A_txdatak => A_TOSTDLOGICVECTOR(gnd_txdatak5_ext),
            A_txdetectrx => gnd_txdetectrx5_ext,
            A_txelecidle => gnd_txelecidle5_ext,
            B_lane_conn => std_logic'('1'),
            B_phystatus => rp_phystatus5_ext,
            B_powerdown => rp_powerdown5_ext,
            B_rate => rp_rate,
            B_rxdata => rp_rxdata5_ext,
            B_rxdatak(0) => rp_rxdatak5_ext,
            B_rxelecidle => rp_rxelecidle5_ext,
            B_rxpolarity => rp_rxpolarity5_ext,
            B_rxstatus => rp_rxstatus5_ext,
            B_rxvalid => rp_rxvalid5_ext,
            B_txcompl => rp_txcompl5_ext,
            B_txdata => rp_txdata5_ext,
            B_txdatak => A_TOSTDLOGICVECTOR(rp_txdatak5_ext),
            B_txdetectrx => rp_txdetectrx5_ext,
            B_txelecidle => rp_txelecidle5_ext,
            pclk_a => ep_clk_out,
            pclk_b => rp_pclk,
            pipe_mode => pipe_mode,
            resetn => pcie_rstn
    );

  lane6 : altpcietb_pipe_phy
    generic map(
      APIPE_WIDTH => 8,
      BPIPE_WIDTH => 8,
      LANE_NUM => 6
    )
    port map(
            A_lane_conn => std_logic'('0'),
            A_phystatus => open_phystatus6_ext,
            A_powerdown => gnd_powerdown6_ext,
            A_rate => rate_ext,
            A_rxdata => open_rxdata6_ext,
            A_rxdatak(0) => open_rxdatak6_ext,
            A_rxelecidle => open_rxelecidle6_ext,
            A_rxpolarity => gnd_rxpolarity6_ext,
            A_rxstatus => open_rxstatus6_ext,
            A_rxvalid => open_rxvalid6_ext,
            A_txcompl => gnd_txcompl6_ext,
            A_txdata => gnd_txdata6_ext,
            A_txdatak => A_TOSTDLOGICVECTOR(gnd_txdatak6_ext),
            A_txdetectrx => gnd_txdetectrx6_ext,
            A_txelecidle => gnd_txelecidle6_ext,
            B_lane_conn => std_logic'('1'),
            B_phystatus => rp_phystatus6_ext,
            B_powerdown => rp_powerdown6_ext,
            B_rate => rp_rate,
            B_rxdata => rp_rxdata6_ext,
            B_rxdatak(0) => rp_rxdatak6_ext,
            B_rxelecidle => rp_rxelecidle6_ext,
            B_rxpolarity => rp_rxpolarity6_ext,
            B_rxstatus => rp_rxstatus6_ext,
            B_rxvalid => rp_rxvalid6_ext,
            B_txcompl => rp_txcompl6_ext,
            B_txdata => rp_txdata6_ext,
            B_txdatak => A_TOSTDLOGICVECTOR(rp_txdatak6_ext),
            B_txdetectrx => rp_txdetectrx6_ext,
            B_txelecidle => rp_txelecidle6_ext,
            pclk_a => ep_clk_out,
            pclk_b => rp_pclk,
            pipe_mode => pipe_mode,
            resetn => pcie_rstn
    );

  lane7 : altpcietb_pipe_phy
    generic map(
      APIPE_WIDTH => 8,
      BPIPE_WIDTH => 8,
      LANE_NUM => 7
    )
    port map(
            A_lane_conn => std_logic'('0'),
            A_phystatus => open_phystatus7_ext,
            A_powerdown => gnd_powerdown7_ext,
            A_rate => rate_ext,
            A_rxdata => open_rxdata7_ext,
            A_rxdatak(0) => open_rxdatak7_ext,
            A_rxelecidle => open_rxelecidle7_ext,
            A_rxpolarity => gnd_rxpolarity7_ext,
            A_rxstatus => open_rxstatus7_ext,
            A_rxvalid => open_rxvalid7_ext,
            A_txcompl => gnd_txcompl7_ext,
            A_txdata => gnd_txdata7_ext,
            A_txdatak => A_TOSTDLOGICVECTOR(gnd_txdatak7_ext),
            A_txdetectrx => gnd_txdetectrx7_ext,
            A_txelecidle => gnd_txelecidle7_ext,
            B_lane_conn => std_logic'('1'),
            B_phystatus => rp_phystatus7_ext,
            B_powerdown => rp_powerdown7_ext,
            B_rate => rp_rate,
            B_rxdata => rp_rxdata7_ext,
            B_rxdatak(0) => rp_rxdatak7_ext,
            B_rxelecidle => rp_rxelecidle7_ext,
            B_rxpolarity => rp_rxpolarity7_ext,
            B_rxstatus => rp_rxstatus7_ext,
            B_rxvalid => rp_rxvalid7_ext,
            B_txcompl => rp_txcompl7_ext,
            B_txdata => rp_txdata7_ext,
            B_txdatak => A_TOSTDLOGICVECTOR(rp_txdatak7_ext),
            B_txdetectrx => rp_txdetectrx7_ext,
            B_txelecidle => rp_txelecidle7_ext,
            pclk_a => ep_clk_out,
            pclk_b => rp_pclk,
            pipe_mode => pipe_mode,
            resetn => pcie_rstn
    );

  rst_clk_gen : altpcietb_rst_clk
    port map(
            ep_core_clk_out => ep_core_clk_out,
            pcie_rstn => pcie_rstn,
            ref_clk_out => refclk,
            ref_clk_sel_code => ref_clk_sel_code,
            rp_rstn => rp_rstn
    );


end europa;

