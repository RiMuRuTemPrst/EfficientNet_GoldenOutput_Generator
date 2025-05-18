module filter_for_bram(
    input clk,
    input reset_n,
    input [31:0] addr_in,
    input [31:0] bound_range,
    input [19:0] size_row,
    output logic [1:0] status,
    input ready,
     
    output logic  [31:0] addr_out
);
    reg [31:0] base_addr;
    always_ff @(posedge clk or negedge reset_n) begin
        if(~reset_n) begin
            base_addr <= 0;
            status <= 0;
        end
        else begin
            if(ready) begin
            // count for pixel
               if(addr_in > base_addr + bound_range + bound_range )
                base_addr <= base_addr + bound_range ;
            end
        end
    end

    always_comb begin  
        if (addr_in < base_addr + bound_range) 
            addr_out = addr_in - base_addr ;
        else addr_out = addr_in - base_addr - bound_range;
    end

endmodule