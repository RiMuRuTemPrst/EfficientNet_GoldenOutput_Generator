module Global_top_fused (
    input clk,
    input reset_n,
    input start,
    output ready,

    // Global BRAM signal
    output logic [31:0] wr_addr_global,
    output logic [31:0] rd_addr_global,
    output logic we_global,

    // Load BRAM signal
    output logic [31:0] wr_addr_fused,
    output logic [31:0] rd_addr_fused,
    output logic we_fused,

    //control signal
    output logic [1:0] control_load,

    //signal for infor of size
    input [31:0] base_addr_IFM,
    input [31:0] base_addr_Weight_layer_1,
    input [31:0] size_Weight_layer_1,
    input [31:0] base_addr_Weight_layer_2,
    input [31:0] size_Weight_layer_2
);
reg [2:0] curr_state, next_state;
parameter IDLE          = 3'b000;
parameter LOAD_WEIGHT   = 3'b001;
parameter LOAD_IFM_CACULATE_STORE    = 3'b010;
parameter END_PIXEL     = 3'b100;

// value for count
parameter NO_LOAD     = 0 ;
parameter LOAD_WEIGHT_C     = 2 ;
parameter LOAD_IFM_C     = 1 ;


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
        START_PIXEL : begin
            if((valid_count >= weight_c - 'h8) || (next_filter) ) begin
                next_state =  DEEP_FETCH;
            end
            else next_state =  START_PIXEL;
        end

        // ST_DATA_BIT
        DEEP_FETCH : begin
            if(count_deep_pixel < weight_c - 'h4) begin
                next_state = DEEP_FETCH ;
            end
            else begin
                if(count_filter < num_filter - 'h4) next_state =  START_PIXEL;
                else next_state =  END_PIXEL;
            end
        end

        // ST_END_TRAN 
        END_PIXEL : begin
            next_state = START_PIXEL ;
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
            control_load <= NO_LOAD;
        end
        else begin
            unique case(curr_state)

            IDLE: begin
                if(next_state == LOAD_WEIGHT) begin
                    rd_addr_global <= base_addr_Weight_layer_1 ;
                    wr_addr_fused <= 0 ;
                    control_load <= LOAD_WEIGHT_C;
                    we_fused <= 1;
                end
            end

            START_PIXEL:begin

                if(next_state == START_PIXEL) begin
                end
                if(next_state == DEEP_FETCH) begin
                    addr_ifm <= addr_ifm + 'h4 ;
                    addr_weight <= addr_weight + 'h4 ;
                    if(~next_filter)
                    valid_count <= 0;
                    count_deep_pixel <= count_deep_pixel + 4;
                end
            end
            DEEP_FETCH: begin
                PE_reset <=0;
                PE_finish <=0;
                if(valid == 1) valid_count <= valid_count + Num_of_PE_x4;
                if(next_state == DEEP_FETCH) begin
                    addr_ifm <= addr_ifm + 'h4 ;
                    addr_weight <= addr_weight + 'h4 ;
                    count_deep_pixel <= count_deep_pixel + 'h4;
                end

                if(next_state == START_PIXEL) begin
                    addr_ifm <= addr_ifm - (weight_c-'h4) ;
                    addr_weight <= addr_weight + 'h4 ;
                    count_deep_pixel <= 0;
                    count_filter <= count_filter + 'h4;
                    next_filter <= 1;
                end

                if(next_state == END_PIXEL) begin
                    count_deep_pixel <= 0;
                    count_filter <= 0;
                end
            end
            END_PIXEL: begin
                PE_reset <=4'b1111;
                PE_finish <=4'b1111;
                if(valid == 1) valid_count <= valid_count + 16;
                if(next_state == START_PIXEL) begin
                    addr_ifm <= addr_ifm + 4 ;
                    addr_weight <= 0 ;
                    next_filter <= 0;
                end
            end
        endcase
    end
end
endmodule