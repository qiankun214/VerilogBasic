module pkg_dual_ram #(
	parameter WIDTH = 8,
	parameter DEPTH_LOG = 8
)(
	input clk,    // Clock

	input ram_write_req,
	input [DEPTH_LOG - 1:0]ram_write_addr,
	input [WIDTH - 1:0]ram_write_data,

	input [DEPTH_LOG - 1:0]ram_read_addr,
	output reg[WIDTH - 1:0]ram_read_data
);

model_dual_ram #(
	.WIDTH(WIDTH),
	.DEPTH_LOG(DEPTH_LOG)
)(
	.clk(clk),    // Clock

	.ram_write_req(ram_write_req),
	.ram_write_addr(ram_write_addr),
	.ram_write_data(ram_write_data),

	.ram_read_addr(ram_read_addr),
	.ram_read_data(ram_read_data)
);

endmodule

