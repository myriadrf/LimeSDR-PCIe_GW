#**************************************************************
# Time Information
#**************************************************************
set_time_format -unit ns -decimal_places 3
#=======================Timing parameters===================================
#LMS7002
	#LMS_MCLK2 period
set MCLK2_period	5
set MCLK1_period	5
	#Setup and hold times from datasheet
set LMS7_Tsu	1.5
set LMS7_Th		.2
	#Calculated expresions
set LMS7_max_dly [expr $MCLK2_period/4 - $LMS7_Tsu]
set LMS7_min_dly [expr $LMS7_Th - $MCLK2_period/4]

#=======================Base clocks=====================================
#FPGA pll
create_clock -period "50MHz" 	-name CLK50_FPGA_2 	[get_ports CLK50_FPGA_2]
create_clock -period "50MHz" 	-name CLK50_FPGA_1 	[get_ports CLK50_FPGA_1]
create_clock -period "100MHZ" -name CLK100_FPGA		[get_ports CLK100_FPGA]
#TX pll
create_clock -period $MCLK1_period 		-name LMS_MCLK1 				[get_ports LMS_MCLK1]
#RX pll
create_clock -period $MCLK2_period 		-name LMS_MCLK2				[get_ports LMS_MCLK2]
#PCIE clock
create_clock -name "PCIE_REFCLK" -period 10.000ns [get_ports {pcie_refclk}]

#======================Virtual clocks============================================
#specialy for derive uncertainty command
#TX pll
create_clock -name LMS_LAUNCH_CLK	-period $MCLK2_period
#======================Generated clocks==========================================
create_generated_clock -name LMS_FCLK2 \
								-source [get_pins inst18|inst35|altpll_component|auto_generated|pll1|inclk[0]] \
								-phase 0 [get_pins inst18|inst35|altpll_component|auto_generated|pll1|clk[0]]
create_generated_clock -name LMS_LATCH_CLK \
								-source [get_pins inst18|inst35|altpll_component|auto_generated|pll1|inclk[0]] \
								-phase 90 [get_pins inst18|inst35|altpll_component|auto_generated|pll1|clk[1]]
#======================Set Input Delay==========================================
#LMS7
set_input_delay	-max $LMS7_max_dly \
						-clock [get_clocks LMS_LAUNCH_CLK] [get_ports {LMS_DIQ2*}]
						
set_input_delay	-max $LMS7_max_dly \
						-clock [get_clocks LMS_LAUNCH_CLK] \
						-clock_fall [get_ports {LMS_DIQ2*}] -add_delay
						
set_input_delay	-min $LMS7_min_dly \
						-clock [get_clocks LMS_LAUNCH_CLK] [get_ports {LMS_DIQ2*}] -add_delay
						
set_input_delay	-min $LMS7_min_dly \
						-clock [get_clocks LMS_LAUNCH_CLK] \
						-clock_fall [get_ports {LMS_DIQ2*}] -add_delay								
##====================Other clock constraints====================================
derive_pll_clocks 
derive_clock_uncertainty

# Set clkA and clkB to be mutually exclusive clocks.
set_clock_groups -exclusive -group [get_clocks {CLK50_FPGA_1}] \
									-group [get_clocks {CLK50_FPGA_2}] \
										-group [get_clocks {LMS_MCLK1}] \
										-group [get_clocks {LMS_MCLK2}]

#set false paths
# LED's
set_false_path -from * -to [get_ports FPGA_LED* ]
set_false_path -from * -to [get_ports FPGA_GPIO*]
set_false_path -from [get_ports EXT_GND*] -to *