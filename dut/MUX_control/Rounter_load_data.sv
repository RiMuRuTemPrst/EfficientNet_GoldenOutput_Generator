module Rounter_load_data(

    input [31:0] wr_addr_fused,
    input we_fused,
    input[1:0] control_load,

    //input for rount
    input [31:0] size_IFM,
    input [31:0] size_Weight_layer_1,
    input [31:0] size_Weight_layer_2,
    //output to BRAM_IFM and BRAM_Weight
    //Weight
    //write address
    output [31:0] wr_addr_Weight_0_layer2,
    output [31:0] wr_addr_Weight_1_layer2,
    output [31:0] wr_addr_Weight_2_layer2,
    output [31:0] wr_addr_Weight_3_layer2,

    //wr
    output [31:0] wr_Weight_0_layer1,
    output [31:0] wr_Weight_1_layer1,
    output [31:0] wr_Weight_2_layer1,
    output [31:0] wr_Weight_3_layer1,
    output [31:0] wr_Weight_4_layer1,
    output [31:0] wr_Weight_5_layer1,
    output [31:0] wr_Weight_6_layer1,
    output [31:0] wr_Weight_7_layer1,
    output [31:0] wr_Weight_8_layer1,
    output [31:0] wr_Weight_9_layer1,
    output [31:0] wr_Weight_10_layer1,
    output [31:0] wr_Weight_11_layer1,
    output [31:0] wr_Weight_12_layer1,
    output [31:0] wr_Weight_13_layer1,
    output [31:0] wr_Weight_14_layer1,
    output [31:0] wr_Weight_15_layer1,

    //we
    output [31:0] we_Weight_0_layer1,
    output [31:0] we_Weight_1_layer1,
    output [31:0] we_Weight_2_layer1,
    output [31:0] we_Weight_3_layer1,
    output [31:0] we_Weight_4_layer1,
    output [31:0] we_Weight_5_layer1,
    output [31:0] we_Weight_6_layer1,
    output [31:0] we_Weight_7_layer1,
    output [31:0] we_Weight_8_layer1,
    output [31:0] we_Weight_9_layer1,
    output [31:0] we_Weight_10_layer1,
    output [31:0] we_Weight_11_layer1,
    output [31:0] we_Weight_12_layer1,
    output [31:0] we_Weight_13_layer1,
    output [31:0] we_Weight_14_layer1,
    output [31:0] we_Weight_15_layer1,

    output [31:0] we_Weight_0_layer2,
    output [31:0] we_Weight_1_layer2,
    output [31:0] we_Weight_2_layer2,
    output [31:0] we_Weight_3_layer2
);
    parameter NO_LOAD     = 0 ;
    parameter LOAD_WEIGHT_C     = 2 ;
    parameter LOAD_IFM_C     = 1 ;

    logic we_IFM;
    logic we_Weight;
    logic addr_Weight_for_layer_2;
    assign addr_Weight_for_layer_2 = wr_addr_fused - size_Weight_layer_1;
    always_comb begin
        we_IFM = 0;
        we_Weight = 0;
        we_Weight_0_layer1 = 0;
        we_Weight_1_layer1 = 0;
        we_Weight_2_layer1 = 0;
        we_Weight_3_layer1 = 0;
        we_Weight_4_layer1 = 0;
        we_Weight_5_layer1 = 0;
        we_Weight_6_layer1 = 0;
        we_Weight_7_layer1 = 0;
        we_Weight_8_layer1 = 0;
        we_Weight_9_layer1 = 0;
        we_Weight_10_layer1 = 0;
        we_Weight_11_layer1 = 0;
        we_Weight_12_layer1 = 0;
        we_Weight_13_layer1 = 0;
        we_Weight_14_layer1 = 0;
        we_Weight_15_layer1 = 0;

        we_Weight_0_layer2 = 0;
        we_Weight_1_layer2 = 0;
        we_Weight_2_layer2 = 0;
        we_Weight_3_layer2 = 0;

        wr_addr_Weight_0_layer2 = 0;
        wr_addr_Weight_1_layer2 = 0;
        wr_addr_Weight_2_layer2 = 0;
        wr_addr_Weight_3_layer2 = 0;
        //control we IFM and Weight
        if(we_fused) begin
            case(control_load) 
                NO_LOAD : begin
                    we_IFM = 0;
                    we_Weight = 0;
                end
                LOAD_WEIGHT_C : begin
                    we_IFM = 0;
                    we_Weight = 1;
                end
                LOAD_IFM_C : begin
                    we_IFM = 1;
                    we_Weight = 0;
                end
                default : begin
                    we_IFM = 0;
                    we_Weight = 0;
                end
            endcase
        end
        if(wr_addr_fused < size_Weight_layer_1) begin

            if(wr_addr_fused < size_Weight_layer_1 << 16) begin
                we_Weight_0_layer1 = 1;
            end
            else begin
                if((wr_addr_fused - (size_Weight_layer_1) << 16) < size_Weight_layer_1 << 16)
            end

        end
        else begin

            wr_addr_Weight_0_layer2 = addr_Weight_for_layer_2 >> 2;
            wr_addr_Weight_1_layer2 = addr_Weight_for_layer_2 >> 2;
            wr_addr_Weight_2_layer2 = addr_Weight_for_layer_2 >> 2;
            wr_addr_Weight_3_layer2 = addr_Weight_for_layer_2 >> 2;

            case(addr_Weight_for_layer_2[1:0])  
                0:we_Weight_0_layer2 = 1;
                1:we_Weight_1_layer2 = 1;
                2:we_Weight_2_layer2 = 1;
                3:we_Weight_3_layer2 = 1;
            endcase
        end
    end
endmodule
