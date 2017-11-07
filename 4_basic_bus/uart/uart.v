module uart #(
	parameter BAUD = 5207
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input uart_din,
	output uart_dout,

	input send_start,
	output send_busy,
	output send_finish,
	input [7:0]send_data,

	output receive_start,
	output receive_busy,
	output receive_finish,
	output [7:0]receive_data
);

wire [3:0]baud_counte_send;
uart_baud_gen #(
	.BAUD(BAUD)
)u_uart_baud_gen_send(
	.clk(clk),
	.rst_n(rst_n),

	.baud_start(send_start),
	// .baud_mid(),
	.baud_final(send_finish),
	.baud_busy(send_busy),

	.baud_counte(baud_counte_send)
);

uart_send u_uart_send(
	.clk(clk),
	.rst_n(rst_n),

	.send_start(send_start),
	.baud_busy(send_busy),

	.baud_counte(baud_counte_send),

	.send_data(send_data),
	.uart_dout(uart_dout)
);

wire baud_mid_receive;
wire [3:0]baud_counte_receive;
uart_baud_gen #(
	.BAUD(BAUD)
)u_uart_baud_gen_receive(
	.clk(clk),
	.rst_n(rst_n),

	.baud_start(receive_start),
	.baud_mid(baud_mid_receive),
	.baud_final(receive_finish),
	.baud_busy(receive_busy),

	.baud_counte(baud_counte_receive)
);

uart_receive u_uart_receive(
	.clk(clk),
	.rst_n(rst_n),

	.receive_start(receive_start),

	.baud_mid(baud_mid_receive),
	.baud_busy(receive_busy),
	.baud_counte(baud_counte_receive),

	.receive_data(receive_data),
	.uart_din(uart_din)
);
endmodule