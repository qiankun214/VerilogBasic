module if_id (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input [`InstAddrBus]if_pc,
	input [`InstBus]if_inst,

	output reg [`InstAddrBus]id_pc,
	output reg [`InstBus]id_inst
);

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{id_pc,id_inst} <= 'b0;
	end else begin
		{id_pc,id_inst} <= {if_pc,if_inst};
	end
end

endmodule