module link_dataflow_controller #(
	parameter ADDR_WIDTH = 16,
	parameter DATA_WIDTH = 8
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	//from initialize
	input [ADDR_WIDTH - 1:0]link_initialize_addr,
	input [DATA_WIDTH - 1:0]link_initialize_data,
	input [DATA_WIDTH - 1:0]link_initialize_done,

	//from system controller
	input [DATA_WIDTH - 1:0]link_controller_write_req,
	input [ADDR_WIDTH - 1:0]link_controller_addr,
	input link_controller_write_req,
	input ram_controller_write_req,
	input link_table_read_valid,

	//from/to outside
	input [DATA_WIDTH - 1:0]outside_write_data,
	output reg outside_read_data_valid

	//to ram
	output reg ram_write_req,
	output reg [ADDR_WIDTH - 1:0]ram_addr,
	output reg [DATA_WIDTH - 1:0]ram_write_data
);

endmodule
