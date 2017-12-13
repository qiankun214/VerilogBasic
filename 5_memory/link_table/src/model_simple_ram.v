module model_simple_ram #(
	parameter RAM_WIDTH = 8,
	parameter RAM_DEPTH_LOG = 8
)(
	input clk,    // Clock

	input write_req,
	input [RAM_DEPTH_LOG - 1:0]addr,
	input [RAM_WIDTH - 1:0]data,
	output [RAM_WIDTH - 1:0]q
);

reg [RAM_WIDTH - 1:0]ram[2 ** RAM_DEPTH_LOG - 1:0];
always @ (posedge clk) begin
	if(write_req) begin
		ram[addr] <= data;
	end
end

assign q = ram[addr];

endmodule