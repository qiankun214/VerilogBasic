module high_to_low #(
	parameter LOW_DATA_WIDTH = 32,
	parameter BRUST_SIZE_LOG = 2
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	// port from high width bus
	input [LOW_DATA_WIDTH * (2 ** BRUST_SIZE_LOG) - 1:0]high_read_data,
	input high_read_valid,
	output reg high_read_finish,

	// port to low width bus
	output reg low_write_valid,
	input low_write_finish,
	output reg [LOW_DATA_WIDTH - 1:0]low_write_data
);

// status of FSM
localparam INIT = 1'b0;
localparam WORK = 1'b1;

// FSM:status change
reg mode,next_mode;
always @(posedge clk or negedge rst_n) begin : proc_mode
	if(~rst_n) begin
		mode <= INIT;
	end else begin
		mode <= next_mode;
	end
end

// compute how many data of low width bus have been send
reg [BRUST_SIZE_LOG - 1:0]tran_counter;
always @(posedge clk or negedge rst_n) begin : proc_tran_counter
	if(~rst_n) begin
		tran_counter <= 'b0;
	end else if(mode != WORK) begin
		tran_counter <= 'b0;
	end else if(low_write_finish) begin
		tran_counter <= tran_counter + 1'b1;
	end
end

// FSN:compute next status
always @(*) begin : proc_next_mode
	case (mode)
		INIT:begin
			if(high_read_valid) begin
				next_mode = WORK;
			end else begin
				next_mode = INIT;
			end
		end
		WORK:begin
			if(low_write_finish && (tran_counter == 2 ** BRUST_SIZE_LOG - 1)) begin
				next_mode = INIT;
			end else begin
				next_mode = WORK;
			end
		end
		default : next_mode = INIT;
	endcase
end

reg [LOW_DATA_WIDTH * (2 ** BRUST_SIZE_LOG) - 1:0]high_read_data_lock;
always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		high_read_data_lock <= 'b0;
	end else if (mode == INIT) begin
		high_read_data_lock <= high_read_data;
	end
end

// generate the valid signal of low width bus
reg temp_low_write_valid;
always @(posedge clk or negedge rst_n) begin : proc_temp_low_write_valid
	if(~rst_n) begin
		temp_low_write_valid <= 'b0;
	end else if(high_read_valid && next_mode == WORK && mode == INIT) begin
		temp_low_write_valid <= 1'b1;
	end else if(low_write_finish && (tran_counter != 2 ** BRUST_SIZE_LOG - 1) && mode == WORK) begin
		temp_low_write_valid <= 1'b1;
	end else begin
		temp_low_write_valid <= 'b0;
	end
end

// delay the valid signal of low width bus
always @(posedge clk or negedge rst_n) begin : proc_high_read_valid
	if(~rst_n) begin
		low_write_valid <= 'b0;
	end else begin
		low_write_valid <= temp_low_write_valid;
	end
end

// split the data to low width bus
always @(posedge clk or negedge rst_n) begin : proc_low_write_data
	if(~rst_n) begin
		low_write_data <= 'b0;
	end else if(mode == INIT) begin
		low_write_data <= high_read_data_lock[LOW_DATA_WIDTH - 1:0];
	end else if(temp_low_write_valid) begin
		low_write_data <= high_read_data_lock[tran_counter * LOW_DATA_WIDTH +:LOW_DATA_WIDTH];
	end
end

always @ (posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		high_read_finish <= 'b0;
	end else if	(mode == WORK && next_mode == INIT)begin
	  	high_read_finish <= 'b1;
	end else begin
		high_read_finish <= 'b0;
	end
end
endmodule
