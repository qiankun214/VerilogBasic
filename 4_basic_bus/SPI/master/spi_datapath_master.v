module spi_datapath_master #(
	parameter SPI_MAX_WIDTH_LOG = 4
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	//config
	input cpha,

	//control flow
	input sck_first_edge,sck_second_edge,
	input spi_start,

	//spi
	input miso,
	output mosi,

	//data
	input [2 ** SPI_MAX_WIDTH_LOG - 1:0]din,
	output reg[2 ** SPI_MAX_WIDTH_LOG - 1:0]dout
);

reg spi_read,spi_write;
always @ (*) begin
	if(cpha) begin
		spi_read = sck_second_edge;
		spi_write = sck_first_edge;
	end else begin
		spi_read = sck_first_edge;
		spi_write = sck_second_edge;
	end
end

reg [2 ** SPI_MAX_WIDTH_LOG - 1:0]din_lock;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{din_lock,dout} <= 'b0;
	end else if(spi_start) begin
		din_lock <= din;
		dout <= 'b0;
	end else if(spi_read) begin
		dout <= {miso,dout[2 ** SPI_MAX_WIDTH_LOG - 1:1]};
	end else if(spi_write) begin
		din_lock <= din_lock >> 1;
	end
end
assign mosi = din_lock[0];

endmodule
