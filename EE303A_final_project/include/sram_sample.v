module demux_4_n
(	input			a	// input, active high
,	input	[2-1 : 0]	s	// select
	
,	output	[4-1 : 0]	yn	// output, active low
);
	wire	[2-1 : 0]	sb;
	
/*
	assign y = ~(a << s);
*/

	INV	sb0_inv (.a(s[0]), .y(sb[0]));
	INV	sb1_inv (.a(s[1]), .y(sb[1]));

	NAND3	yn0_nand(.a(a), .b(sb[1]), .c(sb[0]), .y(yn[0]));
	NAND3	yn1_nand(.a(a), .b(sb[1]), .c(s [0]), .y(yn[1]));
	NAND3	yn2_nand(.a(a), .b(s [1]), .c(sb[0]), .y(yn[2]));
	NAND3	yn3_nand(.a(a), .b(s [1]), .c(s [0]), .y(yn[3]));
		
endmodule: demux_4_n

module mux_4_sram
(	input	[3 : 0]	a	// input
,	input	[1 : 0]	s	// sel
	
,	output		y	// selected output
);

/*
	assign	y = a[s];
*/

	wire	[3 : 0]	as;
	wire	[1 : 0]	sb;

	INV	sb0_inv
	(	.a(s[0])
	,	.y(sb[0])
	);
	
	INV	sb1_inv
	(	.a(s[1])
	,	.y(sb[1])
	);
	
	AND2	as0_and
	(	.a(sb[0])
	,	.b(sb[1])
	,	.y(as[0])
	);
	
	AND2	as1_and
	(	.a(s[0])
	,	.b(sb[1])
	,	.y(as[1])
	);

	AND2	as2_and
	(	.a(sb[0])
	,	.b(s[1])
	,	.y(as[2])
	);

	AND2	as3_and
	(	.a(s[0])
	,	.b(s[1])
	,	.y(as[3])
	);

	BUFT	as0_bufz
	(	.a(a[0])
	,	.b(as[0])
	,	.y(y)
	);

	BUFT	as1_bufz
	(	.a(a[1])
	,	.b(as[1])
	,	.y(y)
	);
	
	BUFT	as2_bufz
	(	.a(a[2])
	,	.b(as[2])
	,	.y(y)
	);

	BUFT	as3_bufz
	(	.a(a[3])
	,	.b(as[3])
	,	.y(y)
	);

endmodule: mux_4_sram


module predecoder_latched
(	input	clk
,	input	rstn

,	input	[12-1:0]	addr_d	// differential output (1: original 0:inverted)
,	output	[16-1:0]	predec_n  // active low output
);
	
	generate
		genvar i;
		genvar j;
		
		for (i = 0; i < 2; i = i + 1)
		begin
			// i = 0: addr[2:0], i = 1: addr[5:3]
			for (j = 0; j < 8; j = j + 1)
			begin
				wire predec_before_ff;
				// j=0: 000, j=1: 001, j=2: 010, j=3: 011, j=4: 100, j=5: 101, j=6: 110, j=7: 111
				NAND3	nand_predec
				(	.a(addr_d[(j & 1) * 6 + i * 3])
				,	.b(addr_d[((j >> 1) & 1) * 6 + i * 3 + 1])
				,	.c(addr_d[((j >> 2) & 1) * 6 + i * 3 + 2])
				,	.y(predec_before_ff)
				);
				
				// samples predec results for faster clk to dout delay
				DFFR	ff_predec
				(	.d(predec_before_ff)
				,	.clk(clk)
				,	.rstn(rstn)
				,	.q(predec_n[i * 8 + j])
				);
			end
		end
	endgenerate
	
endmodule: predecoder_latched

module decoder_64_latched
(	input	clk
,	input	rstn
,	input	[6-1 : 0]	addr	// address input
,	input	read
,	input	write
	
,	output	[64-1 : 0]	rwl	// output
,	output	[64-1 : 0]	wwl	// output
);

	wire	[6-1:0]	addr_n;
	wire	[16-1:0]	predec_n;

	genvar i;
	generate
		for (i = 0; i < 6; i = i + 1)
		begin
			INV inv_addr
			(	.a(addr[i])
			,	.y(addr_n[i])
			);
		end
	endgenerate
	
	predecoder_latched predec
	(	.clk(clk)
	,	.rstn(rstn)
	,	.addr_d({ addr, addr_n })
	,	.predec_n(predec_n)
	);
	
	wire	[4-1:0]	write_n;
	wire	[4-1:0]	read_n;

	generate
		for (i = 0; i < 4; i = i + 1)
		begin
			INV	inv_write
			(	.a(write)
			,	.y(write_n[i])
			);

			INV	inv_read
			(	.a(read)
			,	.y(read_n[i])
			);
		end
		for (i = 0; i < 64; i = i + 1)
		begin
			NOR3	nor_rwl
			(	.a(read_n[i >> 4])
			,	.b(predec_n[i & 3'b111])
			,	.c(predec_n[8 + ((i >> 3) & 3'b111)])
			,	.y(rwl[i])
			);
			
			NOR3	nor_wwl
			(	.a(write_n[i >> 4])
			,	.b(predec_n[i & 3'b111])
			,	.c(predec_n[8 + ((i >> 3) & 3'b111)])
			,	.y(wwl[i])
			);
		end
	endgenerate	
	
endmodule: decoder_64_latched

module mux_2_tg
(	input	[2-1 : 0]	a	// input
,	input	[1-1 : 0]	s	// sel
	
,	output		y	// selected output
);

/*
	assign	y = a[s];
*/

	BUFTL	as0_buf
	(	.a(a[0])
	,	.b(s)
	,	.y(y)
	);

	BUFT	as1_buf
	(	.a(a[1])
	,	.b(s)
	,	.y(y)
	);
	
endmodule: mux_2_tg

module clock_gate_buf
#(
	parameter N_out	= 4
)
(	input	clk
,	input	rstn
,	input	ce	// clock enable active high
,	output	[N_out-1:0]	clk_gated
);

	wire	ce_latched;
	wire	clkn;
	wire	clk_gated_n;
	
	INV	inv_clkn(.a(clk), .y(clkn));

	// samples clock enable signal when clock is low
	LATS	lat_ce
	(	.d(ce)
	,	.en(clkn)
	,	.setn(rstn)
	,	.q(ce_latched)
	);
	
	// multiple and gates to drive more than 16 inputs
	generate
		genvar i;
		for (i = 0; i < N_out; i = i + 1)
		begin
			AND2	nand_clk_gate
			(	.a(clk)
			,	.b(ce_latched)
			,	.y(clk_gated[i])
			);
		end
	endgenerate

endmodule: clock_gate_buf

module delay
#(	parameter	N_del = 3 // Can't be less than 2
,	parameter	Do_inv	= 0
)
(	input	a
,	output	y
);

	wire	[N_del-2:0]	del;
	generate
		genvar i;
		BUF	buf_del_s
		(	.a(a)
		,	.y(del[0])
		);
		for (i = 0; i < N_del-2; i = i + 1)
		begin
			BUF	buf_del
			(	.a(del[i])
			,	.y(del[i + 1])
			);
		end
		if (Do_inv)
		begin
			INV	buf_del_e
			(	.a(del[N_del-2])
			,	.y(y)
			);
		end
		else
		begin
			BUF	buf_del_e
			(	.a(del[N_del-2])
			,	.y(y)
			);
		end
	endgenerate

endmodule: delay

module pulse_gen
(	input	clk
,	input	rstn
,	input	enable	// when using sram
,	input	write_enable	// 0: read, 1: write
,	output	read_pulse
,	output	write_pulse
);

	wire	clk_d;
	wire	clk_d_n;
	
	delay	
	#(	.N_del(2)
	,	.Do_inv(1)
	)	inc_clk
	(	.a(clk)
	,	.y(clk_d_n)
	);

	// generate write pulse using delay lines

	wire	write_enable_n;
	INV	inv_we
	(	.a(write_enable)
	,	.y(write_enable_n)
	);
	
	wire	write_before;

	AND2	and_write
	(	.a(enable)
	,	.b(write_enable)
	,	.y(write_before)
	);
	
	AND3	and_write_pulse
	(	.a(clk)
	,	.b(clk_d_n)
	,	.c(write_before)
	,	.y(write_pulse_f)
	);

	delay	
	#(	.N_del(3)
	,	.Do_inv(0)
	)	del_write_pulse
	(	.a(write_pulse_f)
	,	.y(write_pulse)
	);

	// generate read pulse using SR latch

	wire	read_before;
	wire	read_before_d;
	wire	read_n_pulse;
	wire	read_n_pulse_d;
	wire	read_n_pulse_dd;
	wire	read_pulse_n;
	
	AND2	and_read
	(	.a(enable)
	,	.b(write_enable_n)
	,	.y(read_before)
	);
		
	NAND3	nand_read_pulse
	(	.a(clk)
	,	.b(clk_d_n)
	,	.c(read_before)
	,	.y(read_n_pulse)
	);

	delay	
	#(	.N_del(3)
	,	.Do_inv(0)
	)	del_read_pulse
	(	.a(read_n_pulse)
	,	.y(read_n_pulse_d)
	);

	delay	
	#(	.N_del(4)
	,	.Do_inv(0)
	)	del_read_pulse_d
	(	.a(read_n_pulse_d)
	,	.y(read_n_pulse_dd)
	);

	// two nand gates for SR latch
	NAND2	read_lat_q
	(	.a(read_n_pulse_d)
	,	.b(read_pulse_n)
	,	.y(read_pulse)
	);
	
	NAND3	read_lat_qn
	(	.a(read_n_pulse_dd)
	,	.b(read_pulse)
	,	.c(rstn)
	,	.y(read_pulse_n)
	);
	
endmodule: pulse_gen

module sram // clock sram
(	input	clk
,	input	rstn
,	input	[8-1:0]	addr	// Position of accessed data
,	input	[8-1:0]	data_in	// Used for write. New data to be written
,	input	enable	// when using sram
,	input	write_enable	// 0: read, 1: write

,	output	[8-1:0]	data_out

,	output	[64-1 : 0]	rwl
,	output	[64-1 : 0]	wwl
,	output	[32-1 : 0]	wbl
,	output	[32-1 : 0]	wblb
,	input	[32-1 : 0]	rbl	
);

	wire	[2-1:0]	clk_gated;
	
	// clock gating for enable
	clock_gate_buf
	#(	.N_out(2)
	)	clk_gate
	(	.clk(clk)
	,	.rstn(rstn)
	,	.ce(enable)
	,	.clk_gated(clk_gated)
	);

	// generates read / write pulses
	// used for gating wordlines and sampliing dout 
	wire	read_pulse;
	wire	write_pulse;
	pulse_gen pulse_gen
	(	.clk(clk)
	,	.rstn(rstn)
	,	.enable(enable)
	,	.write_enable(write_enable)
	,	.read_pulse(read_pulse)
	,	.write_pulse(write_pulse)
	);

	// decoder for driving word lines
	decoder_64_latched dec
	(	.clk(clk_gated[0])
	,	.rstn(rstn)
	,	.addr(addr[7:2])
	,	.read(read_pulse)
	,	.write(write_pulse)
	,	.rwl(rwl)
	,	.wwl(wwl)
	);

	// column mux / demux structure
	wire	[2-1:0]	column_sel;
	wire	[2-1:0]	column_sel_n;
	wire	[8-1:0]	data_out_before_lat;

	wire	[8-1:0]	data_in_latched;
	wire	[8-1:0]	data_in_latched_n;
	
	generate
		genvar i;
		genvar j;
		
		// samples column selection value (LSB 2 bits of addr)
		for (i = 0; i < 2; i = i + 1)
		begin
			DFFR	ff_column_sel
			(	.d(addr[i])
			,	.clk(clk)
			,	.rstn(rstn)
			,	.q(column_sel[i])
			,	.qn(column_sel_n[i])
			);
		end
		
		// column mux / latch for read (data out)
		for (i = 0; i < 8; i = i + 1)
		begin
			wire	[2-1:0]	sel;
			for (j = 0; j < 2; j = j + 1)
			begin
				INV	inv_sel
				(	.a(column_sel_n[j])
				,	.y(sel[j])
				);
			end
			mux_4_sram	mux_dout
			(	.a({ rbl[i + 8*3], rbl[i + 8*2], rbl[i + 8*1], rbl[i + 8*0] })
			,	.s(sel)
			,	.y(data_out_before_lat[i])
			);
			
			// latch for storing dout value
			LATR	lat_dout
			(	.d(data_out_before_lat[i])
			,	.en(read_pulse)
			,	.rstn(rstn)
			,	.q(data_out[i])
			);
		end
		
		// data_in sampler and column demux for write
		for (i = 0; i < 8; i = i + 1)
		begin
			wire	[2-1:0]	sel;
			for (j = 0; j < 2; j = j + 1)
			begin
				BUF	buf_sel
				(	.a(column_sel[j])
				,	.y(sel[j])
				);
			end
			DFFR	ff_din
			(	.d(data_in[i])
			,	.clk(clk_gated[1])
			,	.rstn(rstn)
			,	.q(data_in_latched[i])
			,	.qn(data_in_latched_n[i])
			);
			
			demux_4_n demux_wbl
			(	.a(data_in_latched_n[i])
			,	.s(sel)
			,	.yn({ wbl[i + 8*3], wbl[i + 8*2], wbl[i + 8*1], wbl[i + 8*0] })
			);
			
			demux_4_n demux_wblb
			(	.a(data_in_latched[i])
			,	.s(sel)
			,	.yn({ wblb[i + 8*3], wblb[i + 8*2], wblb[i + 8*1], wblb[i + 8*0] })
			);
		end
		
	endgenerate

endmodule: sram
