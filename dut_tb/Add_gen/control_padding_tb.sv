`timescale 1ns/1ps

module control_padding_tb;

  // Parameters
  parameter PE      = 16;
  parameter OFM_C   = 576;
  parameter OFM_W   = 14;
  parameter padding = 1;

  // Clock and Reset
  logic clk;
  logic rst_n;

  // Inputs to DUT
  logic valid;
  logic start;
  logic [PE*8-1:0] data_in;

  // Outputs from DUT
  logic wr_en;
  logic [15:0] addr_next;
  logic [PE*8-1:0] data_out;
  integer  i;

  // Clock generation
  always #5 clk = ~clk;  // 100 MHz clock

  // DUT instantiation
  control_padding_bug #(
    .PE(PE)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .OFM_W(OFM_W),
    .OFM_C(OFM_C),
    .padding(padding),
    .valid(valid),
    .start(start),
    .data_in(data_in),
    .wr_en(wr_en),
    .addr_next(addr_next),
    .data_out(data_out)
  );

  // Task to set valid high for 1 clock cycle
  task set_valid;
    begin
      valid = 1;
      @(posedge clk);  // Wait for 1 clock cycle
      valid = 0;
    end
  endtask

  // Test sequence
  initial begin
    $display("---- Starting testbench ----");

    // Initial values
    clk = 0;
    rst_n = 0;
    start = 0;
    valid = 0;
    data_in = '0;
    
    // Apply reset
    #10 rst_n = 1; start = 1;


    // Wait a few cycle    #20;

    // Start padding mode

    //start = 0;
    #25;

    // Wait 72 clock cycles
    for (i = 0; i < OFM_W * OFM_W * OFM_C ; i = i + 1) begin
    set_valid();
    repeat(23) @(posedge clk);
    end


    // Wait more to observe transitions
    #100;

    $display("---- Simulation complete ----");
   $finish;
  end
endmodule