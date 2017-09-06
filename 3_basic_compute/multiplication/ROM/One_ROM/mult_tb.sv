module mult_tb (
);

parameter WIDTH = 4;

logic clk,rst_n;
logic [WIDTH - 1:0]multiplier1;
logic [WIDTH - 1:0]multiplier2;

logic [2 * WIDTH - 1:0]product;

ROM_4 dut(
    .addr({multiplier1,multiplier2}),
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
	{multiplier1,multiplier2} = 'b0;
	repeat(100) begin
		@(negedge clk);
		multiplier1 = (WIDTH)'($urandom_range(0,2 ** WIDTH));
		multiplier2 = (WIDTH)'($urandom_range(0,2 ** WIDTH));
	end
	$stop();
end

logic [2 * WIDTH - 1:0]exp;
initial begin
	exp = 'b0;
	forever begin
		@(posedge clk);
		exp = multiplier1 * multiplier2;
		if(exp == product) begin
			$display("successful");
		end else begin
			$display("fail");
		end
	end
end
endmodule