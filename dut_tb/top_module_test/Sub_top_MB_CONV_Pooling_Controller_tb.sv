`timescale 1ns / 1ps
// input 9x9x16
// kernel 3x3x16x32
// OFM 56x56x32

`define GOL1 1

// `define IFM_W_layer1_para 58
// `define IFM_C_layer1_para 32
// `define KERNEL_W_layer1_para 3
// `define OFM_C_layer1_para 128
// `define stride_layer1_para 2

// `define OFM_C_layer2_para 16

`define Num_of_layer1_PE_para 16
`define Num_of_layer2_PE_para 4

module Sub_top_MB_CONV_Pooling_Controller_tb #(
    parameter IFM_W_layer1_para= 28, 
    parameter IFM_C_layer1_para =48,
    parameter KERNEL_W_layer1_para =1,
    parameter OFM_C_layer1_para= 192,
    parameter stride_layer1_para= 1,

    parameter KERNEL_W_layer2_para =3,
    parameter OFM_C_layer2_para= 192,
    parameter stride_layer2_para =2,
    

    //
    parameter Start_addr_for_data_layer_2 = (IFM_W_layer1_para + 3) * OFM_C_layer1_para,
    parameter enter_row_data = (IFM_W_layer1_para) * OFM_C_layer1_para,
    parameter inc_addr_for_enter_row = 2*OFM_C_layer1_para,
    parameter End_addr_for_data_layer_2 = ((IFM_W_layer1_para + 2)*(IFM_W_layer1_para + 2) - (IFM_W_layer1_para + 3) ) * OFM_C_layer1_para
);
    reg clk;
    reg reset;
    reg wr_rd_en_IFM;
    reg wr_rd_en_Weight;
    reg wr_rd_en_Weight_layer2;
    reg [31:0] addr_Wei_layer2;


    reg [3:0] KERNEL_W_layer1;
    reg [7:0] OFM_C_layer1;
    reg [7:0] OFM_W_layer1;
    reg [7:0] IFM_C_layer1;
    reg [7:0] IFM_W_layer1;
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

    reg [7:0] data_in_Weight_0_n_state;
    reg [7:0] data_in_Weight_1_n_state;
    reg [7:0] data_in_Weight_2_n_state;
    reg [7:0] data_in_Weight_3_n_state;

    //reg [1:0] control_mux;
    //reg       wr_en_next;
    reg [31:0] addr_ram_next_rd;
    //reg [31:0] addr_ram_next_wr;

    wire [3:0] PE_finish_PE_cluster1x1_wire;

    //reg [3:0] PE_next_valid;
    int count_for_layer_1 =0 ;
    int count_for_layer_2 =0;
    int count_GOPS = 0;
    reg [19:0] addr_w[15:0];
    reg [19:0] addr_IFM;
    reg [15:0] PE_reset;
    reg [15:0] PE_finish;
    wire       done_compute_layer1;

    reg       run;
    reg [3:0] instrution;
    wire        wr_rd_req_IFM_for_tb;
    wire [31:0] wr_addr_IFM_for_tb;
    wire        wr_rd_req_Weight_for_tb;
    wire [31:0] wr_addr_Weight_for_tb;
    reg [31:0] addr_w_n_state;
    wire [7:0] OFM_DW [3:0];
    reg [3:0] PE_reset_n_state;
    reg [3:0] PE_reset_n_state_1;

    
    wire [31:0] OFM;
   
    wire [7:0] OFM_out[15:0];
    
    integer i,j,k,m,k1,k2,k3=0;
    integer ofm_file[15:0];  // Mảng để lưu các file handle
    integer ofm_file_2[3:0];
    integer ofm_file_3;
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

    reg [7:0] input_data_mem0_n_state [0:53823]; // BRAM input data
    reg [7:0] input_data_mem1_n_state [0:23030];
    reg [7:0] input_data_mem2_n_state [0:23030];
    reg [7:0] input_data_mem3_n_state [0:23030];


    logic wr_rd_req_IFM_layer_2;
    logic [31:0] IFM_data_layer_2;
    logic [31:0] addr_IFM_layer_2;
    logic [31:0] wr_addr_IFM_layer_2;
    logic write_padding;
    //CAL START
    logic [31:0] padding_addr;
    logic [31:0] data_addr_layer_2;
    reg cal_start;
    wire [15:0] valid ;
    wire        valid_layer2;
    reg [7:0] ofm_data;
    reg [7:0] ofm_data_2;
    reg [7:0] ofm_data_byte;
    reg [7:0] ofm_data_byte_2;


    reg valid_for_next_pipeline;
    wire done_compute_layer2;
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
    logic [31:0] data_pooling_average;
    Sub_top_MB_CONV_Average_Pooling_New uut (
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

        .addr_Wei_layer2(addr_Wei_layer2),
        .cal_start(cal_start),

        //control signal layer 1
        .PE_reset(PE_reset),
        .PE_finish(PE_finish),
        .PE_finish_PE_cluster1x1(PE_finish_PE_cluster1x1_wire),

        .KERNEL_W_layer1(KERNEL_W_layer1),
        .OFM_C_layer1(OFM_C_layer1),
        .OFM_W_layer1(OFM_W_layer1),
        .IFM_C_layer1(IFM_C_layer1),
        .IFM_W_layer1(IFM_W_layer1),
        .stride_layer1(stride_layer1),
        .valid(valid),
        .valid_layer2(valid_layer2),
        .done_compute(done_compute_layer1),

        //layer2
        .KERNEL_W_layer2(KERNEL_W_layer2_para),
        .IFM_C_layer2(OFM_C_layer2_para),
        .OFM_C_layer2(OFM_C_layer2_para),
        .stride_layer2(stride_layer2_para),

        // for Control_unit
        .run(run),
        .instrution(instrution),
        .wr_rd_req_IFM_for_tb(wr_rd_req_IFM_for_tb),
        .wr_addr_IFM_for_tb(wr_addr_IFM_for_tb),
        .wr_rd_req_Weight_for_tb(wr_rd_req_Weight_for_tb),
        .wr_addr_Weight_for_tb(wr_addr_Weight_for_tb),
        
        
        .OFM_0(OFM_out[0]), .OFM_1(OFM_out[1]), .OFM_2(OFM_out[2]), .OFM_3(OFM_out[3]),
        .OFM_4(OFM_out[4]), .OFM_5(OFM_out[5]), .OFM_6(OFM_out[6]), .OFM_7(OFM_out[7]),
        .OFM_8(OFM_out[8]), .OFM_9(OFM_out[9]), .OFM_10(OFM_out[10]), .OFM_11(OFM_out[11]),
        .OFM_12(OFM_out[12]), .OFM_13(OFM_out[13]), .OFM_14(OFM_out[14]), .OFM_15(OFM_out[15]),



        .PE_reset_n_state(PE_reset_n_state),
       //.addr_w_n_state(addr_w_n_state),

       // layer 2
        .wr_rd_req_IFM_layer_2(wr_rd_req_IFM_layer_2),
        .IFM_data_layer_2(IFM_data_layer_2),
        .addr_IFM_layer_2(addr_IFM_layer_2),
        .wr_addr_IFM_layer_2(wr_addr_IFM_layer_2),
        .write_padding(write_padding),
        .valid_for_next_pipeline(valid_for_next_pipeline),
        .done_compute_layer2(done_compute_layer2),
        //.rd_addr(addr_w)

        //pooling average
        .read_addr_pooling(read_addr_pooling),
        .write_addr_pooling(write_addr_pooling),
        .init_phase_pooling(init_phase_pooling),
        .control_data_pooling(control_data_pooling),
        .we_pooling(we_pooling),
        .data_pooling_average(data_pooling_average)
    );
    pooling_controller pooling_controller_inst (
        .clk(clk),
        .rst_n(reset),
        .valid_layer2(valid_layer2),
        .init_phase_pooling(init_phase_pooling),
        .we_pooling(we_pooling),
        .control_data_pooling(control_data_pooling),

        .read_addr_pooling(read_addr_pooling),
        .write_addr_pooling(write_addr_pooling)
    );
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    int input_size = IFM_W_layer1_para*IFM_W_layer1_para*IFM_C_layer1_para;
    int tile = OFM_C_layer1_para/`Num_of_layer1_PE_para;
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
        data_in_Weight_3 = 0;
        data_in_Weight_4 = 0;
        data_in_Weight_5 = 0;
        data_in_Weight_6 = 0;
        data_in_Weight_7 = 0;
        data_in_Weight_8 = 0;
        data_in_Weight_9 = 0;
        data_in_Weight_10 = 0;
        data_in_Weight_11 = 0;
        data_in_Weight_12 = 0;
        data_in_Weight_13 = 0;       
        data_in_Weight_14 = 0;
        data_in_Weight_15 = 0;

        data_in_Weight_0_n_state=0;
        data_in_Weight_1_n_state=0;
        data_in_Weight_2_n_state=0;
        data_in_Weight_3_n_state=0;

        addr_Wei_layer2 =0;
        
        //wr_rd_req_IFM_layer_2 = 0;
        //IFM_data_layer_2 = 0;
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

        num_of_tiles_for_PE_layer2 = OFM_C_layer2_para/ `Num_of_layer2_PE_para;
       // write_padding = 1;
        //addr_ram_next_wr = -1;
        //wr_en_next = 0;

        // Load input data from file (example: input_data.hex)
       //$readmemh("C:/Users/Admin/OneDrive - Hanoi University of Science and Technology/Desktop/CNN/Fused-Block-CNN/../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/input_56x56x16_pad.hex", input_data_mem);
        //
        if(`GOL1) begin
        $readmemh("../Fused-Block-CNN/address/ifm_padded.hex", input_data_mem);

        $readmemh("../Fused-Block-CNN/address/weight_PE0.hex", input_data_mem0);
        $readmemh("../Fused-Block-CNN/address/weight_PE1.hex", input_data_mem1);
        $readmemh("../Fused-Block-CNN/address/weight_PE2.hex", input_data_mem2);
        $readmemh("../Fused-Block-CNN/address/weight_PE3.hex", input_data_mem3);
        $readmemh("../Fused-Block-CNN/address/weight_PE4.hex", input_data_mem4);
        $readmemh("../Fused-Block-CNN/address/weight_PE5.hex", input_data_mem5);
        $readmemh("../Fused-Block-CNN/address/weight_PE6.hex", input_data_mem6);
        $readmemh("../Fused-Block-CNN/address/weight_PE7.hex", input_data_mem7);
        $readmemh("../Fused-Block-CNN/address/weight_PE8.hex", input_data_mem8);
        $readmemh("../Fused-Block-CNN/address/weight_PE9.hex", input_data_mem9);
        $readmemh("../Fused-Block-CNN/address/weight_PE10.hex", input_data_mem10);
        $readmemh("../Fused-Block-CNN/address/weight_PE11.hex", input_data_mem11);
        $readmemh("../Fused-Block-CNN/address/weight_PE12.hex", input_data_mem12);
        $readmemh("../Fused-Block-CNN/address/weight_PE13.hex", input_data_mem13);
        $readmemh("../Fused-Block-CNN/address/weight_PE14.hex", input_data_mem14);
        $readmemh("../Fused-Block-CNN/address/weight_PE15.hex", input_data_mem15);
        end
        else begin
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/ifm.hex", input_data_mem);

        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight1_PE0.hex", input_data_mem0);
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight1_PE1.hex", input_data_mem1);
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight1_PE2.hex", input_data_mem2);
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight1_PE3.hex", input_data_mem3);
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight1_PE4.hex", input_data_mem4);
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight1_PE5.hex", input_data_mem5);
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight1_PE6.hex", input_data_mem6);
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight1_PE7.hex", input_data_mem7);
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight1_PE8.hex", input_data_mem8);
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight1_PE9.hex", input_data_mem9);
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight1_PE10.hex", input_data_mem10);
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight1_PE11.hex", input_data_mem11);
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight1_PE12.hex", input_data_mem12);
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight1_PE13.hex", input_data_mem13);
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight1_PE14.hex", input_data_mem14);
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight1_PE15.hex", input_data_mem15);

        end
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight2_PE0.hex", input_data_mem0_n_state);
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight2_PE1.hex", input_data_mem1_n_state);
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight2_PE2.hex", input_data_mem2_n_state);
        $readmemh("../Fused-Block-CNN/golden_out_fused_block/weight_hex_folder/weight2_PE3.hex", input_data_mem3_n_state);
        run         =   1;
        instrution  =   1;
        fork
            begin
                // Write data into BRAM
                for (i = 0; i < input_size+1; i = i + 4) begin
                    //addr = i >> 2;  // Chia 4 vì mỗi lần lưu 32-bit
                    data_in_IFM = {input_data_mem[wr_addr_IFM_for_tb*4], input_data_mem[wr_addr_IFM_for_tb*4+1], input_data_mem[wr_addr_IFM_for_tb*4+2], input_data_mem[wr_addr_IFM_for_tb*4+3]};

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
        join

        @(posedge done_compute_layer2);
        @(posedge clk);
        for ( k3 = 0;k3 < (OFM_W_layer1+2)*(OFM_W_layer1+2)*OFM_C_layer2_para ; k3 = k3+4 ) begin
                    addr_IFM_layer_2 = k3;
                    #10;
            //for ( k4=0; k4<4 ; k4+1) begin
            $fwrite(ofm_file_3, "%h\n", IFM_data_layer_2[7:0]);  // Ghi giá trị từng byte vào file
             $fwrite(ofm_file_3, "%h\n", IFM_data_layer_2[15:8]);  // Ghi giá trị từng byte vào file
              $fwrite(ofm_file_3, "%h\n", IFM_data_layer_2[23:16]);  // Ghi giá trị từng byte vào file
               $fwrite(ofm_file_3, "%h\n", IFM_data_layer_2[31:24]);  // Ghi giá trị từng byte vào file

            
        end   
        k3=0;
        addr_IFM_layer_2=0; 
        PE_finish = 0;
    #100000;
        $finish;
    end
    initial begin
        for (k = 0; k < 16; k = k + 1) begin
            if (`GOL1) ofm_file[k] = $fopen($sformatf("../Fused-Block-CNN/address/OFM_PE%0d_DUT.hex", k), "w");
            else    ofm_file[k] = $fopen($sformatf("../Fused-Block-CNN/golden_out_fused_block/output_hex_folder/OFM1_PE%0d_DUT.hex", k), "w");
            if (ofm_file[k] == 0) begin
                $display("Error opening file OFM_PE%d.hex", k); 
                $finish;  
            end
        end

         for (m = 0; m < 4; m = m + 1) begin
             ofm_file_2[m] = $fopen($sformatf("../Fused-Block-CNN/address/OFM_DW_PE%0d_DUT_DW.hex", m), "w");
             if (ofm_file_2[m] == 0) begin
                 $display("Error opening file OFM%d.hex", k);
                 $finish;  
             end
         end

             ofm_file_3= $fopen($sformatf("../Fused-Block-CNN/address/PADDING_control_IFM.hex"), "w");
             if (ofm_file_3 == 0) begin
                 $display("Error opening file", k);
                 $finish;  
             end
    end
   //assign wr_rd_req_IFM_layer_2 = 1;
   assign write_padding = (valid == 16'hFFFF) ? 1 : 0;
   assign wr_addr_IFM_layer_2 = (valid == 16'hFFFF) ? data_addr_layer_2 : padding_addr/4; 

    initial begin
        forever begin
        @ (posedge clk)
        if(data_addr_layer_2 > End_addr_for_data_layer_2/4-4) begin
                //addr_IFM_layer_2 = addr_IFM_layer_2 + 4;
                wr_rd_req_IFM_layer_2 = 0;
            end
        if(uut.cal_start_ctl) begin
        if(valid == 16'hFFFF) begin
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
    if (valid == 16'hFFFF) begin
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
// always @(posedge clk) begin
//     if (done_compute_layer1 == 1) begin
//         // Lưu giá trị OFM vào các file tương ứng
       
//     end
// end


always @(posedge clk) begin
    if (valid == 16'hFFFF) begin
        // Lưu giá trị OFM vào các file tương ứng

                

    end
end


// always @(posedge clk) begin
//     if (valid_layer2 == 1) begin
//         pixel_index = pixel_index + 4;
//         if( pixel_index > OFM_C_layer2_para - 4) pixel_index = 0;
//         // Lưu giá trị OFM vào các file tương ứng
//         count_for_layer_2 = count_for_layer_2 + 1;
//         for (k1 = 0; k1 < 4; k1 = k1 + 1) begin
//             ofm_data_2 = OFM_DW[k1];  // Lấy giá trị OFM từ output
//             // Ghi từng byte của OFM vào các file
//             ofm_data_byte_2 = ofm_data_2;
//             //if (ofm_file[1] != 0) begin
//             //$display("check");
//                 $fwrite(ofm_file_2[k1], "%h\n", ofm_data_byte_2);  // Ghi giá trị từng byte vào file
//                 //$display("check");
                
//            // end
//             ofm_data_2 = ofm_data_2 >> 8;  // Dịch 8 bit cho đến khi hết 32-bit
//         end
//     end
// end

    //initial for pooling
    // initial begin
    //     forever begin
    //         @(posedge clk) begin
    //             if((valid_layer2 == 1)) begin
    //             count_init_for_pooling = count_init_for_pooling + 1;
    //              if(count_init_for_pooling > 48  ) init_phase_pooling = 0;
    //              @(posedge clk);
    //              we_pooling = 1;
    //              read_addr_pooling = read_addr_pooling + 1;
    //              write_addr_pooling = read_addr_pooling - 1;
    //              control_data_pooling = 0;
    //              @(posedge clk);
    //              read_addr_pooling = read_addr_pooling + 1;
    //              write_addr_pooling = read_addr_pooling - 1;
    //              control_data_pooling = 1;
    //              @(posedge clk);
    //              read_addr_pooling = read_addr_pooling + 1;
    //              write_addr_pooling = read_addr_pooling - 1;
    //              control_data_pooling = 2;
    //              @(posedge clk);
    //              read_addr_pooling = read_addr_pooling + 1;
    //              write_addr_pooling = read_addr_pooling - 1;
    //              control_data_pooling = 3;
    //              @(posedge clk);
    //              we_pooling = 0;
    //              if(read_addr_pooling == 192) read_addr_pooling = 0;
    //             end
    //         end
    //     end
    // end

    initial begin
        forever begin
            @(posedge clk) begin
                if(done_compute_layer2 == 1) begin
                    repeat(10) @(posedge clk);
                    read_addr_pooling = 0;
                repeat(192)  
                begin   @(posedge clk) 
                     read_addr_pooling = read_addr_pooling + 1;
                     $display("check");
                end
            end
            end
        end
    end


                
endmodule