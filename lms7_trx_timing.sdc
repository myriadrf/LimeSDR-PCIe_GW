# ----------------------------------------------------------------------------
# FILE: 	Clock_groups.vhd
# DESCRIPTION:	Clock group assigments for TimeQuest
# DATE:	June 2, 2017
# AUTHOR(s):	Lime Microsystems
# REVISIONS:
# ----------------------------------------------------------------------------
# NOTES:
# 
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
#Timing parameters
# ----------------------------------------------------------------------------
set_time_format -unit ns -decimal_places 3


# ----------------------------------------------------------------------------
#Base clocks
# ----------------------------------------------------------------------------
#FPGA pll
create_clock -period 20.000 	-name CLK50_FPGA 	   [get_ports CLK50_FPGA]
create_clock -period 10.000 	-name CLK100_FPGA		[get_ports CLK100_FPGA]
create_clock -period  8.000 	-name CLK125_FPGA 	[get_ports CLK125_FPGA]

#Si5351C clocks
create_clock -period 37.037 	-name SI_CLK0			[get_ports SI_CLK0]
create_clock -period 37.037 	-name SI_CLK1			[get_ports SI_CLK1]
create_clock -period 37.037 	-name SI_CLK2			[get_ports SI_CLK2]
create_clock -period 37.037 	-name SI_CLK3			[get_ports SI_CLK3]
create_clock -period 37.037 	-name SI_CLK5			[get_ports SI_CLK5]
create_clock -period 37.037 	-name SI_CLK6			[get_ports SI_CLK6]
create_clock -period 37.037 	-name SI_CLK7			[get_ports SI_CLK7]
#LMK clk
create_clock -period 32.552 	-name LMK_CLK			[get_ports LMK_CLK]
#PCIE clock
create_clock -period 10.000 	-name "PCIE_REFCLK"  [get_ports {pcie_refclk}]

# ----------------------------------------------------------------------------
#Virtual clocks
# ----------------------------------------------------------------------------
create_clock -period 10.000	-name CLK100_FPGA_VIRT 

# ----------------------------------------------------------------------------
#Generated clocks
# ----------------------------------------------------------------------------

#NIOS spi
create_generated_clock 	-name FPGA_SPI0_SCLK_reg \
								-source [get_ports {CLK100_FPGA}] \
								-divide_by 6 \
								[get_registers {*|lms_ctr_spi_lms:spi_lms|SCLK_reg}]
								
create_generated_clock 	-name FPGA_SPI0_SCLK_out \
								-source [get_registers {*|lms_ctr_spi_lms:spi_lms|SCLK_reg}] \
								[get_ports FPGA_SPI0_SCLK]
								
set_false_path				-to [get_ports FPGA_SPI0_SCLK]
								
create_generated_clock -name FPGA_SPI1_SCLK \
								-source [get_ports CLK100_FPGA] \
								-divide_by 6 \
								[get_registers *|lms_ctr_spi_1:spi_1|SCLK_reg]	
								
							
					
# ----------------------------------------------------------------------------
#Other clock constraints
# ----------------------------------------------------------------------------							
derive_clock_uncertainty
derive_pll_clocks

# ----------------------------------------------------------------------------
#Input constraints
# ----------------------------------------------------------------------------

#NIOS SPI0
#To overcontrain inputs setup time only for fitter by 10%
if {$::quartus(nameofexecutable) ne "quartus_sta"} {
	set_input_delay -clock [get_clocks FPGA_SPI0_SCLK_out] -max 20.9 [get_ports {FPGA_SPI0_MISO}] -clock_fall
	set_input_delay -clock [get_clocks FPGA_SPI0_SCLK_out] -min 16.2 [get_ports {FPGA_SPI0_MISO}] -clock_fall
} else {
	set_input_delay -clock [get_clocks FPGA_SPI0_SCLK_out] -max 19.0 [get_ports {FPGA_SPI0_MISO}] -clock_fall
	set_input_delay -clock [get_clocks FPGA_SPI0_SCLK_out] -min 16.2 [get_ports {FPGA_SPI0_MISO}] -clock_fall
}


# ----------------------------------------------------------------------------
#Output constraints
# ----------------------------------------------------------------------------
#NIOS SPI				
set_output_delay -clock [get_clocks FPGA_SPI0_SCLK_out] -max 15 [get_ports {FPGA_SPI0_MOSI}] 
set_output_delay -clock [get_clocks FPGA_SPI0_SCLK_out] -min -15 [get_ports {FPGA_SPI0_MOSI}]	

#set_multicycle_path -setup -from [get_clocks FX3_PCLK_VIRT ] -to [get_clocks FX3_PCLK] 2
set_multicycle_path -hold -from [get_clocks CLK100_FPGA_VIRT ] -to [get_clocks CLK100_FPGA] 1

# ----------------------------------------------------------------------------
#NIOS constraints
# ----------------------------------------------------------------------------
# JTAG Signal Constraints constrain the TCK port											
create_clock -period 10MHz {altera_reserved_tck}
# Cut all paths to and from tck
set_clock_groups -asynchronous -group {altera_reserved_tck}											
# Constrain the TDI port
set_input_delay -clock altera_reserved_tck -clock_fall .1 [get_ports altera_reserved_tdi]
# Constrain the TMS port
set_input_delay -clock altera_reserved_tck -clock_fall .1 [get_ports altera_reserved_tms]
# Constrain the TDO port
set_output_delay -clock altera_reserved_tck -clock_fall .1 [get_ports altera_reserved_tdo]	

# ----------------------------------------------------------------------------
#Timing exceptions
# ----------------------------------------------------------------------------
	
#Multicycle paths for NIOS SPI
set_multicycle_path -setup -end -from [get_clocks {FPGA_SPI0_SCLK_out}] -to [get_clocks {CLK100_FPGA}] [expr 3]
set_multicycle_path -hold -end -from [get_clocks {FPGA_SPI0_SCLK_out}] -to [get_clocks {CLK100_FPGA}] [expr 5]

set_multicycle_path -setup -start -from [get_clocks CLK100_FPGA] -to [get_clocks FPGA_SPI0_SCLK_out] 3
set_multicycle_path -hold -start -from [get_clocks CLK100_FPGA] -to [get_clocks FPGA_SPI0_SCLK_out] 5		

#set false paths
# For slow speed outputs (Outputs that we dont care about)
set_false_path -to [get_ports FPGA_LED* ]
set_false_path -to [get_ports FPGA_GPIO[*]]
set_false_path -to [get_ports LMS_CORE_LDO_EN]
set_false_path -to [get_ports LMS_RXEN]
set_false_path -to [get_ports LMS_TXEN]
set_false_path -to [get_ports LMS_TXNRX1]
set_false_path -to [get_ports LMS_TXNRX2]
set_false_path -to [get_ports LMS_RESET]
set_false_path -to [get_ports TX2_2_LB*]
set_false_path -to [get_ports TX1_2_LB*]
set_false_path -to [get_ports FPGA_I2C_SCL] 	
set_false_path -to [get_ports FPGA_I2C_SDA]
set_false_path -to [get_ports FPGA_AS_*]
set_false_path -to [get_ports FPGA_SPI1_*]
set_false_path -to [get_ports FPGA_SPI0_LMS_SS]
set_false_path -to [get_ports FAN_CTRL]

#For slow speed inputs (Input that we dont care about)
set_false_path -from [get_ports EXT_GND*]
set_false_path -from [get_ports HW_VER*]
set_false_path -from [get_ports BOM_VER*] 		
set_false_path -from [get_ports ADF_MUXOUT*] 					
set_false_path -from [get_ports FPGA_I2C_SCL] 	
set_false_path -from [get_ports FPGA_I2C_SDA]
set_false_path -from [get_ports LM75_OS]
set_false_path -from [get_ports FPGA_SW[*]]
set_false_path -from [get_ports FPGA_AS_DATA0]
set_false_path -from [get_ports PCIE_PERSTn]
set_false_path -from [get_ports FPGA_GPIO[*]]

#For synchronizer chain in design (sync_reg and bus_sync_reg)
set_false_path -to [get_keepers *sync_reg[0]*]
set_false_path -to [get_keepers *sync_reg0[*]*]


set_false_path -from [get_keepers *singl_clk_with_ref_test*|*cnt_clk0[*]]


#set false paths to output clocks 
#it removes the path from the Unconstrained Paths report, but
#allows it to be used as a clock for output delay analysis
set_false_path -to [get_ports LMS_FCLK1]
set_false_path -to [get_ports LMS_FCLK2]



