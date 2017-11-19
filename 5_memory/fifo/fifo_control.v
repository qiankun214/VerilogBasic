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

wire fifo_full_wire = ((ram_write_addr[DEPTH_LOG - 1:0] == ram_read_addr[DEPTH_LOG - 1:0]) && (ram_write_addr[DEPTH_LOG] != ram_read_addr[DEPTH_LOG]))?1'b1:1'b0;
wire almost_full = ((ram_write_addr[DEPTH_LOG - 1:0] + 1'b1 == ram_read_addr[DEPTH_LOG - 1:0]) && (ram_write_addr[DEPTH_LOG] != ram_read_addr[DEPTH_LOG]))?1'b1:1'b0;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		ram_write_addr <= 'b0;
		ram_write_req <= 'b0;
	end else if(!fifo_full_wire && fifo_write_req) begin
		ram_write_addr <= ram_write_addr + 1'b1;
		ram_write_req <= 1'b1;
	end else begin
		ram_write_req <= 'b0;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fifo_full <= 'b0;
	end else if(almost_full && fifo_write_req) begin
		fifo_full <= 'b1;
	end else if(!fifo_full_wire) begin
		fifo_full <= 'b0;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		ram_write_data <= 'b0;
	end else begin
		ram_write_data <= fifo_write_data;
	end
end

wire fifo_empty_wire = (ram_write_addr == ram_read_addr)?1'b1:1'b0;
wire almost_empty = (ram_write_addr == ram_read_addr + 1'b1)?1'b1:1'b0;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		ram_read_addr <= 'b0;
	end else if(!fifo_empty_wire && fifo_read_req) begin
		ram_read_addr <= ram_read_addr + 1'b1;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		fifo_empty <= 1'b1;
	end else if(almost_empty && fifo_read_req) begin
		fifo_empty <= 1'b1;
	end else if(!fifo_empty_wire) begin
		fifo_empty <= 'b0;
	end
end
endmodule