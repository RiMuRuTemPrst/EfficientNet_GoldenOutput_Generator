module Mutiple_4x4(
    // 3 cặp IFM và Weight
    input  wire [7:0]  input_x1, input_x2, input_x3, input_x4,
    input  wire [7:0]  input_y1, input_y2, input_y3, input_y4,
    // Output
    output wire [7:0]  OFM_1, OFM_2, OFM_3, OFM_4
);
    assign OFM_1 = input_x1 * input_y1;
    assign OFM_2 = input_x2 * input_y2;
    assign OFM_3 = input_x3 * input_y3;
    assign OFM_4 = input_x4 * input_y4;
endmodule