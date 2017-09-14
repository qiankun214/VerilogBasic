module restore_cell #(
	parameter WIDTH = 4,
	parameter STEP = 1
)(
	input clk,
	input rst_n,

	input [WIDTH * 3 - 1:0]remainder_din,
	input [WIDTH - 1:0]divisor,

	output reg [WIDTH * 3 - 1:0]remainder_dout,
	output reg quotient
);

wire [WIDTH * 3:0]divisor_exd = '{divisor};
wire [WIDTH * 3:0]sub = {1'b0,remainder_din} - (divisor_exd << STEP);

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{remainder_dout,quotient} <= 'b0;
	end else begin
		if(sub[WIDTH * 3] == 1'b0) begin
			remainder_dout = sub;
		end else begin
			remainder_dout = remainder_din;
		end
		quotient = ~(sub[3 * WIDTH]);
	end
end

endmodule