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

--/** This VHDL file generates the Incremental Compilation Wrapper that is used for simulation and synthesis
--*/
entity pcie_phy_icm is 
        port (
              -- inputs:
                 signal app_int_sts_icm : IN STD_LOGIC;
                 signal busy_altgxb_reconfig : IN STD_LOGIC;
                 signal cal_blk_clk : IN STD_LOGIC;
                 signal clk125_in : IN STD_LOGIC;
                 signal cpl_err_icm : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                 signal cpl_pending_icm : IN STD_LOGIC;
                 signal crst : IN STD_LOGIC;
                 signal fixedclk_serdes : IN STD_LOGIC;
                 signal gxb_powerdown : IN STD_LOGIC;
                 signal msi_stream_data0 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal msi_stream_valid0 : IN STD_LOGIC;
                 signal npor : IN STD_LOGIC;
                 signal pex_msi_num_icm : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
                 signal phystatus_ext : IN STD_LOGIC;
                 signal pipe_mode : IN STD_LOGIC := std_logic'('0');
                 signal pll_powerdown : IN STD_LOGIC;
                 signal pme_to_cr : IN STD_LOGIC;
                 signal reconfig_clk : IN STD_LOGIC;
                 signal reconfig_togxb : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal refclk : IN STD_LOGIC;
                 signal rstn : IN STD_LOGIC;
                 signal rx_in0 : IN STD_LOGIC := std_logic'('0');
                 signal rx_in1 : IN STD_LOGIC := std_logic'('0');
                 signal rx_in2 : IN STD_LOGIC := std_logic'('0');
                 signal rx_in3 : IN STD_LOGIC := std_logic'('0');
                 signal rx_stream_mask0 : IN STD_LOGIC;
                 signal rx_stream_ready0 : IN STD_LOGIC;
                 signal rxdata0_ext : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal rxdata1_ext : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal rxdata2_ext : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal rxdata3_ext : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal rxdatak0_ext : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal rxdatak1_ext : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal rxdatak2_ext : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal rxdatak3_ext : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
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
                 signal srst : IN STD_LOGIC;
                 signal test_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal tx_stream_data0 : IN STD_LOGIC_VECTOR (74 DOWNTO 0);
                 signal tx_stream_valid0 : IN STD_LOGIC;

              -- outputs:
                 signal app_int_sts_ack_icm : OUT STD_LOGIC;
                 signal cfg_busdev_icm : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                 signal cfg_devcsr_icm : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cfg_linkcsr_icm : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cfg_msicsr_icm : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cfg_prmcsr_icm : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk125_out : OUT STD_LOGIC;
                 signal dlup_exit : OUT STD_LOGIC;
                 signal hotrst_exit : OUT STD_LOGIC;
                 signal l2_exit : OUT STD_LOGIC;
                 signal lane_width_code : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal msi_stream_ready0 : OUT STD_LOGIC;
                 signal phy_sel_code : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal pme_to_sr : OUT STD_LOGIC;
                 signal powerdown_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal reconfig_fromgxb : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
                 signal ref_clk_sel_code : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal rx_stream_data0 : OUT STD_LOGIC_VECTOR (81 DOWNTO 0);
                 signal rx_stream_valid0 : OUT STD_LOGIC;
                 signal rxpolarity0_ext : OUT STD_LOGIC;
                 signal rxpolarity1_ext : OUT STD_LOGIC;
                 signal rxpolarity2_ext : OUT STD_LOGIC;
                 signal rxpolarity3_ext : OUT STD_LOGIC;
                 signal test_out_icm : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                 signal tx_out0 : OUT STD_LOGIC;
                 signal tx_out1 : OUT STD_LOGIC;
                 signal tx_out2 : OUT STD_LOGIC;
                 signal tx_out3 : OUT STD_LOGIC;
                 signal tx_stream_cred0 : OUT STD_LOGIC_VECTOR (21 DOWNTO 0);
                 signal tx_stream_mask0 : OUT STD_LOGIC;
                 signal tx_stream_ready0 : OUT STD_LOGIC;
                 signal txcompl0_ext : OUT STD_LOGIC;
                 signal txcompl1_ext : OUT STD_LOGIC;
                 signal txcompl2_ext : OUT STD_LOGIC;
                 signal txcompl3_ext : OUT STD_LOGIC;
                 signal txdata0_ext : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal txdata1_ext : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal txdata2_ext : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal txdata3_ext : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal txdatak0_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal txdatak1_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal txdatak2_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal txdatak3_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal txdetectrx_ext : OUT STD_LOGIC;
                 signal txelecidle0_ext : OUT STD_LOGIC;
                 signal txelecidle1_ext : OUT STD_LOGIC;
                 signal txelecidle2_ext : OUT STD_LOGIC;
                 signal txelecidle3_ext : OUT STD_LOGIC
              );
end entity pcie_phy_icm;


architecture europa of pcie_phy_icm is
  component pcie_phy is
PORT (
    signal cfg_pmcsr : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal ko_cpl_spc_vc0 : OUT STD_LOGIC_VECTOR (19 DOWNTO 0);
        signal clk125_out : OUT STD_LOGIC;
        signal txcompl1_ext : OUT STD_LOGIC;
        signal l2_exit : OUT STD_LOGIC;
        signal app_msi_ack : OUT STD_LOGIC;
        signal rx_req0 : OUT STD_LOGIC;
        signal rx_dv0 : OUT STD_LOGIC;
        signal txdatak1_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal txelecidle0_ext : OUT STD_LOGIC;
        signal cfg_busdev : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
        signal test_out : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
        signal txelecidle2_ext : OUT STD_LOGIC;
        signal txdatak2_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal tx_out0 : OUT STD_LOGIC;
        signal rxpolarity0_ext : OUT STD_LOGIC;
        signal tx_out2 : OUT STD_LOGIC;
        signal txelecidle3_ext : OUT STD_LOGIC;
        signal txdatak3_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal rx_desc0 : OUT STD_LOGIC_VECTOR (135 DOWNTO 0);
        signal txcompl3_ext : OUT STD_LOGIC;
        signal txelecidle1_ext : OUT STD_LOGIC;
        signal powerdown_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal cfg_prmcsr : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal cfg_msicsr : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        signal tx_out3 : OUT STD_LOGIC;
        signal cfg_linkcsr : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal tx_ack0 : OUT STD_LOGIC;
        signal rx_data0 : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
        signal hotrst_exit : OUT STD_LOGIC;
        signal rxpolarity2_ext : OUT STD_LOGIC;
        signal tx_out1 : OUT STD_LOGIC;
        signal txdata0_ext : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        signal rxpolarity3_ext : OUT STD_LOGIC;
        signal txcompl2_ext : OUT STD_LOGIC;
        signal rxpolarity1_ext : OUT STD_LOGIC;
        signal txdata1_ext : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        signal pme_to_sr : OUT STD_LOGIC;
        signal txdata2_ext : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        signal txdata3_ext : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        signal dlup_exit : OUT STD_LOGIC;
        signal reconfig_fromgxb : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal txdatak0_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal txdetectrx_ext : OUT STD_LOGIC;
        signal rx_be0 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal tx_ws0 : OUT STD_LOGIC;
        signal txcompl0_ext : OUT STD_LOGIC;
        signal tx_cred0 : OUT STD_LOGIC_VECTOR (21 DOWNTO 0);
        signal app_int_ack : OUT STD_LOGIC;
        signal rx_dfr0 : OUT STD_LOGIC;
        signal cfg_tcvcmap : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
        signal cfg_devcsr : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal pex_msi_num : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal rxdatak2_ext : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal app_msi_tc : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal pipe_mode : IN STD_LOGIC;
        signal cal_blk_clk : IN STD_LOGIC;
        signal tx_data0 : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        signal rx_ws0 : IN STD_LOGIC;
        signal rxstatus3_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal reconfig_clk : IN STD_LOGIC;
        signal app_msi_req : IN STD_LOGIC;
        signal app_msi_num : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal gxb_powerdown : IN STD_LOGIC;
        signal refclk : IN STD_LOGIC;
        signal rxstatus0_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal rxelecidle0_ext : IN STD_LOGIC;
        signal busy_altgxb_reconfig : IN STD_LOGIC;
        signal tx_dv0 : IN STD_LOGIC;
        signal rxelecidle3_ext : IN STD_LOGIC;
        signal rxstatus2_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal rx_in1 : IN STD_LOGIC;
        signal pll_powerdown : IN STD_LOGIC;
        signal rxdatak1_ext : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal reconfig_togxb : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal rx_in0 : IN STD_LOGIC;
        signal rxdatak0_ext : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal rxelecidle1_ext : IN STD_LOGIC;
        signal rxdata1_ext : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        signal rxvalid1_ext : IN STD_LOGIC;
        signal rx_in2 : IN STD_LOGIC;
        signal rx_in3 : IN STD_LOGIC;
        signal rxdatak3_ext : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal tx_dfr0 : IN STD_LOGIC;
        signal crst : IN STD_LOGIC;
        signal test_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal rx_mask0 : IN STD_LOGIC;
        signal tx_req0 : IN STD_LOGIC;
        signal phystatus_ext : IN STD_LOGIC;
        signal rx_retry0 : IN STD_LOGIC;
        signal cpl_err : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
        signal rxdata3_ext : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        signal rx_ack0 : IN STD_LOGIC;
        signal rxelecidle2_ext : IN STD_LOGIC;
        signal rxstatus1_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal pme_to_cr : IN STD_LOGIC;
        signal rxdata0_ext : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        signal rxvalid3_ext : IN STD_LOGIC;
        signal rxvalid2_ext : IN STD_LOGIC;
        signal npor : IN STD_LOGIC;
        signal clk125_in : IN STD_LOGIC;
        signal tx_err0 : IN STD_LOGIC;
        signal fixedclk_serdes : IN STD_LOGIC;
        signal rxdata2_ext : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        signal rx_abort0 : IN STD_LOGIC;
        signal srst : IN STD_LOGIC;
        signal app_int_sts : IN STD_LOGIC;
        signal rxvalid0_ext : IN STD_LOGIC;
        signal tx_desc0 : IN STD_LOGIC_VECTOR (127 DOWNTO 0);
        signal cpl_pending : IN STD_LOGIC
      );
  end component pcie_phy;
  component altpcierd_icm_top is
GENERIC (
      TXCRED_WIDTH : NATURAL
      );
    PORT (
    signal pex_msi_num : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal app_msi_tc : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal tx_stream_mask0 : OUT STD_LOGIC;
        signal tx_data0 : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
        signal rx_ws0 : OUT STD_LOGIC;
        signal cfg_linkcsr_icm : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal app_msi_req : OUT STD_LOGIC;
        signal app_msi_num : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal tx_dv0 : OUT STD_LOGIC;
        signal tx_stream_cred0 : OUT STD_LOGIC_VECTOR (21 DOWNTO 0);
        signal tx_stream_ready0 : OUT STD_LOGIC;
        signal app_int_sts_ack_icm : OUT STD_LOGIC;
        signal cfg_devcsr_icm : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal tx_dfr0 : OUT STD_LOGIC;
        signal cfg_busdev_icm : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
        signal tx_req0 : OUT STD_LOGIC;
        signal rx_mask0 : OUT STD_LOGIC;
        signal rx_retry0 : OUT STD_LOGIC;
        signal rx_stream_valid0 : OUT STD_LOGIC;
        signal cpl_err : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal cfg_tcvcmap_icm : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
        signal rx_ack0 : OUT STD_LOGIC;
        signal cfg_prmcsr_icm : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal cfg_msicsr_icm : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        signal msi_stream_ready0 : OUT STD_LOGIC;
        signal rx_stream_data0 : OUT STD_LOGIC_VECTOR (81 DOWNTO 0);
        signal tx_err0 : OUT STD_LOGIC;
        signal test_out_icm : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
        signal rx_abort0 : OUT STD_LOGIC;
        signal app_int_sts : OUT STD_LOGIC;
        signal tx_desc0 : OUT STD_LOGIC_VECTOR (127 DOWNTO 0);
        signal cpl_pending : OUT STD_LOGIC;
        signal app_int_sts_ack : IN STD_LOGIC;
        signal app_int_sts_icm : IN STD_LOGIC;
        signal tx_npcredd_inf0 : IN STD_LOGIC;
        signal app_msi_ack : IN STD_LOGIC;
        signal msi_stream_data0 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal tx_npcredh0 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rx_dv0 : IN STD_LOGIC;
        signal rx_req0 : IN STD_LOGIC;
        signal rx_stream_ready0 : IN STD_LOGIC;
        signal cfg_busdev : IN STD_LOGIC_VECTOR (12 DOWNTO 0);
        signal test_out : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
        signal tx_npcredd0 : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
        signal rx_desc0 : IN STD_LOGIC_VECTOR (135 DOWNTO 0);
        signal tx_stream_valid0 : IN STD_LOGIC;
        signal pex_msi_num_icm : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal clk : IN STD_LOGIC;
        signal cfg_prmcsr : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal cfg_msicsr : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        signal cfg_linkcsr : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal tx_ack0 : IN STD_LOGIC;
        signal msi_stream_valid0 : IN STD_LOGIC;
        signal rx_data0 : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        signal cpl_err_icm : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal cpl_pending_icm : IN STD_LOGIC;
        signal tx_stream_data0 : IN STD_LOGIC_VECTOR (74 DOWNTO 0);
        signal rstn : IN STD_LOGIC;
        signal rx_be0 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal tx_ws0 : IN STD_LOGIC;
        signal tx_cred0 : IN STD_LOGIC_VECTOR (21 DOWNTO 0);
        signal rx_stream_mask0 : IN STD_LOGIC;
        signal rx_dfr0 : IN STD_LOGIC;
        signal cfg_tcvcmap : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
        signal tx_npcredh_inf0 : IN STD_LOGIC;
        signal cfg_devcsr : IN STD_LOGIC_VECTOR (31 DOWNTO 0)
      );
  end component altpcierd_icm_top;
                signal app_int_ack :  STD_LOGIC;
                signal app_int_sts :  STD_LOGIC;
                signal app_msi_ack :  STD_LOGIC;
                signal app_msi_num :  STD_LOGIC_VECTOR (4 DOWNTO 0);
                signal app_msi_req :  STD_LOGIC;
                signal app_msi_tc :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal cfg_busdev :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal cfg_devcsr :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cfg_linkcsr :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cfg_msicsr :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal cfg_prmcsr :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cfg_tcvcmap :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal cpl_err :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal cpl_err_icm_int :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal cpl_err_int :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal cpl_pending :  STD_LOGIC;
                signal internal_app_int_sts_ack_icm :  STD_LOGIC;
                signal internal_cfg_busdev_icm :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal internal_cfg_devcsr_icm :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_cfg_linkcsr_icm :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_cfg_msicsr_icm :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_cfg_prmcsr_icm :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_clk125_out :  STD_LOGIC;
                signal internal_dlup_exit :  STD_LOGIC;
                signal internal_hotrst_exit :  STD_LOGIC;
                signal internal_l2_exit :  STD_LOGIC;
                signal internal_msi_stream_ready0 :  STD_LOGIC;
                signal internal_pme_to_sr :  STD_LOGIC;
                signal internal_powerdown_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_reconfig_fromgxb :  STD_LOGIC_VECTOR (4 DOWNTO 0);
                signal internal_rx_stream_data0 :  STD_LOGIC_VECTOR (81 DOWNTO 0);
                signal internal_rx_stream_valid0 :  STD_LOGIC;
                signal internal_rxpolarity0_ext :  STD_LOGIC;
                signal internal_rxpolarity1_ext :  STD_LOGIC;
                signal internal_rxpolarity2_ext :  STD_LOGIC;
                signal internal_rxpolarity3_ext :  STD_LOGIC;
                signal internal_test_out_icm :  STD_LOGIC_VECTOR (8 DOWNTO 0);
                signal internal_tx_out0 :  STD_LOGIC;
                signal internal_tx_out1 :  STD_LOGIC;
                signal internal_tx_out2 :  STD_LOGIC;
                signal internal_tx_out3 :  STD_LOGIC;
                signal internal_tx_stream_cred0 :  STD_LOGIC_VECTOR (21 DOWNTO 0);
                signal internal_tx_stream_mask0 :  STD_LOGIC;
                signal internal_tx_stream_ready0 :  STD_LOGIC;
                signal internal_txcompl0_ext :  STD_LOGIC;
                signal internal_txcompl1_ext :  STD_LOGIC;
                signal internal_txcompl2_ext :  STD_LOGIC;
                signal internal_txcompl3_ext :  STD_LOGIC;
                signal internal_txdata0_ext :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_txdata1_ext :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_txdata2_ext :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_txdata3_ext :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_txdatak0_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_txdatak1_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_txdatak2_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_txdatak3_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_txdetectrx_ext :  STD_LOGIC;
                signal internal_txelecidle0_ext :  STD_LOGIC;
                signal internal_txelecidle1_ext :  STD_LOGIC;
                signal internal_txelecidle2_ext :  STD_LOGIC;
                signal internal_txelecidle3_ext :  STD_LOGIC;
                signal open_cfg_pmcsr :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal open_cfg_tcvcmap_icm :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal open_ko_cpl_spc_vc0 :  STD_LOGIC_VECTOR (19 DOWNTO 0);
                signal pex_msi_num :  STD_LOGIC_VECTOR (4 DOWNTO 0);
                signal rx_abort0 :  STD_LOGIC;
                signal rx_ack0 :  STD_LOGIC;
                signal rx_be0 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal rx_data0 :  STD_LOGIC_VECTOR (63 DOWNTO 0);
                signal rx_desc0 :  STD_LOGIC_VECTOR (135 DOWNTO 0);
                signal rx_dfr0 :  STD_LOGIC;
                signal rx_dv0 :  STD_LOGIC;
                signal rx_mask0 :  STD_LOGIC;
                signal rx_req0 :  STD_LOGIC;
                signal rx_retry0 :  STD_LOGIC;
                signal rx_ws0 :  STD_LOGIC;
                signal test_in_int :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal test_out_int :  STD_LOGIC_VECTOR (8 DOWNTO 0);
                signal test_out_wire :  STD_LOGIC_VECTOR (8 DOWNTO 0);
                signal tx_ack0 :  STD_LOGIC;
                signal tx_cred0_int :  STD_LOGIC_VECTOR (21 DOWNTO 0);
                signal tx_data0 :  STD_LOGIC_VECTOR (63 DOWNTO 0);
                signal tx_desc0 :  STD_LOGIC_VECTOR (127 DOWNTO 0);
                signal tx_dfr0 :  STD_LOGIC;
                signal tx_dv0 :  STD_LOGIC;
                signal tx_err0 :  STD_LOGIC;
                signal tx_npcredd0 :  STD_LOGIC_VECTOR (11 DOWNTO 0);
                signal tx_npcredd_inf0 :  STD_LOGIC;
                signal tx_npcredh0 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal tx_npcredh_inf0 :  STD_LOGIC;
                signal tx_req0 :  STD_LOGIC;
                signal tx_ws0 :  STD_LOGIC;

begin

  ref_clk_sel_code <= std_logic_vector'("0000");
  lane_width_code <= std_logic_vector'("0010");
  phy_sel_code <= std_logic_vector'("0110");
  test_out_wire <= test_out_int;
  test_in_int <= Std_Logic_Vector'(std_logic_vector'("00000000000000000000000") & test_in(8 DOWNTO 5) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(test_in(3)) & std_logic_vector'("00") & A_ToStdLogicVector(test_in(0)));
  cpl_err <= cpl_err_int & std_logic_vector'("0000");
  cpl_err_icm_int <= cpl_err_icm(2 DOWNTO 0);
  tx_npcredh0 <= std_logic_vector'("0000000") & (A_TOSTDLOGICVECTOR(tx_cred0_int(10)));
  tx_npcredd0 <= std_logic_vector'("00000000000") & (A_TOSTDLOGICVECTOR(tx_cred0_int(11)));
  tx_npcredh_inf0 <= std_logic'('0');
  tx_npcredd_inf0 <= std_logic'('0');
  epmap : pcie_phy
    port map(
            app_int_ack => app_int_ack,
            app_int_sts => app_int_sts,
            app_msi_ack => app_msi_ack,
            app_msi_num => app_msi_num,
            app_msi_req => app_msi_req,
            app_msi_tc => app_msi_tc,
            busy_altgxb_reconfig => busy_altgxb_reconfig,
            cal_blk_clk => cal_blk_clk,
            cfg_busdev => cfg_busdev,
            cfg_devcsr => cfg_devcsr,
            cfg_linkcsr => cfg_linkcsr,
            cfg_msicsr => cfg_msicsr,
            cfg_pmcsr => open_cfg_pmcsr,
            cfg_prmcsr => cfg_prmcsr,
            cfg_tcvcmap => cfg_tcvcmap,
            clk125_in => clk125_in,
            clk125_out => internal_clk125_out,
            cpl_err => cpl_err,
            cpl_pending => cpl_pending,
            crst => crst,
            dlup_exit => internal_dlup_exit,
            fixedclk_serdes => fixedclk_serdes,
            gxb_powerdown => gxb_powerdown,
            hotrst_exit => internal_hotrst_exit,
            ko_cpl_spc_vc0 => open_ko_cpl_spc_vc0,
            l2_exit => internal_l2_exit,
            npor => npor,
            pex_msi_num => pex_msi_num,
            phystatus_ext => phystatus_ext,
            pipe_mode => pipe_mode,
            pll_powerdown => pll_powerdown,
            pme_to_cr => pme_to_cr,
            pme_to_sr => internal_pme_to_sr,
            powerdown_ext => internal_powerdown_ext,
            reconfig_clk => reconfig_clk,
            reconfig_fromgxb => internal_reconfig_fromgxb,
            reconfig_togxb => reconfig_togxb,
            refclk => refclk,
            rx_abort0 => rx_abort0,
            rx_ack0 => rx_ack0,
            rx_be0 => rx_be0,
            rx_data0 => rx_data0,
            rx_desc0 => rx_desc0,
            rx_dfr0 => rx_dfr0,
            rx_dv0 => rx_dv0,
            rx_in0 => rx_in0,
            rx_in1 => rx_in1,
            rx_in2 => rx_in2,
            rx_in3 => rx_in3,
            rx_mask0 => rx_mask0,
            rx_req0 => rx_req0,
            rx_retry0 => rx_retry0,
            rx_ws0 => rx_ws0,
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
            srst => srst,
            test_in => test_in_int,
            test_out => test_out_int,
            tx_ack0 => tx_ack0,
            tx_cred0 => tx_cred0_int,
            tx_data0 => tx_data0,
            tx_desc0 => tx_desc0,
            tx_dfr0 => tx_dfr0,
            tx_dv0 => tx_dv0,
            tx_err0 => tx_err0,
            tx_out0 => internal_tx_out0,
            tx_out1 => internal_tx_out1,
            tx_out2 => internal_tx_out2,
            tx_out3 => internal_tx_out3,
            tx_req0 => tx_req0,
            tx_ws0 => tx_ws0,
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

  icm : altpcierd_icm_top
    generic map(
      TXCRED_WIDTH => 22
    )
    port map(
            app_int_sts => app_int_sts,
            app_int_sts_ack => app_int_ack,
            app_int_sts_ack_icm => internal_app_int_sts_ack_icm,
            app_int_sts_icm => app_int_sts_icm,
            app_msi_ack => app_msi_ack,
            app_msi_num => app_msi_num,
            app_msi_req => app_msi_req,
            app_msi_tc => app_msi_tc,
            cfg_busdev => cfg_busdev,
            cfg_busdev_icm => internal_cfg_busdev_icm,
            cfg_devcsr => cfg_devcsr,
            cfg_devcsr_icm => internal_cfg_devcsr_icm,
            cfg_linkcsr => cfg_linkcsr,
            cfg_linkcsr_icm => internal_cfg_linkcsr_icm,
            cfg_msicsr => cfg_msicsr,
            cfg_msicsr_icm => internal_cfg_msicsr_icm,
            cfg_prmcsr => cfg_prmcsr,
            cfg_prmcsr_icm => internal_cfg_prmcsr_icm,
            cfg_tcvcmap => cfg_tcvcmap,
            cfg_tcvcmap_icm => open_cfg_tcvcmap_icm,
            clk => clk125_in,
            cpl_err => cpl_err_int,
            cpl_err_icm => cpl_err_icm_int,
            cpl_pending => cpl_pending,
            cpl_pending_icm => cpl_pending_icm,
            msi_stream_data0 => msi_stream_data0,
            msi_stream_ready0 => internal_msi_stream_ready0,
            msi_stream_valid0 => msi_stream_valid0,
            pex_msi_num => pex_msi_num,
            pex_msi_num_icm => pex_msi_num_icm,
            rstn => rstn,
            rx_abort0 => rx_abort0,
            rx_ack0 => rx_ack0,
            rx_be0 => rx_be0,
            rx_data0 => rx_data0,
            rx_desc0 => rx_desc0,
            rx_dfr0 => rx_dfr0,
            rx_dv0 => rx_dv0,
            rx_mask0 => rx_mask0,
            rx_req0 => rx_req0,
            rx_retry0 => rx_retry0,
            rx_stream_data0 => internal_rx_stream_data0,
            rx_stream_mask0 => rx_stream_mask0,
            rx_stream_ready0 => rx_stream_ready0,
            rx_stream_valid0 => internal_rx_stream_valid0,
            rx_ws0 => rx_ws0,
            test_out => test_out_wire,
            test_out_icm => internal_test_out_icm,
            tx_ack0 => tx_ack0,
            tx_cred0 => tx_cred0_int,
            tx_data0 => tx_data0,
            tx_desc0 => tx_desc0,
            tx_dfr0 => tx_dfr0,
            tx_dv0 => tx_dv0,
            tx_err0 => tx_err0,
            tx_npcredd0 => tx_npcredd0,
            tx_npcredd_inf0 => tx_npcredd_inf0,
            tx_npcredh0 => tx_npcredh0,
            tx_npcredh_inf0 => tx_npcredh_inf0,
            tx_req0 => tx_req0,
            tx_stream_cred0 => internal_tx_stream_cred0,
            tx_stream_data0 => tx_stream_data0,
            tx_stream_mask0 => internal_tx_stream_mask0,
            tx_stream_ready0 => internal_tx_stream_ready0,
            tx_stream_valid0 => tx_stream_valid0,
            tx_ws0 => tx_ws0
    );

  --vhdl renameroo for output signals
  app_int_sts_ack_icm <= internal_app_int_sts_ack_icm;
  --vhdl renameroo for output signals
  cfg_busdev_icm <= internal_cfg_busdev_icm;
  --vhdl renameroo for output signals
  cfg_devcsr_icm <= internal_cfg_devcsr_icm;
  --vhdl renameroo for output signals
  cfg_linkcsr_icm <= internal_cfg_linkcsr_icm;
  --vhdl renameroo for output signals
  cfg_msicsr_icm <= internal_cfg_msicsr_icm;
  --vhdl renameroo for output signals
  cfg_prmcsr_icm <= internal_cfg_prmcsr_icm;
  --vhdl renameroo for output signals
  clk125_out <= internal_clk125_out;
  --vhdl renameroo for output signals
  dlup_exit <= internal_dlup_exit;
  --vhdl renameroo for output signals
  hotrst_exit <= internal_hotrst_exit;
  --vhdl renameroo for output signals
  l2_exit <= internal_l2_exit;
  --vhdl renameroo for output signals
  msi_stream_ready0 <= internal_msi_stream_ready0;
  --vhdl renameroo for output signals
  pme_to_sr <= internal_pme_to_sr;
  --vhdl renameroo for output signals
  powerdown_ext <= internal_powerdown_ext;
  --vhdl renameroo for output signals
  reconfig_fromgxb <= internal_reconfig_fromgxb;
  --vhdl renameroo for output signals
  rx_stream_data0 <= internal_rx_stream_data0;
  --vhdl renameroo for output signals
  rx_stream_valid0 <= internal_rx_stream_valid0;
  --vhdl renameroo for output signals
  rxpolarity0_ext <= internal_rxpolarity0_ext;
  --vhdl renameroo for output signals
  rxpolarity1_ext <= internal_rxpolarity1_ext;
  --vhdl renameroo for output signals
  rxpolarity2_ext <= internal_rxpolarity2_ext;
  --vhdl renameroo for output signals
  rxpolarity3_ext <= internal_rxpolarity3_ext;
  --vhdl renameroo for output signals
  test_out_icm <= internal_test_out_icm;
  --vhdl renameroo for output signals
  tx_out0 <= internal_tx_out0;
  --vhdl renameroo for output signals
  tx_out1 <= internal_tx_out1;
  --vhdl renameroo for output signals
  tx_out2 <= internal_tx_out2;
  --vhdl renameroo for output signals
  tx_out3 <= internal_tx_out3;
  --vhdl renameroo for output signals
  tx_stream_cred0 <= internal_tx_stream_cred0;
  --vhdl renameroo for output signals
  tx_stream_mask0 <= internal_tx_stream_mask0;
  --vhdl renameroo for output signals
  tx_stream_ready0 <= internal_tx_stream_ready0;
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

