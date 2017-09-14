module restore_cell_divider #(
	parameter WIDTH = 4
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input [2 * WIDTH - 1:0]dividend,
	input [WIDTH - 1:0]divisor,

	output [2 * WIDTH - 1:0]dout,
	output [WIDTH - 1:0]remainder
);

genvar i;
generate
	for (i = 2 * WIDTH - 1; i >= 0; i = i - 1) begin:restore
		wire [3 * WIDTH - 1:0]last_remaider;
		wire [3 * WIDTH - 1:0]this_remaider;
		if(i == 2 * WIDTH - 1) begin
			assign last_remaider = '{dividend};
		end else begin
			assign last_remaider = restore[i + 1].this_remaider;
		end
		restore_cell #(
			.WIDTH(WIDTH),
			.STEP(i)
		) u_restore_cell (
			.clk(clk),
			.rst_n(rst_n),

			.remainder_din(last_remaider),
			.divisor(divisor),

			.remainder_dout(this_remaider),
			.quotient(dout[i])
		);
	end
endgenerate

assign remainder = restore[0].this_remaider[WIDTH - 1:0];

endmodule