module restore_cell #(
	parameter WIDTH = 4,
	parameter STEP = 1
)(
	input [WIDTH * 2:0]remainder_din,
	input [WIDTH - 1:0]divisor,

	output reg [WIDTH * 2 - 1:0]remainder_dout,
	output quotient
);

wire [WIDTH * 2:0]divisor_exd = '{divisor};
wire [WIDTH * 2:0]sub = remainder_din - (divisor_exd << STEP);

always @ (*) begin
	if(sub[WIDTH * 2] == 1'b0) begin
		remainder_dout = sub;
	end else begin
		remainder_dout = remainder_din;
	end
end

assign quotient = ~(sub[2 * WIDTH]);

endmodule