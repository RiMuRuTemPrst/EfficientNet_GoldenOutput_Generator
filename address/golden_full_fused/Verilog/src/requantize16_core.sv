// requantize16_core.sv — Core tính toán 16-lane, 1-stage pipeline
module requantize16_core #(
  parameter int LANES = 16
)(
  input  logic                    clk,
  input  logic                    rst_n,

  input  logic                    in_valid,        // nạp 1 vector vào core
  input  logic [LANES*32-1:0]     acc_vec,         // 16 x int32 (signed)
  input  logic [LANES*32-1:0]     M_vec,           // 16 x int32 (signed)
  input  logic [LANES*8-1:0]      exp_vec,         // 16 x int8  (signed)
  input  logic  signed [7:0]      out_zp,

  output logic                    out_valid,       // = in_valid trễ 1 clk
  output logic [LANES*8-1:0]      ofm_vec          // 16 x int8 (signed)
);
  // Unpack
  logic  signed [31:0] acc [LANES];
  logic  signed [31:0] M   [LANES];
  logic  signed [7:0]  ex  [LANES];

  for (genvar i=0;i<LANES;i++) begin : G_UNP
    always_comb begin
      acc[i] = $signed(acc_vec[i*32 +: 32]);
      M[i]   = $signed(M_vec  [i*32 +: 32]);
      ex[i]  = $signed(exp_vec[i*8  +: 8 ]);
    end
  end

  // Datapath (combinational)
  logic signed [63:0] prod [LANES], adj [LANES];
  logic signed [31:0] y    [LANES];
  logic        [5:0]  rsh  [LANES];
  logic        [31:0] mask [LANES], thr [LANES], rem [LANES];
  logic signed [31:0] q    [LANES], rq [LANES], addzp [LANES];
  logic signed [7:0]  ofm_nx [LANES];

  always_comb begin
    for (int i=0;i<LANES;i++) begin
      // y = srdhm(acc * M / 2^31), left_shift = 0
      prod[i] = acc[i] * M[i];
      adj[i]  = (prod[i] >= 0) ? (prod[i] + 64'sh4000_0000)
                                : (prod[i] + (64'sd1 - 64'sh4000_0000));
      y[i]    = $signed(adj[i] >>> 31);

      // right_shift = -exp if exp<0 else 0  (|exp| <= 31 → 6 bit đủ)
      rsh[i]  = (ex[i][7]) ? 6'(-ex[i]) : 6'd0;

      if (rsh[i] == 0) begin
        rq[i] = y[i];
      end else begin
        mask[i] = 32'hFFFF_FFFF >> (32 - rsh[i]);     // (1<<rsh)-1
        rem[i]  = $unsigned(y[i]) & mask[i];
        thr[i]  = mask[i] >> 1;
        q[i]    = $signed(y[i] >>> rsh[i]);           // arith shift
        if (y[i] < 0)
          rq[i] = q[i] + ((rem[i] >= thr[i]) ? 32'sd1 : 32'sd0);
        else
          rq[i] = q[i] + ((rem[i] >  thr[i]) ? 32'sd1 : 32'sd0);
      end

      // + out_zp rồi saturate về int8
      addzp[i] = rq[i] + {{24{out_zp[7]}}, out_zp};
      if      (addzp[i] >  32'sd127)  ofm_nx[i] =  8'sd127;
      else if (addzp[i] < -32'sd128)  ofm_nx[i] = -8'sd128;
      else                            ofm_nx[i] =  addzp[i][7:0];
    end
  end

  // Output register (1 clk)
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      out_valid <= 1'b0;
      ofm_vec   <= '0;
    end else begin
      out_valid <= in_valid;
      for (int j=0;j<LANES;j++)
        ofm_vec[j*8 +: 8] <= ofm_nx[j];
    end
  end
endmodule
