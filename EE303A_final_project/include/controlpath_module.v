
module processor_fsm // FSM for OISC processor
(	input	clk
,	input	rstn
,	input	leq
,	input	a_vs_b

,	output	sram_en
,	output	sram_we
,	output	[2-1 : 0]	addr_sel
,	output	en_a
,	output	en_b_addr
,	output	pc_inc
,	output	pc_br

,	output	a
,	output	b
,	output	c
,	output	an
,	output	bn
,	output	cn
);
//-------------------------------------------------------------------------------------------------
// Implement your own FSM for OISC processor
	wire	a_vs_b_n, leq_n;
	INV	avsbn(.a(a_vs_b), .y(a_vs_b_n));
	INV	leqn(.a(leq), .y(leq_n));

	// input D for DFFRs
	wire 	d_a, d_b, d_c;
	XNOR2	d_a_1	(.a(a), .b(b), .y(d_a));
	
	wire	db1, db2;
	NAND3	db_1	(.a(a_vs_b_n), .b(bn), .c(c), .y(db1));
	NAND2	db_2	(.a(a), .b(c), .y(db2));
	NAND2	db_3	(.a(db1), .b(db2), .y(d_b));

	wire	dc1, dc2, dc3;
	NAND2	dc_1	(.a(a), .b(cn), .y(dc1));
	NAND2	dc_2	(.a(a), .b(bn), .y(dc2));
	NAND2	dc_3	(.a(bn), .b(c), .y(dc3));
	NAND3	dc_4	(.a(dc1), .b(dc2), .c(dc3), .y(d_c));

	// DFFRs	
	DFFR	A	(.d(d_a), .q(a), .qn(an), .rstn(rstn), .clk(clk));
	DFFR	B	(.d(d_b), .q(b), .qn(bn), .rstn(rstn), .clk(clk));
	DFFR	C	(.d(d_c), .q(c), .qn(cn), .rstn(rstn), .clk(clk));

	// combinational logics
	// sram_en
	NAND3	sen_1	(.a(a), .b(b), .c(cn), .y(sram_en));
	// sram_we
	NOR3	swe_1	(.a(a), .b(bn), .c(cn), .y(sram_we));
	// addr_sel[0]
	NOR3	as0_1	(.a(a), .b(cn), .c(b), .y(addr_sel[0]));
	// addr_sel[1]
	wire	as11;
	NOR2	as1_1	(.a(a), .b(c), .y(as11));
	NOR2	as1_2	(.a(as11), .b(bn), .y(addr_sel[1]));
	// en_a
	BUF	en_a_1	(.a(a), .y(en_a));
	// en_b_addr
	NOR3	enba_1	(.a(a), .b(b), .c(cn), .y(en_b_addr));
	// pc_inc
	wire	pcinc1;
	NOR2	pcinc_1	(.a(a), .b(cn), .y(pcinc1));
	NOR2	pcinc_2	(.a(pcinc1), .b(b), .y(pc_inc));
	// pc_br
	NOR4	pcbr_1	(.a(leq_n), .b(a), .c(bn), .d(cn), .y(pc_br));


//-------------------------------------------------------------------------------------------------
endmodule: processor_fsm
