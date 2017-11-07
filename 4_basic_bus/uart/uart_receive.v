module uart_receive (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	output reg receive_start,

	input baud_mid,
	input baud_busy,
	input [3:0]baud_counte,

	output reg [7:0]receive_data,
	input uart_din
);

// generate "start" of baud
reg uart_din_delay;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		uart_din_delay <= 'b0;
	end else begin
		uart_din_delay <= uart_din;
	end
end

always @ (*) begin
	if(baud_busy) begin
		receive_start = 'b0;
	end else if((uart_din_delay == 1'b1) && (uart_din == 1'b0)) begin
		receive_start = 1'b1;
	end else begin
		receive_start = 'b0;
	end
end

// data flow
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		receive_data <= 'b0;
	end else if(baud_mid) begin
		case (baud_counte)
			4'd1:receive_data[0] <= uart_din;
			4'd2:receive_data[1] <= uart_din;
			4'd3:receive_data[2] <= uart_din;
			4'd4:receive_data[3] <= uart_din;
			4'd5:receive_data[4] <= uart_din;
			4'd6:receive_data[5] <= uart_din;
			4'd7:receive_data[6] <= uart_din;
			4'd8:receive_data[7] <= uart_din;
			default:receive_data <= receive_data;
		endcase
	end
end

endmodule