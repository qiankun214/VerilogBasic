module tb_square (
);

parameter WIDTH = 4;

logic clk;    // Clock
logic rst_n;  // Asynchronous reset active low

logic [2 * WIDTH - 1:0]radicand;

logic [WIDTH - 1:0]dout;
logic [2 * WIDTH - 1:0]remainder;

square_extractor #(
	.WIDTH(WIDTH)
) dut (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.radicand(radicand),

	.dout(dout)
	// .remainder(remainder)
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

logic [2 * WIDTH - 1:0]act;
logic [2 * WIDTH - 1:0]dout_ex;
initial begin
	radicand = 'b0;
	forever begin
		@(negedge clk);
		radicand = (2 * WIDTH)'($urandom_range(0,2 ** (2 * WIDTH)));
		repeat(4 * WIDTH) begin
			@(negedge clk);
		end
		dout_ex = '{dout};
		if(((dout_ex + 1) ** 2 > radicand) && (dout_ex ** 2 <= radicand)) begin
			$display("successfully");
		end else begin
			$display("failed");
			$stop;
		end
	end
end

endmodule