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
use altera_mf.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--/** This VHDL file is used for simulation and synthesis in chained DMA design example
--* This file provides the top level wrapper file of the core and example applications
--*/
entity pcie_phy_example_chaining_pipen1b is 
        port (
              -- inputs:
                 signal free_100MHz : IN STD_LOGIC;
                 signal local_rstn : IN STD_LOGIC;
                 signal pcie_rstn : IN STD_LOGIC;
                 signal pclk_in : IN STD_LOGIC;
                 signal phystatus_ext : IN STD_LOGIC;
                 signal pipe_mode : IN STD_LOGIC := std_logic'('0');
                 signal pld_clk : IN STD_LOGIC;
                 signal refclk : IN STD_LOGIC;
                 signal rx_in0 : IN STD_LOGIC := std_logic'('0');
                 signal rx_in1 : IN STD_LOGIC := std_logic'('0');
                 signal rx_in2 : IN STD_LOGIC := std_logic'('0');
                 signal rx_in3 : IN STD_LOGIC := std_logic'('0');
                 signal rxdata0_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal rxdata1_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal rxdata2_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal rxdata3_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal rxdatak0_ext : IN STD_LOGIC;
                 signal rxdatak1_ext : IN STD_LOGIC;
                 signal rxdatak2_ext : IN STD_LOGIC;
                 signal rxdatak3_ext : IN STD_LOGIC;
                 signal rxelecidle0_ext : IN STD_LOGIC;
                 signal rxelecidle1_ext : IN STD_LOGIC;
                 signal rxelecidle2_ext : IN STD_LOGIC;
                 signal rxelecidle3_ext : IN STD_LOGIC;
                 signal rxstatus0_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal rxstatus1_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal rxstatus2_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal rxstatus3_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal rxvalid0_ext : IN STD_LOGIC;
                 signal rxvalid1_ext : IN STD_LOGIC;
                 signal rxvalid2_ext : IN STD_LOGIC;
                 signal rxvalid3_ext : IN STD_LOGIC;
                 signal test_in : IN STD_LOGIC_VECTOR (39 DOWNTO 0);

              -- outputs:
                 signal clk250_out : OUT STD_LOGIC;
                 signal clk500_out : OUT STD_LOGIC;
                 signal core_clk_out : OUT STD_LOGIC;
                 signal lane_width_code : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal pcie_reconfig_busy : OUT STD_LOGIC;
                 signal phy_sel_code : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal powerdown_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal rate_ext : OUT STD_LOGIC;
                 signal rc_pll_locked : OUT STD_LOGIC;
                 signal ref_clk_sel_code : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal rxpolarity0_ext : OUT STD_LOGIC;
                 signal rxpolarity1_ext : OUT STD_LOGIC;
                 signal rxpolarity2_ext : OUT STD_LOGIC;
                 signal rxpolarity3_ext : OUT STD_LOGIC;
                 signal test_out_icm : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                 signal tx_out0 : OUT STD_LOGIC;
                 signal tx_out1 : OUT STD_LOGIC;
                 signal tx_out2 : OUT STD_LOGIC;
                 signal tx_out3 : OUT STD_LOGIC;
                 signal txcompl0_ext : OUT STD_LOGIC;
                 signal txcompl1_ext : OUT STD_LOGIC;
                 signal txcompl2_ext : OUT STD_LOGIC;
                 signal txcompl3_ext : OUT STD_LOGIC;
                 signal txdata0_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal txdata1_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal txdata2_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal txdata3_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal txdatak0_ext : OUT STD_LOGIC;
                 signal txdatak1_ext : OUT STD_LOGIC;
                 signal txdatak2_ext : OUT STD_LOGIC;
                 signal txdatak3_ext : OUT STD_LOGIC;
                 signal txdetectrx_ext : OUT STD_LOGIC;
                 signal txelecidle0_ext : OUT STD_LOGIC;
                 signal txelecidle1_ext : OUT STD_LOGIC;
                 signal txelecidle2_ext : OUT STD_LOGIC;
                 signal txelecidle3_ext : OUT STD_LOGIC
              );
end entity pcie_phy_example_chaining_pipen1b;


architecture europa of pcie_phy_example_chaining_pipen1b is
  component pcie_phy_plus is
PORT (
    signal tl_cfg_add : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal srstn : OUT STD_LOGIC;
        signal tl_cfg_sts_wr : OUT STD_LOGIC;
        signal tl_cfg_ctl_wr : OUT STD_LOGIC;
        signal txcompl1_ext : OUT STD_LOGIC;
        signal app_msi_ack : OUT STD_LOGIC;
        signal tl_cfg_sts : OUT STD_LOGIC_VECTOR (52 DOWNTO 0);
        signal clk500_out : OUT STD_LOGIC;
        signal txelecidle0_ext : OUT STD_LOGIC;
        signal txdatak1_ext : OUT STD_LOGIC;
        signal tl_cfg_ctl : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal rx_st_err0 : OUT STD_LOGIC;
        signal test_out : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
        signal txelecidle2_ext : OUT STD_LOGIC;
        signal txdatak2_ext : OUT STD_LOGIC;
        signal tx_out0 : OUT STD_LOGIC;
        signal rxpolarity0_ext : OUT STD_LOGIC;
        signal clk250_out : OUT STD_LOGIC;
        signal tx_out2 : OUT STD_LOGIC;
        signal txelecidle3_ext : OUT STD_LOGIC;
        signal txdatak3_ext : OUT STD_LOGIC;
        signal rx_st_eop0 : OUT STD_LOGIC;
        signal lmi_ack : OUT STD_LOGIC;
        signal lane_act : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal rate_ext : OUT STD_LOGIC;
        signal rx_st_be0 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal txcompl3_ext : OUT STD_LOGIC;
        signal rx_st_valid0 : OUT STD_LOGIC;
        signal tx_st_ready0 : OUT STD_LOGIC;
        signal txelecidle1_ext : OUT STD_LOGIC;
        signal powerdown_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal tx_out3 : OUT STD_LOGIC;
        signal rx_st_bardec0 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal ltssm : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal core_clk_out : OUT STD_LOGIC;
        signal tx_fifo_empty0 : OUT STD_LOGIC;
        signal rxpolarity2_ext : OUT STD_LOGIC;
        signal tx_out1 : OUT STD_LOGIC;
        signal txdata0_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rxpolarity3_ext : OUT STD_LOGIC;
        signal txcompl2_ext : OUT STD_LOGIC;
        signal rx_st_sop0 : OUT STD_LOGIC;
        signal rxpolarity1_ext : OUT STD_LOGIC;
        signal rx_st_data0 : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
        signal txdata1_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal pme_to_sr : OUT STD_LOGIC;
        signal txdata2_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rc_pll_locked : OUT STD_LOGIC;
        signal txdata3_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal txdatak0_ext : OUT STD_LOGIC;
        signal txdetectrx_ext : OUT STD_LOGIC;
        signal txcompl0_ext : OUT STD_LOGIC;
        signal tx_cred0 : OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
        signal app_int_ack : OUT STD_LOGIC;
        signal lmi_dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal pex_msi_num : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal rxdatak2_ext : IN STD_LOGIC;
        signal lmi_rden : IN STD_LOGIC;
        signal app_msi_tc : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal pipe_mode : IN STD_LOGIC;
        signal tx_st_sop0 : IN STD_LOGIC;
        signal pm_event : IN STD_LOGIC;
        signal rxstatus3_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal reconfig_clk : IN STD_LOGIC;
        signal pcie_rstn : IN STD_LOGIC;
        signal app_msi_req : IN STD_LOGIC;
        signal app_msi_num : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal refclk : IN STD_LOGIC;
        signal rxstatus0_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal rx_st_ready0 : IN STD_LOGIC;
        signal rxelecidle0_ext : IN STD_LOGIC;
        signal pld_clk : IN STD_LOGIC;
        signal pm_data : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
        signal rxelecidle3_ext : IN STD_LOGIC;
        signal rx_in1 : IN STD_LOGIC;
        signal rxstatus2_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal rxdatak1_ext : IN STD_LOGIC;
        signal pclk_in : IN STD_LOGIC;
        signal rx_in0 : IN STD_LOGIC;
        signal rxdatak0_ext : IN STD_LOGIC;
        signal tx_st_data0 : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        signal rxelecidle1_ext : IN STD_LOGIC;
        signal rxdata1_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rx_st_mask0 : IN STD_LOGIC;
        signal rxvalid1_ext : IN STD_LOGIC;
        signal rx_in2 : IN STD_LOGIC;
        signal rxdatak3_ext : IN STD_LOGIC;
        signal rx_in3 : IN STD_LOGIC;
        signal test_in : IN STD_LOGIC_VECTOR (39 DOWNTO 0);
        signal phystatus_ext : IN STD_LOGIC;
        signal cpl_err : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
        signal tx_st_eop0 : IN STD_LOGIC;
        signal rxdata3_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal lmi_din : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal rxelecidle2_ext : IN STD_LOGIC;
        signal lmi_wren : IN STD_LOGIC;
        signal rxstatus1_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal tx_st_err0 : IN STD_LOGIC;
        signal pme_to_cr : IN STD_LOGIC;
        signal rxdata0_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal tx_st_valid0 : IN STD_LOGIC;
        signal rxvalid3_ext : IN STD_LOGIC;
        signal rxvalid2_ext : IN STD_LOGIC;
        signal fixedclk_serdes : IN STD_LOGIC;
        signal pm_auxpwr : IN STD_LOGIC;
        signal rxdata2_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal reconfig_clk_locked : IN STD_LOGIC;
        signal app_int_sts : IN STD_LOGIC;
        signal local_rstn : IN STD_LOGIC;
        signal rxvalid0_ext : IN STD_LOGIC;
        signal lmi_addr : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
        signal cpl_pending : IN STD_LOGIC
      );
  end component pcie_phy_plus;
  component altpcierd_reconfig_clk_pll is
PORT (
    signal locked : OUT STD_LOGIC;
        signal c0 : OUT STD_LOGIC;
        signal c1 : OUT STD_LOGIC;
        signal inclk0 : IN STD_LOGIC
      );
  end component altpcierd_reconfig_clk_pll;
  component altpcierd_tl_cfg_sample is
GENERIC (
      HIP_SV : NATURAL
      );
    PORT (
    signal cfg_busdev : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
        signal cfg_prmcsr : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal cfg_np_bas : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
        signal cfg_pr_bas : OUT STD_LOGIC_VECTOR (43 DOWNTO 0);
        signal cfg_msicsr : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        signal cfg_linkcsr : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal cfg_tcvcmap : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
        signal cfg_io_bas : OUT STD_LOGIC_VECTOR (19 DOWNTO 0);
        signal cfg_devcsr : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal tl_cfg_sts : IN STD_LOGIC_VECTOR (52 DOWNTO 0);
        signal tl_cfg_add : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal tl_cfg_sts_wr : IN STD_LOGIC;
        signal tl_cfg_ctl_wr : IN STD_LOGIC;
        signal tl_cfg_ctl : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal pld_clk : IN STD_LOGIC;
        signal rstn : IN STD_LOGIC
      );
  end component altpcierd_tl_cfg_sample;
  component altpcierd_cplerr_lmi is
PORT (
    signal lmi_rden : OUT STD_LOGIC;
        signal lmi_din : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal cplerr_lmi_busy : OUT STD_LOGIC;
        signal lmi_wren : OUT STD_LOGIC;
        signal cpl_err_out : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        signal lmi_addr : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
        signal lmi_ack : IN STD_LOGIC;
        signal clk_in : IN STD_LOGIC;
        signal cpl_err_in : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
        signal err_desc : IN STD_LOGIC_VECTOR (127 DOWNTO 0);
        signal rstn : IN STD_LOGIC
      );
  end component altpcierd_cplerr_lmi;
  component altpcierd_example_app_chaining is
GENERIC (
      AVALON_WADDR : NATURAL;
        CHECK_BUS_MASTER_ENA : NATURAL;
        CHECK_RX_BUFFER_CPL : NATURAL;
        CLK_250_APP : NATURAL;
        ECRC_FORWARD_CHECK : NATURAL;
        ECRC_FORWARD_GENER : NATURAL;
        MAX_NUMTAG : NATURAL;
        MAX_PAYLOAD_SIZE_BYTE : NATURAL;
        TL_SELECTION : NATURAL;
        TXCRED_WIDTH : NATURAL
      );
    PORT (
    signal pex_msi_num : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal cpl_err : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        signal app_msi_tc : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal aer_msi_num : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal msi_stream_valid0 : OUT STD_LOGIC;
        signal msi_stream_data0 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal app_msi_req : OUT STD_LOGIC;
        signal app_msi_num : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal rx_stream_ready0 : OUT STD_LOGIC;
        signal pm_data : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
        signal rx_stream_mask0 : OUT STD_LOGIC;
        signal tx_stream_valid0 : OUT STD_LOGIC;
        signal app_int_sts : OUT STD_LOGIC;
        signal err_desc : OUT STD_LOGIC_VECTOR (127 DOWNTO 0);
        signal tx_stream_data0_1 : OUT STD_LOGIC_VECTOR (74 DOWNTO 0);
        signal tx_stream_data0_0 : OUT STD_LOGIC_VECTOR (74 DOWNTO 0);
        signal cpl_pending : OUT STD_LOGIC;
        signal rx_stream_valid0 : IN STD_LOGIC;
        signal cfg_prmcsr : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal clk_in : IN STD_LOGIC;
        signal ko_cpl_spc_vc0 : IN STD_LOGIC_VECTOR (19 DOWNTO 0);
        signal cfg_msicsr : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        signal cfg_linkcsr : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal tx_stream_mask0 : IN STD_LOGIC;
        signal app_msi_ack : IN STD_LOGIC;
        signal rx_stream_data0_0 : IN STD_LOGIC_VECTOR (81 DOWNTO 0);
        signal msi_stream_ready0 : IN STD_LOGIC;
        signal test_sim : IN STD_LOGIC;
        signal cfg_busdev : IN STD_LOGIC_VECTOR (12 DOWNTO 0);
        signal tx_stream_cred0 : IN STD_LOGIC_VECTOR (35 DOWNTO 0);
        signal tx_stream_ready0 : IN STD_LOGIC;
        signal rx_stream_data0_1 : IN STD_LOGIC_VECTOR (81 DOWNTO 0);
        signal rstn : IN STD_LOGIC;
        signal app_int_ack : IN STD_LOGIC;
        signal tx_stream_fifo_empty0 : IN STD_LOGIC;
        signal cfg_tcvcmap : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
        signal cfg_devcsr : IN STD_LOGIC_VECTOR (31 DOWNTO 0)
      );
  end component altpcierd_example_app_chaining;
                signal app_int_ack_icm :  STD_LOGIC;
                signal app_int_sts_icm :  STD_LOGIC;
                signal app_msi_ack :  STD_LOGIC;
                signal app_msi_num :  STD_LOGIC_VECTOR (4 DOWNTO 0);
                signal app_msi_req :  STD_LOGIC;
                signal app_msi_tc :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal cfg_busdev_icm :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal cfg_devcsr_icm :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cfg_io_bas :  STD_LOGIC_VECTOR (19 DOWNTO 0);
                signal cfg_linkcsr_icm :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cfg_msicsr :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal cfg_np_bas :  STD_LOGIC_VECTOR (11 DOWNTO 0);
                signal cfg_pr_bas :  STD_LOGIC_VECTOR (43 DOWNTO 0);
                signal cfg_prmcsr_icm :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpl_err_icm :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal cpl_err_in :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal cpl_pending_icm :  STD_LOGIC;
                signal dl_ltssm :  STD_LOGIC_VECTOR (4 DOWNTO 0);
                signal err_desc :  STD_LOGIC_VECTOR (127 DOWNTO 0);
                signal fixedclk_serdes :  STD_LOGIC;
                signal gnd_cfg_tcvcmap_icm :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal gnd_msi_stream_ready0 :  STD_LOGIC;
                signal gnd_pm_data :  STD_LOGIC_VECTOR (9 DOWNTO 0);
                signal gnd_rx_stream_data0_1 :  STD_LOGIC_VECTOR (81 DOWNTO 0);
                signal gnd_tx_stream_mask0 :  STD_LOGIC;
                signal internal_clk250_out :  STD_LOGIC;
                signal internal_clk500_out :  STD_LOGIC;
                signal internal_core_clk_out :  STD_LOGIC;
                signal internal_powerdown_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_rate_ext :  STD_LOGIC;
                signal internal_rc_pll_locked :  STD_LOGIC;
                signal internal_rxpolarity0_ext :  STD_LOGIC;
                signal internal_rxpolarity1_ext :  STD_LOGIC;
                signal internal_rxpolarity2_ext :  STD_LOGIC;
                signal internal_rxpolarity3_ext :  STD_LOGIC;
                signal internal_tx_out0 :  STD_LOGIC;
                signal internal_tx_out1 :  STD_LOGIC;
                signal internal_tx_out2 :  STD_LOGIC;
                signal internal_tx_out3 :  STD_LOGIC;
                signal internal_txcompl0_ext :  STD_LOGIC;
                signal internal_txcompl1_ext :  STD_LOGIC;
                signal internal_txcompl2_ext :  STD_LOGIC;
                signal internal_txcompl3_ext :  STD_LOGIC;
                signal internal_txdata0_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal internal_txdata1_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal internal_txdata2_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal internal_txdata3_ext :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal internal_txdatak0_ext :  STD_LOGIC;
                signal internal_txdatak1_ext :  STD_LOGIC;
                signal internal_txdatak2_ext :  STD_LOGIC;
                signal internal_txdatak3_ext :  STD_LOGIC;
                signal internal_txdetectrx_ext :  STD_LOGIC;
                signal internal_txelecidle0_ext :  STD_LOGIC;
                signal internal_txelecidle1_ext :  STD_LOGIC;
                signal internal_txelecidle2_ext :  STD_LOGIC;
                signal internal_txelecidle3_ext :  STD_LOGIC;
                signal ko_cpl_spc_vc0 :  STD_LOGIC_VECTOR (19 DOWNTO 0);
                signal lane_act :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal lmi_ack :  STD_LOGIC;
                signal lmi_addr :  STD_LOGIC_VECTOR (11 DOWNTO 0);
                signal lmi_din :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal lmi_dout :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal lmi_rden :  STD_LOGIC;
                signal lmi_wren :  STD_LOGIC;
                signal open_aer_msi_num :  STD_LOGIC_VECTOR (4 DOWNTO 0);
                signal open_cfg_tcvcmap :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal open_cplerr_lmi_busy :  STD_LOGIC;
                signal open_msi_stream_data0 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal open_msi_stream_valid0 :  STD_LOGIC;
                signal open_pm_data :  STD_LOGIC_VECTOR (9 DOWNTO 0);
                signal open_rx_st_err0 :  STD_LOGIC;
                signal open_tx_stream_data0_1 :  STD_LOGIC_VECTOR (74 DOWNTO 0);
                signal otb0 :  STD_LOGIC;
                signal otb1 :  STD_LOGIC;
                signal pex_msi_num_icm :  STD_LOGIC_VECTOR (4 DOWNTO 0);
                signal pme_to_sr :  STD_LOGIC;
                signal reconfig_clk :  STD_LOGIC;
                signal reconfig_clk_locked :  STD_LOGIC;
                signal rx_mask0 :  STD_LOGIC;
                signal rx_st_bardec0 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rx_st_be0 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rx_st_data0 :  STD_LOGIC_VECTOR (63 DOWNTO 0);
                signal rx_st_eop0 :  STD_LOGIC;
                signal rx_st_sop0 :  STD_LOGIC;
                signal rx_stream_data0 :  STD_LOGIC_VECTOR (81 DOWNTO 0);
                signal rx_stream_ready0 :  STD_LOGIC;
                signal rx_stream_valid0 :  STD_LOGIC;
                signal srstn :  STD_LOGIC;
                signal test_out_int :  STD_LOGIC_VECTOR (8 DOWNTO 0);
                signal tl_cfg_add :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal tl_cfg_ctl :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal tl_cfg_ctl_wr :  STD_LOGIC;
                signal tl_cfg_sts :  STD_LOGIC_VECTOR (52 DOWNTO 0);
                signal tl_cfg_sts_wr :  STD_LOGIC;
                signal tx_fifo_empty0 :  STD_LOGIC;
                signal tx_st_data0 :  STD_LOGIC_VECTOR (63 DOWNTO 0);
                signal tx_st_eop0 :  STD_LOGIC;
                signal tx_st_err0 :  STD_LOGIC;
                signal tx_st_sop0 :  STD_LOGIC;
                signal tx_stream_cred0 :  STD_LOGIC_VECTOR (35 DOWNTO 0);
                signal tx_stream_data0 :  STD_LOGIC_VECTOR (74 DOWNTO 0);
                signal tx_stream_ready0 :  STD_LOGIC;
                signal tx_stream_valid0 :  STD_LOGIC;

begin

  ref_clk_sel_code <= std_logic_vector'("0000");
  lane_width_code <= std_logic_vector'("0010");
  phy_sel_code <= std_logic_vector'("0110");
  otb0 <= std_logic'('0');
  otb1 <= std_logic'('1');
  gnd_pm_data <= std_logic_vector'("0000000000");
  ko_cpl_spc_vc0(7 DOWNTO 0) <= std_logic_vector'("00011100");
  ko_cpl_spc_vc0(19 DOWNTO 8) <= std_logic_vector'("000001110000");
  gnd_cfg_tcvcmap_icm <= std_logic_vector'("000000000000000000000000");
  tx_st_sop0 <= tx_stream_data0(73);
  tx_st_err0 <= tx_stream_data0(74);
  rx_stream_data0 <= rx_st_be0 & A_ToStdLogicVector(rx_st_sop0) & A_ToStdLogicVector(rx_st_eop0) & rx_st_bardec0 & rx_st_data0;
  tx_st_data0 <= tx_stream_data0(63 DOWNTO 0);
  tx_st_eop0 <= tx_stream_data0(72);
  test_out_icm <= test_out_int;
  pcie_reconfig_busy <= std_logic'('1');
  gnd_rx_stream_data0_1 <= std_logic_vector'("000000000000000000000000000000000000000000000000000000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(std_logic'('0')));
  gnd_tx_stream_mask0 <= std_logic'('0');
  gnd_msi_stream_ready0 <= std_logic'('0');
  ep_plus : pcie_phy_plus
    port map(
            app_int_ack => app_int_ack_icm,
            app_int_sts => app_int_sts_icm,
            app_msi_ack => app_msi_ack,
            app_msi_num => app_msi_num,
            app_msi_req => app_msi_req,
            app_msi_tc => app_msi_tc,
            clk250_out => internal_clk250_out,
            clk500_out => internal_clk500_out,
            core_clk_out => internal_core_clk_out,
            cpl_err => cpl_err_icm,
            cpl_pending => cpl_pending_icm,
            fixedclk_serdes => fixedclk_serdes,
            lane_act => lane_act,
            lmi_ack => lmi_ack,
            lmi_addr => lmi_addr,
            lmi_din => lmi_din,
            lmi_dout => lmi_dout,
            lmi_rden => lmi_rden,
            lmi_wren => lmi_wren,
            local_rstn => local_rstn,
            ltssm => dl_ltssm,
            pcie_rstn => pcie_rstn,
            pclk_in => pclk_in,
            pex_msi_num => pex_msi_num_icm,
            phystatus_ext => phystatus_ext,
            pipe_mode => pipe_mode,
            pld_clk => pld_clk,
            pm_auxpwr => std_logic'('0'),
            pm_data => gnd_pm_data,
            pm_event => std_logic'('0'),
            pme_to_cr => pme_to_sr,
            pme_to_sr => pme_to_sr,
            powerdown_ext => internal_powerdown_ext,
            rate_ext => internal_rate_ext,
            rc_pll_locked => internal_rc_pll_locked,
            reconfig_clk => reconfig_clk,
            reconfig_clk_locked => reconfig_clk_locked,
            refclk => refclk,
            rx_in0 => rx_in0,
            rx_in1 => rx_in1,
            rx_in2 => rx_in2,
            rx_in3 => rx_in3,
            rx_st_bardec0 => rx_st_bardec0,
            rx_st_be0 => rx_st_be0(7 DOWNTO 0),
            rx_st_data0 => rx_st_data0(63 DOWNTO 0),
            rx_st_eop0 => rx_st_eop0,
            rx_st_err0 => open_rx_st_err0,
            rx_st_mask0 => rx_mask0,
            rx_st_ready0 => rx_stream_ready0,
            rx_st_sop0 => rx_st_sop0,
            rx_st_valid0 => rx_stream_valid0,
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
            rxpolarity0_ext => internal_rxpolarity0_ext,
            rxpolarity1_ext => internal_rxpolarity1_ext,
            rxpolarity2_ext => internal_rxpolarity2_ext,
            rxpolarity3_ext => internal_rxpolarity3_ext,
            rxstatus0_ext => rxstatus0_ext,
            rxstatus1_ext => rxstatus1_ext,
            rxstatus2_ext => rxstatus2_ext,
            rxstatus3_ext => rxstatus3_ext,
            rxvalid0_ext => rxvalid0_ext,
            rxvalid1_ext => rxvalid1_ext,
            rxvalid2_ext => rxvalid2_ext,
            rxvalid3_ext => rxvalid3_ext,
            srstn => srstn,
            test_in => test_in,
            test_out => test_out_int,
            tl_cfg_add => tl_cfg_add,
            tl_cfg_ctl => tl_cfg_ctl,
            tl_cfg_ctl_wr => tl_cfg_ctl_wr,
            tl_cfg_sts => tl_cfg_sts,
            tl_cfg_sts_wr => tl_cfg_sts_wr,
            tx_cred0 => tx_stream_cred0,
            tx_fifo_empty0 => tx_fifo_empty0,
            tx_out0 => internal_tx_out0,
            tx_out1 => internal_tx_out1,
            tx_out2 => internal_tx_out2,
            tx_out3 => internal_tx_out3,
            tx_st_data0 => tx_st_data0(63 DOWNTO 0),
            tx_st_eop0 => tx_st_eop0,
            tx_st_err0 => tx_st_err0,
            tx_st_ready0 => tx_stream_ready0,
            tx_st_sop0 => tx_st_sop0,
            tx_st_valid0 => tx_stream_valid0,
            txcompl0_ext => internal_txcompl0_ext,
            txcompl1_ext => internal_txcompl1_ext,
            txcompl2_ext => internal_txcompl2_ext,
            txcompl3_ext => internal_txcompl3_ext,
            txdata0_ext => internal_txdata0_ext,
            txdata1_ext => internal_txdata1_ext,
            txdata2_ext => internal_txdata2_ext,
            txdata3_ext => internal_txdata3_ext,
            txdatak0_ext => internal_txdatak0_ext,
            txdatak1_ext => internal_txdatak1_ext,
            txdatak2_ext => internal_txdatak2_ext,
            txdatak3_ext => internal_txdatak3_ext,
            txdetectrx_ext => internal_txdetectrx_ext,
            txelecidle0_ext => internal_txelecidle0_ext,
            txelecidle1_ext => internal_txelecidle1_ext,
            txelecidle2_ext => internal_txelecidle2_ext,
            txelecidle3_ext => internal_txelecidle3_ext
    );

  reconfig_pll : altpcierd_reconfig_clk_pll
    port map(
            c0 => reconfig_clk,
            c1 => fixedclk_serdes,
            inclk0 => free_100MHz,
            locked => reconfig_clk_locked
    );

  cfgbus : altpcierd_tl_cfg_sample
    generic map(
      HIP_SV => 0
    )
    port map(
            cfg_busdev => cfg_busdev_icm,
            cfg_devcsr => cfg_devcsr_icm,
            cfg_io_bas => cfg_io_bas,
            cfg_linkcsr => cfg_linkcsr_icm,
            cfg_msicsr => cfg_msicsr,
            cfg_np_bas => cfg_np_bas,
            cfg_pr_bas => cfg_pr_bas,
            cfg_prmcsr => cfg_prmcsr_icm,
            cfg_tcvcmap => open_cfg_tcvcmap,
            pld_clk => pld_clk,
            rstn => srstn,
            tl_cfg_add => tl_cfg_add,
            tl_cfg_ctl => tl_cfg_ctl,
            tl_cfg_ctl_wr => tl_cfg_ctl_wr,
            tl_cfg_sts => tl_cfg_sts,
            tl_cfg_sts_wr => tl_cfg_sts_wr
    );

  lmi_blk : altpcierd_cplerr_lmi
    port map(
            clk_in => pld_clk,
            cpl_err_in => cpl_err_in,
            cpl_err_out => cpl_err_icm,
            cplerr_lmi_busy => open_cplerr_lmi_busy,
            err_desc => err_desc,
            lmi_ack => lmi_ack,
            lmi_addr => lmi_addr,
            lmi_din => lmi_din,
            lmi_rden => lmi_rden,
            lmi_wren => lmi_wren,
            rstn => srstn
    );

  app : altpcierd_example_app_chaining
    generic map(
      AVALON_WADDR => 12,
      CHECK_BUS_MASTER_ENA => 1,
      CHECK_RX_BUFFER_CPL => 1,
      CLK_250_APP => 0,
      ECRC_FORWARD_CHECK => 0,
      ECRC_FORWARD_GENER => 0,
      MAX_NUMTAG => 32,
      MAX_PAYLOAD_SIZE_BYTE => 256,
      TL_SELECTION => 6,
      TXCRED_WIDTH => 36
    )
    port map(
            aer_msi_num => open_aer_msi_num,
            app_int_ack => app_int_ack_icm,
            app_int_sts => app_int_sts_icm,
            app_msi_ack => app_msi_ack,
            app_msi_num => app_msi_num,
            app_msi_req => app_msi_req,
            app_msi_tc => app_msi_tc,
            cfg_busdev => cfg_busdev_icm,
            cfg_devcsr => cfg_devcsr_icm,
            cfg_linkcsr => cfg_linkcsr_icm,
            cfg_msicsr => cfg_msicsr,
            cfg_prmcsr => cfg_prmcsr_icm,
            cfg_tcvcmap => gnd_cfg_tcvcmap_icm,
            clk_in => pld_clk,
            cpl_err => cpl_err_in,
            cpl_pending => cpl_pending_icm,
            err_desc => err_desc,
            ko_cpl_spc_vc0 => ko_cpl_spc_vc0,
            msi_stream_data0 => open_msi_stream_data0,
            msi_stream_ready0 => gnd_msi_stream_ready0,
            msi_stream_valid0 => open_msi_stream_valid0,
            pex_msi_num => pex_msi_num_icm,
            pm_data => open_pm_data,
            rstn => srstn,
            rx_stream_data0_0 => rx_stream_data0,
            rx_stream_data0_1 => gnd_rx_stream_data0_1,
            rx_stream_mask0 => rx_mask0,
            rx_stream_ready0 => rx_stream_ready0,
            rx_stream_valid0 => rx_stream_valid0,
            test_sim => test_in(0),
            tx_stream_cred0 => tx_stream_cred0,
            tx_stream_data0_0 => tx_stream_data0,
            tx_stream_data0_1 => open_tx_stream_data0_1,
            tx_stream_fifo_empty0 => tx_fifo_empty0,
            tx_stream_mask0 => gnd_tx_stream_mask0,
            tx_stream_ready0 => tx_stream_ready0,
            tx_stream_valid0 => tx_stream_valid0
    );

  --vhdl renameroo for output signals
  clk250_out <= internal_clk250_out;
  --vhdl renameroo for output signals
  clk500_out <= internal_clk500_out;
  --vhdl renameroo for output signals
  core_clk_out <= internal_core_clk_out;
  --vhdl renameroo for output signals
  powerdown_ext <= internal_powerdown_ext;
  --vhdl renameroo for output signals
  rate_ext <= internal_rate_ext;
  --vhdl renameroo for output signals
  rc_pll_locked <= internal_rc_pll_locked;
  --vhdl renameroo for output signals
  rxpolarity0_ext <= internal_rxpolarity0_ext;
  --vhdl renameroo for output signals
  rxpolarity1_ext <= internal_rxpolarity1_ext;
  --vhdl renameroo for output signals
  rxpolarity2_ext <= internal_rxpolarity2_ext;
  --vhdl renameroo for output signals
  rxpolarity3_ext <= internal_rxpolarity3_ext;
  --vhdl renameroo for output signals
  tx_out0 <= internal_tx_out0;
  --vhdl renameroo for output signals
  tx_out1 <= internal_tx_out1;
  --vhdl renameroo for output signals
  tx_out2 <= internal_tx_out2;
  --vhdl renameroo for output signals
  tx_out3 <= internal_tx_out3;
  --vhdl renameroo for output signals
  txcompl0_ext <= internal_txcompl0_ext;
  --vhdl renameroo for output signals
  txcompl1_ext <= internal_txcompl1_ext;
  --vhdl renameroo for output signals
  txcompl2_ext <= internal_txcompl2_ext;
  --vhdl renameroo for output signals
  txcompl3_ext <= internal_txcompl3_ext;
  --vhdl renameroo for output signals
  txdata0_ext <= internal_txdata0_ext;
  --vhdl renameroo for output signals
  txdata1_ext <= internal_txdata1_ext;
  --vhdl renameroo for output signals
  txdata2_ext <= internal_txdata2_ext;
  --vhdl renameroo for output signals
  txdata3_ext <= internal_txdata3_ext;
  --vhdl renameroo for output signals
  txdatak0_ext <= internal_txdatak0_ext;
  --vhdl renameroo for output signals
  txdatak1_ext <= internal_txdatak1_ext;
  --vhdl renameroo for output signals
  txdatak2_ext <= internal_txdatak2_ext;
  --vhdl renameroo for output signals
  txdatak3_ext <= internal_txdatak3_ext;
  --vhdl renameroo for output signals
  txdetectrx_ext <= internal_txdetectrx_ext;
  --vhdl renameroo for output signals
  txelecidle0_ext <= internal_txelecidle0_ext;
  --vhdl renameroo for output signals
  txelecidle1_ext <= internal_txelecidle1_ext;
  --vhdl renameroo for output signals
  txelecidle2_ext <= internal_txelecidle2_ext;
  --vhdl renameroo for output signals
  txelecidle3_ext <= internal_txelecidle3_ext;

end europa;

