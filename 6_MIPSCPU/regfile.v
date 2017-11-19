`include "defines.v"

module regfile(

	input clk,
	input rst_n,

	//reg write
	input we,
	input [`RegAddrBus]	waddr,
	input [`RegBus]	wdata,

	//reg read1
	input re1,
	input wire[`RegAddrBus] raddr1,
	output reg[`RegBus] rdata1,

	//reg read2
	input  re2,
	input [`RegAddrBus]	raddr2,
	output reg[`RegBus] rdata2
);

reg [`RegBus]reg_group[`RegNum - 1:0];
integer i;
always @(posedge clk or negedge rst_n) begin : proc_reg_group
	if(~rst_n) begin
		for (i = 0; i < `RegNum; i = i + 1) begin
			reg_group[i] <= 'b0;
		end
	end else begin
		if(we == `WriteEnable) begin
			reg_group[waddr] <= wdata;
		end else begin
			reg_group[waddr] <= reg_group[waddr];
		end
	end
end

always @ (*) begin
	if(~rst_n) begin
		rdata1 = `ZeroWord;
	end else if(raddr1 == 'b0) begin
		rdata1 = `ZeroWord;
	end else if(re1 == `ReadEnable)begin
		if(raddr1 == waddr) begin
			rdata1 = wdata;
		end else begin
			rdata1 = reg_group[raddr1];
		end
	end else begin
		rdata1 = `ZeroWord;
	end
end

always @ (*) begin
	if(~rst_n) begin
		rdata2 <= `ZeroWord;
	end else if(raddr2 == 'b0) begin
		rdata2 = `ZeroWord;
	end else if(re2 == `ReadEnable)begin
		if(raddr2 == waddr) begin
			rdata2 = wdata;
		end else begin
			rdata2 = reg_group[raddr2];
		end
	end else begin
		rdata2 = `ZeroWord;
	end
end

endmodule // regfile
