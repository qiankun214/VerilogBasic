module norestore_cell_divider #(
	parameter WIDTH = 4
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input [2 * WIDTH - 1:0]dividend,
	input [WIDTH - 1:0]divisor,

	output [2 * WIDTH - 1:0]dout,
	output reg [WIDTH - 1:0]remainder
);

genvar i;
generate
	for (i = 2 * WIDTH - 1; i >= 0; i = i - 1) begin:restore
		wire [3 * WIDTH:0]last_remaider;
		wire [3 * WIDTH:0]this_remaider;
		if(i == 2 * WIDTH - 1) begin
			assign last_remaider = '{dividend};
		end else begin
			assign last_remaider = restore[i + 1].this_remaider;
		end
		norestore_cell #(
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

wire [3 * WIDTH:0]remainder_final = restore[0].this_remaider;
always @ (*) begin
	if(remainder_final[3 * WIDTH] == 1'b0) begin
		remainder = remainder_final[WIDTH - 1:0];
	end else begin
		remainder = remainder_final[WIDTH - 1:0] + divisor;
	end
end

endmodule