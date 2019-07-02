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

--/** This VHDL file is used for synthesis in chaining DMA design example
--*
--* This file provides the top level for synthesis
--*/
entity pcie_phy_example_chaining_top is 
        port (
              -- inputs:
                 signal free_100MHz : IN STD_LOGIC;
                 signal local_rstn_ext : IN STD_LOGIC;
                 signal pcie_rstn : IN STD_LOGIC;
                 signal refclk : IN STD_LOGIC;
                 signal req_compliance_push_button_n : IN STD_LOGIC;
                 signal rx_in0 : IN STD_LOGIC;
                 signal rx_in1 : IN STD_LOGIC;
                 signal rx_in2 : IN STD_LOGIC;
                 signal rx_in3 : IN STD_LOGIC;
                 signal usr_sw : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

              -- outputs:
                 signal L0_led : OUT STD_LOGIC;
                 signal alive_led : OUT STD_LOGIC;
                 signal comp_led : OUT STD_LOGIC;
                 signal lane_active_led : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal tx_out0 : OUT STD_LOGIC;
                 signal tx_out1 : OUT STD_LOGIC;
                 signal tx_out2 : OUT STD_LOGIC;
                 signal tx_out3 : OUT STD_LOGIC
              );
end entity pcie_phy_example_chaining_top;


architecture europa of pcie_phy_example_chaining_top is
  component altpcierd_compliance_test is
PORT (
    signal test_in_5_hip : OUT STD_LOGIC;
        signal test_in_32_hip : OUT STD_LOGIC;
        signal pcie_rstn : IN STD_LOGIC;
        signal req_compliance_soft_ctrl : IN STD_LOGIC;
        signal refclk : IN STD_LOGIC;
        signal set_compliance_mode : IN STD_LOGIC;
        signal req_compliance_push_button_n : IN STD_LOGIC;
        signal local_rstn : IN STD_LOGIC
      );
  end component altpcierd_compliance_test;
  component pcie_phy_example_chaining_pipen1b is
PORT (
    signal powerdown_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        signal txelecidle1_ext : OUT STD_LOGIC;
        signal lane_width_code : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal tx_out3 : OUT STD_LOGIC;
        signal core_clk_out : OUT STD_LOGIC;
        signal txcompl1_ext : OUT STD_LOGIC;
        signal rxpolarity2_ext : OUT STD_LOGIC;
        signal tx_out1 : OUT STD_LOGIC;
        signal txdata0_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rxpolarity3_ext : OUT STD_LOGIC;
        signal txcompl2_ext : OUT STD_LOGIC;
        signal phy_sel_code : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal txelecidle0_ext : OUT STD_LOGIC;
        signal txdatak1_ext : OUT STD_LOGIC;
        signal rxpolarity1_ext : OUT STD_LOGIC;
        signal txdata1_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal ref_clk_sel_code : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        signal txdata2_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal txelecidle2_ext : OUT STD_LOGIC;
        signal txdatak2_ext : OUT STD_LOGIC;
        signal tx_out0 : OUT STD_LOGIC;
        signal txdata3_ext : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rxpolarity0_ext : OUT STD_LOGIC;
        signal tx_out2 : OUT STD_LOGIC;
        signal txdatak0_ext : OUT STD_LOGIC;
        signal txdetectrx_ext : OUT STD_LOGIC;
        signal txdatak3_ext : OUT STD_LOGIC;
        signal txelecidle3_ext : OUT STD_LOGIC;
        signal txcompl0_ext : OUT STD_LOGIC;
        signal test_out_icm : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
        signal txcompl3_ext : OUT STD_LOGIC;
        signal rxdatak2_ext : IN STD_LOGIC;
        signal pipe_mode : IN STD_LOGIC;
        signal rxdata3_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rxstatus3_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal pcie_rstn : IN STD_LOGIC;
        signal rxelecidle2_ext : IN STD_LOGIC;
        signal refclk : IN STD_LOGIC;
        signal rxstatus1_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal rxstatus0_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal rxelecidle0_ext : IN STD_LOGIC;
        signal pld_clk : IN STD_LOGIC;
        signal rxdata0_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rxelecidle3_ext : IN STD_LOGIC;
        signal rx_in1 : IN STD_LOGIC;
        signal rxstatus2_ext : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        signal rxvalid3_ext : IN STD_LOGIC;
        signal rxvalid2_ext : IN STD_LOGIC;
        signal free_100MHz : IN STD_LOGIC;
        signal rxdatak1_ext : IN STD_LOGIC;
        signal rx_in0 : IN STD_LOGIC;
        signal rxdatak0_ext : IN STD_LOGIC;
        signal rxelecidle1_ext : IN STD_LOGIC;
        signal rxdata1_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rxvalid1_ext : IN STD_LOGIC;
        signal rx_in2 : IN STD_LOGIC;
        signal rxdata2_ext : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        signal rx_in3 : IN STD_LOGIC;
        signal rxdatak3_ext : IN STD_LOGIC;
        signal test_in : IN STD_LOGIC_VECTOR (39 DOWNTO 0);
        signal local_rstn : IN STD_LOGIC;
        signal rxvalid0_ext : IN STD_LOGIC;
        signal phystatus_ext : IN STD_LOGIC
      );
  end component pcie_phy_example_chaining_pipen1b;
                signal alive_cnt :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal any_rstn :  STD_LOGIC;
                signal any_rstn_r :  STD_LOGIC;
                signal any_rstn_rr :  STD_LOGIC;
                signal clk_out_buf :  STD_LOGIC;
                signal internal_tx_out0 :  STD_LOGIC;
                signal internal_tx_out1 :  STD_LOGIC;
                signal internal_tx_out2 :  STD_LOGIC;
                signal internal_tx_out3 :  STD_LOGIC;
                signal local_rstn :  STD_LOGIC;
                signal open_lane_width_code :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal open_phy_sel_code :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal open_ref_clk_sel_code :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal phystatus_ext :  STD_LOGIC;
                signal powerdown_ext :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal req_compliance_soft_ctrl :  STD_LOGIC;
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
                signal safe_mode :  STD_LOGIC;
                signal set_compliance_mode :  STD_LOGIC;
                signal test_in :  STD_LOGIC_VECTOR (39 DOWNTO 0);
                signal test_in_32_hip :  STD_LOGIC;
                signal test_in_5_hip :  STD_LOGIC;
                signal test_out_icm :  STD_LOGIC_VECTOR (8 DOWNTO 0);
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
                signal txdetectrx_ext :  STD_LOGIC;
                signal txelecidle0_ext :  STD_LOGIC;
                signal txelecidle1_ext :  STD_LOGIC;
                signal txelecidle2_ext :  STD_LOGIC;
                signal txelecidle3_ext :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of any_rstn_r : signal is "SUPPRESS_DA_RULE_INTERNAL=R102";
attribute ALTERA_ATTRIBUTE of any_rstn_rr : signal is "SUPPRESS_DA_RULE_INTERNAL=R102";

begin

  safe_mode <= std_logic'('1');
  local_rstn <= safe_mode OR local_rstn_ext;
  any_rstn <= pcie_rstn AND local_rstn;
  test_in(39 DOWNTO 33) <= std_logic_vector'("0000000");
  set_compliance_mode <= usr_sw(0);
  req_compliance_soft_ctrl <= std_logic'('0');
  test_in(32) <= test_in_32_hip;
  test_in(31 DOWNTO 9) <= std_logic_vector'("00000000000000000000000");
  test_in(8 DOWNTO 6) <= A_EXT (A_WE_StdLogicVector((std_logic'(safe_mode) = '1'), std_logic_vector'("0010"), (std_logic_vector'("0") & (usr_sw(3 DOWNTO 1)))), 3);
  test_in(5) <= test_in_5_hip;
  test_in(4 DOWNTO 0) <= std_logic_vector'("01000");
  --reset Synchronizer
  process (clk_out_buf, any_rstn)
  begin
    if any_rstn = '0' then
      any_rstn_r <= std_logic'('0');
      any_rstn_rr <= std_logic'('0');
    elsif clk_out_buf'event and clk_out_buf = '1' then
      any_rstn_r <= std_logic'('1');
      any_rstn_rr <= any_rstn_r;
    end if;

  end process;

  --LED logic
  process (clk_out_buf, any_rstn_rr)
  begin
    if any_rstn_rr = '0' then
      alive_cnt <= std_logic_vector'("0000000000000000000000000");
      alive_led <= std_logic'('0');
      comp_led <= std_logic'('0');
      L0_led <= std_logic'('0');
      lane_active_led <= std_logic_vector'("0000");
    elsif clk_out_buf'event and clk_out_buf = '1' then
      alive_cnt <= A_EXT (((std_logic_vector'("00000000") & (alive_cnt)) + std_logic_vector'("000000000000000000000000000000001")), 25);
      alive_led <= alive_cnt(24);
      comp_led <= to_std_logic(NOT ((test_out_icm(4 DOWNTO 0) = std_logic_vector'("00011"))));
      L0_led <= to_std_logic(NOT ((test_out_icm(4 DOWNTO 0) = std_logic_vector'("01111"))));
      lane_active_led(3 DOWNTO 0) <= NOT (test_out_icm(8 DOWNTO 5));
    end if;

  end process;

  pcie_compliance_test_enable : altpcierd_compliance_test
    port map(
            local_rstn => local_rstn_ext,
            pcie_rstn => pcie_rstn,
            refclk => refclk,
            req_compliance_push_button_n => req_compliance_push_button_n,
            req_compliance_soft_ctrl => req_compliance_soft_ctrl,
            set_compliance_mode => set_compliance_mode,
            test_in_32_hip => test_in_32_hip,
            test_in_5_hip => test_in_5_hip
    );

  core : pcie_phy_example_chaining_pipen1b
    port map(
            core_clk_out => clk_out_buf,
            free_100MHz => free_100MHz,
            lane_width_code => open_lane_width_code,
            local_rstn => local_rstn,
            pcie_rstn => pcie_rstn,
            phy_sel_code => open_phy_sel_code,
            phystatus_ext => phystatus_ext,
            pipe_mode => std_logic'('0'),
            pld_clk => clk_out_buf,
            powerdown_ext => powerdown_ext,
            ref_clk_sel_code => open_ref_clk_sel_code,
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
            test_out_icm => test_out_icm,
            tx_out0 => internal_tx_out0,
            tx_out1 => internal_tx_out1,
            tx_out2 => internal_tx_out2,
            tx_out3 => internal_tx_out3,
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
            txdetectrx_ext => txdetectrx_ext,
            txelecidle0_ext => txelecidle0_ext,
            txelecidle1_ext => txelecidle1_ext,
            txelecidle2_ext => txelecidle2_ext,
            txelecidle3_ext => txelecidle3_ext
    );

  --vhdl renameroo for output signals
  tx_out0 <= internal_tx_out0;
  --vhdl renameroo for output signals
  tx_out1 <= internal_tx_out1;
  --vhdl renameroo for output signals
  tx_out2 <= internal_tx_out2;
  --vhdl renameroo for output signals
  tx_out3 <= internal_tx_out3;

end europa;

