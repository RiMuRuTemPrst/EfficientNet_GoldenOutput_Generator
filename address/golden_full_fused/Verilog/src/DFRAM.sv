// DFRAM_FF.sv — Single-port, synchronous read (1-cycle after rd_req)
// Version: Force synthesis to FF/LUTRAM instead of BRAM
module DFRAM #(
  parameter int DW    = 128,                 // data width per entry
  parameter int DEPTH = 1024,
  parameter int AW    = $clog2(DEPTH)
)(
  input  logic           clk,
  input  logic           rst_n,

  // ===== Write port (config phase) =====
  input  logic           wr_en,              // 1: write mem[wr_addr] <= wr_data
  input  logic [AW-1:0]  wr_addr,
  input  logic [DW-1:0]  wr_data,

  // ===== Read request (run phase) =====
  input  logic           rd_req,             // pulse: request read at rd_addr
  input  logic [AW-1:0]  rd_addr,
  output logic [DW-1:0]  rd_data,            // valid on next cycle
  output logic           rd_valid            // = rd_req delayed by 1
);

  // Force synthesis to distributed (FF/LUTRAM) instead of block RAM
  (* ram_style = "distributed" *)    // Vivado
  // (* syn_ramstyle = "registers" *) // For Synplify
  logic [DW-1:0] mem [0:DEPTH-1];

  // Read pipeline
  logic [AW-1:0] rd_addr_q;
  logic          rd_req_q;

  // Synchronous logic
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      rd_addr_q <= '0;
      rd_req_q  <= 1'b0;
      rd_data   <= '0;
      rd_valid  <= 1'b0;
    end else begin
      // write
      if (wr_en) begin
        mem[wr_addr] <= wr_data;
      end
      // latch read address when requested
      if (rd_req) begin
        rd_addr_q <= rd_addr;
      end
      // synchronous read (1-cycle delay)
      rd_data  <= mem[rd_addr_q];
      rd_valid <= rd_req_q;
      rd_req_q <= rd_req;
    end
  end
endmodule
