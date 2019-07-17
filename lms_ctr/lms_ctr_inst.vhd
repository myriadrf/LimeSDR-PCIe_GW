	component lms_ctr is
		port (
			clk_clk                                 : in    std_logic                    := 'X';             -- clk
			exfifo_if_d_export                      : in    std_logic_vector(7 downto 0) := (others => 'X'); -- export
			exfifo_if_rd_export                     : out   std_logic;                                       -- export
			exfifo_if_rdempty_export                : in    std_logic                    := 'X';             -- export
			exfifo_of_d_export                      : out   std_logic_vector(7 downto 0);                    -- export
			exfifo_of_wr_export                     : out   std_logic;                                       -- export
			exfifo_of_wrfull_export                 : in    std_logic                    := 'X';             -- export
			exfifo_rst_export                       : out   std_logic;                                       -- export
			i2c_scl_export                          : inout std_logic                    := 'X';             -- export
			i2c_sda_export                          : inout std_logic                    := 'X';             -- export
			leds_external_connection_export         : out   std_logic_vector(7 downto 0);                    -- export
			lms_ctr_gpio_external_connection_export : out   std_logic_vector(3 downto 0);                    -- export
			spi_1_adf4002_MISO                      : in    std_logic                    := 'X';             -- MISO
			spi_1_adf4002_MOSI                      : out   std_logic;                                       -- MOSI
			spi_1_adf4002_SCLK                      : out   std_logic;                                       -- SCLK
			spi_1_adf4002_SS_n                      : out   std_logic;                                       -- SS_n
			spi_1_ext_MISO                          : in    std_logic                    := 'X';             -- MISO
			spi_1_ext_MOSI                          : out   std_logic;                                       -- MOSI
			spi_1_ext_SCLK                          : out   std_logic;                                       -- SCLK
			spi_1_ext_SS_n                          : out   std_logic_vector(1 downto 0);                    -- SS_n
			spi_fpga_as_MISO                        : in    std_logic                    := 'X';             -- MISO
			spi_fpga_as_MOSI                        : out   std_logic;                                       -- MOSI
			spi_fpga_as_SCLK                        : out   std_logic;                                       -- SCLK
			spi_fpga_as_SS_n                        : out   std_logic;                                       -- SS_n
			spi_lms_external_MISO                   : in    std_logic                    := 'X';             -- MISO
			spi_lms_external_MOSI                   : out   std_logic;                                       -- MOSI
			spi_lms_external_SCLK                   : out   std_logic;                                       -- SCLK
			spi_lms_external_SS_n                   : out   std_logic_vector(4 downto 0);                    -- SS_n
			switch_external_connection_export       : in    std_logic_vector(7 downto 0) := (others => 'X'); -- export
			uart_external_connection_rxd            : in    std_logic                    := 'X';             -- rxd
			uart_external_connection_txd            : out   std_logic                                        -- txd
		);
	end component lms_ctr;

	u0 : component lms_ctr
		port map (
			clk_clk                                 => CONNECTED_TO_clk_clk,                                 --                              clk.clk
			exfifo_if_d_export                      => CONNECTED_TO_exfifo_if_d_export,                      --                      exfifo_if_d.export
			exfifo_if_rd_export                     => CONNECTED_TO_exfifo_if_rd_export,                     --                     exfifo_if_rd.export
			exfifo_if_rdempty_export                => CONNECTED_TO_exfifo_if_rdempty_export,                --                exfifo_if_rdempty.export
			exfifo_of_d_export                      => CONNECTED_TO_exfifo_of_d_export,                      --                      exfifo_of_d.export
			exfifo_of_wr_export                     => CONNECTED_TO_exfifo_of_wr_export,                     --                     exfifo_of_wr.export
			exfifo_of_wrfull_export                 => CONNECTED_TO_exfifo_of_wrfull_export,                 --                 exfifo_of_wrfull.export
			exfifo_rst_export                       => CONNECTED_TO_exfifo_rst_export,                       --                       exfifo_rst.export
			i2c_scl_export                          => CONNECTED_TO_i2c_scl_export,                          --                          i2c_scl.export
			i2c_sda_export                          => CONNECTED_TO_i2c_sda_export,                          --                          i2c_sda.export
			leds_external_connection_export         => CONNECTED_TO_leds_external_connection_export,         --         leds_external_connection.export
			lms_ctr_gpio_external_connection_export => CONNECTED_TO_lms_ctr_gpio_external_connection_export, -- lms_ctr_gpio_external_connection.export
			spi_1_adf4002_MISO                      => CONNECTED_TO_spi_1_adf4002_MISO,                      --                    spi_1_adf4002.MISO
			spi_1_adf4002_MOSI                      => CONNECTED_TO_spi_1_adf4002_MOSI,                      --                                 .MOSI
			spi_1_adf4002_SCLK                      => CONNECTED_TO_spi_1_adf4002_SCLK,                      --                                 .SCLK
			spi_1_adf4002_SS_n                      => CONNECTED_TO_spi_1_adf4002_SS_n,                      --                                 .SS_n
			spi_1_ext_MISO                          => CONNECTED_TO_spi_1_ext_MISO,                          --                        spi_1_ext.MISO
			spi_1_ext_MOSI                          => CONNECTED_TO_spi_1_ext_MOSI,                          --                                 .MOSI
			spi_1_ext_SCLK                          => CONNECTED_TO_spi_1_ext_SCLK,                          --                                 .SCLK
			spi_1_ext_SS_n                          => CONNECTED_TO_spi_1_ext_SS_n,                          --                                 .SS_n
			spi_fpga_as_MISO                        => CONNECTED_TO_spi_fpga_as_MISO,                        --                      spi_fpga_as.MISO
			spi_fpga_as_MOSI                        => CONNECTED_TO_spi_fpga_as_MOSI,                        --                                 .MOSI
			spi_fpga_as_SCLK                        => CONNECTED_TO_spi_fpga_as_SCLK,                        --                                 .SCLK
			spi_fpga_as_SS_n                        => CONNECTED_TO_spi_fpga_as_SS_n,                        --                                 .SS_n
			spi_lms_external_MISO                   => CONNECTED_TO_spi_lms_external_MISO,                   --                 spi_lms_external.MISO
			spi_lms_external_MOSI                   => CONNECTED_TO_spi_lms_external_MOSI,                   --                                 .MOSI
			spi_lms_external_SCLK                   => CONNECTED_TO_spi_lms_external_SCLK,                   --                                 .SCLK
			spi_lms_external_SS_n                   => CONNECTED_TO_spi_lms_external_SS_n,                   --                                 .SS_n
			switch_external_connection_export       => CONNECTED_TO_switch_external_connection_export,       --       switch_external_connection.export
			uart_external_connection_rxd            => CONNECTED_TO_uart_external_connection_rxd,            --         uart_external_connection.rxd
			uart_external_connection_txd            => CONNECTED_TO_uart_external_connection_txd             --                                 .txd
		);

