//generated by autoeda

module tb_stack();

parameter WIDTH = 8;
parameter DEPTH_LOG = 4;

logic clk;
logic rst_n;
logic stack_write_req;
logic [WIDTH - 1:0]stack_write_data;
logic stack_read_req;
logic [WIDTH - 1:0]stack_read_data;
logic stack_empty;
logic stack_full;

stack #(
	.WIDTH    (WIDTH),
	.DEPTH_LOG(DEPTH_LOG)
) dut (
	.clk             (clk),
	.rst_n           (rst_n),
	.stack_write_req (stack_write_req),
	.stack_write_data(stack_write_data),
	.stack_read_req  (stack_read_req),
	.stack_read_data (stack_read_data),
	.stack_empty     (stack_empty),
	.stack_full      (stack_full)
);

initial begin
	clk = 0;
	forever begin
		 #50 clk = ~clk;
	end
end

initial begin
	rst_n = 1'b1;
	#5 rst_n = 1'b0;
	#10 rst_n = 1'b1;
end

initial begin
	stack_write_req = 'b0;
	stack_write_data = 'b0;
	stack_read_req = 'b0;
end

task stack_normal_test();
	for (int i = 0; i < 2 ** DEPTH_LOG + 4; i++) begin
		stack_write_data = (WIDTH)'($urandom_range(0,2 ** WIDTH));
		stack_write_req = 1'b1;
		@(negedge clk);
	end
	stack_write_req = 'b0;
	for (int i = 0; i < 2 ** DEPTH_LOG + 4; i++) begin
		stack_read_req = 1'b1;
		@(negedge clk);
	end
	stack_read_req = 'b0;
endtask : stack_normal_test

initial begin
	@(negedge clk);
	@(negedge clk);
	forever begin
		stack_normal_test();
		@(negedge clk);
	end
end

endmodule