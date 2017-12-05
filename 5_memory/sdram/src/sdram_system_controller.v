module sdram_system_controller #(
	parameter BANK_WIDTH = 2,
	parameter ROW_WIDTH = 11,
	parameter COLUMN_WIDTH = 9,
	parameter ORDER_WIDTH = 5
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	//from config
	input [3:0]sdram_precharge_order,
	input [3:0]sdram_refresh_order,
	input [3:0]sdram_config_order,
	input [3:0]sdram_write_order,
	input [3:0]sdram_read_order,

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

endmodule
