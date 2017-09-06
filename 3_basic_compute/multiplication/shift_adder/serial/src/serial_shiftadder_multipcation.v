module serial_shiftadder_multipcation # (
	parameter WIDTH = 4
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input multiplier_valid,
	input [WIDTH - 1:0]multiplier1,
	input [WIDTH - 1:0]multiplier2,

	output reg product_valid,
	output reg [2 * WIDTH - 1:0]product
);

/*****************buffer and shift*******************/
reg [WIDTH - 1:0]min_mult;
reg [2 * WIDTH - 1:0]max_mult;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{max_mult,min_mult} <= 'b0;
	end else if(multiplier_valid == 1'b1) begin
		if(multiplier1 > multiplier2) begin
			max_mult <= '{multiplier1};
			min_mult <= multiplier2;
		end else begin
			max_mult <= '{multiplier2};
			min_mult <= multiplier1;
		end
	end else if(min_mult != 'b0) begin
		max_mult <= max_mult << 1;
		min_mult <= min_mult >> 1;
	end else begin
		max_mult <= max_mult;
		min_mult <= min_mult;
	end
end

/******************adder********************/
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{product_valid,product} <= 'b0;
	end else if(min_mult[0] == 1'b1) begin
		product <= product + max_mult;
		product_valid <= 1'b0;
	end else if(min_mult != 'b0) begin
		product <= product;
		product_valid <= 1'b0;
	end else if(multiplier_valid == 1'b1) begin
		product <= 'b0;
		product_valid <= 1'b0;
	end else begin
		product <= product;
		product_valid <= 1'b1;
	end
end

endmodule

