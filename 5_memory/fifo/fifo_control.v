module fifo_control #(
	parameter WIDTH = 8,
	parameter DEPTH_LOG = 8
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input fifo_write_req,
	input [WIDTH - 1:0]fifo_write_data,
	output reg fifo_full,

	input fifo_read_req,
	output reg fifo_empty,

	output reg ram_write_req,
	output reg [DEPTH_LOG - 1:0]ram_write_addr,
	output reg [WIDTH - 1:0]ram_write_data,

	output reg [DEPTH_LOG - 1:0]ram_read_addr
);

reg [DEPTH_LOG - 1:0]write_point,read_point;
wire almost_full = (write_point == read_point - 1'b1)?1'b1:1'b0;
wire almost_empty = (write_point == read_point + 1'b1)?1'b1:1'b0;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		write_point <= 'b0;
		ram_write_req <= 'b0;
	end else if((!fifo_full || fifo_read_req) && fifo_write_req) begin
		write_point <= write_point + 1'b1;
		ram_write_req <= 1'b1;
	end else begin
		ram_write_req <= 'b0;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fifo_full <= 'b0;
	end else if(fifo_read_req && fifo_write_req) begin
		fifo_full <= fifo_full;
	end else if(fifo_read_req) begin
		fifo_full <= 'b0;
	end else if(almost_full && fifo_write_req) begin
		fifo_full <= 'b1;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		ram_write_data <= 'b0;
		ram_write_addr <= 'b0;
	end else begin
		ram_write_data <= fifo_write_data;
		ram_write_addr <= write_point;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		read_point <= 'b0;
		ram_read_addr <= 'b0;
	end else if(!fifo_empty && fifo_read_req) begin
		read_point <= read_point + 1'b1;
		ram_read_addr <= read_point;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fifo_empty <= 1'b1;
	end else if(fifo_read_req && fifo_write_req) begin
		fifo_empty <= fifo_empty;
	end else if(fifo_write_req) begin
		fifo_empty <= 1'b0;
	end else if(almost_empty && fifo_read_req) begin
		fifo_empty <= 1'b1;
	end
end

endmodule
