	lms_ctr u0 (
		.clk_clk                                 (<connected-to-clk_clk>),                                 //                              clk.clk
		.exfifo_if_d_export                      (<connected-to-exfifo_if_d_export>),                      //                      exfifo_if_d.export
		.exfifo_if_rd_export                     (<connected-to-exfifo_if_rd_export>),                     //                     exfifo_if_rd.export
		.exfifo_if_rdempty_export                (<connected-to-exfifo_if_rdempty_export>),                //                exfifo_if_rdempty.export
		.exfifo_of_d_export                      (<connected-to-exfifo_of_d_export>),                      //                      exfifo_of_d.export
		.exfifo_of_wr_export                     (<connected-to-exfifo_of_wr_export>),                     //                     exfifo_of_wr.export
		.exfifo_of_wrfull_export                 (<connected-to-exfifo_of_wrfull_export>),                 //                 exfifo_of_wrfull.export
		.exfifo_rst_export                       (<connected-to-exfifo_rst_export>),                       //                       exfifo_rst.export
		.i2c_scl_export                          (<connected-to-i2c_scl_export>),                          //                          i2c_scl.export
		.i2c_sda_export                          (<connected-to-i2c_sda_export>),                          //                          i2c_sda.export
		.leds_external_connection_export         (<connected-to-leds_external_connection_export>),         //         leds_external_connection.export
		.lms_ctr_gpio_external_connection_export (<connected-to-lms_ctr_gpio_external_connection_export>), // lms_ctr_gpio_external_connection.export
		.spi_1_adf4002_MISO                      (<connected-to-spi_1_adf4002_MISO>),                      //                    spi_1_adf4002.MISO
		.spi_1_adf4002_MOSI                      (<connected-to-spi_1_adf4002_MOSI>),                      //                                 .MOSI
		.spi_1_adf4002_SCLK                      (<connected-to-spi_1_adf4002_SCLK>),                      //                                 .SCLK
		.spi_1_adf4002_SS_n                      (<connected-to-spi_1_adf4002_SS_n>),                      //                                 .SS_n
		.spi_1_ext_MISO                          (<connected-to-spi_1_ext_MISO>),                          //                        spi_1_ext.MISO
		.spi_1_ext_MOSI                          (<connected-to-spi_1_ext_MOSI>),                          //                                 .MOSI
		.spi_1_ext_SCLK                          (<connected-to-spi_1_ext_SCLK>),                          //                                 .SCLK
		.spi_1_ext_SS_n                          (<connected-to-spi_1_ext_SS_n>),                          //                                 .SS_n
		.spi_fpga_as_MISO                        (<connected-to-spi_fpga_as_MISO>),                        //                      spi_fpga_as.MISO
		.spi_fpga_as_MOSI                        (<connected-to-spi_fpga_as_MOSI>),                        //                                 .MOSI
		.spi_fpga_as_SCLK                        (<connected-to-spi_fpga_as_SCLK>),                        //                                 .SCLK
		.spi_fpga_as_SS_n                        (<connected-to-spi_fpga_as_SS_n>),                        //                                 .SS_n
		.spi_lms_external_MISO                   (<connected-to-spi_lms_external_MISO>),                   //                 spi_lms_external.MISO
		.spi_lms_external_MOSI                   (<connected-to-spi_lms_external_MOSI>),                   //                                 .MOSI
		.spi_lms_external_SCLK                   (<connected-to-spi_lms_external_SCLK>),                   //                                 .SCLK
		.spi_lms_external_SS_n                   (<connected-to-spi_lms_external_SS_n>),                   //                                 .SS_n
		.switch_external_connection_export       (<connected-to-switch_external_connection_export>),       //       switch_external_connection.export
		.uart_external_connection_rxd            (<connected-to-uart_external_connection_rxd>),            //         uart_external_connection.rxd
		.uart_external_connection_txd            (<connected-to-uart_external_connection_txd>)             //                                 .txd
	);

