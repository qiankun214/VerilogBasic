module mult_tb (
);

parameter WIDTH = 4;

logic clk,rst_n;
logic multiplier_valid;
logic [WIDTH - 1:0]multiplier1;
logic [WIDTH - 1:0]multiplier2;

logic product_valid;
logic [2 * WIDTH - 1:0]product;

serial_shiftadder_multipcation # (
	.WIDTH(WIDTH)
) dut (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.multiplier_valid(multiplier_valid),
	.multiplier1(multiplier1),
	.multiplier2(multiplier2),

	.product_valid(product_valid),
	.product(product)
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
	forever begin
		@(negedge clk);
		if(product_valid == 1'b1) begin
			multiplier1 = (WIDTH)'($urandom_range(0,2 ** WIDTH));
			multiplier2 = (WIDTH)'($urandom_range(0,2 ** WIDTH));
			multiplier_valid = 1'b1;
		end else begin
			multiplier_valid = 1'b0;
		end
	end
end

logic [2 * WIDTH - 1:0]exp;
initial begin
	forever begin
		@(posedge product_valid);
		exp = multiplier1 * multiplier2;
		if(exp == product) begin
			$display("successfully, mult1=%d mult2=%d product=%d",multiplier1,multiplier2,product);
		end else begin
			$display("failed,mult1=%d mult2=%d product=%d exp=%d",multiplier1,multiplier2,product,exp);
		end
	end
end

endmodule