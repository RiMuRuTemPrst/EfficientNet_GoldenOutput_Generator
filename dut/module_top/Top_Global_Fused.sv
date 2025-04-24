module Top_Global_Fused(
    input clk,
    input reset_n,
    input [31:0] base_addr_IFM,
    input [31:0] size_IFM,
    input [31:0] base_addr_Weight_layer_1,
    input [31:0] size_Weight_layer_1,
    input [31:0] base_addr_Weight_layer_2,
    input [31:0] size_Weight_layer_2

    input [31:0] wr_addr_global_intial;
    input [31:0] rd_addr_global_intial;
    input we_global_initial;
    input load_phase;
);
    logic [31:0] wr_addr_global_ctl;
    logic [31:0] rd_addr_global_ctl;
    logic we_global_ctl;
    logic [31:0] wr_addr_global;
    logic [31:0] rd_addr_global;
    logic we_global;


    logic [31:0] wr_addr_fused;
    logic [31:0] rd_addr_fused;
    logic we_fused;
    logic[1:0] control_load;
    logic [31:0] wr_addr_Weight_layer_1;

    //signal load we and addr layer
    logic [31:0] wr_addr_Weight_0_layer2,
    logic [31:0] wr_addr_Weight_1_layer2,
    logic [31:0] wr_addr_Weight_2_layer2,
    logic [31:0] wr_addr_Weight_3_layer2,

    //we
    logic [31:0] we_Weight_0_layer1,
    logic [31:0] we_Weight_1_layer1,
    logic [31:0] we_Weight_2_layer1,
    logic [31:0] we_Weight_3_layer1,
    logic [31:0] we_Weight_4_layer1,
    logic [31:0] we_Weight_5_layer1,
    logic [31:0] we_Weight_6_layer1,
    logic [31:0] we_Weight_7_layer1,
    logic [31:0] we_Weight_8_layer1,
    logic [31:0] we_Weight_9_layer1,
    logic [31:0] we_Weight_10_layer1,
    logic [31:0] we_Weight_11_layer1,
    logic [31:0] we_Weight_12_layer1,
    logic [31:0] we_Weight_13_layer1,
    logic [31:0] we_Weight_14_layer1,
    logic [31:0] we_Weight_15_layer1

    logic [31:0] we_Weight_0_layer2,
    logic [31:0] we_Weight_1_layer2,
    logic [31:0] we_Weight_2_layer2,
    logic [31:0] we_Weight_3_layer2,

    assign wr_addr_Weight_layer_1 = wr_addr_fused >> 4;

    Rounter_load_data rounter_load(

    .wr_addr_fused(wr_addr_fused),
    .we_fused(we_fused),
    .control_load(control_load),

    //input for rount
    .size_IFM(size_IFM),
    .size_Weight_layer_1(size_Weight_layer_1),
    .size_Weight_layer_2(size_Weight_layer_2),
    //output to BRAM_IFM and BRAM_Weight
    //Weight
    //write address
    .wr_addr_Weight_0_layer2(wr_addr_Weight_0_layer2),
    .wr_addr_Weight_1_layer2(wr_addr_Weight_1_layer2),
    .wr_addr_Weight_2_layer2(wr_addr_Weight_2_layer2),
    .wr_addr_Weight_3_layer2(wr_addr_Weight_3_layer2),

    //we
    .we_Weight_0_layer1(we_Weight_0_layer1),
    .we_Weight_1_layer1(we_Weight_1_layer1),
    .we_Weight_2_layer1(we_Weight_2_layer1),
    .we_Weight_3_layer1(we_Weight_3_layer1),
    .we_Weight_4_layer1(we_Weight_4_layer1),
    .we_Weight_5_layer1(we_Weight_5_layer1),
    .we_Weight_6_layer1(we_Weight_6_layer1),
    .we_Weight_7_layer1(we_Weight_7_layer1),
    .we_Weight_8_layer1(we_Weight_8_layer1),
    .we_Weight_9_layer1(we_Weight_9_layer1),
    .we_Weight_10_layer1(we_Weight_10_layer1),
    .we_Weight_11_layer1(we_Weight_11_layer1),
    .we_Weight_12_layer1(we_Weight_12_layer1),
    .we_Weight_13_layer1(we_Weight_13_layer1),
    .we_Weight_14_layer1(we_Weight_14_layer1),
    .we_Weight_15_layer1(we_Weight_15_layer1)

    .we_Weight_0_layer2(we_Weight_0_layer2),
    .we_Weight_1_layer2(we_Weight_1_layer2),
    .we_Weight_2_layer2(we_Weight_2_layer2),
    .we_Weight_3_layer2(we_Weight_3_layer2)
);

    assign wr_addr_global = load_phase ? wr_addr_global_intial : wr_addr_global_ctl ;
    assign rd_addr_global = load_phase ? rd_addr_global_intial : rd_addr_global_ctl ;
    assign we_global = load_phase ? we_global_intial : we_global_ctl ;
    Global_top_fused_control_unit Global_control_unit(
        .clk(clk),
        .reset_n(reset_n),
        .start(start),
        .ready(ready),

    // Global BRAM signal
        .wr_addr_global(wr_addr_global_ctl),
        .rd_addr_global(wr_addr_global_ctl),
        .we_global(wr_addr_global_ctl),

    // Load BRAM signal
        .wr_addr_fused(wr_addr_fused),
        .rd_addr_fused(rd_addr_fused),
        .we_fused(we_fused),

    //control signal
        .control_load(control_load),

    //signal for infor of size
        .base_addr_IFM(base_addr_IFM),
        .size_IFM(size_IFM),
        .base_addr_Weight_layer_1(base_addr_Weight_layer_1),
        .size_Weight_layer_1(size_Weight_layer_1),
        .base_addr_Weight_layer_2(base_addr_Weight_layer_2),
        .size_Weight_layer_2(size_Weight_layer_2)
    );


    BRAM_General BRAM_Global#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(128),
        .DEPTH(65536)
    )(
    .clk(clk),
    .wr_rd_en(we_global),                               // Write enable
    .wr_addr(wr_addr_global),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );

    BRAM_General BRAM_IFM#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_global),                               // Write enable
    .wr_addr(wr_addr_global),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );

    BRAM_General BRAM_Weight_0_layer1#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_0_layer1),                               // Write enable
    .wr_addr(wr_addr_Weight_layer_1),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General BRAM_Weight_1_layer_1#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_1_layer1),                               // Write enable
    .wr_addr(wr_addr_Weight_layer_1),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General BRAM_Weight_2_layer_1#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_2_layer1),                               // Write enable
    .wr_addr(wr_addr_Weight_layer_1),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General BRAM_Weight_3_layer_1#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_3_layer1),                               // Write enable
    .wr_addr(wr_addr_Weight_layer_1),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General BRAM_Weight_4_layer_1#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_4_layer1),                               // Write enable
    .wr_addr(wr_addr_Weight_layer_1),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General BRAM_Weight_5_layer_1#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_5_layer1),                               // Write enable
    .wr_addr(wr_addr_Weight_layer_1),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General BRAM_Weight_6_layer_1#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_6_layer1),                               // Write enable
    .wr_addr(wr_addr_Weight_layer_1),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General BRAM_Weight_7_layer_1#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_7_layer1),                               // Write enable
    .wr_addr(wr_addr_Weight_layer_1),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General BRAM_Weight_8_layer_1#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_8_layer1),                               // Write enable
    .wr_addr(wr_addr_Weight_layer_1),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General BRAM_Weight_9_layer_1#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_9_layer1),                               // Write enable
    .wr_addr(wr_addr_Weight_layer_1),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General BRAM_Weight_10_layer_1#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_10_layer1),                               // Write enable
    .wr_addr(wr_addr_Weight_layer_1),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General BRAM_Weight_11_layer_1#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_11_layer1),                               // Write enable
    .wr_addr(wr_addr_Weight_layer_1),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General BRAM_Weight_12_layer_1#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_12_layer1),                               // Write enable
    .wr_addr(wr_addr_Weight_layer_1),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General BRAM_Weight_13_layer_1#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_13_layer1),                               // Write enable
    .wr_addr(wr_addr_Weight_layer_1),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General BRAM_Weight_14_layer_1#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_14_layer1),                               // Write enable
    .wr_addr(wr_addr_Weight_layer_1),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General BRAM_Weight_15_layer_1#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_15_layer1),                               // Write enable
    .wr_addr(wr_addr_Weight_layer_1),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );

    BRAM_General BRAM_Weight_0_layer_2#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_0_layer2),                               // Write enable
    .wr_addr(wr_addr_Weight_0_layer2),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );

    BRAM_General BRAM_Weight_1_layer_2#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_1_layer2),                               // Write enable
    .wr_addr(wr_addr_Weight_1_layer2),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );

    BRAM_General BRAM_Weight_2_layer_2#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_2_layer2),                               // Write enable
    .wr_addr(wr_addr_Weight_2_layer2),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );

    BRAM_General BRAM_Weight_3_layer_2#(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )(
    .clk(clk),
    .wr_rd_en(we_Weight_3_layer2),                               // Write enable
    .wr_addr(wr_addr_Weight_3_layer2),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );

    
endmodule