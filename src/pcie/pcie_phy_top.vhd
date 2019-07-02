-- ----------------------------------------------------------------------------
-- FILE:          pcie_phy_top.vhd
-- DESCRIPTION:   
--
-- DATE:          xx:xx PM weekday, month day, year
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
-- altera vhdl_input_version vhdl_2008
library ieee;
use ieee.std_logic_1164.all;
entity pcie_phy_top is
   port (
   RX_IN0                    : IN  STD_LOGIC;
   RX_IN1                    : IN  STD_LOGIC;
   RX_IN2                    : IN  STD_LOGIC;
   RX_IN3                    : IN  STD_LOGIC;
   APP_INT_STS               : IN  STD_LOGIC;
   APP_MSI_NUM               : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
   APP_MSI_REQ               : IN  STD_LOGIC;
   APP_MSI_TC                : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
   NPOR                      : IN  STD_LOGIC;
   PLD_CLK                   : IN  STD_LOGIC;
   PME_TO_CR                 : IN  STD_LOGIC;
   WORD_CONVERSION_CLK       : IN  STD_LOGIC;
   WORD_CONVERSION_RESET_N   : IN  STD_LOGIC;
   REFCLK                    : IN  STD_LOGIC;
   RX_ST_READY0              : IN  STD_LOGIC;
   TX_ST_DATA0               : IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
   TX_ST_EOP0                : IN  STD_LOGIC;
   TX_ST_SOP0                : IN  STD_LOGIC;
   TX_ST_VALID0              : IN  STD_LOGIC;
   
   TL_CFG_ADD                : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
   TL_CFG_CTL                : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
   CORE_CLK_OUT              : OUT STD_LOGIC;
   TX_OUT0                   : OUT STD_LOGIC;
   TX_OUT1                   : OUT STD_LOGIC;
   TX_OUT2                   : OUT STD_LOGIC;
   TX_OUT3                   : OUT STD_LOGIC;
   APP_MSI_ACK               : OUT STD_LOGIC;
   PME_TO_SR                 : OUT STD_LOGIC;
   RX_ST_DATA0               : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
   RX_ST_EOP0                : OUT STD_LOGIC;
   RX_ST_SOP0                : OUT STD_LOGIC;
   RX_ST_VALID0              : OUT STD_LOGIC;
   TX_ST_READY0              : OUT STD_LOGIC
   );
end entity pcie_phy_top;

architecture rtl of pcie_phy_top is

signal WORD_CONVERSION_RESET_N_reg : STD_LOGIC;

-- rx quad word avalon st 
signal rx_qw_av_st_data  : STD_LOGIC_VECTOR(63 DOWNTO 0);
signal rx_qw_av_st_eop   : STD_LOGIC;
signal rx_qw_av_st_sop   : STD_LOGIC;
signal rx_qw_av_st_rdy   : STD_LOGIC;
signal rx_qw_av_st_vld   : STD_LOGIC;
-- tx quad word avalon st
signal tx_qw_av_st_data  : STD_LOGIC_VECTOR(63 DOWNTO 0);
signal tx_qw_av_st_eop   : STD_LOGIC;
signal tx_qw_av_st_sop   : STD_LOGIC;
signal tx_qw_av_st_rdy   : STD_LOGIC;
signal tx_qw_av_st_vld   : STD_LOGIC;


component pcie_phy is 
        port (
                 signal APP_INT_STS : IN STD_LOGIC;
                 signal APP_MSI_NUM : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
                 signal APP_MSI_REQ : IN STD_LOGIC;
                 signal APP_MSI_TC : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal busy_altgxb_reconfig : IN STD_LOGIC;
                 signal cal_blk_clk : IN STD_LOGIC;
                 signal cpl_err : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
                 signal cpl_pending : IN STD_LOGIC;
                 signal crst : IN STD_LOGIC;
                 signal fixedclk_serdes : IN STD_LOGIC;
                 signal gxb_powerdown : IN STD_LOGIC;
                 signal hpg_ctrler : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
                 signal lmi_addr : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
                 signal lmi_din : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal lmi_rden : IN STD_LOGIC;
                 signal lmi_wren : IN STD_LOGIC;
                 signal NPOR : IN STD_LOGIC;
                 signal pclk_in : IN STD_LOGIC;
                 signal pex_msi_num : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
                 signal phystatus_ext : IN STD_LOGIC;
                 signal pipe_mode : IN STD_LOGIC;
                 signal PLD_CLK : IN STD_LOGIC;
                 signal pll_powerdown : IN STD_LOGIC;
                 signal pm_auxpwr : IN STD_LOGIC;
                 signal pm_data : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
                 signal pm_event : IN STD_LOGIC;
                 signal PME_TO_CR : IN STD_LOGIC;
                 signal reconfig_clk : IN STD_LOGIC;
                 signal reconfig_togxb : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal REFCLK : IN STD_LOGIC;
                 signal RX_IN0 : IN STD_LOGIC;
                 signal RX_IN1 : IN STD_LOGIC;
                 signal RX_IN2 : IN STD_LOGIC;
                 signal RX_IN3 : IN STD_LOGIC;
                 signal rx_st_mask0 : IN STD_LOGIC;
                 signal RX_ST_READY0 : IN STD_LOGIC;
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
                 signal srst : IN STD_LOGIC;
                 signal test_in : IN STD_LOGIC_VECTOR (39 DOWNTO 0);
                 signal TX_ST_DATA0 : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
                 signal TX_ST_EOP0 : IN STD_LOGIC;
                 signal tx_st_err0 : IN STD_LOGIC;
                 signal TX_ST_SOP0 : IN STD_LOGIC;
                 signal TX_ST_VALID0 : IN STD_LOGIC;

              
                 signal app_int_ack : OUT STD_LOGIC;
                 signal APP_MSI_ACK : OUT STD_LOGIC;
                 signal clk250_out : OUT STD_LOGIC;
                 signal clk500_out : OUT STD_LOGIC;
                 signal CORE_CLK_OUT : OUT STD_LOGIC;
                 signal derr_cor_ext_rcv0 : OUT STD_LOGIC;
                 signal derr_cor_ext_rpl : OUT STD_LOGIC;
                 signal derr_rpl : OUT STD_LOGIC;
                 signal dlup_exit : OUT STD_LOGIC;
                 signal hotrst_exit : OUT STD_LOGIC;
                 signal ko_cpl_spc_vc0 : OUT STD_LOGIC_VECTOR (19 DOWNTO 0);
                 signal l2_exit : OUT STD_LOGIC;
                 signal lane_act : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal lmi_ack : OUT STD_LOGIC;
                 signal lmi_dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ltssm : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
                 signal PME_TO_SR : OUT STD_LOGIC;
                 signal powerdown_ext : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal r2c_err0 : OUT STD_LOGIC;
                 signal rate_ext : OUT STD_LOGIC;
                 signal rc_pll_locked : OUT STD_LOGIC;
                 signal rc_rx_digitalreset : OUT STD_LOGIC;
                 signal reconfig_fromgxb : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
                 signal reset_status : OUT STD_LOGIC;
                 signal rx_fifo_empty0 : OUT STD_LOGIC;
                 signal rx_fifo_full0 : OUT STD_LOGIC;
                 signal rx_st_bardec0 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal rx_st_be0 : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal RX_ST_DATA0 : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
                 signal RX_ST_EOP0 : OUT STD_LOGIC;
                 signal rx_st_err0 : OUT STD_LOGIC;
                 signal RX_ST_SOP0 : OUT STD_LOGIC;
                 signal RX_ST_VALID0 : OUT STD_LOGIC;
                 signal rxpolarity0_ext : OUT STD_LOGIC;
                 signal rxpolarity1_ext : OUT STD_LOGIC;
                 signal rxpolarity2_ext : OUT STD_LOGIC;
                 signal rxpolarity3_ext : OUT STD_LOGIC;
                 signal suc_spd_neg : OUT STD_LOGIC;
                 signal test_out : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                 signal TL_CFG_ADD : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal TL_CFG_CTL : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal TL_CFG_CTL_wr : OUT STD_LOGIC;
                 signal tl_cfg_sts : OUT STD_LOGIC_VECTOR (52 DOWNTO 0);
                 signal tl_cfg_sts_wr : OUT STD_LOGIC;
                 signal tx_cred0 : OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
                 signal tx_fifo_empty0 : OUT STD_LOGIC;
                 signal tx_fifo_full0 : OUT STD_LOGIC;
                 signal tx_fifo_rdptr0 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal tx_fifo_wrptr0 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal TX_OUT0 : OUT STD_LOGIC;
                 signal TX_OUT1 : OUT STD_LOGIC;
                 signal TX_OUT2 : OUT STD_LOGIC;
                 signal TX_OUT3 : OUT STD_LOGIC;
                 signal TX_ST_READY0 : OUT STD_LOGIC;
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
end component pcie_phy;

component dword_to_qword is
	port (
		av_st_sink_data            : in  std_logic_vector(63 downto 0) := (others => '0'); 
		av_st_sink_endofpacket     : in  std_logic                     := '0';             
		av_st_sink_startofpacket   : in  std_logic                     := '0';             
		av_st_sink_ready           : out std_logic;                                        
		av_st_sink_valid           : in  std_logic                     := '0';             
		av_st_sink_error           : in  std_logic                     := '0';             
		av_st_source_data          : out std_logic_vector(63 downto 0);                    
		av_st_source_endofpacket   : out std_logic;                                        
		av_st_source_startofpacket : out std_logic;                                        
		av_st_source_error         : out std_logic;                                        
		av_st_source_ready         : in  std_logic                     := '0';             
		av_st_source_valid         : out std_logic;                                        
		clock_sink_clk             : in  std_logic                     := '0';             
		reset_sink_reset           : in  std_logic                     := '0';             
		clock_source_clk           : out std_logic;                                        
		reset_source_reset_req     : out std_logic                                         
	);
end component dword_to_qword;

component qword_to_dword is
	port (
		av_st_sink_data            : in  std_logic_vector(63 downto 0) := (others => '0'); 
		av_st_sink_endofpacket     : in  std_logic                     := '0';             
		av_st_sink_startofpacket   : in  std_logic                     := '0';             
		av_st_sink_ready           : out std_logic;                                        
		av_st_sink_valid           : in  std_logic                     := '0';             
		av_st_sink_error           : in  std_logic                     := '0';             
		av_st_source_data          : out std_logic_vector(63 downto 0);                    
		av_st_source_endofpacket   : out std_logic;                                        
		av_st_source_startofpacket : out std_logic;                                        
		av_st_source_error         : out std_logic;                                        
		av_st_source_ready         : in  std_logic                     := '0';             
		av_st_source_valid         : out std_logic;                                        
		clock_sink_clk             : in  std_logic                     := '0';             
		reset_sink_reset           : in  std_logic                     := '0';             
		clock_source_clk           : out std_logic;                                        
		reset_source_reset_req     : out std_logic                                         
	);
end component qword_to_dword;

component sync_reg is
   port (
      clk         : in std_logic;
      reset_n     : in std_logic;
      async_in    : in std_logic;
      sync_out    : out std_logic
        );
end component sync_reg;

begin

   comp_pcie_phy : pcie_phy
      port map (
                app_int_sts          => APP_INT_STS,
                app_msi_num          => APP_MSI_NUM,
                app_msi_req          => APP_MSI_REQ,
                app_msi_tc           => APP_MSI_TC,
                busy_altgxb_reconfig => '0',
                cal_blk_clk          => PLD_CLK,--'0',
                cpl_err              => (others => '0'),
                cpl_pending          => '0',
                crst                 => NPOR,
                fixedclk_serdes      => '0',
                gxb_powerdown        => not NPOR,
                hpg_ctrler           => (others => '0'),
                lmi_addr             => (others => '0'),
                lmi_din              => (others => '0'),
                lmi_rden             => '0',
                lmi_wren             => '0',
                npor                 => NPOR,
                pclk_in              => '0',
                pex_msi_num          => (others => '0'),
                phystatus_ext        => '0',
                pipe_mode            => '0',
                pld_clk              => PLD_CLK,
                pll_powerdown        => not NPOR,
                pm_auxpwr            => '0',
                pm_data              => (others => '0'),
                pm_event             => '0',
                pme_to_cr            => PME_TO_CR,
                reconfig_clk         => '0',
                reconfig_togxb       => (others => '0'),
                refclk               => REFCLK,
                rx_in0               => RX_IN0,
                rx_in1               => RX_IN1,
                rx_in2               => RX_IN2,
                rx_in3               => RX_IN3,
                rx_st_mask0          => '0',
                rx_st_ready0         => rx_qw_av_st_rdy,
                rxdata0_ext          => (others => '0'),
                rxdata1_ext          => (others => '0'),
                rxdata2_ext          => (others => '0'),
                rxdata3_ext          => (others => '0'),
                rxdatak0_ext         => '0',
                rxdatak1_ext         => '0',
                rxdatak2_ext         => '0',
                rxdatak3_ext         => '0',
                rxelecidle0_ext      => '0',
                rxelecidle1_ext      => '0',
                rxelecidle2_ext      => '0',
                rxelecidle3_ext      => '0',
                rxstatus0_ext        => (others => '0'),
                rxstatus1_ext        => (others => '0'),
                rxstatus2_ext        => (others => '0'),
                rxstatus3_ext        => (others => '0'),
                rxvalid0_ext         => '0',
                rxvalid1_ext         => '0',
                rxvalid2_ext         => '0',
                rxvalid3_ext         => '0',
                srst                 => NPOR,
                test_in              => (others => '0'),
                tx_st_data0          => tx_qw_av_st_data,
                tx_st_eop0           => tx_qw_av_st_eop,
                tx_st_err0           => '0',
                tx_st_sop0           => tx_qw_av_st_sop,
                tx_st_valid0         => tx_qw_av_st_vld,
                
                app_int_ack          => open,
                app_msi_ack          => APP_MSI_ACK,
                clk250_out           => open,
                clk500_out           => open,
                core_clk_out         => CORE_CLK_OUT,
                derr_cor_ext_rcv0    => open,
                derr_cor_ext_rpl     => open,
                derr_rpl             => open,
                dlup_exit            => open,
                hotrst_exit          => open,
                ko_cpl_spc_vc0       => open,
                l2_exit              => open,
                lane_act             => open,
                lmi_ack              => open,
                lmi_dout             => open,
                ltssm                => open,
                pme_to_sr            => PME_TO_SR,
                powerdown_ext        => open,
                r2c_err0             => open,
                rate_ext             => open,
                rc_pll_locked        => open,
                rc_rx_digitalreset   => open,
                reconfig_fromgxb     => open,
                reset_status         => open,
                rx_fifo_empty0       => open,
                rx_fifo_full0        => open,
                rx_st_bardec0        => open,
                rx_st_be0            => open,
                rx_st_data0          => rx_qw_av_st_data,
                rx_st_eop0           => rx_qw_av_st_eop,
                rx_st_err0           => open,
                rx_st_sop0           => rx_qw_av_st_sop,
                rx_st_valid0         => rx_qw_av_st_vld,
                rxpolarity0_ext      => open,
                rxpolarity1_ext      => open,
                rxpolarity2_ext      => open,
                rxpolarity3_ext      => open,
                suc_spd_neg          => open,
                test_out             => open,
                tl_cfg_add           => TL_CFG_ADD,
                tl_cfg_ctl           => TL_CFG_CTL,
                tl_cfg_ctl_wr        => open,
                tl_cfg_sts           => open,
                tl_cfg_sts_wr        => open,
                tx_cred0             => open,
                tx_fifo_empty0       => open,
                tx_fifo_full0        => open,
                tx_fifo_rdptr0       => open,
                tx_fifo_wrptr0       => open,
                tx_out0              => TX_OUT0,
                tx_out1              => TX_OUT1,
                tx_out2              => TX_OUT2,
                tx_out3              => TX_OUT3,
                tx_st_ready0         => tx_qw_av_st_rdy,
                txcompl0_ext         => open,
                txcompl1_ext         => open,
                txcompl2_ext         => open,
                txcompl3_ext         => open,
                txdata0_ext          => open,
                txdata1_ext          => open,
                txdata2_ext          => open,
                txdata3_ext          => open,
                txdatak0_ext         => open,
                txdatak1_ext         => open,
                txdatak2_ext         => open,
                txdatak3_ext         => open,
                txdetectrx_ext       => open,
                txelecidle0_ext      => open,
                txelecidle1_ext      => open,
                txelecidle2_ext      => open,
                txelecidle3_ext      => open
   );

   comp_sync_reg : sync_reg
      port map (
                clk      => WORD_CONVERSION_CLK,
                reset_n  => '1',
                async_in => not WORD_CONVERSION_RESET_N,
                sync_out => word_conversion_reset_n_reg
   );
   
   comp_qword_to_dword : qword_to_dword
      port map (
                av_st_sink_data            => rx_qw_av_st_data,
                av_st_sink_endofpacket     => rx_qw_av_st_eop,
                av_st_sink_startofpacket   => rx_qw_av_st_sop,
                av_st_sink_ready           => rx_qw_av_st_rdy,
                av_st_sink_valid           => rx_qw_av_st_vld,
                av_st_sink_error           => '0',
                av_st_source_data          => RX_ST_DATA0,
                av_st_source_endofpacket   => RX_ST_EOP0,
                av_st_source_startofpacket => RX_ST_SOP0,
                av_st_source_error         => open,
                av_st_source_ready         => RX_ST_READY0,
                av_st_source_valid         => RX_ST_VALID0,
                clock_sink_clk             => PLD_CLK,
                reset_sink_reset           => word_conversion_reset_n_reg,
                clock_source_clk           => open,
                reset_source_reset_req     => open
   );
   
   comp_dword_to_qword : dword_to_qword
      port map (
                av_st_sink_data            => TX_ST_DATA0,
                av_st_sink_endofpacket     => TX_ST_EOP0,
                av_st_sink_startofpacket   => TX_ST_SOP0,
                av_st_sink_ready           => TX_ST_READY0,
                av_st_sink_valid           => TX_ST_VALID0,
                av_st_sink_error           => '0',
                av_st_source_data          => tx_qw_av_st_data,
                av_st_source_endofpacket   => tx_qw_av_st_eop,
                av_st_source_startofpacket => tx_qw_av_st_sop,
                av_st_source_error         => open,
                av_st_source_ready         => tx_qw_av_st_rdy,
                av_st_source_valid         => tx_qw_av_st_vld,
                clock_sink_clk             => PLD_CLK,
                reset_sink_reset           => word_conversion_reset_n_reg,
                clock_source_clk           => open,
                reset_source_reset_req     => open
   );

   



end architecture rtl;