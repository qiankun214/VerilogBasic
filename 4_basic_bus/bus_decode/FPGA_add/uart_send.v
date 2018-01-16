module uart_send (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input send_start,
	input baud_busy,

	input [3:0]baud_counte,

	input [7:0]send_data,
	output reg uart_dout
);

// lock data
reg [7:0]send_data_lock;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		send_data_lock <= 'b0;
	end else if(send_start) begin
		send_data_lock <= send_data;
	end
end

// data flow
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		uart_dout <= 1'b1;
	end else if(baud_busy) begin
		case (baud_counte)
			4'd0:uart_dout <= 1'b0;
			4'd1:uart_dout <= send_data_lock[0];
			4'd2:uart_dout <= send_data_lock[1];
			4'd3:uart_dout <= send_data_lock[2];
			4'd4:uart_dout <= send_data_lock[3];
			4'd5:uart_dout <= send_data_lock[4];
			4'd6:uart_dout <= send_data_lock[5];
			4'd7:uart_dout <= send_data_lock[6];
			4'd8:uart_dout <= send_data_lock[7];
			default:uart_dout <= 1'b1;
		endcase
	end
end

endmodule