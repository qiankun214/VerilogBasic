module io_pad (

	input  io_clk,
	output  clk,

	input  io_rst_n,
	output  rst_n,

	input  io_config_req,
	output  config_req,

	input [5:0] io_config_data,
	output [5:0] config_data,

	output  io_cpol,
	input  cpol,

	output  io_cpha,
	input  cpha,

	output [3:0] io_spi_width,
	input [3:0] spi_width
);
PLBI2F io_clk_0 (
	.CONOF(1'b1),
	.SONOF(1'b0),
	.A    (1'b0),
	.E    (1'b0),
	.PU   (1'b0),
	.PD   (1'b0),
	.P    (io_clk),
	.D    (clk)
);
PLBI2F io_rst_n_0 (
	.CONOF(1'b1),
	.SONOF(1'b0),
	.A    (1'b0),
	.E    (1'b0),
	.PU   (1'b0),
	.PD   (1'b0),
	.P    (io_rst_n),
	.D    (rst_n)
);
PLBI2F io_config_req_0 (
	.CONOF(1'b1),
	.SONOF(1'b0),
	.A    (1'b0),
	.E    (1'b0),
	.PU   (1'b0),
	.PD   (1'b0),
	.P    (io_config_req),
	.D    (config_req)
);
PLBI2F io_config_data_0 (
	.CONOF(1'b1),
	.SONOF(1'b0),
	.A    (1'b0),
	.E    (1'b0),
	.PU   (1'b0),
	.PD   (1'b0),
	.P    (io_config_data),
	.D    (config_data)
);
PLBI2F io_config_data_1 (
	.CONOF(1'b1),
	.SONOF(1'b0),
	.A    (1'b0),
	.E    (1'b0),
	.PU   (1'b0),
	.PD   (1'b0),
	.P    (io_config_data[1]),
	.D    (config_data[1])
);
PLBI2F io_config_data_2 (
	.CONOF(1'b1),
	.SONOF(1'b0),
	.A    (1'b0),
	.E    (1'b0),
	.PU   (1'b0),
	.PD   (1'b0),
	.P    (io_config_data[2]),
	.D    (config_data[2])
);
PLBI2F io_config_data_3 (
	.CONOF(1'b1),
	.SONOF(1'b0),
	.A    (1'b0),
	.E    (1'b0),
	.PU   (1'b0),
	.PD   (1'b0),
	.P    (io_config_data[3]),
	.D    (config_data[3])
);
PLBI2F io_config_data_4 (
	.CONOF(1'b1),
	.SONOF(1'b0),
	.A    (1'b0),
	.E    (1'b0),
	.PU   (1'b0),
	.PD   (1'b0),
	.P    (io_config_data[4]),
	.D    (config_data[4])
);
PLBI2F io_config_data_5 (
	.CONOF(1'b1),
	.SONOF(1'b0),
	.A    (1'b0),
	.E    (1'b0),
	.PU   (1'b0),
	.PD   (1'b0),
	.P    (io_config_data[5]),
	.D    (config_data[5])
);
PLBI2F io_cpol_0 (
	.CONOF(1'b0),
	.SONOF(1'b0),
	.A    (cpol),
	.E    (1'b1),
	.PU   (1'b0),
	.PD   (1'b0),
	.P    (io_cpol),
	.D    ()
);
PLBI2F io_cpha_0 (
	.CONOF(1'b0),
	.SONOF(1'b0),
	.A    (cpha),
	.E    (1'b1),
	.PU   (1'b0),
	.PD   (1'b0),
	.P    (io_cpha),
	.D    ()
);
PLBI2F io_spi_width_0 (
	.CONOF(1'b0),
	.SONOF(1'b0),
	.A    (spi_width),
	.E    (1'b1),
	.PU   (1'b0),
	.PD   (1'b0),
	.P    (io_spi_width),
	.D    ()
);
PLBI2F io_spi_width_1 (
	.CONOF(1'b0),
	.SONOF(1'b0),
	.A    (spi_width[1]),
	.E    (1'b1),
	.PU   (1'b0),
	.PD   (1'b0),
	.P    (io_spi_width[1]),
	.D    ()
);
PLBI2F io_spi_width_2 (
	.CONOF(1'b0),
	.SONOF(1'b0),
	.A    (spi_width[2]),
	.E    (1'b1),
	.PU   (1'b0),
	.PD   (1'b0),
	.P    (io_spi_width[2]),
	.D    ()
);
PLBI2F io_spi_width_3 (
	.CONOF(1'b0),
	.SONOF(1'b0),
	.A    (spi_width[3]),
	.E    (1'b1),
	.PU   (1'b0),
	.PD   (1'b0),
	.P    (io_spi_width[3]),
	.D    ()
);
endmodule
