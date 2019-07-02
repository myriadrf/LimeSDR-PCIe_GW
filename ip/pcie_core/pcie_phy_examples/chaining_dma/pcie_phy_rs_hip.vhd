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

--/** Reset logic for HIP + 
--*/
entity pcie_phy_rs_hip is 
        port (
              -- inputs:
                 signal dlup_exit : IN STD_LOGIC;
                 signal hotrst_exit : IN STD_LOGIC;
                 signal l2_exit : IN STD_LOGIC;
                 signal ltssm : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
                 signal npor : IN STD_LOGIC;
                 signal pld_clk : IN STD_LOGIC;
                 signal test_sim : IN STD_LOGIC;

              -- outputs:
                 signal app_rstn : OUT STD_LOGIC;
                 signal crst : OUT STD_LOGIC;
                 signal srst : OUT STD_LOGIC
              );
end entity pcie_phy_rs_hip;


architecture europa of pcie_phy_rs_hip is
                signal any_rstn_r :  STD_LOGIC;
                signal any_rstn_rr :  STD_LOGIC;
                signal app_rstn0 :  STD_LOGIC;
                signal crst0 :  STD_LOGIC;
                signal dl_ltssm_r :  STD_LOGIC_VECTOR (4 DOWNTO 0);
                signal dlup_exit_r :  STD_LOGIC;
                signal exits_r :  STD_LOGIC;
                signal hotrst_exit_r :  STD_LOGIC;
                signal l2_exit_r :  STD_LOGIC;
                signal otb0 :  STD_LOGIC;
                signal otb1 :  STD_LOGIC;
                signal rsnt_cntn :  STD_LOGIC_VECTOR (10 DOWNTO 0);
                signal srst0 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of any_rstn_r : signal is "SUPPRESS_DA_RULE_INTERNAL=R102 ; SUPPRESS_DA_RULE_INTERNAL=R101";
attribute ALTERA_ATTRIBUTE of any_rstn_rr : signal is "SUPPRESS_DA_RULE_INTERNAL=R102 ; SUPPRESS_DA_RULE_INTERNAL=R101";

begin

  otb0 <= std_logic'('0');
  otb1 <= std_logic'('1');
  --pipe line exit conditions
  process (pld_clk, any_rstn_rr)
  begin
    if any_rstn_rr = '0' then
      dlup_exit_r <= otb1;
      hotrst_exit_r <= otb1;
      l2_exit_r <= otb1;
      exits_r <= otb0;
    elsif pld_clk'event and pld_clk = '1' then
      dlup_exit_r <= dlup_exit;
      hotrst_exit_r <= hotrst_exit;
      l2_exit_r <= l2_exit;
      exits_r <= to_std_logic((((((std_logic'(l2_exit_r) = std_logic'(std_logic'('0')))) OR ((std_logic'(hotrst_exit_r) = std_logic'(std_logic'('0'))))) OR ((std_logic'(dlup_exit_r) = std_logic'(std_logic'('0'))))) OR ((dl_ltssm_r = std_logic_vector'("10000")))));
    end if;

  end process;

  --LTSSM pipeline
  process (pld_clk, any_rstn_rr)
  begin
    if any_rstn_rr = '0' then
      dl_ltssm_r <= std_logic_vector'("00000");
    elsif pld_clk'event and pld_clk = '1' then
      dl_ltssm_r <= ltssm;
    end if;

  end process;

  --reset Synchronizer
  process (pld_clk, npor)
  begin
    if npor = '0' then
      any_rstn_r <= std_logic'('0');
      any_rstn_rr <= std_logic'('0');
    elsif pld_clk'event and pld_clk = '1' then
      any_rstn_r <= std_logic'('1');
      any_rstn_rr <= any_rstn_r;
    end if;

  end process;

  --reset counter
  process (pld_clk, any_rstn_rr)
  begin
    if any_rstn_rr = '0' then
      rsnt_cntn <= std_logic_vector'("00000000000");
    elsif pld_clk'event and pld_clk = '1' then
      if std_logic'(exits_r) = std_logic'(std_logic'('1')) then 
        rsnt_cntn <= std_logic_vector'("01111110000");
      elsif rsnt_cntn /= std_logic_vector'("10000000000") then 
        rsnt_cntn <= A_EXT (((std_logic_vector'("0000000000000000000000") & (rsnt_cntn)) + std_logic_vector'("000000000000000000000000000000001")), 11);
      end if;
    end if;

  end process;

  --sync and config reset
  process (pld_clk, any_rstn_rr)
  begin
    if any_rstn_rr = '0' then
      app_rstn0 <= std_logic'('0');
      srst0 <= std_logic'('1');
      crst0 <= std_logic'('1');
    elsif pld_clk'event and pld_clk = '1' then
      if std_logic'(exits_r) = std_logic'(std_logic'('1')) then 
        srst0 <= std_logic'('1');
        crst0 <= std_logic'('1');
        app_rstn0 <= std_logic'('0');
      -- synthesis translate_off
      elsif ((std_logic'(test_sim) = std_logic'(std_logic'('1')))) AND ((rsnt_cntn>=std_logic_vector'("00000100000"))) then 
        srst0 <= std_logic'('0');
        crst0 <= std_logic'('0');
        app_rstn0 <= std_logic'('1');
      -- synthesis translate_on
      elsif rsnt_cntn = std_logic_vector'("10000000000") then 
        srst0 <= std_logic'('0');
        crst0 <= std_logic'('0');
        app_rstn0 <= std_logic'('1');
      end if;
    end if;

  end process;

  --sync and config reset pipeline
  process (pld_clk, any_rstn_rr)
  begin
    if any_rstn_rr = '0' then
      app_rstn <= std_logic'('0');
      srst <= std_logic'('1');
      crst <= std_logic'('1');
    elsif pld_clk'event and pld_clk = '1' then
      app_rstn <= app_rstn0;
      srst <= srst0;
      crst <= crst0;
    end if;

  end process;


end europa;

