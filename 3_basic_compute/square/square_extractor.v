module square_extractor #(
	parameter WIDTH = 4
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input [2 * WIDTH - 1:0]radicand,

	output [WIDTH - 1:0]dout,
	output [WIDTH - 1:0]remainder
);

genvar i;
generate
	for (i = WIDTH - 1; i >= WIDTH; i = i - 1) begin:square
		wire [2 * WIDTH - 1:0]remainder_dout,remainder_din;
		wire [WIDTH - 1:0]this_dout,last_dout;
		if(i == WIDTH - 1) begin
			assign remainder_dout = 'b0;
			assign last_dout = 'b0;
		end else begin
			assign remainder_dout = square[i + 1].remainder_din;
			assign last_dout = square[i + 1].this_dout;
		end
		square_cell #(
			.WIDTH(WIDTH),
			.STEP(i)
		) u_square_cell (
			.clk(clk),    // Clock
			.rst_n(rst_n),  // Asynchronous reset active low

			.radicand(radicand),
			.last_dout(last_dout),
			.remainder_din(remainder_din),

			.this_dout(this_dout),
			.remainder_dout(remainder_din)
		);
	end
endgenerate

assign dout = square[0].this_dout;
assign remainder = square[0].remainder_dout;

endmodule
