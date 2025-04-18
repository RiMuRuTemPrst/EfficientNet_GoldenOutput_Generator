module Pooling_average(
    input clk,
    input reset_n,
    input [7:0] data_in_0,
    input [7:0] data_in_1,
    input [7:0] data_in_2,
    input [7:0] data_in_3,
    input valid,
    input [1:0] size,
    input [10:0] pixel_index,
    input [7:0] OFM_C,
    input [10:0] read_pixel_index,
    output logic valid_data_out,
    output [18:0] sign_output_0,
    output [18:0] sign_output_1,
    output [18:0] sign_output_2,
    output [18:0] sign_output_3,
    output logic finish,
    output logic [18:0] data_out
);
    parameter SIZE28_28 = 784;
    parameter SIZE14_14 = 196;
    parameter SIZE7_7 = 49;
    parameter PA_SIZE28_28 = 18'h000005;
    parameter PA_SIZE14_14 = 18'h000014;
    parameter PA_SIZE7_7 = 18'h000054;

    logic [18:0] accumulate [ 1024:0 ];
    logic [18:0] valid_sum;
    logic [19:0] count_data;
    logic [18:0] div_param;
    logic acc_reset;
    logic init_phrase;
    logic [10:0] out_div;
    logic [19:0] data_average;
    //logic phase_div;
    //logic [18:0] count_deep;
    always_ff @( posedge clk or negedge reset_n ) begin
        if(~reset_n) begin
            //valid_data_out <= 0;
            //data_average <= 0;
            //accumulate <= 0; 
            accumulate[0] = 0;
            accumulate[1] = 0;
            accumulate[2] = 0;
            accumulate[3] = 0;
            count_data <= 0;
            init_phrase <=1;
            out_div <= 0;
            finish <= 0;
            //count_deep <= 0;
            //phase_div <= 0;
        end
        else begin
            if(valid) begin
                if(init_phrase) 
                 begin
                    accumulate[pixel_index] <= data_in_0;
                    accumulate[pixel_index + 1] <= data_in_1;
                    accumulate[pixel_index + 2] <= data_in_2;
                    accumulate[pixel_index + 3] <= data_in_3;
                 end
                else begin
                    accumulate[pixel_index] <= accumulate[pixel_index] + data_in_0;
                    accumulate[pixel_index + 1] <= accumulate[pixel_index + 1] + data_in_1;
                    accumulate[pixel_index + 2] <= accumulate[pixel_index + 2] + data_in_2;
                    accumulate[pixel_index + 3] <= accumulate[pixel_index + 3] + data_in_3;
                end
                if(pixel_index == 188) begin 
                    init_phrase = 0;
                    count_data = count_data + 1;
                end
            end
                
             //if(acc_reset) begin
            //     //accumulate[pixel_index] <= 0;
            //     count_data <= 0;
                 //out_div <= out_div + 1;
            //     //phase_div <= 1;
            //     //accumulate[out_div] <= data_average;
             //end
            if(valid_data_out) begin
                accumulate[out_div - 1] <= data_average;
                if(out_div < OFM_C)
                out_div <= out_div + 1;
                else finish <= 1;
            end

            if(finish) data_out <= accumulate[read_pixel_index];
        end
    end

    always_ff @( posedge clk or negedge reset_n ) begin
        if(~reset_n) begin
            valid_sum <= 0;
            valid_data_out <= 0;
        end
        else begin
            if(acc_reset) begin
                valid_sum <= accumulate[out_div];
                valid_data_out <= 1;
            end
            else valid_data_out <=0;
        end
    end
    assign data_average = valid_sum * div_param;
    always_comb begin 
        case(size)
            2'b00: if( count_data == SIZE28_28) begin
                acc_reset = 1;
                div_param = PA_SIZE28_28;
            end
            //else acc_reset = 0;
            2'b01: if( count_data == SIZE14_14) begin
                acc_reset = 1;
                div_param = PA_SIZE14_14;
            end 
            //else acc_reset = 0;
            2'b10: if( count_data == SIZE7_7) begin
                acc_reset = 1;
                div_param = PA_SIZE7_7;
            end 
            //else acc_reset = 0;
            //SIZE28_28: if( count_data == SIZE28_28) acc_reset = 1;
            default : begin
                acc_reset = 0;
                div_param = 0;
            end
        endcase
    end
    assign sign_output_0 = accumulate[ pixel_index - 4];
    assign sign_output_1 = accumulate[ pixel_index - 3];
    assign sign_output_2 = accumulate[ pixel_index - 2];
    assign sign_output_3 = accumulate[ pixel_index - 1];
endmodule