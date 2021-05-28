`timescale 1ns/10ps

`define	_GATE_LIST			\
	`_GATE_DEF_BEGIN		\
					\
	`_GATE_DEF(INV, not, 1, 0.8, 0.75)	\
	`_GATE_DEF(AND2, and, 2, 1.5, 1.5)	\
	`_GATE_DEF(AND3, and, 3, 1.8, 2)	\
	`_GATE_DEF(AND4, and, 4, 1.9, 2.25)	\
	`_GATE_DEF(OR2, or, 2, 1.6, 1.5)	\
	`_GATE_DEF(OR3, or, 3, 2.0, 2)	\
	`_GATE_DEF(OR4, or, 4, 2.3, 2.25)	\
					\
	`_GATE_DEF(XOR2, xor, 2, 2.4, 2.25)	\
	`_GATE_DEF(XNOR2, xnor, 2, 2.4, 2.25)	\
					\
	`_GATE_DEF(NAND2, nand, 2, 1, 1)	\
	`_GATE_DEF(NAND3, nand, 3, 1.2, 1.5)	\
	`_GATE_DEF(NAND4, nand, 4, 1.3, 1.75)	\
					\
	`_GATE_DEF(NOR2, nor, 2, 1.3, 1)	\
	`_GATE_DEF(NOR3, nor, 3, 1.7, 1.5)	\
	`_GATE_DEF(NOR4, nor, 4, 2.0, 1.75)	\
					\
	`_GATE_DEF(BUF, buf, 1, 1.2, 1.25)	\
	`_GATE_DEF(BUFT, bufif1, 2, 2.0, 2.75)	\
	`_GATE_DEF(BUFTL, bufif0, 2, 2.0, 2.75)	\
	`_GATE_DEF(INVT, notif1, 2, 1.6, 2.25)	\
	`_GATE_DEF(INVTL, notif0, 2, 1.6, 2.25)	\
					\
	`_GATE_DEF(TIEHI, pullup, 0, 0, 0.75)	\
	`_GATE_DEF(TIELO, pulldown, 0, 0, 0.75)	\
					\
	`_SEQ_GATE_DEF(DFFS, FF, 1, 4.3, 7)	\
	`_SEQ_GATE_DEF(DFFR, FF, 0, 4.3, 7)	\
	`_SEQ_GATE_DEF(LATS, LAT, 1, 3.3, 4.25)	\
	`_SEQ_GATE_DEF(LATR, LAT, 0, 3.3, 4.25)	\
					\
	`_GATE_DEF_END

`define	_GATE_DEF_BEGIN
`define	_GATE_DEF_END

`define _count(x)

`define	_MODULE_PARAMS_0	(output y)
`define	_MODULE_PARAMS_1	(input a, output y)
`define	_MODULE_PARAMS_2	(input a, input b, output y)
`define	_MODULE_PARAMS_3	(input a, input b, input c, output y)
`define	_MODULE_PARAMS_4	(input a, input b, input c, input d, output y)

`define	_MODULE_PARAMS_FF_1	(input d, input clk, input setn, output q, output qn)
`define	_MODULE_PARAMS_FF_0	(input d, input clk, input rstn, output q, output qn)
`define	_MODULE_PARAMS_LAT_1	(input d, input en, input setn, output q, output qn)
`define	_MODULE_PARAMS_LAT_0	(input d, input en, input rstn, output q, output qn)

`define	_FUNC_PARAMS_0(y)	(y)
`define	_FUNC_PARAMS_1(y)	(y, a)
`define	_FUNC_PARAMS_2(y)	(y, a, b)
`define	_FUNC_PARAMS_3(y)	(y, a, b, c)
`define	_FUNC_PARAMS_4(y)	(y, a, b, c, d)

`define	_FUNC_PARAMS_FF_1	(q, qn, d, clk, setn)
`define	_FUNC_PARAMS_FF_0	(q, qn, d, clk, rstn)
`define	_FUNC_PARAMS_LAT_1	(q, qn, d, en, setn)
`define	_FUNC_PARAMS_LAT_0	(q, qn, d, en, rstn)

`define	_IMPL_PRIMITIVE(func, delay, no_inputs)		\
	wire yy;					\
	assign #``delay y = yy;				\
	func _impl `_FUNC_PARAMS_``no_inputs(yy);

`define _IMPL_SEQ(func, delay, init)	\
	reg	val;						\
	assign #(delay) q 	= val;		\
	assign #(delay) qn	= ~val;		\
	`_IMPL_SEQ_ALWAYS_``func(init)	\
	begin							\
		if (!`_IMPL_SEQ_ASYNC_IN_``init)	\
		begin						\
			val <= init;			\
		end							\
		else if (`_IMPL_SEQ_EN_IN_``func)	\
		begin						\
			val	<= d;				\
		end							\
	end

`define	_GATE_DEF(gate_name, func, no_inputs, delay, area)		\
	module gate_name					\
		`_MODULE_PARAMS_``no_inputs;	\
		`_count(gate_name)				\
		`_IMPL_PRIMITIVE(func, delay, no_inputs)	\
	endmodule: gate_name

`define	_SEQ_GATE_DEF(gate_name, func, init, delay, area)		\
	module gate_name						\
		`_MODULE_PARAMS_``func``_``init;	\
		`_count(gate_name)					\
		`_IMPL_SEQ(func, delay, init)				\
	endmodule: gate_name

`define	_IMPL_SEQ_ALWAYS_FF(init)	always @(posedge clk, negedge `_IMPL_SEQ_ASYNC_IN_``init)
`define	_IMPL_SEQ_ALWAYS_LAT(init)	always @*

`define _IMPL_SEQ_ASYNC_IN_1	setn
`define _IMPL_SEQ_ASYNC_IN_0	rstn

`define _IMPL_SEQ_EN_IN_FF	1
`define _IMPL_SEQ_EN_IN_LAT	en

	`_GATE_LIST

`undef	_GATE_DEF
`undef	_SEQ_GATE_DEF
