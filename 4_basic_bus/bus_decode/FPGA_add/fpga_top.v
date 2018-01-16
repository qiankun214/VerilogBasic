module fpga_top(
    input clk,
    input rst_n,

    input uart_din,
    output uart_dout
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

wire [31:0]inter_data;
wire inter_flag;
bus_decode #(
	.BRUST_SIZE_LOG(2),
	.ADDR_WIDTH(16),
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
	.high_read_data(inter_data),
	.high_read_valid(inter_flag),
	// port to high width bus
	.high_write_data(inter_data),
	.high_write_valid(inter_flag)
);
endmodule // fpga_top