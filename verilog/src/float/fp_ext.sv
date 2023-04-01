import lzc_wire::*;
import fp_wire::*;

module fp_ext
(
	input fp_ext_in_type fp_ext_i,
	output fp_ext_out_type fp_ext_o,
	input lzc_32_out_type lzc_o,
	output lzc_32_in_type lzc_i
);
	timeunit 1ns;
	timeprecision 1ps;

	logic [31:0] data;
	logic [1:0] fmt;

	logic [31:0] mantissa;
	logic [32:0] result;
	logic [9:0] classification;
	logic [4:0] counter;
	logic mantissa_zero;
	logic exponent_zero;
	logic exponent_ones;

	always_comb begin

		data = fp_ext_i.data;
		fmt = fp_ext_i.fmt;

		mantissa = 32'hFFFFFFFF;
		counter = 0;

		result = 0;
		classification = 0;

		mantissa_zero = 0;
		exponent_zero = 0;
		exponent_ones = 0;

		if (fmt == 0) begin
			mantissa = {1'h0,data[22:0],8'hFF};
			exponent_zero = ~|data[30:23];
			exponent_ones = &data[30:23];
			mantissa_zero = ~|data[22:0];
		end

		lzc_i.a = mantissa;
		counter = ~lzc_o.c;

		if (fmt == 0) begin
			result[32] = data[31];
			if (&data[30:23]) begin
				result[31:23] = 9'h1FF;
				result[22:0] = data[22:0];
			end else if (|data[30:23]) begin
				result[31:23] = {1'h0,data[30:23]} + 9'h080;
				result[22:0] = data[22:0];
			end else if (counter < 24) begin
				result[31:23] = 9'h081 - {4'h0,counter};
				result[22:0] = (data[22:0] << counter);
			end
		end

		if (result[32]) begin
			if (exponent_ones) begin
				if (mantissa_zero) begin
					classification[0] = 1;
				end else if (result[22] == 0) begin
					classification[8] = 1;
				end else begin
					classification[9] = 1;
				end
			end else if (exponent_zero) begin
				if (mantissa_zero == 1) begin
					classification[3] = 1;
				end else begin
					classification[2] = 1;
				end
			end else begin
				classification[1] = 1;
			end
		end else begin
			if (exponent_ones) begin
				if (mantissa_zero) begin
					classification[7] = 1;
				end else if (result[22] == 0) begin
					classification[8] = 1;
				end else begin
					classification[9] = 1;
				end
			end else if (exponent_zero) begin
				if (mantissa_zero == 1) begin
					classification[4] = 1;
				end else begin
					classification[5] = 1;
				end
			end else begin
				classification[6] = 1;
			end
		end

		fp_ext_o.result = result;
		fp_ext_o.classification = classification;

	end

endmodule
