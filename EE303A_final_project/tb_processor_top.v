//Do not modify this file except clock period. (line 20)
`timescale 1ns/10ps
module tb_processor_top;

	reg	clk;
	reg	rstn;

	processor_top dut
	(	.clk(clk)
	,	.rstn(rstn)
	);
	
	// clock gen
	initial
	begin
		clk = 1'b0;
		#1;
		@(posedge rstn);
		forever
			#20 clk = ~clk; // The delay in this line is half period of clock.
	end

	initial
	begin
		rstn = 1'b0;
		#15 rstn = 1'b1;
	end

endmodule: tb_processor_top