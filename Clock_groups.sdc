# ----------------------------------------------------------------------------
# FILE: 	Clock_groups.vhd
# DESCRIPTION:	Clock group assigments for TimeQuest
# DATE:	June 2, 2017
# AUTHOR(s):	Lime Microsystems
# REVISIONS:
# ----------------------------------------------------------------------------
# NOTES:
# This file must be last in .sdc file list
# ----------------------------------------------------------------------------


# Set clkA and clkB to be mutually exclusive clocks.
set_clock_groups -asynchronous 	-group [get_clocks {CLK50_FPGA_1}] \
											-group [get_clocks {CLK100_FPGA}] \
											-group [get_clocks {CLK50_FPGA_2}] \
											-group [get_clocks {LMK_CLK FPGA_SPI0_SCLK_reg FPGA_SPI0_SCLK_out }] \
											-group [get_clocks {PCIE_REFCLK}] \
											-group [get_clocks {LMS_MCLK1}] \
											-group [get_clocks {TX_PLLCLK_C0}] \
											-group [get_clocks {TX_PLLCLK_C1}] \
											-group [get_clocks {LMS_MCLK2}] \
											-group [get_clocks {RX_PLLCLK_C0}] \
											-group [get_clocks {RX_PLLCLK_C1}] \
											-group [get_clocks {SI_CLK0}] \
                                 -group [get_clocks {SI_CLK1}] \
                                 -group [get_clocks {SI_CLK3}] \
                                 -group [get_clocks {SI_CLK5}] \
											-group [get_clocks {SI_CLK6}] \
                                 -group [get_clocks {inst15|xillybus_inst|pcie|wrapper|altpcie_hip_pipen1b_inst|cyclone_iii.cycloneiv_hssi_pcie_hip|coreclkout}] \
                                 -group [get_clocks {inst28|DDR2_ctrl_top_inst|ddr2_inst|ddr2_controller_phy_inst|ddr2_phy_inst|ddr2_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[1]}]