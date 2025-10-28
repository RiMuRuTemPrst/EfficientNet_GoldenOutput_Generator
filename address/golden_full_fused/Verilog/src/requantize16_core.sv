// requantize16_core.sv — Core 16-lane, 1-stage pipeline (out register)
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

  // Kết quả combinational của từng lane
  logic signed [7:0] ofm_nx [LANES];

  // Generate các lane con — nối trực tiếp slice vào cổng con
  for (genvar i = 0; i < LANES; i++) begin : G_LANES
    requantize16_lane u_lane (
      .acc    ( $signed(acc_vec[i*32 +: 32]) ),
      .M      ( $signed(M_vec  [i*32 +: 32]) ),
      .ex     ( $signed(exp_vec[i*8  +: 8 ]) ),
      .out_zp ( out_zp ),
      .ofm_nx ( ofm_nx[i] )
    );
  end

  // Output register (giữ nguyên pipeline 1 chu kỳ như bản cũ)
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      out_valid <= 1'b0;
      ofm_vec   <= '0;
    end else begin
      out_valid <= in_valid;
      for (int j = 0; j < LANES; j++)
        ofm_vec[j*8 +: 8] <= ofm_nx[j];
    end
  end

endmodule
