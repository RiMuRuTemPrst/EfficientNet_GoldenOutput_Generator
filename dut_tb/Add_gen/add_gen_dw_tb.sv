module address_generator_dw_tb;

  // Parameters
  parameter TOTAL_PE = 4;
  parameter DATA_WIDTH = 32;

  // Inputs
  reg clk;
  reg rst_n;
  reg [3:0] KERNEL_W;
  reg [7:0] OFM_W;
  reg [7:0] OFM_C;
  reg [7:0] IFM_C;
  reg [7:0] IFM_W;
  reg [1:0] stride;
  reg ready;
  reg [31:0] addr_in;
  reg [31:0] addr_IFM;
  reg [31:0] addr_Wei;

  // Outputs
  wire [31:0] req_addr_out_ifm;
  wire [31:0] req_addr_out_filter;
  wire done_compute;
  wire finish_for_PE;
  wire addr_valid_ifm;
  wire done_window;
  wire addr_valid_filter;
  wire [7:0] num_of_tiles_for_PE;

  integer i,j,k,m,k1=0;
  integer ofm_file[15:0];
  reg [7:0]ofm_data;
  reg [7:0] input_data_mem [0:53823]; // BRAM input data
  reg [7:0] input_data_mem0 [0:287];
  reg [7:0] input_data_mem1 [0:287];
  reg [7:0] input_data_mem2 [0:287];
  reg [7:0] input_data_mem3 [0:287];

  wire finish_for_PE_cluster;
  wire valid;

  // Instantiate the DUT (Device Under Test)
  address_generator_dw #(
    .TOTAL_PE(TOTAL_PE),
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .KERNEL_W(KERNEL_W),
    .OFM_W(OFM_W),
    .OFM_C(OFM_C),
    .IFM_C(IFM_C),
    .IFM_W(IFM_W),
    .stride(stride),
    .ready(ready),
    .addr_in(addr_in),
    .req_addr_out_ifm(req_addr_out_ifm),
    .req_addr_out_filter(req_addr_out_filter),
    .done_compute(done_compute),
    .finish_for_PE(finish_for_PE),
    .addr_valid_ifm(addr_valid_ifm),
    .done_window(done_window),
    .addr_valid_filter(addr_valid_filter),
    .num_of_tiles_for_PE(num_of_tiles_for_PE)
  );

  reg wr_rd_en_IFM;
  reg [31:0] data_in_IFM;
  reg [31:0] wr_addr_IFM;
  wire [31:0] IFM_data;


  BRAM_IFM IFM_BRAM(
        .clk(clk),
        .rd_addr(req_addr_out_ifm),
        .wr_addr(addr_IFM),
        .wr_rd_en(wr_rd_en_IFM),
        //.wr_rd_en(wr_rd_req_IFM),
        .data_in(data_in_IFM),
        .data_out(IFM_data)
    );


  reg [19:0] addr_w;
  reg [31:0] wr_addr_Weight;
  reg        wr_rd_en_Weight;
  wire [31:0] Weight_0;
  wire [31:0] Weight_1;
  wire [31:0] Weight_2;
  wire [31:0] Weight_3;
  reg [7:0] data_in_Weight_0;
  reg [7:0] data_in_Weight_1;
  reg [7:0] data_in_Weight_2;
  reg [7:0] data_in_Weight_3;


  BRAM #(
    .DATA_WIDTH(8),
    .off_set_shift(0)
    )BRam_Weight_0_layer1(
        .clk(clk),
        .rd_addr(req_addr_out_filter),
        .wr_addr(addr_Wei),
        .wr_rd_en(wr_rd_en_Weight),
        //.wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_0),
        .data_out(Weight_0)
    );
  BRAM #(
    .DATA_WIDTH(8),
    .off_set_shift(0)
    )BRam_Weight_1_DW(
        .clk(clk),
        .rd_addr(req_addr_out_filter),
        .wr_addr(addr_Wei),
        .wr_rd_en(wr_rd_en_Weight),
        //.wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_1),
        .data_out(Weight_1)
    );
  BRAM #(
    .DATA_WIDTH(8),
    .off_set_shift(0)
    )BRam_Weight_2_DW(
        .clk(clk),
        .rd_addr(req_addr_out_filter),
        .wr_addr(addr_Wei),
        .wr_rd_en(wr_rd_en_Weight),
        //.wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_2),
        .data_out(Weight_2)
    );
  BRAM #(
    .DATA_WIDTH(8),
    .off_set_shift(0)
    )BRam_Weight_3_DW(
        .clk(clk),
        .rd_addr(req_addr_out_filter),
        .wr_addr(addr_Wei),
        .wr_rd_en(wr_rd_en_Weight),
        //.wr_rd_en(wr_rd_req_Weight),
        .data_in(data_in_Weight_3),
        .data_out(Weight_3)
    );     

  wire [7:0]  OFM_0;
  wire [7:0]  OFM_1;
  wire [7:0]  OFM_2;
  wire [7:0]  OFM_3;

  assign finish_for_PE_cluster            =   (ready) && ( req_addr_out_ifm != 'b0 )   ? done_compute : 1'b0;
  assign valid                            =   finish_for_PE_cluster;

  PE_DW_cluster PE_DW(
    .clk(clk),
    .reset_n(rst_n),
    .Weight_0(Weight_0),
    .Weight_1(Weight_1),
    .Weight_2(Weight_2),
    .Weight_3(Weight_3),
    .IFM(IFM_data),
    .PE_reset(done_window),
    .PE_finish(),
    .OFM_0(OFM_0),
    .OFM_1(OFM_1),
    .OFM_2(OFM_2),
    .OFM_3(OFM_3),
    .valid()
);

  // Clock generation
  always begin
    clk = 0;
    #5 clk = 1;
    #5 clk = 0;
  end
  int input_size = 10*10*16;
  int tile = 4;
  // Test process
  initial begin
    // Initialize signals
    // Reset phase
    KERNEL_W = 3;  // 3x3 kernel
    OFM_W = 4;    // Output Feature Map Width
    OFM_C = 16;    // Output Feature Map Channels
    IFM_C = OFM_C;    // Input Feature Map Channels
    IFM_W = 10;    // Input Feature Map Width
    stride = 2;    // Stride 2
    tile = OFM_C/4;
    ready = 0;
    addr_in = 32'h0;
    rst_n = 0;

    wr_rd_en_IFM = 0;
    wr_rd_en_Weight = 0;

    #30
    rst_n = 1;

    
    addr_IFM = 0;
    addr_Wei  = 0;
    data_in_IFM = 0;
    data_in_Weight_0 = 0;
    data_in_Weight_1 = 0;
    data_in_Weight_2 = 0;
    data_in_Weight_3 = 0;


    

    $readmemh("/home/thanhdo/questasim/PE/Fused-Block-CNN/address/ifm_padded.hex", input_data_mem);

    $readmemh("/home/thanhdo/questasim/PE/Fused-Block-CNN/address/weight_PE0.hex", input_data_mem0);
    $readmemh("/home/thanhdo/questasim/PE/Fused-Block-CNN/address/weight_PE1.hex", input_data_mem1);
    $readmemh("/home/thanhdo/questasim/PE/Fused-Block-CNN/address/weight_PE2.hex", input_data_mem2);
    $readmemh("/home/thanhdo/questasim/PE/Fused-Block-CNN/address/weight_PE3.hex", input_data_mem3);

    fork
            begin
                // Write data into BRAM
                for (i = 0; i < input_size+1; i = i + 4) begin
                    addr_IFM = i >> 2;  // Chia 4 vì mỗi lần lưu 32-bit
                    data_in_IFM = {input_data_mem[i], input_data_mem[i+1], input_data_mem[i+2], input_data_mem[i+3]};
                    wr_rd_en_IFM =1;
                    #10;
                end
                wr_rd_en_IFM = 0;
            end
            begin
                for (j = 0; j < KERNEL_W*KERNEL_W*4 +1; j = j + 1) begin

                    addr_Wei <= j;  // Chia 4 vì mỗi lần lưu 32-bit
                    data_in_Weight_0 = {input_data_mem0 [j]};
                    data_in_Weight_1 = {input_data_mem1 [j]};
                    data_in_Weight_2 = {input_data_mem2 [j]};
                    data_in_Weight_3 = {input_data_mem3 [j]};
                    wr_rd_en_Weight = 1;
                    #10;
                end
                wr_rd_en_Weight = 0;
            end
        join

    // Start simulation
    repeat (10) @(posedge clk);
    ready = 1;
    repeat (100) @(posedge clk);
    ready = 0;
    repeat (100) @(posedge clk);
    ready = 1;
    @(posedge done_compute);

    // Finish simulation
    #50;
    $stop;
  end
  initial begin
        for (k = 0; k < 4; k = k + 1) begin
             ofm_file[k] = $fopen($sformatf("/home/thanhdo/questasim/PE/Fused-Block-CNN/address/OFM_PE%0d_DUT.hex", k), "w");
            if (ofm_file[k] == 0) begin
                $display("Error opening file OFM_PE%d.hex", k); 
                $finish;  
            end
        end


    end

    always @(posedge clk) begin
      if (valid == 16'hFFFF) begin
          // Lưu giá trị OFM vào các file tương ứng
          //count_for_layer_1 = count_for_layer_1 + 1;
          for (k = 0; k < 4; k = k + 1) begin
              ofm_data = OFM_0;  // Lấy giá trị OFM từ output
              // Ghi từng byte của OFM vào các file
              //ofm_data_byte = ofm_data;
              //if (ofm_file[1] != 0) begin
              //$display("check");
                  $fwrite(ofm_file[k], "%h\n", ofm_data);  // Ghi giá trị từng byte vào file
                  
            // end
              //ofm_data = ofm_data >> 8;  // Dịch 8 bit cho đến khi hết 32-bit
          end
      end
    end

endmodule