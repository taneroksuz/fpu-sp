import fp_wire::*;

module fp_fdiv
#(
	parameter PERFORMANCE = 0
)
(
	input reset,
	input clock,
	input fp_fdiv_in_type fp_fdiv_i,
	output fp_fdiv_out_type fp_fdiv_o,
	input fp_mac_out_type fp_mac_o,
	output fp_mac_in_type fp_mac_i
);
	timeunit 1ns;
	timeprecision 1ps;

	fp_fdiv_reg_functional_type r;
	fp_fdiv_reg_functional_type rin;

	fp_fdiv_reg_functional_type v;

	fp_fdiv_reg_fixed_type r_fix;
	fp_fdiv_reg_fixed_type rin_fix;

	fp_fdiv_reg_fixed_type v_fix;

	logic [7:0] reciprocal_lut [0:127];
	logic [7:0] reciprocal_root_lut [0:95];

	initial begin
		reciprocal_lut[0] = 8'b00000000; reciprocal_lut[1] = 8'b11111110; reciprocal_lut[2] = 8'b11111100; reciprocal_lut[3] = 8'b11111010; reciprocal_lut[4] = 8'b11111000; reciprocal_lut[5] = 8'b11110110; reciprocal_lut[6] = 8'b11110100; reciprocal_lut[7] = 8'b11110010;
		reciprocal_lut[8] = 8'b11110000; reciprocal_lut[9] = 8'b11101111; reciprocal_lut[10] = 8'b11101101; reciprocal_lut[11] = 8'b11101011; reciprocal_lut[12] = 8'b11101010; reciprocal_lut[13] = 8'b11101000; reciprocal_lut[14] = 8'b11100110; reciprocal_lut[15] = 8'b11100101;
		reciprocal_lut[16] = 8'b11100011; reciprocal_lut[17] = 8'b11100001; reciprocal_lut[18] = 8'b11100000; reciprocal_lut[19] = 8'b11011110; reciprocal_lut[20] = 8'b11011101; reciprocal_lut[21] = 8'b11011011; reciprocal_lut[22] = 8'b11011010; reciprocal_lut[23] = 8'b11011001;
		reciprocal_lut[24] = 8'b11010111; reciprocal_lut[25] = 8'b11010110; reciprocal_lut[26] = 8'b11010100; reciprocal_lut[27] = 8'b11010011; reciprocal_lut[28] = 8'b11010010; reciprocal_lut[29] = 8'b11010000; reciprocal_lut[30] = 8'b11001111; reciprocal_lut[31] = 8'b11001110;
		reciprocal_lut[32] = 8'b11001100; reciprocal_lut[33] = 8'b11001011; reciprocal_lut[34] = 8'b11001010; reciprocal_lut[35] = 8'b11001001; reciprocal_lut[36] = 8'b11000111; reciprocal_lut[37] = 8'b11000110; reciprocal_lut[38] = 8'b11000101; reciprocal_lut[39] = 8'b11000100;
		reciprocal_lut[40] = 8'b11000011; reciprocal_lut[41] = 8'b11000001; reciprocal_lut[42] = 8'b11000000; reciprocal_lut[43] = 8'b10111111; reciprocal_lut[44] = 8'b10111110; reciprocal_lut[45] = 8'b10111101; reciprocal_lut[46] = 8'b10111100; reciprocal_lut[47] = 8'b10111011;
		reciprocal_lut[48] = 8'b10111010; reciprocal_lut[49] = 8'b10111001; reciprocal_lut[50] = 8'b10111000; reciprocal_lut[51] = 8'b10110111; reciprocal_lut[52] = 8'b10110110; reciprocal_lut[53] = 8'b10110101; reciprocal_lut[54] = 8'b10110100; reciprocal_lut[55] = 8'b10110011;
		reciprocal_lut[56] = 8'b10110010; reciprocal_lut[57] = 8'b10110001; reciprocal_lut[58] = 8'b10110000; reciprocal_lut[59] = 8'b10101111; reciprocal_lut[60] = 8'b10101110; reciprocal_lut[61] = 8'b10101101; reciprocal_lut[62] = 8'b10101100; reciprocal_lut[63] = 8'b10101011;
		reciprocal_lut[64] = 8'b10101010; reciprocal_lut[65] = 8'b10101001; reciprocal_lut[66] = 8'b10101000; reciprocal_lut[67] = 8'b10101000; reciprocal_lut[68] = 8'b10100111; reciprocal_lut[69] = 8'b10100110; reciprocal_lut[70] = 8'b10100101; reciprocal_lut[71] = 8'b10100100;
		reciprocal_lut[72] = 8'b10100011; reciprocal_lut[73] = 8'b10100011; reciprocal_lut[74] = 8'b10100010; reciprocal_lut[75] = 8'b10100001; reciprocal_lut[76] = 8'b10100000; reciprocal_lut[77] = 8'b10011111; reciprocal_lut[78] = 8'b10011111; reciprocal_lut[79] = 8'b10011110;
		reciprocal_lut[80] = 8'b10011101; reciprocal_lut[81] = 8'b10011100; reciprocal_lut[82] = 8'b10011100; reciprocal_lut[83] = 8'b10011011; reciprocal_lut[84] = 8'b10011010; reciprocal_lut[85] = 8'b10011001; reciprocal_lut[86] = 8'b10011001; reciprocal_lut[87] = 8'b10011000;
		reciprocal_lut[88] = 8'b10010111; reciprocal_lut[89] = 8'b10010111; reciprocal_lut[90] = 8'b10010110; reciprocal_lut[91] = 8'b10010101; reciprocal_lut[92] = 8'b10010100; reciprocal_lut[93] = 8'b10010100; reciprocal_lut[94] = 8'b10010011; reciprocal_lut[95] = 8'b10010010;
		reciprocal_lut[96] = 8'b10010010; reciprocal_lut[97] = 8'b10010001; reciprocal_lut[98] = 8'b10010000; reciprocal_lut[99] = 8'b10010000; reciprocal_lut[100] = 8'b10001111; reciprocal_lut[101] = 8'b10001111; reciprocal_lut[102] = 8'b10001110; reciprocal_lut[103] = 8'b10001101;
		reciprocal_lut[104] = 8'b10001101; reciprocal_lut[105] = 8'b10001100; reciprocal_lut[106] = 8'b10001100; reciprocal_lut[107] = 8'b10001011; reciprocal_lut[108] = 8'b10001010; reciprocal_lut[109] = 8'b10001010; reciprocal_lut[110] = 8'b10001001; reciprocal_lut[111] = 8'b10001001;
		reciprocal_lut[112] = 8'b10001000; reciprocal_lut[113] = 8'b10000111; reciprocal_lut[114] = 8'b10000111; reciprocal_lut[115] = 8'b10000110; reciprocal_lut[116] = 8'b10000110; reciprocal_lut[117] = 8'b10000101; reciprocal_lut[118] = 8'b10000101; reciprocal_lut[119] = 8'b10000100;
		reciprocal_lut[120] = 8'b10000100; reciprocal_lut[121] = 8'b10000011; reciprocal_lut[122] = 8'b10000011; reciprocal_lut[123] = 8'b10000010; reciprocal_lut[124] = 8'b10000010; reciprocal_lut[125] = 8'b10000001; reciprocal_lut[126] = 8'b10000001; reciprocal_lut[127] = 8'b10000000;

		reciprocal_root_lut[0] = 8'b10110101; reciprocal_root_lut[1] = 8'b10110010; reciprocal_root_lut[2] = 8'b10101111; reciprocal_root_lut[3] = 8'b10101101; reciprocal_root_lut[4] = 8'b10101010; reciprocal_root_lut[5] = 8'b10101000; reciprocal_root_lut[6] = 8'b10100110; reciprocal_root_lut[7] = 8'b10100011;
		reciprocal_root_lut[8] = 8'b10100001; reciprocal_root_lut[9] = 8'b10011111; reciprocal_root_lut[10] = 8'b10011110; reciprocal_root_lut[11] = 8'b10011100; reciprocal_root_lut[12] = 8'b10011010; reciprocal_root_lut[13] = 8'b10011000; reciprocal_root_lut[14] = 8'b10010110; reciprocal_root_lut[15] = 8'b10010101;
		reciprocal_root_lut[16] = 8'b10010011; reciprocal_root_lut[17] = 8'b10010010; reciprocal_root_lut[18] = 8'b10010000; reciprocal_root_lut[19] = 8'b10001111; reciprocal_root_lut[20] = 8'b10001110; reciprocal_root_lut[21] = 8'b10001100; reciprocal_root_lut[22] = 8'b10001011; reciprocal_root_lut[23] = 8'b10001010;
		reciprocal_root_lut[24] = 8'b10001000; reciprocal_root_lut[25] = 8'b10000111; reciprocal_root_lut[26] = 8'b10000110; reciprocal_root_lut[27] = 8'b10000101; reciprocal_root_lut[28] = 8'b10000100; reciprocal_root_lut[29] = 8'b10000011; reciprocal_root_lut[30] = 8'b10000010; reciprocal_root_lut[31] = 8'b10000001;
		reciprocal_root_lut[32] = 8'b10000000; reciprocal_root_lut[33] = 8'b01111111; reciprocal_root_lut[34] = 8'b01111110; reciprocal_root_lut[35] = 8'b01111101; reciprocal_root_lut[36] = 8'b01111100; reciprocal_root_lut[37] = 8'b01111011; reciprocal_root_lut[38] = 8'b01111010; reciprocal_root_lut[39] = 8'b01111001;
		reciprocal_root_lut[40] = 8'b01111000; reciprocal_root_lut[41] = 8'b01110111; reciprocal_root_lut[42] = 8'b01110111; reciprocal_root_lut[43] = 8'b01110110; reciprocal_root_lut[44] = 8'b01110101; reciprocal_root_lut[45] = 8'b01110100; reciprocal_root_lut[46] = 8'b01110011; reciprocal_root_lut[47] = 8'b01110011;
		reciprocal_root_lut[48] = 8'b01110010; reciprocal_root_lut[49] = 8'b01110001; reciprocal_root_lut[50] = 8'b01110001; reciprocal_root_lut[51] = 8'b01110000; reciprocal_root_lut[52] = 8'b01101111; reciprocal_root_lut[53] = 8'b01101111; reciprocal_root_lut[54] = 8'b01101110; reciprocal_root_lut[55] = 8'b01101101;
		reciprocal_root_lut[56] = 8'b01101101; reciprocal_root_lut[57] = 8'b01101100; reciprocal_root_lut[58] = 8'b01101011; reciprocal_root_lut[59] = 8'b01101011; reciprocal_root_lut[60] = 8'b01101010; reciprocal_root_lut[61] = 8'b01101010; reciprocal_root_lut[62] = 8'b01101001; reciprocal_root_lut[63] = 8'b01101001;
		reciprocal_root_lut[64] = 8'b01101000; reciprocal_root_lut[65] = 8'b01100111; reciprocal_root_lut[66] = 8'b01100111; reciprocal_root_lut[67] = 8'b01100110; reciprocal_root_lut[68] = 8'b01100110; reciprocal_root_lut[69] = 8'b01100101; reciprocal_root_lut[70] = 8'b01100101; reciprocal_root_lut[71] = 8'b01100100;
		reciprocal_root_lut[72] = 8'b01100100; reciprocal_root_lut[73] = 8'b01100011; reciprocal_root_lut[74] = 8'b01100011; reciprocal_root_lut[75] = 8'b01100010; reciprocal_root_lut[76] = 8'b01100010; reciprocal_root_lut[77] = 8'b01100010; reciprocal_root_lut[78] = 8'b01100001; reciprocal_root_lut[79] = 8'b01100001;
		reciprocal_root_lut[80] = 8'b01100000; reciprocal_root_lut[81] = 8'b01100000; reciprocal_root_lut[82] = 8'b01011111; reciprocal_root_lut[83] = 8'b01011111; reciprocal_root_lut[84] = 8'b01011111; reciprocal_root_lut[85] = 8'b01011110; reciprocal_root_lut[86] = 8'b01011110; reciprocal_root_lut[87] = 8'b01011101;
		reciprocal_root_lut[88] = 8'b01011101; reciprocal_root_lut[89] = 8'b01011101; reciprocal_root_lut[90] = 8'b01011100; reciprocal_root_lut[91] = 8'b01011100; reciprocal_root_lut[92] = 8'b01011011; reciprocal_root_lut[93] = 8'b01011011; reciprocal_root_lut[94] = 8'b01011011; reciprocal_root_lut[95] = 8'b01011010;
	end

	generate

		if (PERFORMANCE == 1) begin

			always_comb begin

				v = r;

				if (r.state == 0) begin
					if (fp_fdiv_i.op.fdiv) begin
						v.state = 1;
					end
					if (fp_fdiv_i.op.fsqrt) begin
						v.state = 2;
					end
					v.istate = 0;
					v.ready = 0;
				end else if (r.state == 1) begin
					if (v.istate == 8) begin
						v.state = 3;
					end
					v.istate = v.istate + 6'd1;
					v.ready = 0;
				end else if (r.state == 2) begin
					if (v.istate == 10) begin
						v.state = 3;
					end
					v.istate = v.istate + 6'd1;
					v.ready = 0;
				end else if (r.state == 3) begin
					v.state = 4;
					v.ready = 0;
				end else begin
					v.state = 0;
					v.ready = 1;
				end

				if (r.state == 0) begin
					v.a = fp_fdiv_i.data1;
					v.b = fp_fdiv_i.data2;
					v.class_a = fp_fdiv_i.class1;
					v.class_b = fp_fdiv_i.class2;
					v.fmt = fp_fdiv_i.fmt;
					v.rm = fp_fdiv_i.rm;
					v.snan = 0;
					v.qnan = 0;
					v.dbz = 0;
					v.inf = 0;
					v.zero = 0;

					if (fp_fdiv_i.op.fsqrt) begin
						v.b = 33'h07F800000;
						v.class_b = 0;
					end

					if (v.class_a[8] | v.class_b[8]) begin
						v.snan = 1;
					end else if ((v.class_a[3] | v.class_a[4]) & (v.class_b[3] | v.class_b[4])) begin
						v.snan = 1;
					end else if ((v.class_a[0] | v.class_a[7]) & (v.class_b[0] | v.class_b[7])) begin
						v.snan = 1;
					end else if (v.class_a[9] | v.class_b[9]) begin
						v.qnan = 1;
					end

					if ((v.class_a[0] | v.class_a[7]) & (v.class_b[1] | v.class_b[2] | v.class_b[3] | v.class_b[4] | v.class_b[5] | v.class_b[6])) begin
						v.inf = 1;
					end else if ((v.class_b[3] | v.class_b[4]) & (v.class_a[1] | v.class_a[2] | v.class_a[5] | v.class_a[6])) begin
						v.dbz = 1;
					end

					if ((v.class_a[3] | v.class_a[4]) | (v.class_b[0] | v.class_b[7])) begin
						v.zero = 1;
					end

					if (fp_fdiv_i.op.fsqrt) begin
						if (v.class_a[7]) begin
							v.inf = 1;
						end
						if (v.class_a[0] | v.class_a[1] | v.class_a[2]) begin
							v.snan = 1;
						end
					end

					v.qa = {2'h1,v.a[22:0],2'h0};
					v.qb = {2'h1,v.b[22:0],2'h0};

					v.sign_fdiv = v.a[32] ^ v.b[32];
					v.exponent_fdiv = {2'h0,v.a[31:23]} - {2'h0,v.b[31:23]};
					v.y = {1'h0,~|v.b[22:16],reciprocal_lut[$unsigned(v.b[22:16])],17'h0};
					v.op = 0;

					if (fp_fdiv_i.op.fsqrt) begin
						v.qa = {2'h1,v.a[22:0],2'h0};
						if (!v.a[23]) begin
							v.qa = v.qa >> 1;
						end
						v.index = $unsigned(v.qa[25:19]) - 7'd32;
						v.exponent_fdiv = ($signed({2'h0,v.a[31:23]}) + $signed(-11'd253)) >>> 1;
						v.y = {1'h0,reciprocal_root_lut[v.index],18'h0};
						v.op = 1;
					end

					fp_mac_i.a = 0;
					fp_mac_i.b = 0;
					fp_mac_i.c = 0;
					fp_mac_i.op = 0;
				end else if (r.state == 1) begin
					if (r.istate == 0) begin
						fp_mac_i.a = 27'h2000000;
						fp_mac_i.b = v.qb;
						fp_mac_i.c = v.y;
						fp_mac_i.op = 1;
						v.e0 = fp_mac_o.d[51:25];
					end else if (r.istate == 1) begin
						fp_mac_i.a = v.y;
						fp_mac_i.b = v.y;
						fp_mac_i.c = v.e0;
						fp_mac_i.op = 0;
						v.y0 = fp_mac_o.d[51:25];
					end else if (r.istate == 2) begin
						fp_mac_i.a = 27'h0;
						fp_mac_i.b = v.e0;
						fp_mac_i.c = v.e0;
						fp_mac_i.op = 0;
						v.e1 = fp_mac_o.d[51:25];
					end else if (r.istate == 3) begin
						fp_mac_i.a = v.y0;
						fp_mac_i.b = v.y0;
						fp_mac_i.c = v.e1;
						fp_mac_i.op = 0;
						v.y1 = fp_mac_o.d[51:25];
					end else if (r.istate == 4) begin
						fp_mac_i.a = 27'h0;
						fp_mac_i.b = v.qa;
						fp_mac_i.c = v.y1;
						fp_mac_i.op = 0;
						v.q0 = fp_mac_o.d[51:25];
					end else if (r.istate == 5) begin
						fp_mac_i.a = v.qa;
						fp_mac_i.b = v.qb;
						fp_mac_i.c = v.q0;
						fp_mac_i.op = 1;
						v.r0 = fp_mac_o.d;
					end else if (r.istate == 6) begin
						fp_mac_i.a = v.q0;
						fp_mac_i.b = v.r0[51:25];
						fp_mac_i.c = v.y1;
						fp_mac_i.op = 0;
						v.q0 = fp_mac_o.d[51:25];
					end else if (r.istate == 7) begin
						fp_mac_i.a = v.qa;
						fp_mac_i.b = v.qb;
						fp_mac_i.c = v.q0;
						fp_mac_i.op = 1;
						v.r1 = fp_mac_o.d;
						v.q1 = v.q0;
						if ($signed(v.r1[51:25]) > 0) begin
							v.q1 = v.q1 + 1;
						end
					end else if (r.istate == 8) begin
						fp_mac_i.a = v.qa;
						fp_mac_i.b = v.qb;
						fp_mac_i.c = v.q1;
						fp_mac_i.op = 1;
						v.r0 = fp_mac_o.d;
						if (v.r0[51:25] == 0) begin
							v.q0 = v.q1;
							v.r1 = v.r0;
						end
					end else begin
						fp_mac_i.a = 0;
						fp_mac_i.b = 0;
						fp_mac_i.c = 0;
						fp_mac_i.op = 0;
					end
				end else if (r.state == 2) begin
					if (r.istate == 0) begin
						fp_mac_i.a = 27'h0;
						fp_mac_i.b = v.qa;
						fp_mac_i.c = v.y;
						fp_mac_i.op = 0;
						v.y0 = fp_mac_o.d[51:25];
					end else if (r.istate == 1) begin
						fp_mac_i.a = 27'h0;
						fp_mac_i.b = 27'h1000000;
						fp_mac_i.c = v.y;
						fp_mac_i.op = 0;
						v.h0 = fp_mac_o.d[51:25];
					end else if (r.istate == 2) begin
						fp_mac_i.a = 27'h1000000;
						fp_mac_i.b = v.h0;
						fp_mac_i.c = v.y0;
						fp_mac_i.op = 1;
						v.e0 = fp_mac_o.d[51:25];
					end else if (r.istate == 3) begin
						fp_mac_i.a = v.y0;
						fp_mac_i.b = v.y0;
						fp_mac_i.c = v.e0;
						fp_mac_i.op = 0;
						v.y1 = fp_mac_o.d[51:25];
					end else if (r.istate == 4) begin
						fp_mac_i.a = v.h0;
						fp_mac_i.b = v.h0;
						fp_mac_i.c = v.e0;
						fp_mac_i.op = 0;
						v.h1 = fp_mac_o.d[51:25];
					end else if (r.istate == 5) begin
						fp_mac_i.a = v.qa;
						fp_mac_i.b = v.y1;
						fp_mac_i.c = v.y1;
						fp_mac_i.op = 1;
						v.r0 = fp_mac_o.d;
					end else if (r.istate == 6) begin
						fp_mac_i.a = v.y1;
						fp_mac_i.b = v.h1;
						fp_mac_i.c = v.r0[51:25];
						fp_mac_i.op = 0;
						v.y2 = fp_mac_o.d[51:25];
					end else if (r.istate == 7) begin
						fp_mac_i.a = v.qa;
						fp_mac_i.b = v.y2;
						fp_mac_i.c = v.y2;
						fp_mac_i.op = 1;
						v.r0 = fp_mac_o.d;
					end else if (r.istate == 8) begin
						fp_mac_i.a = v.y2;
						fp_mac_i.b = v.h1;
						fp_mac_i.c = v.r0[51:25];
						fp_mac_i.op = 0;
						v.q0 = fp_mac_o.d[51:25];
					end else if (r.istate == 9) begin
						fp_mac_i.a = v.qa;
						fp_mac_i.b = v.q0;
						fp_mac_i.c = v.q0;
						fp_mac_i.op = 1;
						v.r1 = fp_mac_o.d;
						v.q1 = v.q0;
						if ($signed(v.r1[51:25]) > 0) begin
							v.q1 = v.q1 + 1;
						end
					end else if (r.istate == 10) begin
						fp_mac_i.a = v.qa;
						fp_mac_i.b = v.q1;
						fp_mac_i.c = v.q1;
						fp_mac_i.op = 1;
						v.r0 = fp_mac_o.d;
						if (v.r0[51:25] == 0) begin
							v.q0 = v.q1;
							v.r1 = v.r0;
						end
					end else begin
						fp_mac_i.a = 0;
						fp_mac_i.b = 0;
						fp_mac_i.c = 0;
						fp_mac_i.op = 0;
					end
				end else if (r.state == 3) begin
					fp_mac_i.a = 0;
					fp_mac_i.b = 0;
					fp_mac_i.c = 0;
					fp_mac_i.op = 0;

					v.mantissa_fdiv = {v.q0[25:0],30'h0};

					v.remainder_rnd = 2;
					if ($signed(v.r1) > 0) begin
						v.remainder_rnd = 1;
					end else if (v.r1 == 0) begin
						v.remainder_rnd = 0;
					end

					v.counter_fdiv = 0;
					if (v.mantissa_fdiv[55] == 0) begin
						v.mantissa_fdiv = {v.mantissa_fdiv[54:0],1'h0};
						v.counter_fdiv = 1;
					end
					if (v.op == 1) begin
						v.counter_fdiv = 1;
						if (v.mantissa_fdiv[55] == 0) begin
							v.mantissa_fdiv = {v.mantissa_fdiv[54:0],1'h0};
							v.counter_fdiv = 0;
						end
					end

					v.exponent_bias = 127;

					v.sign_rnd = v.sign_fdiv;
					v.exponent_rnd = v.exponent_fdiv + {3'h0,v.exponent_bias} - {9'h0,v.counter_fdiv};

					v.counter_rnd = 0;
					if ($signed(v.exponent_rnd) <= 0) begin
						v.counter_rnd = 25;
						if ($signed(v.exponent_rnd) > -25) begin
							v.counter_rnd = 11'h1 - v.exponent_rnd;
						end
						v.exponent_rnd = 0;
					end

					v.mantissa_fdiv = v.mantissa_fdiv >> v.counter_rnd[5:0];

					v.mantissa_rnd = {1'h0,v.mantissa_fdiv[55:32]};
					v.grs = {v.mantissa_fdiv[31:30],|v.mantissa_fdiv[29:0]};

				end else begin
					fp_mac_i.a = 0;
					fp_mac_i.b = 0;
					fp_mac_i.c = 0;
					fp_mac_i.op = 0;

				end

				fp_fdiv_o.fp_rnd.sig = v.sign_rnd;
				fp_fdiv_o.fp_rnd.expo = v.exponent_rnd;
				fp_fdiv_o.fp_rnd.mant = v.mantissa_rnd;
				fp_fdiv_o.fp_rnd.rema = v.remainder_rnd;
				fp_fdiv_o.fp_rnd.fmt = v.fmt;
				fp_fdiv_o.fp_rnd.rm = v.rm;
				fp_fdiv_o.fp_rnd.grs = v.grs;
				fp_fdiv_o.fp_rnd.snan = v.snan;
				fp_fdiv_o.fp_rnd.qnan = v.qnan;
				fp_fdiv_o.fp_rnd.dbz = v.dbz;
				fp_fdiv_o.fp_rnd.inf = v.inf;
				fp_fdiv_o.fp_rnd.zero = v.zero;
				fp_fdiv_o.ready = v.ready;

				rin = v;

			end

			always_ff @(posedge clock) begin
				if (reset == 0) begin
					r <= init_fp_fdiv_reg_functional;
				end else begin
					r <= rin;
				end
			end

		end

		if (PERFORMANCE == 0) begin

			always_comb begin

				v_fix = r_fix;

				if (r_fix.state == 0) begin
					if (fp_fdiv_i.op.fdiv) begin
						v_fix.state = 1;
						v_fix.istate = 25;
					end
					if (fp_fdiv_i.op.fsqrt) begin
						v_fix.state = 1;
						v_fix.istate = 24;
					end
					v_fix.ready = 0;
				end else if (r_fix.state == 1) begin
					if (v_fix.istate == 0) begin
						v_fix.state = 2;
					end else begin
						v_fix.istate = v_fix.istate - 5'd1;
					end
					v_fix.ready = 0;
				end else if (r_fix.state == 2) begin
					v_fix.state = 3;
					v_fix.ready = 0;
				end else begin
					v_fix.state = 0;
					v_fix.ready = 1;
				end

				if (r_fix.state == 0) begin

					v_fix.a = fp_fdiv_i.data1;
					v_fix.b = fp_fdiv_i.data2;
					v_fix.class_a = fp_fdiv_i.class1;
					v_fix.class_b = fp_fdiv_i.class2;
					v_fix.fmt = fp_fdiv_i.fmt;
					v_fix.rm = fp_fdiv_i.rm;
					v_fix.snan = 0;
					v_fix.qnan = 0;
					v_fix.dbz = 0;
					v_fix.inf = 0;
					v_fix.zero = 0;

					if (fp_fdiv_i.op.fsqrt) begin
						v_fix.b = 33'h07F800000;
						v_fix.class_b = 0;
					end

					if (v_fix.class_a[8] | v_fix.class_b[8]) begin
						v_fix.snan = 1;
					end else if ((v_fix.class_a[3] | v_fix.class_a[4]) & (v_fix.class_b[3] | v_fix.class_b[4])) begin
						v_fix.snan = 1;
					end else if ((v_fix.class_a[0] | v_fix.class_a[7]) & (v_fix.class_b[0] | v_fix.class_b[7])) begin
						v_fix.snan = 1;
					end else if (v_fix.class_a[9] | v_fix.class_b[9]) begin
						v_fix.qnan = 1;
					end

					if ((v_fix.class_a[0] | v_fix.class_a[7]) & (v_fix.class_b[1] | v_fix.class_b[2] | v_fix.class_b[3] | v_fix.class_b[4] | v_fix.class_b[5] | v_fix.class_b[6])) begin
						v_fix.inf = 1;
					end else if ((v_fix.class_b[3] | v_fix.class_b[4]) & (v_fix.class_a[1] | v_fix.class_a[2] | v_fix.class_a[5] | v_fix.class_a[6])) begin
						v_fix.dbz = 1;
					end

					if ((v_fix.class_a[3] | v_fix.class_a[4]) | (v_fix.class_b[0] | v_fix.class_b[7])) begin
						v_fix.zero = 1;
					end

					if (fp_fdiv_i.op.fsqrt) begin
						if (v_fix.class_a[7]) begin
							v_fix.inf = 1;
						end
						if (v_fix.class_a[0] | v_fix.class_a[1] | v_fix.class_a[2]) begin
							v_fix.snan = 1;
						end
					end

					v_fix.sign_fdiv = v_fix.a[32] ^ v_fix.b[32];

					v_fix.exponent_fdiv = {2'h0,v_fix.a[31:23]} - {2'h0,v_fix.b[31:23]};
					if (fp_fdiv_i.op.fsqrt) begin
						v_fix.exponent_fdiv = ($signed({2'h0,v_fix.a[31:23]}) + $signed(-11'd253)) >>> 1;
					end

					v_fix.q = 0;

					v_fix.m = {4'h1,v_fix.b[22:0],1'h0};
					v_fix.r = {5'h1,v_fix.a[22:0]};
					v_fix.op = 0;
					if (fp_fdiv_i.op.fsqrt) begin
						v_fix.m = 0;
						if (v_fix.a[23] == 0) begin
							v_fix.r = {v_fix.r[26:0],1'h0};
						end
						v_fix.op = 1;
					end

				end else if (r_fix.state == 1) begin

					if (v_fix.op == 1) begin
						v_fix.m = {1'h0,v_fix.q,1'h0};
						v_fix.m[r_fix.istate] = 1;
					end
					v_fix.r = {v_fix.r[26:0],1'h0};
					v_fix.e = $signed(v_fix.r) - $signed(v_fix.m);
					if (v_fix.e[26] == 0) begin
						v_fix.q[r_fix.istate] = 1;
						v_fix.r = v_fix.e;
					end

				end else if (r_fix.state == 2) begin

					v_fix.mantissa_fdiv = {v_fix.q,v_fix.r[26:0],25'h0};

					v_fix.counter_fdiv = 0;
					if (v_fix.mantissa_fdiv[77] == 0) begin
						v_fix.counter_fdiv = 1;
					end

					v_fix.mantissa_fdiv = v_fix.mantissa_fdiv << v_fix.counter_fdiv;

					v_fix.sign_rnd = v_fix.sign_fdiv;

					v_fix.exponent_bias = 127;

					v_fix.exponent_rnd = v_fix.exponent_fdiv + {3'h0,v_fix.exponent_bias} - {9'h0,v_fix.counter_fdiv};

					v_fix.counter_rnd = 0;
					if ($signed(v_fix.exponent_rnd) <= 0) begin
						v_fix.counter_rnd = 25;
						if ($signed(v_fix.exponent_rnd) > -25) begin
							v_fix.counter_rnd = 11'h1 - v_fix.exponent_rnd;
						end
						v_fix.exponent_rnd = 0;
					end

					v_fix.mantissa_fdiv = v_fix.mantissa_fdiv >> v_fix.counter_rnd[5:0];

					v_fix.mantissa_rnd = {1'h0,v_fix.mantissa_fdiv[77:54]};
					v_fix.grs = {v_fix.mantissa_fdiv[53:52],|(v_fix.mantissa_fdiv[51:0])};

				end

				fp_fdiv_o.fp_rnd.sig = v_fix.sign_rnd;
				fp_fdiv_o.fp_rnd.expo = v_fix.exponent_rnd;
				fp_fdiv_o.fp_rnd.mant = v_fix.mantissa_rnd;
				fp_fdiv_o.fp_rnd.rema = 2'h0;
				fp_fdiv_o.fp_rnd.fmt = v_fix.fmt;
				fp_fdiv_o.fp_rnd.rm = v_fix.rm;
				fp_fdiv_o.fp_rnd.grs = v_fix.grs;
				fp_fdiv_o.fp_rnd.snan = v_fix.snan;
				fp_fdiv_o.fp_rnd.qnan = v_fix.qnan;
				fp_fdiv_o.fp_rnd.dbz = v_fix.dbz;
				fp_fdiv_o.fp_rnd.inf = v_fix.inf;
				fp_fdiv_o.fp_rnd.zero = v_fix.zero;
				fp_fdiv_o.ready = v_fix.ready;

				rin_fix = v_fix;

			end

			always_ff @(posedge clock) begin
				if (reset == 0) begin
					r_fix <= init_fp_fdiv_reg_fixed;
				end else begin
					r_fix <= rin_fix;
				end
			end

		end

	endgenerate

endmodule
