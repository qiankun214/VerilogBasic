module mult_tb (
);

parameter LOG2_WIDTH = 2;
parameter WIDTH = 2 ** LOG2_WIDTH;

logic clk,rst_n;
logic multiplier_valid;
logic [WIDTH - 1:0]multiplier1;
logic [WIDTH - 1:0]multiplier2;

logic [2 * WIDTH - 1:0]product;

shift_adder #(
	.LOG2_WIDTH(LOG2_WIDTH)
) dut (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.mult1(multiplier1),
	.mult2(multiplier2),
	.din_valid(multiplier_valid),

	.dout(product)
);

initial begin
	clk = 1'b0;
	forever begin
		#50 clk = ~clk;
	end
end

initial begin
	rst_n = 1'b1;
	#5 rst_n = 1'b0;
	#10 rst_n = 1'b1;
end

initial begin
	{multiplier_valid,multiplier1,multiplier2} = 'b0;
	repeat(100) begin
		@(negedge clk);
		multiplier1 = (WIDTH)'($urandom_range(0,2 ** WIDTH));
		multiplier2 = (WIDTH)'($urandom_range(0,2 ** WIDTH));
		multiplier_valid = 1'b1;
	end
	$stop();
end

reg [WIDTH - 1:0]mult11,mult12,mult13;
reg [WIDTH - 1:0]mult21,mult22,mult23;
reg [2 * WIDTH - 1:0]exp;

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{mult11,mult12,mult13,mult21,mult22,mult23} <= 'b0;
	end else begin
		mult13 <= mult12;
		mult12 <= mult11;
		mult11 <= multiplier1;

		mult23 <= mult22;
		mult22 <= mult21;
		mult21 <= multiplier2;
	end
end

initial begin
	exp = 'b0;
	forever begin
		@(negedge clk);
		exp = mult13 * mult23;
		if(exp == product) begin
			$display("successful");
		end else begin
			$display("fail");
		end
	end
end
endmodule