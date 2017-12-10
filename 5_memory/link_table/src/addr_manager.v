module addr_manager #(
	parameter ADDR_WIDTH = 16,
	parameter ADDR_PAGE_NUM_LOG = 12,
	parameter DATA_WIDTH = 8,
	parameter MODE_INIT = 0
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	//from controller
	input table_read_req,
	input table_write_req,
	input [ADDR_PAGE_NUM_LOG - 1:0]table_write_addr,
	//to controller
	output reg [ADDR_PAGE_NUM_LOG - 1:0]table_read_addr,
	output reg [ADDR_PAGE_NUM_LOG - 1:0]table_read_last_addr,
	output reg table_empty,

	//from ram
	input [DATA_WIDTH - 1:0]ram_read_data
);

reg read_req_buffer1,read_req_buffer2;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		read_req_buffer1 <= 'b0;
		read_req_buffer2 <= 'b0;
	end else begin
		read_req_buffer1 <= table_read_req;
		read_req_buffer2 <= table_read_req1;
	end
end

reg [2 * DATA_WIDTH - 1:0]head_point_temp;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		head_point_temp <= 'b0;
	end else begin
		if(read_req_buffer1) begin
			head_point_temp[DATA_WIDTH - 1:0] <= ram_read_data;
		end else if(read_req_buffer2) begin
			head_point_temp[2 * DATA_WIDTH - 1:DATA_WIDTH] <= ram_read_data;
		end
	end
end
assign table_read_addr = head_point_temp[ADDR_PAGE_NUM_LOG - 1:0];

reg [ADDR_PAGE_NUM_LOG - 1:0]table_read_last_addr;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		table_read_last_addr <= 'b0;
	end else if(table_write_req) begin
		table_read_last_addr <= table_write_addr;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		table_empty <= 1'(MODE_INIT);
	end else if(table_read_addr == table_read_last_addr) begin
		table_empty <= 1'b1;
	end else begin
		table_empty <= 'b0;
	end
end

endmodule
