module Pooling_average(
    input clk,
    input reset_n,
    input [8:0] data_in,
    input valid,
    input size,
    output [8:0] dadata_averageta,
    output valid_data_out
);
    parameter SIZE28_28 = 784;
    parameter SIZE14_14 = 196;
    parameter SIZE7x7 = 49;
    parameter PA_SIZE28_28 = 18'h000005;
    parameter PA_SIZE14_14 = 18'h000014;
    parameter PA_SIZE7_7 = 18'h000054;

    logic [18:0] accumulate;
    logic [18:0] valid_sum;
    logic [9:0] count_data;
    logic [18:0] div_param;
    always_ff @( posedge clk or negedge reset_n ) begin
        if(~reset_n) begin
            //valid_data_out <= 0;
            data_average <= 0;
            accumulate <= 0; 
            count_data <= 0;
        end
        else begin
            if(valid) begin
                accumulate <= accumulate + data_in;
                count_data <= count_data + 1;
            end
            if(acc_reset) begin
                accumulate <= 0;
                count_data <= 0;
            end
        end
    end

    always_ff @( posedge clk or negedge reset_n ) begin
        if(~reset_n) begin
            valid_sum <= 0;
            valid_data_out <= 0;
        end
        else begin
            if(acc_reset) begin
                valid_sum <= accumulate;
                valid_data_out <= 1;
            end
            else valid_data_out <=0;
        end
    end
    assign data_average = valid_sum * div_param;
    always_comb begin 
        case(size)
            SIZE28_28: if( count_data == SIZE28_28) begin
                acc_reset = 1;
                div_param = PA_SIZE28_28;
            end
            SIZE14_14: if( count_data == SIZE14_14) begin
                acc_reset = 1;
                div_param = PA_SIZE14_14;
            end
            SIZE7_7: if( count_data == SIZE7_7) begin
                acc_reset = 1;
                div_param = PA_SIZE7_7;
            end
            //SIZE28_28: if( count_data == SIZE28_28) acc_reset = 1;
        endcase
    end
endmodule