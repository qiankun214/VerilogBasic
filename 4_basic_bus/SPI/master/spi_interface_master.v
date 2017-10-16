module spi_interface_master #(
	parameter SPI_MAX_WIDTH_LOG = 4,
	parameter SPI_SCAIL_LOG = 8
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input spi_start,
	output spi_finish,

	output sck,
	output cs,
	output mosi,
	input miso,

	input config_req,
	input [SPI_MAX_WIDTH_LOG + 1:0]config_data,

	input [2 ** SPI_MAX_WIDTH_LOG - 1:0]din,
	output [2 ** SPI_MAX_WIDTH_LOG - 1:0]dout
);

wire cpol,cpha;
wire [SPI_MAX_WIDTH_LOG - 1:0]spi_width;
spi_config #(
	.SPI_MAX_WIDTH_LOG(SPI_MAX_WIDTH_LOG)
) u_spi_config (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.config_req(config_req),
	.config_data(config_data),

	.cpol(cpol),
	.cpha(cpha),
	.spi_width(spi_width)
);

wire sck_first_edge;
wire sck_second_edge;
sck_gen #(
	.SPI_MAX_WIDTH_LOG(SPI_MAX_WIDTH_LOG),
	.SPI_SCAIL_LOG(SPI_SCAIL_LOG)
) u_sck_gen (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.spi_start(spi_start),
	.cpol(cpol),
	.spi_width(spi_width),

	.sck_first_edge(sck_first_edge),
	.sck_second_edge(sck_second_edge),

	.sck(sck),
	.cs(cs),

	.spi_finish(spi_finish)
);

spi_datapath #(
	.SPI_MAX_WIDTH_LOG(SPI_MAX_WIDTH_LOG)
) u_spi_datapath (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	//config
	.cpha(cpha),

	//control flow
	.sck_first_edge(sck_first_edge),
	.sck_second_edge(sck_second_edge),
	.spi_start(spi_start),

	//spi
	.miso(miso),
	.mosi(mosi),

	//data
	.din(din),
	.dout(dout)
);

endmodule
