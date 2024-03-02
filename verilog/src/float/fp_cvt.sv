import lzc_wire::*;
import fp_wire::*;

module fp_cvt #(
    parameter RISCV = 0
) (
    input fp_cvt_f2i_in_type fp_cvt_f2i_i,
    output fp_cvt_f2i_out_type fp_cvt_f2i_o,
    input fp_cvt_i2f_in_type fp_cvt_i2f_i,
    output fp_cvt_i2f_out_type fp_cvt_i2f_o,
    input lzc_32_out_type lzc_o,
    output lzc_32_in_type lzc_i
);
  timeunit 1ns; timeprecision 1ps;

  fp_cvt_f2i_var_type v_f2i;
  fp_cvt_i2f_var_type v_i2f;

  generate

    if (RISCV == 0) begin

      always_comb begin

        v_f2i.data = fp_cvt_f2i_i.data;
        v_f2i.op = fp_cvt_f2i_i.op.fcvt_op;
        v_f2i.rm = fp_cvt_f2i_i.rm;
        v_f2i.classification = fp_cvt_f2i_i.classification;

        v_f2i.flags = 0;
        v_f2i.result = 0;

        v_f2i.snan = v_f2i.classification[8];
        v_f2i.qnan = v_f2i.classification[9];
        v_f2i.infs = v_f2i.classification[0] | v_f2i.classification[7];
        v_f2i.zero = 0;

        if (v_f2i.op == 0) begin
          v_f2i.exponent_bias = 34;
        end else begin
          v_f2i.exponent_bias = 35;
        end

        v_f2i.sign_cvt = v_f2i.data[32];
        v_f2i.exponent_cvt = v_f2i.data[31:23] - 10'd252;
        v_f2i.mantissa_cvt = {36'h1, v_f2i.data[22:0]};

        if ((v_f2i.classification[3] | v_f2i.classification[4]) == 1) begin
          v_f2i.mantissa_cvt[23] = 0;
        end

        v_f2i.oor = 0;

        if ($signed(v_f2i.exponent_cvt) > $signed({2'h0, v_f2i.exponent_bias})) begin
          v_f2i.oor = 1;
        end else if ($signed(v_f2i.exponent_cvt) > 0) begin
          v_f2i.mantissa_cvt = v_f2i.mantissa_cvt << v_f2i.exponent_cvt;
        end

        v_f2i.mantissa_uint = v_f2i.mantissa_cvt[58:26];

        v_f2i.grs = {v_f2i.mantissa_cvt[25:24], |v_f2i.mantissa_cvt[23:0]};
        v_f2i.odd = v_f2i.mantissa_uint[0] | |v_f2i.grs[1:0];

        v_f2i.flags[0] = |v_f2i.grs;

        v_f2i.rnded = 0;
        if (v_f2i.rm == 0) begin  //rne
          if (v_f2i.grs[2] & v_f2i.odd) begin
            v_f2i.rnded = 1;
          end
        end else if (v_f2i.rm == 2) begin  //rdn
          if (v_f2i.sign_cvt & v_f2i.flags[0]) begin
            v_f2i.rnded = 1;
          end
        end else if (v_f2i.rm == 3) begin  //rup
          if (~v_f2i.sign_cvt & v_f2i.flags[0]) begin
            v_f2i.rnded = 1;
          end
        end else if (v_f2i.rm == 4) begin  //rmm
          if (v_f2i.grs[2] & v_f2i.flags[0]) begin
            v_f2i.rnded = 1;
          end
        end

        v_f2i.mantissa_uint = v_f2i.mantissa_uint + {32'h0, v_f2i.rnded};

        v_f2i.or_1 = v_f2i.mantissa_uint[32];
        v_f2i.or_2 = v_f2i.mantissa_uint[31];
        v_f2i.or_3 = |v_f2i.mantissa_uint[30:0];

        v_f2i.zero = v_f2i.or_1 | v_f2i.or_2 | v_f2i.or_3;

        v_f2i.oor_32u = v_f2i.or_1;
        v_f2i.oor_32s = v_f2i.or_1;

        if (v_f2i.sign_cvt) begin
          if (v_f2i.op == 0) begin
            v_f2i.oor_32s = v_f2i.oor_32s | (v_f2i.or_2 & v_f2i.or_3);
          end else if (v_f2i.op == 1) begin
            v_f2i.oor = v_f2i.oor | v_f2i.zero;
          end
        end else begin
          v_f2i.oor_32s = v_f2i.oor_32s | v_f2i.or_2;
        end

        v_f2i.oor_32u = (v_f2i.op == 1) & (v_f2i.oor_32u | v_f2i.oor | v_f2i.infs | v_f2i.snan | v_f2i.qnan);
        v_f2i.oor_32s = (v_f2i.op == 0) & (v_f2i.oor_32s | v_f2i.oor | v_f2i.infs | v_f2i.snan | v_f2i.qnan);

        if (v_f2i.sign_cvt) begin
          v_f2i.mantissa_uint = -v_f2i.mantissa_uint;
        end

        if (v_f2i.op == 0) begin
          v_f2i.result = v_f2i.mantissa_uint[31:0];
          if (v_f2i.oor_32s) begin
            v_f2i.result = 32'h80000000;
            v_f2i.flags  = 5'b10000;
          end
        end else if (v_f2i.op == 1) begin
          v_f2i.result = v_f2i.mantissa_uint[31:0];
          if (v_f2i.oor_32u) begin
            v_f2i.result = 32'hFFFFFFFF;
            v_f2i.flags  = 5'b10000;
          end
        end

        fp_cvt_f2i_o.result = v_f2i.result;
        fp_cvt_f2i_o.flags  = v_f2i.flags;

      end

    end

    if (RISCV == 1) begin

      always_comb begin

        v_f2i.data = fp_cvt_f2i_i.data;
        v_f2i.op = fp_cvt_f2i_i.op.fcvt_op;
        v_f2i.rm = fp_cvt_f2i_i.rm;
        v_f2i.classification = fp_cvt_f2i_i.classification;

        v_f2i.flags = 0;
        v_f2i.result = 0;

        v_f2i.snan = v_f2i.classification[8];
        v_f2i.qnan = v_f2i.classification[9];
        v_f2i.infs = v_f2i.classification[0] | v_f2i.classification[7];
        v_f2i.zero = 0;

        if (v_f2i.op == 0) begin
          v_f2i.exponent_bias = 34;
        end else begin
          v_f2i.exponent_bias = 35;
        end

        v_f2i.sign_cvt = v_f2i.data[32];
        v_f2i.exponent_cvt = v_f2i.data[31:23] - 10'd252;
        v_f2i.mantissa_cvt = {36'h1, v_f2i.data[22:0]};

        if ((v_f2i.classification[3] | v_f2i.classification[4]) == 1) begin
          v_f2i.mantissa_cvt[23] = 0;
        end

        v_f2i.oor = 0;

        if ($signed(v_f2i.exponent_cvt) > $signed({2'h0, v_f2i.exponent_bias})) begin
          v_f2i.oor = 1;
        end else if ($signed(v_f2i.exponent_cvt) > 0) begin
          v_f2i.mantissa_cvt = v_f2i.mantissa_cvt << v_f2i.exponent_cvt;
        end

        v_f2i.mantissa_uint = v_f2i.mantissa_cvt[58:26];

        v_f2i.grs = {v_f2i.mantissa_cvt[25:24], |v_f2i.mantissa_cvt[23:0]};
        v_f2i.odd = v_f2i.mantissa_uint[0] | |v_f2i.grs[1:0];

        v_f2i.flags[0] = |v_f2i.grs;

        v_f2i.rnded = 0;
        if (v_f2i.rm == 0) begin  //rne
          if (v_f2i.grs[2] & v_f2i.odd) begin
            v_f2i.rnded = 1;
          end
        end else if (v_f2i.rm == 2) begin  //rdn
          if (v_f2i.sign_cvt & v_f2i.flags[0]) begin
            v_f2i.rnded = 1;
          end
        end else if (v_f2i.rm == 3) begin  //rup
          if (~v_f2i.sign_cvt & v_f2i.flags[0]) begin
            v_f2i.rnded = 1;
          end
        end else if (v_f2i.rm == 4) begin  //rmm
          if (v_f2i.grs[2] & v_f2i.flags[0]) begin
            v_f2i.rnded = 1;
          end
        end

        v_f2i.mantissa_uint = v_f2i.mantissa_uint + {32'h0, v_f2i.rnded};

        v_f2i.or_1 = v_f2i.mantissa_uint[32];
        v_f2i.or_2 = v_f2i.mantissa_uint[31];
        v_f2i.or_3 = |v_f2i.mantissa_uint[30:0];

        v_f2i.zero = v_f2i.or_1 | v_f2i.or_2 | v_f2i.or_3;

        v_f2i.oor_32u = v_f2i.or_1;
        v_f2i.oor_32s = v_f2i.or_1;

        if (v_f2i.sign_cvt) begin
          if (v_f2i.op == 0) begin
            v_f2i.oor_32s = v_f2i.oor_32s | (v_f2i.or_2 & v_f2i.or_3);
          end else if (v_f2i.op == 1) begin
            v_f2i.oor = v_f2i.oor | v_f2i.zero;
          end
        end else begin
          v_f2i.oor_32s = v_f2i.oor_32s | v_f2i.or_2;
        end

        v_f2i.oor_32u = (v_f2i.op == 1) & (v_f2i.oor_32u | v_f2i.oor | v_f2i.infs | v_f2i.snan | v_f2i.qnan);
        v_f2i.oor_32s = (v_f2i.op == 0) & (v_f2i.oor_32s | v_f2i.oor | v_f2i.infs | v_f2i.snan | v_f2i.qnan);

        if (v_f2i.sign_cvt) begin
          v_f2i.mantissa_uint = -v_f2i.mantissa_uint;
        end

        if (v_f2i.op == 0) begin
          v_f2i.result = v_f2i.mantissa_uint[31:0];
          if (v_f2i.oor_32s) begin
            v_f2i.result = 32'h7FFFFFFF;
            v_f2i.flags  = 5'b10000;
            if (v_f2i.sign_cvt) begin
              if (~(v_f2i.snan | v_f2i.qnan)) begin
                v_f2i.result = 32'h80000000;
              end
            end
          end
        end else if (v_f2i.op == 1) begin
          v_f2i.result = v_f2i.mantissa_uint[31:0];
          if (v_f2i.oor_32u) begin
            v_f2i.result = 32'hFFFFFFFF;
            v_f2i.flags  = 5'b10000;
          end
          if (v_f2i.sign_cvt) begin
            if (~(v_f2i.snan | v_f2i.qnan)) begin
              v_f2i.result = 32'h00000000;
            end
          end
        end

        fp_cvt_f2i_o.result = v_f2i.result;
        fp_cvt_f2i_o.flags  = v_f2i.flags;

      end

    end

  endgenerate

  always_comb begin

    v_i2f.data = fp_cvt_i2f_i.data;
    v_i2f.op = fp_cvt_i2f_i.op.fcvt_op;
    v_i2f.fmt = fp_cvt_i2f_i.fmt;
    v_i2f.rm = fp_cvt_i2f_i.rm;

    v_i2f.snan = 0;
    v_i2f.qnan = 0;
    v_i2f.dbz = 0;
    v_i2f.infs = 0;
    v_i2f.zero = 0;

    v_i2f.exponent_bias = 127;

    v_i2f.sign_uint = 0;
    if (v_i2f.op == 0) begin
      v_i2f.sign_uint = v_i2f.data[31];
    end

    if (v_i2f.sign_uint) begin
      v_i2f.data = -v_i2f.data;
    end

    v_i2f.mantissa_uint = 32'hFFFFFFFF;
    v_i2f.exponent_uint = 0;
    if (!v_i2f.op[1]) begin
      v_i2f.mantissa_uint = v_i2f.data[31:0];
      v_i2f.exponent_uint = 31;
    end

    v_i2f.zero = ~|v_i2f.mantissa_uint;

    lzc_i.a = v_i2f.mantissa_uint;
    v_i2f.counter_uint = ~lzc_o.c;

    v_i2f.mantissa_uint = v_i2f.mantissa_uint << v_i2f.counter_uint;

    v_i2f.sign_rnd = v_i2f.sign_uint;
    v_i2f.exponent_rnd = {6'h0,v_i2f.exponent_uint} + {4'h0,v_i2f.exponent_bias} - {6'h0,v_i2f.counter_uint};

    v_i2f.mantissa_rnd = {1'h0, v_i2f.mantissa_uint[31:8]};
    v_i2f.grs = {v_i2f.mantissa_uint[7:6], |v_i2f.mantissa_uint[5:0]};

    fp_cvt_i2f_o.fp_rnd.sig = v_i2f.sign_rnd;
    fp_cvt_i2f_o.fp_rnd.expo = v_i2f.exponent_rnd;
    fp_cvt_i2f_o.fp_rnd.mant = v_i2f.mantissa_rnd;
    fp_cvt_i2f_o.fp_rnd.rema = 2'h0;
    fp_cvt_i2f_o.fp_rnd.fmt = v_i2f.fmt;
    fp_cvt_i2f_o.fp_rnd.rm = v_i2f.rm;
    fp_cvt_i2f_o.fp_rnd.grs = v_i2f.grs;
    fp_cvt_i2f_o.fp_rnd.snan = v_i2f.snan;
    fp_cvt_i2f_o.fp_rnd.qnan = v_i2f.qnan;
    fp_cvt_i2f_o.fp_rnd.dbz = v_i2f.dbz;
    fp_cvt_i2f_o.fp_rnd.infs = v_i2f.infs;
    fp_cvt_i2f_o.fp_rnd.zero = v_i2f.zero;
    fp_cvt_i2f_o.fp_rnd.diff = 1'h0;

  end

endmodule
