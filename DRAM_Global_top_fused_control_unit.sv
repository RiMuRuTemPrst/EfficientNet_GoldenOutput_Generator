module DRAM_Global_top_fused_control_unit (
    input clk,
    input reset_n,
    input start,
    output logic ready,
    input [15:0] IFM_C,
    input [15:0] IFM_W,

    // Global BRAM signal
    output  logic                  start_write,
    output  logic                  start_read,
    output  logic [32-1:0] addr_read,
    output  logic [32-1:0] addr_write,
    output  logic [127:0] data_in,

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
    input valid_layer2 ,
    input [15:0] col_index_OFM,
    input [15:0] size_3,
    input [15:0] size_6,
    input [15:0] size_change,
    input done_compute,
    input valid_data 
);
reg [2:0] curr_state, next_state;
parameter IDLE          = 3'b000;
parameter LOAD_WEIGHT   = 3'b001;
parameter LOAD_IFM_CACULATE_STORE    = 3'b010;
parameter END_PIXEL     = 3'b100;

// value for count
logic [10:0] load_count;
logic [10:0] count_weight_addr;
logic load_weight_layer_st;
logic wait_load_data_weight;
logic [20:0] we_fused_pre;
logic [10:0] load_row_count;
logic start_load;
logic load_6;
logic change_rd;
assign we_fused = we_fused_pre & {valid_data,valid_data,valid_data,valid_data,valid_data,valid_data,valid_data,valid_data,valid_data,valid_data,valid_data,valid_data,valid_data,valid_data,valid_data,valid_data,valid_data,valid_data,valid_data,valid_data,valid_data} ;
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
            if((addr_read >= base_addr_Weight_layer_1 + size_Weight_layer_1 + size_Weight_layer_2 ) && ~valid_data) begin
                next_state =  LOAD_IFM_CACULATE_STORE;
            end
            else next_state =  LOAD_WEIGHT;
        end

        // ST_DATA_BIT
        LOAD_IFM_CACULATE_STORE : begin
            if(~ done_compute ) begin 
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
       start_read <= 0;
       addr_read <= 0;
        addr_write <= 0;
        data_in <= 0;
        start_write <= 0;
            ready <= 0;
            wr_addr_fused <= 0;
            rd_addr_fused <= 0;
            we_fused_pre <= 0;
            load_count <= 0;
            count_weight_addr <= 0;
            load_weight_layer_st <= 0;
            wait_load_data_weight <= 0;
            start_load <= 1;
            load_6 <= 0;
            change_rd <= 0;
        end
        else begin
            unique case(curr_state)

            IDLE: begin
                if(next_state == LOAD_WEIGHT) begin
                    addr_read <= base_addr_Weight_layer_1 ;
                    wr_addr_fused <= 0 ;
                    start_read <= 1;
                    //we_fused_pre <= 1;
                end
            end

            LOAD_WEIGHT:begin

                if(next_state == LOAD_WEIGHT) begin  //load weight
                    if(addr_read < base_addr_Weight_layer_1 + size_Weight_layer_1 + size_Weight_layer_2) begin
                        if(valid_data) begin
                            //if(addr_read < base_addr_Weight_layer_1 + size_Weight_layer_1 + size_Weight_layer_2) begin
                            addr_read <= addr_read + 16;
                            wr_addr_fused <= wr_addr_fused + 1;
                        end
                        if(  addr_read == base_addr_Weight_layer_1) begin 
                            we_fused_pre <= 1;
                            //wr_addr_fused <= -1 ;
                        end
                        if(load_weight_layer_st) begin //weight layer 2
                            if((((wr_addr_fused + 1) << 4) >= (size_Weight_layer_2 >> 2)) && (wr_addr_fused != -1)) begin
                                if(valid_data) begin
                                wr_addr_fused <= 0;                                                    
                                count_weight_addr <= count_weight_addr + 1;
                                we_fused_pre <= we_fused_pre << 1;
                                end
                            end
                            else begin
                                if(valid_data) begin
                                wr_addr_fused <= wr_addr_fused + 1;
                                end
                            end
                        end else begin //load weight layer 1
                            if( ((wr_addr_fused + 1 )<<4) >= (size_Weight_layer_1 >> 4) && (wr_addr_fused != -1)) begin
                                if(valid_data) begin
                                wr_addr_fused <= 0;
                                count_weight_addr <= count_weight_addr + 1;
                                we_fused_pre <= we_fused_pre << 1;
                                end
                                if(count_weight_addr > 14) begin
                                    load_weight_layer_st <= 1;
                                    count_weight_addr <= 0;
                                end
                            end else begin
                                if(valid_data) begin
                                wr_addr_fused <= wr_addr_fused + 1; 
                                end
                                //wr_addr_fused <= 0;                      
                            end
                        end
                    end
                    else begin
                        start_read <= 0; 
                        we_fused_pre <= 0;
                    end               
                end
                

                if(next_state == LOAD_IFM_CACULATE_STORE) begin
                    addr_read <= base_addr_IFM ;
                    wr_addr_fused <= 0;
                    we_fused_pre <= 21'b1_0000_0000_0000_0000_0000;
                    count_weight_addr <= 0;
                    load_weight_layer_st <= 0;
                    //wait_load_data_weight <= 1;
                    start_read <= 1 ;
                end
                //end
            end

            LOAD_IFM_CACULATE_STORE: begin
                if(valid_data) begin
                if(next_state == LOAD_IFM_CACULATE_STORE) begin
                    if(((wr_addr_fused << 4 ) < size_IFM) || (wr_addr_fused == -1) ) begin


                        if((col_index_OFM > 2) || start_load)    //load 3
                            if(load_count < size_3 ) begin
                                change_rd <= 1;
                                rd_addr_global <= rd_addr_global + 16 ;
                                if(rd_addr_global == base_addr_IFM )  wr_addr_fused <= 0;
                                else
                                wr_addr_fused <= wr_addr_fused + 1 ;
                                load_count <= load_count + 1;
                            end
                            else begin
                                ready <= 1;
                                start_load <= 0;
                                //if(start_load) load_count <= 0;
                            end

                        else if(col_index_OFM == 0) begin    //load 6
                            if((load_count < size_6) && ~load_6 ) begin
                                rd_addr_global <= rd_addr_global + 16 ;
                                if(rd_addr_global == base_addr_IFM )  wr_addr_fused <= 0;
                                else
                                wr_addr_fused <= wr_addr_fused + 1 ;
                                load_count <= load_count + 1;
                            end else begin
                                load_count <= 0;
                                load_6 <=  1;
                            end
                            end
                            else begin 
                                //load_count <= 0;
                                if (change_rd)
                                rd_addr_global <= rd_addr_global - size_change;
                                change_rd <= 0;
                                wr_addr_fused <= -1;
                                load_6 <= 0;
                            end
                        
                    end
                    else begin
                        we_fused <= 0;
                    end
                    if(valid_layer2) begin
                        wr_addr_global <= wr_addr_global + 1;
                        we_global <= 1;
                    end
                    else we_global <= 0;
                end
                if( next_state == IDLE ) begin
                    start_load <= 1;
                load_6 <= 0;
                change_rd <= 0;
                    we_fused <= 0;
                    ready <= 0;
                    load_count <= 0;
                    end
                end
            end
        endcase
    end
end
endmodule