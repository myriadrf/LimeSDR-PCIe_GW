--IP Functional Simulation Model
--VERSION_BEGIN 9.0SP1 cbx_mgl 2009:02:26:16:06:21:SJ cbx_simgen 2008:08:06:16:30:59:SJ  VERSION_END


-- Legal Notice: (c) 2003 Altera Corporation. All rights reserved.
-- You may only use these  simulation  model  output files for simulation
-- purposes and expressly not for synthesis or any other purposes (in which
-- event  Altera disclaims all warranties of any kind). Your use of  Altera
-- Corporation's design tools, logic functions and other software and tools,
-- and its AMPP partner logic functions, and any output files any of the
-- foregoing (including device programming or simulation files), and any
-- associated documentation or information  are expressly subject to the
-- terms and conditions of the  Altera Program License Subscription Agreement
-- or other applicable license agreement, including, without limitation, that
-- your use is for the sole purpose of programming logic devices manufactured
-- by Altera and sold by Altera or its authorized distributors.  Please refer
-- to the applicable agreement for further details.


--synopsys translate_off

 LIBRARY sgate;
 USE sgate.sgate_pack.all;

--synthesis_resources = lut 55 mux21 98 oper_add 3 oper_decoder 1 oper_less_than 1 oper_mux 10 oper_selector 14 
 LIBRARY ieee;
 USE ieee.std_logic_1164.all;

 ENTITY  altpcie_pclk_align IS 
	 PORT 
	 ( 
		 AlignLock	:	OUT  STD_LOGIC;
		 clock	:	IN  STD_LOGIC;
		 offset	:	IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
		 onestep	:	IN  STD_LOGIC;
		 onestep_dir	:	IN  STD_LOGIC;
		 pcie_sw_in	:	IN  STD_LOGIC;
		 pcie_sw_out	:	OUT  STD_LOGIC;
		 PCLK_Master	:	IN  STD_LOGIC;
		 PCLK_Slave	:	IN  STD_LOGIC;
		 PhaseDone	:	IN  STD_LOGIC;
		 PhaseStep	:	OUT  STD_LOGIC;
		 PhaseUpDown	:	OUT  STD_LOGIC;
		 rst	:	IN  STD_LOGIC
	 ); 
 END altpcie_pclk_align;

 ARCHITECTURE RTL OF altpcie_pclk_align IS

	 ATTRIBUTE synthesis_clearbox : natural;
	 ATTRIBUTE synthesis_clearbox OF RTL : ARCHITECTURE IS 1;
	 SIGNAL	ni0lO	:	STD_LOGIC := '0';
	 SIGNAL	niill	:	STD_LOGIC := '0';
	 SIGNAL	niilO	:	STD_LOGIC := '0';
	 SIGNAL	niiOl	:	STD_LOGIC := '0';
	 SIGNAL	nilO	:	STD_LOGIC := '0';
	 SIGNAL  wire_nill_w_lg_nilO133w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	ni0Oi	:	STD_LOGIC := '0';
	 SIGNAL	ni0Ol	:	STD_LOGIC := '0';
	 SIGNAL	ni0OO	:	STD_LOGIC := '0';
	 SIGNAL	nii0i	:	STD_LOGIC := '0';
	 SIGNAL	nii0l	:	STD_LOGIC := '0';
	 SIGNAL	nii0O	:	STD_LOGIC := '0';
	 SIGNAL	nii1i	:	STD_LOGIC := '0';
	 SIGNAL	nii1l	:	STD_LOGIC := '0';
	 SIGNAL	nii1O	:	STD_LOGIC := '0';
	 SIGNAL	niiii	:	STD_LOGIC := '0';
	 SIGNAL	niiil	:	STD_LOGIC := '0';
	 SIGNAL	niiiO	:	STD_LOGIC := '0';
	 SIGNAL	niili	:	STD_LOGIC := '0';
	 SIGNAL	niiOO	:	STD_LOGIC := '0';
	 SIGNAL	nil0i	:	STD_LOGIC := '0';
	 SIGNAL	nil0l	:	STD_LOGIC := '0';
	 SIGNAL	nil0O	:	STD_LOGIC := '0';
	 SIGNAL	nil1i	:	STD_LOGIC := '0';
	 SIGNAL	nil1l	:	STD_LOGIC := '0';
	 SIGNAL	nil1O	:	STD_LOGIC := '0';
	 SIGNAL	nilii	:	STD_LOGIC := '0';
	 SIGNAL	nilil	:	STD_LOGIC := '0';
	 SIGNAL	niliO	:	STD_LOGIC := '0';
	 SIGNAL	nilll	:	STD_LOGIC := '0';
	 SIGNAL  wire_nilli_w_lg_nil1i563w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nilli_w_lg_w_lg_w_lg_niliO496w497w498w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nilli_w_lg_w_lg_nil0O334w335w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nilli_w_lg_w_lg_niliO496w497w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nilli_w_lg_w_lg_niliO496w551w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nilli_w_lg_nil0O334w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nilli_w_lg_nilii493w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nilli_w_lg_niliO496w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	nilOi	:	STD_LOGIC := '0';
	 SIGNAL  wire_nillO_w_lg_w_lg_w_lg_nilOi509w555w556w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nillO_w_lg_w_lg_nilOi509w555w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nillO_w_lg_nilOi509w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	niOl	:	STD_LOGIC := '0';
	 SIGNAL  wire_niOi_w_lg_niOl134w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	n1i	:	STD_LOGIC := '0';
	 SIGNAL	ni0iO	:	STD_LOGIC := '0';
	 SIGNAL	ni0li	:	STD_LOGIC := '0';
	 SIGNAL	niii	:	STD_LOGIC := '0';
	 SIGNAL	niil	:	STD_LOGIC := '0';
	 SIGNAL	niiO	:	STD_LOGIC := '0';
	 SIGNAL	nili	:	STD_LOGIC := '0';
	 SIGNAL	nilOl	:	STD_LOGIC := '0';
	 SIGNAL	nilOO	:	STD_LOGIC := '0';
	 SIGNAL	niOO	:	STD_LOGIC := '0';
	 SIGNAL	nl0i	:	STD_LOGIC := '0';
	 SIGNAL	nl0l	:	STD_LOGIC := '0';
	 SIGNAL	nl0O	:	STD_LOGIC := '0';
	 SIGNAL	nl1i	:	STD_LOGIC := '0';
	 SIGNAL	nl1l	:	STD_LOGIC := '0';
	 SIGNAL	nl1O	:	STD_LOGIC := '0';
	 SIGNAL	nlii	:	STD_LOGIC := '0';
	 SIGNAL	nlil	:	STD_LOGIC := '0';
	 SIGNAL	nliO	:	STD_LOGIC := '0';
	 SIGNAL	nlli	:	STD_LOGIC := '0';
	 SIGNAL	nlll	:	STD_LOGIC := '0';
	 SIGNAL	nllO	:	STD_LOGIC := '0';
	 SIGNAL	nlOi	:	STD_LOGIC := '0';
	 SIGNAL	nlOl	:	STD_LOGIC := '0';
	 SIGNAL  wire_nlOO_w_lg_nili566w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nlOO_w_lg_niii569w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nlOO_w_lg_niil567w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nlOO_w_lg_niiO565w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nlOO_w_lg_nilOO571w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL	wire_n00i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n00O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n01O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0ii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0il_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0iO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0li_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0ll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0lO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0Oi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0Ol_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n0OO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n10i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n10l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n10O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n11i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n11l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n11O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1ii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1il_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1iO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1li_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1ll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1lO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1Oi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1Ol_dataout	:	STD_LOGIC;
	 SIGNAL	wire_n1OO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_ni1i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_ni1l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nil_dataout	:	STD_LOGIC;
	 SIGNAL	wire_niO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl00i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl00l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl00O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl01i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl01l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl01O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl0ii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl0il_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl0iO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl0li_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl0ll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl0lO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl0Oi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl0Ol_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl0OO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl1il_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl1iO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl1li_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl1ll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl1lO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl1Oi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl1Ol_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nl1OO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nli_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nli0i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nli0l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nli0O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nli1i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nli1l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nli1O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nliii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nliil_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nliiO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nlili_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nlill_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nlilO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nliOi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nliOl_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nliOO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nll1i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nllil_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nlliO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nllOO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nlO0i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nlO0l_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nlO0O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nlO1i_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nlO1O_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nlOii_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nlOil_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nlOiO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nlOli_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nlOll_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nlOlO_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nlOOi_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nlOOl_dataout	:	STD_LOGIC;
	 SIGNAL	wire_nlOOO_dataout	:	STD_LOGIC;
	 SIGNAL  wire_ni0l_a	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_ni0l_b	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_gnd	:	STD_LOGIC;
	 SIGNAL  wire_ni0l_o	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_ni1O_a	:	STD_LOGIC_VECTOR (8 DOWNTO 0);
	 SIGNAL  wire_ni1O_b	:	STD_LOGIC_VECTOR (8 DOWNTO 0);
	 SIGNAL  wire_ni1O_o	:	STD_LOGIC_VECTOR (8 DOWNTO 0);
	 SIGNAL  wire_nlO_a	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_nlO_b	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_nlO_o	:	STD_LOGIC_VECTOR (4 DOWNTO 0);
	 SIGNAL  wire_nllli_i	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_nllli_o	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_nlO1l_w_lg_o238w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_nlO1l_a	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_nlO1l_b	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_nlO1l_o	:	STD_LOGIC;
	 SIGNAL  wire_nll0i_data	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_nll0i_o	:	STD_LOGIC;
	 SIGNAL  wire_nll0i_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_nll0l_data	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_nll0l_o	:	STD_LOGIC;
	 SIGNAL  wire_nll0l_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_nll0O_data	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_nll0O_o	:	STD_LOGIC;
	 SIGNAL  wire_nll0O_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_nll1l_data	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_nll1l_o	:	STD_LOGIC;
	 SIGNAL  wire_nll1l_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_nll1O_data	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_nll1O_o	:	STD_LOGIC;
	 SIGNAL  wire_nll1O_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_nllii_data	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_nllii_o	:	STD_LOGIC;
	 SIGNAL  wire_nllii_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_nllll_data	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_nllll_o	:	STD_LOGIC;
	 SIGNAL  wire_nllll_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_nlllO_data	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_nlllO_o	:	STD_LOGIC;
	 SIGNAL  wire_nlllO_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_nllOi_data	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_nllOi_o	:	STD_LOGIC;
	 SIGNAL  wire_nllOi_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_nllOl_data	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_nllOl_o	:	STD_LOGIC;
	 SIGNAL  wire_nllOl_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_niO0i_data	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_niO0i_o	:	STD_LOGIC;
	 SIGNAL  wire_niO0i_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_niO0O_data	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_niO0O_o	:	STD_LOGIC;
	 SIGNAL  wire_niO0O_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_niO1i_data	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_niO1i_o	:	STD_LOGIC;
	 SIGNAL  wire_niO1i_sel	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
	 SIGNAL  wire_niOil_data	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_niOil_o	:	STD_LOGIC;
	 SIGNAL  wire_niOil_sel	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_niOli_data	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_niOli_o	:	STD_LOGIC;
	 SIGNAL  wire_niOli_sel	:	STD_LOGIC_VECTOR (3 DOWNTO 0);
	 SIGNAL  wire_niOOi_data	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_niOOi_o	:	STD_LOGIC;
	 SIGNAL  wire_niOOi_sel	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_niOOl_data	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_niOOl_o	:	STD_LOGIC;
	 SIGNAL  wire_niOOl_sel	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_niOOO_data	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_niOOO_o	:	STD_LOGIC;
	 SIGNAL  wire_niOOO_sel	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_nl10i_data	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_nl10i_o	:	STD_LOGIC;
	 SIGNAL  wire_nl10i_sel	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_nl10l_data	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_nl10l_o	:	STD_LOGIC;
	 SIGNAL  wire_nl10l_sel	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
	 SIGNAL  wire_nl10O_data	:	STD_LOGIC_VECTOR (5 DOWNTO 0);
	 SIGNAL  wire_nl10O_o	:	STD_LOGIC;
	 SIGNAL  wire_nl10O_sel	:	STD_LOGIC_VECTOR (5 DOWNTO 0);
	 SIGNAL  wire_nl11i_data	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_nl11i_o	:	STD_LOGIC;
	 SIGNAL  wire_nl11i_sel	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_nl11l_data	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_nl11l_o	:	STD_LOGIC;
	 SIGNAL  wire_nl11l_sel	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_nl11O_data	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_nl11O_o	:	STD_LOGIC;
	 SIGNAL  wire_nl11O_sel	:	STD_LOGIC_VECTOR (6 DOWNTO 0);
	 SIGNAL  wire_w_lg_n0OOi51w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_PhaseDone333w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  wire_w_lg_rst50w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  n0O0i :	STD_LOGIC;
	 SIGNAL  n0O0l :	STD_LOGIC;
	 SIGNAL  n0O0O :	STD_LOGIC;
	 SIGNAL  n0O1O :	STD_LOGIC;
	 SIGNAL  n0Oii :	STD_LOGIC;
	 SIGNAL  n0Oil :	STD_LOGIC;
	 SIGNAL  n0OiO :	STD_LOGIC;
	 SIGNAL  n0Oli :	STD_LOGIC;
	 SIGNAL  n0Oll :	STD_LOGIC;
	 SIGNAL  n0OlO :	STD_LOGIC;
	 SIGNAL  n0OOi :	STD_LOGIC;
 BEGIN

	wire_gnd <= '0';
	wire_w_lg_n0OOi51w(0) <= NOT n0OOi;
	wire_w_lg_PhaseDone333w(0) <= NOT PhaseDone;
	wire_w_lg_rst50w(0) <= NOT rst;
	AlignLock <= ni0lO;
	n0O0i <= (((((nilOi OR niliO) OR nilil) OR nil0O) OR nil0i) OR nil0l);
	n0O0l <= wire_nillO_w_lg_nilOi509w(0);
	n0O0O <= (((((((niiil AND niiii) AND nii0O) AND nii0l) AND nii0i) AND nii1O) AND nii1l) AND nii1i);
	n0O1O <= (((((nilOi OR niliO) OR nilil) OR nilii) OR nil0O) OR nil0i);
	n0Oii <= (wire_nlO1l_o AND ni0Oi);
	n0Oil <= (((wire_nlOO_w_lg_nili566w(0) AND wire_nlOO_w_lg_niil567w(0)) AND wire_nlOO_w_lg_niii569w(0)) AND wire_nlOO_w_lg_nilOO571w(0));
	n0OiO <= '1';
	n0Oli <= (n0Oll AND nil1O);
	n0Oll <= ((((nili AND niiO) AND niil) AND niii) AND nilOO);
	n0OlO <= (((((((((((((n1i AND nlOl) AND nlOi) AND nllO) AND nlll) AND nlli) AND nliO) AND nlil) AND nlii) AND nl0O) AND nl0l) AND nl0i) AND nl1O) AND nl1l);
	n0OOi <= (((((((((((((n1i OR nlOl) OR nlOi) OR nllO) OR nlll) OR nlli) OR nliO) OR nlil) OR nlii) OR nl0O) OR nl0l) OR nl0i) OR nl1O) OR nl1l);
	pcie_sw_out <= nilOl;
	PhaseStep <= niiiO;
	PhaseUpDown <= niili;
	PROCESS (clock, rst)
	BEGIN
		IF (rst = '1') THEN
				ni0lO <= '0';
		ELSIF (clock = '1' AND clock'event) THEN
			IF (nil0l = '1') THEN
				ni0lO <= n0OiO;
			END IF;
		END IF;
	END PROCESS;
	PROCESS (clock, rst)
	BEGIN
		IF (rst = '1') THEN
				niill <= '0';
				niilO <= '0';
				niiOl <= '0';
		ELSIF (clock = '1' AND clock'event) THEN
			IF (nilll = '1') THEN
				niill <= wire_nli0i_dataout;
				niilO <= wire_nl0OO_dataout;
				niiOl <= wire_nli1i_dataout;
			END IF;
		END IF;
	END PROCESS;
	PROCESS (PCLK_Master, rst)
	BEGIN
		IF (rst = '1') THEN
				nilO <= '0';
		ELSIF (PCLK_Master = '1' AND PCLK_Master'event) THEN
			IF (n0Oil = '1') THEN
				nilO <= n0OlO;
			END IF;
		END IF;
	END PROCESS;
	wire_nill_w_lg_nilO133w(0) <= NOT nilO;
	PROCESS (clock, rst)
	BEGIN
		IF (rst = '1') THEN
				ni0Oi <= '0';
				ni0Ol <= '0';
				ni0OO <= '0';
				nii0i <= '0';
				nii0l <= '0';
				nii0O <= '0';
				nii1i <= '0';
				nii1l <= '0';
				nii1O <= '0';
				niiii <= '0';
				niiil <= '0';
				niiiO <= '0';
				niili <= '0';
				niiOO <= '0';
				nil0i <= '0';
				nil0l <= '0';
				nil0O <= '0';
				nil1i <= '0';
				nil1l <= '0';
				nil1O <= '0';
				nilii <= '0';
				nilil <= '0';
				niliO <= '0';
				nilll <= '0';
		ELSIF (clock = '1' AND clock'event) THEN
				ni0Oi <= wire_niO0O_o;
				ni0Ol <= wire_niO1i_o;
				ni0OO <= wire_niOli_o;
				nii0i <= wire_n10i_dataout;
				nii0l <= wire_n10l_dataout;
				nii0O <= wire_n10O_dataout;
				nii1i <= wire_n11i_dataout;
				nii1l <= wire_n11l_dataout;
				nii1O <= wire_n11O_dataout;
				niiii <= wire_n1ii_dataout;
				niiil <= wire_n1il_dataout;
				niiiO <= wire_niOil_o;
				niili <= wire_niO0i_o;
				niiOO <= (nil1l AND wire_nilli_w_lg_nil1i563w(0));
				nil0i <= wire_niOOi_o;
				nil0l <= wire_niOOl_o;
				nil0O <= wire_niOOO_o;
				nil1i <= nil1l;
				nil1l <= nili;
				nil1O <= wire_nl10O_o;
				nilii <= wire_nl11i_o;
				nilil <= wire_nl11l_o;
				niliO <= wire_nl11O_o;
				nilll <= wire_nl10i_o;
		END IF;
	END PROCESS;
	wire_nilli_w_lg_nil1i563w(0) <= NOT nil1i;
	wire_nilli_w_lg_w_lg_w_lg_niliO496w497w498w(0) <= wire_nilli_w_lg_w_lg_niliO496w497w(0) OR nil0l;
	wire_nilli_w_lg_w_lg_nil0O334w335w(0) <= wire_nilli_w_lg_nil0O334w(0) OR nil0l;
	wire_nilli_w_lg_w_lg_niliO496w497w(0) <= wire_nilli_w_lg_niliO496w(0) OR nil0i;
	wire_nilli_w_lg_w_lg_niliO496w551w(0) <= wire_nilli_w_lg_niliO496w(0) OR nilii;
	wire_nilli_w_lg_nil0O334w(0) <= nil0O OR nil0i;
	wire_nilli_w_lg_nilii493w(0) <= nilii OR nil0O;
	wire_nilli_w_lg_niliO496w(0) <= niliO OR nilil;
	PROCESS (clock, rst)
	BEGIN
		IF (rst = '1') THEN
				nilOi <= '1';
		ELSIF (clock = '1' AND clock'event) THEN
				nilOi <= wire_nl10l_o;
		END IF;
	END PROCESS;
	wire_nillO_w_lg_w_lg_w_lg_nilOi509w555w556w(0) <= wire_nillO_w_lg_w_lg_nilOi509w555w(0) OR nil0l;
	wire_nillO_w_lg_w_lg_nilOi509w555w(0) <= wire_nillO_w_lg_nilOi509w(0) OR nil0i;
	wire_nillO_w_lg_nilOi509w(0) <= nilOi OR nil0O;
	PROCESS (PCLK_Master, rst)
	BEGIN
		IF (rst = '1') THEN
				niOl <= '1';
		ELSIF (PCLK_Master = '1' AND PCLK_Master'event) THEN
			IF (n0Oil = '1') THEN
				niOl <= wire_w_lg_n0OOi51w(0);
			END IF;
		END IF;
	END PROCESS;
	wire_niOi_w_lg_niOl134w(0) <= NOT niOl;
	PROCESS (PCLK_Master, rst)
	BEGIN
		IF (rst = '1') THEN
				n1i <= '0';
				ni0iO <= '0';
				ni0li <= '0';
				niii <= '0';
				niil <= '0';
				niiO <= '0';
				nili <= '0';
				nilOl <= '0';
				nilOO <= '0';
				niOO <= '0';
				nl0i <= '0';
				nl0l <= '0';
				nl0O <= '0';
				nl1i <= '0';
				nl1l <= '0';
				nl1O <= '0';
				nlii <= '0';
				nlil <= '0';
				nliO <= '0';
				nlli <= '0';
				nlll <= '0';
				nllO <= '0';
				nlOi <= '0';
				nlOl <= '0';
		ELSIF (PCLK_Master = '1' AND PCLK_Master'event) THEN
				n1i <= nlOl;
				ni0iO <= ni0li;
				ni0li <= pcie_sw_in;
				niii <= wire_n1O_dataout;
				niil <= wire_n0i_dataout;
				niiO <= wire_n0l_dataout;
				nili <= wire_n0O_dataout;
				nilOl <= ni0iO;
				nilOO <= wire_n1l_dataout;
				niOO <= PCLK_Slave;
				nl0i <= nl1O;
				nl0l <= nl0i;
				nl0O <= nl0l;
				nl1i <= niOO;
				nl1l <= nl1i;
				nl1O <= nl1l;
				nlii <= nl0O;
				nlil <= nlii;
				nliO <= nlil;
				nlli <= nliO;
				nlll <= nlli;
				nllO <= nlll;
				nlOi <= nllO;
				nlOl <= nlOi;
		END IF;
	END PROCESS;
	wire_nlOO_w_lg_nili566w(0) <= nili AND wire_nlOO_w_lg_niiO565w(0);
	wire_nlOO_w_lg_niii569w(0) <= NOT niii;
	wire_nlOO_w_lg_niil567w(0) <= NOT niil;
	wire_nlOO_w_lg_niiO565w(0) <= NOT niiO;
	wire_nlOO_w_lg_nilOO571w(0) <= NOT nilOO;
	wire_n00i_dataout <= wire_ni0l_o(2) WHEN ni0Ol = '1'  ELSE wire_n0lO_dataout;
	wire_n00l_dataout <= wire_ni0l_o(3) WHEN ni0Ol = '1'  ELSE wire_n0Oi_dataout;
	wire_n00O_dataout <= wire_ni0l_o(4) WHEN ni0Ol = '1'  ELSE wire_n0Ol_dataout;
	wire_n01i_dataout <= niiil WHEN n0O0O = '1'  ELSE wire_n0iO_dataout;
	wire_n01l_dataout <= wire_ni0l_o(0) WHEN ni0Ol = '1'  ELSE wire_n0li_dataout;
	wire_n01O_dataout <= wire_ni0l_o(1) WHEN ni0Ol = '1'  ELSE wire_n0ll_dataout;
	wire_n0i_dataout <= wire_niO_dataout AND NOT(n0Oli);
	wire_n0ii_dataout <= wire_ni0l_o(5) WHEN ni0Ol = '1'  ELSE wire_n0OO_dataout;
	wire_n0il_dataout <= wire_ni0l_o(6) WHEN ni0Ol = '1'  ELSE wire_ni1i_dataout;
	wire_n0iO_dataout <= wire_ni0l_o(7) WHEN ni0Ol = '1'  ELSE wire_ni1l_dataout;
	wire_n0l_dataout <= wire_nli_dataout AND NOT(n0Oli);
	wire_n0li_dataout <= wire_ni1O_o(1) WHEN n0Oii = '1'  ELSE nii1i;
	wire_n0ll_dataout <= wire_ni1O_o(2) WHEN n0Oii = '1'  ELSE nii1l;
	wire_n0lO_dataout <= wire_ni1O_o(3) WHEN n0Oii = '1'  ELSE nii1O;
	wire_n0O_dataout <= wire_nll_dataout AND NOT(n0Oli);
	wire_n0Oi_dataout <= wire_ni1O_o(4) WHEN n0Oii = '1'  ELSE nii0i;
	wire_n0Ol_dataout <= wire_ni1O_o(5) WHEN n0Oii = '1'  ELSE nii0l;
	wire_n0OO_dataout <= wire_ni1O_o(6) WHEN n0Oii = '1'  ELSE nii0O;
	wire_n10i_dataout <= offset(3) WHEN ni0OO = '1'  ELSE wire_n1lO_dataout;
	wire_n10l_dataout <= offset(4) WHEN ni0OO = '1'  ELSE wire_n1Oi_dataout;
	wire_n10O_dataout <= offset(5) WHEN ni0OO = '1'  ELSE wire_n1Ol_dataout;
	wire_n11i_dataout <= offset(0) WHEN ni0OO = '1'  ELSE wire_n1iO_dataout;
	wire_n11l_dataout <= offset(1) WHEN ni0OO = '1'  ELSE wire_n1li_dataout;
	wire_n11O_dataout <= offset(2) WHEN ni0OO = '1'  ELSE wire_n1ll_dataout;
	wire_n1ii_dataout <= offset(6) WHEN ni0OO = '1'  ELSE wire_n1OO_dataout;
	wire_n1il_dataout <= offset(7) WHEN ni0OO = '1'  ELSE wire_n01i_dataout;
	wire_n1iO_dataout <= nii1i WHEN n0O0O = '1'  ELSE wire_n01l_dataout;
	wire_n1l_dataout <= wire_nii_dataout AND NOT(n0Oli);
	wire_n1li_dataout <= nii1l WHEN n0O0O = '1'  ELSE wire_n01O_dataout;
	wire_n1ll_dataout <= nii1O WHEN n0O0O = '1'  ELSE wire_n00i_dataout;
	wire_n1lO_dataout <= nii0i WHEN n0O0O = '1'  ELSE wire_n00l_dataout;
	wire_n1O_dataout <= wire_nil_dataout AND NOT(n0Oli);
	wire_n1Oi_dataout <= nii0l WHEN n0O0O = '1'  ELSE wire_n00O_dataout;
	wire_n1Ol_dataout <= nii0O WHEN n0O0O = '1'  ELSE wire_n0ii_dataout;
	wire_n1OO_dataout <= niiii WHEN n0O0O = '1'  ELSE wire_n0il_dataout;
	wire_ni1i_dataout <= wire_ni1O_o(7) WHEN n0Oii = '1'  ELSE niiii;
	wire_ni1l_dataout <= wire_ni1O_o(8) WHEN n0Oii = '1'  ELSE niiil;
	wire_nii_dataout <= nilOO WHEN n0Oll = '1'  ELSE wire_nlO_o(0);
	wire_nil_dataout <= niii WHEN n0Oll = '1'  ELSE wire_nlO_o(1);
	wire_niO_dataout <= niil WHEN n0Oll = '1'  ELSE wire_nlO_o(2);
	wire_nl00i_dataout <= nilOi AND NOT(onestep);
	wire_nl00l_dataout <= nil0i AND NOT(wire_w_lg_PhaseDone333w(0));
	wire_nl00O_dataout <= nil0l AND NOT(wire_w_lg_PhaseDone333w(0));
	wire_nl01i_dataout <= nilil AND NOT(onestep);
	wire_nl01l_dataout <= niliO AND NOT(onestep);
	wire_nl01O_dataout <= nilll AND NOT(onestep);
	wire_nl0ii_dataout <= nil0O AND NOT(wire_w_lg_PhaseDone333w(0));
	wire_nl0il_dataout <= nilii AND NOT(wire_w_lg_PhaseDone333w(0));
	wire_nl0iO_dataout <= nilil AND NOT(wire_w_lg_PhaseDone333w(0));
	wire_nl0li_dataout <= niliO AND NOT(wire_w_lg_PhaseDone333w(0));
	wire_nl0ll_dataout <= nilll OR wire_w_lg_PhaseDone333w(0);
	wire_nl0lO_dataout <= nilOi AND NOT(wire_w_lg_PhaseDone333w(0));
	wire_nl0Oi_dataout <= nil1O OR wire_w_lg_PhaseDone333w(0);
	wire_nl0Ol_dataout <= niiiO AND NOT(wire_w_lg_PhaseDone333w(0));
	wire_nl0OO_dataout <= wire_nll1l_o WHEN niiOO = '1'  ELSE niilO;
	wire_nl1il_dataout <= nil0l OR wire_w_lg_PhaseDone333w(0);
	wire_nl1iO_dataout <= nilll AND NOT(wire_w_lg_PhaseDone333w(0));
	wire_nl1li_dataout <= onestep_dir WHEN onestep = '1'  ELSE niili;
	wire_nl1ll_dataout <= niiiO OR onestep;
	wire_nl1lO_dataout <= nil0i OR onestep;
	wire_nl1Oi_dataout <= nil0l AND NOT(onestep);
	wire_nl1Ol_dataout <= nil0O AND NOT(onestep);
	wire_nl1OO_dataout <= nilii AND NOT(onestep);
	wire_nli_dataout <= niiO WHEN n0Oll = '1'  ELSE wire_nlO_o(3);
	wire_nli0i_dataout <= wire_nllii_o WHEN niiOO = '1'  ELSE niill;
	wire_nli0l_dataout <= wire_nllil_dataout WHEN niiOO = '1'  ELSE ni0Oi;
	wire_nli0O_dataout <= nil0i AND NOT(niiOO);
	wire_nli1i_dataout <= wire_nll1O_o WHEN niiOO = '1'  ELSE niiOl;
	wire_nli1l_dataout <= wire_nll0i_o WHEN niiOO = '1'  ELSE ni0Ol;
	wire_nli1O_dataout <= wire_nll0l_o WHEN niiOO = '1'  ELSE niili;
	wire_nliii_dataout <= wire_nlliO_dataout WHEN niiOO = '1'  ELSE nil0l;
	wire_nliil_dataout <= wire_nllli_o(5) WHEN niiOO = '1'  ELSE nil0O;
	wire_nliiO_dataout <= wire_nllll_o WHEN niiOO = '1'  ELSE nilii;
	wire_nlili_dataout <= wire_nlllO_o WHEN niiOO = '1'  ELSE nilil;
	wire_nlill_dataout <= wire_nllOi_o WHEN niiOO = '1'  ELSE niliO;
	wire_nlilO_dataout <= nilll AND NOT(niiOO);
	wire_nliOi_dataout <= nilOi AND NOT(niiOO);
	wire_nliOl_dataout <= wire_nllOl_o WHEN niiOO = '1'  ELSE niiiO;
	wire_nliOO_dataout <= wire_nll0O_o WHEN niiOO = '1'  ELSE ni0OO;
	wire_nll_dataout <= nili WHEN n0Oll = '1'  ELSE wire_nlO_o(4);
	wire_nll1i_dataout <= nil1O AND NOT(niiOO);
	wire_nllil_dataout <= wire_nllOO_dataout WHEN wire_nllli_o(7) = '1'  ELSE ni0Oi;
	wire_nlliO_dataout <= wire_nlO1l_w_lg_o238w(0) AND wire_nllli_o(7);
	wire_nllOO_dataout <= ni0Oi OR wire_nlO1l_o;
	wire_nlO0i_dataout <= ni0Ol OR wire_nill_w_lg_nilO133w(0);
	wire_nlO0l_dataout <= niilO OR wire_nill_w_lg_nilO133w(0);
	wire_nlO0O_dataout <= ni0Ol OR wire_niOi_w_lg_niOl134w(0);
	wire_nlO1i_dataout <= niiiO OR wire_nlO1l_o;
	wire_nlO1O_dataout <= niiOl OR niOl;
	wire_nlOii_dataout <= niilO OR wire_niOi_w_lg_niOl134w(0);
	wire_nlOil_dataout <= ni0Ol OR NOT(nilO);
	wire_nlOiO_dataout <= niill OR nilO;
	wire_nlOli_dataout <= ni0Ol OR niOl;
	wire_nlOll_dataout <= niilO WHEN niOl = '1'  ELSE wire_nlOOO_dataout;
	wire_nlOlO_dataout <= niill WHEN niOl = '1'  ELSE wire_nlOiO_dataout;
	wire_nlOOi_dataout <= wire_nill_w_lg_nilO133w(0) OR niOl;
	wire_nlOOl_dataout <= nilO AND NOT(niOl);
	wire_nlOOO_dataout <= niilO OR NOT(nilO);
	wire_ni0l_a <= ( niiil & niiii & nii0O & nii0l & nii0i & nii1O & nii1l & nii1i);
	wire_ni0l_b <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "1");
	ni0l :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 8,
		width_b => 8,
		width_o => 8
	  )
	  PORT MAP ( 
		a => wire_ni0l_a,
		b => wire_ni0l_b,
		cin => wire_gnd,
		o => wire_ni0l_o
	  );
	wire_ni1O_a <= ( niiil & niiii & nii0O & nii0l & nii0i & nii1O & nii1l & nii1i & "1");
	wire_ni1O_b <= ( "1" & "1" & "1" & "1" & "1" & "1" & "1" & "0" & "1");
	ni1O :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 9,
		width_b => 9,
		width_o => 9
	  )
	  PORT MAP ( 
		a => wire_ni1O_a,
		b => wire_ni1O_b,
		cin => wire_gnd,
		o => wire_ni1O_o
	  );
	wire_nlO_a <= ( nili & niiO & niil & niii & nilOO);
	wire_nlO_b <= ( "0" & "0" & "0" & "0" & "1");
	nlO :  oper_add
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 5,
		width_b => 5,
		width_o => 5
	  )
	  PORT MAP ( 
		a => wire_nlO_a,
		b => wire_nlO_b,
		cin => wire_gnd,
		o => wire_nlO_o
	  );
	wire_nllli_i <= ( niiOl & niilO & niill);
	nllli :  oper_decoder
	  GENERIC MAP (
		width_i => 3,
		width_o => 8
	  )
	  PORT MAP ( 
		i => wire_nllli_i,
		o => wire_nllli_o
	  );
	wire_nlO1l_w_lg_o238w(0) <= NOT wire_nlO1l_o;
	wire_nlO1l_a <= ( "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0");
	wire_nlO1l_b <= ( niiil & niiii & nii0O & nii0l & nii0i & nii1O & nii1l & nii1i);
	nlO1l :  oper_less_than
	  GENERIC MAP (
		sgate_representation => 0,
		width_a => 8,
		width_b => 8
	  )
	  PORT MAP ( 
		a => wire_nlO1l_a,
		b => wire_nlO1l_b,
		cin => wire_gnd,
		o => wire_nlO1l_o
	  );
	wire_nll0i_data <= ( ni0Ol & wire_nlOil_dataout & ni0Ol & wire_nlO0O_dataout & "1" & wire_nlOli_dataout & wire_nlO0i_dataout & ni0Ol);
	wire_nll0i_sel <= ( niiOl & niilO & niill);
	nll0i :  oper_mux
	  GENERIC MAP (
		width_data => 8,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_nll0i_data,
		o => wire_nll0i_o,
		sel => wire_nll0i_sel
	  );
	wire_nll0l_data <= ( niili & "0" & niili & "0" & wire_niOi_w_lg_niOl134w & wire_niOi_w_lg_niOl134w & "1" & wire_nlOOl_dataout);
	wire_nll0l_sel <= ( niiOl & niilO & niill);
	nll0l :  oper_mux
	  GENERIC MAP (
		width_data => 8,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_nll0l_data,
		o => wire_nll0l_o,
		sel => wire_nll0l_sel
	  );
	wire_nll0O_data <= ( "0" & nilO & "1" & "0" & "0" & "0" & "0" & "0");
	wire_nll0O_sel <= ( niiOl & niilO & niill);
	nll0O :  oper_mux
	  GENERIC MAP (
		width_data => 8,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_nll0O_data,
		o => wire_nll0O_o,
		sel => wire_nll0O_sel
	  );
	wire_nll1l_data <= ( niilO & niilO & "0" & wire_nlOii_dataout & niilO & niilO & wire_nlO0l_dataout & wire_nlOll_dataout);
	wire_nll1l_sel <= ( niiOl & niilO & niill);
	nll1l :  oper_mux
	  GENERIC MAP (
		width_data => 8,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_nll1l_data,
		o => wire_nll1l_o,
		sel => wire_nll1l_sel
	  );
	wire_nll1O_data <= ( niiOl & niiOl & "0" & niiOl & wire_nlO1O_dataout & wire_nlO1O_dataout & niiOl & wire_nlO1O_dataout);
	wire_nll1O_sel <= ( niiOl & niilO & niill);
	nll1O :  oper_mux
	  GENERIC MAP (
		width_data => 8,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_nll1O_data,
		o => wire_nll1O_o,
		sel => wire_nll1O_sel
	  );
	wire_nllii_data <= ( niill & wire_nlOiO_dataout & "0" & niill & niill & niill & niill & wire_nlOlO_dataout);
	wire_nllii_sel <= ( niiOl & niilO & niill);
	nllii :  oper_mux
	  GENERIC MAP (
		width_data => 8,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_nllii_data,
		o => wire_nllii_o,
		sel => wire_nllii_sel
	  );
	wire_nllll_data <= ( wire_nlO1l_o & nilO & "0" & "0" & niOl & "0" & "0" & "0");
	wire_nllll_sel <= ( niiOl & niilO & niill);
	nllll :  oper_mux
	  GENERIC MAP (
		width_data => 8,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_nllll_data,
		o => wire_nllll_o,
		sel => wire_nllll_sel
	  );
	wire_nlllO_data <= ( "0" & "0" & "0" & "0" & wire_niOi_w_lg_niOl134w & wire_niOi_w_lg_niOl134w & "1" & wire_nlOOl_dataout);
	wire_nlllO_sel <= ( niiOl & niilO & niill);
	nlllO :  oper_mux
	  GENERIC MAP (
		width_data => 8,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_nlllO_data,
		o => wire_nlllO_o,
		sel => wire_nlllO_sel
	  );
	wire_nllOi_data <= ( "0" & wire_nill_w_lg_nilO133w & "0" & "1" & "0" & niOl & "0" & wire_nlOOi_dataout);
	wire_nllOi_sel <= ( niiOl & niilO & niill);
	nllOi :  oper_mux
	  GENERIC MAP (
		width_data => 8,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_nllOi_data,
		o => wire_nllOi_o,
		sel => wire_nllOi_sel
	  );
	wire_nllOl_data <= ( wire_nlO1i_dataout & "1" & niiiO & "1" & "1" & "1" & "1" & "1");
	wire_nllOl_sel <= ( niiOl & niilO & niill);
	nllOl :  oper_mux
	  GENERIC MAP (
		width_data => 8,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_nllOl_data,
		o => wire_nllOl_o,
		sel => wire_nllOl_sel
	  );
	wire_niO0i_data <= ( niili & wire_nli1O_dataout & wire_nl1li_dataout);
	wire_niO0i_sel <= ( n0O1O & nilll & nil0l);
	niO0i :  oper_selector
	  GENERIC MAP (
		width_data => 3,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_niO0i_data,
		o => wire_niO0i_o,
		sel => wire_niO0i_sel
	  );
	wire_niO0O_data <= ( ni0Oi & wire_nli0l_dataout & "0");
	wire_niO0O_sel <= ( n0O0i & nilll & nilii);
	niO0O :  oper_selector
	  GENERIC MAP (
		width_data => 3,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_niO0O_data,
		o => wire_niO0O_o,
		sel => wire_niO0O_sel
	  );
	wire_niO1i_data <= ( ni0Ol & wire_nli1l_dataout & "0");
	wire_niO1i_sel <= ( wire_nillO_w_lg_w_lg_w_lg_nilOi509w555w556w & nilll & wire_nilli_w_lg_w_lg_niliO496w551w);
	niO1i :  oper_selector
	  GENERIC MAP (
		width_data => 3,
		width_sel => 3
	  )
	  PORT MAP ( 
		data => wire_niO1i_data,
		o => wire_niO1i_o,
		sel => wire_niO1i_sel
	  );
	wire_niOil_data <= ( niiiO & wire_nliOl_dataout & wire_nl0Ol_dataout & wire_nl0Ol_dataout & wire_nl0Ol_dataout & wire_nl1ll_dataout & wire_nl0Ol_dataout);
	wire_niOil_sel <= ( n0O0l & nilll & niliO & nilil & nilii & nil0l & nil0i);
	niOil :  oper_selector
	  GENERIC MAP (
		width_data => 7,
		width_sel => 7
	  )
	  PORT MAP ( 
		data => wire_niOil_data,
		o => wire_niOil_o,
		sel => wire_niOil_sel
	  );
	wire_niOli_data <= ( "1" & wire_nliOO_dataout & ni0OO & "0");
	wire_niOli_sel <= ( nilOi & nilll & wire_nilli_w_lg_w_lg_w_lg_niliO496w497w498w & wire_nilli_w_lg_nilii493w);
	niOli :  oper_selector
	  GENERIC MAP (
		width_data => 4,
		width_sel => 4
	  )
	  PORT MAP ( 
		data => wire_niOli_data,
		o => wire_niOli_o,
		sel => wire_niOli_sel
	  );
	wire_niOOi_data <= ( "0" & wire_nli0O_dataout & wire_nl00l_dataout & wire_nl00l_dataout & wire_nl00l_dataout & wire_nl1lO_dataout & wire_nl00l_dataout);
	wire_niOOi_sel <= ( n0O0l & nilll & niliO & nilil & nilii & nil0l & nil0i);
	niOOi :  oper_selector
	  GENERIC MAP (
		width_data => 7,
		width_sel => 7
	  )
	  PORT MAP ( 
		data => wire_niOOi_data,
		o => wire_niOOi_o,
		sel => wire_niOOi_sel
	  );
	wire_niOOl_data <= ( "0" & wire_nliii_dataout & wire_nl00O_dataout & wire_nl00O_dataout & wire_nl00O_dataout & wire_nl1Oi_dataout & wire_nl1il_dataout);
	wire_niOOl_sel <= ( n0O0l & nilll & niliO & nilil & nilii & nil0l & nil0i);
	niOOl :  oper_selector
	  GENERIC MAP (
		width_data => 7,
		width_sel => 7
	  )
	  PORT MAP ( 
		data => wire_niOOl_data,
		o => wire_niOOl_o,
		sel => wire_niOOl_sel
	  );
	wire_niOOO_data <= ( "0" & wire_nliil_dataout & wire_nl0ii_dataout & wire_nl0ii_dataout & wire_nl0ii_dataout & wire_nl1Ol_dataout & wire_nl0ii_dataout);
	wire_niOOO_sel <= ( n0O0l & nilll & niliO & nilil & nilii & nil0l & nil0i);
	niOOO :  oper_selector
	  GENERIC MAP (
		width_data => 7,
		width_sel => 7
	  )
	  PORT MAP ( 
		data => wire_niOOO_data,
		o => wire_niOOO_o,
		sel => wire_niOOO_sel
	  );
	wire_nl10i_data <= ( "1" & wire_nlilO_dataout & wire_nl0ll_dataout & wire_nl0ll_dataout & wire_nl0ll_dataout & wire_nl01O_dataout & wire_nl1iO_dataout & "0");
	wire_nl10i_sel <= ( nilOi & nilll & niliO & nilil & nilii & nil0l & nil0i & nil0O);
	nl10i :  oper_selector
	  GENERIC MAP (
		width_data => 8,
		width_sel => 8
	  )
	  PORT MAP ( 
		data => wire_nl10i_data,
		o => wire_nl10i_o,
		sel => wire_nl10i_sel
	  );
	wire_nl10l_data <= ( "0" & wire_nliOi_dataout & wire_nl0lO_dataout & wire_nl0lO_dataout & wire_nl0lO_dataout & wire_nl00i_dataout & wire_nl0lO_dataout & "1");
	wire_nl10l_sel <= ( nilOi & nilll & niliO & nilil & nilii & nil0l & nil0i & nil0O);
	nl10l :  oper_selector
	  GENERIC MAP (
		width_data => 8,
		width_sel => 8
	  )
	  PORT MAP ( 
		data => wire_nl10l_data,
		o => wire_nl10l_o,
		sel => wire_nl10l_sel
	  );
	wire_nl10O_data <= ( "1" & wire_nll1i_dataout & wire_nl0Oi_dataout & wire_nl0Oi_dataout & wire_nl0Oi_dataout & nil1O);
	wire_nl10O_sel <= ( nilOi & nilll & niliO & nilil & nilii & wire_nilli_w_lg_w_lg_nil0O334w335w);
	nl10O :  oper_selector
	  GENERIC MAP (
		width_data => 6,
		width_sel => 6
	  )
	  PORT MAP ( 
		data => wire_nl10O_data,
		o => wire_nl10O_o,
		sel => wire_nl10O_sel
	  );
	wire_nl11i_data <= ( "0" & wire_nliiO_dataout & wire_nl0il_dataout & wire_nl0il_dataout & wire_nl0il_dataout & wire_nl1OO_dataout & wire_nl0il_dataout);
	wire_nl11i_sel <= ( n0O0l & nilll & niliO & nilil & nilii & nil0l & nil0i);
	nl11i :  oper_selector
	  GENERIC MAP (
		width_data => 7,
		width_sel => 7
	  )
	  PORT MAP ( 
		data => wire_nl11i_data,
		o => wire_nl11i_o,
		sel => wire_nl11i_sel
	  );
	wire_nl11l_data <= ( "0" & wire_nlili_dataout & wire_nl0iO_dataout & wire_nl0iO_dataout & wire_nl0iO_dataout & wire_nl01i_dataout & wire_nl0iO_dataout);
	wire_nl11l_sel <= ( n0O0l & nilll & niliO & nilil & nilii & nil0l & nil0i);
	nl11l :  oper_selector
	  GENERIC MAP (
		width_data => 7,
		width_sel => 7
	  )
	  PORT MAP ( 
		data => wire_nl11l_data,
		o => wire_nl11l_o,
		sel => wire_nl11l_sel
	  );
	wire_nl11O_data <= ( "0" & wire_nlill_dataout & wire_nl0li_dataout & wire_nl0li_dataout & wire_nl0li_dataout & wire_nl01l_dataout & wire_nl0li_dataout);
	wire_nl11O_sel <= ( n0O0l & nilll & niliO & nilil & nilii & nil0l & nil0i);
	nl11O :  oper_selector
	  GENERIC MAP (
		width_data => 7,
		width_sel => 7
	  )
	  PORT MAP ( 
		data => wire_nl11O_data,
		o => wire_nl11O_o,
		sel => wire_nl11O_sel
	  );

 END RTL; --altpcie_pclk_align
--synopsys translate_on
--VALID FILE
