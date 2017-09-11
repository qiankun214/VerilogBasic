module tb_divider (
);

parameter WIDTH = 4;

logic clk;    // Clock
logic rst_n;  // Asynchronous reset active low
logic [2 * WIDTH - 1:0]dividend;
logic [WIDTH - 1:0]divisor;

logic din_valid;

logic [2 * WIDTH - 1:0]dout;
logic [WIDTH - 1:0]remainder;

norestore_divider #(
	.WIDTH(WIDTH)
) dut (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.dividend(dividend),
	.divisor(divisor),

	.din_valid(din_valid),

	.dout(dout),
	.remainder(remainder)
);

initial begin
	clk = 'b0;
	forever begin
		#50 clk = ~clk;
	end
end

initial begin
	rst_n = 1'b1;
	# 5 rst_n = 'b0;
	#10 rst_n = 1'b1;
end

logic [2 * WIDTH - 1:0]dout_exp;
logic [WIDTH - 1:0]remainder_exp;
initial begin
	{dividend,divisor,din_valid} = 'b0;
	forever begin
		@(negedge clk);
		dividend = (2 * WIDTH)'($urandom_range(0,2 ** (2 * WIDTH)));
		divisor = (WIDTH)'($urandom_range(1,2 ** WIDTH - 1));
		din_valid = 1'b1;

		remainder_exp = dividend % divisor;
		dout_exp = (dividend - remainder_exp) / divisor;

		repeat(5 * WIDTH) begin
			@(negedge clk);
			din_valid = 'b0;
		end
		if((remainder == remainder_exp) && (dout_exp == dout)) begin
			$display("successfully");
		end else begin
			$display("failed");
			$stop;
		end
	end
end

endmodule