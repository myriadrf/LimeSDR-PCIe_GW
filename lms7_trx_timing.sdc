#=======================Base clocks=====================================
#FPGA pll
create_clock -period "50MHz" 	-name CLK50_FPGA_2 	[get_ports CLK50_FPGA_2]
create_clock -period "50MHz" 	-name CLK50_FPGA_1 	[get_ports CLK50_FPGA_1]
create_clock -period "100MHZ" -name CLK100_FPGA		[get_ports CLK100_FPGA]
#TX pll
create_clock -period "17.5MHz" -name MCLK1TX 		[get_ports LMS_MCLK1]
#RX pll
create_clock -period "160MHz" -name MCLK2RX			[get_ports LMS_MCLK2]
#PCIE clock
create_clock -name "PCIE_REFCLK" -period 10.000ns [get_ports {pcie_refclk}]

#======================Virtual clocks============================================
#specialy for derive uncertainty command
#TX pll

##RX pll
#create_clock -period "160MHz" 		-name MCLK2RX_virt
#
#
##FX3 spci clock
#create_clock -period "1MHz" 			-name FX3_SPI_SCK_virt
##====================Other clock constraints====================================
derive_pll_clocks 
derive_clock_uncertainty

#
#set_clock_groups -asynchronous 	-group {MCLK1TX} \
#											-group {MCLK2RX} \
#											-group {CLK50_FPGA_2} \
#											-group {CLK50_FPGA_1} \
#											-group {CLK100_FPGA} 
#
#
#set_false_path -setup -rise_from {MCLK2RX_virt} -rise_to {inst18|altpll_component|auto_generated|pll1|clk[1]}
#set_false_path -setup -fall_from {MCLK2RX_virt} -fall_to {inst18|altpll_component|auto_generated|pll1|clk[1]}
#set_false_path -hold -rise_from {MCLK2RX_virt} -fall_to {inst18|altpll_component|auto_generated|pll1|clk[1]}
#set_false_path -hold -fall_from {MCLK2RX_virt} -rise_to {inst18|altpll_component|auto_generated|pll1|clk[1]}

#set false paths
# LED's
set_false_path -from * -to [get_ports FPGA_LED* ]
set_false_path -from * -to [get_ports FPGA_GPIO*]
set_false_path -from [get_ports EXT_GND*] -to *