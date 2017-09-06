module serial_multrom_mult_top #(
	parameter HALF_WIDTH = 2
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input start,
	input [2 * HALF_WIDTH - 1:0]mult1,mult2,
	output [4 * HALF_WIDTH - 1:0]dout
);

wire [2 * HALF_WIDTH - 1:0]rom_dout;
wire [2 * HALF_WIDTH - 1:0]rom_address;
serial_multrom_mult_core #(
	.HALF_WIDTH(HALF_WIDTH)
) u_serial_multrom_mult_core (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.mult1(mult1),
	.mult2(mult2),

	.start(start),
	.rom_dout(rom_dout),
	.rom_address(rom_address),
	.dout(dout)
);

ROM_4 u_ROM_4(
    .addr(rom_address),
    .dout(rom_dout)
);
endmodule