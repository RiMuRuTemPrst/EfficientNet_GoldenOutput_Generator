`timescale 1ns/10ps
`define CYCLE     2.5
`define MAX_CYCLE 64'd300000  // timeout theo th�?i gian mô ph�?ng

`ifdef SYN
  // TODO: add lib + netlist synth nếu cần
`else
//  `include "../src/DFRAM.sv"
//  `include "../src/requantize16_core.sv"
//  `include "../src/requantize16_top.sv"
`endif

module tb_requantize16;

  //==================== Clock / Reset ====================//
  logic clk = 0;
  logic rst_n = 0;
  initial forever #(`CYCLE/2) clk = ~clk;
  initial begin
    rst_n = 0;
    #(`CYCLE*4);
    rst_n = 1;
  end

  //==================== File paths ====================//
  // Chỉnh path theo cấu trúc thư mục của bạn
  string QMUL_FILE   = "../../Golden_Data/Layer_Logs/layer_003_CONV_2D_qmul_map.txt";
  string EXP_FILE    = "../../Golden_Data/Layer_Logs/layer_003_CONV_2D_exp_map.txt";
  string ACC_FILE    = "../../Golden_Data/Layer_Logs/layer_003_CONV_2D_acc_map.txt";
  string GOLDEN_FILE = "../../Golden_Data/Data_Dump/golden_outputs/op_003_CONV_2D_output.txt";

  // Zero-point của layer (đổi nếu khác)
  localparam signed [7:0] OUT_ZP = 8'sd37;

  //==================== DUT wiring ====================//
  localparam int LANES = 16;
  localparam int DEPTH = 1<<20;     // đủ lớn
  localparam int AW    = $clog2(DEPTH);

  logic                    start;
  logic [AW-1:0]           addr_r;
  logic [LANES*32-1:0]     acc_vec;
  logic  signed [7:0]      out_zp;

  logic                    ready;
  logic                    done;
  logic [LANES*8-1:0]      ofm_vec;

  // DUT
  requantize16_top #(.LANES(LANES), .DEPTH(DEPTH), .AW(AW)) i_DUT (
    .clk        (clk),
    .rst_n      (rst_n),

    // write ports (TB ghi trực tiếp vào mem => không dùng cổng này)
    .m_wr_en    (1'b0), .m_wr_addr('0), .m_wr_data('0),
    .e_wr_en    (1'b0), .e_wr_addr('0), .e_wr_data('0),

    // run
    .start      (start),
    .addr       (addr_r),
    .acc_vec    (acc_vec),
    .out_zp     (out_zp),

    .ready      (ready),
    .done       (done),
    .ofm_vec    (ofm_vec)
  );

  //==================== Plusargs / Watchdog ====================//
  int LIMIT_ENTRIES = -1;         // ENTRIES=N để chạy nhanh 1 phần
  int MAX_WAIT_CYCLES = 32;       // MAXWAIT=W để chỉnh watchdog đợi 'done'
  initial begin
    if ($value$plusargs("ENTRIES=%d", LIMIT_ENTRIES))
      $display("[TB] LIMIT_ENTRIES = %0d", LIMIT_ENTRIES);
    if ($value$plusargs("MAXWAIT=%d", MAX_WAIT_CYCLES))
      $display("[TB] MAX_WAIT_CYCLES = %0d", MAX_WAIT_CYCLES);
  end

  //==================== File handles ====================//
  integer fm, fe, fa, fg;   // qmul, exp, acc, golden
  int errors = 0;
  int shown  = 0;           // in tối đa 10 mismatch
  int total_entries = 0;    // đếm theo stream thực tế

  //==================== Helpers: đ�?c 1 entry ====================//
  // Trả v�? 0 nếu EOF bất kỳ file nào khi đ�?c entry tiếp theo
  function automatic bit read_one_entry_pack_ME(
      output logic [LANES*32-1:0] M_pack,
      output logic [LANES*8 -1:0] E_pack
  );
    int c, v;
    byte signed vb;
    begin
      M_pack = '0;
      E_pack = '0;
      // đ�?c 16 qmul (int32 decimal)
      for (int k=0; k<LANES; k++) begin
        c = $fscanf(fm, "%d\n", v);
        if (c!=1) return 0;
        M_pack[k*32 +: 32] = $signed(v);
      end
      // đ�?c 16 exp (int8 decimal, có thể âm)
      for (int k=0; k<LANES; k++) begin
        c = $fscanf(fe, "%d\n", v);
        if (c!=1) return 0;
        vb = v; // cast v�? 8-bit có dấu
        E_pack[k*8 +: 8] = vb;
      end
      return 1;
    end
  endfunction

  function automatic bit read_one_entry_acc(
      output logic [LANES*32-1:0] ACC_pack
  );
    int c, v;
    begin
      ACC_pack = '0;
      for (int k=0; k<LANES; k++) begin
        c = $fscanf(fa, "%d\n", v);
        if (c!=1) return 0;
        ACC_pack[k*32 +: 32] = $signed(v);
      end
      return 1;
    end
  endfunction

  function automatic bit read_one_entry_golden(
      output logic [LANES*8-1:0] GOLD_pack
  );
    int c, v;
    byte signed vb;
    begin
      GOLD_pack = '0;
      for (int k=0; k<LANES; k++) begin
        c = $fscanf(fg, "%d\n", v);
        if (c!=1) return 0;
        vb = v; // cast v�? 8-bit có dấu
        GOLD_pack[k*8 +: 8] = vb;
      end
      return 1;
    end
  endfunction

  //==================== Quy trình chính theo entry ====================//
  task automatic process_all_entries();
    logic [LANES*32-1:0] M_pack, ACC_pack;
    logic [LANES*8 -1:0] E_pack;
    logic [LANES*8 -1:0] GOLD_pack;

    int idx = 0;

    begin
      out_zp = OUT_ZP;

      // mở file
      fm = $fopen(QMUL_FILE,   "r"); if (!fm) begin $display("[TB] ERROR open %s", QMUL_FILE);   $finish; end
      fe = $fopen(EXP_FILE,    "r"); if (!fe) begin $display("[TB] ERROR open %s", EXP_FILE);    $finish; end
      fa = $fopen(ACC_FILE,    "r"); if (!fa) begin $display("[TB] ERROR open %s", ACC_FILE);    $finish; end
      fg = $fopen(GOLDEN_FILE, "r"); if (!fg) begin $display("[TB] ERROR open %s", GOLDEN_FILE); $finish; end

      // ch�? reset
      @(posedge rst_n);
      @(negedge clk);

      // vòng lặp theo entry
      forever begin
        if (LIMIT_ENTRIES>0 && idx>=LIMIT_ENTRIES) break;

        // đ�?c 1 entry từ 4 file
        if (!read_one_entry_pack_ME(M_pack, E_pack)) break;
        if (!read_one_entry_acc(ACC_pack))           break;
        if (!read_one_entry_golden(GOLD_pack))       break;

        // nạp M/exp vào 2 DFRAM ở địa chỉ idx
        i_DUT.u_dfram_M.mem[idx] = M_pack;
        i_DUT.u_dfram_E.mem[idx] = E_pack;

        // ch�? DUT sẵn sàng (IDLE)
        if (!ready) @(posedge ready);

        // phát start cho entry này
        addr_r  = idx[AW-1:0];
        acc_vec = ACC_pack;
        start   = 1'b1;
        @(negedge clk);
        start   = 1'b0;

        // watchdog đợi done
        bit done_seen = 0;
        for (int w=0; w<MAX_WAIT_CYCLES; w++) begin
          @(negedge clk);
          if (done===1'b1) begin
            done_seen = 1;
            break;
          end
        end
        if (!done_seen) begin
          errors++;
          if (shown < 10) begin
            $display("[TB][TIMEOUT] entry=%0d addr=%0d: 'done' không v�? trong %0d chu kỳ.",
                     idx, addr_r, MAX_WAIT_CYCLES);
            shown++;
          end
          idx++;
          continue;
        end

        // so sánh 16 byte với golden của entry này
        @(negedge clk); // chốt ofm_vec tại chu kỳ 'done'
        for (int k=0; k<LANES; k++) begin
          byte signed dutb = ofm_vec[k*8 +: 8];
          byte signed refb = GOLD_pack[k*8 +: 8];
          if (dutb !== refb) begin
            errors++;
            if (shown < 10) begin
              $display("[Mismatch] entry=%0d lane=%0d : DUT=%0d (0x%0h) vs GOLD=%0d (0x%0h)",
                        idx, k, $signed(dutb), dutb, $signed(refb), refb);
              shown++;
            end
          end
        end

        idx++;
      end

      total_entries = idx;

      // đóng file
      $fclose(fm); $fclose(fe); $fclose(fa); $fclose(fg);

      if (errors==0)
        $display("[TB] ✅ PASS: %0d entries × %0d lanes khớp hoàn toàn.", total_entries, LANES);
      else
        $display("[TB] �?� FAIL: %0d mismatches trên %0d entries.", errors, total_entries);
    end
  endtask

  //==================== Main ====================//
  initial begin
    process_all_entries();

    if (errors==0) begin
      print_cat_pass();
    end else begin
      print_cat_fail();
    end
    $finish;
  end

  //==================== Timeout theo th�?i gian mô ph�?ng ====================//
  initial begin
    #(`MAX_CYCLE);
    print_cat_timeout();
    $finish;
  end

  //==================== Waveform (optional) ====================//
`ifdef FSDB
  initial begin
    $fsdbDumpfile("requantize.fsdb");
    $fsdbDumpvars("+struct", "+mda", tb_requantize16);
    $fsdbDumpvars("+struct", "+mda", i_DUT);
  end
`endif

  //==================== ASCII cat prints ====================//
  task automatic print_cat_pass;
    $display("\n");
    $display("\n");
    $display("        ****************************               ");
    $display("        **                        **       |\\__||  ");
    $display("        **  Congratulations !!    **      / O.O  | ");
    $display("        **                        **    /_____   | ");
    $display("        **  Simulation PASS!!     **   /^ ^ ^ \\  |");
    $display("        **                        **  |^ ^ ^ ^ |w| ");
    $display("        ****************************   \\m___m__|_|");
    $display("\n");
  endtask

  task automatic print_cat_fail;
    $display("\n");
    $display("\n");
    $display("        ****************************               ");
    $display("        **                        **       |\\__||  ");
    $display("        **  OOPS!!                **      / X,X  | ");
    $display("        **                        **    /_____   | ");
    $display("        **  Simulation Failed!!   **   /^ ^ ^ \\  |");
    $display("        **                        **  |^ ^ ^ ^ |w| ");
    $display("        ****************************   \\m___m__|_|");
    $display("\n");
  endtask

  task automatic print_cat_timeout;
    $display("\n");
    $display("\n");
    $display("        ****************************               ");
    $display("        **                        **       |\\__||  ");
    $display("        **  OOPS!! Timeout        **      / -,-  | ");
    $display("        **                        **    /_____   | ");
    $display("        **  Simulation Stopped!   **   /^ ^ ^ \\  |");
    $display("        **                        **  |^ ^ ^ ^ |w| ");
    $display("        ****************************   \\m___m__|_|");
    $display("\n");
  endtask

endmodule
