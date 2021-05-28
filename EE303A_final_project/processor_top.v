`include "./include/controlpath_module.v"
`include "./include/datapath_modules.v"
`include "./include/gates.v"
`include "./include/sram_array.v"
`include "./include/sram_sample.v"

// ***************************************

module processor_top
(	input	clk
,	input	rstn
);

// ***************************************
// * SRAM

	wire	[8-1:0]	sram_addr;
	wire	[8-1:0]	sub_out;	
	wire	sram_en;
	wire	sram_we;

	wire	[8-1:0]	sram_dout;
	wire	[7 : 0]	sub_out_m;
	wire	[64-1 : 0]	rwl;
	wire	[64-1 : 0]	wwl;
	wire	[32-1 : 0]	wbl;
	wire	[32-1 : 0]	wblb;
	wire	[32-1 : 0]	rbl;

	sram sram
	(	.clk(clk)
	,	.rstn(rstn)
	
	,	.addr(sram_addr)
	,	.data_in(sub_out_m)
	,	.enable(sram_en)
	,	.write_enable(sram_we)
	
	,	.data_out(sram_dout)
	
	,	.rwl(rwl)
	,	.wwl(wwl)
	,	.wbl(wbl)
	,	.wblb(wblb)
	,	.rbl(rbl)
	);

	sram_array_64_32	sram_array
	(	.rwl(rwl)
	,	.wwl(wwl)
	,	.wbl(wbl)
	,	.wblb(wblb)
	,	.rbl(rbl)
	);

// ***************************************
// * 4 Registers: A, B (addr / data), C

	wire [8-1 : 0]	reg_a_q;
	wire [8-1 : 0]	reg_b_addr_q;
	wire [8-1 : 0]	reg_b_data_q;
	wire [8-1 : 0]	reg_c_q;
	
	wire			en_a;
	wire			en_b_addr;
	wire [1 : 0]	addr_sel;

	wire	st_a, st_b, st_c, st_an, st_bn, st_cn;
	wire	clkn;
	INV	inv_clk (.a(clk), .y(clkn));
	
	wire	[7 : 0]	temp_b;
	wire	[7 : 0]	delay_sr;
	wire	[7 : 0]	delay_sr_2;
	wire	en2, en2_1;
	NAND3	sel2(.a(st_an), .b(st_bn), .c(st_c), .y(en2));
	NOR2	sel2_1	(.a(en2), .b(clk), .y(en2_1));
	generate
		genvar j;
		for (j=0; j<8; j=j+1) begin
			BUF	buf_sr	(.a(sram_dout[j]), .y(delay_sr[j]));
		end
	endgenerate


	register 
	#(	.N(8)
	)	reg_a
	(	.clk(clk)
	,	.rstn(rstn)
	,	.en(en_a)
	,	.d(delay_sr)
	,	.q(reg_a_q)
	);


	wire	en_b_gating;
	AND2	clk_neg2 (.a(en_b_addr), .b(clkn), .y(en_b_gating));
	register 
	#(	.N(8)
	)	reg_b_addr
	(	.clk(clk)
	,	.rstn(rstn)
	,	.en(en_b_addr)
	,	.d(delay_sr)
	,	.q(reg_b_addr_q)
	);

	wire	pc_inc;
	wire	[7 : 0]	temp_a;
	wire	en1, en1_1;
	NAND3	sel1(.a(st_a), .b(st_bn), .c(st_cn), .y(en1));
	NOR2	sel1_1	(.a(en1), .b(clk), .y(en1_1));
	mux_8 	mux8_1
	(	.a(sram_dout)
	,	.b(temp_a)
	,	.sel(en1_1)
	,	.y(temp_a)
	);


	mux_8	mux8_2
	(	.a(delay_sr)
	,	.b(temp_b)
	,	.sel(en2_1)
	,	.y(temp_b)
	);


	wire	a_vs_b;
	compare	compare_a_and_b
	(	.a(temp_a)
	,	.b(temp_b)
	,	.y(a_vs_b)
	);


// ***************************************
// * Program Counter

	wire	[8-1 : 0]	pc_addr;
	wire	pc_br;

	program_counter	pc
	(	.clk(clk)
	,	.rstn(rstn)
	,	.inc(pc_inc)
	,	.branch(pc_br)
	,	.new_addr(sram_dout)
	,	.addr(pc_addr)
	);

// ***************************************
// * Mux for Selecting Memory Address	
	mux_bus_24_to_8	mux_sram_addr
	(	.i({ reg_b_addr_q, reg_a_q, pc_addr })
	,	.s(addr_sel)
	,	.y(sram_addr)
	);
	
// ***************************************
// * Subtractor, using adder and invertor

	wire	[7 : 0]	temp_a_d;
	wire	en3, en3_1;
	NAND3	sel3	(.a(st_a), .b(st_b), .c(st_c), .y(en3));
	NOR2	sel3_1	(.a(en3), .b(clk), .y(en3_1));
	mux_8	a_inv_mux
	(	.a(sram_dout)
	,	.b(temp_a_d)
	,	.sel(en3_1)
	,	.y(temp_a_d)
	);

	wire	[7 : 0]	a_inv;
	generate
		genvar i;
		for (i=0 ; i<8 ; i=i+1) begin
			INV	inv_a(.a(temp_a_d[i]), .y(a_inv[i]));
		end
	endgenerate


	wire	[7 : 0]	temp_b_d;
	wire	en4, en4_1;
	NAND3	sel4	(.a(st_a), .b(st_b), .c(st_cn), .y(en4));
	NOR2	sel4_1	(.a(en4), .b(clk), .y(en4_1));
	mux_8	b_d_mux
	(	.a(sram_dout)
	,	.b(temp_b_d)
	,	.sel(en4_1)
	,	.y(temp_b_d)
	);

	wire	zero, one;
	TIEHI	tie_one(.y(one));
	TIELO	tie_zero(.y(zero));

	wire	lo_cout;


	adder_4
	adder_lo
	(	.a(temp_b_d[3:0])
	,	.b(a_inv[3:0])
	,	.ci(one)
	,	.s(sub_out[3:0])
	,	.co(lo_cout)
	);
	
	adder_4
	adder_hi
	(	.a(temp_b_d[7:4])
	,	.b(a_inv[7:4])
	,	.ci(lo_cout)
	,	.s(sub_out[7:4])
	);

// a size!
	mux_8 sub_out_mux
	(	.a({zero,zero,zero,zero,zero,zero,zero,zero})
	,	.b(sub_out)
	,	.sel(a_vs_b)
	,	.y(sub_out_m)
	);
	
// ***************************************
// * Comparator (less than or equal to zero)

	wire	leq_out;
	
	less_than_or_equal_to_zero	leq_leq
	(	.a(sub_out_m)
	,	.y(leq_out)
	);

	wire	temp_leq;
	wire	en5;
	AND3	sel5	(.a(st_a), .b(st_bn), .c(st_c), .y(en5));
	mux_1	leq_mux
	(	.a(leq_out)
	,	.b(temp_leq)
	,	.sel(en5)
	,	.y(temp_leq)
	);

	
// ***************************************
// * FSM for Control Signal Generation

	processor_fsm fsm
	(	.clk(clk)
	,	.rstn(rstn)
	,	.leq(temp_leq)
	,	.a_vs_b(a_vs_b)


	,	.sram_en(sram_en)
	,	.sram_we(sram_we)
	,	.addr_sel(addr_sel)
	,	.en_a(en_a)
	,	.en_b_addr(en_b_addr)
	,	.pc_inc(pc_inc)
	,	.pc_br(pc_br)
	,	.a(st_a)
	,	.b(st_b)
	,	.c(st_c)
	,	.an(st_an)
	,	.bn(st_bn)
	,	.cn(st_cn)
	);

endmodule: processor_top
