spi_config #(
	.SPI_MAX_WIDTH_LOG(SPI_MAX_WIDTH_LOG)
) u_config_2 (
	.clk        (<connection clk>),
	.rst_n      (<connection rst_n>),
	.config_req (<connection config_req>),
	.config_data(<connection config_data>),
	.cpol       (<connection cpol>),
	.cpha       (<connection cpha>),
	.spi_width  (<connection spi_width>)
);

spi_config #(
	.SPI_MAX_WIDTH_LOG(SPI_MAX_WIDTH_LOG)
) u_config (
	.clk        (<connection clk>),
	.rst_n      (<connection rst_n>),
	.config_req (<connection config_req>),
	.config_data(<connection config_data>),
	.cpol       (<connection cpol>),
	.cpha       (<connection cpha>),
	.spi_width  (<connection spi_width>)
);