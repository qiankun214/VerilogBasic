module initialize_manager #(
	parameter ADDR_WIDTH = 16,
	parameter ADDR_PAGE_NUM_LOG = 12,
	parameter DATA_WIDTH = 8
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	output reg link_initialize_done,
	output reg [ADDR_WIDTH - 1:0]link_initialize_addr,
	output reg [DATA_WIDTH - 1:0]link_initialize_data
);

reg initialize_done;
reg [ADDR_PAGE_NUM_LOG:0]link_initialize_page;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		link_initialize_page <= 'b0;
	end else if(!initialize_done) begin
		link_initialize_page <= link_initialize_page + 1'b1;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		initialize_done <= 'b0;
	end else if(link_initialize_page == 2 ** (ADDR_PAGE_NUM_LOG + 1) - 1) begin
		initialize_done <= 1'b1;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		link_initialize_addr <= 'b0;
	end else begin
		link_initialize_addr <= link_initialize_page[ADDR_PAGE_NUM_LOG - 1:0];
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		link_initialize_data <= 'b0;
	end else begin
		if(link_initialize_page[0] == 1'b0) begin
			link_initialize_data <= {link_initialize_page[ADDR_PAGE_NUM_LOG - DATA_WIDTH:1],(2 * DATA_WIDTH - ADDR_PAGE_NUM_LOG + 2)'0};
		end else begin
			link_initialize_page <= link_initialize_page[ADDR_PAGE_NUM_LOG -: DATA_WIDTH];
		end
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		link_initialize_done <= 'b0;
	end else begin
		link_initialize_done <= initialize_done;
	end
end

endmodule
