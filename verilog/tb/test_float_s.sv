import fp_wire::*;

module test_float_s
(
  input  logic reset,
  input  logic clock
);

	timeunit 1ns;
	timeprecision 1ps;

	localparam TEST0 = 0;
	localparam TEST1 = 1;
	localparam TEST2 = 2;

	integer data_file;
	integer scan_file;

	logic [31:0] dataread [0:3];

	typedef struct packed{
		logic [1:0] state;
		logic [31:0] data1;
		logic [31:0] data2;
		logic [31:0] data3;
		logic [31:0] result;
		logic [4:0] flags;
		logic [1:0] fmt;
		logic [2:0] rm;
		fp_operation_type op;
		logic [0:0] enable;
		logic [31:0] result_orig;
		logic [31:0] result_calc;
		logic [31:0] result_diff;
		logic [4:0] flags_orig;
		logic [4:0] flags_calc;
		logic [4:0] flags_diff;
		logic [0:0] ready_calc;
		logic [0:0] terminate;
	} fp_result;

	fp_result init_fp_res = '{
		state : TEST0,
		data1 : 0,
		data2 : 0,
		data3 : 0,
		result : 0,
		flags : 0,
		fmt : 0,
		rm : 0,
		op : init_fp_operation,
		enable : 0,
		result_orig : 0,
		result_calc : 0,
		result_diff : 0,
		flags_orig : 0,
		flags_calc : 0,
		flags_diff : 0,
		ready_calc : 0,
		terminate : 0
	};

	fp_result v;
	fp_result r,rin;

	fp_unit_in_type fp_unit_i;
	fp_unit_out_type fp_unit_o;

	string operation [0:1] = '{"f32_div","f32_sqrt"};
	string mode [0:4] = '{"rne","rtz","rdn","rup","rmm"};
	logic [2:0] rm [0:4] = '{0,1,2,3,4};

	string filename;

	logic load;

	integer i;
	integer j;

	always_comb begin

		@(posedge clock);

		if (reset == 0) begin
			load = 0;
			i = 0;
			j = 0;
		end

		if (load == 0) begin
			filename = {operation[i],"_",mode[j],".hex"};
			data_file = $fopen(filename, "r");
			if (data_file == 0) begin
				$display({filename," is not available!"});
				$finish;
			end
			load = 1;
		end

		v = r;

		case(r.state)
			TEST0 : begin
				if (reset == 0) begin
					v.state = TEST0;
					v.enable = 0;
				end else begin
					v.state = TEST1;
					v.enable = 1;
				end
			end
			TEST1 : begin
				if (fp_unit_o.fp_exe_o.ready == 1) begin
					v.state = TEST2;
				end
				v.enable = 0;
			end
			TEST2 : begin
				v.state = TEST0;
				v.enable = 0;
			end
			default : begin
				v.state = TEST0;
				v.enable = 0;
			end
		endcase

		case(r.state)
			TEST0 : begin
				if ($feof(data_file)) begin
					v.enable = 1;
					v.terminate = 1;
					dataread = '{default:0};
				end else begin
					v.enable = 1;
					v.terminate = 0;
					scan_file = $fscanf(data_file,"%h %h %h %h\n", dataread[0], dataread[1], dataread[2], dataread[3]);
				end
				
				if (v.terminate == 1) begin
					$write("%c[1;34m",8'h1B);
					$display({operation[i]," ",mode[j]});
					$write("%c[0m",8'h1B);
					$write("%c[1;32m",8'h1B);
					$display("TEST SUCCEEDED");
					$write("%c[0m",8'h1B);
					$finish;
				end

				if (operation[i] == "f32_div") begin
					v.data1 = dataread[0];
					v.data2 = dataread[1];
					v.data3 = 0;
					v.result = dataread[2];
					v.flags = dataread[3][4:0];
				end else begin
					v.data1 = dataread[0];
					v.data2 = 0;
					v.data3 = 0;
					v.result = dataread[1];
					v.flags = dataread[2][4:0];
				end

				v.fmt = 0;
				v.rm = rm[j];
				v.op.fmadd = 0;
				v.op.fadd = 0;
				v.op.fsub = 0;
				v.op.fmul = 0;
				v.op.fdiv = operation[i] == "f32_div" ? 1 : 0;
				v.op.fsqrt = operation[i] == "f32_sqrt" ? 1 : 0;
				v.op.fcmp = 0;
				v.op.fcvt_i2f = 0;
				v.op.fcvt_f2i = 0;
				v.op.fcvt_op = 0;

				if (reset == 0) begin
					v.op = init_fp_operation;
					v.enable = 0;
				end
			end
			TEST1 : begin
				v.result_orig = v.result;
				v.flags_orig = v.flags;

				v.result_calc = fp_unit_o.fp_exe_o.result;
				v.flags_calc = fp_unit_o.fp_exe_o.flags;
				v.ready_calc = fp_unit_o.fp_exe_o.ready;

				if (v.ready_calc == 1) begin
					if ((v.op.fcvt_f2i == 0 && v.op.fcmp == 0) && v.result_calc[31:0] == 32'h7FC00000) begin
						v.result_diff = {1'h0,v.result_orig[30:22] ^ v.result_calc[30:22],22'h0};
					end else begin
						v.result_diff = v.result_orig ^ v.result_orig;
					end
					v.flags_diff = v.flags_orig ^ v.flags_calc;
				end else begin
					v.result_diff = 0;
					v.flags_diff = 0;
				end
				v.op = init_fp_operation;
				v.enable = 0;
			end
			TEST2 : begin
				if (v.ready_calc == 1) begin
					if ((v.result_diff != 0) || (v.flags_diff != 0)) begin
						$write("%c[1;34m",8'h1B);
						$display({operation[i]," ",mode[j]});
						$write("%c[0m",8'h1B);
						$write("%c[1;31m",8'h1B);
						$display("TEST FAILED");
						$display("A                 = 0x%H",r.data1);
						$display("B                 = 0x%H",r.data2);
						$display("C                 = 0x%H",r.data3);
						$display("RESULT DIFFERENCE = 0x%H",v.result_diff);
						$display("RESULT REFERENCE  = 0x%H",v.result_orig);
						$display("RESULT CALCULATED = 0x%H",v.result_calc);
						$display("FLAGS DIFFERENCE  = 0x%H",v.flags_diff);
						$display("FLAGS REFERENCE   = 0x%H",v.flags_orig);
						$display("FLAGS CALCULATED  = 0x%H",v.flags_calc);
						$write("%c[0m",8'h1B);
						$finish;
					end
				end
				v.op = init_fp_operation;
				v.enable = 0;
			end
			default : begin
				v.op = init_fp_operation;
				v.enable = 0;
			end
		endcase

		fp_unit_i.fp_exe_i.data1 = v.data1;
		fp_unit_i.fp_exe_i.data2 = v.data2;
		fp_unit_i.fp_exe_i.data3 = v.data3;
		fp_unit_i.fp_exe_i.fmt = v.fmt;
		fp_unit_i.fp_exe_i.rm = v.rm;
		fp_unit_i.fp_exe_i.op = v.op;
		fp_unit_i.fp_exe_i.enable = v.enable;

		rin = v;

	end

	always_ff @(posedge clock) begin
		if (reset == 0) begin
			r <= init_fp_res;
		end else begin
			r <= rin;
		end
	end

	fp_unit fp_unit_comp
	(
		.reset ( reset ),
		.clock ( clock ),
		.fp_unit_i ( fp_unit_i ),
		.fp_unit_o ( fp_unit_o )
	);

endmodule
