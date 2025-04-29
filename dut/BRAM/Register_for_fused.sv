module Register_for_fused (
    input clk,
    input reset_n,
    input [31:0] data_in,
    output logic [127:0] data_out,
    input valid,
    output logic valid_out
);
    reg [1:0] count_data;
    always_ff @( posedge clk or negedge reset_n ) begin 
        if(~reset_n) begin
            count_data <= 0;
            data_out <= 0;
            valid_out <=0;
        end
        else begin
            if(valid) begin
                count_data <= count_data + 1;

                case(count_data )
                    2'b00: data_out[31:0] <= data_in ;
                    2'b01: data_out[63:32] <= data_in ;
                    2'b10: data_out[95:64] <= data_in ;
                    2'b11: data_out[127:96] <= data_in ;
                endcase
            end
            if( (count_data == 3) && valid ) valid_out <= 1;
            else valid_out <= 0;
        end        
    end
    
endmodule