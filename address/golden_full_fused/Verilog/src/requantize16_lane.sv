// requantize16_lane.sv — combinational logic cho 1 lane
module requantize16_lane (
  input  logic  signed [31:0] acc,
  input  logic  signed [31:0] M,
  input  logic  signed [7:0]  ex,
  input  logic  signed [7:0]  out_zp,
  output logic  signed [7:0]  ofm_nx
);

  // y = srdhm(acc * M / 2^31), rounding như bản gốc
  logic signed [63:0] prod, adj;
  logic signed [31:0] y;
  logic       [5:0]   rsh;
  logic       [31:0]  mask, thr, rem;
  logic signed [31:0] q, rq, addzp;

  always_comb begin
    // 1) Nhân 32x32 -> 64, round-to-nearest-ties-to-away (như code gốc)
    prod = acc * M;
    adj  = (prod >= 0) ? (prod + 64'sh4000_0000)
                       : (prod + (64'sd1 - 64'sh4000_0000));
    y    = $signed(adj >>> 31);

    // 2) right_shift = -ex if ex<0 else 0  (|ex| <= 31 -> 6 bit đủ)
    rsh  = ex[7] ? -ex : 6'd0;

    if (rsh == 0) begin
        rq = y;
    end else begin
      mask = 32'hFFFF_FFFF >> (32 - rsh);   // (1<<rsh)-1
        rem  = $unsigned(y) & mask;
        thr  = mask >> 1;
      q    = $signed(y >>> rsh);            // arith shift
        if (y < 0)
        rq = q + ((rem >= thr) ? 32'sd1 : 32'sd0);
        else
        rq = q + ((rem >  thr) ? 32'sd1 : 32'sd0);
    end

    // 3) + out_zp và saturate về int8
    addzp = rq + {{24{out_zp[7]}}, out_zp};
    if      (addzp >  32'sd127)  ofm_nx =  8'sd127;
    else if (addzp < -32'sd128)  ofm_nx = -8'sd128;
    else                          ofm_nx =  addzp[7:0];
  end

endmodule
