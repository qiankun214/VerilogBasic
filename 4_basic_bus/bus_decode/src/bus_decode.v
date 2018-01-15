module bus_decode #(
	parameter BRUST_SIZE_LOG = 2,
	parameter ADDR_WIDTH = 16,
	parameter LOW_DATA_WIDTH = 8
) (
	input clk,
	input rst_n,

	// port from low width bus
	input [LOW_DATA_WIDTH - 1:0]low_read_data,
	input low_read_valid,
	// port to low width bus
	output low_write_valid,
	output [LOW_DATA_WIDTH - 1:0]low_write_data,
	input low_write_finish,

	// port from high width bus
	input [LOW_DATA_WIDTH * (2 ** BRUST_SIZE_LOG) - 1:0]high_read_data,
	output high_read_finish,
	input high_read_valid,
	// port to high width bus
	output [LOW_DATA_WIDTH * (2 ** BRUST_SIZE_LOG) - 1:0]high_write_data,
	output [ADDR_WIDTH - 1:0]high_write_addr,
	output high_write_valid
);



high_to_low #(
	.BRUST_SIZE_LOG(BRUST_SIZE_LOG),
	.LOW_DATA_WIDTH(LOW_DATA_WIDTH)
) u_high_to_low_0 (
	.clk             (clk),
	.rst_n           (rst_n),
	.high_read_data  (high_read_data),
	.high_read_valid (high_read_valid),
	.high_read_finish(high_read_finish),
	.low_write_valid (low_write_valid),
	.low_write_finish(low_write_finish),
	.low_write_data  (low_write_data)
);

low_to_high #(
	.BRUST_SIZE_LOG(BRUST_SIZE_LOG),
	.ADDR_WIDTH    (ADDR_WIDTH),
	.LOW_DATA_WIDTH(LOW_DATA_WIDTH)
) u_low_to_high_0 (
	.clk             (clk),
	.rst_n           (rst_n),
	.low_read_valid  (low_read_valid),
	.low_read_data   (low_read_data),
	.high_write_addr (high_write_addr),
	.high_write_data (high_write_data),
	.high_write_valid(high_write_valid)
);

endmodule
