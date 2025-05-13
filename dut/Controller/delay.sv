module delay(
    input clk,
    input rst_n,
    input [15:0] IFM_C,
    input [15:0] OFM_C,
    input done_compute,
    output logic done_compute_delay
);
logic [31:0] count;
logic tmp;

always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        count <= 0;
        done_compute_delay <= 0;
    end
    else  begin 
        if (~done_compute) begin
            count <= 0;
        end
        if (done_compute) done_compute_delay <= done_compute;
        if (count  == IFM_C * OFM_C >> 2) begin
            done_compute_delay <= done_compute;
            count <= 0;
        end
        else 
        count <= count + 1;
    //    count[31] <= done_compute;
    //    count[30] <= count[31];
    //    count[29] <= count[30];
    //    count[28] <= count[29];
    //    count[27] <= count[28];
    //    count[26] <= count[27];
    //    count[25] <= count[26];
    //    count[24] <= count[25];
    //    count[23] <= count[24];
    //    count[22] <= count[23];
    //    count[21] <= count[22];
    //    count[20] <= count[21];
    //    count[19] <= count[20];
    //    count[18] <= count[19];
    //    count[17] <= count[18];
    //    count[16] <= count[17];
    //    count[15] <= count[16];
    //    count[14] <= count[15];
    //    count[14] <= count[15];
    //    count[13] <= count[14];
    //    count[12] <= count[13];
    //    count[11] <= count[12];
    //    count[10] <= count[11];
    //    count[9] <= count[10];
    //    count[8] <= count[9];
    //    count[7] <= count[8];
    //    count[6] <= count[7];
    //    count[5] <= count[6];
    //    count[4] <= count[5];
    //    count[3] <= count[4];
    //    count[2] <= count[3];
    //    count[1] <= count[2];
    //    count[0] <= count[1];
    //    done_compute_delay <= count[0];
    end
end


endmodule