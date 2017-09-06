`timescale 1ns/1ps
module mult_tb (
);

parameter HALF_WIDTH = 4;
parameter WIDTH = HALF_WIDTH * 2;

logic clk,rst_n;
logic start;
logic [WIDTH - 1:0]multiplier1;
logic [WIDTH - 1:0]multiplier2;

logic [2 * WIDTH - 1:0]product;

serial_multrom_mult_top #(
	.HALF_WIDTH(HALF_WIDTH)
) dut (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.start(start),
	.mult1(multiplier1),
	.mult2(multiplier2),
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

logic [2 * WIDTH - 1:0]exp;
initial begin
	{multiplier1,multiplier2} = 'b0;
	repeat(100) begin
		@(negedge clk);
		start = 1'b1;
		multiplier1 = (WIDTH)'($urandom_range(0,2 ** WIDTH));
		multiplier2 = (WIDTH)'($urandom_range(0,2 ** WIDTH));
		exp = multiplier1 * multiplier2;
		repeat(12) begin
			@(negedge clk);
			start = 'b0;
		end
		if(product == exp) begin
			$display("successful");
		end else begin
			$display("fail");
		end
	end
	$stop();
end

endmodule