module uart_to_high #(
	parameter BAUD = 5207,
	parameter BRUST_SIZE_LOG = 2,
	parameter ADDR_WIDTH = 16
)(
	//system
    input clk,
    input rst_n,

	// uart interface
    input uart_din,
    output uart_dout,

	//from high width bus
	input [8 * (2 ** BRUST_SIZE_LOG) - 1:0]high_read_data,
	input high_read_valid,
	output high_read_finish,
	//to high width bus
	output [8 * (2 ** BRUST_SIZE_LOG) - 1:0]high_write_data,
	output [ADDR_WIDTH - 1:0]high_write_addr,
	output high_write_valid
);

wire [7:0]low_read_data;
wire [7:0]low_write_data;
wire low_read_valid;
wire low_write_valid;
wire low_write_finish;

uart #(
	.BAUD(5207)
) u_uart (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.uart_din(uart_din),
	.uart_dout(uart_dout),

	.send_start(low_write_valid),
	.send_finish(low_write_finish),
	.send_data(low_write_data),

	.receive_finish(low_read_valid),
	.receive_data(low_read_data)
);

bus_decode #(
	.BRUST_SIZE_LOG(BRUST_SIZE_LOG),
	.ADDR_WIDTH(ADDR_WIDTH),
	.LOW_DATA_WIDTH(8)
) u_bus_decode (
	.clk(clk),
	.rst_n(rst_n),

	// port from low width bus
	.low_read_data(low_read_data),
	.low_read_valid(low_read_valid),
	// port to low width bus
	.low_write_valid(low_write_valid),
	.low_write_data(low_write_data),
	.low_write_finish(low_write_finish),

	// port from high width bus
	.high_read_data(high_read_data),
	.high_read_finish(high_read_finish),
	.high_read_valid(high_read_valid),
	// port to high width bus
	.high_write_data(high_write_data),
	.high_write_addr(high_write_addr),
	.high_write_valid(high_write_valid)
);

endmodule // fpga_top
