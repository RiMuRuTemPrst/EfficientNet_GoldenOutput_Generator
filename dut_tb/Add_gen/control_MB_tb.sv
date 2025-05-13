`timescale 1ns/1ps

module control_MB_tb;

  // Parameters
  parameter PE      = 16;
  parameter OFM_C   = 32;     // Nên chọn là bội của PE (ở đây tile = 512)
  parameter OFM_W   = 5;

  // Clock and Reset
  logic clk;
  logic rst_n;

  // Inputs to DUT
  logic valid;
  logic start;
  logic [PE*8-1:0] data_in;

  // Outputs from DUT
  logic wr_en;
  logic [31:0] addr_next;
  logic [PE*8-1:0] data_out;

  // Counter
  integer i, j, t;

  // Clock generation (100 MHz)
  always #5 clk = ~clk;

  // DUT instantiation
  control_MB #(
    .PE(PE)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .valid(valid),
    .start(start),
    .data_in(data_in),
    .OFM_C(OFM_C),
    .OFM_W(OFM_W),
    .wr_en(wr_en),
    .addr_next(addr_next),
    .data_out(data_out)
  );

  // Task: set valid signal with dummy data
  task set_valid_data(input int index);
    begin
      data_in = {PE{8'hA0 + index[3:0]}};
      valid = 1;
      @(posedge clk);
      valid = 0;
    end
  endtask

  // Test sequence
  initial begin
    $display("===== Start control_MB testbench =====");

    // Initial values
    clk = 0;
    rst_n = 0;
    start = 0;
    valid = 0;
    data_in = 0;

    // Apply reset
    #10;
    rst_n = 1;
    @(posedge clk);
    
    // Start FSM
    start = 1;
    @(posedge clk);
    start = 0;

    // Loop for all tiles
    for (t = 0; t < (OFM_C << 4) / (PE*8); t = t + 1) begin  // tile = OFM_C << 4
      for (i = 0; i < OFM_W; i = i + 1) begin // row
        for (j = 0; j < OFM_W; j = j + 1) begin // col
            repeat (10) begin
                @(posedge clk);
            end
          set_valid_data(j + i);
          repeat(1) @(posedge clk);
        end
      end
    end

    // Observe additional transitions
    repeat(20) @(posedge clk);

    $display("===== Finish testbench =====");
    $finish;
  end

  // Monitor output
  always_ff @(posedge clk) begin
    if (wr_en)
      $display("[%0t] wr_en=1, addr=%0d, data_out[7:0]=%h", $time, addr_next, data_out[7:0]);
  end

endmodule
