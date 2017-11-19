module pc (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	output reg ce,
	output reg [`InstAddrBus]pc
);

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		ce <= `ChipDisable;
	end else begin
		ce <= `ChipEnable;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		pc <= 'b0
	end else begin
		if(ce == `ChipEnable) begin
			pc <= pc + 3'd4;
		end else begin
			pc <= pc;
		end
	end
end

endmodule
