module serial_multrom_mult_core #(
	parameter HALF_WIDTH = 4
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input [2 * HALF_WIDTH - 1:0]mult1,mult2,

	input start,
	input [2 * HALF_WIDTH - 1:0]rom_dout,
	output reg [2 * HALF_WIDTH - 1:0]rom_address,
	output reg [4 * HALF_WIDTH - 1:0]dout
);

parameter INIT = 1'b0,
	      WORK = 1'b1;
reg mode;
reg [1:0]counte_4_decay2;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		mode <= 1'b0;
	end else begin
		case (mode)
			INIT:begin
				if(start == 1'b1) begin
					mode <= WORK;
				end else begin
					mode <= INIT;
				end
			end
			WORK:begin
				if(counte_4_decay2 == 2'd3) begin
					mode <= INIT;
				end else begin
					mode <= WORK;
				end
			end
			default:mode <= INIT;
		endcase
	end
end

reg [1:0]counte_4;
always @(posedge clk or negedge rst_n) begin : proc_counte_4
	if(~rst_n) begin
		counte_4 <= 'b0;
	end else if(mode == WORK)begin
		counte_4 <= counte_4 + 1'b1;
	end else begin
		counte_4 <= 'b0;
	end
end

reg [2 * HALF_WIDTH - 1:0]mult1_lock,mult2_lock;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{mult1_lock,mult2_lock} <= 'b0;
	end else if(start == 1'b1)begin
		{mult1_lock,mult2_lock} <= {mult1,mult2};
	end else begin
		{mult1_lock,mult2_lock} <= {mult1_lock,mult2_lock};
	end
end

reg [1:0]counte_4_decay;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{rom_address,counte_4_decay} <= 'b0;
	end else if(start == 1'b1) begin
		{rom_address,counte_4_decay} <= 'b0;
	end else begin
		case (counte_4)
			2'd0:rom_address <= {mult1_lock[HALF_WIDTH - 1:0],mult2_lock[HALF_WIDTH - 1:0]};
			2'd1:rom_address <= {mult1_lock[2 * HALF_WIDTH - 1:HALF_WIDTH],mult2_lock[HALF_WIDTH - 1:0]};
			2'd2:rom_address <= {mult1_lock[HALF_WIDTH - 1:0],mult2_lock[2 * HALF_WIDTH - 1:HALF_WIDTH]};
			2'd3:rom_address <= {mult1_lock[2 * HALF_WIDTH - 1:HALF_WIDTH],mult2_lock[2 * HALF_WIDTH - 1:HALF_WIDTH]};
			default:rom_address <= 'b0;
		endcase
		counte_4_decay <= counte_4;
	end
end

wire [4 * HALF_WIDTH - 1:0]rom_dout_ex = '{rom_dout};
reg [4 * HALF_WIDTH - 1:0]rom_dout_lock;

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{rom_dout_lock,counte_4_decay2} <= 'b0;
	end else if(start == 1'b1) begin
		{rom_dout_lock,counte_4_decay2} <= 'b0;
	end else begin
		case (counte_4_decay)
			2'd0:rom_dout_lock <= rom_dout_ex;
			2'd1:rom_dout_lock <= rom_dout_ex << HALF_WIDTH;
			2'd2:rom_dout_lock <= rom_dout_ex << HALF_WIDTH;
			2'd3:rom_dout_lock <= rom_dout_ex << (2 * HALF_WIDTH);
			default:rom_dout_lock <= 'b0;
		endcase
		counte_4_decay2 <= counte_4_decay;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		dout <= 'b0;
	end else if(mode == WORK) begin
		dout <= dout + rom_dout_lock;
	end else if(start == 1'b1) begin
		dout <= 'b0;
	end else begin
		dout <= dout;
	end
end

endmodule