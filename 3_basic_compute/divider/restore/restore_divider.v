module restore_divider #(
	parameter WIDTH = 4
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input [WIDTH * 2 - 1:0]dividend,
	input [WIDTH - 1:0]divisor,

	input din_valid,

	output reg [2 * WIDTH - 1:0]dout,
	output [WIDTH - 1:0]remainder
);

reg [2 * WIDTH:0]remainder_r;
reg [3 * WIDTH - 1:0]divisor_move;
reg [WIDTH - 1:0]divisor_lock;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{remainder_r,divisor_lock,divisor_move,dout} <= 'b0;
	end else begin
		if(din_valid == 1'b1) begin	//lock input data
			remainder_r[WIDTH * 2 - 1:0] <= dividend;
			remainder_r[2 * WIDTH] <= 'b0;
			divisor_move[3 * WIDTH - 1:2 * WIDTH] <= divisor;
			divisor_move[2 * WIDTH - 1:0] <= 'b0;
			divisor_lock <= divisor;
			dout <= 'b0;
		end else if((divisor_move > '{remainder_r}) && (dout == 'b0)) begin
			remainder_r <= remainder_r;
			dout <= 'b0;
			divisor_move <= divisor_move >> 1;
			divisor_lock <= divisor_lock;
		end else if(divisor_move >= '{divisor_lock}) begin
			if(remainder_r[2 * WIDTH] == 1'b0) begin //sub
				remainder_r <= remainder_r - divisor_move;
				dout <= {dout[2 * WIDTH - 2:0],1'b1};
				// divisor_move <= divisor_move >> 1;
				divisor_lock <= divisor_lock;
				if(remainder_r >= divisor_move) begin
					divisor_move <= divisor_move >> 1;
				end else begin
					divisor_move <= divisor_move;
				end
			end else begin	//restore
				remainder_r <= remainder_r + divisor_move;
				dout <= {dout[2 * WIDTH - 1:1],1'b0};
				divisor_move <= divisor_move >> 1;
				divisor_lock <= divisor_lock;
			end
		end else begin
			remainder_r <= remainder_r;
			divisor_lock <= divisor_lock;
			divisor_move <= divisor_move;
			dout <= dout;
		end
	end
end

assign remainder = remainder_r[WIDTH - 1:0];

endmodule