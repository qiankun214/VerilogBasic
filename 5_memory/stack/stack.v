module stack #(
	parameter WIDTH = 8,
	parameter DEPTH_LOG = 4
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input stack_write_req,
	input [WIDTH - 1:0]stack_write_data,
	input stack_read_req,
	output [WIDTH - 1:0]stack_read_data,

	output stack_empty,
	output stack_full
);

wire ram_write_req;
wire [DEPTH_LOG - 1:0]ram_addr;
wire [WIDTH - 1:0]ram_write_data;
stack_controller #(
	.WIDTH    (WIDTH),
	.DEPTH_LOG(DEPTH_LOG)
) u_stack_control (
	.clk             (clk),
	.rst_n           (rst_n),
	.stack_write_req (stack_write_req),
	.stack_write_data(stack_write_data),
	.stack_read_req  (stack_read_req),
	.stack_empty     (stack_empty),
	.stack_full      (stack_full),
	.ram_write_req   (ram_write_req),
	.ram_addr        (ram_addr),
	.ram_write_data  (ram_write_data)
);

pkg_simple_ram #(
	.RAM_WIDTH    (WIDTH),
	.RAM_DEPTH_LOG(DEPTH_LOG)
) u_stack_ram (
	.clk      (clk),
	.write_req(ram_write_req),
	.addr     (ram_addr),
	.data     (ram_write_data),
	.q        (stack_read_data)
);

endmodule

