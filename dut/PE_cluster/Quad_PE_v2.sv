module Quad_PE_v2(
    input  wire        clk,
    input  wire        reset_n,
    // 3 cặp IFM và Weight
    input  wire [7:0]  IFM1, IFM2, IFM3, IFM4,
    input  wire [7:0]  coef_1, coef_2, coef_3, coef_4,
    input  wire mul_en,
    input  wire [7:0]  Weight1, Weight2, Weight3,Weight4,
    // Tín hiệu điều khiển
    input  wire        PE_reset,      
    input  wire        PE_finish, 
    // Output
    output wire [7:0]  OFM,
    output wire        valid
);

    // --- Các wire trung gian ---
    wire [23:0] mul1, mul2, mul3,mul4;   // Kết quả 3 phép nhân
    wire [23:0] add1, add2, add3;        // Kết quả cộng dồn từng bước
    wire [23:0] sum_d;                   // Giá trị tổng mới
    reg  [23:0] sum_q;                   // Thanh ghi lưu giá trị tổng
    reg        valid_r;                 // Thanh ghi xuất cờ valid
    reg  [23:0] mul_sum;

    wire [7:0] c1,c2,c3,c4;

    assign c1 = mul_en? coef_1 : 1;
    assign c2 = mul_en? coef_2 : 1;
    assign c3 = mul_en? coef_3 : 1;
    assign c4 = mul_en? coef_4 : 1;

    // Nhân 3 cặp IFM*Weight
    assign mul1 = IFM1 * Weight1 * c1;
    assign mul2 = IFM2 * Weight2 * c2;
    assign mul3 = IFM3 * Weight3 * c3;
    assign mul4 = IFM4 * Weight4 * c4;

    assign add1 = mul1 + mul2;
    assign add2 = mul4 + mul3;
    assign add3 = add1 + add2;


    assign sum_d = add3 + mul_sum;

    always@(posedge clk or negedge reset_n) begin
        if(~reset_n) begin
            sum_q <= 0;
        end
        else begin
            sum_q <= sum_d; 
        end
    end
    assign mul_sum = (PE_reset) ? 0 : sum_q ;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            valid_r <= 1'b0;
        end else if (PE_finish) begin
            valid_r <= 1'b1;
        end else begin
            valid_r <= 1'b0;
        end
    end

    // Gán các ngõ ra
    assign OFM   = sum_q[7:0];
    assign valid = valid_r;

endmodule