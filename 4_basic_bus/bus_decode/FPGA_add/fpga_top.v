module fpga_top(
    input clk,
    input rst_n,

	// uart interface
    input uart_din,
    output uart_dout
);

wire [31:0]inter_data;
wire inter_valid;
uart_to_high #(
	.BAUD(5207),
	.BRUST_SIZE_LOG(2),
	.ADDR_WIDTH(16)
) u_uart_to_interface (
	//system
    .clk,
    .rst_n,

	// uart interface
    .uart_din(uart_din),
    .uart_dout(uart_dout),

	//from high width bus
	.high_read_data(inter_data),
	.high_read_valid(inter_valid),
	//to high width bus
	.high_write_data(inter_data),
	.high_write_valid(inter_valid)
);

endmodule // fpga_top