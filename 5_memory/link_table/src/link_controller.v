module link_controller #(
	parameter ADDR_WIDTH = 16,
	parameter ADDR_PAGE_NUM_LOG = 12,
	parameter DATA_WIDTH = 8
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	//from/to table addr manager
	input [ADDR_PAGE_NUM_LOG - 1:0]data_table_head_addr,
	input [ADDR_PAGE_NUM_LOG - 1:0]data_table_last_addr,
	input data_table_empty,
	output reg data_table_read_req,
	output reg data_table_write_req,
	output [ADDR_PAGE_NUM_LOG - 1:0]data_table_write_addr,

	//from/to empty addr manager
	input [ADDR_PAGE_NUM_LOG - 1:0]empty_table_head_addr,
	input [ADDR_PAGE_NUM_LOG - 1:0]empty_table_last_addr,
	input empty_table_empty,
	output reg empty_table_read_req,
	output reg empty_table_write_req,
	output [ADDR_PAGE_NUM_LOG - 1:0]empty_table_write_addr,

	//to dataflow controller
	output reg link_controller_write_req,
	output reg [ADDR_WIDTH - 1:0]link_controller_addr,
	output [DATA_WIDTH - 1:0]link_controller_write_data,
	output reg ram_controller_write_req,
	output reg link_table_read_valid

	//from/to outside
	input link_table_write_req,
	input link_table_read_req,
	output reg link_table_busy
);

localparam INIT = 3'd0;
localparam REQ_ADDR = 3'd1;
localparam DATAFLOW = 3'd2;
localparam REWRITE = 3'd3;
localparam REWRITE_NEXT = 3'd4;

reg [2:0]mode,next_mode;
wire is_mode_init = (mode == INIT)?1'b1:1'b0;
wire is_mode_req_addr = (mode == REQ_ADDR)?1'b1:1'b0;
wire is_mode_dataflow = (mode == DATAFLOW)?1'b1:1'b0;
wire is_mode_rewrite = ((mode == REWRITE) || (mode == REWRITE_NEXT))?1'b1:1'b0;
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
		REWRITE:next_mode = REWRITE_NEXT;
		REWRITE_NEXT:next_mode = INIT;
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
			page_addr_buffer <= empty_table_head_addr;
		end else begin
			page_addr_buffer <= data_table_head_addr;
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
		link_controller_write_req <= 'b0;
	end else if(write_req_buffer && is_mode_dataflow) begin
		link_controller_write_req <= 1'b1;
	end else begin
		link_controller_write_req <= 'b0;
	end
end

always @(posedge clk or negedge rst_n) begin : proc_ram
	if(~rst_n) begin
		link_controller_addr <= 'b0;
	end else begin
		case (mode)
			REQ_ADDR:link_controller_addr <= page_addr_buffer;
			DATAFLOW_NUM:link_controller_addr <= {page_addr_buffer,controller_counter};
			REWRITE:begin
				if(write_req_buffer) begin
					link_controller_addr <= data_table_last_addr;
				end else begin
					link_controller_addr <= empty_table_last_addr;
				end
			end
			REWRITE_NEXT:begin
				if(write_req_buffer) begin
					link_controller_addr <= data_table_last_addr + 1'b1;
				end else begin
					link_controller_addr <= empty_table_last_addr + 1'b1;
				end
			end
			default:link_controller_addr <= link_controller_addr;
		endcase
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		link_controller_write_data <= 'b0;
	end else if(is_mode_rewrite) begin
		if(mode == REWRITE) begin
			link_controller_write_data <= page_addr_buffer[DATA_WIDTH - 1:0];
		end else begin
			link_controller_write_data <= {(2 * DATA_WIDTH - ADDR_PAGE_NUM_LOG + 2)'0,page_addr_buffer[ADDR_PAGE_NUM_LOG - 1:DATA_WIDTH]};
		end
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

