module uart_baud_gen #(
	parameter BAUD = 5207
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input baud_start,
	output reg baud_mid,
	output reg baud_final,
	output baud_busy,

	output reg [3:0]baud_counte
);

localparam INIT = 1'b0;
localparam WORK = 1'b1;

reg mode,next_mode;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		mode <= 0;
	end else begin
		mode <= next_mode;
	end
end

always @ (*) begin
	case (mode)
		INIT:begin
			if(baud_start) begin
				next_mode = WORK;
			end else begin
				next_mode = INIT;
			end
		end
		WORK:begin
			if(baud_counte == 4'd10) begin
				next_mode = INIT;
			end else begin
				next_mode = WORK;
			end
		end
		default:next_mode = INIT;
	endcase
end
assign baud_busy = mode;

// counter for generating baud
reg [12:0]counter;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		counter <= 'b0;
	end else if(mode == WORK) begin
		if(counter == BAUD) begin
			counter <= 'b0;
		end else begin
			counter <= counter + 1'b1;
		end
	end
end

// counter for data flow
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		baud_counte <= 'b0;
	end else if(mode == INIT) begin
		baud_counte <= 'b0;
	end else if(counter == BAUD) begin
		baud_counte <= baud_counte + 1'b1;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		baud_mid <= 'b0;
	end else if(counter == BAUD / 2) begin
		baud_mid <= 1'b1;
	end else begin
		baud_mid <= 'b0;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		baud_final <= 'b0;
	end else if(baud_counte == 4'd10) begin
		baud_final <= 1'b1;
	end else begin
		baud_final <= 'b0;
	end
end

endmodule

