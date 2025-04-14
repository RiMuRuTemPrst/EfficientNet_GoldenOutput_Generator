module Pooling_average(
    input clk,
    input reset_n,
    input [8:0] data_in,
    input valid,
    input size,
    output [8:0] data,
    output valid_data_out
);
    parameter SIZE28_28 = 784;
    parameter SIZE14_14 = 196;
    parameter SIZE7x7 = 49;

    logic [18:0] accumulate_q;
    logic [18:0] 
    logic [9:0] count_data;
    always_ff @( posedge clk or negedge reset_n ) begin
        if(~reset_n) begin
            valid_data_out <= 0;
            data <= 0;
            accumulate <= 0; 
            count_data <= 0;
        end
        else begin
            if(valid) begin
                accumulate <= accumulate + data_in;
                count_data <= count_data + 1;
            end
            if()
        end
    end


    always_comb begin 
        case(size)
            SIZE28_28: if( count_data == SIZE28_28) 
        endcase
    end
endmodule