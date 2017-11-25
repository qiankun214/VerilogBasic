module fifo_top #(
	parameter WIDTH = 8,
	parameter DEPTH_LOG = 8
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input fifo_write_req,
	input [WIDTH - 1:0]fifo_write_data,
	output fifo_full,

	input fifo_read_req,
	output fifo_empty,
	output [WIDTH - 1:0]ram_read_data
);

wire ram_write_req;
wire [DEPTH_LOG - 1:0]ram_write_addr,ram_read_addr;
wire [WIDTH - 1:0]ram_write_data;
fifo_control #(
	.WIDTH    (WIDTH),
	.DEPTH_LOG(DEPTH_LOG)
) u_u_fifo_control (
	.clk            (clk),
	.rst_n          (rst_n),
	.fifo_write_req (fifo_write_req),
	.fifo_write_data(fifo_write_data),
	.fifo_full      (fifo_full),
	.fifo_read_req  (fifo_read_req),
	.fifo_empty     (fifo_empty),
	.ram_write_req  (ram_write_req),
	.ram_write_addr (ram_write_addr),
	.ram_write_data (ram_write_data),
	.ram_read_addr  (ram_read_addr)
);

pkg_dual_ram #(
	.WIDTH    (WIDTH),
	.DEPTH_LOG(DEPTH_LOG)
) u_u_fifo_ram (
	.clk           (clk),
	.rst_n         (rst_n),
	.ram_write_req (ram_write_req),
	.ram_write_addr(ram_write_addr),
	.ram_write_data(ram_write_data),
	.ram_read_addr (ram_read_addr),
	.ram_read_data (ram_read_data)
);

endmodule
