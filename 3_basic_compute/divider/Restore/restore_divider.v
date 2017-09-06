module restore_divider #(
	parameter WIDTH = 4
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input [2 * WIDTH - 1:0]dividend,
	input [WIDTH - 1:0]divisor,

	input din_valid,
	output dout_valid,

	output reg[WIDTH - 1:0]dout,
	output reg [WIDTH - 1:0]remainder
);

reg [2 * WIDTH - 1:0]divisor_lock;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		divisor_lock <= 'b0;
	end else if(din_valid == 1'b1) begin
		divisor_lock[2 * WIDTH - 1:WIDTH] <= divisor;
		divisor_lock[WIDTH] <= 'b0;
	end else begin
		divisor_lock <= divisor_lock >> 1;
	end
end

reg [2 * WIDTH - 1:0]divisor_lock;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{remainder,dout} <= 'b0;
	end else if(din_valid == 1'b1) begin
		remainder <= dividend;
		dout <= 'b0;
	end else if(divisor_lock[2 * WIDTH - 1:WIDTH - 1] != 'b0)begin
		if(remainder >= divisor_lock) begin
			remainder <= remainder - divisor_lock;
			dout <= {dout[WIDTH - 2:0],1'b1};
		end else begin
			remainder <= remainder;
			dout <= {dout[WIDTH - 2:0],1'b0};
		end
	end else begin
		{remainder,dout} <= {remainder,dout};
	end
end

endmodule