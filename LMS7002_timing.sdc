################################################################################
#Timing parameters
################################################################################
#LMS7002
	#LMS_MCLK2 period
set LMS_MCLK1_period  		6.25
set LMS_MCLK2_period			6.25
	#Setup and hold times from datasheet
set LMS_LMS7_Tsu				1.00
set LMS_LMS7_Th				1.00

	#Measured Tco_min and Tco_max values
set LMS_Tco_max				4.05
set LMS_Tco_min				2.90

	#Tco based
set LMS7_IN_MAX_DELAY [expr $LMS_Tco_max]
set LMS7_IN_MIN_DELAY [expr $LMS_Tco_min]

################################################################################
#Base clocks
################################################################################

create_clock -period $LMS_MCLK1_period 			-name LMS_MCLK1			[get_ports LMS_MCLK1] 
create_clock -period $LMS_MCLK2_period 			-name LMS_MCLK2 			[get_ports LMS_MCLK2]


################################################################################
#Virtual clocks
################################################################################
create_clock -name LMS_MCLK2_VIRT			-period $LMS_MCLK2_period

################################################################################
#Generated clocks
################################################################################

#LMS TX PLL
create_generated_clock 	-name  TX_PLLCLK_C0 \
								-source [get_pins inst20|inst35|altpll_component|auto_generated|pll1|inclk[0]] \
								-phase 0 [get_pins inst20|inst35|altpll_component|auto_generated|pll1|clk[0]]
								
create_generated_clock 	-name   TX_PLLCLK_C1 \
								-source [get_pins inst20|inst35|altpll_component|auto_generated|pll1|inclk[0]] \
								-phase 90 [get_pins inst20|inst35|altpll_component|auto_generated|pll1|clk[1]]	


								
##LMS1_FCLK1 clock output pin 
#create_generated_clock -name LMS_FCLK1_PLL \
#								-master [get_clocks TX_PLLCLK_C0] \
#								-source [get_pins {inst20|inst61|ALTDDIO_OUT_component|auto_generated|ddio_outa[0]|dataout}] \
#								[get_ports LMS_FCLK1]
#LMS1_FCLK1 clock output pin 
create_generated_clock -name LMS_FCLK1_PLL \
								-source [get_pins inst20|inst35|altpll_component|auto_generated|pll1|clk[0]] \
								[get_ports LMS_FCLK1]
								

															
#LMS RX PLL
create_generated_clock -name RX_PLLCLK_C0 \
								-source [get_pins inst18|inst35|altpll_component|auto_generated|pll1|inclk[0]] \
								-phase 0 [get_pins inst18|inst35|altpll_component|auto_generated|pll1|clk[0]]
create_generated_clock -name RX_PLLCLK_C1 \
								-source [get_pins inst18|inst35|altpll_component|auto_generated|pll1|inclk[0]] \
								-phase 90 [get_pins inst18|inst35|altpll_component|auto_generated|pll1|clk[1]]
								
#LMS_FCLK2 clock 							
create_generated_clock 	-name LMS_FCLK2 \
								-source [get_pins {inst18|inst61|ALTDDIO_OUT_component|auto_generated|ddio_outa[0]|dataout}] \
								[get_ports {LMS_FCLK2}]
								
################################################################################
#Input constraints
################################################################################
#LMS1 when MCLK2 is 160MHz
set_input_delay	-max $LMS7_IN_MAX_DELAY \
						-clock [get_clocks LMS_MCLK2_VIRT] [get_ports {LMS_DIQ2_D[*] LMS_DIQ2_IQSEL2}]
						
set_input_delay	-min $LMS7_IN_MIN_DELAY \
						-clock [get_clocks LMS_MCLK2_VIRT] [get_ports {LMS_DIQ2_D[*] LMS_DIQ2_IQSEL2}]
						
set_input_delay	-max $LMS7_IN_MAX_DELAY \
						-clock [get_clocks LMS_MCLK2_VIRT] \
						-clock_fall [get_ports {LMS_DIQ2_D[*] LMS_DIQ2_IQSEL2}] -add_delay
												
set_input_delay	-min $LMS7_IN_MIN_DELAY \
						-clock [get_clocks LMS_MCLK2_VIRT] \
						-clock_fall [get_ports {LMS_DIQ2_D[*] LMS_DIQ2_IQSEL2}] -add_delay
						
################################################################################
#Output constraints
################################################################################
#LMS1						
set_output_delay	-max $LMS_LMS7_Tsu \
						-clock [get_clocks LMS_FCLK1_PLL] [get_ports {LMS_DIQ1_D[*] LMS_DIQ1_IQSEL}]
						
set_output_delay	-min -$LMS_LMS7_Th \
						-clock [get_clocks LMS_FCLK1_PLL] [get_ports {LMS_DIQ1_D[*] LMS_DIQ1_IQSEL}]						
						
set_output_delay	-max $LMS_LMS7_Tsu \
						-clock [get_clocks LMS_FCLK1_PLL] \
						-clock_fall [get_ports {LMS_DIQ1_D[*] LMS_DIQ1_IQSEL}] -add_delay
											
set_output_delay	-min -$LMS_LMS7_Th \
						-clock [get_clocks LMS_FCLK1_PLL] \
						-clock_fall [get_ports {LMS_DIQ1_D[*] LMS_DIQ1_IQSEL}] -add_delay	
						
	
################################################################################
#Exceptions
################################################################################
#Between Center aligned different edge transfers in DIQ2 interface (when sampling with PLL phase shifted clock >5MHz)
set_false_path -setup 	-rise_from 	[get_clocks LMS_MCLK2_VIRT] -fall_to \
												[get_clocks RX_PLLCLK_C1]
set_false_path -setup 	-fall_from 	[get_clocks LMS_MCLK2_VIRT] -rise_to \
												[get_clocks RX_PLLCLK_C1]
set_false_path -hold 	-rise_from 	[get_clocks LMS_MCLK2_VIRT] -rise_to \
												[get_clocks RX_PLLCLK_C1]
set_false_path -hold 	-fall_from 	[get_clocks LMS_MCLK2_VIRT] -fall_to \
												[get_clocks RX_PLLCLK_C1]	
												
												
set_multicycle_path -hold -end -from [get_clocks {LMS_MCLK2_VIRT}] -to [get_clocks {RX_PLLCLK_C1}] [expr -1]

#Between Center aligned same edge transfers in DIQ1 interface
set_false_path -setup 	-rise_from 	[get_clocks TX_PLLCLK_C1] -rise_to \
												[get_clocks LMS_FCLK1_PLL]
set_false_path -setup 	-fall_from 	[get_clocks TX_PLLCLK_C1] -fall_to \
												[get_clocks LMS_FCLK1_PLL]
set_false_path -hold 	-rise_from 	[get_clocks TX_PLLCLK_C1] -fall_to \
												[get_clocks LMS_FCLK1_PLL]
set_false_path -hold 	-fall_from 	[get_clocks TX_PLLCLK_C1] -rise_to \
												[get_clocks LMS_FCLK1_PLL]
												


#Clock groups					
#Other clock groups are set in top .sdc file

										
#False Path between PLL output and clock output ports LMS2_FCLK1 an LMS2_FCLK2
set_false_path -to [get_ports LMS_FCLK*]	

#To cut paths for TX interface clock mux




