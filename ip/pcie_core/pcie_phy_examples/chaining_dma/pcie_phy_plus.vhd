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

--/** PCIe wrapper + 
--*/
entity pcie_phy_plus is 
        port (
              -- inputs:
                 signal app_int_sts : IN STD_LOGIC;
                 signal app_msi_num : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
                 signal app_msi_req : IN STD_LOGIC;
                 signal app_msi_tc : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal cpl_err : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                 signal cpl_pending : IN STD_LOGIC;
                 signal fixedclk_serdes : IN STD_LOGIC;
                 signal lmi_addr : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
                 signal lmi_din : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal lmi_rden : IN STD_LOGIC;
                 signal lmi_wren : IN STD_LOGIC;
                 signal local_rstn : IN STD_LOGIC;
                 signal pcie_rstn : IN STD_LOGIC;
                 signal pclk_in : IN STD_LOGIC;
                 signal pex_msi_num : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
                 signal phystatus_ext : IN STD_LOGIC;
                 signal pipe_mode : IN STD_LOGIC := std_logic'('0');
                 signal pld_clk : IN STD_LOGIC;
                 signal pm_auxpwr : IN STD_LOGIC;
                 signal pm_data : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
                 signal pm_event : IN STD_LOGIC;
                 signal pme_to_cr : IN STD_LOGIC;
                 signal reconfig_clk : IN STD_LOGIC;
                 signal reconfig_clk_locked : IN STD_LOGIC;
                 signal refclk : IN STD_LOGIC;
                 signal rx_in0 : IN STD_LOGIC := std_logic'('0');
                 signal rx_in1 : IN STD_LOGIC := std_logic'('0');
                 signal rx_in2 : IN STD_LOGIC := std_logic'('0');
                 signal rx_in3 : IN STD_LOGIC := std_logic'('0');
                 signal rx_st_mask0 : IN STD_LOGIC;
                 signal rx_st_ready0 : IN STD_LOGIC;
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
                 signal tx_st_data0 : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
                 signal tx_st_eop0 : IN STD_LOGIC;
                 signal tx_st_err0 : IN STD_LOGIC;
                 signal tx_st_sop0 : IN STD_LOGIC;
                 signal tx_st_valid0 : IN STD_LOGIC;

              -- outputs:
                 signal app_int_ack : OUT STD_LOGIC;
                 signal app_msi_ack : OUT STD_LOGIC;
                 signal clk250_out : OUT STD_LOGIC;
                 signal clk500_out : OUT STD_LOGIC;
                 signal core_clk_out : OUT STD_LOGIC;
                 signal lane_act : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal lmi_ack : OUT STD_LOGIC;
                 signal lmi_dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ltssm : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
                 signal pme_to_sr : OUT STD_LOGIC;
                 signal powerdown_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal rate_ext : OUT STD_LOGIC;
                 signal rc_pll_locked : OUT STD_LOGIC;
                 signal rx_st_bardec0 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal rx_st_be0 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal rx_st_data0 : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
                 signal rx_st_eop0 : OUT STD_LOGIC;
                 signal rx_st_err0 : OUT STD_LOGIC;
                 signal rx_st_sop0 : OUT STD_LOGIC;
                 signal rx_st_valid0 : OUT STD_LOGIC;
                 signal rxpolarity0_ext : OUT STD_LOGIC;
                 signal rxpolarity1_ext : OUT STD_LOGIC;
                 signal rxpolarity2_ext : OUT STD_LOGIC;
                 signal rxpolarity3_ext : OUT STD_LOGIC;
                 signal srstn : OUT STD_LOGIC;
                 signal test_out : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                 signal tl_cfg_add : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal tl_cfg_ctl : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal tl_cfg_ctl_wr : OUT STD_LOGIC;
                 signal tl_cfg_sts : OUT STD_LOGIC_VECTOR (52 DOWNTO 0);
                 signal tl_cfg_sts_wr : OUT STD_LOGIC;
                 signal tx_cred0 : OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
                 signal tx_fifo_empty0 : OUT STD_LOGIC;
                 signal tx_out0 : OUT STD_LOGIC;
                 signal tx_out1 : OUT STD_LOGIC;
                 signal tx_out2 : OUT STD_LOGIC;
                 signal tx_out3 : OUT STD_LOGIC;
                 signal tx_st_ready0 : OUT STD_LOGIC;
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
end entity pcie_phy_plus;


architecture europa of pcie_phy_plus is
  component pcie_phy is
PORT (
    signal tx_fifo_full0 : OUT STD_LOGIC;
        signal tl_cfg_add : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal tl_cfg_sts_wr : OUT STD_LOGIC;
        signal tl_cfg_ctl_wr : OUT STD_LOGIC;
        signal txcompl1_ext : OUT STD_LOGIC;
        signal l2_exit : OUT STD_LOGIC;
        signal app_msi_ack : OUT STD_LOGIC;
        signal tl_cfg_sts : OUT STD_LOGIC_VECTOR (52 DOWNTO 0);
        signal clk500_out : OUT STD_LOGIC;
        signal txelecidle0_ext : OUT STD_LOGIC;
        signal txdatak1_ext : OUT STD_LOGIC;
        signal tl_cfg_ctl : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal rx_fifo_empty0 : OUT STD_LOGIC;
        signal rx_st_err0 : OUT STD_LOGIC;
        signal test_out : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
        signal txelecidle2_ext : OUT STD_LOGIC;
        signal txdatak2_ext : OUT STD_LOGIC;
        signal tx_out0 : OUT STD_LOGIC;
        signal rxpolarity0_ext : OUT STD_LOGIC;
        signal clk250_out : OUT STD_LOGIC;
        signal tx_out2 : OUT STD_LOGIC;
        signal rx_fifo_full0 : OUT STD_LOGIC;
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
        signal core_clk_out : OUT STD_LOGIC;
        signal ltssm : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal hotrst_exit : OUT STD_LOGIC;
        signal tx_fifo_empty0 : OUT STD_LOGIC;
        signal rxpolarity2_ext : OUT STD_LOGIC;
        signal tx_out1 : OUT STD_LOGIC;
        signal txdata0_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rxpolarity3_ext : OUT STD_LOGIC;
        signal txcompl2_ext : OUT STD_LOGIC;
        signal rx_st_sop0 : OUT STD_LOGIC;
        signal rxpolarity1_ext : OUT STD_LOGIC;
        signal rx_st_data0 : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
        signal tx_fifo_rdptr0 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal txdata1_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal pme_to_sr : OUT STD_LOGIC;
        signal txdata2_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rc_pll_locked : OUT STD_LOGIC;
        signal txdata3_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal reconfig_fromgxb : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal dlup_exit : OUT STD_LOGIC;
        signal txdatak0_ext : OUT STD_LOGIC;
        signal txdetectrx_ext : OUT STD_LOGIC;
        signal txcompl0_ext : OUT STD_LOGIC;
        signal tx_cred0 : OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
        signal app_int_ack : OUT STD_LOGIC;
        signal lmi_dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        signal tx_fifo_wrptr0 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal pex_msi_num : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal rxdatak2_ext : IN STD_LOGIC;
        signal lmi_rden : IN STD_LOGIC;
        signal app_msi_tc : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal pipe_mode : IN STD_LOGIC;
        signal cal_blk_clk : IN STD_LOGIC;
        signal tx_st_sop0 : IN STD_LOGIC;
        signal pm_event : IN STD_LOGIC;
        signal rxstatus3_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal reconfig_clk : IN STD_LOGIC;
        signal app_msi_req : IN STD_LOGIC;
        signal gxb_powerdown : IN STD_LOGIC;
        signal app_msi_num : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal refclk : IN STD_LOGIC;
        signal rxstatus0_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal rx_st_ready0 : IN STD_LOGIC;
        signal rxelecidle0_ext : IN STD_LOGIC;
        signal busy_altgxb_reconfig : IN STD_LOGIC;
        signal pld_clk : IN STD_LOGIC;
        signal pm_data : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
        signal rxelecidle3_ext : IN STD_LOGIC;
        signal rx_in1 : IN STD_LOGIC;
        signal rxstatus2_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal pll_powerdown : IN STD_LOGIC;
        signal rxdatak1_ext : IN STD_LOGIC;
        signal reconfig_togxb : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal rx_in0 : IN STD_LOGIC;
        signal pclk_in : IN STD_LOGIC;
        signal rxdatak0_ext : IN STD_LOGIC;
        signal tx_st_data0 : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        signal rxelecidle1_ext : IN STD_LOGIC;
        signal rxdata1_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rx_st_mask0 : IN STD_LOGIC;
        signal rxvalid1_ext : IN STD_LOGIC;
        signal rx_in2 : IN STD_LOGIC;
        signal hpg_ctrler : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal rx_in3 : IN STD_LOGIC;
        signal rxdatak3_ext : IN STD_LOGIC;
        signal crst : IN STD_LOGIC;
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
        signal npor : IN STD_LOGIC;
        signal fixedclk_serdes : IN STD_LOGIC;
        signal pm_auxpwr : IN STD_LOGIC;
        signal rxdata2_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal srst : IN STD_LOGIC;
        signal app_int_sts : IN STD_LOGIC;
        signal rxvalid0_ext : IN STD_LOGIC;
        signal lmi_addr : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
        signal cpl_pending : IN STD_LOGIC
      );
  end component pcie_phy;
  component altpcie_reconfig_3cgx is
PORT (
    signal reconfig_togxb : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal busy : OUT STD_LOGIC;
        signal reconfig_clk : IN STD_LOGIC;
        signal reconfig_fromgxb : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal offset_cancellation_reset : IN STD_LOGIC
      );
  end component altpcie_reconfig_3cgx;
  component pcie_phy_rs_hip is
PORT (
    signal srst : OUT STD_LOGIC;
        signal app_rstn : OUT STD_LOGIC;
        signal crst : OUT STD_LOGIC;
        signal dlup_exit : IN STD_LOGIC;
        signal ltssm : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        signal npor : IN STD_LOGIC;
        signal pld_clk : IN STD_LOGIC;
        signal hotrst_exit : IN STD_LOGIC;
        signal l2_exit : IN STD_LOGIC;
        signal test_sim : IN STD_LOGIC
      );
  end component pcie_phy_rs_hip;
                signal busy_altgxb_reconfig :  STD_LOGIC;
                signal busy_altgxb_reconfig_altr :  STD_LOGIC;
                signal crst :  STD_LOGIC;
                signal dlup_exit :  STD_LOGIC;
                signal gnd_hpg_ctrler :  STD_LOGIC_VECTOR (4 DOWNTO 0);
                signal gxb_powerdown :  STD_LOGIC;
                signal hotrst_exit :  STD_LOGIC;
                signal hotrst_exit_altr :  STD_LOGIC;
                signal internal_app_int_ack :  STD_LOGIC;
                signal internal_app_msi_ack :  STD_LOGIC;
                signal internal_clk250_out :  STD_LOGIC;
                signal internal_clk500_out :  STD_LOGIC;
                signal internal_core_clk_out :  STD_LOGIC;
                signal internal_lane_act :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal internal_lmi_ack :  STD_LOGIC;
                signal internal_lmi_dout :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_ltssm :  STD_LOGIC_VECTOR (4 DOWNTO 0);
                signal internal_pme_to_sr :  STD_LOGIC;
                signal internal_powerdown_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_rate_ext :  STD_LOGIC;
                signal internal_rc_pll_locked :  STD_LOGIC;
                signal internal_rx_st_bardec0 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal internal_rx_st_be0 :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal internal_rx_st_data0 :  STD_LOGIC_VECTOR (63 DOWNTO 0);
                signal internal_rx_st_eop0 :  STD_LOGIC;
                signal internal_rx_st_err0 :  STD_LOGIC;
                signal internal_rx_st_sop0 :  STD_LOGIC;
                signal internal_rx_st_valid0 :  STD_LOGIC;
                signal internal_rxpolarity0_ext :  STD_LOGIC;
                signal internal_rxpolarity1_ext :  STD_LOGIC;
                signal internal_rxpolarity2_ext :  STD_LOGIC;
                signal internal_rxpolarity3_ext :  STD_LOGIC;
                signal internal_srstn :  STD_LOGIC;
                signal internal_test_out :  STD_LOGIC_VECTOR (8 DOWNTO 0);
                signal internal_tl_cfg_add :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal internal_tl_cfg_ctl :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_tl_cfg_ctl_wr :  STD_LOGIC;
                signal internal_tl_cfg_sts :  STD_LOGIC_VECTOR (52 DOWNTO 0);
                signal internal_tl_cfg_sts_wr :  STD_LOGIC;
                signal internal_tx_cred0 :  STD_LOGIC_VECTOR (35 DOWNTO 0);
                signal internal_tx_fifo_empty0 :  STD_LOGIC;
                signal internal_tx_out0 :  STD_LOGIC;
                signal internal_tx_out1 :  STD_LOGIC;
                signal internal_tx_out2 :  STD_LOGIC;
                signal internal_tx_out3 :  STD_LOGIC;
                signal internal_tx_st_ready0 :  STD_LOGIC;
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
                signal l2_exit :  STD_LOGIC;
                signal npor :  STD_LOGIC;
                signal npor_serdes_pll_locked :  STD_LOGIC;
                signal offset_cancellation_reset :  STD_LOGIC;
                signal open_rx_fifo_empty0 :  STD_LOGIC;
                signal open_rx_fifo_full0 :  STD_LOGIC;
                signal open_tx_fifo_full0 :  STD_LOGIC;
                signal open_tx_fifo_rdptr0 :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal open_tx_fifo_wrptr0 :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal otb0 :  STD_LOGIC;
                signal otb1 :  STD_LOGIC;
                signal pll_powerdown :  STD_LOGIC;
                signal reconfig_fromgxb :  STD_LOGIC_VECTOR (33 DOWNTO 0);
                signal reconfig_togxb :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal srst :  STD_LOGIC;

begin

  otb0 <= std_logic'('0');
  otb1 <= std_logic'('1');
  offset_cancellation_reset <= NOT reconfig_clk_locked;
  reconfig_fromgxb(33 DOWNTO 5) <= std_logic_vector'("00000000000000000000000000000");
  gnd_hpg_ctrler <= std_logic_vector'("00000");
  busy_altgxb_reconfig_altr <= A_WE_StdLogic(((std_logic'(pipe_mode) = std_logic'(otb1))), otb0, busy_altgxb_reconfig);
  gxb_powerdown <= NOT npor;
  hotrst_exit_altr <= hotrst_exit;
  pll_powerdown <= NOT npor;
  npor_serdes_pll_locked <= (pcie_rstn AND local_rstn) AND internal_rc_pll_locked;
  npor <= pcie_rstn AND local_rstn;
  epmap : pcie_phy
    port map(
            app_int_ack => internal_app_int_ack,
            app_int_sts => app_int_sts,
            app_msi_ack => internal_app_msi_ack,
            app_msi_num => app_msi_num,
            app_msi_req => app_msi_req,
            app_msi_tc => app_msi_tc,
            busy_altgxb_reconfig => busy_altgxb_reconfig_altr,
            cal_blk_clk => reconfig_clk,
            clk250_out => internal_clk250_out,
            clk500_out => internal_clk500_out,
            core_clk_out => internal_core_clk_out,
            cpl_err => cpl_err,
            cpl_pending => cpl_pending,
            crst => crst,
            dlup_exit => dlup_exit,
            fixedclk_serdes => fixedclk_serdes,
            gxb_powerdown => gxb_powerdown,
            hotrst_exit => hotrst_exit,
            hpg_ctrler => gnd_hpg_ctrler,
            l2_exit => l2_exit,
            lane_act => internal_lane_act,
            lmi_ack => internal_lmi_ack,
            lmi_addr => lmi_addr,
            lmi_din => lmi_din,
            lmi_dout => internal_lmi_dout,
            lmi_rden => lmi_rden,
            lmi_wren => lmi_wren,
            ltssm => internal_ltssm,
            npor => npor,
            pclk_in => pclk_in,
            pex_msi_num => pex_msi_num,
            phystatus_ext => phystatus_ext,
            pipe_mode => pipe_mode,
            pld_clk => pld_clk,
            pll_powerdown => pll_powerdown,
            pm_auxpwr => pm_auxpwr,
            pm_data => pm_data,
            pm_event => pm_event,
            pme_to_cr => pme_to_cr,
            pme_to_sr => internal_pme_to_sr,
            powerdown_ext => internal_powerdown_ext,
            rate_ext => internal_rate_ext,
            rc_pll_locked => internal_rc_pll_locked,
            reconfig_clk => reconfig_clk,
            reconfig_fromgxb => reconfig_fromgxb(4 DOWNTO 0),
            reconfig_togxb => reconfig_togxb,
            refclk => refclk,
            rx_fifo_empty0 => open_rx_fifo_empty0,
            rx_fifo_full0 => open_rx_fifo_full0,
            rx_in0 => rx_in0,
            rx_in1 => rx_in1,
            rx_in2 => rx_in2,
            rx_in3 => rx_in3,
            rx_st_bardec0 => internal_rx_st_bardec0,
            rx_st_be0 => internal_rx_st_be0(7 DOWNTO 0),
            rx_st_data0 => internal_rx_st_data0(63 DOWNTO 0),
            rx_st_eop0 => internal_rx_st_eop0,
            rx_st_err0 => internal_rx_st_err0,
            rx_st_mask0 => rx_st_mask0,
            rx_st_ready0 => rx_st_ready0,
            rx_st_sop0 => internal_rx_st_sop0,
            rx_st_valid0 => internal_rx_st_valid0,
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
            test_in => test_in,
            test_out => internal_test_out,
            tl_cfg_add => internal_tl_cfg_add,
            tl_cfg_ctl => internal_tl_cfg_ctl,
            tl_cfg_ctl_wr => internal_tl_cfg_ctl_wr,
            tl_cfg_sts => internal_tl_cfg_sts,
            tl_cfg_sts_wr => internal_tl_cfg_sts_wr,
            tx_cred0 => internal_tx_cred0,
            tx_fifo_empty0 => internal_tx_fifo_empty0,
            tx_fifo_full0 => open_tx_fifo_full0,
            tx_fifo_rdptr0 => open_tx_fifo_rdptr0,
            tx_fifo_wrptr0 => open_tx_fifo_wrptr0,
            tx_out0 => internal_tx_out0,
            tx_out1 => internal_tx_out1,
            tx_out2 => internal_tx_out2,
            tx_out3 => internal_tx_out3,
            tx_st_data0 => tx_st_data0(63 DOWNTO 0),
            tx_st_eop0 => tx_st_eop0,
            tx_st_err0 => tx_st_err0,
            tx_st_ready0 => internal_tx_st_ready0,
            tx_st_sop0 => tx_st_sop0,
            tx_st_valid0 => tx_st_valid0,
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

  reconfig : altpcie_reconfig_3cgx
    port map(
            busy => busy_altgxb_reconfig,
            offset_cancellation_reset => offset_cancellation_reset,
            reconfig_clk => reconfig_clk,
            reconfig_fromgxb => reconfig_fromgxb(4 DOWNTO 0),
            reconfig_togxb => reconfig_togxb
    );

  rs_hip : pcie_phy_rs_hip
    port map(
            app_rstn => internal_srstn,
            crst => crst,
            dlup_exit => dlup_exit,
            hotrst_exit => hotrst_exit_altr,
            l2_exit => l2_exit,
            ltssm => internal_ltssm,
            npor => npor_serdes_pll_locked,
            pld_clk => pld_clk,
            srst => srst,
            test_sim => test_in(0)
    );

  --vhdl renameroo for output signals
  app_int_ack <= internal_app_int_ack;
  --vhdl renameroo for output signals
  app_msi_ack <= internal_app_msi_ack;
  --vhdl renameroo for output signals
  clk250_out <= internal_clk250_out;
  --vhdl renameroo for output signals
  clk500_out <= internal_clk500_out;
  --vhdl renameroo for output signals
  core_clk_out <= internal_core_clk_out;
  --vhdl renameroo for output signals
  lane_act <= internal_lane_act;
  --vhdl renameroo for output signals
  lmi_ack <= internal_lmi_ack;
  --vhdl renameroo for output signals
  lmi_dout <= internal_lmi_dout;
  --vhdl renameroo for output signals
  ltssm <= internal_ltssm;
  --vhdl renameroo for output signals
  pme_to_sr <= internal_pme_to_sr;
  --vhdl renameroo for output signals
  powerdown_ext <= internal_powerdown_ext;
  --vhdl renameroo for output signals
  rate_ext <= internal_rate_ext;
  --vhdl renameroo for output signals
  rc_pll_locked <= internal_rc_pll_locked;
  --vhdl renameroo for output signals
  rx_st_bardec0 <= internal_rx_st_bardec0;
  --vhdl renameroo for output signals
  rx_st_be0 <= internal_rx_st_be0;
  --vhdl renameroo for output signals
  rx_st_data0 <= internal_rx_st_data0;
  --vhdl renameroo for output signals
  rx_st_eop0 <= internal_rx_st_eop0;
  --vhdl renameroo for output signals
  rx_st_err0 <= internal_rx_st_err0;
  --vhdl renameroo for output signals
  rx_st_sop0 <= internal_rx_st_sop0;
  --vhdl renameroo for output signals
  rx_st_valid0 <= internal_rx_st_valid0;
  --vhdl renameroo for output signals
  rxpolarity0_ext <= internal_rxpolarity0_ext;
  --vhdl renameroo for output signals
  rxpolarity1_ext <= internal_rxpolarity1_ext;
  --vhdl renameroo for output signals
  rxpolarity2_ext <= internal_rxpolarity2_ext;
  --vhdl renameroo for output signals
  rxpolarity3_ext <= internal_rxpolarity3_ext;
  --vhdl renameroo for output signals
  srstn <= internal_srstn;
  --vhdl renameroo for output signals
  test_out <= internal_test_out;
  --vhdl renameroo for output signals
  tl_cfg_add <= internal_tl_cfg_add;
  --vhdl renameroo for output signals
  tl_cfg_ctl <= internal_tl_cfg_ctl;
  --vhdl renameroo for output signals
  tl_cfg_ctl_wr <= internal_tl_cfg_ctl_wr;
  --vhdl renameroo for output signals
  tl_cfg_sts <= internal_tl_cfg_sts;
  --vhdl renameroo for output signals
  tl_cfg_sts_wr <= internal_tl_cfg_sts_wr;
  --vhdl renameroo for output signals
  tx_cred0 <= internal_tx_cred0;
  --vhdl renameroo for output signals
  tx_fifo_empty0 <= internal_tx_fifo_empty0;
  --vhdl renameroo for output signals
  tx_out0 <= internal_tx_out0;
  --vhdl renameroo for output signals
  tx_out1 <= internal_tx_out1;
  --vhdl renameroo for output signals
  tx_out2 <= internal_tx_out2;
  --vhdl renameroo for output signals
  tx_out3 <= internal_tx_out3;
  --vhdl renameroo for output signals
  tx_st_ready0 <= internal_tx_st_ready0;
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

