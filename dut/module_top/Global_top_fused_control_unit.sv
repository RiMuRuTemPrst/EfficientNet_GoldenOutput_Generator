module Global_top_fused_control_unit (
    input clk,
    input reset_n,
    input start,
    output logic ready,

    // Global BRAM signal
    output logic [31:0] wr_addr_global,
    output logic [31:0] rd_addr_global,
    output logic we_global,

    // Load BRAM signal
    output logic [31:0] wr_addr_fused,
    output logic [31:0] rd_addr_fused,
    output logic [20:0] we_fused,

    //signal for infor of size
    input [31:0] base_addr_IFM,
    input [31:0] size_IFM,
    input [31:0] base_addr_Weight_layer_1,
    input [31:0] size_Weight_layer_1,
    input [31:0] base_addr_Weight_layer_2,
    input [31:0] size_Weight_layer_2,
    
    //input from Fused_block
    input valid_layer2 
);
reg [2:0] curr_state, next_state;
parameter IDLE          = 3'b000;
parameter LOAD_WEIGHT   = 3'b001;
parameter LOAD_IFM_CACULATE_STORE    = 3'b010;
parameter END_PIXEL     = 3'b100;

// value for count
logic [1:0] load_count;
logic [10:0] count_weight_addr;
logic load_weight_layer_st;



always_comb begin
    // case(data_bit_num)
    //     2'b00: bit_num = 5;
    //     2'b01: bit_num = 6;
    //     2'b10: bit_num = 7;
    //     2'b11: bit_num = 8;
    //     default : bit_num = 8;
    // endcase
    // bit_to_end = bit_num + parity_en;
    // sum_of_bit = b[0] + b[1] + b[2] + b[3] + b[4] + b[5] + b[6] + b[7] ;
end
// alwayff change state
always_ff@(posedge clk or negedge reset_n) begin
    if(~reset_n) begin
        curr_state <= 0;
    end
    else begin
        curr_state <= next_state;
    end
end

// alwaycomb to caculate the next_state
always_comb begin
    unique case(curr_state)
        
        // ST_IDLE to ...
        IDLE : begin
            if(start == 1) next_state = LOAD_WEIGHT;
            else next_state = IDLE ;
        end

        // ST_START_BIT
        LOAD_WEIGHT : begin
            if(rd_addr_global < base_addr_Weight_layer_1 + size_Weight_layer_1 + size_Weight_layer_2) begin
                next_state =  LOAD_WEIGHT;
            end
            else next_state =  LOAD_IFM_CACULATE_STORE;
        end

        // ST_DATA_BIT
        LOAD_IFM_CACULATE_STORE : begin
            if(wr_addr_fused < size_IFM) begin
                next_state = LOAD_IFM_CACULATE_STORE ;
            end
            else begin
                next_state = IDLE ;
            end
        end
        
    endcase
end

//always_ff for output
    always_ff@(posedge clk or negedge reset_n) begin
        if(~reset_n) begin
            ready <= 0;
            wr_addr_global <= 0;
            rd_addr_global <= 0;
            we_global <= 0;
            wr_addr_fused <= 0;
            rd_addr_fused <= 0;
            we_fused <= 0;
            load_count <= 0;
            count_weight_addr <= 0;
            load_weight_layer_st <= 0;
        end
        else begin
            unique case(curr_state)

            IDLE: begin
                if(next_state == LOAD_WEIGHT) begin
                    rd_addr_global <= base_addr_Weight_layer_1 ;
                    wr_addr_fused <= 0 ;
                    we_fused <= 1;
                end
            end

            LOAD_WEIGHT:begin

                if(next_state == LOAD_WEIGHT) begin
                    rd_addr_global <= rd_addr_global + 4;
                    if(load_weight_layer_st) begin //weight layer 2
                        if(wr_addr_fused > (size_Weight_layer_2 >> 2)) begin
                            wr_addr_fused <= 0;                     
                            count_weight_addr <= count_weight_addr + 1;
                            we_fused <= we_fused << 1;
                        end
                        else begin
                            wr_addr_fused <= wr_addr_fused + 4;
                        end
                    end else begin
                        if(wr_addr_fused > (size_Weight_layer_1 >> 4)) begin
                            wr_addr_fused <= 0;
                            count_weight_addr <= count_weight_addr + 1;
                            we_fused <= we_fused << 1;
                            if(count_weight_addr > 14) begin
                                load_weight_layer_st <= 1;
                                count_weight_addr <= 0;
                            end
                        end else begin
                            wr_addr_fused <= wr_addr_fused + 4; 
                            //wr_addr_fused <= 0;                      
                        end
                    end
                end

                if(next_state == LOAD_IFM_CACULATE_STORE) begin
                    rd_addr_global <= base_addr_IFM ;
                    wr_addr_fused <= 0;
                    we_fused <= we_fused << 1;
                    count_weight_addr <= 0;
                end
            end

            LOAD_IFM_CACULATE_STORE: begin
                    if(next_state == LOAD_IFM_CACULATE_STORE) begin
                    rd_addr_global <= rd_addr_global + 4 ;
                    wr_addr_fused <= wr_addr_fused + 4 ;
                    load_count <= load_count + 1;
                    if(load_count == 2) begin
                        ready <= 1;
                    end
                    if(valid_layer2) begin
                        wr_addr_global = wr_addr_global + 4;
                        we_global <= 1;
                    end
                end
                if( next_state == IDLE ) begin
                    we_fused <= 0;
                end
            end
        endcase
    end
end
endmodule