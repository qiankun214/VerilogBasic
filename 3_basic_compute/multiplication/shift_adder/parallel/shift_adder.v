module shift_adder #(
	parameter LOG2_WIDTH = 2
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input [2 ** LOG2_WIDTH - 1:0]mult1,mult2,
	input din_valid,

	output [(2 ** LOG2_WIDTH) * 2 - 1:0]dout
);

parameter WIDTH = 2 ** LOG2_WIDTH;

wire [(WIDTH ** 2) * 2 - 1:0]shift_dout;
parallel_shifter #(
	.WIDTH(WIDTH)
) u_parallel_shifter (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.mult_valid(din_valid),
	.mult1(mult1),
	.mult2(mult2),

	.shift_dout(shift_dout)
);

wire [LOG2_WIDTH + 2 * WIDTH:0]adder_dout;
adder_tree #(
	.LAYER_NUM(LOG2_WIDTH),
	.MIN_ADDER_WIDTH(2 * WIDTH)
) u_adder_tree (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.adder_din(shift_dout),
	.adder_dout(adder_dout)
);
assign dout = adder_dout[WIDTH * 2 - 1:0];

endmodule