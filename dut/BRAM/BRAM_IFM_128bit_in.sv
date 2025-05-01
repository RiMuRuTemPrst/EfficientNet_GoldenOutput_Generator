module BRAM_IFM_128bit_in
#(
    parameter DATA_WIDTH= 32,
    parameter DEPTH= 100352
)(
    input wire clk,
    input wire wr_rd_en,                     // Write enable
    input wire [31:0] wr_addr,           // Write address (6-bit → 64 hàng)
    input wire [31:0] rd_addr,           // Read address (6-bit → 64 hàng)
    input wire [127:0] data_in,          // Dữ liệu đầu vào 64-bit
    output reg [31:0] data_out      // Đầu ra 2048-bit (256*8 bit)
    //output reg [19:0] addr
);

    // Dùng 32 khối BRAM chạy song song, mỗi khối lưu 64-bit
    reg [31:0] bram [0:DEPTH-1];  // Dùng 1 mảng một chiều
    
    //integer i;
    always @(posedge clk) begin
        if (wr_rd_en) begin
            bram[wr_addr]     <= data_in[31:0];  // Ghi dữ liệu vào BRAM
            bram[wr_addr + 1] <= data_in[63:32];  // Ghi dữ liệu vào BRAM
            bram[wr_addr + 2] <= data_in[95:64];  // Ghi dữ liệu vào BRAM
            bram[wr_addr + 3] <= data_in[127:96];  // Ghi dữ liệu vào BRAM
        end
        data_out <= bram[ rd_addr >> 2 ];
        // addr <= rd_addr; 
    end

endmodule
