module control_padding#(
    parameter PE = 16
)
(   
    input                                clk,
    input                                rst_n,
    input                                valid,
    input                                start,
    input        [PE * 8 - 1 : 0]        data_in,
    input  [7:0]                        OFM_C,
    input  [7:0]                        OFM_W,
    input                                padding,
    output logic                         wr_en,
    output logic [15:0]                  addr_next,
    output logic [PE * 8 - 1 : 0]        data_out
);
logic [15:0] count_padd;
logic [15:0] count_data;
logic [15:0] count_height;
logic [15:0] count_height_padd;
logic [15:0] count_lr;
logic [15:0] addr_padding = 0;
logic [15:0] addr_data = OFM_C * (OFM_W + 3 * padding) / 4;
logic end_signal;


parameter ROW_PADDING =             3'b000;
parameter LEFT_RIGHT_PADDING =      3'b001;
parameter NEXT_LEFT_RIGHT_PADDING = 3'b010;
parameter ROW_DATA =                3'b011;
parameter NEXT_ROW_DATA =           3'b100;
parameter IDLE =                    3'b101;

logic [2:0] current_state, next_state;

always_ff @( posedge clk or negedge rst_n ) begin 
    if (!rst_n) begin
        current_state <= IDLE;
    end
    else current_state <= next_state;
end
always_comb begin 
    case(current_state)
        IDLE: begin
            if(start) next_state = ROW_PADDING;
            else if (valid)begin
                if (count_data >= ((OFM_C * OFM_W) >> 4) - 1) next_state = NEXT_ROW_DATA;
                else next_state = ROW_DATA;
            end
            else next_state = IDLE;
        end
        ROW_PADDING: begin
            if (valid) begin
                if (count_data >= ((OFM_C * OFM_W) >> 4) - 1) next_state = NEXT_ROW_DATA;
                else next_state = ROW_DATA;
            end
            else if (count_padd >= ((OFM_C * (OFM_W + padding)) >> 4) - 1 ) begin
                if (end_signal) next_state = IDLE;
                else next_state = LEFT_RIGHT_PADDING;
            end
            else next_state = ROW_PADDING;
        end
        ROW_DATA: begin
            if (!valid) begin
                    if (count_padd >= ((OFM_C *(OFM_W + padding)) >> 4) - 1)begin
                        if(end_signal) next_state = IDLE;
                        else next_state = LEFT_RIGHT_PADDING;
                    end
                    else next_state = ROW_PADDING;
            end
            else begin
                if (count_data >= ((OFM_C * OFM_W) >> 4) - 1) next_state = NEXT_ROW_DATA;
                else next_state = ROW_DATA;
            end
        end
        NEXT_ROW_DATA: begin
            if (!valid) begin
                    if (count_padd >= ((OFM_C *(OFM_W + padding)) >> 4) - 1)begin
                        if(end_signal) next_state = IDLE;
                        else next_state = LEFT_RIGHT_PADDING;
                    end
                    else next_state = ROW_PADDING;
            end
            else begin
                if (count_height < OFM_W - 1) next_state = ROW_DATA;
                else next_state = IDLE;
            end
        end
        LEFT_RIGHT_PADDING: begin
            if (valid) begin
                if (count_data >= ((OFM_C * OFM_W) >> 4) - 1) next_state = NEXT_ROW_DATA;
                else next_state = ROW_DATA;
            end
            else begin
                if (count_lr < ((2 * padding * OFM_C) >> 4) - 1) next_state = LEFT_RIGHT_PADDING;
                else next_state = NEXT_LEFT_RIGHT_PADDING;
            end
        end
        NEXT_LEFT_RIGHT_PADDING: begin
            if (valid) begin
                if (count_data >= ((OFM_C * OFM_W) >> 4) - 1) next_state = NEXT_ROW_DATA;
                else next_state = ROW_DATA;
            end
            else begin
                if (count_height_padd >= OFM_W + padding - 1) next_state = ROW_PADDING;
                else next_state = LEFT_RIGHT_PADDING;
            end
        end

    endcase
end
always_ff @(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        count_padd <= 0;
        count_lr <= 0;
        count_height_padd <= 0;
        count_data <= 0;
        count_height <= 0;
        end_signal <=0;
        addr_data <=0;
    end
    else 
    case (current_state) 
        IDLE: begin end
        ROW_PADDING: begin
            if (next_state == LEFT_RIGHT_PADDING) begin
                addr_padding <= addr_padding + 4;
            end
            else if (next_state == IDLE || next_state == ROW_DATA) begin
                addr_padding <= addr_padding;
            end
            else begin
            count_padd <= count_padd + 1;
            addr_padding <= addr_padding + 4;
            count_height_padd <= 0;
            end
        end
        ROW_DATA: begin
            if (next_state == NEXT_ROW_DATA)begin
                addr_data <= addr_data;
            end
            else if (next_state == LEFT_RIGHT_PADDING) begin
                addr_padding <= addr_padding + 4;
                addr_data <= addr_data;
                count_lr <= count_lr + 1;
                count_data <= count_data + 1;
            end
            else begin
                count_data <= count_data + 1;
                addr_data <= addr_data + 4;
            end
        end
        NEXT_ROW_DATA: begin
            count_data <= 0;
            count_height <= count_height + 1;
            addr_data <= addr_data + 2 * OFM_C * padding / 4 + 4;
        end
        LEFT_RIGHT_PADDING: begin
            if (next_state == NEXT_LEFT_RIGHT_PADDING ) begin
                addr_padding <= addr_padding ;
            end
            else if ( next_state == ROW_DATA || next_state == NEXT_ROW_DATA) begin
                addr_padding <= addr_padding;
                addr_data <= addr_data + 4;
            end
            else begin
                count_lr <= count_lr + 1;
                addr_padding <= addr_padding + 4;
            end
        end
        NEXT_LEFT_RIGHT_PADDING: begin
            if (next_state == ROW_PADDING) begin 
                count_padd <= 0;
                addr_padding <= addr_padding + 4;
                end_signal <= 1;            
            end
            else if (next_state == ROW_DATA) begin
                count_lr <= 0;
                addr_data <= addr_data + 4;
                count_height_padd <= count_height_padd + 1;
                addr_padding <= addr_padding + OFM_W * OFM_C / 4 + 4;
            end
            else begin 
                count_lr <= 0;
                count_height_padd <= count_height_padd + 1;
                addr_padding <= addr_padding + OFM_W * OFM_C / 4 + 4;
            end
        end

    endcase
end
always_comb begin
    case(current_state)
        IDLE: begin
            wr_en = 1;
            addr_next = (valid) ? addr_data : addr_padding;
            data_out = 0;
        end
        ROW_PADDING: begin
            wr_en = 1;
            addr_next = (valid) ? addr_data : addr_padding;
            data_out = 0;
        end
        ROW_DATA: begin
            wr_en = 1;
            addr_next = (valid) ? addr_data : addr_padding;
            data_out = data_in;
        end
        NEXT_ROW_DATA: begin
            wr_en = 1;
            addr_next = (valid) ? addr_data : addr_padding;
            data_out = 0;
        end
        LEFT_RIGHT_PADDING: begin
            wr_en = 1;
            addr_next = (valid) ? addr_data : addr_padding;  
            data_out = 0;         
        end
        NEXT_LEFT_RIGHT_PADDING: begin
            wr_en = 1;
            addr_next = (valid) ? addr_data : addr_padding;
            data_out = 0;
        end

    endcase
end

endmodule