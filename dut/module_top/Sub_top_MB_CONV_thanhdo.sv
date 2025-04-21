module Sub_top_MB_CONV_thanhdo(
    input clk,
    input rst_n,
    
    input cal_start,
    input wr_rd_en_IFM,
    input [31:0] data_in_IFM,


    input [31:0] data_in_Weight_0,
    input [31:0] data_in_Weight_1,
    input [31:0] data_in_Weight_2,
    input [31:0] data_in_Weight_3,
    input [31:0] data_in_Weight_4,
    input [31:0] data_in_Weight_5,
    input [31:0] data_in_Weight_6,
    input [31:0] data_in_Weight_7,
    input [31:0] data_in_Weight_8,
    input [31:0] data_in_Weight_9,
    input [31:0] data_in_Weight_10,
    input [31:0] data_in_Weight_11,
    input [31:0] data_in_Weight_12,
    input [31:0] data_in_Weight_13,
    input [31:0] data_in_Weight_14,
    input [31:0] data_in_Weight_15,

    input [31:0] addr_Wei_layer2,
    input wr_rd_en_Weight_layer2,
    input [31:0] data_in_Weight_0_n_state,  // layer 2
    input [31:0] data_in_Weight_1_n_state,  // layer 2
    input [31:0] data_in_Weight_2_n_state,  // layer 2
    input [31:0] data_in_Weight_3_n_state,  // layer 2
    //input wr_en_next,                     // controll  layer1_2

    input [31:0] addr_Wei_layer_reduce,
    input wr_rd_en_Weight_layer_reduce,
    input [31:0] data_in_Weight_0_reduce,  // layer reduce
    input [31:0] data_in_Weight_1_reduce,  // layer reduce
    input [31:0] data_in_Weight_2_reduce,  // layer reduce
    input [31:0] data_in_Weight_3_reduce,  // layer reduce

    input [31:0] addr_Wei_layer_expand,
    input wr_rd_en_Weight_layer_expand,
    input [31:0] data_in_Weight_0_expand,  // layer expand
    input [31:0] data_in_Weight_1_expand,  // layer expand
    input [31:0] data_in_Weight_2_expand,  // layer expand
    input [31:0] data_in_Weight_3_expand,  // layer expand

    //next state pipeline
    //input [31:0] addr_ram_next_rd,
    input [31:0] addr_ram_next_wr,
    input [3:0] PE_reset_n_state,
    //input [31:0] addr_w_n_state,
    output [7:0] OFM_0_DW_layer,
    output [7:0] OFM_1_DW_layer,
    output [7:0] OFM_2_DW_layer,
    output [7:0] OFM_3_DW_layer,

    output [7:0] OFM_0_SE_layer,
    output [7:0] OFM_1_SE_layer,
    output [7:0] OFM_2_SE_layer,
    output [7:0] OFM_3_SE_layer,
    

    //control signal layer 1
    input wire [15:0] PE_reset,
    input wire [15:0] PE_finish,
    //control singal layer 2
    output wire [3:0] PE_finish_PE_cluster1x1,

    input  wire [3:0] KERNEL_W_layer1,
    input  wire [7:0] OFM_W_layer1,
    input  wire [7:0] OFM_C_layer1,
    input  wire [7:0] IFM_C_layer1,
    input  wire [7:0] IFM_W_layer1,
    input  wire [1:0] stride_layer1,

    input  wire [3:0] KERNEL_W_layer2,
    input  wire [7:0] IFM_C_layer2,
    input  wire [7:0] OFM_C_layer2,

    input  wire [7:0] OFM_C_se_reduce,
    input       [31:0]  count_init_for_pooling,
    
    input  wire [1:0] stride_layer2,
    output wire [15:0] valid,
    output wire        valid_layer2,
    output wire        valid_layer_reduce,
    //output wire [15:0] done_window,
    output wire        done_compute,
    


    // for Control_unit
    input  wire        run,
    input  wire [3:0]  instrution,
    output wire        wr_rd_req_IFM_for_tb,
    output wire [31:0] wr_addr_IFM_for_tb,
    output wire        wr_rd_req_Weight_for_tb,
    output wire [31:0] wr_addr_Weight_for_tb,
    output wire [7:0]  OFM_0,
    output wire [7:0]  OFM_1,
    output wire [7:0]  OFM_2,
    output wire [7:0]  OFM_3,
    output wire [7:0]  OFM_4,
    output wire [7:0]  OFM_5,
    output wire [7:0]  OFM_6,
    output wire [7:0]  OFM_7,
    output wire [7:0]  OFM_8,
    output wire [7:0]  OFM_9,
    output wire [7:0]  OFM_10,
    output wire [7:0]  OFM_11,
    output wire [7:0]  OFM_12,
    output wire [7:0]  OFM_13,
    output wire [7:0]  OFM_14,
    output wire [7:0]  OFM_15,
    output wire [7:0]  OFM_16,
    input write_padding ,


    // layer 2 signal 
    input wr_rd_req_IFM_layer_2,
    output [31:0] IFM_data_layer_2,
    input [31:0] addr_IFM_layer_2,
    input valid_for_next_pipeline,
    input [31:0] wr_addr_IFM_layer_2,
    output       done_compute_layer2,

    //signal for pooling average
    input [31:0] read_addr_pooling_tb,
    input [31:0] write_addr_pooling,
    input init_phase_pooling,
    input [1:0] control_data_pooling,
    input we_pooling,
    output [63:0] data_pooling_average
);

    //wire for Weight connect to PE_1x1 from BRAM
    logic [31:0] Weight_0_n_state;
    logic [31:0] Weight_1_n_state;
    logic [31:0] Weight_2_n_state;
    logic [31:0] Weight_3_n_state;
    logic [31:0] addr_ram_next_rd;
    logic [31:0] addr_w_n_state;


    // wire for weight data from Bram to PE_SE reduce
    logic [31:0] Weight_0_reduce;
    logic [31:0] Weight_1_reduce;
    logic [31:0] Weight_2_reduce;
    logic [31:0] Weight_3_reduce;

    // wire for weight data from Bram to PE_SE expand
    logic [31:0] Weight_0_expand;
    logic [31:0] Weight_1_expand;
    logic [31:0] Weight_2_expand;
    logic [31:0] Weight_3_expand;

    //wire to PE_cluster

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
    // wire data_mux and register for pipeline
    wire [31:0] data_out_mux;
    wire [7:0]  OFM_n_CONV_0;
    wire [7:0]  OFM_n_CONV_1;
    wire [7:0]  OFM_n_CONV_2;
    wire [7:0]  OFM_n_CONV_3;
    wire [7:0]  OFM_n_CONV_4;
    wire [7:0]  OFM_n_CONV_5;
    wire [7:0]  OFM_n_CONV_6;
    wire [7:0]  OFM_n_CONV_7;
    wire [7:0]  OFM_n_CONV_8;
    wire [7:0]  OFM_n_CONV_9;
    wire [7:0]  OFM_n_CONV_10;
    wire [7:0]  OFM_n_CONV_11;
    wire [7:0]  OFM_n_CONV_12;
    wire [7:0]  OFM_n_CONV_13;
    wire [7:0]  OFM_n_CONV_14;
    wire [7:0]  OFM_n_CONV_15;

    // wire [7:0]  OFM_active_0;
    // wire [7:0]  OFM_active_1;
    // wire [7:0]  OFM_active_2;
    // wire [7:0]  OFM_active_3;
    // wire [7:0]  OFM_active_4;
    // wire [7:0]  OFM_active_5;
    // wire [7:0]  OFM_active_6;
    // wire [7:0]  OFM_active_7;
    // wire [7:0]  OFM_active_8;
    // wire [7:0]  OFM_active_9;
    // wire [7:0]  OFM_active_10;
    // wire [7:0]  OFM_active_11;
    // wire [7:0]  OFM_active_12;
    // wire [7:0]  OFM_active_13;
    // wire [7:0]  OFM_active_14;
    // wire [7:0]  OFM_active_15;


    wire [15:0] done_window_for_PE_cluster;
    wire [15:0] finish_for_PE_cluster_layer1;
    wire        finish_for_PE_cluster_layer2;
    wire        done_window_one_bit;
    wire        finish_for_PE;
    wire [7:0] count_for_a_OFM_o;
    
    wire        addr_valid;
    wire [7:0]  tile;
    wire        cal_start_ctl;
    wire        wr_rd_req_IFM;
    wire        wr_rd_req_Weight;
    wire [31:0] wr_addr_Weight;
    wire [31:0] wr_addr_IFM;

    logic [31:0] base_addr =0;


    // signal for layer 2
    logic [127:0] data_in_IFM_layer_2;
    wire finish_for_PE_DW_cluster;

    //signal_for_average_Pooling
    logic [31:0] data_in_pooling;
    Control_unit Control_unit(
        .clk(clk),
        .rst_n(rst_n),
        .run(run),
        .instrution(instrution),
        .KERNEL_W(KERNEL_W_layer1),
        .OFM_W(OFM_W_layer1),
        .OFM_C(OFM_C_layer1),
        .IFM_C(IFM_C_layer1),
        .IFM_W(IFM_W_layer1),
        .stride(stride_layer1),
        .addr_valid(addr_valid),
        .done_compute(done_compute),
        .tile(tile),
        //out
        .cal_start(cal_start_ctl),
        .wr_rd_req_IFM(wr_rd_req_IFM),
        .wr_addr_IFM(wr_addr_IFM),
        .wr_rd_req_Weight(wr_rd_req_Weight),
        .wr_addr_Weight(wr_addr_Weight),
        .base_addr(),
        .current_state_o()
    );

    assign wr_rd_req_IFM_for_tb = wr_rd_req_IFM;
    assign wr_addr_IFM_for_tb   = wr_addr_IFM;
    assign wr_rd_req_Weight_for_tb = wr_rd_req_Weight;
    assign wr_addr_Weight_for_tb   = wr_addr_Weight;

    BRAM_IFM IFM_BRAM(
        .clk(clk),
        .rd_addr(addr_IFM),
        .wr_addr(wr_addr_IFM),
        //.wr_rd_en(wr_rd_en_IFM),
        .wr_rd_en(wr_rd_req_IFM),
        .data_in(data_in_IFM),
        .data_out(IFM_data)
    );
    BRAM BRam_Weight_0_layer1(
        .clk(clk),
        .rd_addr(addr_w),
        .wr_addr(wr_addr_Weight),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_0),
        .data_out(Weight_0)
    );
    BRAM BRam_Weight_1_layer1(
        .clk(clk),
        .rd_addr(addr_w),
        .wr_addr(wr_addr_Weight),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_1),
        .data_out(Weight_1)
    );
    BRAM BRam_Weight_2_layer1(
        .clk(clk),
        .rd_addr(addr_w),
        .wr_addr(wr_addr_Weight),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_2),
        .data_out(Weight_2)
    );
    BRAM BRam_Weight_3_layer1(
        .clk(clk),
        .rd_addr(addr_w),
        .wr_addr(wr_addr_Weight),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_3),
        .data_out(Weight_3)
    );
    BRAM BRam_Weight_4_layer1(
        .clk(clk),
        .rd_addr(addr_w),
        .wr_addr(wr_addr_Weight),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_4),
        .data_out(Weight_4)
    );
    BRAM BRam_Weight_5_layer1(
        .clk(clk),
        .rd_addr(addr_w),
        .wr_addr(wr_addr_Weight),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_5),
        .data_out(Weight_5)
    );
    BRAM BRam_Weight_6_layer1(
        .clk(clk),
        .rd_addr(addr_w),
        .wr_addr(wr_addr_Weight),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_6),
        .data_out(Weight_6)
    );
    BRAM BRam_Weight_7_layer1(
        .clk(clk),
        .rd_addr(addr_w),
        .wr_addr(wr_addr_Weight),
        //.wr_rd_en(wr_rd_en_Weight),
.wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_7),
        .data_out(Weight_7)
    );
    BRAM BRam_Weight_8_layer1(
        .clk(clk),
        .rd_addr(addr_w),
        .wr_addr(wr_addr_Weight),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_8),
        .data_out(Weight_8)
    );
    BRAM BRam_Weight_9_layer1(
        .clk(clk),
        .rd_addr(addr_w),
        .wr_addr(wr_addr_Weight),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_9),
        .data_out(Weight_9)
    );
    BRAM BRam_Weight_10_layer1(
        .clk(clk),
        .rd_addr(addr_w),
        .wr_addr(wr_addr_Weight),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_10),
        .data_out(Weight_10)
    );
    BRAM BRam_Weight_11_layer1(
        .clk(clk),
        .rd_addr(addr_w),
        .wr_addr(wr_addr_Weight),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_11),
        .data_out(Weight_11)
    );
    BRAM BRam_Weight_12_layer1(
        .clk(clk),
        .rd_addr(addr_w),
        .wr_addr(wr_addr_Weight),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_12),
        .data_out(Weight_12)
    );
    BRAM BRam_Weight_13_layer1(
        .clk(clk),
        .rd_addr(addr_w),
        .wr_addr(wr_addr_Weight),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_13),
        .data_out(Weight_13)
    );
    BRAM BRam_Weight_14_layer1(
        .clk(clk),
        .rd_addr(addr_w),
        .wr_addr(wr_addr_Weight),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_14),
        .data_out(Weight_14)
    );
    BRAM BRam_Weight_15_layer1(
        .clk(clk),
        .rd_addr(addr_w),
        .wr_addr(wr_addr_Weight),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_15),
        .data_out(Weight_15)
    );
    
    PE_cluster PE_cluster_layer1(
        .clk(clk),
        .reset_n(rst_n),
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
    assign data_in_IFM_layer_2 = write_padding ? {OFM_15,OFM_14,OFM_13,OFM_12,OFM_11,OFM_10,OFM_9,OFM_8,OFM_7,OFM_6,OFM_5,OFM_4,OFM_3,OFM_2,OFM_1,OFM_0} : 0;
    
    address_generator addr_gen(
        .clk(clk),
        .rst_n(rst_n),
        .KERNEL_W(KERNEL_W_layer1),
        .OFM_W(OFM_W_layer1),
        .OFM_C(OFM_C_layer1),
        .IFM_C(IFM_C_layer1),
        .IFM_W(IFM_W_layer1),
        .stride(stride_layer1),
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

    
    assign done_window_for_PE_cluster       =   {16{done_window_one_bit}};
    assign finish_for_PE_cluster_layer1            =   (cal_start_ctl) && ( addr_IFM != 'b0 )   ? {16{finish_for_PE}} : 16'b0;
    assign valid                            =   finish_for_PE_cluster_layer1;


    wire [31:0] req_addr_out_ifm_layer2;
    wire [31:0] req_addr_out_filter_layer2;
    
    wire finish_for_PE_layer2;
    wire addr_valid_ifm_layer2;
    wire done_window_layer2;
    wire addr_valid_filter_layer2;
    wire [7:0] num_of_tiles_for_PE_layer2;
    wire [7:0] OFM_W_layer2 ;
    wire valid_for_next_pipeline_from_control_padding;
    assign OFM_W_layer2 =( OFM_W_layer1 +2*1 - KERNEL_W_layer2 )/ stride_layer2 +1;
    address_generator_dw #(
        .TOTAL_PE(4),
        .DATA_WIDTH(32)
    ) address_generator_dw_inst (
        .clk(clk),
        .rst_n(rst_n),
        .KERNEL_W(KERNEL_W_layer2),
        .OFM_W(OFM_W_layer2),
        .OFM_C(OFM_C_layer2),
        .IFM_C(IFM_C_layer2),
        .IFM_W(OFM_W_layer1+2),
        .stride(stride_layer2),
        //.ready(valid_for_next_pipeline),
        .ready(valid_for_next_pipeline_from_control_padding),
        .addr_in(0),
        .req_addr_out_ifm(req_addr_out_ifm_layer2),
        .req_addr_out_filter(req_addr_out_filter_layer2),
        .done_compute(done_compute_layer2),
        .finish_for_PE(finish_for_PE_layer2),
        .addr_valid_ifm(addr_valid_ifm_layer2),
        .done_window(done_window_layer2),
        .addr_valid_filter(addr_valid_filter_layer2),
        .num_of_tiles_for_PE(num_of_tiles_for_PE_layer2)
    );
    assign finish_for_PE_cluster_layer2 = (1) && (req_addr_out_ifm_layer2!= 'b0)  ? finish_for_PE_layer2 : 1'b0;

    assign valid_layer2 =finish_for_PE_cluster_layer2;

    wire wr_en_from_control_padding;
    wire [31:0] wr_addr_from_control_padding;
    wire [16*8-1:0] IFM_data_layer_2_from_control_padding;

    control_padding #( 
        .PE()
    ) control_padding_inst (
        .clk(clk),
        .rst_n(rst_n),
        .valid(valid),
        .start(cal_start_ctl),
        .data_in({OFM_15,OFM_14,OFM_13,OFM_12,OFM_11,OFM_10,OFM_9,OFM_8,OFM_7,OFM_6,OFM_5,OFM_4,OFM_3,OFM_2,OFM_1,OFM_0}),
        .OFM_C(OFM_C_layer1),
        .OFM_W(OFM_W_layer1),
        .padding(1),
        .wr_en(wr_en_from_control_padding),
        .addr_next(wr_addr_from_control_padding),
        .data_out(IFM_data_layer_2_from_control_padding),
        .valid_for_next_pipeline(valid_for_next_pipeline_from_control_padding)

    );

    BRAM_IFM_128bit_in IFM_BRAM_layer_2(
        .clk(clk),
        //.rd_addr(addr_IFM_layer_2),
        .rd_addr(req_addr_out_ifm_layer2),
        //.wr_addr(wr_addr_IFM_layer_2),
        .wr_addr( wr_addr_from_control_padding ),
        //.wr_rd_en(wr_rd_en_IFM),
        //.wr_rd_en(wr_rd_req_IFM_layer_2),
        .wr_rd_en(wr_en_from_control_padding),
        //.data_in(data_in_IFM_layer_2),
        .data_in( IFM_data_layer_2_from_control_padding ),
        .data_out(IFM_data_layer_2)
    );

    BRAM #(
    .DATA_WIDTH(8),
    .off_set_shift(0)
    )BRam_Weight_0_DW(
        .clk(clk),
        .rd_addr(req_addr_out_filter_layer2),
        .wr_addr(addr_Wei_layer2),
        .wr_rd_en(wr_rd_en_Weight_layer2),
        //.wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_0_n_state),
        .data_out(Weight_0_n_state)
    );
    BRAM #(
        .DATA_WIDTH(8),
        .off_set_shift(0)
    )BRam_Weight_1_DW(
        .clk(clk),
        .rd_addr(req_addr_out_filter_layer2),
        .wr_addr(addr_Wei_layer2),
        .wr_rd_en(wr_rd_en_Weight_layer2),
        //.wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_1_n_state),
        .data_out(Weight_1_n_state)
    );
    BRAM #(
        .DATA_WIDTH(8),
        .off_set_shift(0)
    )BRam_Weight_2_DW(
        .clk(clk),
        .rd_addr(req_addr_out_filter_layer2),
        .wr_addr(addr_Wei_layer2),
        .wr_rd_en(wr_rd_en_Weight_layer2),
        //.wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_2_n_state),
        .data_out(Weight_2_n_state)
    );
    BRAM #(
        .DATA_WIDTH(8),
        .off_set_shift(0)
    )BRam_Weight_3_DW(
        .clk(clk),
        .rd_addr(req_addr_out_filter_layer2),
        .wr_addr(addr_Wei_layer2),
        .wr_rd_en(wr_rd_en_Weight_layer2),
        //.wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_3_n_state),
        .data_out(Weight_3_n_state)
    );


    PE_DW_cluster PE_DW(
        .clk(clk),
        .reset_n(rst_n),
        .Weight_0(Weight_0_n_state),
        .Weight_1(Weight_1_n_state),
        .Weight_2(Weight_2_n_state),
        .Weight_3(Weight_3_n_state),
        .IFM(IFM_data_layer_2),
        .PE_reset(done_window_layer2),
        .PE_finish(),
        .OFM_0(OFM_0_DW_layer),
        .OFM_1(OFM_1_DW_layer),
        .OFM_2(OFM_2_DW_layer),
        .OFM_3(OFM_3_DW_layer),
        .valid(valid_of_DW)
    );


    wire se_layer;
    reg [7:0] IFM_C_se;
    reg [7:0] OFM_C_se;
    wire       done_window_for_SE;
    wire [31:0] req_addr_out_ifm_layerSE;
    wire [31:0] req_addr_out_filter_layerSE;
    wire        finish_for_PE_SE_cluster;
    wire        done_compute_SE;
    reg done_compute_pooling;

    assign data_in_pooling = {OFM_3_DW_layer,OFM_2_DW_layer,OFM_1_DW_layer,OFM_0_DW_layer}  ;



//----------------------------------------------------_FSM_FOR_POOLING------------------------------------//

    reg excute_average ;
    reg [31:0] read_addr_pooling ;
    // assign read_addr_pooling = excute_average ? read_addr_pooling_tb: read_addr_pooling_tb  ; /// for test poolinng block
    assign read_addr_pooling = excute_average ? read_addr_pooling_tb: req_addr_out_ifm_layerSE  ;

    parameter POOLING_IDLE      = 1'b0;
    parameter POOLING_EXCUTE    = 1'b1;
    reg current_state_POOLING , next_state_POOLING ;
    //-------------------------------------------------POOLING---------------------------------------------------------//
    // FSM State Register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state_POOLING <= POOLING_IDLE;
        else
            current_state_POOLING <= next_state_POOLING;
    end
    always @(*) begin
    case (current_state_POOLING)

        POOLING_IDLE: begin
            if ( valid_layer2 ) begin
                next_state_POOLING =    POOLING_EXCUTE ;
            end else begin
                next_state_POOLING =    POOLING_IDLE;
                
            end
        end

        POOLING_EXCUTE: begin
            if ( done_compute_pooling ) begin
                next_state_POOLING =    POOLING_IDLE ;
            end else begin
                next_state_POOLING =    POOLING_EXCUTE;
                
            end
        end
        
        default: begin
            next_state_POOLING  = POOLING_IDLE;
        end

    endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            excute_average <= 0;
        end else begin
            case (next_state_POOLING)
                POOLING_IDLE: begin
                    excute_average<=0;
                end

                POOLING_EXCUTE: begin
                    excute_average<=1;
                end
                                  
                default: begin
                    
                end
            endcase
        end
    end

    // assign se_layer =0;

    // assign IFM_C_se = se_layer ? OFM_C_se_reduce : OFM_C_layer2;

    // assign OFM_C_se = se_layer ? OFM_C_layer2 : OFM_C_se_reduce;

//----------------------------------------------------_FSM_FOR_REDUCE_EXPAND------------------------------------//

    parameter REDUCE_CONV      = 1'b0;
    parameter EXPAND_CONV    = 1'b1;
    reg current_state_SE_layer , next_state_SE_layer ;
    wire [31:0] req_addr_out_ifm_layerSE_for_IFM_BRAM ;
    wire ready_addr_gen_SE ;

    //-------------------------------------------------POOLING---------------------------------------------------------//
    // FSM State Register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state_SE_layer <= REDUCE_CONV;
        else
            current_state_SE_layer <= next_state_SE_layer;
    end
    always @(*) begin
        case (current_state_SE_layer)

            REDUCE_CONV: begin
                if ( done_compute_SE ) begin
                    next_state_SE_layer =    EXPAND_CONV ;
                end else begin
                    next_state_SE_layer =    REDUCE_CONV;
                    
                end
            end

            EXPAND_CONV: begin
                if ( done_compute_SE ) begin
                    next_state_SE_layer =    REDUCE_CONV ;
                end else begin
                    next_state_SE_layer =    EXPAND_CONV;
                    
                end
            end
            
            default: begin
                current_state_SE_layer  = REDUCE_CONV;
            end

        endcase
    end
    reg done_compute_reduce;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            IFM_C_se <=  0;
            done_compute_reduce <=0;
        end else begin
            case (current_state_SE_layer)
                REDUCE_CONV: begin
                    IFM_C_se <=  OFM_C_layer2;
                    OFM_C_se <=  OFM_C_se_reduce;
                    //req_addr_out_ifm_layerSE_for_IFM_BRAM <=    0;
                    if (next_state_SE_layer  == EXPAND_CONV) done_compute_reduce <=1;
                    else done_compute_reduce <=0;
                end

                EXPAND_CONV: begin

                    IFM_C_se <=  OFM_C_se_reduce;
                    OFM_C_se <=  OFM_C_layer2;
                    //req_addr_out_ifm_layerSE_for_IFM_BRAM <= req_addr_out_ifm_layerSE;
                    done_compute_reduce <=0;
                end
                                  
                default: begin
                    
                end
            endcase
        end
    end

    assign req_addr_out_ifm_layerSE_for_IFM_BRAM = current_state_SE_layer ? req_addr_out_ifm_layerSE : 'h0;

    wire [31:0] data_pooling_average_32bit;
    Pooling_average_BRAM pooling(
    .clk(clk),
    .reset_n(rst_n),
    //data signal
    .data_in(data_in_pooling),

    //control signal
    .read_addr(read_addr_pooling),
    .write_addr(write_addr_pooling),
    .we(we_pooling),
    .init_phase(init_phase_pooling),
    .control_data(control_data_pooling),
    .valid(valid_layer2),
    .data_pooling_average(data_pooling_average),
    .data_pooling_average_32bit(data_pooling_average_32bit)
    );
//BRAM for SE reduce layer 

    wire [31:0] IFM_data_reduce_layer;
    assign IFM_data_reduce_layer = data_pooling_average_32bit;
    BRAM BRam_Weight_0_SE_reduce(
        .clk(clk),
        .rd_addr(req_addr_out_filter_layerSE),
        .wr_addr(addr_Wei_layer_reduce),
        .wr_rd_en(wr_rd_en_Weight_layer_reduce),
        //.wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_0_reduce),
        .data_out(Weight_0_reduce)
    );
    
    BRAM BRam_Weight_1_SE_reduce(
        .clk(clk),
        .rd_addr(req_addr_out_filter_layerSE),
        .wr_addr(addr_Wei_layer_reduce),
        .wr_rd_en(wr_rd_en_Weight_layer_reduce),
        //.wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_1_reduce),
        .data_out(Weight_1_reduce)
    );
    
    BRAM BRam_Weight_2_SE_reduce(
        .clk(clk),
        .rd_addr(req_addr_out_filter_layerSE),
        .wr_addr(addr_Wei_layer_reduce),
        .wr_rd_en(wr_rd_en_Weight_layer_reduce),
        //.wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_2_reduce),
        .data_out(Weight_2_reduce)
    );

    BRAM BRam_Weight_3_SE_reduce(
        .clk(clk),
        .rd_addr(req_addr_out_filter_layerSE),
        .wr_addr(addr_Wei_layer_reduce),
        .wr_rd_en(wr_rd_en_Weight_layer_reduce),
        //.wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_3_reduce),
        .data_out(Weight_3_reduce)
    );
//BRAM for SE expand layer 
    BRAM BRam_Weight_0_SE_expand(
        .clk(clk),
        .rd_addr(req_addr_out_filter_layerSE),
        .wr_addr(addr_Wei_layer_reduce),
        .wr_rd_en(wr_rd_en_Weight_layer_reduce),
        //.wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_0_expand),
        .data_out(Weight_0_expand)
    );

    BRAM BRam_Weight_1_SE_expand(
        .clk(clk),
        .rd_addr(req_addr_out_filter_layerSE),
        .wr_addr(addr_Wei_layer_reduce),
        .wr_rd_en(wr_rd_en_Weight_layer_reduce),
        //.wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_1_expand),
        .data_out(Weight_1_expand)
    );

    BRAM BRam_Weight_2_SE_expand(
        .clk(clk),
        .rd_addr(req_addr_out_filter_layerSE),
        .wr_addr(addr_Wei_layer_reduce),
        .wr_rd_en(wr_rd_en_Weight_layer_reduce),
        //.wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_2_expand),
        .data_out(Weight_2_expand)
    );

    BRAM BRam_Weight_3_SE_expand(
        .clk(clk),
        .rd_addr(req_addr_out_filter_layerSE),
        .wr_addr(addr_Wei_layer_reduce),
        .wr_rd_en(wr_rd_en_Weight_layer_reduce),
        //.wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_3_expand),
        .data_out(Weight_3_expand)
    );
    
   
//BRAM for SE expand layer 

    always_ff @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            done_compute_pooling    <=  0;
        end
        else begin
        if( (count_init_for_pooling == 9408 ) && (init_phase_pooling)  ) 
            done_compute_pooling <= 1 ;
        else 
            done_compute_pooling <= 0 ;
        end
            
    end

    assign ready_addr_gen_SE = next_state_SE_layer ? done_compute_reduce :done_compute_pooling  ; 
    
    address_generator_SE addr_gen_SE(
        .clk(clk),
        .rst_n(rst_n),
        .KERNEL_W(1),
        .OFM_W(1),
        .OFM_C(OFM_C_se),
        .IFM_C(IFM_C_se),
        .IFM_W(1),
        .stride(1),
        //.ready(cal_start),
        .ready(ready_addr_gen_SE),
        .addr_in(0),
        .req_addr_out_filter(req_addr_out_filter_layerSE),
        .req_addr_out_ifm(req_addr_out_ifm_layerSE),
        .done_compute(done_compute_SE),
        .done_window(done_window_for_SE),
        .finish_for_PE(finish_for_PE_SE_cluster),
        .addr_valid_filter(),
        .num_of_tiles_for_PE()
    );

    assign valid_layer_reduce = finish_for_PE_SE_cluster;
    wire [31:0] IFM_data_expand_layer;
    wire [31:0] IFM_SE_layer;
    wire [31:0] Weight_0_SE_layer;
    wire [31:0] Weight_1_SE_layer;
    wire [31:0] Weight_2_SE_layer;
    wire [31:0] Weight_3_SE_layer;
    assign IFM_SE_layer = current_state_SE_layer ? IFM_data_expand_layer : IFM_data_reduce_layer;

    assign Weight_0_SE_layer = current_state_SE_layer ? Weight_0_expand : Weight_0_reduce;
    assign Weight_1_SE_layer = current_state_SE_layer ? Weight_1_expand : Weight_1_reduce;
    assign Weight_2_SE_layer = current_state_SE_layer ? Weight_2_expand : Weight_2_reduce;
    assign Weight_3_SE_layer = current_state_SE_layer ? Weight_3_expand : Weight_3_reduce;
    PE_cluster_1x1 PE_SE_cluster(
        .clk(clk),
        .reset_n(rst_n),
        .PE_reset({4{done_window_for_SE}}),
        .Weight_0(Weight_0_SE_layer),
        .Weight_1(Weight_1_SE_layer),
        .Weight_2(Weight_2_SE_layer),
        .Weight_3(Weight_3_SE_layer),
        .IFM(IFM_SE_layer),
        .OFM_0(OFM_0_SE_layer),
        .OFM_1(OFM_1_SE_layer),
        .OFM_2(OFM_2_SE_layer),
        .OFM_3(OFM_3_SE_layer)
    );
    wire [31:0] addr_ram_next_wr_wire;
    Data_controller_MBblock #(
        .control_mux_para(0)
    ) Data_controller_inst(
        .clk(clk),
        .rst_n(rst_n),
        .OFM_data_out_valid({16{finish_for_PE_SE_cluster}}),
        //.control_mux(control_mux_wire),
        .done_compute( done_compute_SE ),
        .addr_ram_next_wr(addr_ram_next_wr_wire),
        .wr_en_next(wr_en_next_write),
        .wr_data_valid(wr_data_valid)
    );
    wire  wr_rd_en_IFM_BRAM_SE;
    assign wr_rd_en_IFM_BRAM_SE = current_state_SE_layer? 0: finish_for_PE_SE_cluster;
    BRAM_IFM IFM_BRAM_SE(
        .clk(clk),
        .rd_addr(req_addr_out_ifm_layerSE_for_IFM_BRAM),
        .wr_addr(addr_ram_next_wr_wire),
        //.wr_rd_en(wr_rd_en_IFM),
        .wr_rd_en(wr_rd_en_IFM_BRAM_SE),
        .data_in({OFM_3_SE_layer,OFM_2_SE_layer,OFM_1_SE_layer,OFM_0_SE_layer}),
        .data_out( IFM_data_expand_layer )
    );
    
    wire  wr_rd_en_IFM_BRAM_Multiple;
    assign wr_rd_en_IFM_BRAM_Multiple = current_state_SE_layer? finish_for_PE_SE_cluster :0;
    BRAM_IFM IFM_BRAM_Multiple(
        .clk(clk),
        .rd_addr(req_addr_out_ifm_layerSE_for_IFM_BRAM),
        .wr_addr(addr_ram_next_wr_wire),
        //.wr_rd_en(wr_rd_en_IFM),
        .wr_rd_en(wr_rd_en_IFM_BRAM_Multiple),
        .data_in({OFM_3_SE_layer,OFM_2_SE_layer,OFM_1_SE_layer,OFM_0_SE_layer}),
        .data_out(  )
    );
    


    

    
    

endmodule