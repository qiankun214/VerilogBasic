module shiftsub_divider #(
	parameter WIDTH = 4
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input [2 * WIDTH - 1:0]dividend,
	input [WIDTH - 1:0]divisor,

	input din_valid,

	output reg [2 * WIDTH - 1:0]dout,
	output reg [2 * WIDTH - 1:0]remainder
);

reg [3 * WIDTH - 1:0]divisor_lock;
reg [WIDTH - 1:0]divisor_ref;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{divisor_lock,divisor_ref} <= 'b0;
	end else if(din_valid == 1'b1) begin
		divisor_lock[3 * WIDTH - 1:2 * WIDTH] <= divisor;
		divisor_lock[WIDTH - 1:0] <= 'b0;
		divisor_ref <= divisor;
	end else if(divisor_lock >= '{divisor_ref}) begin
		divisor_lock <= divisor_lock >> 1;
		divisor_ref <= divisor_ref;
	end else begin
		divisor_lock <= divisor_lock;
		divisor_ref <= divisor_ref;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{remainder,dout} <= 'b0;
	end else if(din_valid == 1'b1) begin
		remainder <= dividend;
		dout <= 'b0;
	end else if((dout == 'b0) && (remainder < divisor_lock)) begin
		remainder <= remainder;
		dout <= dout;
	end else if(divisor_lock >= '{divisor_ref})begin
		if(remainder >= divisor_lock) begin
			remainder <= remainder - divisor_lock;
			dout <= {dout[2 * WIDTH - 2:0],1'b1};
		end else begin
			remainder <= remainder;
			dout <= {dout[2 * WIDTH - 2:0],1'b0};
		end
	end else begin
		{remainder,dout} <= {remainder,dout};
	end
end

endmodule