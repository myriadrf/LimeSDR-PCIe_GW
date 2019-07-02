--IP Functional Simulation Model
--VERSION_BEGIN 11.0 cbx_mgl 2011:03:09:22:48:24:SJ cbx_simgen 2011:03:09:22:37:57:SJ  VERSION_END


-- Copyright (C) 1991-2011 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- You may only use these simulation model output files for simulation
-- purposes and expressly not for synthesis or any other purposes (in which
-- event Altera disclaims all warranties of any kind).


--synopsys translate_off

 LIBRARY sgate;
 USE sgate.sgate_pack.all;

--synthesis_resources = lut 148 mux21 287 oper_add 5 oper_less_than 4 oper_mux 22 oper_selector 9 
 LIBRARY ieee;
 USE ieee.std_logic_1164.all;

 ENTITY  altpcie_rs_serdes IS 
	 PORT 
	 ( 
		 busy_altgxb_reconfig	:	IN  STD_LOGIC;
		 detect_mask_rxdrst	:	IN  STD_LOGIC;
		 fifo_err	:	IN  STD_LOGIC;
		 ltssm	:	IN  STD_LOGIC_VECTOR (4 DOWNTO 0);
		 npor	:	IN  STD_LOGIC;
		 pld_clk	:	IN  STD_LOGIC;
		 pll_locked	:	IN  STD_LOGIC;
		 rc_inclk_eq_125mhz	:	IN  STD_LOGIC;
		 rx_freqlocked	:	IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 rx_pll_locked	:	IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 rx_signaldetect	:	IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 rxanalogreset	:	OUT  STD_LOGIC;
		 rxdigitalreset	:	OUT  STD_LOGIC;
		 test_in	:	IN  STD_LOGIC_VECTOR (39 DOWNTO 0);
		 txdigitalreset	:	OUT  STD_LOGIC;
		 use_c4gx_serdes	:	IN  STD_LOGIC
	 ); 
 END altpcie_rs_serdes;

 ARCHITECTURE RTL OF altpcie_rs_serdes IS

	 ATTRIBUTE synthesis_clearbox : natural;
	 ATTRIBUTE synthesis_clearbox OF RTL : ARCHITECTURE IS 1;
	 SIGNAL	altpcie_rs_serdes_busy_altgxb_reconfig_r_0_250q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_busy_altgxb_reconfig_r_1_249q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_ld_ws_tmr_235q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_ltssm_detect_261q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rxanalogreset_r_208q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rxdigitalreset_r_209q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_serdes_rst_state_strobe_txpll_locked_sd_cnt_230q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_txdigitalreset_r_207q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_0_229q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_10_219q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_11_218q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_12_217q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_13_216q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_14_215q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_15_214q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_16_213q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_17_212q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_18_211q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_19_210q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_1_228q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_2_227q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_3_226q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_4_225q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_5_224q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_6_223q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_7_222q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_8_221q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_waitstate_timer_9_220q	:	STD_LOGIC := '0';
	 SIGNAL  wire_ni_w205w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_0_229q925w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_10_219q905w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_11_218q903w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_12_217q901w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_13_216q899w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_14_215q897w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_15_214q895w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_16_213q893w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_17_212q891w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_18_211q889w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_19_210q888w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_1_228q923w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_2_227q921w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_3_226q919w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_4_225q917w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_5_224q915w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_6_223q913w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_7_222q911w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_8_221q909w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_9_220q907w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	altpcie_rs_serdes_ld_ws_tmr_short_236q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_pll_locked_cnt_0_257q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_pll_locked_cnt_1_256q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_pll_locked_cnt_2_255q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_pll_locked_cnt_3_254q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_pll_locked_cnt_4_253q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_pll_locked_cnt_5_252q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_pll_locked_cnt_6_251q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_pll_locked_r_0_21q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_pll_locked_r_1_20q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_pll_locked_r_2_19q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_pll_locked_stable_258q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_freq_locked_cnt_0_239q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_freq_locked_cnt_1_238q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_freq_locked_cnt_2_237q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_freq_locked_r_0_24q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_freq_locked_r_1_23q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_freq_locked_r_2_22q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_freq_locked_sync_r_240q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_r_0_25q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_r_1_31q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_r_2_37q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_r_3_43q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_r_4_49q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_r_5_55q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_r_6_61q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_r_7_67q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_rr_0_26q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_rr_1_32q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_rr_2_38q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_rr_3_44q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_rr_4_50q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_rr_5_56q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_rr_6_62q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_rr_7_68q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_rrr_0_27q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_rrr_1_33q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_rrr_2_39q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_rrr_3_45q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_rrr_4_51q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_rrr_5_57q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_rrr_6_63q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_rrr_7_69q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_0_530q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_10_520q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_11_519q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_12_518q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_13_517q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_14_516q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_15_515q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_16_514q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_17_513q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_18_512q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_19_511q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_1_529q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_2_528q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_3_527q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_4_526q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_5_525q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_6_524q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_7_523q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_8_522q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_idl_cnt_9_521q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_strb0_0_269q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_strb0_1_268q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_strb0_2_267q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_strb0_3_266q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_strb0_4_265q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_strb0_5_264q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_strb0_6_263q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_strb0_7_262q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_strb1_0_510q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_strb1_1_276q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_strb1_2_275q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_strb1_3_274q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_strb1_4_273q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_strb1_5_272q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_strb1_6_271q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_sd_strb1_7_270q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_r_0_28q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_r_1_34q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_r_2_40q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_r_3_46q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_r_4_52q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_r_5_58q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_r_6_64q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_r_7_70q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_rr_0_29q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_rr_1_35q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_rr_2_41q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_rr_3_47q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_rr_4_53q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_rr_5_59q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_rr_6_65q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_rr_7_71q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_rrr_0_30q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_rrr_1_36q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_rrr_2_42q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_rrr_3_48q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_rrr_4_54q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_rrr_5_60q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_rrr_6_66q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_signaldetect_rrr_7_205q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_sd_state_0_206q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_sd_state_1_531q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_serdes_rst_state_idle_st_cnt_231q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_serdes_rst_state_stable_tx_pll_st_cnt_232q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_serdes_rst_state_wait_state_st_cnt_233q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_ws_tmr_eq_0_234q	:	STD_LOGIC := '0';
	 SIGNAL  wire_nl_w_lg_w993w994w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w993w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_w_lg_w_lg_w_lg_w_lg_w984w986w988w989w990w992w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_w_lg_w_lg_w_lg_w984w986w988w989w990w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_w_lg_w_lg_w984w986w988w989w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_w_lg_w984w986w988w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_w984w986w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w984w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_w_lg_w_lg_w_lg_w_lg_w976w977w979w980w981w982w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_w_lg_w_lg_w_lg_w976w977w979w980w981w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_w_lg_w_lg_w976w977w979w980w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_w_lg_w976w977w979w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_w976w977w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w976w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_19_511q975w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_ld_ws_tmr_short_236q207w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_pll_locked_r_2_19q111w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w880w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w878w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w877w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w226w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_0_530q1001w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_10_520q985w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_11_519q983w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_15_515q978w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_18_512q974w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_1_529q999w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_2_528q997w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_3_527q995w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_6_524q991w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_9_521q987w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_0_510q963w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_1_276q961w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_2_275q959w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_3_274q957w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_4_273q955w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_5_272q953w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_6_271q951w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_7_270q950w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_sync_r_0_248q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_sync_r_1_247q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_sync_r_2_246q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_sync_r_3_245q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_sync_r_4_244q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_sync_r_5_243q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_sync_r_6_242q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_rx_pll_locked_sync_r_7_241q	:	STD_LOGIC := '0';
	 SIGNAL  wire_nlO_w4w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nlO_w6w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nlO_w9w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nlO_w12w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nlO_w15w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nlO_w18w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nlO_w21w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nlO_w24w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	altpcie_rs_serdes_arst_r_0_18q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_arst_r_1_8q	:	STD_LOGIC := '0';
	 SIGNAL	altpcie_rs_serdes_arst_r_2_7q	:	STD_LOGIC := '0';
	 SIGNAL  wire_nO_w_lg_altpcie_rs_serdes_arst_r_2_7q26w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_altpcie_rs_serdes_ld_ws_tmr_183m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_ld_ws_tmr_short_184m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_ld_ws_tmr_short_188m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_pll_locked_cnt_100m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_pll_locked_cnt_101m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_pll_locked_cnt_102m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_pll_locked_cnt_89m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_pll_locked_cnt_90m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_pll_locked_cnt_91m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_pll_locked_cnt_92m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_pll_locked_cnt_93m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_pll_locked_cnt_94m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_pll_locked_cnt_95m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_pll_locked_cnt_96m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_pll_locked_cnt_97m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_pll_locked_cnt_98m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_pll_locked_cnt_99m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rst_rxpcs_sd_260m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_371m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_372m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_373m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_374m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_376m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_487m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_284m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_285m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_286m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_287m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_288m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_289m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_290m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_291m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_292m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_293m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_294m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_295m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_296m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_297m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_298m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_299m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_300m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_301m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_302m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_303m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_306m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_307m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_308m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_309m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_310m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_311m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_312m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_313m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_314m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_315m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_316m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_317m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_318m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_319m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_320m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_321m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_322m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_323m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_324m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_325m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_326m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_327m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_328m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_329m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_330m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_331m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_332m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_333m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_334m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_335m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_336m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_337m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_338m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_339m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_340m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_341m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_342m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_343m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_344m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_345m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_346m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_347m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_348m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_349m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_350m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_351m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_352m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_353m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_354m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_355m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_356m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_357m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_358m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_359m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_360m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_361m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_362m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_363m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_364m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_365m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_378m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_379m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_380m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_381m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_382m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_383m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_384m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_385m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_386m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_387m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_388m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_389m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_390m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_391m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_392m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_393m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_394m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_395m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_396m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_397m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_398m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_399m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_400m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_401m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_402m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_403m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_404m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_405m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_406m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_407m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_408m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_409m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_410m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_411m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_412m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_413m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_414m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_415m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_416m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_417m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_420m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_421m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_422m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_423m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_424m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_425m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_426m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_427m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_428m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_429m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_430m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_431m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_432m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_433m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_434m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_435m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_436m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_437m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_438m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_439m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_442m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_443m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_444m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_445m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_446m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_447m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_448m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_449m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_450m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_451m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_452m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_453m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_454m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_455m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_456m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_457m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_458m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_459m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_460m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_461m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_465m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_466m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_467m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_468m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_469m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_470m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_471m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_472m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_473m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_474m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_475m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_476m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_477m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_478m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_479m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_480m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_481m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_482m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_483m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rx_sd_idl_cnt_484m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rxanalogreset_1m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rxanalogreset_r_179m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rxdigitalreset_4m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rxdigitalreset_5m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_rxdigitalreset_r_192m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_sd_state_366m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_sd_state_367m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_sd_state_418m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_sd_state_419m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_sd_state_440m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_sd_state_441m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_sd_state_462m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_sd_state_463m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_sd_state_485m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_sd_state_486m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_serdes_rst_state_177m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_serdes_rst_state_181m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_serdes_rst_state_182m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_serdes_rst_state_189m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_serdes_rst_state_191m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_106m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_107m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_111m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_112m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_113m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_114m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_115m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_116m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_117m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_118m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_119m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_120m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_121m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_122m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_123m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_124m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_125m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_126m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_127m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_128m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_129m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_130m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_131m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_132m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_133m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_134m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_135m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_136m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_137m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_138m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_139m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_140m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_141m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_142m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_143m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_144m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_145m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_146m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_147m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_148m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_149m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_150m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_151m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_152m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_153m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_154m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_155m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_156m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_157m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_158m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_159m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_160m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_161m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_162m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_163m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_164m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_165m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_166m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_167m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_168m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_169m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_waitstate_timer_170m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_altpcie_rs_serdes_ws_tmr_eq_0_172m_dataout	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_add0_84_a	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_add0_84_b	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_gnd	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_add0_84_o	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_add1_88_a	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_add1_88_b	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_add1_88_o	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_add2_110_a	:	STD_LOGIC_VECTOR (20 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_add2_110_b	:	STD_LOGIC_VECTOR (20 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_add2_110_o	:	STD_LOGIC_VECTOR (20 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_add3_283_a	:	STD_LOGIC_VECTOR (19 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_add3_283_b	:	STD_LOGIC_VECTOR (19 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_add3_283_o	:	STD_LOGIC_VECTOR (19 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_add4_377_a	:	STD_LOGIC_VECTOR (19 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_add4_377_b	:	STD_LOGIC_VECTOR (19 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_add4_377_o	:	STD_LOGIC_VECTOR (19 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_lessthan0_87_a	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_lessthan0_87_b	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_lessthan0_87_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_lessthan1_282_a	:	STD_LOGIC_VECTOR (19 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_lessthan1_282_b	:	STD_LOGIC_VECTOR (19 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_lessthan1_282_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_lessthan2_304_a	:	STD_LOGIC_VECTOR (19 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_lessthan2_304_b	:	STD_LOGIC_VECTOR (19 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_lessthan2_304_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_lessthan3_369_a	:	STD_LOGIC_VECTOR (19 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_lessthan3_369_b	:	STD_LOGIC_VECTOR (19 DOWNTO 0);
	 SIGNAL  wire_vcc	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_lessthan3_369_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux0_488_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux0_488_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux0_488_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux10_498_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux10_498_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux10_498_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux11_499_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux11_499_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux11_499_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux12_500_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux12_500_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux12_500_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux13_501_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux13_501_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux13_501_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux14_502_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux14_502_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux14_502_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux15_503_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux15_503_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux15_503_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux16_504_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux16_504_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux16_504_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux17_505_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux17_505_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux17_505_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux18_506_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux18_506_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux18_506_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux19_507_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux19_507_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux19_507_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux1_489_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux1_489_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux1_489_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux20_508_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux20_508_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux20_508_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux21_509_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux21_509_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux21_509_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux2_490_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux2_490_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux2_490_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux3_491_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux3_491_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux3_491_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux4_492_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux4_492_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux4_492_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux5_493_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux5_493_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux5_493_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux6_494_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux6_494_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux6_494_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux7_495_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux7_495_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux7_495_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux8_496_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux8_496_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux8_496_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux9_497_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_mux9_497_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_mux9_497_sel	:	STD_LOGIC_VECTOR (1 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_selector0_193_data	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_selector0_193_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_selector0_193_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_selector1_194_data	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_selector1_194_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_selector1_194_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_selector2_195_data	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_selector2_195_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_selector2_195_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_selector3_196_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_selector3_196_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_selector3_196_sel	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_selector4_198_data	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_selector4_198_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_selector4_198_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_selector5_200_data	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_selector5_200_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_selector5_200_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_selector6_201_data	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_selector6_201_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_selector6_201_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_selector7_203_data	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_selector7_203_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_selector7_203_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_selector8_204_data	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_altpcie_rs_serdes_selector8_204_o	:	STD_LOGIC;
	 SIGNAL  wire_altpcie_rs_serdes_selector8_204_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_ltssm_range857w860w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_detect_mask_rxdrst2w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_fifo_err206w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_rc_inclk_eq_125mhz112w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w267w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w209w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w657w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w296w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w529w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w300w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w181w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_w_ltssm_range858w859w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  s_wire_altpcie_rs_serdes_always10_0_617_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_always10_174_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_always10_186_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_always10_1_689_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_always12_305_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_always12_370_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_pll_locked_stable_638_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_0_630_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_rx_pll_locked_sync_r_7_626_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_rxdigitalreset_3_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_rxdigitalreset_r_202_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_serdes_rst_state_197_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_stable_sd_280_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_stable_sd_668_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_stable_sd_677_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_txdigitalreset_r_199_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_wideand0_17_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_altpcie_rs_serdes_ws_tmr_eq_0_0_659_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_gnd :	STD_LOGIC;
	 SIGNAL  s_wire_vcc :	STD_LOGIC;
	 SIGNAL  wire_w_ltssm_range857w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_ltssm_range858w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_rx_freqlocked_range3w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_rx_freqlocked_range5w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_rx_freqlocked_range8w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_rx_freqlocked_range11w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_rx_freqlocked_range14w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_rx_freqlocked_range17w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_rx_freqlocked_range20w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_rx_freqlocked_range23w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
 BEGIN

	wire_gnd <= '0';
	wire_vcc <= '1';
	wire_w_lg_w_ltssm_range857w860w(0) <= wire_w_ltssm_range857w(0) AND wire_w_lg_w_ltssm_range858w859w(0);
	wire_w_lg_detect_mask_rxdrst2w(0) <= NOT detect_mask_rxdrst;
	wire_w_lg_fifo_err206w(0) <= NOT fifo_err;
	wire_w_lg_rc_inclk_eq_125mhz112w(0) <= NOT rc_inclk_eq_125mhz;
	wire_w267w(0) <= NOT s_wire_altpcie_rs_serdes_always10_174_dataout;
	wire_w209w(0) <= NOT s_wire_altpcie_rs_serdes_always10_186_dataout;
	wire_w657w(0) <= NOT s_wire_altpcie_rs_serdes_always10_1_689_dataout;
	wire_w296w(0) <= NOT s_wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_0_630_dataout;
	wire_w529w(0) <= NOT s_wire_altpcie_rs_serdes_stable_sd_280_dataout;
	wire_w300w(0) <= NOT s_wire_altpcie_rs_serdes_stable_sd_677_dataout;
	wire_w181w(0) <= NOT s_wire_altpcie_rs_serdes_ws_tmr_eq_0_0_659_dataout;
	wire_w_lg_w_ltssm_range858w859w(0) <= NOT wire_w_ltssm_range858w(0);
	rxanalogreset <= wire_altpcie_rs_serdes_rxanalogreset_1m_dataout;
	rxdigitalreset <= wire_altpcie_rs_serdes_rxdigitalreset_5m_dataout;
	s_wire_altpcie_rs_serdes_always10_0_617_dataout <= (((wire_w_lg_w_ltssm_range857w860w(0) AND (NOT ltssm(2))) AND (NOT ltssm(3))) AND (NOT ltssm(4)));
	s_wire_altpcie_rs_serdes_always10_174_dataout <= ((altpcie_rs_serdes_pll_locked_r_2_19q AND altpcie_rs_serdes_ws_tmr_eq_0_234q) AND altpcie_rs_serdes_pll_locked_stable_258q);
	s_wire_altpcie_rs_serdes_always10_186_dataout <= (altpcie_rs_serdes_ws_tmr_eq_0_234q AND wire_nl_w_lg_altpcie_rs_serdes_ld_ws_tmr_short_236q207w(0));
	s_wire_altpcie_rs_serdes_always10_1_689_dataout <= (((((NOT ltssm(0)) AND wire_w_lg_w_ltssm_range858w859w(0)) AND (NOT ltssm(2))) AND (NOT ltssm(3))) AND (NOT ltssm(4)));
	s_wire_altpcie_rs_serdes_always12_305_dataout <= (s_wire_altpcie_rs_serdes_stable_sd_280_dataout AND wire_altpcie_rs_serdes_lessthan2_304_o);
	s_wire_altpcie_rs_serdes_always12_370_dataout <= (wire_altpcie_rs_serdes_lessthan3_369_o AND test_in(0));
	s_wire_altpcie_rs_serdes_pll_locked_stable_638_dataout <= ((((((altpcie_rs_serdes_pll_locked_cnt_6_251q AND altpcie_rs_serdes_pll_locked_cnt_5_252q) AND altpcie_rs_serdes_pll_locked_cnt_4_253q) AND altpcie_rs_serdes_pll_locked_cnt_3_254q) AND altpcie_rs_serdes_pll_locked_cnt_2_255q) AND altpcie_rs_serdes_pll_locked_cnt_1_256q) AND altpcie_rs_serdes_pll_locked_cnt_0_257q);
	s_wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_0_630_dataout <= ((wire_nl_w877w(0) AND wire_nl_w878w(0)) AND wire_nl_w880w(0));
	s_wire_altpcie_rs_serdes_rx_pll_locked_sync_r_7_626_dataout <= (((((((altpcie_rs_serdes_rx_pll_locked_rrr_0_27q AND altpcie_rs_serdes_rx_pll_locked_rrr_1_33q) AND altpcie_rs_serdes_rx_pll_locked_rrr_2_39q) AND altpcie_rs_serdes_rx_pll_locked_rrr_3_45q) AND altpcie_rs_serdes_rx_pll_locked_rrr_4_51q) AND altpcie_rs_serdes_rx_pll_locked_rrr_5_57q) AND altpcie_rs_serdes_rx_pll_locked_rrr_6_63q) AND altpcie_rs_serdes_rx_pll_locked_rrr_7_69q);
	s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout <= (((((NOT ltssm(0)) AND ltssm(1)) AND (NOT ltssm(2))) AND (NOT ltssm(3))) AND (NOT ltssm(4)));
	s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout <= ((((wire_nl_w_lg_w993w994w(0) AND wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_3_527q995w(0)) AND wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_2_528q997w(0)) AND wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_1_529q999w(0)) AND wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_0_530q1001w(0));
	s_wire_altpcie_rs_serdes_rxdigitalreset_3_dataout <= (altpcie_rs_serdes_rxdigitalreset_r_209q OR wire_altpcie_rs_serdes_rst_rxpcs_sd_260m_dataout);
	s_wire_altpcie_rs_serdes_rxdigitalreset_r_202_dataout <= (altpcie_rs_serdes_serdes_rst_state_strobe_txpll_locked_sd_cnt_230q OR altpcie_rs_serdes_serdes_rst_state_stable_tx_pll_st_cnt_232q);
	s_wire_altpcie_rs_serdes_serdes_rst_state_197_dataout <= (altpcie_rs_serdes_serdes_rst_state_strobe_txpll_locked_sd_cnt_230q OR altpcie_rs_serdes_serdes_rst_state_idle_st_cnt_231q);
	s_wire_altpcie_rs_serdes_stable_sd_280_dataout <= (s_wire_altpcie_rs_serdes_stable_sd_668_dataout AND wire_w300w(0));
	s_wire_altpcie_rs_serdes_stable_sd_668_dataout <= ((((((((NOT (altpcie_rs_serdes_rx_sd_strb0_0_269q XOR altpcie_rs_serdes_rx_sd_strb1_0_510q)) AND (NOT (altpcie_rs_serdes_rx_sd_strb0_1_268q XOR altpcie_rs_serdes_rx_sd_strb1_1_276q))) AND (NOT (altpcie_rs_serdes_rx_sd_strb0_2_267q XOR altpcie_rs_serdes_rx_sd_strb1_2_275q))) AND (NOT (altpcie_rs_serdes_rx_sd_strb0_3_266q XOR altpcie_rs_serdes_rx_sd_strb1_3_274q))) AND (NOT (altpcie_rs_serdes_rx_sd_strb0_4_265q XOR altpcie_rs_serdes_rx_sd_strb1_4_273q))) AND (NOT (altpcie_rs_serdes_rx_sd_strb0_5_264q XOR altpcie_rs_serdes_rx_sd_strb1_5_272q))) AND (NOT (altpcie_rs_serdes_rx_sd_strb0_6_263q XOR altpcie_rs_serdes_rx_sd_strb1_6_271q))) AND (NOT (altpcie_rs_serdes_rx_sd_strb0_7_262q XOR altpcie_rs_serdes_rx_sd_strb1_7_270q)));
	s_wire_altpcie_rs_serdes_stable_sd_677_dataout <= (((((((wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_7_270q950w(0) AND wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_6_271q951w(0)) AND wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_5_272q953w(0)) AND wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_4_273q955w(0)) AND wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_3_274q957w(0)) AND wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_2_275q959w(0)) AND wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_1_276q961w(0)) AND wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_0_510q963w(0));
	s_wire_altpcie_rs_serdes_txdigitalreset_r_199_dataout <= (altpcie_rs_serdes_serdes_rst_state_stable_tx_pll_st_cnt_232q OR altpcie_rs_serdes_serdes_rst_state_wait_state_st_cnt_233q);
	s_wire_altpcie_rs_serdes_wideand0_17_dataout <= (((((((wire_nlO_w4w(0) AND wire_nlO_w6w(0)) AND wire_nlO_w9w(0)) AND wire_nlO_w12w(0)) AND wire_nlO_w15w(0)) AND wire_nlO_w18w(0)) AND wire_nlO_w21w(0)) AND wire_nlO_w24w(0));
	s_wire_altpcie_rs_serdes_ws_tmr_eq_0_0_659_dataout <= (((((((((((((((((((wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_19_210q888w(0) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_18_211q889w(0)) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_17_212q891w(0)) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_16_213q893w(0)) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_15_214q895w(0)) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_14_215q897w(0)) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_13_216q899w(0)) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_12_217q901w(0)) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_11_218q903w(0)) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_10_219q905w(0)) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_9_220q907w(0)) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_8_221q909w(0)) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_7_222q911w(0)) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_6_223q913w(0)) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_5_224q915w(0)) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_4_225q917w(0)) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_3_226q919w(0)) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_2_227q921w(0)) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_1_228q923w(0)) AND wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_0_229q925w(0));
	s_wire_gnd <= '0';
	s_wire_vcc <= '1';
	txdigitalreset <= altpcie_rs_serdes_txdigitalreset_r_207q;
	wire_w_ltssm_range857w(0) <= ltssm(0);
	wire_w_ltssm_range858w(0) <= ltssm(1);
	wire_w_rx_freqlocked_range3w(0) <= rx_freqlocked(0);
	wire_w_rx_freqlocked_range5w(0) <= rx_freqlocked(1);
	wire_w_rx_freqlocked_range8w(0) <= rx_freqlocked(2);
	wire_w_rx_freqlocked_range11w(0) <= rx_freqlocked(3);
	wire_w_rx_freqlocked_range14w(0) <= rx_freqlocked(4);
	wire_w_rx_freqlocked_range17w(0) <= rx_freqlocked(5);
	wire_w_rx_freqlocked_range20w(0) <= rx_freqlocked(6);
	wire_w_rx_freqlocked_range23w(0) <= rx_freqlocked(7);
	PROCESS (pld_clk, altpcie_rs_serdes_arst_r_2_7q)
	BEGIN
		IF (altpcie_rs_serdes_arst_r_2_7q = '1') THEN
				altpcie_rs_serdes_busy_altgxb_reconfig_r_0_250q <= '1';
				altpcie_rs_serdes_busy_altgxb_reconfig_r_1_249q <= '1';
				altpcie_rs_serdes_ld_ws_tmr_235q <= '1';
				altpcie_rs_serdes_ltssm_detect_261q <= '1';
				altpcie_rs_serdes_rxanalogreset_r_208q <= '1';
				altpcie_rs_serdes_rxdigitalreset_r_209q <= '1';
				altpcie_rs_serdes_serdes_rst_state_strobe_txpll_locked_sd_cnt_230q <= '1';
				altpcie_rs_serdes_txdigitalreset_r_207q <= '1';
				altpcie_rs_serdes_waitstate_timer_0_229q <= '1';
				altpcie_rs_serdes_waitstate_timer_10_219q <= '1';
				altpcie_rs_serdes_waitstate_timer_11_218q <= '1';
				altpcie_rs_serdes_waitstate_timer_12_217q <= '1';
				altpcie_rs_serdes_waitstate_timer_13_216q <= '1';
				altpcie_rs_serdes_waitstate_timer_14_215q <= '1';
				altpcie_rs_serdes_waitstate_timer_15_214q <= '1';
				altpcie_rs_serdes_waitstate_timer_16_213q <= '1';
				altpcie_rs_serdes_waitstate_timer_17_212q <= '1';
				altpcie_rs_serdes_waitstate_timer_18_211q <= '1';
				altpcie_rs_serdes_waitstate_timer_19_210q <= '1';
				altpcie_rs_serdes_waitstate_timer_1_228q <= '1';
				altpcie_rs_serdes_waitstate_timer_2_227q <= '1';
				altpcie_rs_serdes_waitstate_timer_3_226q <= '1';
				altpcie_rs_serdes_waitstate_timer_4_225q <= '1';
				altpcie_rs_serdes_waitstate_timer_5_224q <= '1';
				altpcie_rs_serdes_waitstate_timer_6_223q <= '1';
				altpcie_rs_serdes_waitstate_timer_7_222q <= '1';
				altpcie_rs_serdes_waitstate_timer_8_221q <= '1';
				altpcie_rs_serdes_waitstate_timer_9_220q <= '1';
		ELSIF (pld_clk = '1' AND pld_clk'event) THEN
				altpcie_rs_serdes_busy_altgxb_reconfig_r_0_250q <= busy_altgxb_reconfig;
				altpcie_rs_serdes_busy_altgxb_reconfig_r_1_249q <= altpcie_rs_serdes_busy_altgxb_reconfig_r_0_250q;
				altpcie_rs_serdes_ld_ws_tmr_235q <= wire_altpcie_rs_serdes_selector0_193_o;
				altpcie_rs_serdes_ltssm_detect_261q <= (s_wire_altpcie_rs_serdes_always10_0_617_dataout OR s_wire_altpcie_rs_serdes_always10_1_689_dataout);
				altpcie_rs_serdes_rxanalogreset_r_208q <= wire_altpcie_rs_serdes_selector6_201_o;
				altpcie_rs_serdes_rxdigitalreset_r_209q <= wire_altpcie_rs_serdes_selector7_203_o;
				altpcie_rs_serdes_serdes_rst_state_strobe_txpll_locked_sd_cnt_230q <= wire_altpcie_rs_serdes_selector1_194_o;
				altpcie_rs_serdes_txdigitalreset_r_207q <= wire_altpcie_rs_serdes_selector5_200_o;
				altpcie_rs_serdes_waitstate_timer_0_229q <= wire_altpcie_rs_serdes_waitstate_timer_170m_dataout;
				altpcie_rs_serdes_waitstate_timer_10_219q <= wire_altpcie_rs_serdes_waitstate_timer_160m_dataout;
				altpcie_rs_serdes_waitstate_timer_11_218q <= wire_altpcie_rs_serdes_waitstate_timer_159m_dataout;
				altpcie_rs_serdes_waitstate_timer_12_217q <= wire_altpcie_rs_serdes_waitstate_timer_158m_dataout;
				altpcie_rs_serdes_waitstate_timer_13_216q <= wire_altpcie_rs_serdes_waitstate_timer_157m_dataout;
				altpcie_rs_serdes_waitstate_timer_14_215q <= wire_altpcie_rs_serdes_waitstate_timer_156m_dataout;
				altpcie_rs_serdes_waitstate_timer_15_214q <= wire_altpcie_rs_serdes_waitstate_timer_155m_dataout;
				altpcie_rs_serdes_waitstate_timer_16_213q <= wire_altpcie_rs_serdes_waitstate_timer_154m_dataout;
				altpcie_rs_serdes_waitstate_timer_17_212q <= wire_altpcie_rs_serdes_waitstate_timer_153m_dataout;
				altpcie_rs_serdes_waitstate_timer_18_211q <= wire_altpcie_rs_serdes_waitstate_timer_152m_dataout;
				altpcie_rs_serdes_waitstate_timer_19_210q <= wire_altpcie_rs_serdes_waitstate_timer_151m_dataout;
				altpcie_rs_serdes_waitstate_timer_1_228q <= wire_altpcie_rs_serdes_waitstate_timer_169m_dataout;
				altpcie_rs_serdes_waitstate_timer_2_227q <= wire_altpcie_rs_serdes_waitstate_timer_168m_dataout;
				altpcie_rs_serdes_waitstate_timer_3_226q <= wire_altpcie_rs_serdes_waitstate_timer_167m_dataout;
				altpcie_rs_serdes_waitstate_timer_4_225q <= wire_altpcie_rs_serdes_waitstate_timer_166m_dataout;
				altpcie_rs_serdes_waitstate_timer_5_224q <= wire_altpcie_rs_serdes_waitstate_timer_165m_dataout;
				altpcie_rs_serdes_waitstate_timer_6_223q <= wire_altpcie_rs_serdes_waitstate_timer_164m_dataout;
				altpcie_rs_serdes_waitstate_timer_7_222q <= wire_altpcie_rs_serdes_waitstate_timer_163m_dataout;
				altpcie_rs_serdes_waitstate_timer_8_221q <= wire_altpcie_rs_serdes_waitstate_timer_162m_dataout;
				altpcie_rs_serdes_waitstate_timer_9_220q <= wire_altpcie_rs_serdes_waitstate_timer_161m_dataout;
		END IF;
		if (now = 0 ns) then
			altpcie_rs_serdes_busy_altgxb_reconfig_r_0_250q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_busy_altgxb_reconfig_r_1_249q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_ld_ws_tmr_235q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_ltssm_detect_261q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_rxanalogreset_r_208q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_rxdigitalreset_r_209q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_serdes_rst_state_strobe_txpll_locked_sd_cnt_230q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_txdigitalreset_r_207q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_0_229q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_10_219q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_11_218q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_12_217q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_13_216q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_14_215q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_15_214q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_16_213q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_17_212q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_18_211q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_19_210q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_1_228q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_2_227q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_3_226q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_4_225q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_5_224q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_6_223q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_7_222q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_8_221q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_waitstate_timer_9_220q <= '1' after 1 ps;
		end if;
	END PROCESS;
	wire_ni_w205w(0) <= NOT altpcie_rs_serdes_busy_altgxb_reconfig_r_1_249q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_0_229q925w(0) <= NOT altpcie_rs_serdes_waitstate_timer_0_229q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_10_219q905w(0) <= NOT altpcie_rs_serdes_waitstate_timer_10_219q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_11_218q903w(0) <= NOT altpcie_rs_serdes_waitstate_timer_11_218q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_12_217q901w(0) <= NOT altpcie_rs_serdes_waitstate_timer_12_217q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_13_216q899w(0) <= NOT altpcie_rs_serdes_waitstate_timer_13_216q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_14_215q897w(0) <= NOT altpcie_rs_serdes_waitstate_timer_14_215q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_15_214q895w(0) <= NOT altpcie_rs_serdes_waitstate_timer_15_214q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_16_213q893w(0) <= NOT altpcie_rs_serdes_waitstate_timer_16_213q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_17_212q891w(0) <= NOT altpcie_rs_serdes_waitstate_timer_17_212q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_18_211q889w(0) <= NOT altpcie_rs_serdes_waitstate_timer_18_211q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_19_210q888w(0) <= NOT altpcie_rs_serdes_waitstate_timer_19_210q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_1_228q923w(0) <= NOT altpcie_rs_serdes_waitstate_timer_1_228q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_2_227q921w(0) <= NOT altpcie_rs_serdes_waitstate_timer_2_227q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_3_226q919w(0) <= NOT altpcie_rs_serdes_waitstate_timer_3_226q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_4_225q917w(0) <= NOT altpcie_rs_serdes_waitstate_timer_4_225q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_5_224q915w(0) <= NOT altpcie_rs_serdes_waitstate_timer_5_224q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_6_223q913w(0) <= NOT altpcie_rs_serdes_waitstate_timer_6_223q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_7_222q911w(0) <= NOT altpcie_rs_serdes_waitstate_timer_7_222q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_8_221q909w(0) <= NOT altpcie_rs_serdes_waitstate_timer_8_221q;
	wire_ni_w_lg_altpcie_rs_serdes_waitstate_timer_9_220q907w(0) <= NOT altpcie_rs_serdes_waitstate_timer_9_220q;
	PROCESS (pld_clk, altpcie_rs_serdes_arst_r_2_7q)
	BEGIN
		IF (altpcie_rs_serdes_arst_r_2_7q = '1') THEN
				altpcie_rs_serdes_ld_ws_tmr_short_236q <= '0';
				altpcie_rs_serdes_pll_locked_cnt_0_257q <= '0';
				altpcie_rs_serdes_pll_locked_cnt_1_256q <= '0';
				altpcie_rs_serdes_pll_locked_cnt_2_255q <= '0';
				altpcie_rs_serdes_pll_locked_cnt_3_254q <= '0';
				altpcie_rs_serdes_pll_locked_cnt_4_253q <= '0';
				altpcie_rs_serdes_pll_locked_cnt_5_252q <= '0';
				altpcie_rs_serdes_pll_locked_cnt_6_251q <= '0';
				altpcie_rs_serdes_pll_locked_r_0_21q <= '0';
				altpcie_rs_serdes_pll_locked_r_1_20q <= '0';
				altpcie_rs_serdes_pll_locked_r_2_19q <= '0';
				altpcie_rs_serdes_pll_locked_stable_258q <= '0';
				altpcie_rs_serdes_rx_pll_freq_locked_cnt_0_239q <= '0';
				altpcie_rs_serdes_rx_pll_freq_locked_cnt_1_238q <= '0';
				altpcie_rs_serdes_rx_pll_freq_locked_cnt_2_237q <= '0';
				altpcie_rs_serdes_rx_pll_freq_locked_r_0_24q <= '0';
				altpcie_rs_serdes_rx_pll_freq_locked_r_1_23q <= '0';
				altpcie_rs_serdes_rx_pll_freq_locked_r_2_22q <= '0';
				altpcie_rs_serdes_rx_pll_freq_locked_sync_r_240q <= '0';
				altpcie_rs_serdes_rx_pll_locked_r_0_25q <= '0';
				altpcie_rs_serdes_rx_pll_locked_r_1_31q <= '0';
				altpcie_rs_serdes_rx_pll_locked_r_2_37q <= '0';
				altpcie_rs_serdes_rx_pll_locked_r_3_43q <= '0';
				altpcie_rs_serdes_rx_pll_locked_r_4_49q <= '0';
				altpcie_rs_serdes_rx_pll_locked_r_5_55q <= '0';
				altpcie_rs_serdes_rx_pll_locked_r_6_61q <= '0';
				altpcie_rs_serdes_rx_pll_locked_r_7_67q <= '0';
				altpcie_rs_serdes_rx_pll_locked_rr_0_26q <= '0';
				altpcie_rs_serdes_rx_pll_locked_rr_1_32q <= '0';
				altpcie_rs_serdes_rx_pll_locked_rr_2_38q <= '0';
				altpcie_rs_serdes_rx_pll_locked_rr_3_44q <= '0';
				altpcie_rs_serdes_rx_pll_locked_rr_4_50q <= '0';
				altpcie_rs_serdes_rx_pll_locked_rr_5_56q <= '0';
				altpcie_rs_serdes_rx_pll_locked_rr_6_62q <= '0';
				altpcie_rs_serdes_rx_pll_locked_rr_7_68q <= '0';
				altpcie_rs_serdes_rx_pll_locked_rrr_0_27q <= '0';
				altpcie_rs_serdes_rx_pll_locked_rrr_1_33q <= '0';
				altpcie_rs_serdes_rx_pll_locked_rrr_2_39q <= '0';
				altpcie_rs_serdes_rx_pll_locked_rrr_3_45q <= '0';
				altpcie_rs_serdes_rx_pll_locked_rrr_4_51q <= '0';
				altpcie_rs_serdes_rx_pll_locked_rrr_5_57q <= '0';
				altpcie_rs_serdes_rx_pll_locked_rrr_6_63q <= '0';
				altpcie_rs_serdes_rx_pll_locked_rrr_7_69q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_0_530q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_10_520q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_11_519q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_12_518q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_13_517q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_14_516q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_15_515q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_16_514q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_17_513q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_18_512q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_19_511q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_1_529q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_2_528q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_3_527q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_4_526q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_5_525q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_6_524q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_7_523q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_8_522q <= '0';
				altpcie_rs_serdes_rx_sd_idl_cnt_9_521q <= '0';
				altpcie_rs_serdes_rx_sd_strb0_0_269q <= '0';
				altpcie_rs_serdes_rx_sd_strb0_1_268q <= '0';
				altpcie_rs_serdes_rx_sd_strb0_2_267q <= '0';
				altpcie_rs_serdes_rx_sd_strb0_3_266q <= '0';
				altpcie_rs_serdes_rx_sd_strb0_4_265q <= '0';
				altpcie_rs_serdes_rx_sd_strb0_5_264q <= '0';
				altpcie_rs_serdes_rx_sd_strb0_6_263q <= '0';
				altpcie_rs_serdes_rx_sd_strb0_7_262q <= '0';
				altpcie_rs_serdes_rx_sd_strb1_0_510q <= '0';
				altpcie_rs_serdes_rx_sd_strb1_1_276q <= '0';
				altpcie_rs_serdes_rx_sd_strb1_2_275q <= '0';
				altpcie_rs_serdes_rx_sd_strb1_3_274q <= '0';
				altpcie_rs_serdes_rx_sd_strb1_4_273q <= '0';
				altpcie_rs_serdes_rx_sd_strb1_5_272q <= '0';
				altpcie_rs_serdes_rx_sd_strb1_6_271q <= '0';
				altpcie_rs_serdes_rx_sd_strb1_7_270q <= '0';
				altpcie_rs_serdes_rx_signaldetect_r_0_28q <= '0';
				altpcie_rs_serdes_rx_signaldetect_r_1_34q <= '0';
				altpcie_rs_serdes_rx_signaldetect_r_2_40q <= '0';
				altpcie_rs_serdes_rx_signaldetect_r_3_46q <= '0';
				altpcie_rs_serdes_rx_signaldetect_r_4_52q <= '0';
				altpcie_rs_serdes_rx_signaldetect_r_5_58q <= '0';
				altpcie_rs_serdes_rx_signaldetect_r_6_64q <= '0';
				altpcie_rs_serdes_rx_signaldetect_r_7_70q <= '0';
				altpcie_rs_serdes_rx_signaldetect_rr_0_29q <= '0';
				altpcie_rs_serdes_rx_signaldetect_rr_1_35q <= '0';
				altpcie_rs_serdes_rx_signaldetect_rr_2_41q <= '0';
				altpcie_rs_serdes_rx_signaldetect_rr_3_47q <= '0';
				altpcie_rs_serdes_rx_signaldetect_rr_4_53q <= '0';
				altpcie_rs_serdes_rx_signaldetect_rr_5_59q <= '0';
				altpcie_rs_serdes_rx_signaldetect_rr_6_65q <= '0';
				altpcie_rs_serdes_rx_signaldetect_rr_7_71q <= '0';
				altpcie_rs_serdes_rx_signaldetect_rrr_0_30q <= '0';
				altpcie_rs_serdes_rx_signaldetect_rrr_1_36q <= '0';
				altpcie_rs_serdes_rx_signaldetect_rrr_2_42q <= '0';
				altpcie_rs_serdes_rx_signaldetect_rrr_3_48q <= '0';
				altpcie_rs_serdes_rx_signaldetect_rrr_4_54q <= '0';
				altpcie_rs_serdes_rx_signaldetect_rrr_5_60q <= '0';
				altpcie_rs_serdes_rx_signaldetect_rrr_6_66q <= '0';
				altpcie_rs_serdes_rx_signaldetect_rrr_7_205q <= '0';
				altpcie_rs_serdes_sd_state_0_206q <= '0';
				altpcie_rs_serdes_sd_state_1_531q <= '0';
				altpcie_rs_serdes_serdes_rst_state_idle_st_cnt_231q <= '0';
				altpcie_rs_serdes_serdes_rst_state_stable_tx_pll_st_cnt_232q <= '0';
				altpcie_rs_serdes_serdes_rst_state_wait_state_st_cnt_233q <= '0';
				altpcie_rs_serdes_ws_tmr_eq_0_234q <= '0';
		ELSIF (pld_clk = '1' AND pld_clk'event) THEN
				altpcie_rs_serdes_ld_ws_tmr_short_236q <= wire_altpcie_rs_serdes_selector8_204_o;
				altpcie_rs_serdes_pll_locked_cnt_0_257q <= wire_altpcie_rs_serdes_pll_locked_cnt_102m_dataout;
				altpcie_rs_serdes_pll_locked_cnt_1_256q <= wire_altpcie_rs_serdes_pll_locked_cnt_101m_dataout;
				altpcie_rs_serdes_pll_locked_cnt_2_255q <= wire_altpcie_rs_serdes_pll_locked_cnt_100m_dataout;
				altpcie_rs_serdes_pll_locked_cnt_3_254q <= wire_altpcie_rs_serdes_pll_locked_cnt_99m_dataout;
				altpcie_rs_serdes_pll_locked_cnt_4_253q <= wire_altpcie_rs_serdes_pll_locked_cnt_98m_dataout;
				altpcie_rs_serdes_pll_locked_cnt_5_252q <= wire_altpcie_rs_serdes_pll_locked_cnt_97m_dataout;
				altpcie_rs_serdes_pll_locked_cnt_6_251q <= wire_altpcie_rs_serdes_pll_locked_cnt_96m_dataout;
				altpcie_rs_serdes_pll_locked_r_0_21q <= pll_locked;
				altpcie_rs_serdes_pll_locked_r_1_20q <= altpcie_rs_serdes_pll_locked_r_0_21q;
				altpcie_rs_serdes_pll_locked_r_2_19q <= altpcie_rs_serdes_pll_locked_r_1_20q;
				altpcie_rs_serdes_pll_locked_stable_258q <= s_wire_altpcie_rs_serdes_pll_locked_stable_638_dataout;
				altpcie_rs_serdes_rx_pll_freq_locked_cnt_0_239q <= wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_371m_dataout;
				altpcie_rs_serdes_rx_pll_freq_locked_cnt_1_238q <= wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_373m_dataout;
				altpcie_rs_serdes_rx_pll_freq_locked_cnt_2_237q <= wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_376m_dataout;
				altpcie_rs_serdes_rx_pll_freq_locked_r_0_24q <= s_wire_altpcie_rs_serdes_wideand0_17_dataout;
				altpcie_rs_serdes_rx_pll_freq_locked_r_1_23q <= altpcie_rs_serdes_rx_pll_freq_locked_r_0_24q;
				altpcie_rs_serdes_rx_pll_freq_locked_r_2_22q <= altpcie_rs_serdes_rx_pll_freq_locked_r_1_23q;
				altpcie_rs_serdes_rx_pll_freq_locked_sync_r_240q <= wire_w296w(0);
				altpcie_rs_serdes_rx_pll_locked_r_0_25q <= rx_pll_locked(0);
				altpcie_rs_serdes_rx_pll_locked_r_1_31q <= rx_pll_locked(1);
				altpcie_rs_serdes_rx_pll_locked_r_2_37q <= rx_pll_locked(2);
				altpcie_rs_serdes_rx_pll_locked_r_3_43q <= rx_pll_locked(3);
				altpcie_rs_serdes_rx_pll_locked_r_4_49q <= rx_pll_locked(4);
				altpcie_rs_serdes_rx_pll_locked_r_5_55q <= rx_pll_locked(5);
				altpcie_rs_serdes_rx_pll_locked_r_6_61q <= rx_pll_locked(6);
				altpcie_rs_serdes_rx_pll_locked_r_7_67q <= rx_pll_locked(7);
				altpcie_rs_serdes_rx_pll_locked_rr_0_26q <= altpcie_rs_serdes_rx_pll_locked_r_0_25q;
				altpcie_rs_serdes_rx_pll_locked_rr_1_32q <= altpcie_rs_serdes_rx_pll_locked_r_1_31q;
				altpcie_rs_serdes_rx_pll_locked_rr_2_38q <= altpcie_rs_serdes_rx_pll_locked_r_2_37q;
				altpcie_rs_serdes_rx_pll_locked_rr_3_44q <= altpcie_rs_serdes_rx_pll_locked_r_3_43q;
				altpcie_rs_serdes_rx_pll_locked_rr_4_50q <= altpcie_rs_serdes_rx_pll_locked_r_4_49q;
				altpcie_rs_serdes_rx_pll_locked_rr_5_56q <= altpcie_rs_serdes_rx_pll_locked_r_5_55q;
				altpcie_rs_serdes_rx_pll_locked_rr_6_62q <= altpcie_rs_serdes_rx_pll_locked_r_6_61q;
				altpcie_rs_serdes_rx_pll_locked_rr_7_68q <= altpcie_rs_serdes_rx_pll_locked_r_7_67q;
				altpcie_rs_serdes_rx_pll_locked_rrr_0_27q <= altpcie_rs_serdes_rx_pll_locked_rr_0_26q;
				altpcie_rs_serdes_rx_pll_locked_rrr_1_33q <= altpcie_rs_serdes_rx_pll_locked_rr_1_32q;
				altpcie_rs_serdes_rx_pll_locked_rrr_2_39q <= altpcie_rs_serdes_rx_pll_locked_rr_2_38q;
				altpcie_rs_serdes_rx_pll_locked_rrr_3_45q <= altpcie_rs_serdes_rx_pll_locked_rr_3_44q;
				altpcie_rs_serdes_rx_pll_locked_rrr_4_51q <= altpcie_rs_serdes_rx_pll_locked_rr_4_50q;
				altpcie_rs_serdes_rx_pll_locked_rrr_5_57q <= altpcie_rs_serdes_rx_pll_locked_rr_5_56q;
				altpcie_rs_serdes_rx_pll_locked_rrr_6_63q <= altpcie_rs_serdes_rx_pll_locked_rr_6_62q;
				altpcie_rs_serdes_rx_pll_locked_rrr_7_69q <= altpcie_rs_serdes_rx_pll_locked_rr_7_68q;
				altpcie_rs_serdes_rx_sd_idl_cnt_0_530q <= wire_altpcie_rs_serdes_mux19_507_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_10_520q <= wire_altpcie_rs_serdes_mux9_497_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_11_519q <= wire_altpcie_rs_serdes_mux8_496_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_12_518q <= wire_altpcie_rs_serdes_mux7_495_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_13_517q <= wire_altpcie_rs_serdes_mux6_494_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_14_516q <= wire_altpcie_rs_serdes_mux5_493_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_15_515q <= wire_altpcie_rs_serdes_mux4_492_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_16_514q <= wire_altpcie_rs_serdes_mux3_491_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_17_513q <= wire_altpcie_rs_serdes_mux2_490_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_18_512q <= wire_altpcie_rs_serdes_mux1_489_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_19_511q <= wire_altpcie_rs_serdes_mux0_488_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_1_529q <= wire_altpcie_rs_serdes_mux18_506_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_2_528q <= wire_altpcie_rs_serdes_mux17_505_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_3_527q <= wire_altpcie_rs_serdes_mux16_504_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_4_526q <= wire_altpcie_rs_serdes_mux15_503_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_5_525q <= wire_altpcie_rs_serdes_mux14_502_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_6_524q <= wire_altpcie_rs_serdes_mux13_501_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_7_523q <= wire_altpcie_rs_serdes_mux12_500_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_8_522q <= wire_altpcie_rs_serdes_mux11_499_o;
				altpcie_rs_serdes_rx_sd_idl_cnt_9_521q <= wire_altpcie_rs_serdes_mux10_498_o;
				altpcie_rs_serdes_rx_sd_strb0_0_269q <= altpcie_rs_serdes_rx_signaldetect_rrr_0_30q;
				altpcie_rs_serdes_rx_sd_strb0_1_268q <= altpcie_rs_serdes_rx_signaldetect_rrr_1_36q;
				altpcie_rs_serdes_rx_sd_strb0_2_267q <= altpcie_rs_serdes_rx_signaldetect_rrr_2_42q;
				altpcie_rs_serdes_rx_sd_strb0_3_266q <= altpcie_rs_serdes_rx_signaldetect_rrr_3_48q;
				altpcie_rs_serdes_rx_sd_strb0_4_265q <= altpcie_rs_serdes_rx_signaldetect_rrr_4_54q;
				altpcie_rs_serdes_rx_sd_strb0_5_264q <= altpcie_rs_serdes_rx_signaldetect_rrr_5_60q;
				altpcie_rs_serdes_rx_sd_strb0_6_263q <= altpcie_rs_serdes_rx_signaldetect_rrr_6_66q;
				altpcie_rs_serdes_rx_sd_strb0_7_262q <= altpcie_rs_serdes_rx_signaldetect_rrr_7_205q;
				altpcie_rs_serdes_rx_sd_strb1_0_510q <= altpcie_rs_serdes_rx_sd_strb0_0_269q;
				altpcie_rs_serdes_rx_sd_strb1_1_276q <= altpcie_rs_serdes_rx_sd_strb0_1_268q;
				altpcie_rs_serdes_rx_sd_strb1_2_275q <= altpcie_rs_serdes_rx_sd_strb0_2_267q;
				altpcie_rs_serdes_rx_sd_strb1_3_274q <= altpcie_rs_serdes_rx_sd_strb0_3_266q;
				altpcie_rs_serdes_rx_sd_strb1_4_273q <= altpcie_rs_serdes_rx_sd_strb0_4_265q;
				altpcie_rs_serdes_rx_sd_strb1_5_272q <= altpcie_rs_serdes_rx_sd_strb0_5_264q;
				altpcie_rs_serdes_rx_sd_strb1_6_271q <= altpcie_rs_serdes_rx_sd_strb0_6_263q;
				altpcie_rs_serdes_rx_sd_strb1_7_270q <= altpcie_rs_serdes_rx_sd_strb0_7_262q;
				altpcie_rs_serdes_rx_signaldetect_r_0_28q <= rx_signaldetect(0);
				altpcie_rs_serdes_rx_signaldetect_r_1_34q <= rx_signaldetect(1);
				altpcie_rs_serdes_rx_signaldetect_r_2_40q <= rx_signaldetect(2);
				altpcie_rs_serdes_rx_signaldetect_r_3_46q <= rx_signaldetect(3);
				altpcie_rs_serdes_rx_signaldetect_r_4_52q <= rx_signaldetect(4);
				altpcie_rs_serdes_rx_signaldetect_r_5_58q <= rx_signaldetect(5);
				altpcie_rs_serdes_rx_signaldetect_r_6_64q <= rx_signaldetect(6);
				altpcie_rs_serdes_rx_signaldetect_r_7_70q <= rx_signaldetect(7);
				altpcie_rs_serdes_rx_signaldetect_rr_0_29q <= altpcie_rs_serdes_rx_signaldetect_r_0_28q;
				altpcie_rs_serdes_rx_signaldetect_rr_1_35q <= altpcie_rs_serdes_rx_signaldetect_r_1_34q;
				altpcie_rs_serdes_rx_signaldetect_rr_2_41q <= altpcie_rs_serdes_rx_signaldetect_r_2_40q;
				altpcie_rs_serdes_rx_signaldetect_rr_3_47q <= altpcie_rs_serdes_rx_signaldetect_r_3_46q;
				altpcie_rs_serdes_rx_signaldetect_rr_4_53q <= altpcie_rs_serdes_rx_signaldetect_r_4_52q;
				altpcie_rs_serdes_rx_signaldetect_rr_5_59q <= altpcie_rs_serdes_rx_signaldetect_r_5_58q;
				altpcie_rs_serdes_rx_signaldetect_rr_6_65q <= altpcie_rs_serdes_rx_signaldetect_r_6_64q;
				altpcie_rs_serdes_rx_signaldetect_rr_7_71q <= altpcie_rs_serdes_rx_signaldetect_r_7_70q;
				altpcie_rs_serdes_rx_signaldetect_rrr_0_30q <= altpcie_rs_serdes_rx_signaldetect_rr_0_29q;
				altpcie_rs_serdes_rx_signaldetect_rrr_1_36q <= altpcie_rs_serdes_rx_signaldetect_rr_1_35q;
				altpcie_rs_serdes_rx_signaldetect_rrr_2_42q <= altpcie_rs_serdes_rx_signaldetect_rr_2_41q;
				altpcie_rs_serdes_rx_signaldetect_rrr_3_48q <= altpcie_rs_serdes_rx_signaldetect_rr_3_47q;
				altpcie_rs_serdes_rx_signaldetect_rrr_4_54q <= altpcie_rs_serdes_rx_signaldetect_rr_4_53q;
				altpcie_rs_serdes_rx_signaldetect_rrr_5_60q <= altpcie_rs_serdes_rx_signaldetect_rr_5_59q;
				altpcie_rs_serdes_rx_signaldetect_rrr_6_66q <= altpcie_rs_serdes_rx_signaldetect_rr_6_65q;
				altpcie_rs_serdes_rx_signaldetect_rrr_7_205q <= altpcie_rs_serdes_rx_signaldetect_rr_7_71q;
				altpcie_rs_serdes_sd_state_0_206q <= wire_altpcie_rs_serdes_mux21_509_o;
				altpcie_rs_serdes_sd_state_1_531q <= wire_altpcie_rs_serdes_mux20_508_o;
				altpcie_rs_serdes_serdes_rst_state_idle_st_cnt_231q <= wire_altpcie_rs_serdes_selector2_195_o;
				altpcie_rs_serdes_serdes_rst_state_stable_tx_pll_st_cnt_232q <= wire_altpcie_rs_serdes_selector3_196_o;
				altpcie_rs_serdes_serdes_rst_state_wait_state_st_cnt_233q <= wire_altpcie_rs_serdes_selector4_198_o;
				altpcie_rs_serdes_ws_tmr_eq_0_234q <= wire_altpcie_rs_serdes_ws_tmr_eq_0_172m_dataout;
		END IF;
	END PROCESS;
	wire_nl_w_lg_w993w994w(0) <= wire_nl_w993w(0) AND altpcie_rs_serdes_rx_sd_idl_cnt_4_526q;
	wire_nl_w993w(0) <= wire_nl_w_lg_w_lg_w_lg_w_lg_w_lg_w984w986w988w989w990w992w(0) AND altpcie_rs_serdes_rx_sd_idl_cnt_5_525q;
	wire_nl_w_lg_w_lg_w_lg_w_lg_w_lg_w984w986w988w989w990w992w(0) <= wire_nl_w_lg_w_lg_w_lg_w_lg_w984w986w988w989w990w(0) AND wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_6_524q991w(0);
	wire_nl_w_lg_w_lg_w_lg_w_lg_w984w986w988w989w990w(0) <= wire_nl_w_lg_w_lg_w_lg_w984w986w988w989w(0) AND altpcie_rs_serdes_rx_sd_idl_cnt_7_523q;
	wire_nl_w_lg_w_lg_w_lg_w984w986w988w989w(0) <= wire_nl_w_lg_w_lg_w984w986w988w(0) AND altpcie_rs_serdes_rx_sd_idl_cnt_8_522q;
	wire_nl_w_lg_w_lg_w984w986w988w(0) <= wire_nl_w_lg_w984w986w(0) AND wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_9_521q987w(0);
	wire_nl_w_lg_w984w986w(0) <= wire_nl_w984w(0) AND wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_10_520q985w(0);
	wire_nl_w984w(0) <= wire_nl_w_lg_w_lg_w_lg_w_lg_w_lg_w976w977w979w980w981w982w(0) AND wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_11_519q983w(0);
	wire_nl_w_lg_w_lg_w_lg_w_lg_w_lg_w976w977w979w980w981w982w(0) <= wire_nl_w_lg_w_lg_w_lg_w_lg_w976w977w979w980w981w(0) AND altpcie_rs_serdes_rx_sd_idl_cnt_12_518q;
	wire_nl_w_lg_w_lg_w_lg_w_lg_w976w977w979w980w981w(0) <= wire_nl_w_lg_w_lg_w_lg_w976w977w979w980w(0) AND altpcie_rs_serdes_rx_sd_idl_cnt_13_517q;
	wire_nl_w_lg_w_lg_w_lg_w976w977w979w980w(0) <= wire_nl_w_lg_w_lg_w976w977w979w(0) AND altpcie_rs_serdes_rx_sd_idl_cnt_14_516q;
	wire_nl_w_lg_w_lg_w976w977w979w(0) <= wire_nl_w_lg_w976w977w(0) AND wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_15_515q978w(0);
	wire_nl_w_lg_w976w977w(0) <= wire_nl_w976w(0) AND altpcie_rs_serdes_rx_sd_idl_cnt_16_514q;
	wire_nl_w976w(0) <= wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_19_511q975w(0) AND altpcie_rs_serdes_rx_sd_idl_cnt_17_513q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_19_511q975w(0) <= altpcie_rs_serdes_rx_sd_idl_cnt_19_511q AND wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_18_512q974w(0);
	wire_nl_w_lg_altpcie_rs_serdes_ld_ws_tmr_short_236q207w(0) <= NOT altpcie_rs_serdes_ld_ws_tmr_short_236q;
	wire_nl_w_lg_altpcie_rs_serdes_pll_locked_r_2_19q111w(0) <= NOT altpcie_rs_serdes_pll_locked_r_2_19q;
	wire_nl_w880w(0) <= NOT altpcie_rs_serdes_rx_pll_freq_locked_cnt_0_239q;
	wire_nl_w878w(0) <= NOT altpcie_rs_serdes_rx_pll_freq_locked_cnt_1_238q;
	wire_nl_w877w(0) <= NOT altpcie_rs_serdes_rx_pll_freq_locked_cnt_2_237q;
	wire_nl_w226w(0) <= NOT altpcie_rs_serdes_rx_pll_freq_locked_sync_r_240q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_0_530q1001w(0) <= NOT altpcie_rs_serdes_rx_sd_idl_cnt_0_530q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_10_520q985w(0) <= NOT altpcie_rs_serdes_rx_sd_idl_cnt_10_520q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_11_519q983w(0) <= NOT altpcie_rs_serdes_rx_sd_idl_cnt_11_519q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_15_515q978w(0) <= NOT altpcie_rs_serdes_rx_sd_idl_cnt_15_515q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_18_512q974w(0) <= NOT altpcie_rs_serdes_rx_sd_idl_cnt_18_512q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_1_529q999w(0) <= NOT altpcie_rs_serdes_rx_sd_idl_cnt_1_529q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_2_528q997w(0) <= NOT altpcie_rs_serdes_rx_sd_idl_cnt_2_528q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_3_527q995w(0) <= NOT altpcie_rs_serdes_rx_sd_idl_cnt_3_527q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_6_524q991w(0) <= NOT altpcie_rs_serdes_rx_sd_idl_cnt_6_524q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_idl_cnt_9_521q987w(0) <= NOT altpcie_rs_serdes_rx_sd_idl_cnt_9_521q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_0_510q963w(0) <= NOT altpcie_rs_serdes_rx_sd_strb1_0_510q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_1_276q961w(0) <= NOT altpcie_rs_serdes_rx_sd_strb1_1_276q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_2_275q959w(0) <= NOT altpcie_rs_serdes_rx_sd_strb1_2_275q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_3_274q957w(0) <= NOT altpcie_rs_serdes_rx_sd_strb1_3_274q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_4_273q955w(0) <= NOT altpcie_rs_serdes_rx_sd_strb1_4_273q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_5_272q953w(0) <= NOT altpcie_rs_serdes_rx_sd_strb1_5_272q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_6_271q951w(0) <= NOT altpcie_rs_serdes_rx_sd_strb1_6_271q;
	wire_nl_w_lg_altpcie_rs_serdes_rx_sd_strb1_7_270q950w(0) <= NOT altpcie_rs_serdes_rx_sd_strb1_7_270q;
	PROCESS (pld_clk, altpcie_rs_serdes_arst_r_2_7q)
	BEGIN
		IF (altpcie_rs_serdes_arst_r_2_7q = '1') THEN
				altpcie_rs_serdes_rx_pll_locked_sync_r_0_248q <= '0';
				altpcie_rs_serdes_rx_pll_locked_sync_r_1_247q <= '0';
				altpcie_rs_serdes_rx_pll_locked_sync_r_2_246q <= '0';
				altpcie_rs_serdes_rx_pll_locked_sync_r_3_245q <= '0';
				altpcie_rs_serdes_rx_pll_locked_sync_r_4_244q <= '0';
				altpcie_rs_serdes_rx_pll_locked_sync_r_5_243q <= '0';
				altpcie_rs_serdes_rx_pll_locked_sync_r_6_242q <= '0';
				altpcie_rs_serdes_rx_pll_locked_sync_r_7_241q <= '0';
		ELSIF (pld_clk = '1' AND pld_clk'event) THEN
			IF (s_wire_altpcie_rs_serdes_rx_pll_locked_sync_r_7_626_dataout = '1') THEN
				altpcie_rs_serdes_rx_pll_locked_sync_r_0_248q <= s_wire_vcc;
				altpcie_rs_serdes_rx_pll_locked_sync_r_1_247q <= s_wire_vcc;
				altpcie_rs_serdes_rx_pll_locked_sync_r_2_246q <= s_wire_vcc;
				altpcie_rs_serdes_rx_pll_locked_sync_r_3_245q <= s_wire_vcc;
				altpcie_rs_serdes_rx_pll_locked_sync_r_4_244q <= s_wire_vcc;
				altpcie_rs_serdes_rx_pll_locked_sync_r_5_243q <= s_wire_vcc;
				altpcie_rs_serdes_rx_pll_locked_sync_r_6_242q <= s_wire_vcc;
				altpcie_rs_serdes_rx_pll_locked_sync_r_7_241q <= s_wire_vcc;
			END IF;
		END IF;
	END PROCESS;
	wire_nlO_w4w(0) <= altpcie_rs_serdes_rx_pll_locked_sync_r_0_248q OR wire_w_rx_freqlocked_range3w(0);
	wire_nlO_w6w(0) <= altpcie_rs_serdes_rx_pll_locked_sync_r_1_247q OR wire_w_rx_freqlocked_range5w(0);
	wire_nlO_w9w(0) <= altpcie_rs_serdes_rx_pll_locked_sync_r_2_246q OR wire_w_rx_freqlocked_range8w(0);
	wire_nlO_w12w(0) <= altpcie_rs_serdes_rx_pll_locked_sync_r_3_245q OR wire_w_rx_freqlocked_range11w(0);
	wire_nlO_w15w(0) <= altpcie_rs_serdes_rx_pll_locked_sync_r_4_244q OR wire_w_rx_freqlocked_range14w(0);
	wire_nlO_w18w(0) <= altpcie_rs_serdes_rx_pll_locked_sync_r_5_243q OR wire_w_rx_freqlocked_range17w(0);
	wire_nlO_w21w(0) <= altpcie_rs_serdes_rx_pll_locked_sync_r_6_242q OR wire_w_rx_freqlocked_range20w(0);
	wire_nlO_w24w(0) <= altpcie_rs_serdes_rx_pll_locked_sync_r_7_241q OR wire_w_rx_freqlocked_range23w(0);
	PROCESS (pld_clk, npor)
	BEGIN
		IF (npor = '0') THEN
				altpcie_rs_serdes_arst_r_0_18q <= '1';
				altpcie_rs_serdes_arst_r_1_8q <= '1';
				altpcie_rs_serdes_arst_r_2_7q <= '1';
		ELSIF (pld_clk = '1' AND pld_clk'event) THEN
				altpcie_rs_serdes_arst_r_0_18q <= s_wire_gnd;
				altpcie_rs_serdes_arst_r_1_8q <= altpcie_rs_serdes_arst_r_0_18q;
				altpcie_rs_serdes_arst_r_2_7q <= altpcie_rs_serdes_arst_r_1_8q;
		END IF;
		if (now = 0 ns) then
			altpcie_rs_serdes_arst_r_0_18q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_arst_r_1_8q <= '1' after 1 ps;
		end if;
		if (now = 0 ns) then
			altpcie_rs_serdes_arst_r_2_7q <= '1' after 1 ps;
		end if;
	END PROCESS;
	wire_nO_w_lg_altpcie_rs_serdes_arst_r_2_7q26w(0) <= NOT altpcie_rs_serdes_arst_r_2_7q;
	wire_altpcie_rs_serdes_ld_ws_tmr_183m_dataout <= altpcie_rs_serdes_ld_ws_tmr_235q OR NOT(altpcie_rs_serdes_rx_pll_freq_locked_sync_r_240q);
	wire_altpcie_rs_serdes_ld_ws_tmr_short_184m_dataout <= altpcie_rs_serdes_ld_ws_tmr_short_236q OR altpcie_rs_serdes_rx_pll_freq_locked_sync_r_240q;
	wire_altpcie_rs_serdes_ld_ws_tmr_short_188m_dataout <= altpcie_rs_serdes_ld_ws_tmr_short_236q AND NOT(altpcie_rs_serdes_rx_pll_freq_locked_sync_r_240q);
	wire_altpcie_rs_serdes_pll_locked_cnt_100m_dataout <= wire_altpcie_rs_serdes_pll_locked_cnt_93m_dataout AND NOT(wire_nl_w_lg_altpcie_rs_serdes_pll_locked_r_2_19q111w(0));
	wire_altpcie_rs_serdes_pll_locked_cnt_101m_dataout <= wire_altpcie_rs_serdes_pll_locked_cnt_94m_dataout AND NOT(wire_nl_w_lg_altpcie_rs_serdes_pll_locked_r_2_19q111w(0));
	wire_altpcie_rs_serdes_pll_locked_cnt_102m_dataout <= wire_altpcie_rs_serdes_pll_locked_cnt_95m_dataout AND NOT(wire_nl_w_lg_altpcie_rs_serdes_pll_locked_r_2_19q111w(0));
	wire_altpcie_rs_serdes_pll_locked_cnt_89m_dataout <= wire_altpcie_rs_serdes_add1_88_o(6) WHEN wire_altpcie_rs_serdes_lessthan0_87_o = '1'  ELSE altpcie_rs_serdes_pll_locked_cnt_6_251q;
	wire_altpcie_rs_serdes_pll_locked_cnt_90m_dataout <= wire_altpcie_rs_serdes_add1_88_o(5) WHEN wire_altpcie_rs_serdes_lessthan0_87_o = '1'  ELSE altpcie_rs_serdes_pll_locked_cnt_5_252q;
	wire_altpcie_rs_serdes_pll_locked_cnt_91m_dataout <= wire_altpcie_rs_serdes_add1_88_o(4) WHEN wire_altpcie_rs_serdes_lessthan0_87_o = '1'  ELSE altpcie_rs_serdes_pll_locked_cnt_4_253q;
	wire_altpcie_rs_serdes_pll_locked_cnt_92m_dataout <= wire_altpcie_rs_serdes_add1_88_o(3) WHEN wire_altpcie_rs_serdes_lessthan0_87_o = '1'  ELSE altpcie_rs_serdes_pll_locked_cnt_3_254q;
	wire_altpcie_rs_serdes_pll_locked_cnt_93m_dataout <= wire_altpcie_rs_serdes_add1_88_o(2) WHEN wire_altpcie_rs_serdes_lessthan0_87_o = '1'  ELSE altpcie_rs_serdes_pll_locked_cnt_2_255q;
	wire_altpcie_rs_serdes_pll_locked_cnt_94m_dataout <= wire_altpcie_rs_serdes_add1_88_o(1) WHEN wire_altpcie_rs_serdes_lessthan0_87_o = '1'  ELSE altpcie_rs_serdes_pll_locked_cnt_1_256q;
	wire_altpcie_rs_serdes_pll_locked_cnt_95m_dataout <= wire_altpcie_rs_serdes_add1_88_o(0) WHEN wire_altpcie_rs_serdes_lessthan0_87_o = '1'  ELSE altpcie_rs_serdes_pll_locked_cnt_0_257q;
	wire_altpcie_rs_serdes_pll_locked_cnt_96m_dataout <= wire_altpcie_rs_serdes_pll_locked_cnt_89m_dataout AND NOT(wire_nl_w_lg_altpcie_rs_serdes_pll_locked_r_2_19q111w(0));
	wire_altpcie_rs_serdes_pll_locked_cnt_97m_dataout <= wire_altpcie_rs_serdes_pll_locked_cnt_90m_dataout AND NOT(wire_nl_w_lg_altpcie_rs_serdes_pll_locked_r_2_19q111w(0));
	wire_altpcie_rs_serdes_pll_locked_cnt_98m_dataout <= wire_altpcie_rs_serdes_pll_locked_cnt_91m_dataout AND NOT(wire_nl_w_lg_altpcie_rs_serdes_pll_locked_r_2_19q111w(0));
	wire_altpcie_rs_serdes_pll_locked_cnt_99m_dataout <= wire_altpcie_rs_serdes_pll_locked_cnt_92m_dataout AND NOT(wire_nl_w_lg_altpcie_rs_serdes_pll_locked_r_2_19q111w(0));
	wire_altpcie_rs_serdes_rst_rxpcs_sd_260m_dataout <= altpcie_rs_serdes_sd_state_0_206q AND NOT((test_in(32) OR use_c4gx_serdes));
	wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_371m_dataout <= wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_372m_dataout OR altpcie_rs_serdes_rx_pll_freq_locked_r_2_22q;
	wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_372m_dataout <= wire_altpcie_rs_serdes_add0_84_o(1) AND NOT(s_wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_0_630_dataout);
	wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_373m_dataout <= wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_374m_dataout OR altpcie_rs_serdes_rx_pll_freq_locked_r_2_22q;
	wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_374m_dataout <= wire_altpcie_rs_serdes_add0_84_o(2) AND NOT(s_wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_0_630_dataout);
	wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_376m_dataout <= wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_487m_dataout OR altpcie_rs_serdes_rx_pll_freq_locked_r_2_22q;
	wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_487m_dataout <= wire_altpcie_rs_serdes_add0_84_o(3) AND NOT(s_wire_altpcie_rs_serdes_rx_pll_freq_locked_cnt_0_630_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_284m_dataout <= wire_altpcie_rs_serdes_add3_283_o(19) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_285m_dataout <= wire_altpcie_rs_serdes_add3_283_o(18) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_286m_dataout <= wire_altpcie_rs_serdes_add3_283_o(17) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_287m_dataout <= wire_altpcie_rs_serdes_add3_283_o(16) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_288m_dataout <= wire_altpcie_rs_serdes_add3_283_o(15) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_289m_dataout <= wire_altpcie_rs_serdes_add3_283_o(14) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_290m_dataout <= wire_altpcie_rs_serdes_add3_283_o(13) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_291m_dataout <= wire_altpcie_rs_serdes_add3_283_o(12) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_292m_dataout <= wire_altpcie_rs_serdes_add3_283_o(11) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_293m_dataout <= wire_altpcie_rs_serdes_add3_283_o(10) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_294m_dataout <= wire_altpcie_rs_serdes_add3_283_o(9) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_295m_dataout <= wire_altpcie_rs_serdes_add3_283_o(8) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_296m_dataout <= wire_altpcie_rs_serdes_add3_283_o(7) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_297m_dataout <= wire_altpcie_rs_serdes_add3_283_o(6) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_298m_dataout <= wire_altpcie_rs_serdes_add3_283_o(5) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_299m_dataout <= wire_altpcie_rs_serdes_add3_283_o(4) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_300m_dataout <= wire_altpcie_rs_serdes_add3_283_o(3) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_301m_dataout <= wire_altpcie_rs_serdes_add3_283_o(2) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_302m_dataout <= wire_altpcie_rs_serdes_add3_283_o(1) AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_303m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_0_530q AND wire_altpcie_rs_serdes_lessthan1_282_o;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_306m_dataout <= wire_altpcie_rs_serdes_add4_377_o(19) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_19_511q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_307m_dataout <= wire_altpcie_rs_serdes_add4_377_o(18) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_18_512q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_308m_dataout <= wire_altpcie_rs_serdes_add4_377_o(17) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_17_513q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_309m_dataout <= wire_altpcie_rs_serdes_add4_377_o(16) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_16_514q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_310m_dataout <= wire_altpcie_rs_serdes_add4_377_o(15) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_15_515q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_311m_dataout <= wire_altpcie_rs_serdes_add4_377_o(14) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_14_516q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_312m_dataout <= wire_altpcie_rs_serdes_add4_377_o(13) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_13_517q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_313m_dataout <= wire_altpcie_rs_serdes_add4_377_o(12) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_12_518q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_314m_dataout <= wire_altpcie_rs_serdes_add4_377_o(11) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_11_519q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_315m_dataout <= wire_altpcie_rs_serdes_add4_377_o(10) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_10_520q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_316m_dataout <= wire_altpcie_rs_serdes_add4_377_o(9) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_9_521q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_317m_dataout <= wire_altpcie_rs_serdes_add4_377_o(8) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_8_522q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_318m_dataout <= wire_altpcie_rs_serdes_add4_377_o(7) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_7_523q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_319m_dataout <= wire_altpcie_rs_serdes_add4_377_o(6) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_6_524q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_320m_dataout <= wire_altpcie_rs_serdes_add4_377_o(5) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_5_525q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_321m_dataout <= wire_altpcie_rs_serdes_add4_377_o(4) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_4_526q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_322m_dataout <= wire_altpcie_rs_serdes_add4_377_o(3) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_3_527q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_323m_dataout <= wire_altpcie_rs_serdes_add4_377_o(2) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_2_528q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_324m_dataout <= wire_altpcie_rs_serdes_add4_377_o(1) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_1_529q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_325m_dataout <= wire_altpcie_rs_serdes_add4_377_o(0) WHEN s_wire_altpcie_rs_serdes_always12_305_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_0_530q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_326m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_306m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_327m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_307m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_328m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_308m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_329m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_309m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_330m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_310m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_331m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_311m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_332m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_312m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_333m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_313m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_334m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_314m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_335m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_315m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_336m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_316m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_337m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_317m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_338m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_318m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_339m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_319m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_340m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_320m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_341m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_321m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_342m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_322m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_343m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_323m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_344m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_324m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_345m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_325m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_346m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_284m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_326m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_347m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_285m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_327m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_348m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_286m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_328m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_349m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_287m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_329m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_350m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_288m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_330m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_351m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_289m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_331m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_352m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_290m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_332m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_353m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_291m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_333m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_354m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_292m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_334m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_355m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_293m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_335m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_356m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_294m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_336m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_357m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_295m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_337m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_358m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_296m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_338m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_359m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_297m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_339m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_360m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_298m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_340m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_361m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_299m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_341m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_362m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_300m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_342m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_363m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_301m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_343m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_364m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_302m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_344m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_365m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_303m_dataout WHEN s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout = '1'  ELSE wire_altpcie_rs_serdes_rx_sd_idl_cnt_345m_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_378m_dataout <= wire_altpcie_rs_serdes_add4_377_o(19) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_19_511q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_379m_dataout <= wire_altpcie_rs_serdes_add4_377_o(18) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_18_512q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_380m_dataout <= wire_altpcie_rs_serdes_add4_377_o(17) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_17_513q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_381m_dataout <= wire_altpcie_rs_serdes_add4_377_o(16) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_16_514q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_382m_dataout <= wire_altpcie_rs_serdes_add4_377_o(15) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_15_515q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_383m_dataout <= wire_altpcie_rs_serdes_add4_377_o(14) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_14_516q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_384m_dataout <= wire_altpcie_rs_serdes_add4_377_o(13) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_13_517q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_385m_dataout <= wire_altpcie_rs_serdes_add4_377_o(12) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_12_518q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_386m_dataout <= wire_altpcie_rs_serdes_add4_377_o(11) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_11_519q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_387m_dataout <= wire_altpcie_rs_serdes_add4_377_o(10) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_10_520q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_388m_dataout <= wire_altpcie_rs_serdes_add4_377_o(9) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_9_521q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_389m_dataout <= wire_altpcie_rs_serdes_add4_377_o(8) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_8_522q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_390m_dataout <= wire_altpcie_rs_serdes_add4_377_o(7) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_7_523q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_391m_dataout <= wire_altpcie_rs_serdes_add4_377_o(6) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_6_524q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_392m_dataout <= wire_altpcie_rs_serdes_add4_377_o(5) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_5_525q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_393m_dataout <= wire_altpcie_rs_serdes_add4_377_o(4) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_4_526q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_394m_dataout <= wire_altpcie_rs_serdes_add4_377_o(3) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_3_527q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_395m_dataout <= wire_altpcie_rs_serdes_add4_377_o(2) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_2_528q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_396m_dataout <= wire_altpcie_rs_serdes_add4_377_o(1) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_1_529q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_397m_dataout <= wire_altpcie_rs_serdes_add4_377_o(0) WHEN s_wire_altpcie_rs_serdes_stable_sd_280_dataout = '1'  ELSE altpcie_rs_serdes_rx_sd_idl_cnt_0_530q;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_398m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_378m_dataout OR s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_399m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_379m_dataout AND NOT(s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_400m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_380m_dataout OR s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_401m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_381m_dataout OR s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_402m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_382m_dataout AND NOT(s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_403m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_383m_dataout OR s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_404m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_384m_dataout OR s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_405m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_385m_dataout OR s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_406m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_386m_dataout AND NOT(s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_407m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_387m_dataout AND NOT(s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_408m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_388m_dataout AND NOT(s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_409m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_389m_dataout OR s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_410m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_390m_dataout OR s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_411m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_391m_dataout AND NOT(s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_412m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_392m_dataout OR s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_413m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_393m_dataout OR s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_414m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_394m_dataout AND NOT(s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_415m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_395m_dataout AND NOT(s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_416m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_396m_dataout AND NOT(s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_417m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_397m_dataout AND NOT(s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_420m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_398m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_421m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_399m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_422m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_400m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_423m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_401m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_424m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_402m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_425m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_403m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_426m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_404m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_427m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_405m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_428m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_406m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_429m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_407m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_430m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_408m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_431m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_409m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_432m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_410m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_433m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_411m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_434m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_412m_dataout OR s_wire_altpcie_rs_serdes_always12_370_dataout;
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_435m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_413m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_436m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_414m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_437m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_415m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_438m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_416m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_439m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_417m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_442m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_420m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_443m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_421m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_444m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_422m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_445m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_423m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_446m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_424m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_447m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_425m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_448m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_426m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_449m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_427m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_450m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_428m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_451m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_429m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_452m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_430m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_453m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_431m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_454m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_432m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_455m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_433m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_456m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_434m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_457m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_435m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_458m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_436m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_459m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_437m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_460m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_438m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_461m_dataout <= wire_altpcie_rs_serdes_rx_sd_idl_cnt_439m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_465m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_19_511q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_466m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_18_512q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_467m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_17_513q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_468m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_16_514q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_469m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_15_515q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_470m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_14_516q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_471m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_13_517q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_472m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_12_518q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_473m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_11_519q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_474m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_10_520q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_475m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_9_521q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_476m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_8_522q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_477m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_7_523q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_478m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_6_524q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_479m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_5_525q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_480m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_4_526q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_481m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_3_527q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_482m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_2_528q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_483m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_1_529q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rx_sd_idl_cnt_484m_dataout <= altpcie_rs_serdes_rx_sd_idl_cnt_0_530q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_rxanalogreset_1m_dataout <= altpcie_rs_serdes_arst_r_2_7q WHEN use_c4gx_serdes = '1'  ELSE altpcie_rs_serdes_rxanalogreset_r_208q;
	wire_altpcie_rs_serdes_rxanalogreset_r_179m_dataout <= altpcie_rs_serdes_busy_altgxb_reconfig_r_1_249q OR NOT(s_wire_altpcie_rs_serdes_always10_174_dataout);
	wire_altpcie_rs_serdes_rxdigitalreset_4m_dataout <= s_wire_altpcie_rs_serdes_rxdigitalreset_3_dataout AND NOT(altpcie_rs_serdes_ltssm_detect_261q);
	wire_altpcie_rs_serdes_rxdigitalreset_5m_dataout <= s_wire_altpcie_rs_serdes_rxdigitalreset_3_dataout WHEN wire_w_lg_detect_mask_rxdrst2w(0) = '1'  ELSE wire_altpcie_rs_serdes_rxdigitalreset_4m_dataout;
	wire_altpcie_rs_serdes_rxdigitalreset_r_192m_dataout <= wire_w209w(0) OR NOT(altpcie_rs_serdes_rx_pll_freq_locked_sync_r_240q);
	wire_altpcie_rs_serdes_sd_state_366m_dataout <= altpcie_rs_serdes_sd_state_1_531q AND NOT(s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout);
	wire_altpcie_rs_serdes_sd_state_367m_dataout <= altpcie_rs_serdes_sd_state_0_206q OR s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_0_683_dataout;
	wire_altpcie_rs_serdes_sd_state_418m_dataout <= altpcie_rs_serdes_sd_state_1_531q OR s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout;
	wire_altpcie_rs_serdes_sd_state_419m_dataout <= altpcie_rs_serdes_sd_state_0_206q AND NOT(s_wire_altpcie_rs_serdes_rx_sd_idl_cnt_1_710_dataout);
	wire_altpcie_rs_serdes_sd_state_440m_dataout <= wire_altpcie_rs_serdes_sd_state_418m_dataout OR s_wire_altpcie_rs_serdes_always12_370_dataout;
	wire_altpcie_rs_serdes_sd_state_441m_dataout <= wire_altpcie_rs_serdes_sd_state_419m_dataout AND NOT(s_wire_altpcie_rs_serdes_always12_370_dataout);
	wire_altpcie_rs_serdes_sd_state_462m_dataout <= wire_altpcie_rs_serdes_sd_state_440m_dataout AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_sd_state_463m_dataout <= wire_w657w(0) WHEN wire_w529w(0) = '1'  ELSE wire_altpcie_rs_serdes_sd_state_441m_dataout;
	wire_altpcie_rs_serdes_sd_state_485m_dataout <= wire_w657w(0) WHEN wire_w529w(0) = '1'  ELSE altpcie_rs_serdes_sd_state_1_531q;
	wire_altpcie_rs_serdes_sd_state_486m_dataout <= altpcie_rs_serdes_sd_state_0_206q AND NOT(wire_w529w(0));
	wire_altpcie_rs_serdes_serdes_rst_state_177m_dataout <= wire_ni_w205w(0) AND s_wire_altpcie_rs_serdes_always10_174_dataout;
	wire_altpcie_rs_serdes_serdes_rst_state_181m_dataout <= wire_w_lg_fifo_err206w(0) AND altpcie_rs_serdes_rx_pll_freq_locked_sync_r_240q;
	wire_altpcie_rs_serdes_serdes_rst_state_182m_dataout <= fifo_err AND altpcie_rs_serdes_rx_pll_freq_locked_sync_r_240q;
	wire_altpcie_rs_serdes_serdes_rst_state_189m_dataout <= s_wire_altpcie_rs_serdes_always10_186_dataout AND altpcie_rs_serdes_rx_pll_freq_locked_sync_r_240q;
	wire_altpcie_rs_serdes_serdes_rst_state_191m_dataout <= wire_w209w(0) AND altpcie_rs_serdes_rx_pll_freq_locked_sync_r_240q;
	wire_altpcie_rs_serdes_waitstate_timer_106m_dataout <= wire_w_lg_rc_inclk_eq_125mhz112w(0) AND NOT(test_in(0));
	wire_altpcie_rs_serdes_waitstate_timer_107m_dataout <= rc_inclk_eq_125mhz AND NOT(test_in(0));
	wire_altpcie_rs_serdes_waitstate_timer_111m_dataout <= wire_altpcie_rs_serdes_add2_110_o(20) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_19_210q;
	wire_altpcie_rs_serdes_waitstate_timer_112m_dataout <= wire_altpcie_rs_serdes_add2_110_o(19) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_18_211q;
	wire_altpcie_rs_serdes_waitstate_timer_113m_dataout <= wire_altpcie_rs_serdes_add2_110_o(18) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_17_212q;
	wire_altpcie_rs_serdes_waitstate_timer_114m_dataout <= wire_altpcie_rs_serdes_add2_110_o(17) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_16_213q;
	wire_altpcie_rs_serdes_waitstate_timer_115m_dataout <= wire_altpcie_rs_serdes_add2_110_o(16) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_15_214q;
	wire_altpcie_rs_serdes_waitstate_timer_116m_dataout <= wire_altpcie_rs_serdes_add2_110_o(15) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_14_215q;
	wire_altpcie_rs_serdes_waitstate_timer_117m_dataout <= wire_altpcie_rs_serdes_add2_110_o(14) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_13_216q;
	wire_altpcie_rs_serdes_waitstate_timer_118m_dataout <= wire_altpcie_rs_serdes_add2_110_o(13) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_12_217q;
	wire_altpcie_rs_serdes_waitstate_timer_119m_dataout <= wire_altpcie_rs_serdes_add2_110_o(12) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_11_218q;
	wire_altpcie_rs_serdes_waitstate_timer_120m_dataout <= wire_altpcie_rs_serdes_add2_110_o(11) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_10_219q;
	wire_altpcie_rs_serdes_waitstate_timer_121m_dataout <= wire_altpcie_rs_serdes_add2_110_o(10) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_9_220q;
	wire_altpcie_rs_serdes_waitstate_timer_122m_dataout <= wire_altpcie_rs_serdes_add2_110_o(9) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_8_221q;
	wire_altpcie_rs_serdes_waitstate_timer_123m_dataout <= wire_altpcie_rs_serdes_add2_110_o(8) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_7_222q;
	wire_altpcie_rs_serdes_waitstate_timer_124m_dataout <= wire_altpcie_rs_serdes_add2_110_o(7) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_6_223q;
	wire_altpcie_rs_serdes_waitstate_timer_125m_dataout <= wire_altpcie_rs_serdes_add2_110_o(6) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_5_224q;
	wire_altpcie_rs_serdes_waitstate_timer_126m_dataout <= wire_altpcie_rs_serdes_add2_110_o(5) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_4_225q;
	wire_altpcie_rs_serdes_waitstate_timer_127m_dataout <= wire_altpcie_rs_serdes_add2_110_o(4) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_3_226q;
	wire_altpcie_rs_serdes_waitstate_timer_128m_dataout <= wire_altpcie_rs_serdes_add2_110_o(3) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_2_227q;
	wire_altpcie_rs_serdes_waitstate_timer_129m_dataout <= wire_altpcie_rs_serdes_add2_110_o(2) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_1_228q;
	wire_altpcie_rs_serdes_waitstate_timer_130m_dataout <= wire_altpcie_rs_serdes_add2_110_o(1) WHEN wire_w181w(0) = '1'  ELSE altpcie_rs_serdes_waitstate_timer_0_229q;
	wire_altpcie_rs_serdes_waitstate_timer_131m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_111m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_132m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_112m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_133m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_113m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_134m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_114m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_135m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_115m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_136m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_116m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_137m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_117m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_138m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_118m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_139m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_119m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_140m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_120m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_141m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_121m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_142m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_122m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_143m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_123m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_144m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_124m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_145m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_125m_dataout OR altpcie_rs_serdes_ld_ws_tmr_short_236q;
	wire_altpcie_rs_serdes_waitstate_timer_146m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_126m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_147m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_127m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_148m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_128m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_149m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_129m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_150m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_130m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_short_236q);
	wire_altpcie_rs_serdes_waitstate_timer_151m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_131m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_235q);
	wire_altpcie_rs_serdes_waitstate_timer_152m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_132m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_235q);
	wire_altpcie_rs_serdes_waitstate_timer_153m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_106m_dataout WHEN altpcie_rs_serdes_ld_ws_tmr_235q = '1'  ELSE wire_altpcie_rs_serdes_waitstate_timer_133m_dataout;
	wire_altpcie_rs_serdes_waitstate_timer_154m_dataout <= (NOT test_in(0)) WHEN altpcie_rs_serdes_ld_ws_tmr_235q = '1'  ELSE wire_altpcie_rs_serdes_waitstate_timer_134m_dataout;
	wire_altpcie_rs_serdes_waitstate_timer_155m_dataout <= (NOT test_in(0)) WHEN altpcie_rs_serdes_ld_ws_tmr_235q = '1'  ELSE wire_altpcie_rs_serdes_waitstate_timer_135m_dataout;
	wire_altpcie_rs_serdes_waitstate_timer_156m_dataout <= (NOT test_in(0)) WHEN altpcie_rs_serdes_ld_ws_tmr_235q = '1'  ELSE wire_altpcie_rs_serdes_waitstate_timer_136m_dataout;
	wire_altpcie_rs_serdes_waitstate_timer_157m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_107m_dataout WHEN altpcie_rs_serdes_ld_ws_tmr_235q = '1'  ELSE wire_altpcie_rs_serdes_waitstate_timer_137m_dataout;
	wire_altpcie_rs_serdes_waitstate_timer_158m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_106m_dataout WHEN altpcie_rs_serdes_ld_ws_tmr_235q = '1'  ELSE wire_altpcie_rs_serdes_waitstate_timer_138m_dataout;
	wire_altpcie_rs_serdes_waitstate_timer_159m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_107m_dataout WHEN altpcie_rs_serdes_ld_ws_tmr_235q = '1'  ELSE wire_altpcie_rs_serdes_waitstate_timer_139m_dataout;
	wire_altpcie_rs_serdes_waitstate_timer_160m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_140m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_235q);
	wire_altpcie_rs_serdes_waitstate_timer_161m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_141m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_235q);
	wire_altpcie_rs_serdes_waitstate_timer_162m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_142m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_235q);
	wire_altpcie_rs_serdes_waitstate_timer_163m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_106m_dataout WHEN altpcie_rs_serdes_ld_ws_tmr_235q = '1'  ELSE wire_altpcie_rs_serdes_waitstate_timer_143m_dataout;
	wire_altpcie_rs_serdes_waitstate_timer_164m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_107m_dataout WHEN altpcie_rs_serdes_ld_ws_tmr_235q = '1'  ELSE wire_altpcie_rs_serdes_waitstate_timer_144m_dataout;
	wire_altpcie_rs_serdes_waitstate_timer_165m_dataout <= test_in(0) WHEN altpcie_rs_serdes_ld_ws_tmr_235q = '1'  ELSE wire_altpcie_rs_serdes_waitstate_timer_145m_dataout;
	wire_altpcie_rs_serdes_waitstate_timer_166m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_106m_dataout WHEN altpcie_rs_serdes_ld_ws_tmr_235q = '1'  ELSE wire_altpcie_rs_serdes_waitstate_timer_146m_dataout;
	wire_altpcie_rs_serdes_waitstate_timer_167m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_107m_dataout WHEN altpcie_rs_serdes_ld_ws_tmr_235q = '1'  ELSE wire_altpcie_rs_serdes_waitstate_timer_147m_dataout;
	wire_altpcie_rs_serdes_waitstate_timer_168m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_148m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_235q);
	wire_altpcie_rs_serdes_waitstate_timer_169m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_149m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_235q);
	wire_altpcie_rs_serdes_waitstate_timer_170m_dataout <= wire_altpcie_rs_serdes_waitstate_timer_150m_dataout AND NOT(altpcie_rs_serdes_ld_ws_tmr_235q);
	wire_altpcie_rs_serdes_ws_tmr_eq_0_172m_dataout <= s_wire_altpcie_rs_serdes_ws_tmr_eq_0_0_659_dataout AND NOT((altpcie_rs_serdes_ld_ws_tmr_235q OR altpcie_rs_serdes_ld_ws_tmr_short_236q));
	wire_altpcie_rs_serdes_add0_84_a <= ( altpcie_rs_serdes_rx_pll_freq_locked_cnt_2_237q & altpcie_rs_serdes_rx_pll_freq_locked_cnt_1_238q & altpcie_rs_serdes_rx_pll_freq_locked_cnt_0_239q & "1");
	wire_altpcie_rs_serdes_add0_84_b <= ( "1" & "1" & "0" & "1");
	altpcie_rs_serdes_add0_84 :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 4,
		width_b => 4,
		width_o => 4
	  )
	  PORT MAP ( 
		a => wire_altpcie_rs_serdes_add0_84_a,
		b => wire_altpcie_rs_serdes_add0_84_b,
		cin => wire_gnd,
		o => wire_altpcie_rs_serdes_add0_84_o
	  );
	wire_altpcie_rs_serdes_add1_88_a <= ( altpcie_rs_serdes_pll_locked_cnt_6_251q & altpcie_rs_serdes_pll_locked_cnt_5_252q & altpcie_rs_serdes_pll_locked_cnt_4_253q & altpcie_rs_serdes_pll_locked_cnt_3_254q & altpcie_rs_serdes_pll_locked_cnt_2_255q & altpcie_rs_serdes_pll_locked_cnt_1_256q & altpcie_rs_serdes_pll_locked_cnt_0_257q);
	wire_altpcie_rs_serdes_add1_88_b <= ( "0" & "0" & "0" & "0" & "0" & "0" & "1");
	altpcie_rs_serdes_add1_88 :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 7,
		width_b => 7,
		width_o => 7
	  )
	  PORT MAP ( 
		a => wire_altpcie_rs_serdes_add1_88_a,
		b => wire_altpcie_rs_serdes_add1_88_b,
		cin => wire_gnd,
		o => wire_altpcie_rs_serdes_add1_88_o
	  );
	wire_altpcie_rs_serdes_add2_110_a <= ( altpcie_rs_serdes_waitstate_timer_19_210q & altpcie_rs_serdes_waitstate_timer_18_211q & altpcie_rs_serdes_waitstate_timer_17_212q & altpcie_rs_serdes_waitstate_timer_16_213q & altpcie_rs_serdes_waitstate_timer_15_214q & altpcie_rs_serdes_waitstate_timer_14_215q & altpcie_rs_serdes_waitstate_timer_13_216q & altpcie_rs_serdes_waitstate_timer_12_217q & altpcie_rs_serdes_waitstate_timer_11_218q & altpcie_rs_serdes_waitstate_timer_10_219q & altpcie_rs_serdes_waitstate_timer_9_220q & altpcie_rs_serdes_waitstate_timer_8_221q & altpcie_rs_serdes_waitstate_timer_7_222q & altpcie_rs_serdes_waitstate_timer_6_223q & altpcie_rs_serdes_waitstate_timer_5_224q & altpcie_rs_serdes_waitstate_timer_4_225q & altpcie_rs_serdes_waitstate_timer_3_226q & altpcie_rs_serdes_waitstate_timer_2_227q & altpcie_rs_serdes_waitstate_timer_1_228q & altpcie_rs_serdes_waitstate_timer_0_229q & "1");
	wire_altpcie_rs_serdes_add2_110_b <= ( "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "0" & "1");
	altpcie_rs_serdes_add2_110 :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 21,
		width_b => 21,
		width_o => 21
	  )
	  PORT MAP ( 
		a => wire_altpcie_rs_serdes_add2_110_a,
		b => wire_altpcie_rs_serdes_add2_110_b,
		cin => wire_gnd,
		o => wire_altpcie_rs_serdes_add2_110_o
	  );
	wire_altpcie_rs_serdes_add3_283_a <= ( altpcie_rs_serdes_rx_sd_idl_cnt_19_511q & altpcie_rs_serdes_rx_sd_idl_cnt_18_512q & altpcie_rs_serdes_rx_sd_idl_cnt_17_513q & altpcie_rs_serdes_rx_sd_idl_cnt_16_514q & altpcie_rs_serdes_rx_sd_idl_cnt_15_515q & altpcie_rs_serdes_rx_sd_idl_cnt_14_516q & altpcie_rs_serdes_rx_sd_idl_cnt_13_517q & altpcie_rs_serdes_rx_sd_idl_cnt_12_518q & altpcie_rs_serdes_rx_sd_idl_cnt_11_519q & altpcie_rs_serdes_rx_sd_idl_cnt_10_520q & altpcie_rs_serdes_rx_sd_idl_cnt_9_521q & altpcie_rs_serdes_rx_sd_idl_cnt_8_522q & altpcie_rs_serdes_rx_sd_idl_cnt_7_523q & altpcie_rs_serdes_rx_sd_idl_cnt_6_524q & altpcie_rs_serdes_rx_sd_idl_cnt_5_525q & altpcie_rs_serdes_rx_sd_idl_cnt_4_526q & altpcie_rs_serdes_rx_sd_idl_cnt_3_527q & altpcie_rs_serdes_rx_sd_idl_cnt_2_528q & altpcie_rs_serdes_rx_sd_idl_cnt_1_529q & "1");
	wire_altpcie_rs_serdes_add3_283_b <= ( "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "1" & "0" & "1" & "0" & "1");
	altpcie_rs_serdes_add3_283 :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 20,
		width_b => 20,
		width_o => 20
	  )
	  PORT MAP ( 
		a => wire_altpcie_rs_serdes_add3_283_a,
		b => wire_altpcie_rs_serdes_add3_283_b,
		cin => wire_gnd,
		o => wire_altpcie_rs_serdes_add3_283_o
	  );
	wire_altpcie_rs_serdes_add4_377_a <= ( altpcie_rs_serdes_rx_sd_idl_cnt_19_511q & altpcie_rs_serdes_rx_sd_idl_cnt_18_512q & altpcie_rs_serdes_rx_sd_idl_cnt_17_513q & altpcie_rs_serdes_rx_sd_idl_cnt_16_514q & altpcie_rs_serdes_rx_sd_idl_cnt_15_515q & altpcie_rs_serdes_rx_sd_idl_cnt_14_516q & altpcie_rs_serdes_rx_sd_idl_cnt_13_517q & altpcie_rs_serdes_rx_sd_idl_cnt_12_518q & altpcie_rs_serdes_rx_sd_idl_cnt_11_519q & altpcie_rs_serdes_rx_sd_idl_cnt_10_520q & altpcie_rs_serdes_rx_sd_idl_cnt_9_521q & altpcie_rs_serdes_rx_sd_idl_cnt_8_522q & altpcie_rs_serdes_rx_sd_idl_cnt_7_523q & altpcie_rs_serdes_rx_sd_idl_cnt_6_524q & altpcie_rs_serdes_rx_sd_idl_cnt_5_525q & altpcie_rs_serdes_rx_sd_idl_cnt_4_526q & altpcie_rs_serdes_rx_sd_idl_cnt_3_527q & altpcie_rs_serdes_rx_sd_idl_cnt_2_528q & altpcie_rs_serdes_rx_sd_idl_cnt_1_529q & altpcie_rs_serdes_rx_sd_idl_cnt_0_530q);
	wire_altpcie_rs_serdes_add4_377_b <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "1");
	altpcie_rs_serdes_add4_377 :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 20,
		width_b => 20,
		width_o => 20
	  )
	  PORT MAP ( 
		a => wire_altpcie_rs_serdes_add4_377_a,
		b => wire_altpcie_rs_serdes_add4_377_b,
		cin => wire_gnd,
		o => wire_altpcie_rs_serdes_add4_377_o
	  );
	wire_altpcie_rs_serdes_lessthan0_87_a <= ( altpcie_rs_serdes_pll_locked_cnt_6_251q & altpcie_rs_serdes_pll_locked_cnt_5_252q & altpcie_rs_serdes_pll_locked_cnt_4_253q & altpcie_rs_serdes_pll_locked_cnt_3_254q & altpcie_rs_serdes_pll_locked_cnt_2_255q & altpcie_rs_serdes_pll_locked_cnt_1_256q & altpcie_rs_serdes_pll_locked_cnt_0_257q);
	wire_altpcie_rs_serdes_lessthan0_87_b <= ( "1" & "1" & "1" & "1" & "1" & "1" & "1");
	altpcie_rs_serdes_lessthan0_87 :  oper_less_than
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 7,
		width_b => 7
	  )
	  PORT MAP ( 
		a => wire_altpcie_rs_serdes_lessthan0_87_a,
		b => wire_altpcie_rs_serdes_lessthan0_87_b,
		cin => wire_gnd,
		o => wire_altpcie_rs_serdes_lessthan0_87_o
	  );
	wire_altpcie_rs_serdes_lessthan1_282_a <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "1" & "0" & "1" & "0");
	wire_altpcie_rs_serdes_lessthan1_282_b <= ( altpcie_rs_serdes_rx_sd_idl_cnt_19_511q & altpcie_rs_serdes_rx_sd_idl_cnt_18_512q & altpcie_rs_serdes_rx_sd_idl_cnt_17_513q & altpcie_rs_serdes_rx_sd_idl_cnt_16_514q & altpcie_rs_serdes_rx_sd_idl_cnt_15_515q & altpcie_rs_serdes_rx_sd_idl_cnt_14_516q & altpcie_rs_serdes_rx_sd_idl_cnt_13_517q & altpcie_rs_serdes_rx_sd_idl_cnt_12_518q & altpcie_rs_serdes_rx_sd_idl_cnt_11_519q & altpcie_rs_serdes_rx_sd_idl_cnt_10_520q & altpcie_rs_serdes_rx_sd_idl_cnt_9_521q & altpcie_rs_serdes_rx_sd_idl_cnt_8_522q & altpcie_rs_serdes_rx_sd_idl_cnt_7_523q & altpcie_rs_serdes_rx_sd_idl_cnt_6_524q & altpcie_rs_serdes_rx_sd_idl_cnt_5_525q & altpcie_rs_serdes_rx_sd_idl_cnt_4_526q & altpcie_rs_serdes_rx_sd_idl_cnt_3_527q & altpcie_rs_serdes_rx_sd_idl_cnt_2_528q & altpcie_rs_serdes_rx_sd_idl_cnt_1_529q & altpcie_rs_serdes_rx_sd_idl_cnt_0_530q);
	altpcie_rs_serdes_lessthan1_282 :  oper_less_than
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 20,
		width_b => 20
	  )
	  PORT MAP ( 
		a => wire_altpcie_rs_serdes_lessthan1_282_a,
		b => wire_altpcie_rs_serdes_lessthan1_282_b,
		cin => wire_gnd,
		o => wire_altpcie_rs_serdes_lessthan1_282_o
	  );
	wire_altpcie_rs_serdes_lessthan2_304_a <= ( altpcie_rs_serdes_rx_sd_idl_cnt_19_511q & altpcie_rs_serdes_rx_sd_idl_cnt_18_512q & altpcie_rs_serdes_rx_sd_idl_cnt_17_513q & altpcie_rs_serdes_rx_sd_idl_cnt_16_514q & altpcie_rs_serdes_rx_sd_idl_cnt_15_515q & altpcie_rs_serdes_rx_sd_idl_cnt_14_516q & altpcie_rs_serdes_rx_sd_idl_cnt_13_517q & altpcie_rs_serdes_rx_sd_idl_cnt_12_518q & altpcie_rs_serdes_rx_sd_idl_cnt_11_519q & altpcie_rs_serdes_rx_sd_idl_cnt_10_520q & altpcie_rs_serdes_rx_sd_idl_cnt_9_521q & altpcie_rs_serdes_rx_sd_idl_cnt_8_522q & altpcie_rs_serdes_rx_sd_idl_cnt_7_523q & altpcie_rs_serdes_rx_sd_idl_cnt_6_524q & altpcie_rs_serdes_rx_sd_idl_cnt_5_525q & altpcie_rs_serdes_rx_sd_idl_cnt_4_526q & altpcie_rs_serdes_rx_sd_idl_cnt_3_527q & altpcie_rs_serdes_rx_sd_idl_cnt_2_528q & altpcie_rs_serdes_rx_sd_idl_cnt_1_529q & altpcie_rs_serdes_rx_sd_idl_cnt_0_530q);
	wire_altpcie_rs_serdes_lessthan2_304_b <= ( "1" & "0" & "1" & "1" & "0" & "1" & "1" & "1" & "0" & "0" & "0" & "1" & "1" & "0" & "1" & "1" & "0" & "0" & "0" & "0");
	altpcie_rs_serdes_lessthan2_304 :  oper_less_than
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 20,
		width_b => 20
	  )
	  PORT MAP ( 
		a => wire_altpcie_rs_serdes_lessthan2_304_a,
		b => wire_altpcie_rs_serdes_lessthan2_304_b,
		cin => wire_gnd,
		o => wire_altpcie_rs_serdes_lessthan2_304_o
	  );
	wire_altpcie_rs_serdes_lessthan3_369_a <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "1" & "0" & "0" & "0" & "0" & "0");
	wire_altpcie_rs_serdes_lessthan3_369_b <= ( altpcie_rs_serdes_rx_sd_idl_cnt_19_511q & altpcie_rs_serdes_rx_sd_idl_cnt_18_512q & altpcie_rs_serdes_rx_sd_idl_cnt_17_513q & altpcie_rs_serdes_rx_sd_idl_cnt_16_514q & altpcie_rs_serdes_rx_sd_idl_cnt_15_515q & altpcie_rs_serdes_rx_sd_idl_cnt_14_516q & altpcie_rs_serdes_rx_sd_idl_cnt_13_517q & altpcie_rs_serdes_rx_sd_idl_cnt_12_518q & altpcie_rs_serdes_rx_sd_idl_cnt_11_519q & altpcie_rs_serdes_rx_sd_idl_cnt_10_520q & altpcie_rs_serdes_rx_sd_idl_cnt_9_521q & altpcie_rs_serdes_rx_sd_idl_cnt_8_522q & altpcie_rs_serdes_rx_sd_idl_cnt_7_523q & altpcie_rs_serdes_rx_sd_idl_cnt_6_524q & altpcie_rs_serdes_rx_sd_idl_cnt_5_525q & altpcie_rs_serdes_rx_sd_idl_cnt_4_526q & altpcie_rs_serdes_rx_sd_idl_cnt_3_527q & altpcie_rs_serdes_rx_sd_idl_cnt_2_528q & altpcie_rs_serdes_rx_sd_idl_cnt_1_529q & altpcie_rs_serdes_rx_sd_idl_cnt_0_530q);
	altpcie_rs_serdes_lessthan3_369 :  oper_less_than
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 20,
		width_b => 20
	  )
	  PORT MAP ( 
		a => wire_altpcie_rs_serdes_lessthan3_369_a,
		b => wire_altpcie_rs_serdes_lessthan3_369_b,
		cin => wire_vcc,
		o => wire_altpcie_rs_serdes_lessthan3_369_o
	  );
	wire_altpcie_rs_serdes_mux0_488_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_465m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_442m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_346m_dataout);
	wire_altpcie_rs_serdes_mux0_488_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux0_488 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux0_488_data,
		o => wire_altpcie_rs_serdes_mux0_488_o,
		sel => wire_altpcie_rs_serdes_mux0_488_sel
	  );
	wire_altpcie_rs_serdes_mux10_498_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_475m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_452m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_356m_dataout);
	wire_altpcie_rs_serdes_mux10_498_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux10_498 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux10_498_data,
		o => wire_altpcie_rs_serdes_mux10_498_o,
		sel => wire_altpcie_rs_serdes_mux10_498_sel
	  );
	wire_altpcie_rs_serdes_mux11_499_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_476m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_453m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_357m_dataout);
	wire_altpcie_rs_serdes_mux11_499_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux11_499 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux11_499_data,
		o => wire_altpcie_rs_serdes_mux11_499_o,
		sel => wire_altpcie_rs_serdes_mux11_499_sel
	  );
	wire_altpcie_rs_serdes_mux12_500_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_477m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_454m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_358m_dataout);
	wire_altpcie_rs_serdes_mux12_500_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux12_500 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux12_500_data,
		o => wire_altpcie_rs_serdes_mux12_500_o,
		sel => wire_altpcie_rs_serdes_mux12_500_sel
	  );
	wire_altpcie_rs_serdes_mux13_501_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_478m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_455m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_359m_dataout);
	wire_altpcie_rs_serdes_mux13_501_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux13_501 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux13_501_data,
		o => wire_altpcie_rs_serdes_mux13_501_o,
		sel => wire_altpcie_rs_serdes_mux13_501_sel
	  );
	wire_altpcie_rs_serdes_mux14_502_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_479m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_456m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_360m_dataout);
	wire_altpcie_rs_serdes_mux14_502_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux14_502 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux14_502_data,
		o => wire_altpcie_rs_serdes_mux14_502_o,
		sel => wire_altpcie_rs_serdes_mux14_502_sel
	  );
	wire_altpcie_rs_serdes_mux15_503_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_480m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_457m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_361m_dataout);
	wire_altpcie_rs_serdes_mux15_503_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux15_503 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux15_503_data,
		o => wire_altpcie_rs_serdes_mux15_503_o,
		sel => wire_altpcie_rs_serdes_mux15_503_sel
	  );
	wire_altpcie_rs_serdes_mux16_504_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_481m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_458m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_362m_dataout);
	wire_altpcie_rs_serdes_mux16_504_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux16_504 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux16_504_data,
		o => wire_altpcie_rs_serdes_mux16_504_o,
		sel => wire_altpcie_rs_serdes_mux16_504_sel
	  );
	wire_altpcie_rs_serdes_mux17_505_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_482m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_459m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_363m_dataout);
	wire_altpcie_rs_serdes_mux17_505_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux17_505 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux17_505_data,
		o => wire_altpcie_rs_serdes_mux17_505_o,
		sel => wire_altpcie_rs_serdes_mux17_505_sel
	  );
	wire_altpcie_rs_serdes_mux18_506_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_483m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_460m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_364m_dataout);
	wire_altpcie_rs_serdes_mux18_506_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux18_506 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux18_506_data,
		o => wire_altpcie_rs_serdes_mux18_506_o,
		sel => wire_altpcie_rs_serdes_mux18_506_sel
	  );
	wire_altpcie_rs_serdes_mux19_507_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_484m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_461m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_365m_dataout);
	wire_altpcie_rs_serdes_mux19_507_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux19_507 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux19_507_data,
		o => wire_altpcie_rs_serdes_mux19_507_o,
		sel => wire_altpcie_rs_serdes_mux19_507_sel
	  );
	wire_altpcie_rs_serdes_mux1_489_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_466m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_443m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_347m_dataout);
	wire_altpcie_rs_serdes_mux1_489_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux1_489 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux1_489_data,
		o => wire_altpcie_rs_serdes_mux1_489_o,
		sel => wire_altpcie_rs_serdes_mux1_489_sel
	  );
	wire_altpcie_rs_serdes_mux20_508_data <= ( "0" & wire_altpcie_rs_serdes_sd_state_485m_dataout & wire_altpcie_rs_serdes_sd_state_462m_dataout & wire_altpcie_rs_serdes_sd_state_366m_dataout);
	wire_altpcie_rs_serdes_mux20_508_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux20_508 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux20_508_data,
		o => wire_altpcie_rs_serdes_mux20_508_o,
		sel => wire_altpcie_rs_serdes_mux20_508_sel
	  );
	wire_altpcie_rs_serdes_mux21_509_data <= ( "0" & wire_altpcie_rs_serdes_sd_state_486m_dataout & wire_altpcie_rs_serdes_sd_state_463m_dataout & wire_altpcie_rs_serdes_sd_state_367m_dataout);
	wire_altpcie_rs_serdes_mux21_509_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux21_509 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux21_509_data,
		o => wire_altpcie_rs_serdes_mux21_509_o,
		sel => wire_altpcie_rs_serdes_mux21_509_sel
	  );
	wire_altpcie_rs_serdes_mux2_490_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_467m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_444m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_348m_dataout);
	wire_altpcie_rs_serdes_mux2_490_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux2_490 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux2_490_data,
		o => wire_altpcie_rs_serdes_mux2_490_o,
		sel => wire_altpcie_rs_serdes_mux2_490_sel
	  );
	wire_altpcie_rs_serdes_mux3_491_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_468m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_445m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_349m_dataout);
	wire_altpcie_rs_serdes_mux3_491_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux3_491 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux3_491_data,
		o => wire_altpcie_rs_serdes_mux3_491_o,
		sel => wire_altpcie_rs_serdes_mux3_491_sel
	  );
	wire_altpcie_rs_serdes_mux4_492_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_469m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_446m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_350m_dataout);
	wire_altpcie_rs_serdes_mux4_492_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux4_492 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux4_492_data,
		o => wire_altpcie_rs_serdes_mux4_492_o,
		sel => wire_altpcie_rs_serdes_mux4_492_sel
	  );
	wire_altpcie_rs_serdes_mux5_493_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_470m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_447m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_351m_dataout);
	wire_altpcie_rs_serdes_mux5_493_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux5_493 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux5_493_data,
		o => wire_altpcie_rs_serdes_mux5_493_o,
		sel => wire_altpcie_rs_serdes_mux5_493_sel
	  );
	wire_altpcie_rs_serdes_mux6_494_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_471m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_448m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_352m_dataout);
	wire_altpcie_rs_serdes_mux6_494_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux6_494 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux6_494_data,
		o => wire_altpcie_rs_serdes_mux6_494_o,
		sel => wire_altpcie_rs_serdes_mux6_494_sel
	  );
	wire_altpcie_rs_serdes_mux7_495_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_472m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_449m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_353m_dataout);
	wire_altpcie_rs_serdes_mux7_495_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux7_495 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux7_495_data,
		o => wire_altpcie_rs_serdes_mux7_495_o,
		sel => wire_altpcie_rs_serdes_mux7_495_sel
	  );
	wire_altpcie_rs_serdes_mux8_496_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_473m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_450m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_354m_dataout);
	wire_altpcie_rs_serdes_mux8_496_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux8_496 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux8_496_data,
		o => wire_altpcie_rs_serdes_mux8_496_o,
		sel => wire_altpcie_rs_serdes_mux8_496_sel
	  );
	wire_altpcie_rs_serdes_mux9_497_data <= ( "0" & wire_altpcie_rs_serdes_rx_sd_idl_cnt_474m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_451m_dataout & wire_altpcie_rs_serdes_rx_sd_idl_cnt_355m_dataout);
	wire_altpcie_rs_serdes_mux9_497_sel <= ( altpcie_rs_serdes_sd_state_1_531q & altpcie_rs_serdes_sd_state_0_206q);
	altpcie_rs_serdes_mux9_497 :  oper_mux
	  GENERIC MAP (
		width_data => 4,
		width_sel => 2
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_mux9_497_data,
		o => wire_altpcie_rs_serdes_mux9_497_o,
		sel => wire_altpcie_rs_serdes_mux9_497_sel
	  );
	wire_altpcie_rs_serdes_selector0_193_data <= ( "0" & wire_altpcie_rs_serdes_ld_ws_tmr_183m_dataout & altpcie_rs_serdes_ld_ws_tmr_235q);
	wire_altpcie_rs_serdes_selector0_193_sel <= ( altpcie_rs_serdes_serdes_rst_state_strobe_txpll_locked_sd_cnt_230q & altpcie_rs_serdes_serdes_rst_state_idle_st_cnt_231q & s_wire_altpcie_rs_serdes_txdigitalreset_r_199_dataout);
	altpcie_rs_serdes_selector0_193 :  oper_selector
	  GENERIC MAP (
		width_data => 3,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_selector0_193_data,
		o => wire_altpcie_rs_serdes_selector0_193_o,
		sel => wire_altpcie_rs_serdes_selector0_193_sel
	  );
	wire_altpcie_rs_serdes_selector1_194_data <= ( wire_altpcie_rs_serdes_rxanalogreset_r_179m_dataout & wire_nl_w226w & "0");
	wire_altpcie_rs_serdes_selector1_194_sel <= ( altpcie_rs_serdes_serdes_rst_state_strobe_txpll_locked_sd_cnt_230q & altpcie_rs_serdes_serdes_rst_state_idle_st_cnt_231q & s_wire_altpcie_rs_serdes_txdigitalreset_r_199_dataout);
	altpcie_rs_serdes_selector1_194 :  oper_selector
	  GENERIC MAP (
		width_data => 3,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_selector1_194_data,
		o => wire_altpcie_rs_serdes_selector1_194_o,
		sel => wire_altpcie_rs_serdes_selector1_194_sel
	  );
	wire_altpcie_rs_serdes_selector2_195_data <= ( "0" & wire_altpcie_rs_serdes_serdes_rst_state_181m_dataout & wire_altpcie_rs_serdes_serdes_rst_state_189m_dataout);
	wire_altpcie_rs_serdes_selector2_195_sel <= ( s_wire_altpcie_rs_serdes_rxdigitalreset_r_202_dataout & altpcie_rs_serdes_serdes_rst_state_idle_st_cnt_231q & altpcie_rs_serdes_serdes_rst_state_wait_state_st_cnt_233q);
	altpcie_rs_serdes_selector2_195 :  oper_selector
	  GENERIC MAP (
		width_data => 3,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_selector2_195_data,
		o => wire_altpcie_rs_serdes_selector2_195_o,
		sel => wire_altpcie_rs_serdes_selector2_195_sel
	  );
	wire_altpcie_rs_serdes_selector3_196_data <= ( wire_altpcie_rs_serdes_serdes_rst_state_177m_dataout & wire_altpcie_rs_serdes_serdes_rst_state_182m_dataout & wire_nl_w226w & wire_nl_w226w);
	wire_altpcie_rs_serdes_selector3_196_sel <= ( altpcie_rs_serdes_serdes_rst_state_strobe_txpll_locked_sd_cnt_230q & altpcie_rs_serdes_serdes_rst_state_idle_st_cnt_231q & altpcie_rs_serdes_serdes_rst_state_stable_tx_pll_st_cnt_232q & altpcie_rs_serdes_serdes_rst_state_wait_state_st_cnt_233q);
	altpcie_rs_serdes_selector3_196 :  oper_selector
	  GENERIC MAP (
		width_data => 4,
		width_sel => 4
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_selector3_196_data,
		o => wire_altpcie_rs_serdes_selector3_196_o,
		sel => wire_altpcie_rs_serdes_selector3_196_sel
	  );
	wire_altpcie_rs_serdes_selector4_198_data <= ( "0" & altpcie_rs_serdes_rx_pll_freq_locked_sync_r_240q & wire_altpcie_rs_serdes_serdes_rst_state_191m_dataout);
	wire_altpcie_rs_serdes_selector4_198_sel <= ( s_wire_altpcie_rs_serdes_serdes_rst_state_197_dataout & altpcie_rs_serdes_serdes_rst_state_stable_tx_pll_st_cnt_232q & altpcie_rs_serdes_serdes_rst_state_wait_state_st_cnt_233q);
	altpcie_rs_serdes_selector4_198 :  oper_selector
	  GENERIC MAP (
		width_data => 3,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_selector4_198_data,
		o => wire_altpcie_rs_serdes_selector4_198_o,
		sel => wire_altpcie_rs_serdes_selector4_198_sel
	  );
	wire_altpcie_rs_serdes_selector5_200_data <= ( wire_w267w & altpcie_rs_serdes_txdigitalreset_r_207q & "0");
	wire_altpcie_rs_serdes_selector5_200_sel <= ( altpcie_rs_serdes_serdes_rst_state_strobe_txpll_locked_sd_cnt_230q & altpcie_rs_serdes_serdes_rst_state_idle_st_cnt_231q & s_wire_altpcie_rs_serdes_txdigitalreset_r_199_dataout);
	altpcie_rs_serdes_selector5_200 :  oper_selector
	  GENERIC MAP (
		width_data => 3,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_selector5_200_data,
		o => wire_altpcie_rs_serdes_selector5_200_o,
		sel => wire_altpcie_rs_serdes_selector5_200_sel
	  );
	wire_altpcie_rs_serdes_selector6_201_data <= ( wire_altpcie_rs_serdes_rxanalogreset_r_179m_dataout & altpcie_rs_serdes_rxanalogreset_r_208q & "0");
	wire_altpcie_rs_serdes_selector6_201_sel <= ( altpcie_rs_serdes_serdes_rst_state_strobe_txpll_locked_sd_cnt_230q & altpcie_rs_serdes_serdes_rst_state_idle_st_cnt_231q & s_wire_altpcie_rs_serdes_txdigitalreset_r_199_dataout);
	altpcie_rs_serdes_selector6_201 :  oper_selector
	  GENERIC MAP (
		width_data => 3,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_selector6_201_data,
		o => wire_altpcie_rs_serdes_selector6_201_o,
		sel => wire_altpcie_rs_serdes_selector6_201_sel
	  );
	wire_altpcie_rs_serdes_selector7_203_data <= ( "1" & altpcie_rs_serdes_rxdigitalreset_r_209q & wire_altpcie_rs_serdes_rxdigitalreset_r_192m_dataout);
	wire_altpcie_rs_serdes_selector7_203_sel <= ( s_wire_altpcie_rs_serdes_rxdigitalreset_r_202_dataout & altpcie_rs_serdes_serdes_rst_state_idle_st_cnt_231q & altpcie_rs_serdes_serdes_rst_state_wait_state_st_cnt_233q);
	altpcie_rs_serdes_selector7_203 :  oper_selector
	  GENERIC MAP (
		width_data => 3,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_selector7_203_data,
		o => wire_altpcie_rs_serdes_selector7_203_o,
		sel => wire_altpcie_rs_serdes_selector7_203_sel
	  );
	wire_altpcie_rs_serdes_selector8_204_data <= ( altpcie_rs_serdes_ld_ws_tmr_short_236q & wire_altpcie_rs_serdes_ld_ws_tmr_short_184m_dataout & wire_altpcie_rs_serdes_ld_ws_tmr_short_188m_dataout);
	wire_altpcie_rs_serdes_selector8_204_sel <= ( s_wire_altpcie_rs_serdes_serdes_rst_state_197_dataout & altpcie_rs_serdes_serdes_rst_state_stable_tx_pll_st_cnt_232q & altpcie_rs_serdes_serdes_rst_state_wait_state_st_cnt_233q);
	altpcie_rs_serdes_selector8_204 :  oper_selector
	  GENERIC MAP (
		width_data => 3,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_altpcie_rs_serdes_selector8_204_data,
		o => wire_altpcie_rs_serdes_selector8_204_o,
		sel => wire_altpcie_rs_serdes_selector8_204_sel
	  );

 END RTL; --altpcie_rs_serdes
--synopsys translate_on
--VALID FILE
