module adder_tree #(
	parameter LAYER_NUM = 4,
	parameter MIN_ADDER_WIDTH = 8
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input [(2 ** LAYER_NUM) * MIN_ADDER_WIDTH - 1:0]adder_din,
	output [LAYER_NUM + MIN_ADDER_WIDTH - 1:0]adder_dout
);

genvar i;
generate
	for(i = LAYER_NUM;i > 0;i = i - 1)begin:adder_layer_def
		wire [(2 ** i) * (MIN_ADDER_WIDTH + LAYER_NUM - i) - 1:0]layer_din;
		wire [2 ** (i - 1) * (MIN_ADDER_WIDTH + LAYER_NUM - i + 1) - 1:0]layer_dout;
		if(i == LAYER_NUM) begin
			assign layer_din = adder_din;
		end else begin
			assign layer_din = adder_layer_def[i + 1].layer_dout;
		end
		adder_layer # (
			.ADDER_NUM(2 ** (i - 1)),
			.ADDER_WIDTH(MIN_ADDER_WIDTH + LAYER_NUM - i)
		) u_adder_layer (
			.clk(clk),    // Clock
			.rst_n(rst_n),  // Asynchronous reset active low
			.adder_din(layer_din),
			.adder_dout(layer_dout)
		);
	end
endgenerate

assign adder_dout = adder_layer_def[1].layer_dout;
endmodule