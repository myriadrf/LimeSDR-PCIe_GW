LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;

--Legal Notice: (C)2009 Altera Corporation. All rights reserved.  Your
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

-- synthesis translate_off
-- synthesis translate_on

ENTITY altpcierd_compliance_test IS
   PORT (
      local_rstn                    : IN STD_LOGIC;		-- Local board reset
      pcie_rstn                     : IN STD_LOGIC;		-- PCIe reset
      refclk                        : IN STD_LOGIC;		-- 100 Mhz clock
      req_compliance_push_button_n  : IN STD_LOGIC;		-- Push button to cycle through compliance mode, gen1, gen2 - Active low
      req_compliance_soft_ctrl      : IN STD_LOGIC;		-- Register to cycle trough compliance mode (monitor rising edge on this register - Active on 0 to 1 transition
      set_compliance_mode           : IN STD_LOGIC;		-- Set compliance mode (test_in[32])
      
      test_in_5_hip                 : OUT STD_LOGIC;
      test_in_32_hip                : OUT STD_LOGIC
   );
END ENTITY altpcierd_compliance_test;

ARCHITECTURE trans OF altpcierd_compliance_test IS
   
   SIGNAL rstn                       : STD_LOGIC;		-- async rstn synchronized on refclk
   SIGNAL exit_ltssm_compliance      : STD_LOGIC;		-- when 1 : force exit LTSSM COMPLIANCE state
   -- When 0 : if board plugged on compliance based board, LTSSM returns to COMPLIANCE state
   SIGNAL new_edge_for_compliance    : STD_LOGIC;
   SIGNAL ltssm_cnt_cycles           : STD_LOGIC_VECTOR(2 DOWNTO 0);
   
   --
   -- LTSSM Compliance forcing in/out
   --
   
   SIGNAL req_compliance_cycle       : STD_LOGIC;
   SIGNAL req_compliance_cycle_r     : STD_LOGIC;
   SIGNAL req_compliance_soft_ctrl_r : STD_LOGIC;
   
   --De bouncer  for push button
   SIGNAL dbc_cnt                    : STD_LOGIC_VECTOR(15 DOWNTO 0);
   
   -- Sync async reset
   SIGNAL npor                       : STD_LOGIC;
   SIGNAL rstn_sync                  : STD_LOGIC_VECTOR(2 DOWNTO 0);
   -- X-HDL generated signals

   SIGNAL altr0 : STD_LOGIC;
BEGIN
   test_in_5_hip <= '1' WHEN (set_compliance_mode = '0') ELSE
                    exit_ltssm_compliance;
   test_in_32_hip <= set_compliance_mode;
   exit_ltssm_compliance <= ltssm_cnt_cycles(2);
   PROCESS (refclk, rstn)
   BEGIN
      IF (rstn = '0') THEN
         ltssm_cnt_cycles <= "000";
      ELSIF (refclk'EVENT AND refclk = '1') THEN
         IF (new_edge_for_compliance = '1') THEN
            ltssm_cnt_cycles <= "111";
         ELSIF (ltssm_cnt_cycles /= "000") THEN
            ltssm_cnt_cycles <= ltssm_cnt_cycles - "001";
         END IF;
      END IF;
   END PROCESS;
   altr0 <= '0' WHEN (dbc_cnt = "0000000000000000") ELSE
                       '1';
   PROCESS (refclk, rstn)
   BEGIN
      IF (rstn = '0') THEN
         req_compliance_cycle <= '1';
         req_compliance_cycle_r <= '1';
         req_compliance_soft_ctrl_r <= '1';
      ELSIF (refclk'EVENT AND refclk = '1') THEN
         req_compliance_cycle <= altr0;
         req_compliance_cycle_r <= req_compliance_cycle;
         req_compliance_soft_ctrl_r <= req_compliance_soft_ctrl;
      END IF;
   END PROCESS;
   new_edge_for_compliance <= '1' WHEN (((req_compliance_cycle_r = '1') AND (req_compliance_cycle = '0')) OR ((req_compliance_soft_ctrl_r = '0') AND (req_compliance_soft_ctrl = '1'))) ELSE
                              '0';
   PROCESS (refclk, rstn)
   BEGIN
      IF (rstn = '0') THEN
         dbc_cnt <= "1111111111111111";
      ELSIF (refclk'EVENT AND refclk = '1') THEN
         IF (req_compliance_push_button_n = '0') THEN
            dbc_cnt <= "1111111111111111";
         ELSIF (dbc_cnt /= "0000000000000000") THEN
            dbc_cnt <= dbc_cnt - "0000000000000001";
         END IF;
      END IF;
   END PROCESS;
   
   npor <= pcie_rstn AND local_rstn;
   PROCESS (refclk, npor)
   BEGIN
      IF (npor = '0') THEN
         rstn_sync(2 DOWNTO 0) <= "000";
      ELSIF (refclk'EVENT AND refclk = '1') THEN
         rstn_sync(0) <= '1';
         rstn_sync(1) <= rstn_sync(0);
         rstn_sync(2) <= rstn_sync(1);
      END IF;
   END PROCESS;
   rstn <= rstn_sync(2);
   
END ARCHITECTURE trans;


