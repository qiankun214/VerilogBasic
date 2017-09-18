module square_cell #(
	parameter WIDTH = 4,
	parameter STEP = 0
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input [2 * WIDTH - 1:0]radicand,
	input [WIDTH - 1:0]last_dout,
	input [2 * WIDTH - 1:0]remainder_din,

	output reg [WIDTH - 1:0]this_dout,
	output reg [2 * WIDTH - 1:0]remainder_dout
);

wire [2 * WIDTH - 1:0]target_data = {remainder_din[2 * WIDTH - 3:0],radicand[2 * STEP +:2]};
wire [2 * WIDTH - 1:0]try_data = '{last_dout,2'b01};

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{this_dout,remainder_dout} <= 'b0;
	end else begin
		if(target_data >= try_data) begin
			this_dout <= {last_dout[WIDTH - 2:0],1'b1};
			remainder_dout <= target_data - try_data;
		end else begin
			this_dout <= {last_dout[WIDTH - 2:0],1'b0};
			remainder_dout <= target_data;
		end
	end
end
endmodule