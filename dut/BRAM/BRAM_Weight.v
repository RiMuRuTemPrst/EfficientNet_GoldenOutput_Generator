module BRAM_Weight #(
    parameter DATA_WIDTH    = 32,     // Số bit mỗi ô
    parameter DEPTH         = 8192,   // Tổng số ô nhớ
    parameter off_set_shift = 2       // Số bit dịch để truy cập theo word
)(
    input wire clk,
    input wire wr_rd_en,                               // Write enable
    input wire [$clog2(DEPTH)-1:0] wr_addr,            // Địa chỉ ghi
    input wire [$clog2(DEPTH*2**off_set_shift)-1:0] rd_addr,  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    input wire [DATA_WIDTH-1:0] data_in,               // Dữ liệu vào
    output reg [DATA_WIDTH-1:0] data_out               // Dữ liệu ra
);

    // Khai báo RAM theo DEPTH
    (* ram_style = "block" *) reg [DATA_WIDTH-1:0] bram [0:DEPTH-1];

    always @(posedge clk) begin
        if (wr_rd_en) begin
            bram[wr_addr] <= data_in;
        end
        data_out <= bram[rd_addr >> off_set_shift];
    end

endmodule
