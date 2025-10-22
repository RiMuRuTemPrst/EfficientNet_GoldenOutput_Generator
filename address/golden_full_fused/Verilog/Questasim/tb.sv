`timescale 1ns/10ps
`define CYCLE     2.5
`define MAX_CYCLE 64'd30000000000

`ifdef SYN
  // TODO: add your cell lib + synthesized netlist here
`else
  `include "../src/DFRAM.sv"
  `include "../src/requantize16_core.sv"
  `include "../src/requantize16_top.sv"
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
  // Chỉnh path cho khớp với project của bạn
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
  logic signed [7:0]       out_zp;

  logic                    ready;
  logic                    done;
  logic [LANES*8-1:0]      ofm_vec;

  // DUT
  requantize16_top #(.LANES(LANES), .DEPTH(DEPTH), .AW(AW)) i_DUT (
    .clk        (clk),
    .rst_n      (rst_n),

    // write ports (không dùng: TB nạp trực tiếp vào mem)
    .m_wr_en    (1'b0),
    .m_wr_addr  ('0),
    .m_wr_data  ('0),
    .e_wr_en    (1'b0),
    .e_wr_addr  ('0),
    .e_wr_data  ('0),

    // run
    .start      (start),
    .addr       (addr_r),
    .acc_vec    (acc_vec),
    .out_zp     (out_zp),

    .ready      (ready),
    .done       (done),
    .ofm_vec    (ofm_vec)
  );

  //==================== File buffers ====================//
  int         code;
  int         errors = 0;
  int         shown  = 0; // in tối đa 10 mismatch

  int          signed qmul   [$];  // int32 từ qmul_map
  byte         signed expv   [$];  // int8  từ exp_map
  int          signed acc    [$];  // int32 từ acc_map
  byte         signed golden [$];  // int8  từ golden OFM

  //==================== Helpers ====================//
  task automatic read_int_file(input string fname, output int signed arr[$]);
    int fp, v, c;
    begin
      arr.delete();
      fp = $fopen(fname, "r");
      if (!fp) begin
        $display("[TB] ERROR: cannot open %s", fname); $finish;
      end
      while (!$feof(fp)) begin
        c = $fscanf(fp, "%d\n", v);
        if (c==1) arr.push_back(v);
      end
      $fclose(fp);
    end
  endtask

  task automatic read_int8_file(input string fname, output byte signed arr[$]);
    int fp, v, c;
    byte signed tmpb;
    begin
      arr.delete();
      fp = $fopen(fname, "r");
      if (!fp) begin
        $display("[TB] ERROR: cannot open %s", fname); $finish;
      end
      while (!$feof(fp)) begin
        c = $fscanf(fp, "%d\n", v);
        if (c==1) begin
          tmpb = v;               // sign-cast về int8
          arr.push_back(tmpb);
        end
      end
      $fclose(fp);
    end
  endtask

  // Gói 16-lane / entry & nạp trực tiếp 2 DFRAM bên trong DUT (hierarchical)
  task automatic load_mem_from_arrays();
    int entries, idx, k;
    logic [LANES*32-1:0] M_pack;
    logic [LANES*8 -1:0] E_pack;
    begin
      if ( (qmul.size()%LANES)!=0 || (expv.size()%LANES)!=0 ||
           (acc.size()%LANES )!=0 || (golden.size()%LANES)!=0 ) begin
        $display("[TB] ERROR: file sizes are not multiple of %0d lanes.", LANES);
        $finish;
      end
      entries = qmul.size()/LANES;
      if ( entries != (expv.size()/LANES) ||
           entries != (acc.size()/LANES ) ||
           entries != (golden.size()/LANES) ) begin
        $display("[TB] ERROR: arrays size mismatch (entries).");
        $finish;
      end

      for (idx=0; idx<entries; idx++) begin
        M_pack = '0; E_pack = '0;
        for (k=0; k<LANES; k++) begin
          M_pack[k*32 +: 32] = qmul [idx*LANES + k][31:0];
          E_pack[k*8  +:  8] = expv [idx*LANES + k][7:0];
        end
        // nạp trực tiếp vào mem của DFRAM
        i_DUT.u_dfram_M.mem[idx] = M_pack;
        i_DUT.u_dfram_E.mem[idx] = E_pack;
      end
      $display("[TB] Loaded %0d entries into DFRAM(M) & DFRAM(E).", entries);
    end
  endtask

  // Chạy lần lượt từng entry: phát start, đợi done, so sánh 16 byte
  task automatic run_and_check();
    int entries, idx, k, base;
    byte signed dutb, refb;
    begin
      out_zp  = OUT_ZP;
      entries = acc.size()/LANES;

      start   = 1'b0;
      addr_r  = '0;
      acc_vec = '0;
      @(negedge clk);

      for (idx=0; idx<entries; idx++) begin
        // pack acc_vec
        for (k=0; k<LANES; k++)
          acc_vec[k*32 +: 32] = acc[idx*LANES + k][31:0];

        addr_r = idx[AW-1:0];

        // start 1 chu kỳ
        start = 1'b1;
        @(negedge clk);
        start = 1'b0;

        // đợi done (core: done sau 2 clk kể từ start)
        wait (done===1'b1);
        @(negedge clk); // chốt ofm_vec tại done

        base = idx*LANES;
        for (k=0; k<LANES; k++) begin
          dutb = ofm_vec[k*8 +: 8];
          refb = golden[base + k];
          if (dutb !== refb) begin
            errors++;
            if (shown < 10) begin
              $display("[Mismatch] entry=%0d lane=%0d : DUT=%0d (0x%0h) vs GOLD=%0d (0x%0h)",
                        idx, k, $signed(dutb), dutb, $signed(refb), refb);
              shown++;
            end
          end
        end
      end

      if (errors==0)
        $display("[TB] ✅ PASS: all %0d entries × %0d lanes matched.", entries, LANES);
      else
        $display("[TB] ❌ FAIL: %0d mismatches found.", errors);
    end
  endtask

  //==================== Main ====================//
  initial begin
    @(posedge rst_n);

    read_int_file (QMUL_FILE,   qmul);
    read_int8_file(EXP_FILE,    expv);
    read_int_file (ACC_FILE,    acc);
    read_int8_file(GOLDEN_FILE, golden);

    $display("[TB] Sizes: M=%0d, exp=%0d, acc=%0d, golden=%0d",
              qmul.size(), expv.size(), acc.size(), golden.size());

    load_mem_from_arrays();
    run_and_check();

    if (errors==0) begin
      print_cat_pass();
    end else begin
      print_cat_fail();
    end
    $finish;
  end

  //==================== Timeout ====================//
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
