module adder_layer #(
	parameter ADDER_NUM = 4,
	parameter ADDER_WIDTH = 8
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input [ADDER_NUM * ADDER_WIDTH * 2 - 1:0]adder_din,

	output [ADDER_NUM * (ADDER_WIDTH + 1) - 1:0]adder_dout
);

genvar i;
generate
	for(i = 0;i < ADDER_NUM;i = i + 1) begin:adder_layer_gen
		wire [ADDER_WIDTH - 1:0]add1 = adder_din[2 * i * ADDER_WIDTH +: ADDER_WIDTH];
		wire [ADDER_WIDTH - 1:0]add2 = adder_din[(2 * i + 1) * ADDER_WIDTH +: ADDER_WIDTH];
		wire [ADDER_WIDTH:0]sum = add1 + add2;
		reg [ADDER_WIDTH:0]sum_reg;
		always @ (posedge clk or negedge rst_n) begin
			if(~rst_n) begin
				sum_reg <= 'b0;
			end else begin
				sum_reg <= sum;
			end
		end
		assign adder_dout[i * (ADDER_WIDTH + 1) +: ADDER_WIDTH + 1] = sum_reg;
	end
endgenerate

endmodule