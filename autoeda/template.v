module <module> #(
	parameter SPI_MAX_WIDTH_LOG = 4
) (
	input [SPI_MAX_WIDTH_LOG + 1:0]config_data_1,
	input config_req,
	input rst_n,
	input clk,
	input [SPI_MAX_WIDTH_LOG + 1:0]config_data,
	input config_req_1,
	output [SPI_MAX_WIDTH_LOG - 1:0]spi_width_1,
	output cpha,
	output cpol_1,
	output cpol,
	output [SPI_MAX_WIDTH_LOG - 1:0]spi_width,
	output cpha_1
);



spi_config #(
	.SPI_MAX_WIDTH_LOG(SPI_MAX_WIDTH_LOG)
) u_config_0 (
	.clk        (clk),
	.rst_n      (rst_n),
	.config_req (config_req),
	.config_data(config_data),
	.cpol       (cpol),
	.cpha       (cpha),
	.spi_width  (spi_width)
);
spi_config #(
	.SPI_MAX_WIDTH_LOG(SPI_MAX_WIDTH_LOG)
) u_config_1 (
	.clk        (clk),
	.rst_n      (rst_n),
	.config_req (config_req_1),
	.config_data(config_data_1),
	.cpol       (cpol_1),
	.cpha       (cpha_1),
	.spi_width  (spi_width_1)
);

spi_config #(
	.SPI_MAX_WIDTH_LOG(SPI_MAX_WIDTH_LOG)
) u_config_2_0 (
	.clk        (clk),
	.rst_n      (rst_n),
	.config_req (config_req),
	.config_data(config_data),
	.cpol       (cpol),
	.cpha       (cpha),
	.spi_width  (spi_width)
);

endmodule
