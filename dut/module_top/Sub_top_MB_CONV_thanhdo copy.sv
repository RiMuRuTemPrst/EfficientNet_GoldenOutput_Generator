module Sub_top_MB_CONV_thanhdo#
(   
    parameter Num_of_layer1_PE_para= 16, 
    parameter Num_of_layer2_PE_para =4
)(
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
    input        wr_rd_en_Weight_layer2,
    input [31:0] data_in_Weight_0_n_state,  // layer 2
    input [31:0] data_in_Weight_1_n_state,  // layer 2
    input [31:0] data_in_Weight_2_n_state,  // layer 2
    input [31:0] data_in_Weight_3_n_state,  // layer 2

    input [31:0] addr_Wei_layer_reduce,
    input        wr_rd_en_Weight_layer_reduce,

    input [31:0] data_in_Weight_0_reduce,  // layer reduce
    input [31:0] data_in_Weight_1_reduce,  // layer reduce
    input [31:0] data_in_Weight_2_reduce,  // layer reduce
    input [31:0] data_in_Weight_3_reduce,  // layer reduce

    input [31:0] addr_Wei_layer_expand,
    input        wr_rd_en_Weight_layer_expand,
    input [31:0] data_in_Weight_0_expand,  // layer expand
    input [31:0] data_in_Weight_1_expand,  // layer expand
    input [31:0] data_in_Weight_2_expand,  // layer expand
    input [31:0] data_in_Weight_3_expand,  // layer expand

    //next state pipeline
    input [31:0] addr_ram_next_wr,
    input [3:0] PE_reset_n_state,
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

    input  wire [3:0] KERNEL_W_layer1,
    input  wire [7:0] OFM_W_layer1,
    input  wire [7:0] OFM_C_layer1,
    input  wire [7:0] IFM_C_layer1,
    input  wire [7:0] IFM_W_layer1,
    input  wire [1:0] stride_layer1,


    input  wire [7:0] OFM_C_layer7,
 

    input  wire [3:0] KERNEL_W_layer2,
    input  wire [7:0] IFM_C_layer2,
    input  wire [7:0] OFM_C_layer2,

    input  wire [7:0] OFM_C_se_reduce,
   
    
    input  wire [1:0] stride_layer2,

    


    // for Control_unit
    input  wire        run,
    input  wire [3:0]  instrution, 
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
    input [31:0] addr_IFM_layer_2,
    input valid_for_next_pipeline,
    input [31:0] wr_addr_IFM_layer_2,
    

    //signal for pooling average
    input [31:0] read_addr_pooling_tb, // must have rtl code
    input [31:0] write_addr_pooling,  // must have rtl code
    input init_phase_pooling,         // must have rtl code
    input [1:0] control_data_pooling, // must have rtl code
    input we_pooling,                 // must have rtl code
    input [31:0]  count_init_for_pooling, // must have rtl code



    //layer CONV 1x1 next
    input [31:0] addr_wr_pre_SE, // must have rtl code
    input [31:0] addr_rd_pre_SE, // must have rtl code
    input [31:0] addr_rd_mul, // must have rtl code
    input start_mutiple, // must have rtl code
    input multiply_we_back // must have rtl code
);

    logic [31:0] addr_wr_pre_SE_test;
    logic [31:0] addr_rd_pre_SE_test;
    logic [31:0] addr_rd_mul_test;
    logic start_mutiple_test;
    logic multiply_we_back_test;

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

    logic [31:0] addr_IFM_Conv1x1;
    logic [19:0] addr_wei_Conv1x1;
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
    wire        we_Weight_Conv1x1;
    wire [31:0] wr_addr_Weight;
    wire [31:0] wr_addr_IFM;

    logic [31:0] base_addr =0;


    // signal for layer 2
    logic [127:0] data_in_IFM_layer_2;
    wire finish_for_PE_DW_cluster;

    //signal_for_average_Pooling
    logic [31:0] data_in_pooling;

    //signal_for_CONV1x1_post_SE
    logic [31:0] multiple_x;
    logic [31:0] multiple_y;
    logic [7:0] OFM_mul_1;
    logic [7:0] OFM_mul_2;
    logic [7:0] OFM_mul_3;
    logic [7:0] OFM_mul_4;
    logic [31:0] data_write_back_post_SE;
    logic [31:0] data_in_post_SE;
    logic       valid_post_SE;

    reg [3:0] KERNEL_W_Conv1x1;
    reg [7:0] OFM_W_Conv1x1;
    reg [7:0] OFM_C_Conv1x1;
    reg [7:0] IFM_C_Conv1x1;
    reg [7:0] IFM_W_Conv1x1;
    reg [1:0] stride_Conv1x1;
    reg       ready_Con1x1;
    wire        done_compute_Conv1x1;

    wire       done_compute_layer2;

    wire [63:0] data_pooling_average;

    wire [31:0] IFM_data_check_padding;


    wire [2:0] current_state_SE_layer_for_ctl_unit;
    Control_unit Control_unit(
        .clk(clk),
        .rst_n(rst_n),
        .run(run),
        .instrution(instrution),
        .KERNEL_W(KERNEL_W_layer1),
        .OFM_W(OFM_W_Conv1x1),
        .OFM_C(OFM_C_Conv1x1),
        .IFM_C(IFM_C_Conv1x1),
        .IFM_W(IFM_W_Conv1x1),
        .stride(stride_Conv1x1),
        .addr_valid(addr_valid),
        .done_compute(done_compute_Conv1x1),
        .tile(tile),
        .current_state_SE_layer(current_state_SE_layer_for_ctl_unit),
        //out
        .cal_start(cal_start_ctl),
        .wr_rd_req_IFM(wr_rd_req_IFM),
        .wr_addr_IFM(wr_addr_IFM),
        .wr_rd_req_Weight(we_Weight_Conv1x1),
        .wr_addr_Weight(wr_addr_Weight),
        .base_addr(),
        .current_state_o()
    );



    BRAM_IFM IFM_BRAM(
        .clk(clk),
        .rd_addr(addr_IFM_Conv1x1),
        .wr_addr(wr_addr_IFM),
        //.wr_rd_en(wr_rd_en_IFM),
        .wr_rd_en(wr_rd_req_IFM),
        .data_in(data_in_IFM),
        .data_out(IFM_data)
    );
    reg [31:0] wr_addr_Weight_Conv1x1;
    BRAM BRam_Weight_0_layer1(
        .clk(clk),
        .rd_addr(addr_wei_Conv1x1),
        .wr_addr(wr_addr_Weight_Conv1x1),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(we_Weight_Conv1x1),
        .data_in(data_in_Weight_0),
        .data_out(Weight_0)
    );
    BRAM BRam_Weight_1_layer1(
        .clk(clk),
        .rd_addr(addr_wei_Conv1x1),
        .wr_addr(wr_addr_Weight_Conv1x1),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(we_Weight_Conv1x1),
        .data_in(data_in_Weight_1),
        .data_out(Weight_1)
    );
    BRAM BRam_Weight_2_layer1(
        .clk(clk),
        .rd_addr(addr_wei_Conv1x1),
        .wr_addr(wr_addr_Weight_Conv1x1),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(we_Weight_Conv1x1),
        .data_in(data_in_Weight_2),
        .data_out(Weight_2)
    );
    BRAM BRam_Weight_3_layer1(
        .clk(clk),
        .rd_addr(addr_wei_Conv1x1),
        .wr_addr(wr_addr_Weight_Conv1x1),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(we_Weight_Conv1x1),
        .data_in(data_in_Weight_3),
        .data_out(Weight_3)
    );
    BRAM BRam_Weight_4_layer1(
        .clk(clk),
        .rd_addr(addr_wei_Conv1x1),
        .wr_addr(wr_addr_Weight_Conv1x1),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(we_Weight_Conv1x1),
        .data_in(data_in_Weight_4),
        .data_out(Weight_4)
    );
    BRAM BRam_Weight_5_layer1(
        .clk(clk),
        .rd_addr(addr_wei_Conv1x1),
        .wr_addr(wr_addr_Weight_Conv1x1),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(we_Weight_Conv1x1),
        .data_in(data_in_Weight_5),
        .data_out(Weight_5)
    );
    BRAM BRam_Weight_6_layer1(
        .clk(clk),
        .rd_addr(addr_wei_Conv1x1),
        .wr_addr(wr_addr_Weight_Conv1x1),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(we_Weight_Conv1x1),
        .data_in(data_in_Weight_6),
        .data_out(Weight_6)
    );
    BRAM BRam_Weight_7_layer1(
        .clk(clk),
        .rd_addr(addr_wei_Conv1x1),
        .wr_addr(wr_addr_Weight_Conv1x1),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(we_Weight_Conv1x1),
        .data_in(data_in_Weight_7),
        .data_out(Weight_7)
    );
    BRAM BRam_Weight_8_layer1(
        .clk(clk),
        .rd_addr(addr_wei_Conv1x1),
        .wr_addr(wr_addr_Weight_Conv1x1),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(we_Weight_Conv1x1),
        .data_in(data_in_Weight_8),
        .data_out(Weight_8)
    );
    BRAM BRam_Weight_9_layer1(
        .clk(clk),
        .rd_addr(addr_wei_Conv1x1),
        .wr_addr(wr_addr_Weight_Conv1x1),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(we_Weight_Conv1x1),
        .data_in(data_in_Weight_9),
        .data_out(Weight_9)
    );
    BRAM BRam_Weight_10_layer1(
        .clk(clk),
        .rd_addr(addr_wei_Conv1x1),
        .wr_addr(wr_addr_Weight_Conv1x1),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(we_Weight_Conv1x1),
        .data_in(data_in_Weight_10),
        .data_out(Weight_10)
    );
    BRAM BRam_Weight_11_layer1(
        .clk(clk),
        .rd_addr(addr_wei_Conv1x1),
        .wr_addr(wr_addr_Weight_Conv1x1),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(we_Weight_Conv1x1),
        .data_in(data_in_Weight_11),
        .data_out(Weight_11)
    );
    BRAM BRam_Weight_12_layer1(
        .clk(clk),
        .rd_addr(addr_wei_Conv1x1),
        .wr_addr(wr_addr_Weight_Conv1x1),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(we_Weight_Conv1x1),
        .data_in(data_in_Weight_12),
        .data_out(Weight_12)
    );
    BRAM BRam_Weight_13_layer1(
        .clk(clk),
        .rd_addr(addr_wei_Conv1x1),
        .wr_addr(wr_addr_Weight_Conv1x1),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(we_Weight_Conv1x1),
        .data_in(data_in_Weight_13),
        .data_out(Weight_13)
    );
    BRAM BRam_Weight_14_layer1(
        .clk(clk),
        .rd_addr(addr_wei_Conv1x1),
        .wr_addr(wr_addr_Weight_Conv1x1),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(we_Weight_Conv1x1),
        .data_in(data_in_Weight_14),
        .data_out(Weight_14)
    );
    BRAM BRam_Weight_15_layer1(
        .clk(clk),
        .rd_addr(addr_wei_Conv1x1),
        .wr_addr(wr_addr_Weight_Conv1x1),
        //.wr_rd_en(wr_rd_en_Weight),
        .wr_rd_en(we_Weight_Conv1x1),
        .data_in(data_in_Weight_15),
        .data_out(Weight_15)
    );
    reg [31:0] IFM_data_Conv1x1;
    reg        mul_en_Conv1x1;
    PE_cluster_v2 PE_cluster_layer1(
        .clk(clk),
        .reset_n(rst_n),
        .PE_reset(done_window_for_PE_cluster),
        //.PE_finish(PE_finish),
        //.valid(valid),
        .mul_en(mul_en_Conv1x1),
        .coef_1(coef_1),
        .coef_2(coef_2),
        .coef_3(coef_3),
        .coef_4(coef_4),

        .IFM(IFM_data_Conv1x1),
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
    
    

    address_generator addr_gen(
        .clk(clk),
        .rst_n(rst_n),
        .KERNEL_W(KERNEL_W_Conv1x1),
        .OFM_W(OFM_W_Conv1x1),
        .OFM_C(OFM_C_Conv1x1),
        .IFM_C(IFM_C_Conv1x1),
        .IFM_W(IFM_W_Conv1x1),
        .stride(stride_Conv1x1),
        //.ready(cal_start),
        .ready(ready_Con1x1),
        .addr_in(base_addr),
        .req_addr_out_filter(addr_wei_Conv1x1),
        .req_addr_out_ifm(addr_IFM_Conv1x1),
        .done_compute(done_compute_Conv1x1),
        .done_window(done_window_one_bit),
        .finish_for_PE(finish_for_PE),
        .addr_valid_filter(addr_valid),
        .num_of_tiles_for_PE(tile)
    );

    
    assign done_window_for_PE_cluster       =   {16{done_window_one_bit}};
    assign finish_for_PE_cluster_layer1     =   (cal_start_ctl) && ( addr_IFM_Conv1x1 != 'b0 )   ? {16{finish_for_PE}} : 16'b0;


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
    assign finish_for_PE_cluster_layer2 =  (req_addr_out_ifm_layer2!= 'b0)  ? finish_for_PE_layer2 : 1'b0;


    wire wr_en_from_control_padding;
    wire [31:0] wr_addr_from_control_padding;
    wire [16*8-1:0] IFM_data_layer_2_from_control_padding;


    reg start_for_control_padding;
    control_padding #( 
        .PE()
    ) control_padding_inst (
        .clk(clk),
        .rst_n(rst_n),
        .valid(finish_for_PE_cluster_layer1),
        .start(start_for_control_padding),
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
        .data_out(IFM_data_check_padding)
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
        .IFM(IFM_data_check_padding),
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
    

    parameter POOLING_IDLE      = 0;
    parameter POOLING_EXCUTE_1  = 1;
    parameter POOLING_EXCUTE_2  = 2;
    parameter POOLING_EXCUTE_3  = 3;
    parameter POOLING_EXCUTE_4  = 4;
    reg [2:0] last_state_POOLING, current_state_POOLING , next_state_POOLING ;

    reg [31:0] count_init_for_pooling_test;
    logic [31:0] read_addr_pooling_test;
    logic [31:0] write_addr_pooling_test;
    logic init_phase_pooling_test;
    logic [1:0] control_data_pooling_test;
    reg [7:0] counter_num_of_PE_for_DW_1;
    reg [7:0] counter_num_of_PE_for_DW_2;
    reg [7:0] addition_counter_for_Pooling;
    wire [7:0] counter_num_of_PE_for_DW;

    reg we_pooling_test;
    reg done_compute_pooling_test;
    // assign read_addr_pooling = excute_average ? read_addr_pooling_tb: read_addr_pooling_tb  ; /// for test poolinng block
    assign read_addr_pooling = excute_average ? read_addr_pooling_test: req_addr_out_ifm_layerSE  ;

    assign control_data_pooling_test = counter_num_of_PE_for_DW;
    //-------------------------------------------------POOLING---------------------------------------------------------//
    // FSM State Register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state_POOLING <= POOLING_IDLE;
        else
            current_state_POOLING <= next_state_POOLING;
    end
     always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            last_state_POOLING <= POOLING_IDLE;
        else
            last_state_POOLING <= current_state_POOLING;
    end
    always @(*) begin
    case (current_state_POOLING)

        POOLING_IDLE: begin
            if ( finish_for_PE_cluster_layer2 ) begin
                next_state_POOLING =    POOLING_EXCUTE_1 ;
            end else begin
                next_state_POOLING =    POOLING_IDLE;
                
            end
        end

        POOLING_EXCUTE_1: begin
            if ( finish_for_PE_cluster_layer2 ) begin
                next_state_POOLING =    POOLING_EXCUTE_2 ;
            end else begin
                next_state_POOLING =    POOLING_EXCUTE_1;
            end
        end
        POOLING_EXCUTE_2: begin
            if ( done_compute_pooling_test ) begin
                next_state_POOLING =    POOLING_IDLE ;
            end else begin
                if ( finish_for_PE_cluster_layer2 ) begin
                    next_state_POOLING =    POOLING_EXCUTE_1 ;
                end else begin
                    next_state_POOLING =    POOLING_EXCUTE_2;
                end
            end
        end
        
        default: begin
            next_state_POOLING  = POOLING_IDLE;
        end

    endcase
    end

    

    assign counter_num_of_PE_for_DW = counter_num_of_PE_for_DW_1+ counter_num_of_PE_for_DW_2 -1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            excute_average                  <=0;
            count_init_for_pooling_test     <=0;
            read_addr_pooling_test          <=0;
            write_addr_pooling_test         <=0;
            init_phase_pooling_test         <=1;
            we_pooling_test                 <=0;
            counter_num_of_PE_for_DW_1      <=0;
            counter_num_of_PE_for_DW_2      <=0;
            done_compute_pooling_test       <=0;
            addition_counter_for_Pooling    <=0;
        end else begin
            case (current_state_POOLING)
                POOLING_IDLE: begin

                    count_init_for_pooling_test <= 0;
                    init_phase_pooling_test <= 1;
                    done_compute_pooling_test <= 0 ;
                    addition_counter_for_Pooling<=0;
                end

                POOLING_EXCUTE_1: begin
                    counter_num_of_PE_for_DW_2    <=0;
                    if ( finish_for_PE_cluster_layer2 ) count_init_for_pooling_test <= count_init_for_pooling_test +1;                    
                    
                    if ( counter_num_of_PE_for_DW_1 < Num_of_layer2_PE_para ) begin
                        counter_num_of_PE_for_DW_1 <= counter_num_of_PE_for_DW_1+1;
                        we_pooling_test <=1;
                        read_addr_pooling_test <= read_addr_pooling_test + 1;
                        write_addr_pooling_test <= read_addr_pooling_test;
                        if(read_addr_pooling_test == OFM_C_layer2) read_addr_pooling_test <=0;
                    end else begin
                        we_pooling_test <=0;
                    end
                    if ( count_init_for_pooling_test > (OFM_C_layer2 /Num_of_layer2_PE_para) -1 ) begin
                        init_phase_pooling_test <= 0;
                    end

                end
                POOLING_EXCUTE_2: begin
                    counter_num_of_PE_for_DW_1 <= 0;
                    if ( finish_for_PE_cluster_layer2 ) begin
                        count_init_for_pooling_test <= count_init_for_pooling_test +1;
                    end else begin
                        if (count_init_for_pooling_test == OFM_W_layer2*OFM_W_layer2*OFM_C_layer2/Num_of_layer2_PE_para -1 )
                           begin 
                            addition_counter_for_Pooling <= addition_counter_for_Pooling+1;
                           end
                        else addition_counter_for_Pooling <=0;
                    end
                    if ( counter_num_of_PE_for_DW_2 < Num_of_layer2_PE_para ) begin
                        counter_num_of_PE_for_DW_2 <= counter_num_of_PE_for_DW_2+1;
                        we_pooling_test <=1;
                        read_addr_pooling_test <= read_addr_pooling_test + 1;
                        write_addr_pooling_test <= read_addr_pooling_test;
                        if(read_addr_pooling_test == OFM_C_layer2-1) read_addr_pooling_test <=0;
                    end else begin
                        we_pooling_test <=0;
                    end
 
                    if( addition_counter_for_Pooling == Num_of_layer2_PE_para +2 ) 
                        done_compute_pooling_test <= 1 ;
                    else 
                        done_compute_pooling_test <= 0 ;

                end
                                  
                default: begin
                    
                end
            endcase

            case (next_state_POOLING)
                POOLING_IDLE: begin
                    excute_average<=0;
                end

                POOLING_EXCUTE_1: begin
                    excute_average<=1; 
                end
                POOLING_EXCUTE_2: begin
                    excute_average<=1; 
                end
                                  
                default: begin
                    
                end
            endcase
        end
    end


//----------------------------------------------------_FSM_FOR_REDUCE_EXPAND------------------------------------//
    parameter DW_CONV           = 3'b000;
    parameter REDUCE_CONV       = 3'b001;
    parameter EXPAND_CONV       = 3'b010;
    parameter MULTIPLE          = 3'b011;
    parameter LAST_CONV         = 3'b100;
    reg [2:0]current_state_SE_layer , next_state_SE_layer ;
    reg [31:0] req_addr_out_ifm_layerSE_for_IFM_BRAM ;
    reg [31:0] IFM_SE_layer;
    reg [31:0] Weight_0_SE_layer;
    reg [31:0] Weight_1_SE_layer;
    reg [31:0] Weight_2_SE_layer;
    reg [31:0] Weight_3_SE_layer;
    reg wr_rd_en_IFM_BRAM_SE;
    reg wr_rd_en_IFM_BRAM_Multiple;
    reg ready_addr_gen_SE;

    reg [31:0] addr_rd_pre_SE_IFM;

    wire [31:0] IFM_data_reduce_layer;
    wire [31:0] IFM_data_expand_layer;

    reg done_compute_reduce;
    assign current_state_SE_layer_for_ctl_unit = current_state_SE_layer;


    //wire ready_addr_gen_SE ;

    //-------------------------------------------------POOLING---------------------------------------------------------//
    // FSM State Register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state_SE_layer <= DW_CONV;
        else
            current_state_SE_layer <= next_state_SE_layer;
    end
    always @(*) begin
        case (current_state_SE_layer)
            DW_CONV: begin
                if ( done_compute_layer2 ) begin
                    next_state_SE_layer =    REDUCE_CONV ;
                end else begin
                    next_state_SE_layer =    DW_CONV;
                    
                end
            end
           
            REDUCE_CONV: begin
                if ( done_compute_SE ) begin
                    next_state_SE_layer =    EXPAND_CONV ;
                end else begin
                    next_state_SE_layer =    REDUCE_CONV;
                    
                end
            end

            EXPAND_CONV: begin
                if ( done_compute_SE ) begin
                    next_state_SE_layer =    MULTIPLE ;
                end else begin
                    next_state_SE_layer =    EXPAND_CONV;
                    
                end
            end
            MULTIPLE: begin
                if( valid_post_SE ==0 ) begin
                    next_state_SE_layer =    LAST_CONV;
                end else begin
                    next_state_SE_layer =    MULTIPLE;
                end  
            end

            LAST_CONV: begin
                if( done_compute_Conv1x1 ==1 ) begin
                    next_state_SE_layer =    DW_CONV;
                end else begin
                    next_state_SE_layer =    LAST_CONV;
                end
                
            end
            default: begin

            end

        endcase
    end



    always @(*) begin

        case (current_state_SE_layer)
            DW_CONV: begin
                KERNEL_W_Conv1x1 = KERNEL_W_layer1;
                OFM_W_Conv1x1    = OFM_W_layer1;
                OFM_C_Conv1x1    = OFM_C_layer1;
                IFM_C_Conv1x1    = IFM_C_layer1;
                IFM_W_Conv1x1    = IFM_W_layer1;
                stride_Conv1x1   = stride_layer1;
                ready_Con1x1     = cal_start_ctl;
                mul_en_Conv1x1   ='b0;

                start_for_control_padding = cal_start_ctl;

                addr_rd_pre_SE_IFM = addr_rd_pre_SE;
                IFM_data_Conv1x1   = IFM_data;
                wr_addr_Weight_Conv1x1 = wr_addr_Weight;

                req_addr_out_ifm_layerSE_for_IFM_BRAM = 'h0;
                
                IFM_SE_layer      = IFM_data_reduce_layer;
                Weight_0_SE_layer = Weight_0_reduce;
                Weight_1_SE_layer = Weight_1_reduce;
                Weight_2_SE_layer = Weight_2_reduce;
                Weight_3_SE_layer = Weight_3_reduce;
                
                wr_rd_en_IFM_BRAM_SE = finish_for_PE_SE_cluster;
                wr_rd_en_IFM_BRAM_Multiple = 'h0;

                data_in_post_SE = data_in_pooling;
                valid_post_SE   = finish_for_PE_cluster_layer2;
            end

            REDUCE_CONV: begin
                KERNEL_W_Conv1x1 = 1;
                OFM_W_Conv1x1    = OFM_W_layer2;
                OFM_C_Conv1x1    = OFM_C_layer7;
                IFM_C_Conv1x1    = OFM_C_layer2;
                IFM_W_Conv1x1    = OFM_W_layer2;
                stride_Conv1x1   = 1;
                mul_en_Conv1x1   ='b0;

                ready_Con1x1     = cal_start_ctl;

                start_for_control_padding = 0;

                addr_rd_pre_SE_IFM = addr_rd_pre_SE;
                IFM_data_Conv1x1   = IFM_data;
                wr_addr_Weight_Conv1x1 = wr_addr_Weight;

                req_addr_out_ifm_layerSE_for_IFM_BRAM = 'h0;
                
                IFM_SE_layer      = IFM_data_reduce_layer;
                Weight_0_SE_layer = Weight_0_reduce;
                Weight_1_SE_layer = Weight_1_reduce;
                Weight_2_SE_layer = Weight_2_reduce;
                Weight_3_SE_layer = Weight_3_reduce;
                
                wr_rd_en_IFM_BRAM_SE = finish_for_PE_SE_cluster;
                wr_rd_en_IFM_BRAM_Multiple = 'h0;

                data_in_post_SE = data_in_pooling;
                valid_post_SE   = finish_for_PE_cluster_layer2;
                
            end

            EXPAND_CONV: begin
                addr_rd_pre_SE_IFM = addr_rd_pre_SE;
                KERNEL_W_Conv1x1 = 1;
                OFM_W_Conv1x1    = OFM_W_layer2;
                OFM_C_Conv1x1    = OFM_C_layer7;
                IFM_C_Conv1x1    = OFM_C_layer2;
                IFM_W_Conv1x1    = OFM_W_layer2;
                stride_Conv1x1   = 1;
                mul_en_Conv1x1   ='b0;

                req_addr_out_ifm_layerSE_for_IFM_BRAM = req_addr_out_ifm_layerSE;

                IFM_SE_layer      = IFM_data_expand_layer;
                Weight_0_SE_layer = Weight_0_expand;
                Weight_1_SE_layer = Weight_1_expand;
                Weight_2_SE_layer = Weight_2_expand;
                Weight_3_SE_layer = Weight_3_expand;

                wr_addr_Weight_Conv1x1 = wr_addr_Weight;

                wr_rd_en_IFM_BRAM_SE = 'h0;
                wr_rd_en_IFM_BRAM_Multiple = finish_for_PE_SE_cluster;

                data_in_post_SE = data_in_pooling;
                valid_post_SE   = finish_for_PE_cluster_layer2;
               
            end

            MULTIPLE: begin
                addr_rd_pre_SE_IFM = addr_rd_pre_SE;
                req_addr_out_ifm_layerSE_for_IFM_BRAM = 0;

                mul_en_Conv1x1   ='b0;

                IFM_SE_layer      = 0;
                Weight_0_SE_layer = 0;
                Weight_1_SE_layer = 0;
                Weight_2_SE_layer = 0;
                Weight_3_SE_layer = 0;

                wr_addr_Weight_Conv1x1 = wr_addr_Weight;

                wr_rd_en_IFM_BRAM_SE = 'h0;
                wr_rd_en_IFM_BRAM_Multiple = 0;

                data_in_post_SE = data_write_back_post_SE;
                valid_post_SE   = multiply_we_back;
               
            end

            LAST_CONV: begin
                KERNEL_W_Conv1x1 = 1;
                OFM_W_Conv1x1    = OFM_W_layer2;
                OFM_C_Conv1x1    = OFM_C_layer7;
                IFM_C_Conv1x1    = OFM_C_layer2;
                IFM_W_Conv1x1    = OFM_W_layer2;
                stride_Conv1x1   = 1;
                ready_Con1x1     = 1;

                addr_rd_pre_SE_IFM = addr_IFM_Conv1x1;
                IFM_data_Conv1x1   = multiple_y;
                wr_addr_Weight_Conv1x1 = wr_addr_Weight; // inprogress
                
            end
            
            default: begin

            end

        endcase
        case (next_state_SE_layer)
            DW_CONV: begin
                ready_addr_gen_SE   = done_compute_pooling_test;
            end

            REDUCE_CONV: begin
                ready_addr_gen_SE   = done_compute_pooling_test;
                
            end

            EXPAND_CONV: begin
               ready_addr_gen_SE    = done_compute_reduce;
            end

            MULTIPLE: begin

            end
            LAST_CONV: begin
                
            end
            
            default: begin

            end

        endcase
    end
    

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            IFM_C_se                <=0;
            done_compute_reduce     <=0;

        end else begin
            case (current_state_SE_layer)
                DW_CONV: begin
                    
                    IFM_C_se <=  OFM_C_layer2;
                    OFM_C_se <=  OFM_C_se_reduce;
                end
                REDUCE_CONV: begin
                    IFM_C_se <=  OFM_C_layer2;
                    OFM_C_se <=  OFM_C_se_reduce;
                    if (next_state_SE_layer  == EXPAND_CONV) done_compute_reduce <=1;
                    else done_compute_reduce <=0;
                end

                EXPAND_CONV: begin

                    IFM_C_se <=  OFM_C_se_reduce;
                    OFM_C_se <=  OFM_C_layer2;
                    done_compute_reduce <=0;
                end

                MULTIPLE: begin

                    
                end
                                  
                default: begin
                    
                end
            endcase
        end
    end


    wire [31:0] data_pooling_average_32bit;
    Pooling_average_BRAM pooling(
    .clk(clk),
    .reset_n(rst_n),
    //data signal
    .data_in(data_in_pooling),

    //control signal
    .read_addr(read_addr_pooling),
    .write_addr(write_addr_pooling_test),
    .we(we_pooling_test),
    .init_phase(init_phase_pooling_test),
    .control_data(control_data_pooling_test),
    .valid(finish_for_PE_cluster_layer2),
    .data_pooling_average(data_pooling_average),
    .data_pooling_average_32bit(data_pooling_average_32bit)
    );
//BRAM for SE reduce layer 

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
    //ready_addr_gen_SE = next_state_SE_layer ? done_compute_reduce :done_compute_pooling  ; 
   
//BRAM for SE expand layer 

//     always_ff @(posedge clk or negedge rst_n) begin
//         if(~rst_n) begin
//             done_compute_pooling    <=  0;
//         end
//         else begin
//         if( (count_init_for_pooling == OFM_W_layer2*OFM_W_layer2*OFM_C_layer2/Num_of_layer2_PE_para ) && (init_phase_pooling)  ) 
//             done_compute_pooling <= 1 ;
//         else 
//             done_compute_pooling <= 0 ;
//         end
            
// end
    
    
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
    // wire  wr_rd_en_IFM_BRAM_SE;
    // assign wr_rd_en_IFM_BRAM_SE = current_state_SE_layer? 0: finish_for_PE_SE_cluster;
    BRAM_IFM IFM_BRAM_SE(
        .clk(clk),    

        .rd_addr(req_addr_out_ifm_layerSE_for_IFM_BRAM),
        .wr_addr(addr_ram_next_wr_wire),
        //.wr_rd_en(wr_rd_en_IFM),
        .wr_rd_en(wr_rd_en_IFM_BRAM_SE),
        .data_in({OFM_3_SE_layer,OFM_2_SE_layer,OFM_1_SE_layer,OFM_0_SE_layer}),
        .data_out( IFM_data_expand_layer )
    );
    
    // wire  wr_rd_en_IFM_BRAM_Multiple;
    // assign wr_rd_en_IFM_BRAM_Multiple = current_state_SE_layer? finish_for_PE_SE_cluster :0;

    BRAM_IFM IFM_BRAM_Multiple(
        .clk(clk),
        .rd_addr(addr_rd_mul),
        .wr_addr(addr_ram_next_wr_wire),
        //.wr_rd_en(wr_rd_en_IFM),
        .wr_rd_en(wr_rd_en_IFM_BRAM_Multiple),
        .data_in({OFM_3_SE_layer,OFM_2_SE_layer,OFM_1_SE_layer,OFM_0_SE_layer}),
        .data_out( multiple_x)
    );
    // assign data_in_post_SE = start_mutiple ? data_write_back_post_SE : data_in_pooling;
    // assign valid_post_SE = start_mutiple ? multiply_we_back : valid_layer2;

// multiple controller
    reg [1:0] start_mutiple_counter;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
           addr_wr_pre_SE_test      <=0;
           start_mutiple_counter    <=0;
           multiply_we_back_test    <=0;
           addr_rd_pre_SE_test      <=0;
           start_mutiple_test       <=0;
           addr_rd_mul_test         <=0;
        end else begin

            if ( finish_for_PE_cluster_layer2 ) begin
                addr_wr_pre_SE_test <= addr_wr_pre_SE_test + 1;
            end else begin
                if ( done_compute_layer2 ) addr_wr_pre_SE_test <=0;
            end

            if (done_compute_SE ) start_mutiple_counter <= start_mutiple_counter + 1;  

            if ( start_mutiple_counter == 2 ) begin  // 2= number of SE_conv_layer
                start_mutiple_test <= 1;
                multiply_we_back_test <= 1;
                addr_wr_pre_SE_test <= addr_rd_pre_SE_test/4;
                addr_rd_mul_test <= addr_rd_mul_test + 4;
                addr_rd_pre_SE_test <= addr_rd_pre_SE_test + 4;

                if(addr_rd_mul_test > OFM_C_layer1 - 4) begin
                    addr_rd_mul_test <= 0;
                end
            end

            if(addr_rd_pre_SE_test >= OFM_W_layer2*OFM_W_layer2*OFM_C_layer2 )
            begin
                start_mutiple_counter   <= 0;
                multiply_we_back_test   <= 0;
                addr_rd_pre_SE_test     <=0;
            end

        end
    end

    BRAM_OFM_pre_SE BRAM_pre_SE(
        .clk(clk),
        //.rd_addr(addr_rd_pre_SE), // for test ofm_ multiply
        .rd_addr(addr_rd_pre_SE_IFM),
        .wr_addr(addr_wr_pre_SE),
        //.wr_addr(addr_wr_pre_SE_test),
        //.wr_rd_en(wr_rd_en_IFM),
        .wr_rd_en(valid_post_SE),
        .data_in(data_in_post_SE),
        .data_out( multiple_y )
    );

    Mutiple_4x4 Mul_PE(
        .input_x1(multiple_x[7:0]),
        .input_x2(multiple_x[15:8]),
        .input_x3(multiple_x[23:16]),
        .input_x4(multiple_x[31:24]),
        .input_y1(multiple_y[7:0]),
        .input_y2(multiple_y[15:8]),
        .input_y3(multiple_y[23:16]),
        .input_y4(multiple_y[31:24]),
        .OFM_1(OFM_mul_1),
        .OFM_2(OFM_mul_2),
        .OFM_3(OFM_mul_3),
        .OFM_4(OFM_mul_4)
    );
    
    assign data_write_back_post_SE = {OFM_mul_4,OFM_mul_3,OFM_mul_2,OFM_mul_1};

    

    
    

endmodule