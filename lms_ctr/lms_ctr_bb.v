
module lms_ctr (
	clk_clk,
	exfifo_if_d_export,
	exfifo_if_rd_export,
	exfifo_if_rdempty_export,
	exfifo_of_d_export,
	exfifo_of_wr_export,
	exfifo_of_wrfull_export,
	exfifo_rst_export,
	i2c_scl_export,
	i2c_sda_export,
	leds_external_connection_export,
	lms_ctr_gpio_external_connection_export,
	spi_1_adf4002_MISO,
	spi_1_adf4002_MOSI,
	spi_1_adf4002_SCLK,
	spi_1_adf4002_SS_n,
	spi_1_ext_MISO,
	spi_1_ext_MOSI,
	spi_1_ext_SCLK,
	spi_1_ext_SS_n,
	spi_fpga_as_MISO,
	spi_fpga_as_MOSI,
	spi_fpga_as_SCLK,
	spi_fpga_as_SS_n,
	spi_lms_external_MISO,
	spi_lms_external_MOSI,
	spi_lms_external_SCLK,
	spi_lms_external_SS_n,
	switch_external_connection_export,
	uart_external_connection_rxd,
	uart_external_connection_txd);	

	input		clk_clk;
	input	[7:0]	exfifo_if_d_export;
	output		exfifo_if_rd_export;
	input		exfifo_if_rdempty_export;
	output	[7:0]	exfifo_of_d_export;
	output		exfifo_of_wr_export;
	input		exfifo_of_wrfull_export;
	output		exfifo_rst_export;
	inout		i2c_scl_export;
	inout		i2c_sda_export;
	output	[7:0]	leds_external_connection_export;
	output	[3:0]	lms_ctr_gpio_external_connection_export;
	input		spi_1_adf4002_MISO;
	output		spi_1_adf4002_MOSI;
	output		spi_1_adf4002_SCLK;
	output		spi_1_adf4002_SS_n;
	input		spi_1_ext_MISO;
	output		spi_1_ext_MOSI;
	output		spi_1_ext_SCLK;
	output	[1:0]	spi_1_ext_SS_n;
	input		spi_fpga_as_MISO;
	output		spi_fpga_as_MOSI;
	output		spi_fpga_as_SCLK;
	output		spi_fpga_as_SS_n;
	input		spi_lms_external_MISO;
	output		spi_lms_external_MOSI;
	output		spi_lms_external_SCLK;
	output	[4:0]	spi_lms_external_SS_n;
	input	[7:0]	switch_external_connection_export;
	input		uart_external_connection_rxd;
	output		uart_external_connection_txd;
endmodule
