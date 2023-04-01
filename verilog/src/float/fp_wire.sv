package fp_wire;
	timeunit 1ns;
	timeprecision 1ps;

	typedef struct packed{
		logic fmadd;
		logic fmsub;
		logic fnmadd;
		logic fnmsub;
		logic fadd;
		logic fsub;
		logic fmul;
		logic fdiv;
		logic fsqrt;
		logic fsgnj;
		logic fcmp;
		logic fmax;
		logic fclass;
		logic fmv_i2f;
		logic fmv_f2i;
		logic fcvt_i2f;
		logic fcvt_f2i;
		logic [1:0] fcvt_op;
	} fp_operation_type;

	parameter fp_operation_type init_fp_operation = '{
		fmadd : 0,
		fmsub : 0,
		fnmadd : 0,
		fnmsub : 0,
		fadd : 0,
		fsub : 0,
		fmul : 0,
		fdiv : 0,
		fsqrt : 0,
		fsgnj : 0,
		fcmp : 0,
		fmax : 0,
		fclass : 0,
		fmv_i2f : 0,
		fmv_f2i : 0,
		fcvt_i2f : 0,
		fcvt_f2i : 0,
		fcvt_op : 0
	};

	typedef struct packed{
		logic [31:0] data1;
		logic [31:0] data2;
		logic [31:0] data3;
		fp_operation_type op;
		logic [1:0] fmt;
		logic [2:0] rm;
		logic enable;
	} fp_exe_in_type;

	typedef struct packed{
		logic [31:0] result;
		logic [4:0] flags;
		logic ready;
	} fp_exe_out_type;

	typedef struct packed{
		logic [32:0] data1;
		logic [32:0] data2;
		logic [2:0] rm;
		logic [9:0] class1;
		logic [9:0] class2;
	} fp_cmp_in_type;

	typedef struct packed{
		logic [31:0] result;
		logic [4:0] flags;
	} fp_cmp_out_type;

	typedef struct packed{
		logic [31:0] data1;
		logic [31:0] data2;
		logic [32:0] ext1;
		logic [32:0] ext2;
		logic [1:0] fmt;
		logic [2:0] rm;
		logic [9:0] class1;
		logic [9:0] class2;
	} fp_max_in_type;

	typedef struct packed{
		logic [31:0] result;
		logic [4:0] flags;
	} fp_max_out_type;

	typedef struct packed{
		logic [31:0] data1;
		logic [31:0] data2;
		logic [1:0] fmt;
		logic [2:0] rm;
	} fp_sgnj_in_type;

	typedef struct packed{
		logic [31:0] result;
	} fp_sgnj_out_type;

	typedef struct packed{
		logic [31:0] data;
		logic [1:0] fmt;
	} fp_ext_in_type;

	typedef struct packed{
		logic [32:0] result;
		logic [9:0] classification;
	 } fp_ext_out_type;

	typedef struct packed{
		fp_exe_in_type fp_exe_i;
	} fp_unit_in_type;

	typedef struct packed{
		fp_exe_out_type fp_exe_o;
	} fp_unit_out_type;

	typedef struct packed{
		logic sig;
		logic [10:0] expo;
		logic [24:0] mant;
		logic [1:0] rema;
		logic [1:0] fmt;
		logic [2:0] rm;
		logic [2:0] grs;
		logic snan;
		logic qnan;
		logic dbz;
		logic inf;
		logic zero;
		logic diff;
	} fp_rnd_in_type;

	parameter fp_rnd_in_type init_fp_rnd_in = '{
		sig : 0,
		expo : 0,
		mant : 0,
		rema : 0,
		fmt : 0,
		rm : 0,
		grs : 0,
		snan : 0,
		qnan : 0,
		dbz : 0,
		inf : 0,
		zero : 0,
		diff : 0
	};

	typedef struct packed{
		logic [31:0] result;
		logic [4:0] flags;
	} fp_rnd_out_type;

	typedef struct packed{
		logic [32:0] data1;
		logic [32:0] data2;
		logic [32:0] data3;
		logic [9:0] class1;
		logic [9:0] class2;
		logic [9:0] class3;
		fp_operation_type op;
		logic [1:0] fmt;
		logic [2:0] rm;
	} fp_fma_in_type;

	typedef struct packed{
		fp_rnd_in_type fp_rnd;
		logic ready;
	} fp_fma_out_type;

	typedef struct packed{
		logic [1:0] fmt;
		logic [2:0] rm;
		logic snan;
		logic qnan;
		logic dbz;
		logic inf;
		logic zero;
		logic neg;
		logic sign_mul;
		logic [10:0] exponent_mul;
		logic [76:0] mantissa_mul;
		logic sign_add;
		logic [10:0] exponent_add;
		logic [76:0] mantissa_add;
		logic exponent_neg;
		logic ready;
	} fp_fma_reg_type_1;

	parameter fp_fma_reg_type_1 init_fp_fma_reg_1 = '{
		fmt : 0,
		rm : 0,
		snan : 0,
		qnan : 0,
		dbz : 0,
		inf : 0,
		zero : 0,
		neg : 0,
		sign_mul : 0,
		exponent_mul : 0,
		mantissa_mul : 0,
		sign_add : 0,
		exponent_add : 0,
		mantissa_add : 0,
		exponent_neg : 0,
		ready : 0
	};

	typedef struct packed{
		logic [32:0] a;
		logic [32:0] b;
		logic [32:0] c;
		logic [9:0] class_a;
		logic [9:0] class_b;
		logic [9:0] class_c;
		logic [1:0] fmt;
		logic [2:0] rm;
		logic snan;
		logic qnan;
		logic dbz;
		logic inf;
		logic zero;
		logic neg;
		logic sign_a;
		logic [8:0] exponent_a;
		logic [23:0] mantissa_a;
		logic sign_b;
		logic [8:0] exponent_b;
		logic [23:0] mantissa_b;
		logic sign_c;
		logic [8:0] exponent_c;
		logic [23:0] mantissa_c;
		logic sign_mul;
		logic [10:0] exponent_mul;
		logic [76:0] mantissa_mul;
		logic sign_add;
		logic [10:0] exponent_add;
		logic [76:0] mantissa_add;
		logic [76:0] mantissa_l;
		logic [76:0] mantissa_r;
		logic [10:0] exponent_dif;
		logic [5:0] counter_dif;
		logic exponent_neg;
		logic ready;
	} fp_fma_var_type_1;

	typedef struct packed{
		logic sign_rnd;
		logic [10:0] exponent_rnd;
		logic [24:0] mantissa_rnd;
		logic [1:0] fmt;
		logic [2:0] rm;
		logic [2:0] grs;
		logic snan;
		logic qnan;
		logic dbz;
		logic inf;
		logic zero;
		logic diff;
		logic ready;
	} fp_fma_reg_type_2;

	parameter fp_fma_reg_type_2 init_fp_fma_reg_2 = '{
		sign_rnd : 0,
		exponent_rnd : 0,
		mantissa_rnd : 0,
		fmt : 0,
		rm : 0,
		grs : 0,
		snan : 0,
		qnan : 0,
		dbz : 0,
		inf : 0,
		zero : 0,
		diff : 0,
		ready : 0
	};

	typedef struct packed{
		logic [1:0] fmt;
		logic [2:0] rm;
		logic snan;
		logic qnan;
		logic dbz;
		logic inf;
		logic zero;
		logic diff;
		logic neg;
		logic sign_mul;
		logic [10:0] exponent_mul;
		logic [76:0] mantissa_mul;
		logic sign_add;
		logic [10:0] exponent_add;
		logic [76:0] mantissa_add;
		logic exponent_neg;
		logic sign_mac;
		logic [10:0] exponent_mac;
		logic [76:0] mantissa_mac;
		logic [6:0] counter_mac;
		logic [10:0] counter_sub;
		logic [7:0] bias;
		logic sign_rnd;
		logic [10:0] exponent_rnd;
		logic [24:0] mantissa_rnd;
		logic [2:0] grs;
		logic ready;
	} fp_fma_var_type_2;

	typedef struct packed{
		logic [26:0] a;
		logic [26:0] b;
		logic [26:0] c;
		logic op;
	} fp_mac_in_type;

	typedef struct packed{
		logic [51:0] d;
	} fp_mac_out_type;

	typedef struct packed{
		logic [32:0] data1;
		logic [32:0] data2;
		logic [9:0] class1;
		logic [9:0] class2;
		fp_operation_type op;
		logic [1:0] fmt;
		logic [2:0] rm;
	} fp_fdiv_in_type;

	typedef struct packed{
		fp_rnd_in_type fp_rnd;
		logic ready;
	} fp_fdiv_out_type;

	typedef struct packed{
		logic [2:0] state;
		logic [5:0] istate;
		logic [1:0] fmt;
		logic [2:0] rm;
		logic [32:0] a;
		logic [32:0] b;
		logic [9:0] class_a;
		logic [9:0] class_b;
		logic snan;
		logic qnan;
		logic inf;
		logic dbz;
		logic zero;
		logic op;
		logic [6:0] index;
		logic [26:0] qa;
		logic [26:0] qb;
		logic [26:0] q0;
		logic [26:0] q1;
		logic [26:0] y;
		logic [26:0] y0;
		logic [26:0] y1;
		logic [26:0] y2;
		logic [26:0] h0;
		logic [26:0] h1;
		logic [26:0] e0;
		logic [26:0] e1;
		logic [51:0] r0;
		logic [51:0] r1;
		logic sign_fdiv;
		logic [10:0] exponent_fdiv;
		logic [55:0] mantissa_fdiv;
		logic [1:0] counter_fdiv;
		logic [7:0] exponent_bias;
		logic sign_rnd;
		logic [10:0] exponent_rnd;
		logic [24:0] mantissa_rnd;
		logic [1:0] remainder_rnd;
		logic [10:0] counter_rnd;
		logic [2:0] grs;
		logic odd;
		logic [31:0] result;
		logic [4:0] flags;
		logic ready;
	} fp_fdiv_reg_functional_type;

	parameter fp_fdiv_reg_functional_type init_fp_fdiv_reg_functional = '{
		state : 0,
		istate : 0,
		fmt : 0,
		rm : 0,
		a : 0,
		b : 0,
		class_a : 0,
		class_b : 0,
		snan : 0,
		qnan : 0,
		inf : 0,
		dbz : 0,
		zero : 0,
		op : 0,
		index : 0,
		qa : 0,
		qb : 0,
		q0 : 0,
		q1 : 0,
		y : 0,
		y0 : 0,
		y1 : 0,
		y2 : 0,
		h0 : 0,
		h1 : 0,
		e0 : 0,
		e1 : 0,
		r0 : 0,
		r1 : 0,
		sign_fdiv : 0,
		exponent_fdiv : 0,
		mantissa_fdiv : 0,
		counter_fdiv : 0,
		exponent_bias : 0,
		sign_rnd : 0,
		exponent_rnd : 0,
		mantissa_rnd : 0,
		remainder_rnd : 0,
		counter_rnd : 0,
		grs : 0,
		odd : 0,
		result : 0,
		flags : 0,
		ready : 0
	};

	typedef struct packed{
		logic [2:0] state;
		logic [4:0] istate;
		logic [1:0] fmt;
		logic [2:0] rm;
		logic [32:0] a;
		logic [32:0] b;
		logic [9:0] class_a;
		logic [9:0] class_b;
		logic snan;
		logic qnan;
		logic inf;
		logic dbz;
		logic zero;
		logic op;
		logic [26:0] qa;
		logic [26:0] qb;
		logic [25:0] q;
		logic [27:0] e;
		logic [27:0] r;
		logic [27:0] m;
		logic sign_fdiv;
		logic [10:0] exponent_fdiv;
		logic [77:0] mantissa_fdiv;
		logic [1:0] counter_fdiv;
		logic [7:0] exponent_bias;
		logic sign_rnd;
		logic [10:0] exponent_rnd;
		logic [24:0] mantissa_rnd;
		logic [1:0] remainder_rnd;
		logic [10:0] counter_rnd;
		logic [2:0] grs;
		logic odd;
		logic [31:0] result;
		logic [4:0] flags;
		logic ready;
	} fp_fdiv_reg_fixed_type;

	parameter fp_fdiv_reg_fixed_type init_fp_fdiv_reg_fixed = '{
		state : 0,
		istate : 0,
		fmt : 0,
		rm : 0,
		a : 0,
		b : 0,
		class_a : 0,
		class_b : 0,
		snan : 0,
		qnan : 0,
		inf : 0,
		dbz : 0,
		zero : 0,
		op : 0,
		qa : 0,
		qb : 0,
		q : 0,
		e : 0,
		r : 0,
		m : 0,
		sign_fdiv : 0,
		exponent_fdiv : 0,
		mantissa_fdiv : 0,
		counter_fdiv : 0,
		exponent_bias : 0,
		sign_rnd : 0,
		exponent_rnd : 0,
		mantissa_rnd : 0,
		remainder_rnd : 0,
		counter_rnd : 0,
		grs : 0,
		odd : 0,
		result : 0,
		flags : 0,
		ready : 0
	};

	typedef struct packed{
		logic [32:0] data;
		fp_operation_type op;
		logic [2:0] rm;
		logic [9:0] classification;
	} fp_cvt_f2i_in_type;

	typedef struct packed{
		logic [31:0] result;
		logic [4:0] flags;
	} fp_cvt_f2i_out_type;

	typedef struct packed{
		logic [32:0] data;
		logic [1:0] op;
		logic [2:0] rm;
		logic [9:0] classification;
		logic [31:0] result;
		logic [4:0] flags;
		logic snan;
		logic qnan;
		logic inf;
		logic zero;
		logic sign_cvt;
		logic [9:0] exponent_cvt;
		logic [58:0] mantissa_cvt;
		logic [7:0] exponent_bias;
		logic [32:0] mantissa_uint;
		logic [2:0] grs;
		logic odd;
		logic rnded;
		logic oor;
		logic or_1;
		logic or_2;
		logic or_3;
		logic or_4;
		logic or_5;
		logic oor_64u;
		logic oor_64s;
		logic oor_32u;
		logic oor_32s;
	} fp_cvt_f2i_var_type;

	typedef struct packed{
		logic [31:0] data;
		fp_operation_type op;
		logic [1:0] fmt;
		logic [2:0] rm;
	} fp_cvt_i2f_in_type;

	typedef struct packed{
		fp_rnd_in_type fp_rnd;
	} fp_cvt_i2f_out_type;

	typedef struct packed{
		logic [31:0] data;
		logic [1:0] op;
		logic [1:0] fmt;
		logic [2:0] rm;
		logic snan;
		logic qnan;
		logic dbz;
		logic inf;
		logic zero;
		logic sign_uint;
		logic [4:0] exponent_uint;
		logic [31:0] mantissa_uint;
		logic [4:0] counter_uint;
		logic [6:0] exponent_bias;
		logic sign_rnd;
		logic [10:0] exponent_rnd;
		logic [24:0] mantissa_rnd;
		logic [2:0] grs;
	} fp_cvt_i2f_var_type;

endpackage
