module Pooling_average_BRAM(
    input clk,
    input reset_n,
    
    //data signal
    input [31:0] data_in,

    //control signal
    input [31:0] read_addr,
    input [31:0] write_addr,
    input we,
    input init_phase,
    input [1:0] control_data,
    input valid,
    input [15:0] IFM_W,

    output [63:0] data_pooling_average,
    output [31:0] data_pooling_average_32bit
);
    parameter DIV_14x14 = 31'h0000014e;
    parameter DIV_7x7 = 31'h00000539;

    logic [31:0] DIV;
    logic [31:0] data_for_write;
    logic [31:0] data_for_read;
    logic [31:0] add_data;
    logic [7:0] IFM_data;
    logic [31:0] IFM_reg_data;

    logic [31:0] data_out_0_for_SE;
    logic [31:0] data_out_1_for_SE;
    logic [31:0] data_out_2_for_SE;
    logic [31:0] data_out_3_for_SE;

    logic [63:0] divide_data_out_0_for_SE;
    logic [63:0] divide_data_out_1_for_SE;
    logic [63:0] divide_data_out_2_for_SE;
    logic [63:0] divide_data_out_3_for_SE;


    always_ff @(posedge clk or negedge reset_n) begin
        if(~reset_n) begin
            IFM_reg_data <= 0;
        end
        else if(valid) begin
            IFM_reg_data <= data_in;
    end
    end

    always_comb begin
        case(IFM_W)
            'd14 : DIV = DIV_14x14 ; 
            'd07 : DIV = DIV_7x7 ; 
            default :
             DIV=1;
        endcase
    end
    //mux for init phase
    assign add_data = (init_phase) ? 0 : data_for_read;
    assign data_pooling_average = ((data_for_read << 16) * DIV);

    assign divide_data_out_0_for_SE = ((data_out_0_for_SE << 16) * DIV);
    assign divide_data_out_1_for_SE = ((data_out_1_for_SE << 16) * DIV);
    assign divide_data_out_2_for_SE = ((data_out_2_for_SE << 16) * DIV);
    assign divide_data_out_3_for_SE = ((data_out_3_for_SE << 16) * DIV);
    
    assign data_pooling_average_32bit ={divide_data_out_3_for_SE[39:32],
                                        divide_data_out_2_for_SE[39:32],
                                        divide_data_out_1_for_SE[39:32],
                                        divide_data_out_0_for_SE[39:32]};

    //mux for divide data_in 128
    always_comb begin
        case(control_data)
            2'b00 : IFM_data = IFM_reg_data[7:0] ; 
            2'b01 : IFM_data = IFM_reg_data[15:8] ; 
            2'b10 : IFM_data = IFM_reg_data[23:16] ; 
            2'b11 : IFM_data = IFM_reg_data[31:24] ; 
        endcase
    end

    //division
    assign data_for_write = add_data + IFM_data;

    BRAM_Pooling IFM_BRAM_layer_2(
        .clk(clk),
        //.rd_addr(addr_IFM_layer_2),
        .rd_addr(read_addr),
        //.wr_addr(wr_addr_IFM_layer_2),
        .wr_addr( write_addr ),
        //.wr_rd_en(wr_rd_en_IFM),
        //.wr_rd_en(wr_rd_req_IFM_layer_2),
        .wr_rd_en(we),
        //.data_in(data_in_IFM_layer_2),
        .data_in( data_for_write ),
        .data_out(data_for_read),
        .data_out_0_for_SE(data_out_0_for_SE),
        .data_out_1_for_SE(data_out_1_for_SE),
        .data_out_2_for_SE(data_out_2_for_SE),
        .data_out_3_for_SE(data_out_3_for_SE)

    );
endmodule