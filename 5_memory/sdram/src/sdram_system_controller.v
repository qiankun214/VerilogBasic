module sdram_system_controller #(
	parameter BANK_WIDTH = 2,
	parameter ROW_WIDTH = 11,
	parameter COLUMN_WIDTH = 9,
	parameter ORDER_WIDTH = 5,
	parameter REFRACOTRY_WIDTH = 5
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	//from config
	input [3:0]sdram_precharge_order,
	input [3:0]sdram_refresh_order,
	input [3:0]sdram_config_order,
	input [3:0]sdram_write_order,
	input [3:0]sdram_read_order,
	input [2:0]sdram_precharge_stand,
	input [2:0]sdram_refresh_stand,
	input [2:0]sdram_config_stand,
	input [2:0]sdram_write_stand,
	input [2:0]sdram_read_stand,
	input [2:0]sdram_active_stand,
	input [BANK_WIDTH + ROW_WIDTH + COLUMN_WIDTH - 1:0]sdram_config_data,
	input [REFRACOTRY_WIDTH - 1:0]sdram_burst_length,

	//from refresh counter
	input sdram_refresh_req,

	//from init controller
	input sdram_init_refresh_req,
	input sdram_init_config_req,
	input sdram_init_precharge_req,
	//to init controller/refresh counter
	output reg sdram_inside_order_ack,

	//from outside
	input [BANK_WIDTH + ROW_WIDTH + COLUMN_WIDTH - 1:0]sdram_addr,
	input sdram_write_req,
	input sdram_read_req,
	//to outside
	output reg sdram_data_valid,
	output reg sdram_busy,
	output reg sdram_outside_order_ack,

	//to dataflow
	output reg sdram_data_bus_mode,

	//to sdram
	output reg sdram_cs_n,
	output reg sdram_we_n,
	output reg sdram_ras_n,
	output reg sdram_cas_n,
	output reg [BANK_WIDTH - 1:0]sdram_ba,
	output reg [ROW_WIDTH - 1:0]sdram_a
);

localparam INIT = 4'd0;
localparam CLOSE_ROW = 4'd1;
localparam ACTIVE_ROW = 4'd2;
localparam READ_COLUMN = 4'd3;
localparam WRITE_COLUMN = 4'd4;
localparam REFRESH = 4'd5;
localparam PRECHARGE = 4'd6;
localparam CONFIG = 4'd7;
localparam STAND = 4'd8;

reg [3:0]mode,next_mode;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		mode <= INIT;
	end else begin
		mode <= next_mode;
	end
end

//lock and analysis addr
wire is_lock_time = (mode == INIT)?1'b1:1'b0;
reg [BANK_WIDTH - 1:0]  bank_addr;
reg [ROW_WIDTH - 1:0]   row_addr;
reg [COLUMN_WIDTH - 1:0]column_addr;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		bank_addr <= 'b0;
		row_addr <= 'b0;
		column_addr <= 'b0;
	end else if(is_lock_time) begin
		bank_addr <= sdram_addr_lock[BANK_WIDTH + ROW_WIDTH + COLUMN_WIDTH - 1 -:BANK_WIDTH];
		row_addr <= sdram_addr_lock[ROW_WIDTH + COLUMN_WIDTH - 1 -:ROW_WIDTH];
		column_addr <= sdram_addr_lock[COLUMN_WIDTH - 1:0];
	end
end

//lock sdram_write_req
reg write_req_lock;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		write_req_lock <= 'b0;
	end else if(is_lock_time) begin
		write_req_lock <= sdram_write_req;
	end
end

//activity record
reg [2 ** BANK_WIDTH - 1:0]bank_active;
reg [(2 ** BANK_WIDTH) * ROW_WIDTH - 1:0]row_active;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		bank_active <= 'b0;
		row_active <= 'b0;
	end else if(mode == ACTIVE_ROW) begin
		bank_active[bank_addr +: 1] <= 1'b1;
		row_active[bank_addr * ROW_WIDTH +:ROW_WIDTH] <= row_addr;
	end
end

//refractory manange
reg [REFRACOTRY_WIDTH - 1:0]refractory_time;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		refractory_time <= (REFRACOTRY_WIDTH)'(2 ** REFRACOTRY_WIDTH - 1);
	end else if(mode == CLOSE_ROW) begin
		refractory_time <= sdram_precharge_stand;
	end else if(mode == ACTIVE_ROW) begin
		refractory_time <= sdram_active_stand;
	end else if(mode != next_mode) begin
		case (mode)
			PRECHARGE:refractory_time <= sdram_precharge_stand;
			ACTIVE_ROW:refractory_time <= sdram_active_stand;
			WRITE_COLUMN:refractory_time <= sdram_write_stand;
			READ_COLUMN:refractory_time <= sdram_read_stand;
			CONFIG:refractory_time <= sdram_config_stand;
			REFRESH:refractory_time <= sdram_refresh_stand;
			default:refractory_time <= refractory_time;
		endcase
	end
end

reg [REFRACOTRY_WIDTH - 1:0]refractory_counte;
wire refractory_finish = (refractory_time == refractory_counte)?1'b1:1'b0;
wire is_refractory_active = ((mode == STAND) || (mode == CLOSE_ROW) || (mode == ACTIVE_ROW))?1'b1:1'b0;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		refractory_counte <= 'b0;
	end else if(refractory_counte == refractory_time) begin
		refractory_counte <= 'b0;
	end else if(is_refractory_active) begin
		refractory_counte <= refractory_counte + 1'b1;
	end
end

wire is_page_hit = (bank_active[bank_addr +:1] == 'b0)?1'b1:1'b0;
wire is_page_first_hit = ((bank_active[bank_addr +: 1] == 1'b1) && (row_active[bank_addr * ROW_WIDTH +:ROW_WIDTH] != row_addr))?1'b1:1'b0;
always @ (*) begin
	case (mode)
		INIT:begin
			if(sdram_refresh_req || sdram_init_refresh_req) begin
				next_mode = REFRESH;
			end else if(sdram_init_precharge_req) begin
				next_mode = PRECHARGE;
			end else if(sdram_init_config_req) begin
				next_mode = CONFIG;
			end else if(sdram_write_req) begin
				if(is_page_first_hit) begin
					next_mode = WRITE_COLUMN;
				end else if(is_page_hit) begin
					next_mode = ACTIVE_ROW;
				end else begin
					next_mode = CLOSE_ROW;
				end
			end else if(sdram_read_req) begin
				if(is_page_first_hit) begin
					next_mode = READ_COLUMN;
				end else if(is_page_hit) begin
					next_mode = ACTIVE_ROW;
				end else begin
					next_mode = CLOSE_ROW;
				end
			end else begin
				next_mode = INIT;
			end
		end
		CLOSE_ROW:begin
			if(refractory_finish) begin
				next_mode = ACTIVE_ROW;
			end else begin
				next_mode = CLOSE_ROW;
			end
		end
		ACTIVE_ROW:begin
			if(refractory_finish) begin
				if(write_req_lock) begin
					next_mode = WRITE_COLUMN;
				end else begin
					next_mode = READ_COLUMN;
				end
			end else begin
				next_mode = ACTIVE_ROW;
			end
		end
		PRECHARGE,REFRESH,CONFIG,WRITE_COLUMN,READ_COLUMN:next_mode = STAND;
		STAND:begin
			if(refractory_finish) begin
				next_mode = INIT;
			end else begin
				next_mode = STAND;
			end
		end
		default:next_mode = INIT;
	endcase
end

endmodule
