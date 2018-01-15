//test
module spi_config #(
	parameter SPI_MAX_WIDTH_LOG = 4
)(
	input clk,rst_n,  // Asynchronous reset active low
/*
test
 */
	input config_req,
	input [SPI_MAX_WIDTH_LOG + 1:0]config_data,

	output reg cpol,
	output reg cpha,
	output reg [SPI_MAX_WIDTH_LOG - 1:0]spi_width
);

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{cpol,cpha,spi_width} <= 'b0;
	end else if(config_req) begin
		{cpol,cpha,spi_width} <= config_data;
	end else begin
		{cpol,cpha,spi_width} <= {cpol,cpha,spi_width};
	end
end

endmodule