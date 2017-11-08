module uart_fpga_test (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input uart_din,
	output uart_dout
);

wire uart_sign;
wire [7:0]data;
uart #(
	.BAUD(5207)
) u_uart (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.uart_din(uart_din),
	.uart_dout(uart_dout),

	.send_start(uart_sign),
	.send_busy,
	.send_finish,
	.send_data(data),

	.receive_start,
	.receive_busy,
	.receive_finish(uart_sign),
	.receive_data(data)
);

endmodule
