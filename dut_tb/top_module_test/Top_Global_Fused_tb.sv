module Top_Global_Fused_tb;
    // Clock and Reset
    logic clk;
    logic reset_n;

    // Inputs to DUT
    logic [31:0] base_addr_IFM;
    logic [31:0] size_IFM;
    logic [31:0] base_addr_Weight_layer_1;
    logic [31:0] size_Weight_layer_1;
    logic [31:0] base_addr_Weight_layer_2;
    logic [31:0] size_Weight_layer_2;
    logic [31:0] wr_addr_global_initial;
    logic [31:0] rd_addr_global_initial;
    logic [127:0] data_load_in_global;
    logic we_global_initial;
    logic load_phase;
    logic start;

    // Instantiate DUT
    Top_Global_Fused dut (
        .clk(clk),
        .reset_n(reset_n),
        .base_addr_IFM(base_addr_IFM),
        .size_IFM(size_IFM),
        .base_addr_Weight_layer_1(base_addr_Weight_layer_1),
        .size_Weight_layer_1(size_Weight_layer_1),
        .base_addr_Weight_layer_2(base_addr_Weight_layer_2),
        .size_Weight_layer_2(size_Weight_layer_2),
        .wr_addr_global_initial(wr_addr_global_initial),
        .rd_addr_global_initial(rd_addr_global_initial),
        .data_load_in_global(data_load_in_global),
        .we_global_initial(we_global_initial),
        .start(start),
        .load_phase(load_phase)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        reset_n = 0;
        base_addr_IFM = 32'h0000_0000;
        size_IFM = 32'h24BFF;
        base_addr_Weight_layer_1 = 32'h24BFF;
        size_Weight_layer_1 = 32'h3400;
        base_addr_Weight_layer_2 = 32'h0020_0000;
        size_Weight_layer_2 = 32'h2400;
        wr_addr_global_initial = 32'd0;
        rd_addr_global_initial = 32'd0;
        data_load_in_global = 128'hDEADBEEF_CAFECAFE_BADC0DE0_12345678;
        we_global_initial = 0;
        load_phase = 0;
        start = 0;

        // Apply reset
        #20;
        reset_n = 1;

        // Phase 1: Load data into global BRAM
        #10;
        load_phase = 1;
        we_global_initial = 1;
        repeat(1000) begin 
            @(posedge clk) 
            wr_addr_global_initial = wr_addr_global_initial + 1;
        end
        // Pulse write enable for 1 cycle
        #10;
        we_global_initial = 0;
        start = 1;
        // Wait for a few cycles
        #20;

        // Phase 2: Turn off load_phase for your later dev work
        load_phase = 0;

        // You can add assertions or further logic here
        #1000000;

        $finish;
    end
endmodule
