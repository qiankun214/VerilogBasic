module tb_square (
);

parameter WIDTH = 4;

logic clk;    // Clock
logic rst_n;  // Asynchronous reset active low

logic [2 * WIDTH - 1:0]radicand;

logic [WIDTH - 1:0]dout;
logic [WIDTH - 1:0]remainder;

square_extractor #(
	.WIDTH(WIDTH)
) dut (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.radicand(remainder),

	.dout(dout),
	.remainder(remainder)
);

initial begin
	clk = 0;
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
	radicand = 'b0;
	forever begin
		@(negedge clk);
		radicand = (WIDTH)'($urandom_range(0,2 ** (2 * WIDTH)));
		repeat(4 * WIDTH) begin
			@(negedge clk);
		end
	end
end

endmodule