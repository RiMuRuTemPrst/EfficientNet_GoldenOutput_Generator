module Top_Global_Fused(
    input clk,
    input reset_n,
    input [31:0] base_addr_IFM,
    input [31:0] size_IFM,
    input [31:0] base_addr_Weight_layer_1,
    input [31:0] size_Weight_layer_1,
    input [31:0] base_addr_Weight_layer_2,
    input [31:0] size_Weight_layer_2,

    input [31:0] wr_addr_global_initial,
    input [31:0] rd_addr_global_initial,
    input [127:0] data_load_in_global,
    input we_global_initial,
    input start,
    input load_phase
);
    logic [31:0] wr_addr_global_ctl;
    logic [31:0] rd_addr_global_ctl;
    logic we_global_ctl;
    logic [31:0] wr_addr_global;
    logic [31:0] rd_addr_global;
    logic we_global;


    logic [31:0] wr_addr_fused;
    logic [31:0] rd_addr_fused;
    logic [20:0] we_fused;


    
    assign wr_addr_global = load_phase ? wr_addr_global_initial : wr_addr_global_ctl ;
    assign rd_addr_global = load_phase ? rd_addr_global_initial : rd_addr_global_ctl ;
    assign we_global = load_phase ? we_global_initial : we_global_ctl ;
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


    //signal for infor of size
        .base_addr_IFM(base_addr_IFM),
        .size_IFM(size_IFM),
        .base_addr_Weight_layer_1(base_addr_Weight_layer_1),
        .size_Weight_layer_1(size_Weight_layer_1),
        .base_addr_Weight_layer_2(base_addr_Weight_layer_2),
        .size_Weight_layer_2(size_Weight_layer_2)
    );


    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(128),
        .DEPTH(65536)
    )BRAM_Global(
    .clk(clk),
    .wr_rd_en(we_global),                               // Write enable
    .wr_addr(wr_addr_global),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(data_load_in_global),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );

    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_IFM(
    .clk(clk),
    .wr_rd_en(we_fused[20]),                               // Write enable
    .wr_addr(wr_addr_global),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );

    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_0_layer1(
    .clk(clk),
    .wr_rd_en(we_fused[0]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_1_layer_1(
    .clk(clk),
    .wr_rd_en(we_fused[1]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_2_layer_1(
    .clk(clk),
    .wr_rd_en(we_fused[2]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_3_layer_1(
    .clk(clk),
    .wr_rd_en(we_fused[3]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_4_layer_1(
    .clk(clk),
    .wr_rd_en(we_fused[4]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_5_layer_1(
    .clk(clk),
    .wr_rd_en(we_fused[5]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_6_layer_1(
    .clk(clk),
    .wr_rd_en(we_fused[6]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_7_layer_1(
    .clk(clk),
    .wr_rd_en(we_fused[7]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_8_layer_1(
    .clk(clk),
    .wr_rd_en(we_fused[8]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_9_layer_1(
    .clk(clk),
    .wr_rd_en(we_fused[9]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_10_layer_1(
    .clk(clk),
    .wr_rd_en(we_fused[10]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_11_layer_1(
    .clk(clk),
    .wr_rd_en(we_fused[11]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_12_layer_1(
    .clk(clk),
    .wr_rd_en(we_fused[12]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_13_layer_1(
    .clk(clk),
    .wr_rd_en(we_fused[13]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_14_layer_1(
    .clk(clk),
    .wr_rd_en(we_fused[14]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );
    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_15_layer_1(
    .clk(clk),
    .wr_rd_en(we_fused[15]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );

    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_0_layer_2(
    .clk(clk),
    .wr_rd_en(we_fused[16]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );

    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_1_layer_2(
    .clk(clk),
    .wr_rd_en(we_fused[17]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );

    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_2_layer_2(
    .clk(clk),
    .wr_rd_en(we_fused[18]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );

    BRAM_General #(
        .DATA_WIDTH_IN(128),
        .DATA_WIDTH_OUT(32),
        .DEPTH(36)
    )BRAM_Weight_3_layer_2(
    .clk(clk),
    .wr_rd_en(we_fused[19]),                               // Write enable
    .wr_addr(wr_addr_fused),            // Địa chỉ ghi
    .rd_addr(rd_addr_global),  // Địa chỉ đọc (địa chỉ byte → cần dịch)
    .data_in(),               // Dữ liệu vào
    .data_out()               // Dữ liệu ra
    );

    
endmodule