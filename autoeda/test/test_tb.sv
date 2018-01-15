spi_config #(
	.SPI_MAX_WIDTH_LOG(SPI_MAX_WIDTH_LOG)
) u_./test/spi_config (
	.clk        (clk),
	.rst_n      (rst_n),
	.config_req (config_req),
	.config_data(config_data),
	.cpol       (cpol),
	.cpha       (cpha),
	.spi_width  (spi_width)
);