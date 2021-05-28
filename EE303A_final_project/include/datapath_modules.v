module register
#(	parameter N = 8
)
(	input	clk
,	input	rstn
,	input	en
,	input	[N-1 : 0]	d
,	output	[N-1 : 0]	q
);

	wire	new_clk;
	AND2	ff_clk	(.a(clk), .b(en), .y(new_clk));

	generate
		genvar i;
		for (i=0 ; i<N ; i=i+1) begin
			DFFR	dffr	(.clk(new_clk), .q(q[i]), .qn(), .d(d[i]), .rstn(rstn));
		end
	endgenerate
	
endmodule: register

module program_counter
(	input	clk
,	input	rstn
,	input	inc
,	input	branch
,	input	[8-1 : 0]	new_addr
,	output	[8-1 : 0]	addr
);

	wire	[7:0] d;
	BUFT	buf_newaddr0 (.a(new_addr[0]), .b(branch), .y(d[0]));
	wire	inc_cond_d03, nbranch;
	INV	inv_nbranch (.a(branch), .y(nbranch));
	NAND2	nand_inccondd03 (.a(nbranch), .b(inc), .y(inc_cond_d03));
	INVTL	inv_addr0 (.a(addr[0]), .b(inc_cond_d03), .y(d[0]));
	wire	nochange_cond_d07;
	NOR2	nor_nochangecondd07 (.a(branch), .b(inc), .y(nochange_cond_d07));
	BUFT	buf_addr0 (.a(addr[0]), .b(nochange_cond_d07), .y(d[0]));
	
	BUFT	buf_newaddr1 (.a(new_addr[1]), .b(branch), .y(d[1]));
	wire	addr1plus;
	XOR2	xor_addr1plus (.a(addr[1]), .b(addr[0]), .y(addr1plus));
	BUFTL	buf_addr1plus (.a(addr1plus), .b(inc_cond_d03), .y(d[1]));
	BUFT	buf_addr1 (.a(addr[1]), .b(nochange_cond_d07), .y(d[1]));

	BUFT	buf_newaddr2 (.a(new_addr[2]), .b(branch), .y(d[2]));
	wire	addr2plus, addr10and;
	AND2	and_addr10and (.a(addr[1]), .b(addr[0]), .y(addr10and));
	XOR2	xor_addr2plus (.a(addr[2]), .b(addr10and), .y(addr2plus));
	BUFTL	buf_addr2plus (.a(addr2plus), .b(inc_cond_d03), .y(d[2]));
	BUFT	buf_addr2 (.a(addr[2]), .b(nochange_cond_d07), .y(d[2]));

	BUFT	buf_newaddr3 (.a(new_addr[3]), .b(branch), .y(d[3]));
	wire	addr3plus, addr210and;
	AND3	and_addr210and (.a(addr[2]), .b(addr[1]), .c(addr[0]), .y(addr210and));
	XOR2	xor_addr3plus (.a(addr[3]), .b(addr210and), .y(addr3plus));
	BUFTL	buf_addr3plus (.a(addr3plus), .b(inc_cond_d03), .y(d[3]));
	BUFT	buf_addr3 (.a(addr[3]), .b(nochange_cond_d07), .y(d[3]));

	BUFT	buf_newaddr4 (.a(new_addr[4]), .b(branch), .y(d[4]));
	wire	inc_cond_d47, addr3210and;
	AND4	and_addr3210and (.a(addr[3]), .b(addr[2]), .c(addr[1]), .d(addr[0]), .y(addr3210and));
	NAND3	nand_inccondd47 (.a(nbranch), .b(inc), .c(addr3210and), .y(inc_cond_d47));
	INVTL	inv_addr4 (.a(addr[4]), .b(inc_cond_d47), .y(d[4]));
	BUFT	buf_addr4 (.a(addr[4]), .b(nochange_cond_d07), .y(d[4]));
	wire	nochange_cond_d47, addr3210nand;
	NAND4	nand_addr3210nand (.a(addr[3]), .b(addr[2]), .c(addr[1]), .d(addr[0]), .y(addr3210nand));
	NAND3	nand_nochangecondd47 (.a(nbranch), .b(inc), .c(addr3210nand), .y(nochange_cond_d47));
	BUFTL	buftl_addr4 (.a(addr[4]), .b(nochange_cond_d47), .y(d[4]));

	BUFT	buf_newaddr5 (.a(new_addr[5]), .b(branch), .y(d[5]));
	wire	addr5plus;
	XOR2	xor_addr5plus (.a(addr[5]), .b(addr[4]), .y(addr5plus));
	BUFTL	buf_addr5plus (.a(addr5plus), .b(inc_cond_d47), .y(d[5]));
	BUFT	buf_addr5 (.a(addr[5]), .b(nochange_cond_d07), .y(d[5]));
	BUFTL	buftl_addr5 (.a(addr[5]), .b(nochange_cond_d47), .y(d[5]));

	BUFT	buf_newaddr6 (.a(new_addr[6]), .b(branch), .y(d[6]));
	wire	addr6plus, addr54and;
	AND2	and_addr54and (.a(addr[5]), .b(addr[4]), .y(addr54and));
	XOR2	xor_addr6plus (.a(addr[6]), .b(addr54and), .y(addr6plus));
	BUFTL	buf_addr6plus (.a(addr6plus), .b(inc_cond_d47), .y(d[6]));
	BUFT	buf_addr6 (.a(addr[6]), .b(nochange_cond_d07), .y(d[6]));
	BUFTL	buftl_addr6 (.a(addr[6]), .b(nochange_cond_d47), .y(d[6]));

	BUFT	buf_newaddr7 (.a(new_addr[7]), .b(branch), .y(d[7]));
	wire	addr7plus, addr654and;
	AND3	and_add654and (.a(addr[6]), .b(addr[5]), .c(addr[4]), .y(addr654and));
	XOR2	xor_addr7plus (.a(addr[7]), .b(addr654and), .y(addr7plus));
	BUFTL	buf_addr7plus (.a(addr7plus), .b(inc_cond_d47), .y(d[7]));
	BUFT	buf_addr7 (.a(addr[7]), .b(nochange_cond_d07), .y(d[7]));
	BUFTL	buftl_addr7 (.a(addr[7]), .b(nochange_cond_d47), .y(d[7]));

	generate
		genvar i;
		for (i=0; i<8; i=i+1)
		begin: dff_addr
			DFFR	dff_addri (.d(d[i]), .clk(clk), .rstn(rstn), .q(addr[i]));
		end
	endgenerate



endmodule: program_counter


module mux_3
(	input	[3-1 : 0]	a
,	input	[2-1 : 0]	s

,	output			y
);
	wire	a10;
	mux_2	a_10	(.a(a[1:0]), .s(s[0]), .y(a10));
	mux_2	a_y	(.a({a[2], a10}), .s(s[1]), .y(y));
endmodule: mux_3

module mux_2
(	input	[2-1 : 0]	a	// input
,	input	[1-1 : 0]	s	// sel
	
,	output		y	// selected output
);
	BUFTL	as0_buf	(.a(a[0]), .b(s), .y(y));
	BUFT	as1_buf	(.a(a[1]), .b(s), .y(y));
endmodule: mux_2

module mux_bus_24_to_8
(	input	[23: 0]	i	// { i_n, i_n-1, ..., i_0 }
,	input	[1 : 0]	s
,	output	[7 : 0]	y
);

	generate
		genvar n;
		for (n=0 ; n<8 ; n=n+1) begin
			mux_3	mux3	(.a( {i[n+16], i[n+8], i[n]} ), .s(s), .y(y[n]));
		end
	endgenerate

endmodule: mux_bus_24_to_8

module mux_8
(	input	[7 : 0]	a
,	input	[7 : 0] b
,	input	sel
,	output	[7 : 0]	y
);
/*	assign y = (sel == 1) ? a : b;	*/

	generate
		genvar i;
		for (i=0; i<8; i=i+1)
		begin
			BUFT	a_buft	(.a(a[i]), .b(sel), .y(y[i]));
			BUFTL	a_buftl	(.a(b[i]), .b(sel), .y(y[i]));
		end
	endgenerate	

endmodule : mux_8

module mux_1
(	input	a
,	input	b
,	input	sel
,	output	y
);

	BUFT	a_buft	(.a(a), .b(sel), .y(y));
	BUFTL	a_buftl	(.a(b), .b(sel), .y(y));

endmodule : mux_1


module adder_4
(	input	[4-1 : 0]	a
,	input	[4-1 : 0]	b
,	input	ci
,	output	[4-1 : 0]	s
,	output	co
);
	wire	[3 : 0] g;
	wire	[3 : 0] gn;
	AND2	a0b0_and(.a(a[0]), .b(b[0]), .y(g[0]));
	AND2	a1b1_and(.a(a[1]), .b(b[1]), .y(g[1]));
	AND2	a2b2_and(.a(a[2]), .b(b[2]), .y(g[2]));
	AND2	a3b3_and(.a(a[3]), .b(b[3]), .y(g[3]));
	NAND2	a0b0_nand(.a(a[0]), .b(b[0]), .y(gn[0]));
	NAND2	a1b1_nand(.a(a[1]), .b(b[1]), .y(gn[1]));
	NAND2	a2b2_nand(.a(a[2]), .b(b[2]), .y(gn[2]));
	NAND2	a3b3_nand(.a(a[3]), .b(b[3]), .y(gn[3]));

	wire	[3 : 0] p;
	XOR2	a0b0_xor(.a(a[0]), .b(b[0]), .y(p[0]));
	XOR2	a1b1_xor(.a(a[1]), .b(b[1]), .y(p[1]));
	XOR2	a2b2_xor(.a(a[2]), .b(b[2]), .y(p[2]));
	XOR2	a3b3_xor(.a(a[3]), .b(b[3]), .y(p[3]));

	wire	[2 : 0] c;
	NAND2	p0ci_nand(.a(p[0]), .b(ci), .y(p0ci));
	NAND2	c0_nand(.a(gn[0]), .b(p0ci), .y(c[0]));
	NAND2	p1g0_nand(.a(p[1]), .b(g[0]), .y(p1g0));
	NAND3	p1p0ci_and(.a(p[1]), .b(p[0]), .c(ci), .y(p1p0ci));
	NAND3	c1_nand(.a(gn[1]), .b(p1g0), .c(p1p0ci), .y(c[1]));
	NAND2	p2g1_nand(.a(p[2]), .b(g[1]), .y(p2g1));
	NAND3	p2p1g0_nand(.a(p[2]), .b(p[1]), .c(g[0]), .y(p2p1g0));
	NAND4	p2p1p0ci_nand(.a(p[2]), .b(p[1]), .c(p[0]), .d(ci), .y(p2p1p0ci));
	NAND4	c2_nand(.a(gn[2]), .b(p2g1), .c(p2p1g0), .d(p2p1p0ci), .y(c[2]));

	XOR2	s0_xor(.a(p[0]), .b(ci), .y(s[0]));
	XOR2	s1_xor(.a(p[1]), .b(c[0]), .y(s[1]));
	XOR2	s2_xor(.a(p[2]), .b(c[1]), .y(s[2]));
	XOR2	s3_xor(.a(p[3]), .b(c[2]), .y(s[3]));

	wire	p3g2, p3p2g1, p3p2p1g0;

	NAND2	p3g2_nand(.a(p[3]), .b(g[2]), .y(p3g2));
	NAND3	p3p2g1_nand(.a(p[3]), .b(p[2]), .c(g[1]), .y(p3p2g1));
	NAND4	p3p2p1g0_nand(.a(p[3]), .b(p[2]), .c(p[1]), .d(g[0]), .y(p3p2p1g0));

	wire	group_g03, group_p03;

	NAND4	g03_and(.a(gn[3]), .b(p3g2), .c(p3p2g1), .d(p3p2p1g0), .y(group_g03));
	AND4	p03_and(.a(p[3]), .b(p[2]), .c(p[1]), .d(p[0]), .y(group_p03));

	wire	p03ci;
	
	AND2	p03ci_and(.a(group_p03), .b(ci), .y(p03ci));
	OR2	c3_or(.a(group_g03), .b(p03ci), .y(co));

endmodule: adder_4
	
module less_than_or_equal_to_zero
(	input	[8-1 : 0]	a
,	output	y
);

/*	assign y = (a[8-1] == 1'b1) || (a == 0);	*/

	wire	zero, one;
	TIELO	lo	(.y(zero));
	TIEHI	hi	(.y(one));

	//wire	msb_n; // if msb==1, msb_n = 0
	//INV	msbn	(.a(a[7]), .y(msb_n));

	wire	a1, a2, a_0; // if a==0, a_0==1
	OR4	a7_4	(.a(a[7]), .b(a[6]), .c(a[5]), .d(a[4]), .y(a1));
	OR4	a3_0	(.a(a[3]), .b(a[2]), .c(a[1]), .d(a[0]), .y(a2));
	OR2	a_all	(.a(a1), .b(a2), .y(a_0));

	wire	a7n;	
	INV	a7_n	(.a(a[7]), .y(a7n));
	NAND2	leq	(.a(a7n), .b(a_0), .y(y));

endmodule: less_than_or_equal_to_zero


module compare
(	input	[7 : 0]	a
,	input	[7 : 0] b
,	output	y
);

	wire	[7 : 0]	comp;
	generate
		genvar i;
		for (i=0 ; i<8 ; i=i+1) begin
			XNOR2	c_i	(.a(a[i]), .b(b[i]), .y(comp[i]));
		end
	endgenerate

	wire	[1 : 0]	comp_t;
	NAND4	c_low	(.a(comp[0]), .b(comp[1]), .c(comp[2]), .d(comp[3]), .y(comp_t[0]));
	NAND4	c_high	(.a(comp[4]), .b(comp[5]), .c(comp[6]), .d(comp[7]), .y(comp_t[1]));
	NOR2	c	(.a(comp_t[0]), .b(comp_t[1]), .y(y));

/*	assign y = (a==b);	*/
endmodule: compare


