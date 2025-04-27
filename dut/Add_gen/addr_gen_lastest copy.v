module address_generator #(
    parameter TOTAL_PE   = 16,
    parameter DATA_WIDTH = 32
)(
    input  wire clk,
    input  wire rst_n,
    input  wire [3:0] KERNEL_W,
    input  wire [7:0] OFM_W,
    input  wire [7:0] OFM_C,
    input  wire [7:0] IFM_C,
    input  wire [7:0] IFM_W,
    input  wire [1:0] stride,
    input  wire ready,
    input  wire [31:0] addr_in,

    output wire [31:0] req_addr_out_ifm,
    output wire [31:0] req_addr_out_filter,
    output reg done_compute,
    output reg finish_for_PE,
    output reg addr_valid_ifm,
    output reg done_window,
    output wire addr_valid_filter,
    output wire [7:0] num_of_tiles_for_PE
);

wire in_progress;
reg [15:0] count_for_a_Window;
reg [15:0] count_for_a_OFM;
reg [15:0] row_index_KERNEL;
reg [15:0] col_index_KERNEL;

reg [15:0] row_index_OFM;
reg [15:0] col_index_OFM;
reg [15:0] tiles_count;
reg [31:0] addr_fetch_ifm;
reg [31:0] predict_line_addr_fetch_ifm;
reg [31:0] predict_window_addr_fetch_ifm;
reg [31:0] predict_window_OFM_addr_fetch_ifm;
reg [31:0] addr_fetch_filter;
reg [31:0] window_start_addr_ifm;
reg [31:0] window_start_addr_filter;


// FSM state encoding for IFM
parameter START_ADDR_IFM        = 2'b00;
parameter FETCH_WINDOW          = 2'b01;
parameter NEXT_WINDOW           = 2'b10;
reg [2:0] current_state_IFM, next_state_IFM;


// FSM state encoding for WEIGHT
parameter START_ADDR_FILTER     = 1'b0;
parameter FETCH_FILTER          = 1'b1;
reg current_state_FILTER, next_state_FILTER;

wire [2:0] stride_shift;
assign stride_shift = (stride == 1 ) ? 0 : (stride == 2 ? 1 : 0);

reg [7:0] num_of_mul_in_PE = 4; 
//---------------------------------------------------LUT-num_of_mul_in_PE--------------------------------------------------------//
reg [7:0] num_of_mul_in_PE_shift; 

always @(*) begin
    case (num_of_mul_in_PE)
        'h2 : begin
            num_of_mul_in_PE_shift = 'h1;
        end
        'h4: begin
            num_of_mul_in_PE_shift = 'h2;
        end
        'h8: begin
            num_of_mul_in_PE_shift = 'h3;
        end
        default : 
            num_of_mul_in_PE_shift = 'h2;
    endcase 
end
//---------------------------------------------------LUT-TOTAL_PE--------------------------------------------------------//
reg [7:0] total_PE_shift =4; 

always @(*) begin
    case (4)
        2 : begin
            total_PE_shift = 'h1;
        end
        4: begin
            total_PE_shift = 'h2;
        end
        8: begin
            total_PE_shift = 'h3;
        end
        6: begin
            total_PE_shift = 'h4;
        end
        32: begin
            total_PE_shift = 'h5;
        end
        default : 
            total_PE_shift = 'h2;
    endcase
end

//---------------------------------------------------LUT-KERNEL_W--------------------------------------------------------//
reg [7:0] num_of_KERNEL_points; // = KERNEL_W *KERNEL_W

always @(*) begin
    case (KERNEL_W)
        'h3 : begin
            num_of_KERNEL_points = 'h9;
        end
        'h2: begin
            num_of_KERNEL_points = 'h4;
        end
        'h1: begin
            num_of_KERNEL_points = 'h1;
        end
        default : 
            num_of_KERNEL_points = 'h9;
    endcase
end

//---------------------------------------------------LUT-KERNEL_W--------------------------------------------------------//
reg [7:0] num_of_OFM_points; // = KERNEL_W *KERNEL_W

always @(*) begin
    case (KERNEL_W)
        'h3 : begin
            num_of_OFM_points = 'h9;
        end
        'h2: begin
            num_of_OFM_points = 'h4;
        end
        default : 
            num_of_OFM_points = 'h9;
    endcase
end

wire [7:0] num_of_tiles         = IFM_C >> num_of_mul_in_PE_shift ;

assign num_of_tiles_for_PE  = OFM_C >> total_PE_shift;
//---------------------------------------------------LUT-num_of_tiles_shift--------------------------------------------------------//
reg [7:0] num_of_tiles_shift; // use shift operation
always @(*) begin
    case (num_of_tiles)
        'd2 : begin
            num_of_tiles_shift = 'h1;
        end
        'd4: begin
            num_of_tiles_shift = 'h2;
        end
        'd8: begin
            num_of_tiles_shift = 'h3;
        end
        'd16: begin
            num_of_tiles_shift = 'h4;
        end
        default : 
            num_of_tiles_shift = 'h2;
    endcase
end
//---------------------------------------------------LUT-IFM_C_shift--------------------------------------------------------//
reg [7:0] IFM_C_shift; // use shift operation
always @(*) begin
    case (IFM_C)
        'd2 : begin
            IFM_C_shift = 'h1;
        end
        'd4: begin
            IFM_C_shift = 'h2;
        end
        'd8: begin
            IFM_C_shift = 'h3;
        end
        'd16: begin
            IFM_C_shift = 'h4;
        end
        'd32: begin
            IFM_C_shift = 'h5;
        end
        default : 
            IFM_C_shift = 'h2;
    endcase
end
//---------------------------------------------------LUT-OFM_C_shift--------------------------------------------------------//
reg [7:0] OFM_C_shift; // use shift operation
always @(*) begin
    case (OFM_C)
        'd2 : begin
            OFM_C_shift = 'h1;
        end
        'd4: begin
            OFM_C_shift = 'h2;
        end
        'd8: begin
            OFM_C_shift = 'h3;
        end
        'd16: begin
            OFM_C_shift = 'h4;
        end
        'd32: begin
            OFM_C_shift = 'h5;
        end
        'd64: begin
            OFM_C_shift = 'h6;
        end
        'd128: begin
            OFM_C_shift = 'h7;
        end
        default : 
            OFM_C_shift = 'h2;
    endcase
end




//---------------------------------------------------IFM---------------------------------------------------------//
// FSM State Register
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        current_state_IFM <= START_ADDR_IFM;
    else
        current_state_IFM <= next_state_IFM;
end

/////////////////////// FSM Next State Logic ///////////////////////
always @(*) begin
    case (current_state_IFM)
        START_ADDR_IFM: begin
            if ( ready && count_for_a_OFM ==0 ) begin
                next_state_IFM =    FETCH_WINDOW ;
            end else begin
                next_state_IFM =    START_ADDR_IFM;
                
            end
            addr_valid_ifm  = 1'b0;
        end

        FETCH_WINDOW: begin
            
            if ( count_for_a_Window < num_of_KERNEL_points * num_of_tiles * num_of_tiles_for_PE  -1) begin
            //if ( count_for_a_Window <  (num_of_KERNEL_points << (IFM_C_shift - num_of_mul_in_PE_shift + OFM_C_shift - total_PE_shift) ) -1 ) begin
                next_state_IFM =    FETCH_WINDOW ;
            end else begin
                next_state_IFM =    NEXT_WINDOW;
            end
            addr_valid_ifm  = 1'b1;
            // if ( count_for_a_OFM == OFM_W*OFM_W ) done_compute    =  1;
            // else done_compute    =  0;
        end

        NEXT_WINDOW: begin

            if (count_for_a_OFM < OFM_W*OFM_W -1 )   begin
                next_state_IFM  =   FETCH_WINDOW ;
                
            end else begin
                next_state_IFM  =    START_ADDR_IFM;
                
            end
            addr_valid_ifm  = 1'b1;
        end

        default: begin
            next_state_IFM  = START_ADDR_IFM;
            addr_valid_ifm  = 1'b0;
        end

    endcase
end
/////////////////////// stride logic  ///////////////////////
reg [31:0] stride_offset_for_col;
always @(*) begin  
    case ( stride )
    'h1: stride_offset_for_col  =   0;
    'h2: // stride_offset_for_col  =   ( IFM_W << (stride_shift-1) << IFM_C_shift );
            stride_offset_for_col  =   ( (IFM_W << (stride_shift-1)) * IFM_C );
    endcase
end

reg [7:0] skip_a_pixel;
always @(*) begin  
    case ( IFM_W[0] )
    
    'b0: begin 
        if (stride ==2) skip_a_pixel    =   IFM_C;
        else            skip_a_pixel    =   'h0;
    end
    'b1: begin 
                        skip_a_pixel    =   'h0;
    end
    endcase
end
                
/////////////////////// FSM Output Logic ///////////////////////
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        predict_line_addr_fetch_ifm         <= 'h0;
        predict_window_addr_fetch_ifm       <= 'h0;
        predict_window_OFM_addr_fetch_ifm   <= 'h0;
        done_window                         <= 'h0;

    end
    else begin

        //if ( (row_index_KERNEL == (KERNEL_W  << num_of_tiles_shift) -4 )  ) begin 
        if ( (row_index_KERNEL == (KERNEL_W  *num_of_tiles) -4 )  ) begin 
            if ( col_index_KERNEL != (KERNEL_W -1))
            //predict_line_addr_fetch_ifm         <= predict_line_addr_fetch_ifm + (IFM_W << IFM_C_shift ) ;
            predict_line_addr_fetch_ifm         <= predict_line_addr_fetch_ifm + (IFM_W *IFM_C ) ;
            else 
            predict_line_addr_fetch_ifm         <= window_start_addr_ifm  ;
        end

        //if ( (row_index_KERNEL == (KERNEL_W  << num_of_tiles_shift) -3 ) && ( col_index_KERNEL == KERNEL_W -1  )  && ( tiles_count == num_of_tiles_for_PE -1  ) ) begin 
        if ( (row_index_KERNEL == (KERNEL_W  * num_of_tiles) -3 ) && ( col_index_KERNEL == KERNEL_W -1  )  && ( tiles_count == num_of_tiles_for_PE -1  ) ) begin 
            predict_window_addr_fetch_ifm       <= window_start_addr_ifm + ( IFM_C << stride_shift );
            predict_line_addr_fetch_ifm         <= window_start_addr_ifm + ( IFM_C << stride_shift );
        end
        
        //if ( (row_index_KERNEL == (KERNEL_W << num_of_tiles_shift) -2 ) && ( col_index_KERNEL == KERNEL_W -1  ) && ( tiles_count == num_of_tiles_for_PE -1  ) && ( row_index_OFM == OFM_W -1 ) ) begin
        if ( (row_index_KERNEL == (KERNEL_W * num_of_tiles) -2 ) && ( col_index_KERNEL == KERNEL_W -1  ) && ( tiles_count == num_of_tiles_for_PE -1  ) && ( row_index_OFM == OFM_W -1 ) ) begin 
            // predict_window_OFM_addr_fetch_ifm   <= window_start_addr_ifm + ( KERNEL_W << IFM_C_shift ) + stride_offset_for_col + skip_a_pixel;
            // predict_window_addr_fetch_ifm       <= window_start_addr_ifm + ( KERNEL_W << IFM_C_shift ) + stride_offset_for_col + skip_a_pixel;
            // predict_line_addr_fetch_ifm         <= window_start_addr_ifm + ( KERNEL_W << IFM_C_shift ) + stride_offset_for_col + skip_a_pixel;
            predict_window_OFM_addr_fetch_ifm   <= window_start_addr_ifm + ( KERNEL_W *IFM_C ) + stride_offset_for_col + skip_a_pixel;
            predict_window_addr_fetch_ifm       <= window_start_addr_ifm + ( KERNEL_W *IFM_C ) + stride_offset_for_col + skip_a_pixel;
            predict_line_addr_fetch_ifm         <= window_start_addr_ifm + ( KERNEL_W *IFM_C ) + stride_offset_for_col + skip_a_pixel;
        end
        if ( ( row_index_KERNEL == 'h0 )&& ( col_index_KERNEL ==  'h0 )  ) begin 
            done_window <= 'b1;
            if (count_for_a_OFM =='h0 && count_for_a_Window=='h0 && tiles_count=='h0)
                finish_for_PE <='h0;
            else
                finish_for_PE<= 'b1;   
        end else begin
            done_window <= 'b0;
            finish_for_PE<= 'b0; 
        end

    end
end

// FSM Output Logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        addr_fetch_ifm          <= addr_in;
        count_for_a_Window      <= 1'b0;
        row_index_KERNEL        <= 8'b0;
        count_for_a_OFM         <= 8'b0;
        col_index_KERNEL        <= 8'b0;
        row_index_OFM           <= 8'b0;
        col_index_OFM           <= 8'b0;
        tiles_count             <= 8'b0;
        done_compute            <= 1'h0;
        window_start_addr_ifm   <= 8'h0;
    end else begin
        case (current_state_IFM)
            START_ADDR_IFM: begin
                done_compute    <=  0;
                if ( ready ) begin
                    row_index_KERNEL        <= 8'b0;
                    col_index_KERNEL        <= 8'b0;
                    col_index_OFM           <= 8'b0;
                    count_for_a_Window      <= 8'b0;
                    window_start_addr_ifm   <= 8'h0;
                    count_for_a_OFM         <=  'h0;
                end else begin
                    addr_fetch_ifm          <= addr_in;
                    count_for_a_Window      <= 1'b0;
                    row_index_KERNEL        <= 8'b0;
                    count_for_a_OFM         <= 8'b0;
                    col_index_KERNEL        <= 8'b0;
                    row_index_OFM           <= 8'b0;
                    col_index_OFM           <= 8'b0;
                    tiles_count             <= 8'b0;
                    done_compute            <= 1'h0;
                    window_start_addr_ifm   <= 8'h0;

                end
                
            end

            FETCH_WINDOW: begin
                count_for_a_Window  <= count_for_a_Window + 'b1;
                
                if ( count_for_a_Window < num_of_KERNEL_points* num_of_tiles * num_of_tiles_for_PE  -1) begin
                //if ( count_for_a_Window < (num_of_KERNEL_points <<  (IFM_C_shift - num_of_mul_in_PE_shift + OFM_C_shift - total_PE_shift))   -1) begin
                    //if (row_index_KERNEL    <   KERNEL_W * num_of_tiles -1 ) begin  
                    //if (row_index_KERNEL    <   (KERNEL_W << num_of_tiles_shift) -1 ) begin  
                    if (row_index_KERNEL    <   (KERNEL_W * num_of_tiles) -1 ) begin 
                        row_index_KERNEL    <= row_index_KERNEL + 1'b1;
                        addr_fetch_ifm      <= addr_fetch_ifm + 'h4;               
                    end  
                    else
                    begin
                        
                        //if (row_index_KERNEL == (KERNEL_W << num_of_tiles_shift) -1) begin
                        if (row_index_KERNEL == (KERNEL_W * num_of_tiles) -1) begin
                        row_index_KERNEL    <= 'b0;
                        addr_fetch_ifm      <= predict_line_addr_fetch_ifm;
                        end
                        if (col_index_KERNEL    <   KERNEL_W -1 ) begin
                            col_index_KERNEL    <= col_index_KERNEL + 1'b1;
                        end
                        else
                        begin
                            col_index_KERNEL    <= 'b0;
                            if ( tiles_count    <   num_of_tiles_for_PE)  begin  
                                tiles_count     <=  tiles_count +1'b1 ;
                                
                            end
                        end
                    
                    end
                end else begin
                    addr_fetch_ifm          <=   predict_window_addr_fetch_ifm ;
                    count_for_a_Window      <= 'b0;
                    row_index_KERNEL        <= 'b0;
                    col_index_KERNEL        <= 'b0;
                end
            end 

            NEXT_WINDOW: begin
                
                count_for_a_OFM             <= count_for_a_OFM + 'b1;
                tiles_count                 <= 0;
                window_start_addr_ifm       <= predict_window_addr_fetch_ifm;

                if (row_index_KERNEL == 0)      row_index_KERNEL    <= row_index_KERNEL +1;
                if (count_for_a_Window == 0)    count_for_a_Window  <= count_for_a_Window +1;    

                if (count_for_a_OFM    <   OFM_W*OFM_W-1) begin
                    if ( row_index_OFM < OFM_W-1) begin
                        addr_fetch_ifm          <= addr_fetch_ifm +'h4 ;
                        row_index_OFM           <= row_index_OFM +1;
                    end
                    else
                    begin
                        addr_fetch_ifm          <= addr_fetch_ifm +'h4 ;
                        col_index_OFM           <= col_index_OFM + 1'b1;   
                        row_index_OFM           <=  0;
                        if ( col_index_OFM < OFM_W) begin
                            
                        end
                        else 
                        begin
                            
                        end
                    end

                end else begin    
                     if ( count_for_a_OFM >= OFM_W*OFM_W-1 ) done_compute    <=  1;
                        else done_compute    <=  0;
                end
                if (count_for_a_OFM >= OFM_W*OFM_W -1 )   begin
                    
                end else begin
        
                end
                
            end

            default: begin
                addr_fetch_ifm          <= addr_in ;
            end
        endcase
    end
end




assign req_addr_out_ifm = addr_fetch_ifm;


//---------------------------------------------------WEIGHT---------------------------------------------------------//
// FSM State Register
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        current_state_FILTER <= START_ADDR_FILTER;
    else
        current_state_FILTER <= next_state_FILTER;
end


// FSM Next State Logic
always @(*) begin
    case (current_state_FILTER)
        START_ADDR_FILTER: begin

            if ( ready ) begin
                next_state_FILTER   =  FETCH_FILTER ;
                
            end else begin
                next_state_FILTER   = START_ADDR_FILTER;
            end

        end
        FETCH_FILTER: begin
         
            if (count_for_a_Window <  num_of_KERNEL_points * num_of_tiles * num_of_tiles_for_PE  -1) begin
            //if ( count_for_a_Window < (num_of_KERNEL_points <<  (IFM_C_shift - num_of_mul_in_PE_shift + OFM_C_shift - total_PE_shift))   -1) begin
                if (ready) begin
                    next_state_FILTER   = FETCH_FILTER;
                end else begin
                    next_state_FILTER   = START_ADDR_FILTER;
                end
            end else begin
                next_state_FILTER   = START_ADDR_FILTER;
            end
        end
        default: 
                next_state_FILTER   = START_ADDR_FILTER;
    endcase
end


// FSM Output Logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        addr_fetch_filter   <= addr_in;
    end else begin
        case (current_state_FILTER)
            START_ADDR_FILTER: begin
                if ( ready ) begin
                    window_start_addr_filter    <=  addr_fetch_filter;
                    if ( addr_valid_ifm ==1 )  addr_fetch_filter    <=  addr_fetch_filter + 'h4; 
                end 
                else begin
                    addr_fetch_filter <= 'h0;
                end
            end

            FETCH_FILTER: begin
                if ( addr_valid_ifm ==1 ) begin
                    if (count_for_a_Window ==  (num_of_KERNEL_points * num_of_tiles * num_of_tiles_for_PE  -1)) begin
                    //if ( count_for_a_Window == (num_of_KERNEL_points <<  (IFM_C_shift - num_of_mul_in_PE_shift + OFM_C_shift - total_PE_shift)) -1 ) begin
                    addr_fetch_filter           <=  addr_in;
                    end else
                    addr_fetch_filter           <= addr_fetch_filter + 'h4;  
                end                 
            end
            default: begin
                addr_fetch_filter  <= 'b0;
                
            end
        endcase
    end
end

assign addr_valid_filter   = addr_valid_ifm;
assign req_addr_out_filter = addr_fetch_filter;


endmodule