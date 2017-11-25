module model_dual_ram #(
	parameter WIDTH = 8,
	parameter DEPTH_LOG = 8
)(
	input clk,    // Clock
	input rst_n,

	input ram_write_req,
	input [DEPTH_LOG - 1:0]ram_write_addr,
	input [WIDTH - 1:0]ram_write_data,

	input [DEPTH_LOG - 1:0]ram_read_addr,
	output [WIDTH - 1:0]ram_read_data
);

// reg [WIDTH - 1:0]ram_write_data_lock;
// reg [DEPTH_LOG - 1:0]ram_write_addr_lock;
// reg ram_write_req_lock;
// always @ (posedge clk or negedge rst_n) begin
// 	if(~rst_n) begin
// 		ram_write_req_lock <= 'b0;
// 		ram_write_data_lock <= 'b0;
// 		ram_write_addr_lock <= 'b0;
// 	end else begin
// 		ram_write_req_lock <= ram_write_req;
// 		ram_write_data_lock <= ram_write_data;
// 		ram_write_addr_lock <= ram_write_addr;
// 	end
// end


reg [WIDTH - 1:0]ram[2 ** DEPTH_LOG - 1:0];
// always @(posedge clk) begin
// 	if(ram_write_req_lock) begin
// 		ram[ram_write_addr_lock] <= ram_write_data_lock;
// 	end
// end

always @(posedge clk) begin
	if(ram_write_req) begin
		ram[ram_write_addr] <= ram_write_data;
	end
end

// reg [DEPTH_LOG - 1:0]ram_read_addr_lock;
// always @ (posedge clk) begin
// 	if(~rst_n) begin
// 		ram_read_addr_lock <= 'b0;
// 	end else begin
// 		ram_read_addr_lock <= ram_read_addr;
// 	end
// end
assign ram_read_data = ram[ram_read_addr];

endmodule