module norestore_cell #(
	parameter WIDTH = 4,
	parameter STEP = 1
)(
	input clk,
	input rst_n,

	input [WIDTH * 3:0]remainder_din,
	input [WIDTH - 1:0]divisor,

	output reg [WIDTH * 3:0]remainder_dout,
	output reg quotient
);

wire [WIDTH * 3:0]divisor_exd = '{divisor};
wire [WIDTH * 3:0]divisor_move = divisor_exd << STEP;
wire [WIDTH * 3:0]sub = remainder_din - divisor_move;
wire [WIDTH * 3:0]add = remainder_din + divisor_move;

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{remainder_dout,quotient} <= 'b0;
	end else begin
		if(remainder_din[3 * WIDTH] == 'b0) begin
			remainder_dout = sub;
			quotient = ~(sub[3 * WIDTH]);
		end else begin
			remainder_dout = add;
			quotient = ~(add[3 * WIDTH]);
		end
	end
end

endmodule