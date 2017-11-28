module stack_controller #(
	parameter DEPTH_LOG = 4,
	parameter WIDTH = 8
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input stack_write_req,
	input [WIDTH - 1:0]stack_write_data,
	input stack_read_req,

	output reg stack_empty,
	output stack_full,

	output reg ram_write_req,
	output reg [DEPTH_LOG - 1:0]ram_addr,
	output reg [WIDTH - 1:0]ram_write_data
);

reg [DEPTH_LOG:0]stack_point;
wire is_full = (stack_point == 2 ** DEPTH_LOG)?1'b1:1'b0;
wire is_empty = (stack_point == 'b0)?1'b1:1'b0;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		stack_point <= 'b0;
	end else if(stack_write_req && stack_read_req) begin
		stack_point <= stack_point;
	end else if(stack_write_req && !is_full) begin
		stack_point <= stack_point + 1'b1;
	end else if(stack_read_req && !is_empty) begin
		stack_point <= stack_point - 1'b1;
	end
end
assign stack_full = stack_point[DEPTH_LOG];

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		stack_empty <= 'b0;
	end else if(ram_addr == 'b0 && is_empty) begin
		stack_empty <= 1'b1;
	end else begin
		stack_empty <= 'b0;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		ram_write_req <= 'b0;
	end else if(!is_full) begin
		ram_write_req <= stack_write_req;
	end else begin
		ram_write_req <= 'b0;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		ram_addr <= 'b0;
		ram_write_data <= stack_write_data;
	end else begin
		ram_addr <= stack_point[DEPTH_LOG - 1:0];
		ram_write_data <= stack_write_data;
	end
end

endmodule
