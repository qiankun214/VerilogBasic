module get_order (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	output [`InstBus] id_inst,
	output [`InstAddrBus] id_pc,

	input [`InstBus]rom_inst,
	output [`InstAddrBus] rom_pc,
	output ce
);

pc u_pc(
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.ce(ce),
	.pc(rom_pc)
);

if_id u_if_id(
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.if_pc(rom_pc),
	.if_inst(rom_inst),

	.id_pc(id_pc),
	.id_inst(id_inst)
);
endmodule