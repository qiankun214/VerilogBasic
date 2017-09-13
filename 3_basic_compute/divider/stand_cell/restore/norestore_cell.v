module norestore_cell #(
	parameter WIDTH = 4,
	parameter STEP = 1
)(
	input [WIDTH * 2:0]remainder_din,
	input [WIDTH - 1:0]divisor,

	output reg [WIDTH * 2 - 1:0]remainder_dout,
	output reg quotient
);

wire [WIDTH * 2:0]divisor_exd = '{divisor};
wire [WIDTH * 2:0]divisor_move = divisor_exd << STEP;
wire [WIDTH * 2:0]sub = remainder_din - divisor_move;
wire [WIDTH * 2:0]add = remainder_din + divisor_move;

always @ (*) begin
	if(remainder_din[2 * WIDTH] == 'b0) begin
		remainder_dout = sub;
		quotient = ~(sub[2 * WIDTH]);
	end else begin
		remainder_dout = add;
		quotient = ~(add[2 * WIDTH]);
	end
end

endmodule