module norestore_square_cell #(
	parameter WIDTH = 4,
	parameter STEP = 0
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input [2 * WIDTH - 1:0]radicand,
	input [WIDTH - 1:0]last_dout,
	input [2 * WIDTH:0]remainder_din,

	output reg [WIDTH - 1:0]this_dout,
	output reg [2 * WIDTH:0]remainder_dout
);

wire [2 * WIDTH:0]target_data = {remainder_din[2 * WIDTH],remainder_din[2 * WIDTH - 3:0],radicand[2 * STEP +:2]};
wire [2 * WIDTH:0]pos_data = {last_dout,2'b01};
wire [2 * WIDTH:0]neg_data = {last_dout,2'b11};

wire [2 * WIDTH:0]pos_final_data = target_data - pos_data;
wire [2 * WIDTH:0]neg_final_data = target_data + neg_data;
wire [2 * WIDTH:0]final_data = (remainder_din[2 * WIDTH])?neg_final_data:pos_final_data;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{this_dout,remainder_dout} <= 'b0;
	end else begin
		remainder_dout <= final_data;
		this_dout <= {last_dout[WIDTH - 2:0],~final_data[2 * WIDTH]};
	end
end

endmodule