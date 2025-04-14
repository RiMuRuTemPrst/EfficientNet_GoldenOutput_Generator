module Pooling_average_tb;

    // Parameters
    parameter SIZE28_28 = 784;
    parameter SIZE14_14 = 196;
    parameter SIZE7x7 = 49;

    // Inputs
    reg clk;
    reg reset_n;
    reg [8:0] data_in;
    reg valid;
    reg size;

    // Outputs
    wire [8:0] data;
    wire valid_data_out;

    // Instantiate the Pooling_average module
    Pooling_average uut (
        .clk(clk),
        .reset_n(reset_n),
        .data_in(data_in),
        .valid(valid),
        .size(size),
        .data(data),
        .valid_data_out(valid_data_out)
    );

    // Clock Generation
    always begin
        #5 clk = ~clk; // Generate clock with 10 time unit period
    end

    // Test Stimulus
    initial begin
        // Initialize Inputs
        clk = 0;
        reset_n = 0;
        data_in = 0;
        valid = 0;
        size = SIZE28_28;

        // Apply reset
        #10;
        reset_n = 1;
        
        // Test with SIZE28_28
        #10;
        valid = 1;
        for (int i = 0; i < SIZE28_28; i = i + 1) begin
            data_in = i; // Test with increasing values
            #10; // Wait for clock to toggle
        end
        #10;
        valid = 0;

        // Test with SIZE14_14
        #10;
        size = SIZE14_14;
        valid = 1;
        for (int i = 0; i < SIZE14_14; i = i + 1) begin
            data_in = i;
            #10;
        end
        #10;
        valid = 0;

        // Test with SIZE7x7
        #10;
        size = SIZE7x7;
        valid = 1;
        for (int i = 0; i < SIZE7x7; i = i + 1) begin
            data_in = i;
            #10;
        end
        #10;
        valid = 0;

        // Finish simulation
        #10;
        $finish;
    end

    // Monitor Outputs
    initial begin
        $monitor("Time: %0t | data_in: %0d | data: %0d | valid_data_out: %0d | size: %0d", 
                 $time, data_in, data, valid_data_out, size);
    end

endmodule
