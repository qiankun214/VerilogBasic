module adder_tree_tb(
);

parameter MIN_ADDER_WIDTH = 8;
parameter LAYER_NUM = 4;

reg clk;
reg rst_n;

reg [(2 ** (LAYER_NUM - 1)) * MIN_ADDER_WIDTH - 1:0]adder_din;
wire [LAYER_NUM + MIN_ADDER_WIDTH - 1:0]adder_dout;

adder_tree #(
	.LAYER_NUM(4),
	.MIN_ADDER_WIDTH(8)
) dut (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low
	
	.adder_din(adder_din),
	.adder_dout(adder_dout)
);

initial begin:clk_gen
	clk = 1'b0;
	forever begin
		#50 clk = ~clk;
	end
end

initial begin:rst_gen
	rst_n = 1'b1;
	#5 rst_n = 1'b0;
	#10 rst_n = 1'b1;
end

initial begin
	adder_din = 'b0;
	forever begin
		@(negedge clk);
		adder_din = ((2 ** (LAYER_NUM - 1)) * MIN_ADDER_WIDTH)'($urandom_range(0,65535));
	end
end

endmodule

