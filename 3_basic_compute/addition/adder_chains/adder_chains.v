module adder_chains #(
	parameter MIN_WIDTH = 8,
	parameter ADDER_NUM = 4
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input [MIN_WIDTH * ADDER_NUM - 1:0]adder_din,

	output [MIN_WIDTH + ADDER_NUM - 1:0]adder_dout
);

genvar i;
generate
	for (i = 0; i < ADDER_NUM; i = i + 1) begin:layer
		reg [MIN_WIDTH + i:0]layer_result;
		wire [MIN_WIDTH + i - 1:0]layer_din0,layer_din1;
		if(i == 0) begin
			assign layer_din0 = adder_din[MIN_WIDTH - 1:0];
			assign layer_din1 = adder_din[2 * MIN_WIDTH - 1:MIN_WIDTH];
		end else begin
			assign layer_din0 = layer[i - 1].layer_result;
			assign layer_din1 = {adder_din[i * MIN_WIDTH +:MIN_WIDTH]};
		end

		always @(posedge clk or negedge rst_n) begin 
		 	if(~rst_n) begin
		 		layer_result <= 'b0;
		 	end else begin
		 		layer_result <= layer_din0 + layer_din1;
		 	end
		 end 
	end
endgenerate

assign adder_dout = layer[ADDER_NUM - 1].layer_result;

endmodule