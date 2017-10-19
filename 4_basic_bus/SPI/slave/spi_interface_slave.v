module spi_interface_slave #(
	parameter SPI_MAX_WIDTH_LOG = 4
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	output spi_start,
	output spi_finish,

	input sck,
	input cs,
	input mosi,
	output miso,

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
sck_detect u_sck_detect(
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.cpol(cpol),
	.cpha(cpha),
	.spi_width(spi_width),

	.sck_first_edge(sck_first_edge),
	.sck_second_edge(sck_second_edge),

	.sck(sck),
	.cs(cs),

	.spi_start(spi_start),
	.spi_finish(spi_finish)
);

spi_datapath_slave #(
	.SPI_MAX_WIDTH_LOG(SPI_MAX_WIDTH_LOG)
) u_spi_datapath_slave (
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
