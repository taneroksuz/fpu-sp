package lzc_wire;
	timeunit 1ns;
	timeprecision 1ps;

	typedef struct packed{
		logic [31:0] a;
	} lzc_32_in_type;

	typedef struct packed{
		logic [4:0] c;
		logic v;
	} lzc_32_out_type;

	typedef struct packed{
		logic [127:0] a;
	} lzc_128_in_type;

	typedef struct packed{
		logic [6:0] c;
		logic v;
	} lzc_128_out_type;

endpackage
