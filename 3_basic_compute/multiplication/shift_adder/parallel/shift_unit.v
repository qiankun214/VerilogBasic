module shift_unit #(
	parameter WIDTH = 4,
	parameter SHIFT_NUM = 0
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input shift_valid,
	input shift_mask,
	input [WIDTH - 1:0]shift_din,

	output reg [2 * WIDTH - 1:0]shift_dout
);

wire [2 * WIDTH - 1:0]shift_din_ext;
assign shift_din_ext = {(WIDTH)'(0),shift_din};

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		shift_dout <= 'b0;
	end else if((shift_valid == 1'b1) && (shift_mask == 1'b1)) begin
		shift_dout <= shift_din_ext << SHIFT_NUM;
	end else begin
		shift_dout <= 'b0;
	end
end

endmodule