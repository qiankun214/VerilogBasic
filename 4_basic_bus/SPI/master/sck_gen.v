module sck_gen #(
	parameter SPI_MAX_WIDTH_LOG = 4,
	parameter SPI_SCAIL_LOG = 8
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input spi_start,
	input cpol,
	input cpha,
	input [SPI_MAX_WIDTH_LOG - 1:0]spi_width,

	output reg sck_first_edge,sck_second_edge,

	output sck,
	output cs,

	output reg spi_finish
);

localparam INIT = 1'b0,
		   WORK = 1'b1;

localparam SCAIL = 2 ** SPI_SCAIL_LOG - 2,
		   SCAIL_HALF = 2 ** (SPI_SCAIL_LOG - 1) - 2;

reg mode;
reg [SPI_MAX_WIDTH_LOG:0]counte;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		mode <= 'b0;
	end else begin
		case (mode)
			INIT:begin
				if(spi_start) begin
					mode <= WORK;
				end else begin
					mode <= INIT;
				end
			end
			WORK:begin
				if(counte > {1'b0,spi_width}) begin
					mode <= INIT;
				end else begin
					mode <= WORK;
				end
			end
			default:mode <= INIT;
		endcase
	end
end
assign cs = ~mode;

reg [SPI_SCAIL_LOG - 1:0]freq_counte;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		freq_counte <= 'b0;
	end else if(mode == WORK) begin
		freq_counte <= freq_counte + 1'b1;
	end else begin
		freq_counte <= 'b0;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		counte <= 'b0;
	end else if(mode == WORK) begin
		if(freq_counte == SCAIL) begin
			counte <= counte + 1'b1;
		end else begin
			counte <= counte;
		end
	end else begin
		counte <= 'b0;
	end
end

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		spi_finish <= 'b0;
	end else if((counte > spi_width) && (freq_counte == 'b0)) begin
		spi_finish <= 1'b1;
	end else begin
		spi_finish <= 'b0;
	end
end

reg sck_source;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		sck_first_edge <= 'b0;
		sck_second_edge <= 'b0;
		sck_source <= 'b0;
	end else if(freq_counte == SCAIL_HALF) begin
		if((cpha == 1'b1) && (counte == 'b0)) begin
			sck_first_edge <= 1'b0;
		end else begin
			sck_first_edge <= 1'b1;
		end
		sck_source <= ~sck_source;
	end else if(freq_counte == SCAIL) begin
		sck_second_edge <= 1'b1;
		sck_source <= ~sck_source;
	end else if(mode == INIT) begin
		sck_first_edge <= 'b0;
		sck_second_edge <= 'b0;
		sck_source <= 'b0;
	end else begin
		sck_first_edge <= 'b0;
		sck_second_edge <= 'b0;
	end
end
assign sck = (cpol)?(!sck_source):sck_source;

endmodule
