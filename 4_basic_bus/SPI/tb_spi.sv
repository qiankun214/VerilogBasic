module tb_spi (
);

parameter SPI_MAX_WIDTH_LOG = 4;
parameter SPI_SCAIL_LOG = 8;
parameter SPI_WIDTH = 16;

logic clk;    // Clock
logic rst_n;  // Asynchronous reset active low

logic master_spi_start;
logic master_spi_finish;
logic slave_spi_start;
logic slave_spi_finish;

logic sck;
logic cs;
logic mosi;
logic miso;

logic config_req;
logic [SPI_MAX_WIDTH_LOG + 1:0]config_data;

logic [2 ** SPI_MAX_WIDTH_LOG - 1:0]master_din;
logic [2 ** SPI_MAX_WIDTH_LOG - 1:0]master_dout;
logic [2 ** SPI_MAX_WIDTH_LOG - 1:0]slave_din;
logic [2 ** SPI_MAX_WIDTH_LOG - 1:0]slave_dout;

spi_interface_master #(
	.SPI_MAX_WIDTH_LOG(SPI_MAX_WIDTH_LOG),
	.SPI_SCAIL_LOG(SPI_SCAIL_LOG)
) u_master (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.spi_start(master_spi_start),
	.spi_finish(master_spi_finish),

	.sck(sck),
	.cs(cs),
	.mosi(mosi),
	.miso(miso),

	.config_req(config_req),
	.config_data(config_data),

	.din(master_din),
	.dout(master_dout)
);

spi_interface_slave #(
	.SPI_MAX_WIDTH_LOG(SPI_MAX_WIDTH_LOG)
) u_receive (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.spi_start(slave_spi_start),
	.spi_finish(slave_spi_finish),

	.sck(sck),
	.cs(cs),
	.mosi(mosi),
	.miso(miso),

	.config_req(config_req),
	.config_data(config_data),

	.din(slave_din),
	.dout(slave_dout)
);

initial begin
	clk = 'b0;
	forever begin
		#50 clk = ~clk;
	end
end

initial begin
	rst_n = 1'b1;
	#5 rst_n = 'b0;
	#10 rst_n = 1'b1;
end

initial begin
	master_spi_start = 'b0;
	master_din = 'b0;
	slave_din = 'b0;
	config_req = 'b0;
	config_data = 'b0;

	@(negedge clk);
	config_req = 1'b1;
	config_data = {2'b10,(SPI_MAX_WIDTH_LOG)'(SPI_WIDTH - 1)};
	@(negedge clk);

	forever begin
		@(negedge clk);
		master_din = (SPI_WIDTH)'($urandom_range(0,2 ** SPI_WIDTH));
		slave_din = (SPI_WIDTH)'($urandom_range(0,2 ** SPI_WIDTH));
		master_spi_start = 1'b1;
		@(negedge clk);
		master_spi_start = 1'b0;

		while(slave_spi_finish != 1'b1) begin
			@(negedge clk);
		end
		$display("%h\-\>%h",master_dout,slave_din);
		$display("%h\-\>%h",slave_dout,master_din);
		if((master_din != slave_dout) || (master_dout != slave_din)) begin
			$stop;
		end
	end

end
endmodule
