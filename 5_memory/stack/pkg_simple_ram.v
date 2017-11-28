module pkg_simple_ram #(
	parameter RAM_WIDTH = 8,
	parameter RAM_DEPTH_LOG = 8
)(
	input clk,    // Clock

	input write_req,
	input [RAM_DEPTH_LOG - 1:0]addr,
	input [RAM_WIDTH - 1:0]data,
	output [RAM_WIDTH - 1:0]q
);

model_simple_ram #(
	.RAM_WIDTH(RAM_WIDTH),
	.RAM_DEPTH_LOG(RAM_DEPTH_LOG)
) u_stack_ram (
	.clk(clk),    // Clock

	.write_req(write_req),
	.addr(addr),
	.data(data),
	.q(q)
);

endmodule
