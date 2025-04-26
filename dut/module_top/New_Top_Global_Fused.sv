module New_Top_Global_Fused(
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
     //Write to PE_cluster
    wire [7:0]  OFM_0;
    wire [7:0]  OFM_1;
    wire [7:0]  OFM_2;
    wire [7:0]  OFM_3;
    wire [7:0]  OFM_4;
    wire [7:0]  OFM_5;
    wire [7:0]  OFM_6;
    wire [7:0]  OFM_7;
    wire [7:0]  OFM_8;
    wire [7:0]  OFM_9;
    wire [7:0]  OFM_10;
    wire [7:0]  OFM_11;
    wire [7:0]  OFM_12;
    wire [7:0]  OFM_13;
    wire [7:0]  OFM_14;
    wire [7:0]  OFM_15;
    wire [7:0]  OFM_16;
    logic [31:0] addr_IFM;
    logic [19:0] addr_w;
    logic [31:0] IFM_data;
    logic [31:0] Weight_0;
    logic [31:0] Weight_1;
    logic [31:0] Weight_2;
    logic [31:0] Weight_3;
    logic [31:0] Weight_4;
    logic [31:0] Weight_5;
    logic [31:0] Weight_6;
    logic [31:0] Weight_7;
    logic [31:0] Weight_8;
    logic [31:0] Weight_9;
    logic [31:0] Weight_10;
    logic [31:0] Weight_11;
    logic [31:0] Weight_12;
    logic [31:0] Weight_13;
    logic [31:0] Weight_14;
    logic [31:0] Weight_15; 
    wire [31:0] out_BRAM_CONV;

    wire [15:0] done_window_for_PE_cluster;
    // wire [15:0] finish_for_PE_cluster;
    wire        done_window_one_bit;
    wire        finish_for_PE;
    // wire [7:0] count_for_a_OFM_o;
    
    wire        addr_valid;
    wire [7:0]  tile;
    wire        cal_start_ctl;
    // wire        wr_rd_req_IFM;
    // wire        wr_rd_req_Weight;
    // wire [31:0] wr_addr_Weight;
    // wire [31:0] wr_addr_IFM;

    logic [31:0] base_addr =0;
    logic  [31:0] data_out_global_BRAM;
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
    .data_out(data_out_global_BRAM)               // Dữ liệu ra
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
    .data_in(data_out_global_BRAM),               // Dữ liệu vào
    .data_out(IFM_data)               // Dữ liệu ra
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
    .data_in(data_out_global_BRAM),               // Dữ liệu vào
    .data_out(Weight_0)               // Dữ liệu ra
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

    address_generator addr_gen(
        .clk(clk),
        .rst_n(reset),
        .KERNEL_W(KERNEL_W),
        .OFM_W(OFM_W),
        .OFM_C(OFM_C),
        .IFM_C(IFM_C),
        .IFM_W(IFM_W),
        .stride(stride),
        //.ready(cal_start),
        .ready(cal_start_ctl),
        .addr_in(base_addr),
        .req_addr_out_filter(addr_w),
        .req_addr_out_ifm(addr_IFM),
        .done_compute(done_compute),
        .done_window(done_window_one_bit),
        .finish_for_PE(finish_for_PE),
        .addr_valid_filter(addr_valid),
        .num_of_tiles_for_PE(tile)
    );

    CONV_1x1_controller CONV_1x1_controller_inst(
        .clk(clk),
        .reset_n(reset),
        .valid(wr_data_valid),
        .weight_c(IFM_C_layer2),
        .num_filter(OFM_C_layer2),
        .cal_start(cal_start_ctl),
        .addr_ifm(addr_ram_next_rd),
        .addr_weight(addr_w_n_state),
        .PE_reset(PE_reset_n_state_wire),
        .PE_finish(PE_finish_PE_cluster1x1)
    );

    wire [3:0] PE_reset_n_state_wire;
    PE_cluster_1x1 PE_cluster_1x1(
        .clk(clk),
        .reset_n(reset),
        .PE_reset(PE_reset_n_state_wire),
        .Weight_0(Weight_0_n_state),
        .Weight_1(Weight_1_n_state),
        .Weight_2(Weight_2_n_state),
        .Weight_3(Weight_3_n_state),
        .IFM(out_BRAM_CONV),
        .OFM_0(OFM_0_n_state),
        .OFM_1(OFM_1_n_state),
        .OFM_2(OFM_2_n_state),
        .OFM_3(OFM_3_n_state)
    );
    
    PE_cluster PE_cluster_layer1(
        .clk(clk),
        .reset_n(reset),
        .PE_reset(done_window_for_PE_cluster),
        .PE_finish(PE_finish),
        //.valid(valid),
        .IFM(IFM_data),
        .Weight_0(Weight_0),
        .Weight_1(Weight_1),
        .Weight_2(Weight_2),
        .Weight_3(Weight_3),
        .Weight_4(Weight_4),
        .Weight_5(Weight_5),
        .Weight_6(Weight_6),
        .Weight_7(Weight_7),
        .Weight_8(Weight_8),
        .Weight_9(Weight_9),
        .Weight_10(Weight_10),
        .Weight_11(Weight_11),
        .Weight_12(Weight_12),
        .Weight_13(Weight_13),
        .Weight_14(Weight_14),
        .Weight_15(Weight_15),
        .OFM_0(OFM_0),
        .OFM_1(OFM_1),
        .OFM_2(OFM_2),
        .OFM_3(OFM_3),
        .OFM_4(OFM_4),
        .OFM_5(OFM_5),
        .OFM_6(OFM_6),
        .OFM_7(OFM_7),
        .OFM_8(OFM_8),
        .OFM_9(OFM_9),
        .OFM_10(OFM_10),
        .OFM_11(OFM_11),
        .OFM_12(OFM_12),
        .OFM_13(OFM_13),
        .OFM_14(OFM_14),
        .OFM_15(OFM_15)

    );

endmodule