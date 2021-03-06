module pkg_data_table_manager (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	//from controller
	input data_table_read_req,
	input data_table_write_req,
	input [ADDR_PAGE_NUM_LOG - 1:0]data_table_write_addr,
	//to controller
	output [ADDR_PAGE_NUM_LOG - 1:0]data_table_read_addr,
	output [ADDR_PAGE_NUM_LOG - 1:0]data_table_read_last_addr,
	output data_table_empty,

	//from ram
	input [DATA_WIDTH - 1:0]ram_read_data
);

addr_manager #(
	.ADDR_WIDTH(ADDR_WIDTH),
	.ADDR_PAGE_NUM_LOG(ADDR_PAGE_NUM_LOG),
	.DATA_WIDTH(DATA_WIDTH),
	.MODE_INIT(MODE_INIT)
) u_data_table_manager (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	//from controller
	.table_read_req(data_table_read_req),
	.table_write_req(data_table_write_req),
	.table_write_addr(data_table_write_addr),
	//to controller
	.table_read_addr(data_table_read_addr),
	.table_read_last_addr(data_table_read_last_addr),
	.table_empty(data_table_empty),

	//from ram
	.ram_read_data(ram_read_data)
);

endmodule
