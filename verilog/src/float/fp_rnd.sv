import fp_wire::*;

module fp_rnd (
    input  fp_rnd_in_type  fp_rnd_i,
    output fp_rnd_out_type fp_rnd_o
);
  timeunit 1ns; timeprecision 1ps;

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
  logic infs;
  logic zero;
  logic diff;

  logic odd;
  logic rndup;
  logic rnddn;
  logic shift;
  logic [31:0] result;
  logic [4:0] flags;

  always_comb begin

    sig = fp_rnd_i.sig;
    expo = fp_rnd_i.expo;
    mant = fp_rnd_i.mant;
    rema = fp_rnd_i.rema;
    fmt = fp_rnd_i.fmt;
    rm = fp_rnd_i.rm;
    grs = fp_rnd_i.grs;
    snan = fp_rnd_i.snan;
    qnan = fp_rnd_i.qnan;
    dbz = fp_rnd_i.dbz;
    infs = fp_rnd_i.infs;
    zero = fp_rnd_i.zero;
    diff = fp_rnd_i.diff;

    result = 0;
    flags = 0;

    odd = mant[0] | |grs[1:0] | (rema == 1);
    flags[0] = (rema != 0) | |grs;

    rndup = 0;
    rnddn = 0;
    if (rm == 0) begin  //rne
      if (grs[2] & odd) begin
        rndup = 1;
      end
    end else if (rm == 1) begin  //rtz
      rnddn = 1;
    end else if (rm == 2) begin  //rdn
      if (sig & flags[0]) begin
        rndup = 1;
      end else if (~sig & zero & diff) begin
        sig = ~sig;
      end else if (~sig) begin
        rnddn = 1;
      end
    end else if (rm == 3) begin  //rup
      if (~sig & flags[0]) begin
        rndup = 1;
      end else if (sig) begin
        rnddn = 1;
      end
    end else if (rm == 4) begin  //rmm
      if (grs[2] & flags[0]) begin
        rndup = 1;
      end
    end

    //if (expo == 0) begin
    //	flags[1] = flags[0];
    //end

    mant = mant + {24'h0, rndup};

    if (rndup == 1) begin
      if (expo == 0) begin
        if (mant[23]) begin
          expo = 1;
        end
      end
    end

    if (rnddn == 1) begin
      if (expo >= 255) begin
        expo  = 254;
        mant  = {2'b0, {23{1'b1}}};
        flags = 5'b00101;
      end
    end

    shift = 0;
    if (fmt == 0) begin
      if (mant[24]) begin
        shift = 1;
      end
    end

    expo = expo + {10'h0, shift};
    mant = mant >> shift;

    if (expo == 0) begin
      flags[1] = flags[0];
    end

    if (rndup == 1) begin
      if (expo == 1) begin
        if (|mant[22:0] == 0) begin
          flags[1] = rm == 2 || rm == 3 ? ((grs == 1) | (grs == 2) | (grs == 3) | (grs == 4)) : ((grs == 4) | (grs == 5));
        end
      end
    end

    if (snan) begin
      flags = 5'b10000;
    end else if (qnan) begin
      flags = 5'b00000;
    end else if (dbz) begin
      flags = 5'b01000;
    end else if (infs) begin
      flags = 5'b00000;
    end else if (zero) begin
      flags = 5'b00000;
    end

    if (fmt == 0) begin
      if (snan | qnan) begin
        result = {1'h0, 8'hFF, 23'h400000};
      end else if (dbz | infs) begin
        result = {sig, 8'hFF, 23'h000000};
      end else if (zero) begin
        result = {sig, 8'h00, 23'h000000};
      end else if (expo == 0) begin
        result = {sig, 8'h00, mant[22:0]};
      end else if ($signed(expo) > 254) begin
        flags  = 5'b00101;
        result = {sig, 8'hFF, 23'h000000};
      end else begin
        result = {sig, expo[7:0], mant[22:0]};
      end
    end

    fp_rnd_o.result = result;
    fp_rnd_o.flags  = flags;

  end

endmodule
