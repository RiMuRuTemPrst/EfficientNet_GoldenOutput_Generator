module Data_controller #(
    parameter control_mux_para = 'h3,
    parameter PE = 4
)
 (
    input   wire          clk,
    input   wire          rst_n,
    input   wire  [15:0]  OFM_data_out_valid,
    input                 done_compute,
    input         [15:0]  IFM_C,
    input         [15:0]  OFM_C,
    output  reg   [1:0]   control_mux,
    output  reg   [31:0]  addr_ram_next_wr,
    output  wire          wr_en_next,
    output  reg           wr_data_valid,
    output                done_compute_1x1
);

parameter START        = 2'b00;
parameter DATA_FETCH    = 2'b01;
reg [1:0] current_state, next_state;
reg [15:0] count_done_1x1;
reg tmp_done;
reg done_compute_1x1_reg;
assign done_compute_1x1 = done_compute_1x1_reg;
// FSM State Register
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        current_state <= START;
    else
        current_state <= next_state;
end

always@(*) begin
    if(~done_compute_1x1_reg) begin
    case ( current_state )
    START : begin
        if (OFM_data_out_valid == 16'hFFFF)  next_state = DATA_FETCH;
        else                                 next_state = START;
    end
    DATA_FETCH : begin
        if (control_mux==control_mux_para)           next_state = START;
        else                            next_state = DATA_FETCH;
    end
    endcase
    end else begin
    addr_ram_next_wr = 0;
    end
end
assign wr_en_next= (current_state==DATA_FETCH)? 'h1 : 'h0; 


always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        control_mux         <= 3'h0;
        addr_ram_next_wr    <= 32'h0;
        wr_data_valid       <= 1'h0;
        done_compute_1x1_reg    <= 1'b0;
        count_done_1x1       <= 1'b0;
        tmp_done <= 0;
    end else begin
    if (done_compute)     tmp_done <= 1;
    if (tmp_done) begin
        count_done_1x1 <= count_done_1x1 + 1;
    end
    if (count_done_1x1 == IFM_C * OFM_C >> 2 ) begin 
        done_compute_1x1_reg <= 1;
        tmp_done <= 0;
    end
    case ( current_state )

    START : begin
        control_mux         <= 'h0;
        wr_data_valid       <= 'h0;
    end
    DATA_FETCH : begin
        control_mux          <= control_mux + 'h1;
        addr_ram_next_wr     <= addr_ram_next_wr + 'h1;
        if (control_mux==control_mux_para)   wr_data_valid   <=  'h1;
        else                    wr_data_valid   <=  'h0;
    end
    endcase

    end
end


endmodule