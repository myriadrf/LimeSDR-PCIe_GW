## Generated SDC file "LimeSDR-PCIE_lms7_trx.out.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"

## DATE    "Mon Jul 15 15:32:34 2019"

##
## DEVICE  "EP4CGX30CF23C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {LMS_MCLK1} -period 6.250 -waveform { 0.000 3.125 } [get_ports {LMS_MCLK1}] -add
create_clock -name {LMS_MCLK1_5MHZ} -period 200.000 -waveform { 0.000 100.000 } [get_ports {LMS_MCLK1}] -add
create_clock -name {LMS_MCLK2} -period 6.250 -waveform { 0.000 3.125 } [get_ports {LMS_MCLK2}] -add
create_clock -name {LMS_MCLK2_5MHZ} -period 200.000 -waveform { 0.000 100.000 } [get_ports {LMS_MCLK2}] -add
create_clock -name {LMS_MCLK2_VIRT} -period 6.250 -waveform { 0.000 3.125 } 
create_clock -name {LMS_MCLK2_VIRT_5MHz} -period 200.000 -waveform { 0.000 100.000 } 
create_clock -name {CLK50_FPGA} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLK50_FPGA}]
create_clock -name {CLK100_FPGA} -period 10.000 -waveform { 0.000 5.000 } [get_ports {CLK100_FPGA}]
create_clock -name {CLK125_FPGA} -period 8.000 -waveform { 0.000 4.000 } [get_ports {CLK125_FPGA}]
create_clock -name {SI_CLK0} -period 37.037 -waveform { 0.000 18.518 } [get_ports {SI_CLK0}]
create_clock -name {SI_CLK1} -period 37.037 -waveform { 0.000 18.518 } [get_ports {SI_CLK1}]
create_clock -name {SI_CLK2} -period 37.037 -waveform { 0.000 18.518 } [get_ports {SI_CLK2}]
create_clock -name {SI_CLK3} -period 37.037 -waveform { 0.000 18.518 } [get_ports {SI_CLK3}]
create_clock -name {SI_CLK5} -period 37.037 -waveform { 0.000 18.518 } [get_ports {SI_CLK5}]
create_clock -name {SI_CLK6} -period 37.037 -waveform { 0.000 18.518 } [get_ports {SI_CLK6}]
create_clock -name {SI_CLK7} -period 37.037 -waveform { 0.000 18.518 } [get_ports {SI_CLK7}]
create_clock -name {LMK_CLK} -period 32.552 -waveform { 0.000 16.276 } [get_ports {LMK_CLK}]
create_clock -name {PCIE_REFCLK} -period 10.000 -waveform { 0.000 5.000 } [get_ports {pcie_refclk}]
create_clock -name {CLK100_FPGA_VIRT} -period 10.000 -waveform { 0.000 5.000 } 


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {TX_PLLCLK_C0} -source [get_pins -compatibility_mode {*tx_pll_top*|*|*|pll1|inclk[0]}] -master_clock {LMS_MCLK1} [get_pins -compatibility_mode {*tx_pll_top*|*|*|pll1|clk[0]}] 
create_generated_clock -name {TX_PLLCLK_C1} -source [get_pins -compatibility_mode {*tx_pll_top*|*|*|pll1|inclk[0]}] -master_clock {LMS_MCLK1} [get_pins -compatibility_mode {*tx_pll_top*|*|*|pll1|clk[1]}] 
create_generated_clock -name {LMS_FCLK1_PLL} -source [get_pins -compatibility_mode {*tx_pll_top*|*|*|dataout*}] -master_clock {TX_PLLCLK_C0} -invert [get_ports {LMS_FCLK1}] -add
create_generated_clock -name {LMS_FCLK1_DRCT} -source [get_pins -compatibility_mode {*tx_pll_top*|*|*|dataout*}] -master_clock {LMS_MCLK1_5MHZ} -invert [get_ports {LMS_FCLK1}] -add
create_generated_clock -name {RX_PLLCLK_C0} -source [get_pins -compatibility_mode {*rx_pll_top*|*|*|pll1|inclk[0]}] -master_clock {LMS_MCLK2} [get_pins -compatibility_mode {*rx_pll_top*|*|*|pll1|clk[0]}] 
create_generated_clock -name {RX_PLLCLK_C1} -source [get_pins -compatibility_mode {*rx_pll_top*|*|*|pll1|inclk[0]}] -master_clock {LMS_MCLK2} [get_pins -compatibility_mode {*rx_pll_top*|*|*|pll1|clk[1]}] 
create_generated_clock -name {LMS_FCLK2_PLL} -source [get_pins -compatibility_mode {*rx_pll_top*|*|*|dataout*}] -master_clock {RX_PLLCLK_C0} [get_ports {LMS_FCLK2}] -add
create_generated_clock -name {LMS_FCLK2_DRCT} -source [get_pins -compatibility_mode {*rx_pll_top*|*|*|dataout*}] -master_clock {LMS_MCLK2_5MHZ} [get_ports {LMS_FCLK2}] -add
create_generated_clock -name {FPGA_SPI0_SCLK_reg} -source [get_ports {CLK100_FPGA}] -divide_by 6 -master_clock {CLK100_FPGA} [get_registers {*|lms_ctr_spi_lms:spi_lms|SCLK_reg}] 
create_generated_clock -name {FPGA_SPI0_SCLK_out} -source [get_registers {*|lms_ctr_spi_lms:spi_lms|SCLK_reg}] -master_clock {FPGA_SPI0_SCLK_reg} [get_ports {FPGA_SPI0_SCLK}] 
create_generated_clock -name {FPGA_SPI1_SCLK} -source [get_ports {CLK100_FPGA}] -divide_by 6 -master_clock {CLK100_FPGA} [get_registers {*|lms_ctr_spi_1:spi_1|SCLK_reg}] 
create_generated_clock -name {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|cent_unit0|refclkout} -source [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pma0|clockout}] -duty_cycle 50/1 -multiply_by 1 -master_clock {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pma0|clockout} [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|cent_unit0|refclkout}] 
create_generated_clock -name {inst2_pcie_top|inst0_pll_pcie|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {inst2_pcie_top|inst0_pll_pcie|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 5 -divide_by 4 -master_clock {CLK125_FPGA} [get_pins {inst2_pcie_top|inst0_pll_pcie|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {inst2_pcie_top|inst0_pll_pcie|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {inst2_pcie_top|inst0_pll_pcie|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 2 -master_clock {CLK125_FPGA} [get_pins {inst2_pcie_top|inst0_pll_pcie|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pma3|clockout} -source [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|icdrclk}] -duty_cycle 50/1 -multiply_by 1 -divide_by 5 -master_clock {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|icdrclk} [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pma3|clockout}] 
create_generated_clock -name {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pma1|clockout} -source [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|icdrclk}] -duty_cycle 50/1 -multiply_by 1 -divide_by 5 -master_clock {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|icdrclk} [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pma1|clockout}] 
create_generated_clock -name {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pma2|clockout} -source [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|icdrclk}] -duty_cycle 50/1 -multiply_by 1 -divide_by 5 -master_clock {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|icdrclk} [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pma2|clockout}] 
create_generated_clock -name {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|wrapper|altpcie_hip_pipen1b_inst|cyclone_iii.cycloneiv_hssi_pcie_hip|pllfixedclk} -source [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|cent_unit0|refclkout}] -duty_cycle 50/1 -multiply_by 1 -divide_by 2 -master_clock {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|cent_unit0|refclkout} [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|wrapper|altpcie_hip_pipen1b_inst|cyclone_iii.cycloneiv_hssi_pcie_hip|pllfixedclk}] 
create_generated_clock -name {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|wrapper|altpcie_hip_pipen1b_inst|cyclone_iii.cycloneiv_hssi_pcie_hip|coreclkout} -source [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|wrapper|altpcie_hip_pipen1b_inst|cyclone_iii.cycloneiv_hssi_pcie_hip|pllfixedclk}] -duty_cycle 50/1 -multiply_by 1 -master_clock {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|wrapper|altpcie_hip_pipen1b_inst|cyclone_iii.cycloneiv_hssi_pcie_hip|pllfixedclk} [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|wrapper|altpcie_hip_pipen1b_inst|cyclone_iii.cycloneiv_hssi_pcie_hip|coreclkout}] 
create_generated_clock -name {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|icdrclk} -source [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 25 -divide_by 2 -master_clock {PCIE_REFCLK} [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|icdrclk}] 
create_generated_clock -name {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|clk[0]} -source [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 25 -divide_by 2 -master_clock {PCIE_REFCLK} [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|clk[1]} -source [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 5 -divide_by 2 -master_clock {PCIE_REFCLK} [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|clk[2]} -source [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|inclk[0]}] -duty_cycle 20/1 -multiply_by 5 -divide_by 2 -master_clock {PCIE_REFCLK} [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pma0|clockout} -source [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|icdrclk}] -duty_cycle 50/1 -multiply_by 1 -divide_by 5 -master_clock {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|icdrclk} [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pma0|clockout}] 
create_generated_clock -name {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pma0|clockout} -source [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|clk[1]}] -duty_cycle 50/1 -multiply_by 1 -master_clock {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|clk[1]} [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pma0|clockout}] 
create_generated_clock -name {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pma1|clockout} -source [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|clk[1]}] -duty_cycle 50/1 -multiply_by 1 -master_clock {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|clk[1]} [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pma1|clockout}] 
create_generated_clock -name {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pma2|clockout} -source [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|clk[1]}] -duty_cycle 50/1 -multiply_by 1 -master_clock {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|clk[1]} [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pma2|clockout}] 
create_generated_clock -name {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pma3|clockout} -source [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|clk[1]}] -duty_cycle 50/1 -multiply_by 1 -master_clock {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|pll0|auto_generated|pll1|clk[1]} [get_pins {inst2_pcie_top|inst1_litepcie_top|inst0_litepcie_core|pcie_phy_top|comp_pcie_phy|serdes|pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pma3|clockout}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {LMS_MCLK1_5MHZ}] -rise_to [get_clocks {LMS_MCLK1_5MHZ}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {LMS_MCLK1_5MHZ}] -fall_to [get_clocks {LMS_MCLK1_5MHZ}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {LMS_MCLK1_5MHZ}] -rise_to [get_clocks {LMS_FCLK1_DRCT}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {LMS_MCLK1_5MHZ}] -fall_to [get_clocks {LMS_FCLK1_DRCT}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {LMS_MCLK1_5MHZ}] -rise_to [get_clocks {LMS_MCLK1_5MHZ}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {LMS_MCLK1_5MHZ}] -fall_to [get_clocks {LMS_MCLK1_5MHZ}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {LMS_MCLK1_5MHZ}] -rise_to [get_clocks {LMS_FCLK1_DRCT}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {LMS_MCLK1_5MHZ}] -fall_to [get_clocks {LMS_FCLK1_DRCT}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {LMS_MCLK2_VIRT}] -rise_to [get_clocks {RX_PLLCLK_C1}] -setup 0.060  
set_clock_uncertainty -rise_from [get_clocks {LMS_MCLK2_VIRT}] -rise_to [get_clocks {RX_PLLCLK_C1}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {LMS_MCLK2_VIRT}] -fall_to [get_clocks {RX_PLLCLK_C1}] -setup 0.060  
set_clock_uncertainty -rise_from [get_clocks {LMS_MCLK2_VIRT}] -fall_to [get_clocks {RX_PLLCLK_C1}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {LMS_MCLK2_VIRT}] -rise_to [get_clocks {RX_PLLCLK_C1}] -setup 0.060  
set_clock_uncertainty -fall_from [get_clocks {LMS_MCLK2_VIRT}] -rise_to [get_clocks {RX_PLLCLK_C1}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {LMS_MCLK2_VIRT}] -fall_to [get_clocks {RX_PLLCLK_C1}] -setup 0.060  
set_clock_uncertainty -fall_from [get_clocks {LMS_MCLK2_VIRT}] -fall_to [get_clocks {RX_PLLCLK_C1}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {LMS_MCLK2_5MHZ}] -rise_to [get_clocks {LMS_MCLK2_5MHZ}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {LMS_MCLK2_5MHZ}] -fall_to [get_clocks {LMS_MCLK2_5MHZ}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {LMS_MCLK2_5MHZ}] -rise_to [get_clocks {LMS_MCLK2_5MHZ}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {LMS_MCLK2_5MHZ}] -fall_to [get_clocks {LMS_MCLK2_5MHZ}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {LMS_MCLK2_VIRT_5MHz}] -rise_to [get_clocks {LMS_MCLK2_5MHZ}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {LMS_MCLK2_VIRT_5MHz}] -fall_to [get_clocks {LMS_MCLK2_5MHZ}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {LMS_MCLK2_VIRT_5MHz}] -rise_to [get_clocks {LMS_MCLK2_5MHZ}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {LMS_MCLK2_VIRT_5MHz}] -fall_to [get_clocks {LMS_MCLK2_5MHZ}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {TX_PLLCLK_C1}] -rise_to [get_clocks {TX_PLLCLK_C1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {TX_PLLCLK_C1}] -fall_to [get_clocks {TX_PLLCLK_C1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {TX_PLLCLK_C1}] -rise_to [get_clocks {LMS_FCLK1_PLL}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {TX_PLLCLK_C1}] -fall_to [get_clocks {LMS_FCLK1_PLL}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {TX_PLLCLK_C1}] -rise_to [get_clocks {TX_PLLCLK_C1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {TX_PLLCLK_C1}] -fall_to [get_clocks {TX_PLLCLK_C1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {TX_PLLCLK_C1}] -rise_to [get_clocks {LMS_FCLK1_PLL}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {TX_PLLCLK_C1}] -fall_to [get_clocks {LMS_FCLK1_PLL}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {RX_PLLCLK_C1}] -rise_to [get_clocks {RX_PLLCLK_C1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {RX_PLLCLK_C1}] -fall_to [get_clocks {RX_PLLCLK_C1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {RX_PLLCLK_C1}] -rise_to [get_clocks {RX_PLLCLK_C1}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {RX_PLLCLK_C1}] -fall_to [get_clocks {RX_PLLCLK_C1}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLK100_FPGA}] -rise_to [get_clocks {CLK100_FPGA}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK100_FPGA}] -fall_to [get_clocks {CLK100_FPGA}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK100_FPGA}] -rise_to [get_clocks {FPGA_SPI1_SCLK}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK100_FPGA}] -fall_to [get_clocks {FPGA_SPI1_SCLK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK100_FPGA}] -rise_to [get_clocks {CLK100_FPGA}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK100_FPGA}] -fall_to [get_clocks {CLK100_FPGA}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK100_FPGA}] -rise_to [get_clocks {FPGA_SPI1_SCLK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK100_FPGA}] -fall_to [get_clocks {FPGA_SPI1_SCLK}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK125_FPGA}] -rise_to [get_clocks {CLK125_FPGA}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK125_FPGA}] -fall_to [get_clocks {CLK125_FPGA}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK125_FPGA}] -rise_to [get_clocks {CLK125_FPGA}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK125_FPGA}] -fall_to [get_clocks {CLK125_FPGA}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {LMK_CLK}] -rise_to [get_clocks {LMK_CLK}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {LMK_CLK}] -fall_to [get_clocks {LMK_CLK}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {LMK_CLK}] -rise_to [get_clocks {FPGA_SPI0_SCLK_reg}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {LMK_CLK}] -fall_to [get_clocks {FPGA_SPI0_SCLK_reg}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {LMK_CLK}] -rise_to [get_clocks {FPGA_SPI1_SCLK}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {LMK_CLK}] -fall_to [get_clocks {FPGA_SPI1_SCLK}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {LMK_CLK}] -rise_to [get_clocks {LMK_CLK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {LMK_CLK}] -fall_to [get_clocks {LMK_CLK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {LMK_CLK}] -rise_to [get_clocks {FPGA_SPI0_SCLK_reg}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {LMK_CLK}] -fall_to [get_clocks {FPGA_SPI0_SCLK_reg}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {LMK_CLK}] -rise_to [get_clocks {FPGA_SPI1_SCLK}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {LMK_CLK}] -fall_to [get_clocks {FPGA_SPI1_SCLK}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {FPGA_SPI0_SCLK_reg}] -rise_to [get_clocks {LMS_FCLK1_PLL}] -setup 0.140  
set_clock_uncertainty -rise_from [get_clocks {FPGA_SPI0_SCLK_reg}] -rise_to [get_clocks {LMS_FCLK1_PLL}] -hold 0.150  
set_clock_uncertainty -rise_from [get_clocks {FPGA_SPI0_SCLK_reg}] -fall_to [get_clocks {LMS_FCLK1_PLL}] -setup 0.140  
set_clock_uncertainty -rise_from [get_clocks {FPGA_SPI0_SCLK_reg}] -fall_to [get_clocks {LMS_FCLK1_PLL}] -hold 0.150  
set_clock_uncertainty -rise_from [get_clocks {FPGA_SPI0_SCLK_reg}] -rise_to [get_clocks {LMS_FCLK1_DRCT}]  0.120  
set_clock_uncertainty -rise_from [get_clocks {FPGA_SPI0_SCLK_reg}] -fall_to [get_clocks {LMS_FCLK1_DRCT}]  0.120  
set_clock_uncertainty -rise_from [get_clocks {FPGA_SPI0_SCLK_reg}] -rise_to [get_clocks {LMK_CLK}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {FPGA_SPI0_SCLK_reg}] -fall_to [get_clocks {LMK_CLK}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {FPGA_SPI0_SCLK_reg}] -rise_to [get_clocks {FPGA_SPI0_SCLK_reg}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {FPGA_SPI0_SCLK_reg}] -fall_to [get_clocks {FPGA_SPI0_SCLK_reg}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {FPGA_SPI0_SCLK_reg}] -rise_to [get_clocks {LMS_FCLK1_PLL}] -setup 0.140  
set_clock_uncertainty -fall_from [get_clocks {FPGA_SPI0_SCLK_reg}] -rise_to [get_clocks {LMS_FCLK1_PLL}] -hold 0.150  
set_clock_uncertainty -fall_from [get_clocks {FPGA_SPI0_SCLK_reg}] -fall_to [get_clocks {LMS_FCLK1_PLL}] -setup 0.140  
set_clock_uncertainty -fall_from [get_clocks {FPGA_SPI0_SCLK_reg}] -fall_to [get_clocks {LMS_FCLK1_PLL}] -hold 0.150  
set_clock_uncertainty -fall_from [get_clocks {FPGA_SPI0_SCLK_reg}] -rise_to [get_clocks {LMS_FCLK1_DRCT}]  0.120  
set_clock_uncertainty -fall_from [get_clocks {FPGA_SPI0_SCLK_reg}] -fall_to [get_clocks {LMS_FCLK1_DRCT}]  0.120  
set_clock_uncertainty -fall_from [get_clocks {FPGA_SPI0_SCLK_reg}] -rise_to [get_clocks {LMK_CLK}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {FPGA_SPI0_SCLK_reg}] -fall_to [get_clocks {LMK_CLK}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {FPGA_SPI0_SCLK_reg}] -rise_to [get_clocks {FPGA_SPI0_SCLK_reg}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {FPGA_SPI0_SCLK_reg}] -fall_to [get_clocks {FPGA_SPI0_SCLK_reg}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {FPGA_SPI0_SCLK_out}] -rise_to [get_clocks {FPGA_SPI0_SCLK_reg}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {FPGA_SPI0_SCLK_out}] -fall_to [get_clocks {FPGA_SPI0_SCLK_reg}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {FPGA_SPI0_SCLK_out}] -rise_to [get_clocks {FPGA_SPI0_SCLK_reg}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {FPGA_SPI0_SCLK_out}] -fall_to [get_clocks {FPGA_SPI0_SCLK_reg}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {FPGA_SPI1_SCLK}] -rise_to [get_clocks {CLK100_FPGA}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {FPGA_SPI1_SCLK}] -fall_to [get_clocks {CLK100_FPGA}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {FPGA_SPI1_SCLK}] -rise_to [get_clocks {FPGA_SPI1_SCLK}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {FPGA_SPI1_SCLK}] -fall_to [get_clocks {FPGA_SPI1_SCLK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {FPGA_SPI1_SCLK}] -rise_to [get_clocks {CLK100_FPGA}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {FPGA_SPI1_SCLK}] -fall_to [get_clocks {CLK100_FPGA}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {FPGA_SPI1_SCLK}] -rise_to [get_clocks {FPGA_SPI1_SCLK}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {FPGA_SPI1_SCLK}] -fall_to [get_clocks {FPGA_SPI1_SCLK}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay -max -clock_fall -clock [get_clocks {FPGA_SPI0_SCLK_out}]  19.000 [get_ports {FPGA_SPI0_MISO}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {FPGA_SPI0_SCLK_out}]  16.200 [get_ports {FPGA_SPI0_MISO}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[0]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[0]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[0]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[0]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[0]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[0]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[0]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[0]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[1]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[1]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[1]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[1]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[1]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[1]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[1]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[1]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[2]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[2]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[2]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[2]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[2]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[2]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[2]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[2]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[3]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[3]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[3]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[3]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[3]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[3]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[3]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[3]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[4]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[4]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[4]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[4]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[4]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[4]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[4]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[4]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[5]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[5]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[5]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[5]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[5]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[5]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[5]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[5]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[6]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[6]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[6]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[6]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[6]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[6]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[6]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[6]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[7]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[7]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[7]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[7]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[7]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[7]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[7]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[7]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[8]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[8]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[8]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[8]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[8]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[8]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[8]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[8]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[9]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[9]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[9]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[9]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[9]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[9]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[9]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[9]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[10]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[10]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[10]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[10]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[10]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[10]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[10]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[10]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[11]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[11]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_D[11]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_D[11]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[11]}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[11]}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_D[11]}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_D[11]}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_IQSEL2}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_IQSEL2}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  4.250 [get_ports {LMS_DIQ2_IQSEL2}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT}]  2.000 [get_ports {LMS_DIQ2_IQSEL2}]
set_input_delay -add_delay -max -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_IQSEL2}]
set_input_delay -add_delay -min -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_IQSEL2}]
set_input_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  4.250 [get_ports {LMS_DIQ2_IQSEL2}]
set_input_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_MCLK2_VIRT_5MHz}]  2.000 [get_ports {LMS_DIQ2_IQSEL2}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {altera_reserved_tck}]  0.100 [get_ports {altera_reserved_tdi}]
set_input_delay -add_delay  -clock_fall -clock [get_clocks {altera_reserved_tck}]  0.100 [get_ports {altera_reserved_tms}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay -max -clock [get_clocks {FPGA_SPI0_SCLK_out}]  15.000 [get_ports {FPGA_SPI0_MOSI}]
set_output_delay -add_delay -min -clock [get_clocks {FPGA_SPI0_SCLK_out}]  -15.000 [get_ports {FPGA_SPI0_MOSI}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[0]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[0]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[0]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[0]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[0]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[0]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[0]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[0]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[1]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[1]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[1]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[1]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[1]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[1]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[1]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[1]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[2]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[2]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[2]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[2]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[2]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[2]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[2]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[2]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[3]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[3]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[3]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[3]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[3]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[3]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[3]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[3]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[4]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[4]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[4]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[4]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[4]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[4]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[4]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[4]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[5]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[5]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[5]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[5]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[5]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[5]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[5]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[5]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[6]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[6]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[6]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[6]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[6]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[6]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[6]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[6]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[7]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[7]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[7]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[7]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[7]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[7]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[7]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[7]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[8]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[8]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[8]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[8]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[8]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[8]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[8]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[8]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[9]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[9]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[9]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[9]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[9]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[9]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[9]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[9]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[10]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[10]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[10]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[10]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[10]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[10]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[10]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[10]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[11]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[11]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_D[11]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_D[11]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[11]}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[11]}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_D[11]}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_D[11]}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_IQSEL}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_IQSEL}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  1.500 [get_ports {LMS_DIQ1_IQSEL}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_PLL}]  -2.400 [get_ports {LMS_DIQ1_IQSEL}]
set_output_delay -add_delay -max -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_IQSEL}]
set_output_delay -add_delay -min -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_IQSEL}]
set_output_delay -add_delay -max -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  1.500 [get_ports {LMS_DIQ1_IQSEL}]
set_output_delay -add_delay -min -clock_fall -clock [get_clocks {LMS_FCLK1_DRCT}]  -2.400 [get_ports {LMS_DIQ1_IQSEL}]
set_output_delay -add_delay  -clock_fall -clock [get_clocks {altera_reserved_tck}]  0.100 [get_ports {altera_reserved_tdo}]


#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -exclusive -group [get_clocks {LMS_FCLK1_PLL}] -group [get_clocks {LMS_FCLK1_DRCT}] 
set_clock_groups -exclusive -group [get_clocks {LMS_MCLK1}] -group [get_clocks {LMS_MCLK1_5MHZ}] 
set_clock_groups -exclusive -group [get_clocks {LMS_MCLK2 LMS_MCLK2_VIRT}] -group [get_clocks {LMS_MCLK2_5MHZ LMS_MCLK2_VIRT_5MHz}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {CLK50_FPGA}] -group [get_clocks {CLK100_FPGA}] -group [get_clocks {CLK125_FPGA}] -group [get_clocks {LMK_CLK FPGA_SPI0_SCLK_reg FPGA_SPI0_SCLK_out }] -group [get_clocks {PCIE_REFCLK *|pcie|wrapper|altpcie_hip_pipen1b_inst|cyclone_iii.cycloneiv_hssi_pcie_hip|coreclkou}] -group [get_clocks {LMS_MCLK1}] -group [get_clocks {LMS_MCLK1_5MHZ}] -group [get_clocks {TX_PLLCLK_C0}] -group [get_clocks {TX_PLLCLK_C1}] -group [get_clocks {LMS_MCLK2}] -group [get_clocks {LMS_MCLK2_5MHZ}] -group [get_clocks {RX_PLLCLK_C0}] -group [get_clocks {RX_PLLCLK_C1}] -group [get_clocks {SI_CLK0}] -group [get_clocks {SI_CLK1}] -group [get_clocks {SI_CLK2}] -group [get_clocks {SI_CLK3}] -group [get_clocks {SI_CLK5}] -group [get_clocks {SI_CLK6}] -group [get_clocks {SI_CLK7}] -group [get_clocks {*|ddr2_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|pll1|clk[1]}] 


#**************************************************************
# Set False Path
#**************************************************************

set_false_path -setup -rise_from  [get_clocks {LMS_MCLK2_VIRT}]  -rise_to  [get_clocks {RX_PLLCLK_C1}]
set_false_path -setup -fall_from  [get_clocks {LMS_MCLK2_VIRT}]  -fall_to  [get_clocks {RX_PLLCLK_C1}]
set_false_path -hold -rise_from  [get_clocks {LMS_MCLK2_VIRT}]  -rise_to  [get_clocks {RX_PLLCLK_C1}]
set_false_path -hold -fall_from  [get_clocks {LMS_MCLK2_VIRT}]  -fall_to  [get_clocks {RX_PLLCLK_C1}]
set_false_path -setup -rise_from  [get_clocks {LMS_MCLK2_VIRT_5MHz}]  -rise_to  [get_clocks {LMS_MCLK2_5MHZ}]
set_false_path -setup -fall_from  [get_clocks {LMS_MCLK2_VIRT_5MHz}]  -fall_to  [get_clocks {LMS_MCLK2_5MHZ}]
set_false_path -hold -rise_from  [get_clocks {LMS_MCLK2_VIRT_5MHz}]  -rise_to  [get_clocks {LMS_MCLK2_5MHZ}]
set_false_path -hold -fall_from  [get_clocks {LMS_MCLK2_VIRT_5MHz}]  -fall_to  [get_clocks {LMS_MCLK2_5MHZ}]
set_false_path -setup -rise_from  [get_clocks {TX_PLLCLK_C1}]  -fall_to  [get_clocks {LMS_FCLK1_PLL}]
set_false_path -setup -fall_from  [get_clocks {TX_PLLCLK_C1}]  -rise_to  [get_clocks {LMS_FCLK1_PLL}]
set_false_path -hold -rise_from  [get_clocks {TX_PLLCLK_C1}]  -fall_to  [get_clocks {LMS_FCLK1_PLL}]
set_false_path -hold -fall_from  [get_clocks {TX_PLLCLK_C1}]  -rise_to  [get_clocks {LMS_FCLK1_PLL}]
set_false_path -setup -rise_from  [get_clocks {LMS_MCLK1_5MHZ}]  -fall_to  [get_clocks {LMS_FCLK1_DRCT}]
set_false_path -setup -fall_from  [get_clocks {LMS_MCLK1_5MHZ}]  -rise_to  [get_clocks {LMS_FCLK1_DRCT}]
set_false_path -hold -rise_from  [get_clocks {LMS_MCLK1_5MHZ}]  -fall_to  [get_clocks {LMS_FCLK1_DRCT}]
set_false_path -hold -fall_from  [get_clocks {LMS_MCLK1_5MHZ}]  -rise_to  [get_clocks {LMS_FCLK1_DRCT}]
set_false_path  -from  [get_clocks {LMS_MCLK2_VIRT}]  -to  [get_clocks {LMS_MCLK2}]
set_false_path  -from  [get_clocks {LMS_MCLK1}]  -to  [get_clocks {LMS_FCLK1_PLL}]
set_false_path  -from  [get_clocks {LMS_MCLK1}]  -to  [get_clocks {LMS_FCLK1_DRCT}]
set_false_path  -from  [get_clocks {TX_PLLCLK_C1}]  -to  [get_clocks {LMS_FCLK1_DRCT}]
set_false_path  -from  [get_clocks {LMS_MCLK1_5MHZ}]  -to  [get_clocks {LMS_FCLK1_PLL}]
set_false_path  -from  [get_clocks {LMS_MCLK2_VIRT_5MHz}]  -to  [get_clocks {RX_PLLCLK_C1}]
set_false_path  -from  [get_clocks {LMS_MCLK2}]  -to  [get_clocks {LMS_MCLK2}]
set_false_path  -from  [get_clocks {LMS_MCLK1}]  -to  [get_clocks {LMS_MCLK1}]
set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_re9:dffpipe16|dffe17a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_qe9:dffpipe13|dffe14a*}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_hd9:dffpipe17|dffe18a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_gd9:dffpipe14|dffe15a*}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_qd9:dffpipe13|dffe14a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_pd9:dffpipe10|dffe11a*}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_kd9:dffpipe16|dffe17a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_jd9:dffpipe13|dffe14a*}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_md9:dffpipe12|dffe13a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_ld9:dffpipe9|dffe10a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_nd9:dffpipe6|dffe7a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_bd9:dffpipe11|dffe12a*}]
set_false_path -from [get_keepers {**}] -to [get_keepers {*phasedone_state*}]
set_false_path -from [get_keepers {**}] -to [get_keepers {*internal_phasestep*}]
set_false_path -to [get_ports {LMS_FCLK*}]
set_false_path -to [get_ports {FPGA_SPI0_SCLK}]
set_false_path -to [get_ports {FPGA_LED*}]
set_false_path -to [get_ports {FPGA_GPIO[*]}]
set_false_path -to [get_ports {LMS_CORE_LDO_EN}]
set_false_path -to [get_ports {LMS_RXEN}]
set_false_path -to [get_ports {LMS_TXEN}]
set_false_path -to [get_ports {LMS_TXNRX1}]
set_false_path -to [get_ports {LMS_TXNRX2}]
set_false_path -to [get_ports {LMS_RESET}]
set_false_path -to [get_ports {TX2_2_LB*}]
set_false_path -to [get_ports {TX1_2_LB*}]
set_false_path -to [get_ports {FPGA_I2C_SCL}]
set_false_path -to [get_ports {FPGA_I2C_SDA}]
set_false_path -to [get_ports {FPGA_AS_*}]
set_false_path -to [get_ports {FPGA_SPI1_*}]
set_false_path -to [get_ports {FPGA_SPI0_LMS_SS}]
set_false_path -to [get_ports {FAN_CTRL}]
set_false_path -from [get_ports {EXT_GND*}] 
set_false_path -from [get_ports {HW_VER*}] 
set_false_path -from [get_ports {BOM_VER*}] 
set_false_path -from [get_ports {ADF_MUXOUT*}] 
set_false_path -from [get_ports {FPGA_I2C_SCL}] 
set_false_path -from [get_ports {FPGA_I2C_SDA}] 
set_false_path -from [get_ports {LM75_OS}] 
set_false_path -from [get_ports {FPGA_SW[*]}] 
set_false_path -from [get_ports {FPGA_AS_DATA0}] 
set_false_path -from [get_ports {PCIE_PERSTn}] 
set_false_path -from [get_ports {FPGA_GPIO[*]}] 
set_false_path -to [get_keepers {*sync_reg[0]*}]
set_false_path -to [get_keepers {*sync_reg0[*]*}]
set_false_path -from [get_keepers {*singl_clk_with_ref_test*|*cnt_clk0[*]}] 
set_false_path -to [get_ports {LMS_FCLK1}]
set_false_path -to [get_ports {LMS_FCLK2}]
set_false_path -to [get_pins -nocase -compatibility_mode {*|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain*|clrn}]
set_false_path -from [get_keepers {*lms_ctr_nios2_cpu_cpu:*|lms_ctr_nios2_cpu_cpu_nios2_oci:the_lms_ctr_nios2_cpu_cpu_nios2_oci|lms_ctr_nios2_cpu_cpu_nios2_oci_break:the_lms_ctr_nios2_cpu_cpu_nios2_oci_break|break_readreg*}] -to [get_keepers {*lms_ctr_nios2_cpu_cpu:*|lms_ctr_nios2_cpu_cpu_nios2_oci:the_lms_ctr_nios2_cpu_cpu_nios2_oci|lms_ctr_nios2_cpu_cpu_debug_slave_wrapper:the_lms_ctr_nios2_cpu_cpu_debug_slave_wrapper|lms_ctr_nios2_cpu_cpu_debug_slave_tck:the_lms_ctr_nios2_cpu_cpu_debug_slave_tck|*sr*}]
set_false_path -from [get_keepers {*lms_ctr_nios2_cpu_cpu:*|lms_ctr_nios2_cpu_cpu_nios2_oci:the_lms_ctr_nios2_cpu_cpu_nios2_oci|lms_ctr_nios2_cpu_cpu_nios2_oci_debug:the_lms_ctr_nios2_cpu_cpu_nios2_oci_debug|*resetlatch}] -to [get_keepers {*lms_ctr_nios2_cpu_cpu:*|lms_ctr_nios2_cpu_cpu_nios2_oci:the_lms_ctr_nios2_cpu_cpu_nios2_oci|lms_ctr_nios2_cpu_cpu_debug_slave_wrapper:the_lms_ctr_nios2_cpu_cpu_debug_slave_wrapper|lms_ctr_nios2_cpu_cpu_debug_slave_tck:the_lms_ctr_nios2_cpu_cpu_debug_slave_tck|*sr[33]}]
set_false_path -from [get_keepers {*lms_ctr_nios2_cpu_cpu:*|lms_ctr_nios2_cpu_cpu_nios2_oci:the_lms_ctr_nios2_cpu_cpu_nios2_oci|lms_ctr_nios2_cpu_cpu_nios2_oci_debug:the_lms_ctr_nios2_cpu_cpu_nios2_oci_debug|monitor_ready}] -to [get_keepers {*lms_ctr_nios2_cpu_cpu:*|lms_ctr_nios2_cpu_cpu_nios2_oci:the_lms_ctr_nios2_cpu_cpu_nios2_oci|lms_ctr_nios2_cpu_cpu_debug_slave_wrapper:the_lms_ctr_nios2_cpu_cpu_debug_slave_wrapper|lms_ctr_nios2_cpu_cpu_debug_slave_tck:the_lms_ctr_nios2_cpu_cpu_debug_slave_tck|*sr[0]}]
set_false_path -from [get_keepers {*lms_ctr_nios2_cpu_cpu:*|lms_ctr_nios2_cpu_cpu_nios2_oci:the_lms_ctr_nios2_cpu_cpu_nios2_oci|lms_ctr_nios2_cpu_cpu_nios2_oci_debug:the_lms_ctr_nios2_cpu_cpu_nios2_oci_debug|monitor_error}] -to [get_keepers {*lms_ctr_nios2_cpu_cpu:*|lms_ctr_nios2_cpu_cpu_nios2_oci:the_lms_ctr_nios2_cpu_cpu_nios2_oci|lms_ctr_nios2_cpu_cpu_debug_slave_wrapper:the_lms_ctr_nios2_cpu_cpu_debug_slave_wrapper|lms_ctr_nios2_cpu_cpu_debug_slave_tck:the_lms_ctr_nios2_cpu_cpu_debug_slave_tck|*sr[34]}]
set_false_path -from [get_keepers {*lms_ctr_nios2_cpu_cpu:*|lms_ctr_nios2_cpu_cpu_nios2_oci:the_lms_ctr_nios2_cpu_cpu_nios2_oci|lms_ctr_nios2_cpu_cpu_nios2_ocimem:the_lms_ctr_nios2_cpu_cpu_nios2_ocimem|*MonDReg*}] -to [get_keepers {*lms_ctr_nios2_cpu_cpu:*|lms_ctr_nios2_cpu_cpu_nios2_oci:the_lms_ctr_nios2_cpu_cpu_nios2_oci|lms_ctr_nios2_cpu_cpu_debug_slave_wrapper:the_lms_ctr_nios2_cpu_cpu_debug_slave_wrapper|lms_ctr_nios2_cpu_cpu_debug_slave_tck:the_lms_ctr_nios2_cpu_cpu_debug_slave_tck|*sr*}]
set_false_path -from [get_keepers {*lms_ctr_nios2_cpu_cpu:*|lms_ctr_nios2_cpu_cpu_nios2_oci:the_lms_ctr_nios2_cpu_cpu_nios2_oci|lms_ctr_nios2_cpu_cpu_debug_slave_wrapper:the_lms_ctr_nios2_cpu_cpu_debug_slave_wrapper|lms_ctr_nios2_cpu_cpu_debug_slave_tck:the_lms_ctr_nios2_cpu_cpu_debug_slave_tck|*sr*}] -to [get_keepers {*lms_ctr_nios2_cpu_cpu:*|lms_ctr_nios2_cpu_cpu_nios2_oci:the_lms_ctr_nios2_cpu_cpu_nios2_oci|lms_ctr_nios2_cpu_cpu_debug_slave_wrapper:the_lms_ctr_nios2_cpu_cpu_debug_slave_wrapper|lms_ctr_nios2_cpu_cpu_debug_slave_sysclk:the_lms_ctr_nios2_cpu_cpu_debug_slave_sysclk|*jdo*}]
set_false_path -from [get_keepers {sld_hub:*|irf_reg*}] -to [get_keepers {*lms_ctr_nios2_cpu_cpu:*|lms_ctr_nios2_cpu_cpu_nios2_oci:the_lms_ctr_nios2_cpu_cpu_nios2_oci|lms_ctr_nios2_cpu_cpu_debug_slave_wrapper:the_lms_ctr_nios2_cpu_cpu_debug_slave_wrapper|lms_ctr_nios2_cpu_cpu_debug_slave_sysclk:the_lms_ctr_nios2_cpu_cpu_debug_slave_sysclk|ir*}]
set_false_path -from [get_keepers {sld_hub:*|sld_shadow_jsm:shadow_jsm|state[1]}] -to [get_keepers {*lms_ctr_nios2_cpu_cpu:*|lms_ctr_nios2_cpu_cpu_nios2_oci:the_lms_ctr_nios2_cpu_cpu_nios2_oci|lms_ctr_nios2_cpu_cpu_nios2_oci_debug:the_lms_ctr_nios2_cpu_cpu_nios2_oci_debug|monitor_go}]


#**************************************************************
# Set Multicycle Path
#**************************************************************

set_multicycle_path -hold -end -from  [get_clocks {CLK100_FPGA_VIRT}]  -to  [get_clocks {CLK100_FPGA}] 1
set_multicycle_path -setup -end -from  [get_clocks {FPGA_SPI0_SCLK_out}]  -to  [get_clocks {CLK100_FPGA}] 3
set_multicycle_path -hold -end -from  [get_clocks {FPGA_SPI0_SCLK_out}]  -to  [get_clocks {CLK100_FPGA}] 5
set_multicycle_path -setup -start -from  [get_clocks {CLK100_FPGA}]  -to  [get_clocks {FPGA_SPI0_SCLK_out}] 3
set_multicycle_path -hold -start -from  [get_clocks {CLK100_FPGA}]  -to  [get_clocks {FPGA_SPI0_SCLK_out}] 5


#**************************************************************
# Set Maximum Delay
#**************************************************************

set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pcs2~OBSERVABLEQUADRESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pcs2~OBSERVABLE_DIGITAL_RESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pcs1~OBSERVABLEQUADRESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pcs1~OBSERVABLE_DIGITAL_RESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pcs0~OBSERVABLEQUADRESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pcs0~OBSERVABLE_DIGITAL_RESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|cent_unit0~OBSERVABLEDPRIORESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|cent_unit0~OBSERVABLEDPRIOLOAD }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|cent_unit0~OBSERVABLEDPRIODISABLE }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|cent_unit0~OBSERVABLERXDIGITALRESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|cent_unit0~OBSERVABLETXDIGITALRESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|cent_unit0~OBSERVABLERXANALOGRESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pcs3~OBSERVABLEQUADRESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pcs3~OBSERVABLE_DIGITAL_RESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pcs0~OBSERVABLEQUADRESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pcs0~OBSERVABLE_DIGITAL_RESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pcs1~OBSERVABLEQUADRESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pcs1~OBSERVABLE_DIGITAL_RESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pcs2~OBSERVABLEQUADRESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pcs2~OBSERVABLE_DIGITAL_RESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pcs3~OBSERVABLEQUADRESET }] 20.000
set_max_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pcs3~OBSERVABLE_DIGITAL_RESET }] 20.000


#**************************************************************
# Set Minimum Delay
#**************************************************************

set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pcs2~OBSERVABLEQUADRESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pcs2~OBSERVABLE_DIGITAL_RESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pcs1~OBSERVABLEQUADRESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pcs1~OBSERVABLE_DIGITAL_RESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pcs0~OBSERVABLEQUADRESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pcs0~OBSERVABLE_DIGITAL_RESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|cent_unit0~OBSERVABLEDPRIORESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|cent_unit0~OBSERVABLEDPRIOLOAD }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|cent_unit0~OBSERVABLEDPRIODISABLE }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|cent_unit0~OBSERVABLERXDIGITALRESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|cent_unit0~OBSERVABLETXDIGITALRESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|cent_unit0~OBSERVABLERXANALOGRESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pcs3~OBSERVABLEQUADRESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|receive_pcs3~OBSERVABLE_DIGITAL_RESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pcs0~OBSERVABLEQUADRESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pcs0~OBSERVABLE_DIGITAL_RESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pcs1~OBSERVABLEQUADRESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pcs1~OBSERVABLE_DIGITAL_RESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pcs2~OBSERVABLEQUADRESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pcs2~OBSERVABLE_DIGITAL_RESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pcs3~OBSERVABLEQUADRESET }] 0.000
set_min_delay -to [get_ports { pcie_top:inst2_pcie_top|litepcie_top:inst1_litepcie_top|litepcie_core:inst0_litepcie_core|pcie_phy_top:pcie_phy_top|pcie_phy:comp_pcie_phy|pcie_phy_serdes:serdes|pcie_phy_serdes_alt_c3gxb_jse8:pcie_phy_serdes_alt_c3gxb_jse8_component|transmit_pcs3~OBSERVABLE_DIGITAL_RESET }] 0.000


#**************************************************************
# Set Input Transition
#**************************************************************

