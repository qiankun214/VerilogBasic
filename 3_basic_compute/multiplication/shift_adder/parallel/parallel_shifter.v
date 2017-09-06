module parallel_shifter #(
	parameter WIDTH = 4
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input mult_valid,
	input [WIDTH - 1:0]mult1,mult2,

	output [(WIDTH ** 2) * 2 - 1:0]shift_dout
);

genvar a;
generate
	for (a = 0; a < WIDTH; a = a + 1) begin:shifter_layer
		shift_unit #(
			.WIDTH(WIDTH),
			.SHIFT_NUM(a)
		) u_shift_unit (
			.clk(clk),    // Clock
			.rst_n(rst_n),  // Asynchronous reset active low
			.shift_valid(mult_valid),
			.shift_mask(mult2[a]),
			.shift_din(mult1),

			.shift_dout(shift_dout[a * 2 * WIDTH +: 2 * WIDTH])
		);
	end
endgenerate

endmodule
