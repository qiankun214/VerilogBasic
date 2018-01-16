//generated by autoeda
`include "../src/defines.v"
module tb_vector_mul_top();

parameter RAM_ADDR_WIDTH = 1;
parameter DATA_WIDTH = 32;
parameter ORDER_WIDTH = 8;
parameter BAUD = 5207;
parameter BRUST_SIZE_LOG = 2;
parameter ADDR_WIDTH = 9;

logic uart_din;
logic clk;
logic rst_n;
logic uart_dout;

fpga_top dut (
	.uart_din (uart_din),
	.clk      (clk),
	.rst_n    (rst_n),
	.uart_dout(uart_dout)
);

logic [7:0]uart_send_data,uart_receive_data;
logic uart_send_start,uart_send_finish;
logic uart_receive_finish;

uart #(
	.BAUD(5207)
) u_interface (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.uart_din(uart_dout),
	.uart_dout(uart_din),

	.send_start(uart_send_start),
	.send_busy(),
	.send_finish(uart_send_finish),
	.send_data(uart_send_data),

	.receive_start(),
	.receive_busy(),
	.receive_finish(uart_receive_finish),
	.receive_data(uart_receive_data)
);
initial begin
	clk = 0;
	forever begin
		 # 5 clk = ~clk;
	end
end

initial begin
	rst_n = 1'b1;
	#1 rst_n = 1'b0;
	#1 rst_n = 1'b1;
end

task uart_send(input logic[7:0]data);
	@(negedge clk);
	uart_send_start = 1'b1;
	uart_send_data = data;
	@(negedge clk);
	uart_send_start = 'b0;
	while(uart_send_finish != 1'b1) begin
		@(negedge clk);
	end
endtask : uart_send

task test_uart_rebuild(
	input integer num,
	input integer start,
	input integer data[255:0]
);
	uart_send(`DATA_TRAN);
	uart_send(8'(start % 256));
	uart_send(8'(start / 256));
	uart_send(8'((num) / 4));
	for (int i = 0; i < num; i++) begin
		$display("sending %d",data[i]);
		// $display("%d",dut.u_uart_interface_0.u_uart_input_0.tran_counter[BRUST_SIZE_LOG - 1:0]);
		uart_send(8'(data[i]));
	end
endtask : test_uart_rebuild

task uart_receive(output logic[7:0] result_data);
	do begin
		@(negedge clk);
	end while (uart_receive_finish != 1'b1);
	result_data = uart_receive_data;
endtask : uart_receive

integer data[255:0];
initial begin
	logic[7:0]result;
	uart_send_start = 'b0;
	uart_send_data = 'b0;
	for (int i = 0; i < 16; i++) begin
		data[i] = i;
		$display("%d",data[i]);
	end

	repeat(10) begin
		test_uart_rebuild(4,0,data);
		for (int i = 0; i < 4 ; i++) begin
			uart_receive(result);
			$display("receive:%d",result);
		end
	end
end

endmodule
