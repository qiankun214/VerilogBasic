module uart (
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

uart_baud_gen u_uart_baud_gen_send(
	.clk(clk),
	.rst_n(rst_n),

	.baud_start(),
	.baud_mid(),
	.baud_final(),

	.baud_counte()
);

uart_send u_uart_send(
	.clk(clk),
	.rst_n(rst_n),

	.send_start(),
	.send_busy(),
	.send_finish(),

	.baud_mid(),
	.baud_final(),
	.baud_counte(),

	.send_data()
	.uart_din()
);

uart_baud_gen u_uart_baud_gen_receive(
	.clk(clk),
	.rst_n(rst_n),

	.baud_start(),
	.baud_mid(),
	.baud_final(),

	.baud_clk(),
	.baud_counte()
);

uart_receive u_uart_receive(
	.clk(clk),
	.rst_n(rst_n),

	.receive_start(),
	.receive_busy(),
	.receive_finish(),

	.baud_mid(),
	.baud_final(),
	.baud_counte(),

	.receive_data(),
	.uart_dout()
);
endmodule