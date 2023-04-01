import fp_wire::*;

module fp_mac
(
	input reset,
	input clock,
	input fp_mac_in_type fp_mac_i,
	output fp_mac_out_type fp_mac_o
);
	timeunit 1ns;
	timeprecision 1ps;

	logic [51:0] add;
	logic [53:0] mul;
	logic [51:0] mac;
	logic [51:0] res;

	assign add = {fp_mac_i.a,25'h0};
	assign mul = $signed(fp_mac_i.b) * $signed(fp_mac_i.c);
	assign mac = (fp_mac_i.op == 0) ? mul[51:0] : -mul[51:0];
	assign res = add + mac;
	assign fp_mac_o.d = res;

endmodule
