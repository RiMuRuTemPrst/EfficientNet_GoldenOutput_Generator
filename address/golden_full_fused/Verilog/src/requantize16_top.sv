
module requantize16_top #(
  parameter int LANES   = 16,
  parameter int DEPTH   = 131072,
  parameter int AW      = $clog2(DEPTH)
)(
  input  logic                    clk,
  input  logic                    rst_n,

  // ===== Host viết cấu hình vào 2 DFRAM =====
  // M (512b / entry)
  input  logic                    m_wr_en,
  input  logic [AW-1:0]           m_wr_addr,
  input  logic [LANES*32-1:0]     m_wr_data,
  // EXP (128b / entry)
  input  logic                    e_wr_en,
  input  logic [AW-1:0]           e_wr_addr,
  input  logic [LANES*8-1:0]      e_wr_data,

  // ===== Tín hiệu chạy =====
  input  logic                    start,          // pulse 1 chu kỳ
  input  logic [AW-1:0]           addr,           // entry index cần đọc
  input  logic [LANES*32-1:0]     acc_vec,        // 16 x int32
  input  logic  signed [7:0]      out_zp,

  output logic                    ready,          // sẵn sàng nhận start
  output logic                    done,           // pulse khi ofm_vec hợp lệ
  output logic [LANES*8-1:0]      ofm_vec         // 16 x int8
);

  // ================= 2x DFRAM =================
  // M: 512-bit / entry
  logic                    m_rd_req;
  logic [AW-1:0]           m_rd_addr;
  logic [LANES*32-1:0]     m_rd_data;
  logic                    m_rd_valid;

  DFRAM #(.DW(LANES*32), .DEPTH(DEPTH), .AW(AW)) u_dfram_M (
    .clk     (clk),
    .wr_en   (m_wr_en),
    .wr_addr (m_wr_addr),
    .wr_data (m_wr_data),
    .rd_req  (m_rd_req),
    .rd_addr (m_rd_addr),
    .rd_data (m_rd_data),
    .rd_valid(m_rd_valid)
  );

  // EXP: 128-bit / entry (16 x int8)
  logic                    e_rd_req;
  logic [AW-1:0]           e_rd_addr;
  logic [LANES*8-1:0]      e_rd_data;
  logic                    e_rd_valid;

  DFRAM #(.DW(LANES*8), .DEPTH(DEPTH), .AW(AW)) u_dfram_E (
    .clk     (clk),
    .wr_en   (e_wr_en),
    .wr_addr (e_wr_addr),
    .wr_data (e_wr_data),
    .rd_req  (e_rd_req),
    .rd_addr (e_rd_addr),
    .rd_data (e_rd_data),
    .rd_valid(e_rd_valid)
  );

  typedef enum logic [1:0] {IDLE, WAIT_RD, ISSUE_CORE} state_t;
  state_t st, st_n;

  // Giữ acc & addr khi start
  logic [LANES*32-1:0] acc_q;
  logic [AW-1:0]       addr_q;

  // Core wires
  logic core_in_valid, core_out_valid;

  // Ready khi rảnh ở IDLE
  assign ready = (st == IDLE);
  assign done  = core_out_valid;

  // FSM
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) st <= IDLE;
    else        st <= st_n;
  end

  always_comb begin
    st_n = st;
    case (st)
      IDLE:     st_n = (start) ? WAIT_RD : IDLE;
      WAIT_RD:  st_n = (m_rd_valid && e_rd_valid) ? ISSUE_CORE : WAIT_RD;
      ISSUE_CORE: st_n = IDLE; // core out_valid trễ 1 chu kỳ, nhưng ta có 'done' riêng
      default:  st_n = IDLE;
    endcase
  end

  // Latch acc & addr tại start
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      acc_q  <= '0;
      addr_q <= '0;
    end else if (start && (st==IDLE)) begin
      acc_q  <= acc_vec;
      addr_q <= addr;
    end
  end

  // Phát rd_req đồng thời tới 2 DFRAM ở chu kỳ start
  assign m_rd_req = (st==IDLE) && start;
  assign e_rd_req = (st==IDLE) && start;
  assign m_rd_addr= addr;   // addr ổn định khi start
  assign e_rd_addr= addr;

  // Nạp vào core khi cả 2 DFRAM báo valid (chu kỳ kế)
  assign core_in_valid = (st==WAIT_RD) && m_rd_valid && e_rd_valid;

  requantize16_core #(.LANES(LANES)) u_core (
    .clk      (clk),
    .rst_n    (rst_n),
    .in_valid (core_in_valid),
    .acc_vec  (acc_q),       // acc đã giữ từ chu kỳ start
    .M_vec    (m_rd_data),   // data từ DFRAM (chu kỳ sau start)
    .exp_vec  (e_rd_data),
    .out_zp   (out_zp),
    .out_valid(core_out_valid),
    .ofm_vec  (ofm_vec)
  );

endmodule
