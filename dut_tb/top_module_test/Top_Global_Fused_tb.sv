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

    logic [31:0] base_addr_OFM;
    logic [31:0] wr_addr_global_initial;
    logic [31:0] rd_addr_global_initial;
    logic [127:0] data_load_in_global;
  
    logic we_global_initial;
    logic load_phase;
    logic start;

    logic write_block_2;
    logic write_block_3;
    logic write_block_4;
    //input of size 
    logic [3:0] KERNEL_W;
    logic [15:0] OFM_W;
    logic [15:0] OFM_C;
    logic [15:0] IFM_C;
    logic [15:0] IFM_W;
    logic [1:0] stride;
    logic [15:0] IFM_C_layer2;
    logic [15:0] OFM_C_layer2;
    logic [15:0] OFM_W_layer2;
    int sw_index_load_mem;
    reg [7:0] input_data_mem [0:1000000];


    // value for count
    int h = 0;
    int k = 0;
    int m = 0;
    int n = 0;
    // value immediate
    reg [31:0] ofm_data_1;
    reg [31:0] ofm_data_2;
    reg [31:0] ofm_data_3;
    reg [31:0] ofm_data_4;

    reg [7:0] ofm_data_byte_1;
    reg [7:0] ofm_data_byte_2;
    reg [7:0] ofm_data_byte_3;
    reg [7:0] ofm_data_byte_4;

    wire [7:0] OFM[15:0];
    wire [7:0] OFM_n_state [3:0];
    wire [7:0] OFM_3[15:0];
    wire [7:0] OFM_n_state_4 [3:0];

    reg [31:0] ofm_data_5;
    reg [31:0] ofm_data_6;
    reg [31:0] ofm_data_7;
    reg [31:0] ofm_data_8;

    reg [7:0] ofm_data_byte_5;
    reg [7:0] ofm_data_byte_6;
    reg [7:0] ofm_data_byte_7;
    reg [7:0] ofm_data_byte_8;

    wire [7:0] OFM_5[15:0];
    wire [7:0] OFM_n_state_6 [3:0];
    wire [7:0] OFM_7[15:0];
    wire [7:0] OFM_n_state_8 [3:0];

    logic start_layer_2;
    logic start_layer_3;
    //handle for file 
    integer ofm_file_1[15:0];
    integer ofm_file_2[3:0];
    integer ofm_file_3[15:0];
    integer ofm_file_4[3:0];
    integer ofm_file_5[15:0];
    integer ofm_file_6[3:0];
    integer ofm_file_7[15:0];
    integer ofm_file_8[3:0];

    // Instantiate DUT
    New_Top_Global_Fused dut (
        .clk(clk),
        .reset_n(reset_n),
        .base_addr_IFM(base_addr_IFM),
        .size_IFM(size_IFM),
        .base_addr_Weight_layer_1(base_addr_Weight_layer_1),
        .size_Weight_layer_1(size_Weight_layer_1),
        .base_addr_Weight_layer_2(base_addr_Weight_layer_2),
        .size_Weight_layer_2(size_Weight_layer_2),
        .base_addr_OFM(base_addr_OFM),
        .wr_addr_global_initial(wr_addr_global_initial),
        .rd_addr_global_initial(rd_addr_global_initial),
        .data_load_in_global(data_load_in_global),
        .we_global_initial(we_global_initial),
        .start(start),
        .load_phase(load_phase),
        .KERNEL_W(KERNEL_W),
        .OFM_W(OFM_W),
        .OFM_C(OFM_C),
        .IFM_C(IFM_C),
        .IFM_W(IFM_W),
        .IFM_C_layer2(IFM_C_layer2),
        .OFM_C_layer2(OFM_C_layer2),
        .OFM_W_layer2(OFM_W_layer2),
        .stride(stride)
    );
    //assign for debug
    assign OFM_n_state[0] = dut.OFM_0_n_state;
    assign OFM_n_state[1] = dut.OFM_1_n_state;
    assign OFM_n_state[2] = dut.OFM_2_n_state;
    assign OFM_n_state[3] = dut.OFM_3_n_state;

    assign OFM[0] = dut.OFM_0;
    assign OFM[1] = dut.OFM_1;
    assign OFM[2] = dut.OFM_2;
    assign OFM[3] = dut.OFM_3;
    assign OFM[4] = dut.OFM_4;
    assign OFM[5] = dut.OFM_5;
    assign OFM[6] = dut.OFM_6;
    assign OFM[7] = dut.OFM_7;
    assign OFM[8] = dut.OFM_8;
    assign OFM[9] = dut.OFM_9;
    assign OFM[10] = dut.OFM_10;
    assign OFM[11] = dut.OFM_11;
    assign OFM[12] = dut.OFM_12;
    assign OFM[13] = dut.OFM_13;
    assign OFM[14] = dut.OFM_14;
    assign OFM[15] = dut.OFM_15;

    assign OFM_n_state_4[0] = dut.OFM_0_n_state;
    assign OFM_n_state_4[1] = dut.OFM_1_n_state;
    assign OFM_n_state_4[2] = dut.OFM_2_n_state;
    assign OFM_n_state_4[3] = dut.OFM_3_n_state;

    assign OFM_3[0] = dut.OFM_0;
    assign OFM_3[1] = dut.OFM_1;
    assign OFM_3[2] = dut.OFM_2;
    assign OFM_3[3] = dut.OFM_3;
    assign OFM_3[4] = dut.OFM_4;
    assign OFM_3[5] = dut.OFM_5;
    assign OFM_3[6] = dut.OFM_6;
    assign OFM_3[7] = dut.OFM_7;
    assign OFM_3[8] = dut.OFM_8;
    assign OFM_3[9] = dut.OFM_9;
    assign OFM_3[10] = dut.OFM_10;
    assign OFM_3[11] = dut.OFM_11;
    assign OFM_3[12] = dut.OFM_12;
    assign OFM_3[13] = dut.OFM_13;
    assign OFM_3[14] = dut.OFM_14;
    assign OFM_3[15] = dut.OFM_15;

    assign OFM_n_state_6[0] = dut.OFM_0_n_state;
    assign OFM_n_state_6[1] = dut.OFM_1_n_state;
    assign OFM_n_state_6[2] = dut.OFM_2_n_state;
    assign OFM_n_state_6[3] = dut.OFM_3_n_state;

    assign OFM_5[0] = dut.OFM_0;
    assign OFM_5[1] = dut.OFM_1;
    assign OFM_5[2] = dut.OFM_2;
    assign OFM_5[3] = dut.OFM_3;
    assign OFM_5[4] = dut.OFM_4;
    assign OFM_5[5] = dut.OFM_5;
    assign OFM_5[6] = dut.OFM_6;
    assign OFM_5[7] = dut.OFM_7;
    assign OFM_5[8] = dut.OFM_8;
    assign OFM_5[9] = dut.OFM_9;
    assign OFM_5[10] = dut.OFM_10;
    assign OFM_5[11] = dut.OFM_11;
    assign OFM_5[12] = dut.OFM_12;
    assign OFM_5[13] = dut.OFM_13;
    assign OFM_5[14] = dut.OFM_14;
    assign OFM_5[15] = dut.OFM_15;

    assign OFM_n_state_8[0] = dut.OFM_0_n_state;
    assign OFM_n_state_8[1] = dut.OFM_1_n_state;
    assign OFM_n_state_8[2] = dut.OFM_2_n_state;
    assign OFM_n_state_8[3] = dut.OFM_3_n_state;

    assign OFM_7[0] = dut.OFM_0;
    assign OFM_7[1] = dut.OFM_1;
    assign OFM_7[2] = dut.OFM_2;
    assign OFM_7[3] = dut.OFM_3;
    assign OFM_7[4] = dut.OFM_4;
    assign OFM_7[5] = dut.OFM_5;
    assign OFM_7[6] = dut.OFM_6;
    assign OFM_7[7] = dut.OFM_7;
    assign OFM_7[8] = dut.OFM_8;
    assign OFM_7[9] = dut.OFM_9;
    assign OFM_7[10] = dut.OFM_10;
    assign OFM_7[11] = dut.OFM_11;
    assign OFM_7[12] = dut.OFM_12;
    assign OFM_7[13] = dut.OFM_13;
    assign OFM_7[14] = dut.OFM_14;
    assign OFM_7[15] = dut.OFM_15;
    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        reset_n = 0;
        start_layer_2 =0;
        start_layer_3 =0;
        write_block_2 = 0;
        write_block_3 = 0;
        write_block_4 = 0;
        //initial for fused layer 1
        base_addr_IFM = 32'h0000_0000;
        size_IFM = 32'h32C40;
        base_addr_Weight_layer_1 = 32'h32C40;
        size_Weight_layer_1 = 32'h2400;
        base_addr_Weight_layer_2 = 32'h0035040;
        size_Weight_layer_2 = 32'h800;
        base_addr_OFM = 32'h61000;
        wr_addr_global_initial = -1;
        rd_addr_global_initial = 32'd0;
        data_load_in_global = 128'hDEADBEEF_CAFECAFE_ABCDC0DE0_12345678;
        we_global_initial = 0;
        load_phase = 0;
        start = 0;
        sw_index_load_mem = 0;
        KERNEL_W = 3;
        OFM_W = 56;
        OFM_C = 64;
        IFM_C = 16;
        IFM_W = 114;
        stride = 2;
        IFM_C_layer2 = 64;
        OFM_C_layer2 = 32;
        OFM_W_layer2 = 56;
        $readmemh("../Fused-Block-CNN/address/golden_full_fused/hex/global_ram.hex", input_data_mem);
        // Apply reset
        @(posedge clk) 
        @(posedge clk) 
        reset_n = 1;

        // Phase 1: Load data into global BRAM
        @(posedge clk) 
        load_phase = 1;
        we_global_initial = 1;
        repeat(24708) begin 
            @(posedge clk) 
            wr_addr_global_initial = wr_addr_global_initial + 1;
            data_load_in_global = {input_data_mem[sw_index_load_mem + 15],input_data_mem[sw_index_load_mem + 14],input_data_mem[sw_index_load_mem + 13],input_data_mem[sw_index_load_mem + 12],input_data_mem[sw_index_load_mem + 11],input_data_mem[sw_index_load_mem + 10],input_data_mem[sw_index_load_mem + 9],input_data_mem[sw_index_load_mem + 8],input_data_mem[sw_index_load_mem + 7],input_data_mem[sw_index_load_mem + 6],input_data_mem[sw_index_load_mem + 5],input_data_mem[sw_index_load_mem + 4],input_data_mem[sw_index_load_mem + 3],input_data_mem[sw_index_load_mem + 2],input_data_mem[sw_index_load_mem + 1],input_data_mem[sw_index_load_mem + 0]};
            sw_index_load_mem = sw_index_load_mem + 16;
        end
        // Pulse write enable for 1 cycle
        @(posedge clk) 
        we_global_initial = 0;
        start = 1;
        // Wait for a few cycles
        @(posedge clk) 
        @(posedge clk) 
        $display("START FUSED BLOCK 1");
        start = 0;

        // Phase 2: Turn off load_phase for your later dev work
        load_phase = 0;
        @(dut.done_compute_1x1);
        write_block_2 = 1;
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        begin
        $display("DONE FUSED BLOCK 1");
        $display("START FUSED BLOCK 2");
            base_addr_IFM = 32'h61000;
            size_IFM = 32'h1A480;
            base_addr_Weight_layer_1 = 32'h35840;
            size_Weight_layer_1 = 32'h9000;
            base_addr_Weight_layer_2 = 32'h003E840;
            size_Weight_layer_2 = 32'h1000;
            base_addr_OFM = 32'h7B480;
            wr_addr_global_initial = -1;
            rd_addr_global_initial = 32'd0;
            data_load_in_global = 128'hDEADBEEF_CAFECAFE_ABCDC0DE0_12345678;
            we_global_initial = 0;
            load_phase = 0;
            start = 1;
            sw_index_load_mem = 0;
            KERNEL_W = 3;
            OFM_W = 56;
            OFM_C = 128;
            IFM_C = 32;
            IFM_W = 58;
            stride = 1;
            IFM_C_layer2 = 128;
            OFM_C_layer2 = 32;
        end
        @(posedge clk) start = 0;
        @(posedge clk)
        @(posedge clk)
        @(dut.done_compute_1x1);
        write_block_2 = 0;
        write_block_3 = 1;
        $display("DONE FUSED BLOCK 2");
        repeat(100) begin
        @(posedge clk);
        end
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        begin
        // $display("START FUSED BLOCK 3");
        //  begin
        //     base_addr_IFM = 32'h7B480;
        //     size_IFM = 32'h1A480;
        //     base_addr_Weight_layer_1 = 32'h3F840;
        //     size_Weight_layer_1 = 32'h9000;
        //     base_addr_Weight_layer_2 = 32'h48840;
        //     size_Weight_layer_2 = 32'h1800;
        //     base_addr_OFM = 32'h95900;
        //     wr_addr_global_initial = -1;
        //     rd_addr_global_initial = 32'd0;
        //     data_load_in_global = 128'hDEADBEEF_CAFECAFE_ABCDC0DE0_12345678;
        //     we_global_initial = 0;
        //     load_phase = 0;
        //     start = 1;
        //     sw_index_load_mem = 0;
        //     KERNEL_W = 3;
        //     OFM_W = 28;
        //     OFM_C = 128;
        //     IFM_C = 32;
        //     IFM_W = 58;
        //     stride = 2;
        //     IFM_C_layer2 = 128;
        //     OFM_C_layer2 = 48;
        //     OFM_W_layer2 = 28;
        // end
        // @(posedge clk) start = 0;
        // @(posedge clk)
        // @(posedge clk)
        // @(dut.done_compute);
        // write_block_2 = 0;
        // write_block_3 = 0;
        // write_block_4 = 1;
        // @(posedge clk)
        // @(posedge clk)
        // @(posedge clk)
        // @(posedge clk)
        // $display("DONE FUSED BLOCK 3");
        // begin
        // $display("START FUSED BLOCK 4");
        //  begin
        //     base_addr_IFM = 32'h95900;
        //     size_IFM = 32'h0A8C0;
        //     base_addr_Weight_layer_1 = 32'h4A040;
        //     size_Weight_layer_1 = 32'h14400;
        //     base_addr_Weight_layer_2 = 32'h5E440;
        //     size_Weight_layer_2 = 32'h2400;
        //     base_addr_OFM = 32'hA01C0;
        //     wr_addr_global_initial = -1;
        //     rd_addr_global_initial = 32'd0;
        //     data_load_in_global = 128'hDEADBEEF_CAFECAFE_ABCDC0DE0_12345678;
        //     we_global_initial = 0;
        //     load_phase = 0;
        //     start = 1;
        //     sw_index_load_mem = 0;
        //     KERNEL_W = 3;
        //     OFM_W = 28;
        //     OFM_C = 192;
        //     IFM_C = 48;
        //     IFM_W = 30;
        //     stride = 1;
        //     IFM_C_layer2 = 192;
        //     OFM_C_layer2 = 48;
        //     OFM_W_layer2 = 28;
        // end
        // @(posedge clk) start = 0;
        // $display("DONE FUSED BLOCK 4");
        // repeat (5 ) @(posedge clk);
        // @(dut.done_compute);
        // repeat (100 ) @(posedge clk);
        // $finish;
        // end
        // You can add assertions or further logic here
        
    end
    end
//inital for load hex debug
    always @(posedge clk) begin
    if (write_block_2) begin
    if (dut.PE_finish_PE_cluster1x1 == 15) begin
        for (k = 0; k < 4; k = k + 1) begin
            ofm_data_4 = OFM_n_state[k];  // Lấy giá trị OFM từ output
            // Ghi từng byte của OFM vào các file
            ofm_data_byte_4 = ofm_data_4;
            //if (ofm_file[1] != 0) begin
            //$display("check");
                $fwrite(ofm_file_4[k], "%h\n", ofm_data_byte_4);  // Ghi giá trị từng byte vào file
                //$display("check");
                
           // end
            ofm_data_4 = ofm_data_4 >> 8;  // Dịch 8 bit cho đến khi hết 32-bit
        end
    end
    if (dut.valid == 16'hffff) begin
        for (h = 0; h < 16; h = h + 1) begin
            ofm_data_3 = OFM[h];  // Lấy giá trị OFM từ output
            // Ghi từng byte của OFM vào các file
            ofm_data_byte_3 = ofm_data_3;
            //if (ofm_file[1] != 0) begin
            //$display("check");
                $fwrite(ofm_file_3[h], "%h\n", ofm_data_byte_3);  // Ghi giá trị từng byte vào file
                //$display("check");
                
           // end
            ofm_data_3 = ofm_data_3 >> 8;  // Dịch 8 bit cho đến khi hết 32-bit
        end
    end
    end
    else if (write_block_3) begin
    if (dut.PE_finish_PE_cluster1x1 == 15) begin
        for (k = 0; k < 4; k = k + 1) begin
            ofm_data_6 = OFM_n_state[k];  // Lấy giá trị OFM từ output
            // Ghi từng byte của OFM vào các file
            ofm_data_byte_6 = ofm_data_6;
            //if (ofm_file[1] != 0) begin
            //$display("check");
                $fwrite(ofm_file_6[k], "%h\n", ofm_data_byte_6);  // Ghi giá trị từng byte vào file
                //$display("check");
                
           // end
            ofm_data_6 = ofm_data_6 >> 8;  // Dịch 8 bit cho đến khi hết 32-bit
        end
    end
    if (dut.valid == 16'hffff) begin
        for (h = 0; h < 16; h = h + 1) begin
            ofm_data_5 = OFM[h];  // Lấy giá trị OFM từ output
            // Ghi từng byte của OFM vào các file
            ofm_data_byte_5 = ofm_data_5;
            //if (ofm_file[1] != 0) begin
            //$display("check");
                $fwrite(ofm_file_5[h], "%h\n", ofm_data_byte_5);  // Ghi giá trị từng byte vào file
                //$display("check");
                
           // end
            ofm_data_5 = ofm_data_5 >> 8;  // Dịch 8 bit cho đến khi hết 32-bit
        end
    end
    end
    else if (write_block_4) begin
    if (dut.PE_finish_PE_cluster1x1 == 15) begin
        for (k = 0; k < 4; k = k + 1) begin
            ofm_data_8 = OFM_n_state[k];  // Lấy giá trị OFM từ output
            // Ghi từng byte của OFM vào các file
            ofm_data_byte_8 = ofm_data_8;
            //if (ofm_file[1] != 0) begin
            //$display("check");
                $fwrite(ofm_file_8[k], "%h\n", ofm_data_byte_8);  // Ghi giá trị từng byte vào file
                //$display("check");
                
           // end
            ofm_data_8 = ofm_data_8 >> 8;  // Dịch 8 bit cho đến khi hết 32-bit
        end
    end
    if (dut.valid == 16'hffff) begin
        for (h = 0; h < 16; h = h + 1) begin
            ofm_data_7 = OFM[h];  // Lấy giá trị OFM từ output
            // Ghi từng byte của OFM vào các file
            ofm_data_byte_7 = ofm_data_7;
            //if (ofm_file[1] != 0) begin
            //$display("check");
                $fwrite(ofm_file_7[h], "%h\n", ofm_data_byte_7);  // Ghi giá trị từng byte vào file
                //$display("check");
                
           // end
            ofm_data_7 = ofm_data_7 >> 8;  // Dịch 8 bit cho đến khi hết 32-bit
        end
    end
    end
    else begin
    if (dut.PE_finish_PE_cluster1x1 == 15) begin
        for (k = 0; k < 4; k = k + 1) begin
            ofm_data_2 = OFM_n_state[k];  // Lấy giá trị OFM từ output
            // Ghi từng byte của OFM vào các file
            ofm_data_byte_2 = ofm_data_2;
            //if (ofm_file[1] != 0) begin
            //$display("check");
                $fwrite(ofm_file_2[k], "%h\n", ofm_data_byte_2);  // Ghi giá trị từng byte vào file
                //$display("check");
                
           // end
            ofm_data_2 = ofm_data_2 >> 8;  // Dịch 8 bit cho đến khi hết 32-bit
        end
    end
    if (dut.valid == 16'hffff) begin
        for (h = 0; h < 16; h = h + 1) begin
            ofm_data_1 = OFM[h];  // Lấy giá trị OFM từ output
            // Ghi từng byte của OFM vào các file
            ofm_data_byte_1 = ofm_data_1;
            //if (ofm_file[1] != 0) begin
            //$display("check");
                $fwrite(ofm_file_1[h], "%h\n", ofm_data_byte_1);  // Ghi giá trị từng byte vào file
                //$display("check");
                
           // end
            ofm_data_1 = ofm_data_1 >> 8;  // Dịch 8 bit cho đến khi hết 32-bit
        end
    end
    end
end

    //inital for open file 
    initial begin
        for (m = 0; m < 4; m = m + 1) begin
                    ofm_file_2[m] = $fopen($sformatf("../Fused-Block-CNN/address/golden_full_fused/hex/OFM2_PE%0d_DUT.hex", m), "w");
                    if (ofm_file_2[m] == 0) begin
                        $display("Error opening file OFM_PE%d.hex", k);
                        $finish;  
                    end
                end
    end
    initial begin
        for (n = 0; n < 16; n = n + 1) begin
                    ofm_file_1[n] = $fopen($sformatf("../Fused-Block-CNN/address/golden_full_fused/hex/OFM1_PE%0d_DUT.hex", n), "w");
                    if (ofm_file_1[n] == 0) begin
                        $display("Error opening file OFM_PE%d.hex", k);
                        $finish; 
                    end
                end
    end
    initial begin
        for (m = 0; m < 4; m = m + 1) begin
                    ofm_file_4[m] = $fopen($sformatf("../Fused-Block-CNN/address/golden_full_fused/hex/OFM4_PE%0d_DUT.hex", m), "w");
                    if (ofm_file_4[m] == 0) begin
                        $display("Error opening file OFM_PE%d.hex", k);
                        $finish;  
                    end
                end
    end

    initial begin
        for (n = 0; n < 16; n = n + 1) begin
                    ofm_file_3[n] = $fopen($sformatf("../Fused-Block-CNN/address/golden_full_fused/hex/OFM3_PE%0d_DUT.hex", n), "w");
                    if (ofm_file_3[n] == 0) begin
                        $display("Error opening file OFM_PE%d.hex", k);
                        $finish; 
                    end
                end
    end

    initial begin
        for (m = 0; m < 4; m = m + 1) begin
                    ofm_file_6[m] = $fopen($sformatf("../Fused-Block-CNN/address/golden_full_fused/hex/OFM6_PE%0d_DUT.hex", m), "w");
                    if (ofm_file_6[m] == 0) begin
                        $display("Error opening file OFM_PE%d.hex", k);
                        $finish;  
                    end
                end
    end
    initial begin
        for (n = 0; n < 16; n = n + 1) begin
                    ofm_file_7[n] = $fopen($sformatf("../Fused-Block-CNN/address/golden_full_fused/hex/OFM7_PE%0d_DUT.hex", n), "w");
                    if (ofm_file_7[n] == 0) begin
                        $display("Error opening file OFM_PE%d.hex", k);
                        $finish; 
                    end
                end
    end
    initial begin
        for (m = 0; m < 4; m = m + 1) begin
                    ofm_file_8[m] = $fopen($sformatf("../Fused-Block-CNN/address/golden_full_fused/hex/OFM8_PE%0d_DUT.hex", m), "w");
                    if (ofm_file_8[m] == 0) begin
                        $display("Error opening file OFM_PE%d.hex", k);
                        $finish;  
                    end
                end
    end

    initial begin
        for (n = 0; n < 16; n = n + 1) begin
                    ofm_file_5[n] = $fopen($sformatf("../Fused-Block-CNN/address/golden_full_fused/hex/OFM5_PE%0d_DUT.hex", n), "w");
                    if (ofm_file_5[n] == 0) begin
                        $display("Error opening file OFM_PE%d.hex", k);
                        $finish; 
                    end
                end
    end

    //initial for finish
    initial begin
         forever begin
             @(posedge clk)
             if(dut.done_compute) begin
                 start_layer_2 = 0;                
            end
        end
    end
    initial begin
        @(start_layer_2) begin
        $display("DONE FUSED BLOCK 1");
        $display("START FUSED BLOCK 2");
            base_addr_IFM = 32'h0000_0000;
            size_IFM = 32'h1A480;
            base_addr_Weight_layer_1 = 32'h35840;
            size_Weight_layer_1 = 32'h9000;
            base_addr_Weight_layer_2 = 32'h003E840;
            size_Weight_layer_2 = 32'h1000;
            wr_addr_global_initial = -1;
            rd_addr_global_initial = 32'd0;
            data_load_in_global = 128'hDEADBEEF_CAFECAFE_ABCDC0DE0_12345678;
            we_global_initial = 0;
            load_phase = 0;
            start = 1;
            sw_index_load_mem = 0;
            KERNEL_W = 3;
            OFM_W = 56;
            OFM_C = 128;
            IFM_C = 32;
            IFM_W = 58;
            stride = 1;
            IFM_C_layer2 = 128;
            OFM_C_layer2 = 32;
        end
        @(posedge clk) start = 0;
        // repeat(1000000) begin
        //      @(posedge clk) ;
        // end
       
       

    end

    initial begin
         forever begin
             @(posedge clk)
             if (start_layer_2) begin
                if(dut.done_compute) begin
                    $display("DONE FUSED BLOCK 2");
                    start_layer_3 = 0;                
                end
             end
        end
    end

    initial begin
        @(start_layer_3) begin
        $display("START FUSED BLOCK 3");
         begin
            base_addr_IFM = 32'h0000_0000;
            size_IFM = 32'h1A480;
            base_addr_Weight_layer_1 = 32'h3F840;
            size_Weight_layer_1 = 32'h9000;
            base_addr_Weight_layer_2 = 32'h48840;
            size_Weight_layer_2 = 32'h1800;
            wr_addr_global_initial = -1;
            rd_addr_global_initial = 32'd0;
            data_load_in_global = 128'hDEADBEEF_CAFECAFE_ABCDC0DE0_12345678;
            we_global_initial = 0;
            load_phase = 0;
            start = 1;
            sw_index_load_mem = 0;
            KERNEL_W = 3;
            OFM_W = 28;
            OFM_C = 128;
            IFM_C = 32;
            IFM_W = 58;
            stride = 2;
            IFM_C_layer2 = 128;
            OFM_C_layer2 = 48;
            OFM_W_layer2 = 28;
        end
        @(posedge clk) start = 0;
        repeat (100 ) @(posedge clk);
        @(dut.done_compute);
        $display("DONE FUSED BLOCK 3");
        repeat (100 ) @(posedge clk);
        $finish;
        end
    end
endmodule
