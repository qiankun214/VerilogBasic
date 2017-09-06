module tb_adder_chains (
);

parameter MIN_WIDTH = 8;
parameter ADDER_NUM = 4;

reg clk;   // Clock
reg rst_n;  // Asynchronous reset active low
reg [MIN_WIDTH * ADDER_NUM - 1:0]adder_din;
wire [MIN_WIDTH + ADDER_NUM - 1:0]adder_dout;

adder_chains #(
	.MIN_WIDTH(MIN_WIDTH),
	.ADDER_NUM(ADDER_NUM)
) dut (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low
	.adder_din(adder_din),

	.adder_dout(adder_dout)
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

reg [MIN_WIDTH - 1:0]adder_split_din[ADDER_NUM - 1:0];
integer i;
initial begin
	i = 0;
	adder_din = 'b0;
	forever begin
		@(negedge clk)
		for (i = 0; i < ADDER_NUM; i = i + 1) begin
			adder_split_din[i] = (MIN_WIDTH)'($urandom_range(0,2 ** MIN_WIDTH - 1));
			adder_din[i * MIN_WIDTH +:MIN_WIDTH] = adder_split_din[i];
		end
	end
end

endmodule