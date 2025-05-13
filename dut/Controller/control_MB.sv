module control_MB#(
    parameter PE = 16
)
(   
    input                                clk,
    input                                rst_n,
    input                                valid,
    input                                start,
    input        [PE * 8 - 1 : 0]        data_in,
    input logic [15:0]                   OFM_C,
    input logic [15:0]                   OFM_W,
    output logic                         wr_en,
    output logic [31:0]                  addr_next,
    output logic [PE * 8 - 1 : 0]        data_out
);
logic [31:0] count_data;
logic [31:0] count_col;
logic [31:0] count_row;
logic [7:0] tile;
logic [7:0] count_tile;
logic [7:0] addr_base;
logic [7:0] shift_addr;


always_comb begin
    tile = OFM_C >> 4;
    shift_addr = tile << 2;
end

parameter IDLE_0 =                  3'd0;
parameter IDLE =                    3'd1;
parameter ROW =                     3'd2;
parameter NEXT_ROW =                3'd3;
parameter NEXT_TILE =               3'd4;

logic [2:0] current_state, next_state;

always_ff @( posedge clk or negedge rst_n ) begin 
    if (!rst_n) begin
        current_state <= IDLE_0;
    end
    else current_state <= next_state;
end
always_comb begin 
    case(current_state)

        IDLE_0: begin
            if(start) next_state = IDLE;
            else next_state= IDLE_0;
        end
        IDLE: begin
            if (valid)begin
                if (count_col == OFM_W - 1) begin
                    if (count_row == OFM_W - 1) next_state = NEXT_TILE;
                    else  next_state = NEXT_ROW;
                end
                else next_state = ROW;
            end
            else next_state = IDLE;
        end
        ROW: begin
            next_state = IDLE;
        end
        NEXT_ROW: begin
            next_state = IDLE;
        end
        NEXT_TILE: begin
            if (count_tile == tile - 1) next_state = IDLE_0;
            else next_state = IDLE;
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end
always_ff @(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        count_col <= 0;
        count_row <= 0;
        count_tile <= 0;
        addr_next  <= 0;
        addr_base <= 0;
    end
    else begin
    case (current_state) 
        IDLE_0 : begin
            count_col <= 0;
            count_row <= 0;
            count_tile <= 0;
            addr_next  <= 0;
            addr_base <= 0;
        end
        IDLE: begin
             addr_next <= addr_next;
        end
        ROW: begin
            addr_next <= addr_next + shift_addr;
            count_col <= count_col + 1;
        end
        NEXT_ROW: begin
            count_col <= 0;
            addr_next <= addr_next + shift_addr;
            count_row <= count_row + 1;
        end
        NEXT_TILE: begin
            count_col <= 0;
            count_row <= 0;
            addr_next <= addr_base + 4;
            count_tile <= count_tile + 1;
            addr_base <= addr_base + 4;
        end
        default : begin
            count_col <= 0;
            count_row <= 0;
            count_tile <= 0;
            addr_next  <= 0;
            addr_base <= 0;
        end
    endcase
    
    end
end
always_comb begin
    case(next_state)
        IDLE_0: begin
            wr_en    = 0;
            data_out = 0;
        end
        IDLE: begin
            wr_en = 0;
            data_out = 0;
        end
        ROW: begin
            wr_en = 1;
            data_out = data_in;
        end
        NEXT_ROW: begin
            wr_en = 1;
            data_out = data_in;
        end     
        NEXT_TILE: begin
            wr_en = 0;
            data_out = data_in;
        end
        default: begin
            wr_en    = 0;
            data_out = 0;
        end
    endcase
end

endmodule