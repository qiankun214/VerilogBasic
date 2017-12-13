module pkg_simple_ram #(
	parameter DATA_WIDTH = 8,
	parameter ADDR_WIDTH = 8
)(
	input clk,    // Clock

	input ram_write_req,
	input [ADDR_WIDTH - 1:0]ram_addr,
	input [DATA_WIDTH - 1:0]ram_write_data,
	output [DATA_WIDTH - 1:0]ram_read_data
);

model_simple_ram #(
	.RAM_WIDTH(DATA_WIDTH),
	.RAM_DEPTH_LOG(ADDR_WIDTH)
) u_stack_ram (
	.clk(clk),    // Clock

	.write_req(ram_write_req),
	.addr(ram_addr),
	.data(ram_write_data),
	.q(ram_read_data)
);

endmodule
