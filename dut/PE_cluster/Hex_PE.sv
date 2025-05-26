module Hex_PE(
    input  wire        clk,
    input  wire        reset_n,
    // 3 cặp IFM và Weight
    input  wire [7:0]  IFM1, IFM2, IFM3, IFM4, IFM5, IFM6, IFM7, IFM8 ,IFM9, IFM10, IFM11, IFM12 ,IFM13, IFM14, IFM15, IFM15,
    input  wire [7:0]  Weight1, Weight2, Weight3, Weight4, Weight5, Weight6, Weight7 ,Weight8, Weight9, Weight10, Weight11, Weight12 ,Weight13, Weight14, Weight15, Weight16,
    // Tín hiệu điều khiển
    input  wire        PE_reset,      
    input  wire        PE_finish, 
    // Output
    output wire [7:0]  OFM,
    output wire        valid
);

    // --- Các wire trung gian ---
    wire [16:0] mul1, mul2, mul3, mul4, mul5, mul6, mul7, mul8, mul9, mul10, mul11, mul12, mul13, mul14, mul15, mul16;   // Kết quả 3 phép nhân
    wire [16:0] add1, add2, add3, add4, add5, add6, add7, add8, add9, add10, add11, add12, add13, add14, add15;        // Kết quả cộng dồn từng bước
    wire [16:0] sum_d;                   // Giá trị tổng mới
    reg  [7:0] sum_q;                   // Thanh ghi lưu giá trị tổng
    reg        valid_r;                 // Thanh ghi xuất cờ valid
    reg  [7:0] mul_sum;

    // Nhân 3 cặp IFM*Weight
    assign mul1 = IFM1 * Weight1;
    assign mul2 = IFM2 * Weight2;
    assign mul3 = IFM3 * Weight3;
    assign mul4 = IFM4 * Weight4;
    assign mul5 = IFM5 * Weight5;
    assign mul6 = IFM6 * Weight6;
    assign mul7 = IFM7 * Weight7;
    assign mul8 = IFM8 * Weight8;
    assign mul9 = IFM9 * Weight9;
    assign mul10 = IFM10 * Weight10;
    assign mul11 = IFM11 * Weight11;
    assign mul12 = IFM12 * Weight12;
    assign mul13 = IFM13 * Weight13;
    assign mul14 = IFM14 * Weight14;
    assign mul15 = IFM15 * Weight15;
    assign mul16 = IFM16 * Weight16;
    always_ff @(posedge clk or negedge reset_n) begin
        if(~reset) begin
            add1 <= 0;
            add2 <= 0;
            add3 <= 0;
            add4 <= 0;
            add5 <= 0;
            add6 <= 0;
            add7 <= 0;
            add8 <= 0;
            add9 <= 0;
            add10 <= 0;
            add11 <= 0;
            add12 <= 0;
            add13 <= 0;
            add14 <= 0;
            add15 <= 0;
            add16 <= 0;
        end
        else begin
            add1 <= mul1 + mul2;

            add2 <= mul4 + mul3;

            add3 <= mul5 + mul6;

            add4 <= mul7 + mul8;

            add5 <= mul9 + mul10;

            add6 <= mul11 + mul12;

            add7 <= mul13 + mul14;

            add8 <= mul15 + mul16;

            add9 <= add1 + add2;

            add10 <= add3 + add4;

            add11 <= add5 + add6;

            add12 <= add7 + add8;

            add13 <= add9 + add10;

            add14 <= add11 + add12;

            add15 <= add13 + add14;
        end
    end


    assign sum_d = add15 + mul_sum;

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
    assign OFM   = sum_q;
    assign valid = valid_r;

endmodule