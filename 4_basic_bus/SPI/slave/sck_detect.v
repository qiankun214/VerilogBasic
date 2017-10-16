module sck_gen(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input cpol,
	input spi_width,

	output sck_first_edge,sck_second_edge,

	input sck,
	input cs,

	output spi_start,spi_finish
);

wire sck_handle = (cpol)?(!sck):sck;
reg cs_last,sck_last;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{cs_last,sck_last} <= 'b0;
	end else begin
		{cs_last,sck_last} <= {cs,sck_handle};
	end
end

assign spi_start = ((cs_last == 1'b1) && (cs == 1'b0))?1'b1:1'b0;
assign spi_finish = ((cs_last == 1'b0) && (cs == 1'b1))?1'b1:1'b0;
assign sck_first_edge = ((sck_last == 1'b0) && (sck_handle == 1'b1))?1'b1:1'b0;
assign sck_second_edge = ((sck_last == 1'b1) && (sck_handle == 1'b0))?1'b1:1'b0;

endmodule
