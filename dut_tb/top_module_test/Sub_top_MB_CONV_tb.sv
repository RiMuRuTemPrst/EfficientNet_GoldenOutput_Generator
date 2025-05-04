`timescale 1ns / 1ps
// input 9x9x16
// kernel 3x3x16x32
// OFM 56x56x32

`define GOL1 0

`ifndef IFM_W_layer1_para
    `define IFM_W_layer1_para 28
`endif
// `define IFM_C_layer1_para 32
// `define KERNEL_W_layer1_para 3
// `define OFM_C_layer1_para 128
// `define stride_layer1_para 2

// `define OFM_C_layer2_para 16

`define Num_of_layer1_PE_para 16
`define Num_of_layer2_PE_para 4

module Sub_top_MB_CONV_tb #(
    parameter IFM_W_layer1_para     = 14, 

    parameter IFM_C_layer1_para     = 96,

    parameter OFM_C_layer1_para     = 384,

    parameter stride_layer2_para    = 1,

    parameter OFM_C_se_reduce_para  = 24,

    parameter OFM_C_layer7_para     = 96 
    
    
);
    parameter stride_layer1_para    = 1;
    parameter KERNEL_W_layer1_para  =1;
    parameter KERNEL_W_layer2_para  =3;
    parameter OFM_C_layer2_para     = OFM_C_layer1_para;
    parameter OFM_W_layer2_para = IFM_W_layer1_para / stride_layer2_para;
    parameter Start_addr_for_data_layer_2 = (IFM_W_layer1_para + 3) * OFM_C_layer1_para;
    parameter enter_row_data = (IFM_W_layer1_para) * OFM_C_layer1_para;
    parameter inc_addr_for_enter_row = 2*OFM_C_layer1_para;
    parameter End_addr_for_data_layer_2 = ((IFM_W_layer1_para + 2)*(IFM_W_layer1_para + 2) - (IFM_W_layer1_para + 3) ) * OFM_C_layer1_para;

    reg clk;
    reg reset;
    reg wr_rd_en_IFM;
    reg wr_rd_en_Weight;
    reg wr_rd_en_Weight_layer2;
    reg [31:0] addr_Wei_layer2;

    reg wr_rd_en_Weight_layer_reduce;
    reg [31:0] addr_Wei_layer_reduce;

    reg wr_rd_en_Weight_layer_expand;
    reg [31:0] addr_Wei_layer_expand;


    reg [3:0] KERNEL_W_layer1;
    reg [15:0] OFM_C_layer1;
    reg [15:0] OFM_W_layer1;
    reg [15:0] IFM_C_layer1;
    reg [15:0] IFM_W_layer1;
    reg [1:0] stride_layer1;

    reg [31:0] addr, addr_lay2;
    reg [31:0] data_in_IFM;
    reg [31:0] data_in_Weight_0;
    reg [31:0] data_in_Weight_1;
    reg [31:0] data_in_Weight_2;
    reg [31:0] data_in_Weight_3;
    reg [31:0] data_in_Weight_4;
    reg [31:0] data_in_Weight_5;
    reg [31:0] data_in_Weight_6;
    reg [31:0] data_in_Weight_7;
    reg [31:0] data_in_Weight_8;
    reg [31:0] data_in_Weight_9;
    reg [31:0] data_in_Weight_10;
    reg [31:0] data_in_Weight_11;
    reg [31:0] data_in_Weight_12;
    reg [31:0] data_in_Weight_13;
    reg [31:0] data_in_Weight_14;
    reg [31:0] data_in_Weight_15;

    reg [7:0] data_in_Weight_0_n_state;     // layer 2
    reg [7:0] data_in_Weight_1_n_state;     // layer 2
    reg [7:0] data_in_Weight_2_n_state;     // layer 2
    reg [7:0] data_in_Weight_3_n_state;     // layer 2

    reg [31:0] data_in_Weight_0_reduce;   // layer reduce
    reg [31:0] data_in_Weight_1_reduce;   // layer reduce
    reg [31:0] data_in_Weight_2_reduce;   // layer reduce
    reg [31:0] data_in_Weight_3_reduce;   // layer reduce

    reg [31:0] data_in_Weight_0_expand;   // layer expand
    reg [31:0] data_in_Weight_1_expand;   // layer expand
    reg [31:0] data_in_Weight_2_expand;   // layer expand
    reg [31:0] data_in_Weight_3_expand;   // layer expand

    //reg [1:0] control_mux;
    //reg       wr_en_next;
    reg [31:0] addr_ram_next_rd;
    //reg [31:0] addr_ram_next_wr;


    //reg [3:0] PE_next_valid;
    int count_for_layer_1 =0 ;
    int count_for_layer_2 =0;
    int count_GOPS = 0;
    reg [19:0] addr_w[15:0];
    reg [19:0] addr_IFM;
    reg [15:0] PE_reset;
    //reg [15:0] PE_finish;
    wire       done_compute_layer1;

    reg       run;
    reg [3:0] instrution;
    wire        wr_rd_req_IFM_for_tb;
    //wire [31:0] wr_addr_IFM_for_tb;
    //wire        wr_rd_req_Weight_for_tb;
    //wire [31:0] uut.wr_addr_Weight;
    reg [31:0] addr_w_n_state;
    wire [7:0] OFM_DW [3:0];
    wire [7:0] OFM_SE [3:0];
    reg [3:0] PE_reset_n_state;
    reg [3:0] PE_reset_n_state_1;

    
    wire [31:0] OFM;
   
    wire [7:0] OFM_out[15:0];
    
    integer i,j,k,m,k1,k2,k3,k4,k5,k6,k7,k8,k9,j0,j1,j2=0;
    integer ofm_file[15:0];  // Mảng để lưu các file handle
    integer ofm_file_2[3:0];
    integer padding_data;
    integer ofm_file_3;
    integer ofm_file_4;
    integer ofm_file_5[3:0];
    integer ofm_file_6;
    integer ofm_file_7;
    integer ofm_file_8[15:0];
    int link_inital;

    reg [7:0] input_data_mem [0:1076480]; // BRAM input data
    reg [7:0] input_data_mem0 [0:23030];
    reg [7:0] input_data_mem1 [0:23030];
    reg [7:0] input_data_mem2 [0:23030];
    reg [7:0] input_data_mem3 [0:23030];
    reg [7:0] input_data_mem4 [0:23030];
    reg [7:0] input_data_mem5 [0:23030];
    reg [7:0] input_data_mem6 [0:23030];
    reg [7:0] input_data_mem7 [0:23030];
    reg [7:0] input_data_mem8 [0:23030];
    reg [7:0] input_data_mem9 [0:23030];
    reg [7:0] input_data_mem10 [0:23030];
    reg [7:0] input_data_mem11 [0:23030];
    reg [7:0] input_data_mem12 [0:23030];
    reg [7:0] input_data_mem13 [0:23030];
    reg [7:0] input_data_mem14 [0:23030];
    reg [7:0] input_data_mem15 [0:23030];

    reg [7:0] input_data_mem0_2 [0:23030];
    reg [7:0] input_data_mem1_2 [0:23030];
    reg [7:0] input_data_mem2_2 [0:23030];
    reg [7:0] input_data_mem3_2 [0:23030];
    reg [7:0] input_data_mem4_2 [0:23030];
    reg [7:0] input_data_mem5_2 [0:23030];
    reg [7:0] input_data_mem6_2 [0:23030];
    reg [7:0] input_data_mem7_2 [0:23030];
    reg [7:0] input_data_mem8_2 [0:23030];
    reg [7:0] input_data_mem9_2 [0:23030];
    reg [7:0] input_data_mem10_2 [0:23030];
    reg [7:0] input_data_mem11_2 [0:23030];
    reg [7:0] input_data_mem12_2 [0:23030];
    reg [7:0] input_data_mem13_2 [0:23030];
    reg [7:0] input_data_mem14_2 [0:23030];
    reg [7:0] input_data_mem15_2 [0:23030];

    reg [7:0] input_data_mem0_n_state [0:53823]; // BRAM input data
    reg [7:0] input_data_mem1_n_state [0:23030];
    reg [7:0] input_data_mem2_n_state [0:23030];
    reg [7:0] input_data_mem3_n_state [0:23030];

    reg [7:0] input_data_mem0_reduce [0:23030]; // BRAM input data
    reg [7:0] input_data_mem1_reduce [0:23030];
    reg [7:0] input_data_mem2_reduce [0:23030];
    reg [7:0] input_data_mem3_reduce [0:23030];

    reg [7:0] input_data_mem0_expand [0:23030]; // BRAM input data
    reg [7:0] input_data_mem1_expand [0:23030];
    reg [7:0] input_data_mem2_expand [0:23030];
    reg [7:0] input_data_mem3_expand [0:23030];


    logic wr_rd_req_IFM_layer_2;
    logic [31:0] addr_IFM_layer_2;
    logic [31:0] wr_addr_IFM_layer_2;
    logic write_padding;
    //CAL START
    logic [31:0] padding_addr;
    logic [31:0] data_addr_layer_2;
    reg cal_start;

    reg [7:0] ofm_data;
    reg [7:0] ofm_data_2;
    reg [7:0] ofm_data_byte;
    reg [7:0] ofm_data_byte_2;


    reg valid_for_next_pipeline;
    int count_valid_for_dw;
    int count_line,count_line_pipelined;


    int count_valid;
    int count_row;
    int num_of_tiles_for_PE_layer2;

    //pooling
    logic [31:0] read_addr_pooling;
    logic [31:0] write_addr_pooling;
    logic init_phase_pooling;
    logic [1:0] control_data_pooling;
    logic we_pooling;
    int count_init_for_pooling;
    logic [63:0] data_pooling_average;

    //next CONV_1x1
    logic [31:0] addr_rd_pre_SE;
    logic [31:0] addr_wr_pre_SE;
    int start_mutiple;
    logic [31:0] addr_rd_mul;
    logic start_mutiple_for_dut;
    logic multiply_we_back;
    Sub_top_MB_CONV_thanhdo uut (
        .clk(clk),
        .rst_n(reset),
        .wr_rd_en_IFM(wr_rd_en_IFM),
        .wr_rd_en_Weight_layer2(wr_rd_en_Weight_layer2),
        .data_in_IFM(data_in_IFM),
        .data_in_Weight_0(data_in_Weight_0),
        .data_in_Weight_1(data_in_Weight_1),
        .data_in_Weight_2(data_in_Weight_2),
        .data_in_Weight_3(data_in_Weight_3),
        .data_in_Weight_4(data_in_Weight_4),
        .data_in_Weight_5(data_in_Weight_5),
        .data_in_Weight_6(data_in_Weight_6),
        .data_in_Weight_7(data_in_Weight_7),
        .data_in_Weight_8(data_in_Weight_8),
        .data_in_Weight_9(data_in_Weight_9),
        .data_in_Weight_10(data_in_Weight_10),
        .data_in_Weight_11(data_in_Weight_11),
        .data_in_Weight_12(data_in_Weight_12),
        .data_in_Weight_13(data_in_Weight_13),
        .data_in_Weight_14(data_in_Weight_14),
        .data_in_Weight_15(data_in_Weight_15),

        .data_in_Weight_0_n_state(data_in_Weight_0_n_state),
        .data_in_Weight_1_n_state(data_in_Weight_1_n_state),
        .data_in_Weight_2_n_state(data_in_Weight_2_n_state),
        .data_in_Weight_3_n_state(data_in_Weight_3_n_state),

        .addr_Wei_layer_reduce(addr_Wei_layer_reduce),
        .wr_rd_en_Weight_layer_reduce(wr_rd_en_Weight_layer_reduce),
        .data_in_Weight_0_reduce(data_in_Weight_0_reduce),
        .data_in_Weight_1_reduce(data_in_Weight_1_reduce),
        .data_in_Weight_2_reduce(data_in_Weight_2_reduce),
        .data_in_Weight_3_reduce(data_in_Weight_3_reduce),

        .addr_Wei_layer_expand(addr_Wei_layer_expand),
        .wr_rd_en_Weight_layer_expand(wr_rd_en_Weight_layer_expand),
        .data_in_Weight_0_expand(data_in_Weight_0_expand),
        .data_in_Weight_1_expand(data_in_Weight_1_expand),
        .data_in_Weight_2_expand(data_in_Weight_2_expand),
        .data_in_Weight_3_expand(data_in_Weight_3_expand),

        .addr_Wei_layer2(addr_Wei_layer2),
        .cal_start(cal_start),

        //control signal layer 1
        .PE_reset(PE_reset),
        .KERNEL_W_layer1(KERNEL_W_layer1),
        .OFM_C_layer1(OFM_C_layer1),
        .OFM_W_layer1(OFM_W_layer1),
        .IFM_C_layer1(IFM_C_layer1),
        .IFM_W_layer1(IFM_W_layer1),
        .stride_layer1(stride_layer1),


        .OFM_C_layer7(OFM_C_layer7_para),


        //.done_compute(done_compute_layer1),

        //layer2
        .KERNEL_W_layer2(KERNEL_W_layer2_para),
        .IFM_C_layer2(OFM_C_layer2_para),
        .OFM_C_layer2(OFM_C_layer2_para),
        .stride_layer2(stride_layer2_para),

        // SE layer
        .OFM_C_se_reduce(OFM_C_se_reduce_para),
        

        // for Control_unit
        .run(run),
        .instrution(instrution),
        
        
        .OFM_0(OFM_out[0]), .OFM_1(OFM_out[1]), .OFM_2(OFM_out[2]), .OFM_3(OFM_out[3]),
        .OFM_4(OFM_out[4]), .OFM_5(OFM_out[5]), .OFM_6(OFM_out[6]), .OFM_7(OFM_out[7]),
        .OFM_8(OFM_out[8]), .OFM_9(OFM_out[9]), .OFM_10(OFM_out[10]), .OFM_11(OFM_out[11]),
        .OFM_12(OFM_out[12]), .OFM_13(OFM_out[13]), .OFM_14(OFM_out[14]), .OFM_15(OFM_out[15]),

        .OFM_0_DW_layer( OFM_DW[0]), .OFM_1_DW_layer( OFM_DW[1]), 
        .OFM_2_DW_layer( OFM_DW[2]), .OFM_3_DW_layer( OFM_DW[3]), 

        .OFM_0_SE_layer( OFM_SE[0]), .OFM_1_SE_layer( OFM_SE[1]),
        .OFM_2_SE_layer( OFM_SE[2]), .OFM_3_SE_layer( OFM_SE[3]),


        .PE_reset_n_state(PE_reset_n_state),
       //.addr_w_n_state(addr_w_n_state),

       // layer 2
        .wr_rd_req_IFM_layer_2(wr_rd_req_IFM_layer_2),
        .addr_IFM_layer_2(addr_IFM_layer_2),
        .wr_addr_IFM_layer_2(wr_addr_IFM_layer_2),
        .write_padding(write_padding),
        .valid_for_next_pipeline(valid_for_next_pipeline),

        //pooling average
        .read_addr_pooling_tb(read_addr_pooling),
        .write_addr_pooling(write_addr_pooling),
        .init_phase_pooling(init_phase_pooling),
        .control_data_pooling(control_data_pooling),
        .we_pooling(we_pooling),
        .count_init_for_pooling(count_init_for_pooling),

        //next_CONV_1x1
        .addr_rd_pre_SE(addr_rd_pre_SE),
        .addr_wr_pre_SE(addr_wr_pre_SE),
        .addr_rd_mul(addr_rd_mul),
        .start_mutiple(start_mutiple_for_dut),
        .multiply_we_back(multiply_we_back)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    int input_size = IFM_W_layer1_para*IFM_W_layer1_para*IFM_C_layer1_para;
    int tile = OFM_C_layer1_para/`Num_of_layer1_PE_para;
    int tile_2 = OFM_C_layer7_para/`Num_of_layer1_PE_para;
    initial begin
        ////////////////////////////////////LOAD PHASE//////////////////////////////////////////////////
        // Reset phase
        reset       = 0;
        PE_reset    = 0;
        run         =   1;
        #3000
        reset = 1;
        wr_rd_en_IFM = 0;
        wr_rd_en_Weight = 0;
        wr_rd_en_Weight_layer2=0;
        addr = 0;

        KERNEL_W_layer1 = KERNEL_W_layer1_para ;
        OFM_W_layer1 = ((IFM_W_layer1_para+ 2*0 -KERNEL_W_layer1_para)/ stride_layer1_para )+1;
        OFM_C_layer1 = OFM_C_layer1_para;
        IFM_C_layer1 = IFM_C_layer1_para;
        IFM_W_layer1 = IFM_W_layer1_para;


        stride_layer1 = stride_layer1_para;

        cal_start = 0;
        data_in_IFM = 0;
        data_in_Weight_0 = 0;
        data_in_Weight_1 = 0;
        data_in_Weight_2 = 0;
        data_in_Weight_2_n_state=0;
        data_in_Weight_3_n_state=0;

        data_in_Weight_0_reduce=0;
        data_in_Weight_1_reduce=0;
        data_in_Weight_2_reduce=0;
        data_in_Weight_3_reduce=0;

        data_in_Weight_0_expand=0;
        data_in_Weight_1_expand=0;
        data_in_Weight_2_expand=0;
        data_in_Weight_3_expand=0;

        addr_Wei_layer2 =0;
        
        //wr_rd_req_IFM_layer_2 = 0;
        addr_IFM_layer_2 = 0;
        padding_addr = 0;
        data_addr_layer_2 = Start_addr_for_data_layer_2/4;
        count_row = 0;
        wr_rd_req_IFM_layer_2 = 1;
        count_valid_for_dw = 0;
        count_line = 0;
        count_line_pipelined =0;
        valid_for_next_pipeline = 0;

        //pooling 
        read_addr_pooling = 0;
        write_addr_pooling = 0;
        init_phase_pooling = 1;
        control_data_pooling = 1;
        we_pooling = 0;
        count_init_for_pooling = 0;

        //next_CONV_1x1
        addr_rd_pre_SE = 0;
        addr_wr_pre_SE = 0;
        start_mutiple = 0;
        addr_rd_mul = 0;
        start_mutiple_for_dut = 0;
        num_of_tiles_for_PE_layer2 = OFM_C_layer2_para/ `Num_of_layer2_PE_para;
       // write_padding = 1;
        //addr_ram_next_wr = -1;
        //wr_en_next = 0;

        // Load input data from file (example: input_data.hex)
       //$readmemh("C:/Users/Admin/OneDrive - Hanoi University of Science and Technology/Desktop/CNN/Fused-Block-CNN/../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/input_56x56x16_pad.hex", input_data_mem);
        //
        begin
        // $readmemh("../Fused-Block-CNN/address/ifm_padded.hex", input_data_mem);

        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/weight6_PE0.hex", input_data_mem0_2);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/weight6_PE1.hex", input_data_mem1_2);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/weight6_PE2.hex", input_data_mem2_2);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/weight6_PE3.hex", input_data_mem3_2);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/weight6_PE4.hex", input_data_mem4_2);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/weight6_PE5.hex", input_data_mem5_2);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/weight6_PE6.hex", input_data_mem6_2);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/weight6_PE7.hex", input_data_mem7_2);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/weight6_PE8.hex", input_data_mem8_2);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/weight6_PE9.hex", input_data_mem9_2);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/weight6_PE10.hex", input_data_mem10_2);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/weight6_PE11.hex", input_data_mem11_2);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/weight6_PE12.hex", input_data_mem12_2);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/weight6_PE13.hex", input_data_mem13_2);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/weight6_PE14.hex", input_data_mem14_2);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/weight6_PE15.hex", input_data_mem15_2);
        end
        begin
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/ifm.hex", input_data_mem);

        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE0.hex", input_data_mem0);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE1.hex", input_data_mem1);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE2.hex", input_data_mem2);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE3.hex", input_data_mem3);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE4.hex", input_data_mem4);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE5.hex", input_data_mem5);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE6.hex", input_data_mem6);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE7.hex", input_data_mem7);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE8.hex", input_data_mem8);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE9.hex", input_data_mem9);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE10.hex", input_data_mem10);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE11.hex", input_data_mem11);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE12.hex", input_data_mem12);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE13.hex", input_data_mem13);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE14.hex", input_data_mem14);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE15.hex", input_data_mem15);

        end
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/DW/weight2_PE0.hex", input_data_mem0_n_state);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/DW/weight2_PE1.hex", input_data_mem1_n_state);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/DW/weight2_PE2.hex", input_data_mem2_n_state);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/DW/weight2_PE3.hex", input_data_mem3_n_state);
        
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Reduce/weight4_PE0.hex", input_data_mem0_reduce);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Reduce/weight4_PE1.hex", input_data_mem1_reduce);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Reduce/weight4_PE2.hex", input_data_mem2_reduce);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Reduce/weight4_PE3.hex", input_data_mem3_reduce);

        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Expand/weight5_PE0.hex", input_data_mem0_expand);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Expand/weight5_PE1.hex", input_data_mem1_expand);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Expand/weight5_PE2.hex", input_data_mem2_expand);
        $readmemh("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Expand/weight5_PE3.hex", input_data_mem3_expand);
        run         =   1;
        instrution  =   1;
        fork
            begin
                // Write data into BRAM
                for (i = 0; i < input_size+1; i = i + 4) begin
                    //addr = i >> 2;  // Chia 4 vì mỗi lần lưu 32-bit
                    data_in_IFM = {input_data_mem[uut.wr_addr_IFM*4], input_data_mem[uut.wr_addr_IFM*4+1], input_data_mem[uut.wr_addr_IFM*4+2], input_data_mem[uut.wr_addr_IFM*4+3]};

                    #10;
                end
                wr_rd_en_IFM = 0;
            end
            begin
                for (j = 0; j < IFM_C_layer1*KERNEL_W_layer1*KERNEL_W_layer1*tile +1; j = j + 4) begin

                    addr <= j >> 2;  // Chia 4 vì mỗi lần lưu 32-bit
                    data_in_Weight_0 = {input_data_mem0 [addr*4], input_data_mem0[addr*4+1], input_data_mem0[addr*4+2], input_data_mem0[addr*4+3]};
                    data_in_Weight_1 = {input_data_mem1 [addr*4], input_data_mem1[addr*4+1], input_data_mem1[addr*4+2], input_data_mem1[addr*4+3]};
                    data_in_Weight_2 = {input_data_mem2 [addr*4], input_data_mem2[addr*4+1], input_data_mem2[addr*4+2], input_data_mem2[addr*4+3]};
                    data_in_Weight_3 = {input_data_mem3 [addr*4], input_data_mem3[addr*4+1], input_data_mem3[addr*4+2], input_data_mem3[addr*4+3]};
                    data_in_Weight_4 = {input_data_mem4 [addr*4], input_data_mem4[addr*4+1], input_data_mem4[addr*4+2], input_data_mem4[addr*4+3]};
                    data_in_Weight_5 = {input_data_mem5 [addr*4], input_data_mem5[addr*4+1], input_data_mem5[addr*4+2], input_data_mem5[addr*4+3]};
                    data_in_Weight_6 = {input_data_mem6 [addr*4], input_data_mem6[addr*4+1], input_data_mem6[addr*4+2], input_data_mem6[addr*4+3]};
                    data_in_Weight_7 = {input_data_mem7 [addr*4], input_data_mem7[addr*4+1], input_data_mem7[addr*4+2], input_data_mem7[addr*4+3]};
                    data_in_Weight_8 = {input_data_mem8 [addr*4], input_data_mem8[addr*4+1], input_data_mem8[addr*4+2], input_data_mem8[addr*4+3]};
                    data_in_Weight_9 = {input_data_mem9 [addr*4], input_data_mem9[addr*4+1], input_data_mem9[addr*4+2], input_data_mem9[addr*4+3]};
                    data_in_Weight_10 = {input_data_mem10[addr*4], input_data_mem10[addr*4+1], input_data_mem10[addr*4+2], input_data_mem10[addr*4+3]};
                    data_in_Weight_11 = {input_data_mem11[addr*4], input_data_mem11[addr*4+1], input_data_mem11[addr*4+2], input_data_mem11[addr*4+3]};
                    data_in_Weight_12 = {input_data_mem12[addr*4], input_data_mem12[addr*4+1], input_data_mem12[addr*4+2], input_data_mem12[addr*4+3]};
                    data_in_Weight_13 = {input_data_mem13[addr*4], input_data_mem13[addr*4+1], input_data_mem13[addr*4+2], input_data_mem13[addr*4+3]};
                    data_in_Weight_14 = {input_data_mem14[addr*4], input_data_mem14[addr*4+1], input_data_mem14[addr*4+2], input_data_mem14[addr*4+3]};
                    data_in_Weight_15 = {input_data_mem15[addr*4], input_data_mem15[addr*4+1], input_data_mem15[addr*4+2], input_data_mem15[addr*4+3]};

                    wr_rd_en_Weight = 1;
                    #10;
                end
                wr_rd_en_Weight = 0;
            end
            begin
                for (k2 = 0; k2 < KERNEL_W_layer2_para*KERNEL_W_layer2_para*num_of_tiles_for_PE_layer2 +1; k2 = k2 + 1) begin

                    addr_Wei_layer2 <= k2;  // Chia 4 vì mỗi lần lưu 32-bit
                    data_in_Weight_0_n_state = {input_data_mem0_n_state [k2]};
                    data_in_Weight_1_n_state = {input_data_mem1_n_state [k2]};
                    data_in_Weight_2_n_state = {input_data_mem2_n_state [k2]};
                    data_in_Weight_3_n_state = {input_data_mem3_n_state [k2]};
                    wr_rd_en_Weight_layer2 = 1;
                    #10;
                end
                wr_rd_en_Weight_layer2 = 0;
            end
            begin
                for (k4 = 0; k4 < OFM_C_layer2_para* (OFM_C_se_reduce_para/`Num_of_layer2_PE_para) +1; k4 = k4 + 4) begin

                    addr_Wei_layer_reduce   <= k4 >>2;  // Chia 4 vì mỗi lần lưu 32-bit
                    data_in_Weight_0_reduce = {input_data_mem0_reduce [k4+3],input_data_mem0_reduce [k4+2],input_data_mem0_reduce [k4+1],input_data_mem0_reduce [k4+0]};
                    data_in_Weight_1_reduce = {input_data_mem1_reduce [k4+3],input_data_mem1_reduce [k4+2],input_data_mem1_reduce [k4+1],input_data_mem1_reduce [k4+0]};
                    data_in_Weight_2_reduce = {input_data_mem2_reduce [k4+3],input_data_mem2_reduce [k4+2],input_data_mem2_reduce [k4+1],input_data_mem2_reduce [k4+0]};
                    data_in_Weight_3_reduce = {input_data_mem3_reduce [k4+3],input_data_mem3_reduce [k4+2],input_data_mem3_reduce [k4+1],input_data_mem3_reduce [k4+0]};
                    wr_rd_en_Weight_layer_reduce = 1;
                    #10;
                end
                wr_rd_en_Weight_layer_reduce = 0;
            end
            begin
                for (k5 = 0; k5 < OFM_C_layer2_para* (OFM_C_se_reduce_para/`Num_of_layer2_PE_para) +1; k5 = k5 + 4) begin

                    addr_Wei_layer_expand   <= k5 >>2;  // Chia 4 vì mỗi lần lưu 32-bit
                    data_in_Weight_0_expand = {input_data_mem0_expand [k5+3],input_data_mem0_expand [k5+2],input_data_mem0_expand [k5+1],input_data_mem0_expand [k5+0]};
                    data_in_Weight_1_expand = {input_data_mem1_expand [k5+3],input_data_mem1_expand [k5+2],input_data_mem1_expand [k5+1],input_data_mem1_expand [k5+0]};
                    data_in_Weight_2_expand = {input_data_mem2_expand [k5+3],input_data_mem2_expand [k5+2],input_data_mem2_expand [k5+1],input_data_mem2_expand [k5+0]};
                    data_in_Weight_3_expand = {input_data_mem3_expand [k5+3],input_data_mem3_expand [k5+2],input_data_mem3_expand [k5+1],input_data_mem3_expand [k5+0]};
                    wr_rd_en_Weight_layer_expand = 1;
                    #10;
                end
                wr_rd_en_Weight_layer_expand = 0;
            end
            
        join

        repeat (1) @(posedge uut.done_compute_Conv1x1);
        // @(posedge uut.done_compute_layer2);
        // #10000;
        //$finish;
        
        @(posedge uut.wr_rd_req_IFM);
        begin : load_weight_for_last_conv
                for (k7 = 0; k7 < OFM_C_layer2_para*KERNEL_W_layer1*KERNEL_W_layer1*tile_2 +24; k7 = k7 + 4) begin

                    //addr <= k7 >> 2;  // Chia 4 vì mỗi lần lưu 32-bit
                    data_in_Weight_0 = {input_data_mem0_2 [uut.wr_addr_Weight*4+3], input_data_mem0_2[uut.wr_addr_Weight*4+2], input_data_mem0_2[uut.wr_addr_Weight*4+1], input_data_mem0_2[uut.wr_addr_Weight*4+0]};
                    data_in_Weight_1 = {input_data_mem1_2[uut.wr_addr_Weight*4+3], input_data_mem1_2[uut.wr_addr_Weight*4+2], input_data_mem1_2[uut.wr_addr_Weight*4+1], input_data_mem1_2[uut.wr_addr_Weight*4+0]};
                    data_in_Weight_2 = {input_data_mem2_2[uut.wr_addr_Weight*4+3], input_data_mem2_2[uut.wr_addr_Weight*4+2], input_data_mem2_2[uut.wr_addr_Weight*4+1], input_data_mem2_2[uut.wr_addr_Weight*4+0]};
                    data_in_Weight_3 = {input_data_mem3_2[uut.wr_addr_Weight*4+3], input_data_mem3_2[uut.wr_addr_Weight*4+2], input_data_mem3_2[uut.wr_addr_Weight*4+1], input_data_mem3_2[uut.wr_addr_Weight*4+0]};
                    data_in_Weight_4 = {input_data_mem4_2[uut.wr_addr_Weight*4+3], input_data_mem4_2[uut.wr_addr_Weight*4+2], input_data_mem4_2[uut.wr_addr_Weight*4+1], input_data_mem4_2[uut.wr_addr_Weight*4+0]};
                    data_in_Weight_5 = {input_data_mem5_2[uut.wr_addr_Weight*4+3], input_data_mem5_2[uut.wr_addr_Weight*4+2], input_data_mem5_2[uut.wr_addr_Weight*4+1], input_data_mem5_2[uut.wr_addr_Weight*4+0]};
                    data_in_Weight_6 = {input_data_mem6_2[uut.wr_addr_Weight*4+3], input_data_mem6_2[uut.wr_addr_Weight*4+2], input_data_mem6_2[uut.wr_addr_Weight*4+1], input_data_mem6_2[uut.wr_addr_Weight*4+0]};
                    data_in_Weight_7 = {input_data_mem7_2[uut.wr_addr_Weight*4+3], input_data_mem7_2[uut.wr_addr_Weight*4+2], input_data_mem7_2[uut.wr_addr_Weight*4+1], input_data_mem7_2[uut.wr_addr_Weight*4+0]};
                    data_in_Weight_8 = {input_data_mem8_2[uut.wr_addr_Weight*4+3], input_data_mem8_2[uut.wr_addr_Weight*4+2], input_data_mem8_2[uut.wr_addr_Weight*4+1], input_data_mem8_2[uut.wr_addr_Weight*4+0]};
                    data_in_Weight_9 = {input_data_mem9_2[uut.wr_addr_Weight*4+3], input_data_mem9_2[uut.wr_addr_Weight*4+2], input_data_mem9_2[uut.wr_addr_Weight*4+1], input_data_mem9_2[uut.wr_addr_Weight*4+0]};
                    data_in_Weight_10 = {input_data_mem10_2[uut.wr_addr_Weight*4+3], input_data_mem10_2[uut.wr_addr_Weight*4+2], input_data_mem10_2[uut.wr_addr_Weight*4+1], input_data_mem10_2[uut.wr_addr_Weight*4+0]};
                    data_in_Weight_11 = {input_data_mem11_2[uut.wr_addr_Weight*4+3], input_data_mem11_2[uut.wr_addr_Weight*4+2], input_data_mem11_2[uut.wr_addr_Weight*4+1], input_data_mem11_2[uut.wr_addr_Weight*4+0]};
                    data_in_Weight_12 = {input_data_mem12_2[uut.wr_addr_Weight*4+3], input_data_mem12_2[uut.wr_addr_Weight*4+2], input_data_mem12_2[uut.wr_addr_Weight*4+1], input_data_mem12_2[uut.wr_addr_Weight*4+0]};
                    data_in_Weight_13 = {input_data_mem13_2[uut.wr_addr_Weight*4+3], input_data_mem13_2[uut.wr_addr_Weight*4+2], input_data_mem13_2[uut.wr_addr_Weight*4+1], input_data_mem13_2[uut.wr_addr_Weight*4+0]};
                    data_in_Weight_14 = {input_data_mem14_2[uut.wr_addr_Weight*4+3], input_data_mem14_2[uut.wr_addr_Weight*4+2], input_data_mem14_2[uut.wr_addr_Weight*4+1], input_data_mem14_2[uut.wr_addr_Weight*4+0]};
                    data_in_Weight_15 = {input_data_mem15_2[uut.wr_addr_Weight*4+3], input_data_mem15_2[uut.wr_addr_Weight*4+2], input_data_mem15_2[uut.wr_addr_Weight*4+1], input_data_mem15_2[uut.wr_addr_Weight*4+0]};

                    wr_rd_en_Weight = 1;
                    #10;
                end
                wr_rd_en_Weight = 0;
        end

        @(posedge clk);
        for ( k3 = 0;k3 < (OFM_W_layer1+2)*(OFM_W_layer1+2)*OFM_C_layer2_para ; k3 = k3+4 ) begin
            addr_IFM_layer_2 = k3;
                    #10;
            //for ( k4=0; k4<4 ; k4+1) begin
            $fwrite(padding_data, "%h\n", uut.IFM_data_check_padding[7:0]);  // Ghi giá trị từng byte vào file
            $fwrite(padding_data, "%h\n", uut.IFM_data_check_padding[15:8]);  // Ghi giá trị từng byte vào file
            $fwrite(padding_data, "%h\n", uut.IFM_data_check_padding[23:16]);  // Ghi giá trị từng byte vào file
            $fwrite(padding_data, "%h\n", uut.IFM_data_check_padding[31:24]);  // Ghi giá trị từng byte vào file

            
        end   
        k3=0;
    //  #100000;
    //      $finish;
        addr_IFM_layer_2=0; 
        //PE_finish = 0;
        @(posedge uut.done_compute_Conv1x1);
        #10;
        $finish;
        #10;
        $finish;
        #10;
        $finish;
        #10;
        $finish;
    end
    initial begin
        for (k = 0; k < 16; k = k + 1) begin
            if (`GOL1) ofm_file[k] = $fopen($sformatf("../Fused-Block-CNN/address/OFM1_PE%0d_DUT.hex", k), "w");
            else    ofm_file[k] = $fopen($sformatf("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/OFM1_PE%0d_DUT.hex", k), "w");
            if (ofm_file[k] == 0) begin
                $display("Error opening file OFM_PE%d.hex", k); 
                $finish;  
            end
        end

        for (m = 0; m < 4; m = m + 1) begin
            ofm_file_2[m] = $fopen($sformatf("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/DW/OFM2_PE%0d_DUT_DW.hex", m), "w");
            if (ofm_file_2[m] == 0) begin
                $display("Error opening file OFM%d.hex", k);
                $finish;  
            end
        end

        ofm_file_3 = $fopen($sformatf("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Average_Pooling/ofm_3_DUT.hex"), "w");
        if (ofm_file_3 == 0) begin
            $display("Error opening file OFM%d.hex", k);
            $finish;  
        end
        

        padding_data= $fopen($sformatf("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/DW/PADDING_control_IFM.hex"), "w");
        if (padding_data == 0) begin
            $display("Error opening file", k);
            $finish;  
        end


        ofm_file_4 = $fopen($sformatf("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Reduce/OFM4_DUT_SE.hex"), "w");
        if (ofm_file_4== 0) begin
            $display("Error opening file OFM%d.hex", k);
            $finish;  
            
        end

        for (k8 = 0; k8 < 4; k8 = k8 + 1) begin
            ofm_file_5[k8] = $fopen($sformatf("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Expand/OFM5_PE%0d_DUT_SE.hex", k8), "w");
            if (ofm_file_5[m] == 0) begin
                $display("Error opening file OFM%d.hex", k);
                $finish;  
            end
        end

        // ofm_file_6= $fopen($sformatf("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Multiply/ofm_multiply_DUT.hex"), "w");
        // if (ofm_file_6 == 0) begin
        //     $display("Error opening file", k);
        //     $finish;  
        // end

        for (j0 = 0; j0 < 16; j0 = j0 + 1) begin
            ofm_file_8[j0] = $fopen($sformatf("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/OFM6_PE%0d_DUT.hex", j0), "w");
            if (ofm_file_8[j0] == 0) begin
                $display("Error opening file OFM%d.hex", k);
                $finish;  
            end
        end

    end
   //assign wr_rd_req_IFM_layer_2 = 1;
   assign write_padding = (uut.finish_for_PE_cluster_layer1 == 16'hFFFF) ? 1 : 0;
   assign wr_addr_IFM_layer_2 = (uut.finish_for_PE_cluster_layer1 == 16'hFFFF) ? data_addr_layer_2 : padding_addr/4; 

    initial begin
        forever begin
        @ (posedge clk)
        if(data_addr_layer_2 > End_addr_for_data_layer_2/4-4) begin
                //addr_IFM_layer_2 = addr_IFM_layer_2 + 4;
                wr_rd_req_IFM_layer_2 = 0;
            end
        if(uut.cal_start_ctl) begin
        if(uut.finish_for_PE_cluster_layer1 == 16'hFFFF) begin
            valid_for_next_pipeline = 0;
            count_valid_for_dw = count_valid_for_dw + 16;
            if(count_valid_for_dw == OFM_C_layer1_para * (IFM_W_layer1_para + 2) ) begin
                count_line = count_line + 1;
                count_line_pipelined = count_line_pipelined + 1;
                count_valid_for_dw = 0;
                if(count_line > 2) begin
                    if(count_line_pipelined > 1 ) begin
                        valid_for_next_pipeline = 1;
                        count_line_pipelined =0;
                    end
                end
            end
            //wr_rd_req_IFM_layer_2 = 1;
            //addr_IFM_layer_2 <= data_addr_layer_2;
            if(count_row < enter_row_data - 16) begin
                data_addr_layer_2 = data_addr_layer_2 + 4;
                count_row = count_row + 16;
            end else
            begin
                data_addr_layer_2 = data_addr_layer_2 + inc_addr_for_enter_row /4+ 4 ;
                count_row = 0;
            end
            @ (posedge clk );
            //wr_rd_req_IFM_layer_2 = 0;
        end 
        else begin
            
            if((padding_addr >= Start_addr_for_data_layer_2 - 16) && (padding_addr <= End_addr_for_data_layer_2)) begin
                if(((padding_addr + 16)%OFM_C_layer1_para) || !((padding_addr + 16)%(30*OFM_C_layer1_para)) ) padding_addr = padding_addr +16 ;
                else padding_addr = padding_addr + enter_row_data + 16;
            end
            else begin
                if(padding_addr <= End_addr_for_data_layer_2 + OFM_C_layer1_para*(IFM_W_layer1_para+3))
                    padding_addr = padding_addr + 16;
                else begin
                    //wr_rd_req_IFM_layer_2 = 0;
                end
            end
        end
        end
        end
    end
always @(posedge clk) begin
    if (uut.finish_for_PE_cluster_layer1 == 16'hFFFF  && (uut.current_state_SE_layer!= 'd3) ) begin
        // Lưu giá trị OFM vào các file tương ứng
        count_for_layer_1 = count_for_layer_1 + 1;
        for (k = 0; k < 16; k = k + 1) begin
            ofm_data = OFM_out[k];  // Lấy giá trị OFM từ output
            // Ghi từng byte của OFM vào các file
            ofm_data_byte = ofm_data;
            //if (ofm_file[1] != 0) begin
            //$display("check");
                $fwrite(ofm_file[k], "%h\n", ofm_data_byte);  // Ghi giá trị từng byte vào file
                
           // end
            ofm_data = ofm_data >> 8;  // Dịch 8 bit cho đến khi hết 32-bit
        end
    end
end

always @(posedge clk) begin
    if ((uut.finish_for_PE_cluster_layer1 == 16'hFFFF) && (uut.current_state_SE_layer== 'd3)) begin
        for (j1 = 0; j1 < 16; j1 = j1 + 1) begin

            $fwrite(ofm_file_8[j1], "%h\n", OFM_out[j1]);  // Ghi giá trị từng byte vào file

        end
    end
end


always @(posedge clk) begin
    if (uut.finish_for_PE_cluster_layer2 == 1) begin
        // Lưu giá trị OFM vào các file tương ứng
        count_for_layer_2 = count_for_layer_2 + 1;
        for (k1 = 0; k1 < 4; k1 = k1 + 1) begin
            ofm_data_2 = OFM_DW[k1];  // Lấy giá trị OFM từ output
            // Ghi từng byte của OFM vào các file
            ofm_data_byte_2 = ofm_data_2;
            //if (ofm_file[1] != 0) begin
            //$display("check");
                $fwrite(ofm_file_2[k1], "%h\n", ofm_data_byte_2);  // Ghi giá trị từng byte vào file
                //$display("check");
                
           // end
            ofm_data_2 = ofm_data_2 >> 8;  // Dịch 8 bit cho đến khi hết 32-bit
        end
    end
end




always @(posedge clk) begin
    if (uut.finish_for_PE_SE_cluster == 1 && (uut.current_state_SE_layer == 1)) begin
        // Lưu giá trị OFM vào các file tương ứng
        $fwrite(ofm_file_4, "%h\n", OFM_SE[0]);  // Ghi giá trị từng byte vào file
        $fwrite(ofm_file_4, "%h\n", OFM_SE[1]);  // Ghi giá trị từng byte vào file
        $fwrite(ofm_file_4, "%h\n", OFM_SE[2]);  // Ghi giá trị từng byte vào file
        $fwrite(ofm_file_4, "%h\n", OFM_SE[3]);  // Ghi giá trị từng byte vào file
    end
end

always @(posedge clk) begin
    if (uut.finish_for_PE_SE_cluster == 1 && (uut.current_state_SE_layer == 2)) begin
        for (k9 = 0; k9 < 4; k9 = k9 + 1) begin
        // Lưu giá trị OFM vào các file tương ứng
        $fwrite(ofm_file_5[k9], "%h\n", OFM_SE[k9]);  // Ghi giá trị từng byte vào file
        end
    end
end

// always @(posedge clk) begin
//     if (valid_layer2 == 1) begin
//                 $fwrite(ofm_3_DUT, "%h\n", data_pooling_average[39:32]);  // Ghi giá trị từng byte vào file
//         end
    
// end

//initial for pooling
    initial begin
        forever begin
            @(posedge clk) begin
                if((uut.finish_for_PE_cluster_layer2 == 1)) begin
                    
                   // if ( count_init_for_pooling < OFM_W_layer2_para *OFM_W_layer2_para *OFM_C_layer2_para / 4) begin
                        count_init_for_pooling = count_init_for_pooling + 1;
                        if(count_init_for_pooling > 48  ) init_phase_pooling = 0;
                        @(posedge clk);
                        we_pooling = 1;
                        read_addr_pooling = read_addr_pooling + 1;
                        write_addr_pooling = read_addr_pooling - 1;
                        control_data_pooling = 0;
                        @(posedge clk);
                        read_addr_pooling = read_addr_pooling + 1;
                        write_addr_pooling = read_addr_pooling - 1;
                        control_data_pooling = 1;
                        @(posedge clk);
                        read_addr_pooling = read_addr_pooling + 1;
                        write_addr_pooling = read_addr_pooling - 1;
                        control_data_pooling = 2;
                        @(posedge clk);
                        read_addr_pooling = read_addr_pooling + 1;
                        write_addr_pooling = read_addr_pooling - 1;
                        control_data_pooling = 3;
                        @(posedge clk);
                        we_pooling = 0;
                        if(read_addr_pooling == OFM_C_layer2_para) read_addr_pooling = 0;

                    // end else begin
                    //     count_init_for_pooling =0;
                    // end
                end else begin
                    if ( count_init_for_pooling >(OFM_W_layer2_para *OFM_W_layer2_para *OFM_C_layer2_para / 4) -1) begin
                         if (init_phase_pooling) count_init_for_pooling =0;
                    end
                end
            end
        end
    end

    initial begin
        forever begin
            @(posedge clk) begin
                if(uut.done_compute_layer2 == 1) begin
                    repeat(10) @(posedge clk);
                    read_addr_pooling = 0;
                    init_phase_pooling<=1;
                repeat(OFM_C_layer2_para+1)  
                begin   @(posedge clk) 
                    if (read_addr_pooling !=0) $fwrite(ofm_file_3, "%h\n", uut.data_pooling_average[39:32]);  // Ghi giá trị từng byte vào file
                     read_addr_pooling = read_addr_pooling + 1;
                     //$display("check");
                end
            end
            end
        end
    end
    
    
    
    //intial for PE_SE_BRAM
    initial begin
        forever begin
            @(posedge clk) begin
                if((uut.finish_for_PE_cluster_layer2 == 1)) begin
                    addr_wr_pre_SE = addr_wr_pre_SE + 1;
                   // if ( count_init_for_pooling < OFM_W_layer2_para *OFM_W_layer2_para *OFM_C_layer2_para / 4) begin
                        
                end 
              end
            end
        end
    
    initial begin
        forever begin
            @(posedge clk) begin
                if((uut.done_compute_SE == 1)) begin
                    start_mutiple = start_mutiple + 1;
                   // if ( count_init_for_pooling < OFM_W_layer2_para *OFM_W_layer2_para *OFM_C_layer2_para / 4) begin
                end 
                if(start_mutiple == 2) begin
                    start_mutiple_for_dut = 1;
                    addr_wr_pre_SE = addr_rd_pre_SE/4;
                    multiply_we_back = 1;
                    addr_rd_mul = addr_rd_mul + 4;
                    addr_rd_pre_SE = addr_rd_pre_SE + 4;
                    if(addr_rd_mul > OFM_C_layer1_para - 4) begin
                        addr_rd_mul = 0;
                    end
                end
                if(addr_rd_pre_SE >= 14*14*192 + 4) begin
                    addr_rd_pre_SE = -4;
                    start_mutiple = 1;
                    multiply_we_back = 0;
                    repeat(OFM_W_layer2_para*OFM_W_layer2_para*OFM_C_layer2_para/`Num_of_layer2_PE_para +1 ) begin
                        addr_rd_pre_SE = addr_rd_pre_SE + 4;
                        @(posedge clk);
                        $fwrite(ofm_file_6, "%h\n", uut.data_out_multiply[7:0]);  // ofm_multiplt_DUT
                        $fwrite(ofm_file_6, "%h\n", uut.data_out_multiply[15:8]); // ofm_multiplt_DUT
                        $fwrite(ofm_file_6, "%h\n", uut.data_out_multiply[23:16]);// ofm_multiplt_DUT
                        $fwrite(ofm_file_6, "%h\n", uut.data_out_multiply[31:24]); // ofm_multiplt_DUT

                    end
                end
              end
            end
        end
    endmodule