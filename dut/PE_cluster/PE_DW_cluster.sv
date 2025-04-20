module PE_DW_cluster(
    input  wire        clk,
    input  wire        reset_n,
    // 3 cặp IFM và Weightt
    input  wire [7:0]  Weight_0,
    input  wire [7:0]  Weight_1,
    input  wire [7:0]  Weight_2,
    input  wire [7:0]  Weight_3,

    input  wire [31:0]  IFM,

    // Tín hiệu điều khiển
    input  wire  PE_reset,      
    input  wire  PE_finish, 
    // Output
    output wire [7:0]  OFM_0,
    output wire [7:0]  OFM_1,
    output wire [7:0]  OFM_2,
    output wire [7:0]  OFM_3,
    output wire [3:0] valid
);
    mono_PE PE_inst_0(
    .clk(clk),
    .reset_n(reset_n),
    .IFM(IFM[31:24]),
    .Weight(Weight_3),
    .OFM(OFM_3),
    .PE_reset(PE_reset),
    .PE_finish(PE_finish)
    );
    mono_PE PE_inst_1(
    .clk(clk),
    .reset_n(reset_n),
    .IFM(IFM[23:16]),
    .Weight(Weight_2),
    .OFM(OFM_2),
    .PE_reset(PE_reset),
    .PE_finish(PE_finish)
    );
    mono_PE PE_inst_2(
    .clk(clk),
    .reset_n(reset_n),
    .IFM(IFM[15:8]),
    .Weight(Weight_1),
    .OFM(OFM_1),
    .PE_reset(PE_reset),
    .PE_finish(PE_finish)
    );
    mono_PE PE_inst_3(
    .clk(clk),
    .reset_n(reset_n),
    .IFM(IFM[7:0]),
    .Weight(Weight_0),
    .OFM(OFM_0),
    .PE_reset(PE_reset),
    .PE_finish(PE_finish)
    );
    

endmodule