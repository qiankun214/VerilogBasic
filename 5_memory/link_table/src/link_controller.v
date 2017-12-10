module link_controller #(
	parameter ADDR_WIDTH = 16,
	parameter ADDR_PAGE_NUM_LOG = 12,
	parameter DATA_WIDTH = 8
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	//from/to table addr manager
	input [ADDR_PAGE_NUM_LOG - 1:0]data_table_read_addr,
	input [ADDR_PAGE_NUM_LOG - 1:0]data_table_read_last_addr,
	input data_table_empty,
	output reg data_table_read_req,
	output reg data_table_write_req,
	output [ADDR_PAGE_NUM_LOG - 1:0]data_table_write_addr,

	//from/to empty addr manager
	input [ADDR_PAGE_NUM_LOG - 1:0]empty_table_read_addr,
	input [ADDR_PAGE_NUM_LOG - 1:0]empty_table_read_last_addr,
	input empty_table_empty,
	output reg empty_table_read_req,
	output reg empty_table_write_req,
	output [ADDR_PAGE_NUM_LOG - 1:0]empty_table_write_addr,

	//to ram
	output reg ram_write_req,
	output reg [ADDR_WIDTH - 1:0]ram_addr,
	// input [DATA_WIDTH - 1:0]ram_read_data,

	//to dataflow controller
	output [DATA_WIDTH - 1:0]ram_write_data,
	output reg ram_controller_write_req,
	output reg link_table_read_valid

	//from/to outside
	input link_table_write_req,
	input link_table_read_req,
	output reg link_table_busy
);

localparam INIT = 2'd0;
localparam REQ_ADDR = 2'd1;
localparam DATAFLOW = 2'd2;
localparam REWRITE = 2'd3;

reg [1:0]mode,next_mode;
wire is_mode_init = (mode == INIT)?1'b1:1'b0;
wire is_mode_req_addr = (mode == REQ_ADDR)?1'b1:1'b0;
wire is_mode_dataflow = (mode == DATAFLOW)?1'b1:1'b0;
wire is_mode_rewrite = (mode == REWRITE)?1'b1:1'b0;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		mode <= INIT;
	end else begin
		mode <= next_mode;
	end
end

localparam DATAFLOW_NUM = 2 ** (ADDR_WIDTH - ADDR_PAGE_NUM_LOG) - 1;
reg [ADDR_WIDTH - ADDR_PAGE_NUM_LOG - 1:0]controller_counter;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		controller_counter <= 'b0;
	end else if(is_mode_dataflow) begin
		controller_counter <= controller_counter + 1'b1;
	end else begin
		controller_counter <= 'b0;
	end
end

always @(*) begin
	case (mode)
		INIT:begin
			if(link_table_read_req && !data_table_empty) begin
				next_mode = REQ_ADDR;
			end else if(link_table_write_req && !empty_table_empty) begin
				next_mode = REQ_ADDR;
			end else begin
				next_mode = INIT;
			end
		end
		REQ_ADDR:next_mode = DATAFLOW;
		DATAFLOW:begin
			if(controller_counter == DATAFLOW_NUM) begin
				next_mode = REWRITE;
			end else begin
				next_mode = DATAFLOW;
			end
		end
		REWRITE:next_mode = INIT;
		default:next_mode = INIT;
	endcase
end

reg write_req_buffer;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		write_req_buffer <= 'b0;
	end else if(is_mode_init) begin
		write_req_buffer <= link_table_write_req;
	end
end

reg [ADDR_PAGE_NUM_LOG - 1:0]page_addr_buffer;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		page_addr_buffer <= 'b0;
	end else if(next_mode == REQ_ADDR) begin
		if(link_table_write_req) begin
			page_addr_buffer <= empty_table_read_addr;
		end else begin
			page_addr_buffer <= data_table_read_addr;
		end
	end
end

//to data table manager
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		data_table_read_req <= 'b0;
	end else if(is_mode_req_addr && !write_req_buffer) begin
		data_table_read_req <= 1'b1;
	end else begin
		data_table_read_req <= 'b0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		data_table_write_req <= 'b0;
	end else if(is_mode_rewrite && write_req_buffer) begin
		data_table_write_req <= 1'b1;
	end else begin
		data_table_write_req <= 'b0;
	end
end

assign data_table_write_addr <= page_addr_buffer;

//to empty table manager
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		empty_table_read_req <= 'b0;
	end else if(is_mode_req_addr && write_req_buffer) begin
		empty_table_read_req <= 1'b1;
	end else begin
		empty_table_read_req <= 'b0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		empty_table_write_req <= 'b0;
	end else if(is_mode_rewrite && !write_req_buffer) begin
		empty_table_write_req <= 1'b1;
	end else begin
		empty_table_write_req <= 'b0;
	end
end

assign empty_table_write_addr <= page_addr_buffer;

//ram control
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		ram_write_req <= 'b0;
	end else if(write_req_buffer && is_mode_dataflow) begin
		ram_write_req <= 1'b1;
	end else begin
		ram_write_req <= 'b0;
	end
end

always @(posedge clk or negedge rst_n) begin : proc_ram
	if(~rst_n) begin
		ram_addr <= 'b0;
	end else begin
		case (mode)
			REQ_ADDR:ram_addr <= page_addr_buffer;
			DATAFLOW_NUM:ram_addr <= {page_addr_buffer,controller_counter};
			REWRITE:begin
				if(write_req_buffer) begin
					ram_addr <= data_table_read_last_addr;
				end else begin
					ram_addr <= empty_table_read_last_addr;
				end
			end
			default:ram_addr <= ram_addr;
		endcase
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		ram_controller_write_req <= 'b0;
	end else if(is_mode_rewrite) begin
		ram_controller_write_req <= 1'b1;
	end else begin
		ram_controller_write_req <= 'b0;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(rst_n) begin
		link_table_read_valid <= 'b0;
	end else if(is_mode_dataflow) begin
		link_table_read_valid <= 1'b1;
	end else begin
		link_table_read_valid <= 'b0;
	end
end

//to outside
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		link_table_busy <= 'b0
	end else begin
		link_table_busy <= is_mode_init;
	end
end

endmodule

