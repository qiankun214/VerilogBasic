`include "defines.v"
module low_to_high #(
	parameter LOW_DATA_WIDTH = 8,
	parameter ADDR_WIDTH = 16,
	parameter BRUST_SIZE_LOG = 2
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	// port from low width bus
	input low_read_valid,
	input [LOW_DATA_WIDTH - 1:0]low_read_data,

	// port to high width bus
	output reg [ADDR_WIDTH - 1:0]high_write_addr,
	output reg [LOW_DATA_WIDTH * (2 ** BRUST_SIZE_LOG) - 1:0]high_write_data,
	output reg high_write_valid
);

// compute the bus width of high width bus
localparam HIGH_DATA_WIDTH = LOW_DATA_WIDTH * (2 ** BRUST_SIZE_LOG);

// status of FSM
localparam INIT = 3'd0;
localparam ADDR_GET_LOW = 3'd1;
localparam ADDR_GET_HIGH = 3'd2;
localparam ADDR_COUNTE = 3'd3;
localparam DATA_HANDLE = 3'd4;

// FSM:status change
reg [2:0]mode,next_mode;
assign debug_mode = mode;
always @(posedge clk or negedge rst_n) begin : proc_mode
	if(~rst_n) begin
		mode <= INIT;
	end else begin
		mode <= next_mode;
	end
end

// get naive start addr of brust transform
reg [15:0]temp_start_addr;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		temp_start_addr <= 'b0;
	end else if(low_read_valid && (mode == ADDR_GET_LOW)) begin
		temp_start_addr[7:0] <= low_read_data;
	end else if(low_read_valid && (mode == ADDR_GET_HIGH)) begin
		temp_start_addr[15:8] <= low_read_data;
	end
end

// get brust lenght
reg [7:0]brust_lenght;
always @(posedge clk or negedge rst_n) begin : proc_brust_lenght
	if(~rst_n) begin
		brust_lenght <= 8'd255;
	end else if(low_read_valid && (mode == ADDR_COUNTE)) begin
		brust_lenght <= low_read_data;
	end
end
// counte how many bytes have been transformed
reg [7 + BRUST_SIZE_LOG:0]tran_counter;
always @(posedge clk or negedge rst_n) begin : proc_tran_counter
	if(~rst_n) begin
		tran_counter <= 'b0;
	end else if(low_read_valid && (mode == DATA_HANDLE)) begin
		tran_counter <= tran_counter + 1'b1;
	end else if(mode != DATA_HANDLE) begin
		tran_counter <= 'b0;
	end
end

// FSM:compute next status
wire is_tran_finish = ((brust_lenght == tran_counter[7 + BRUST_SIZE_LOG:BRUST_SIZE_LOG] + 1'b1) && (tran_counter[BRUST_SIZE_LOG - 1:0] == 2 ** BRUST_SIZE_LOG - 1))?1'b1:1'b0;
always @(*) begin : proc_next_mode
	case (mode)
		INIT:begin
			if(low_read_valid && low_read_data == `DATA_TRAN) begin
				next_mode = ADDR_GET_LOW;
			end else begin
				next_mode = INIT;
			end
		end
		ADDR_GET_LOW:begin
			if(low_read_valid) begin
				next_mode = ADDR_GET_HIGH;
			end else begin
				next_mode = ADDR_GET_LOW;
			end
		end
		ADDR_GET_HIGH:begin
			if(low_read_valid) begin
				next_mode = ADDR_COUNTE;
			end else begin
				next_mode = ADDR_GET_HIGH;
			end
		end
		ADDR_COUNTE:begin
			if(low_read_valid) begin
				next_mode = DATA_HANDLE;
			end else begin
				next_mode = ADDR_COUNTE;
			end
		end
		DATA_HANDLE:begin
			if(low_read_valid && is_tran_finish) begin
				next_mode = INIT;
			end else begin
				next_mode = DATA_HANDLE;
			end
		end
		default : next_mode = INIT;
	endcase
end

// compute the address of high width bus
always @(posedge clk or negedge rst_n) begin : proc_high_write_addr
	if(~rst_n) begin
		high_write_addr <= 'b0;
	end else begin
		high_write_addr <= temp_start_addr[ADDR_WIDTH - 1:0] + tran_counter[7 + BRUST_SIZE_LOG:BRUST_SIZE_LOG];
	end
end

// assemble data of high width bus
always @(posedge clk or negedge rst_n) begin : proc_high_write_data
	if(~rst_n) begin
		high_write_data <= 'b0;
	end else begin
		high_write_data[tran_counter[BRUST_SIZE_LOG - 1:0] * LOW_DATA_WIDTH +:LOW_DATA_WIDTH] <= low_read_data;
	end
end

// generate control signal of high width bus
localparam BRUST_SIZE = (2 ** BRUST_SIZE_LOG) - 1;
always @(posedge clk or negedge rst_n) begin : proc_high_write_valid
	if(~rst_n) begin
		high_write_valid <= 'b0;
	end else if (low_read_valid && (tran_counter[BRUST_SIZE_LOG - 1:0] == BRUST_SIZE)) begin
		high_write_valid <= 1'b1;
	end else begin
		high_write_valid <= 'b0;
	end
end

endmodule
