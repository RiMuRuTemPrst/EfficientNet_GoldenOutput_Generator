address_generator addr_gen(
.clk(clk),
.rst_n(rst_n),
.KERNEL_W(KERNEL_W_layer1),
.OFM_W(OFM_W_layer1),
.OFM_C(OFM_C_layer1),
.IFM_C(IFM_C_layer1),
.IFM_W(IFM_W_layer1),
.stride(stride_layer1),
//.ready(cal_start),
.ready(cal_start_ctl),
.addr_in(base_addr),
.req_addr_out_filter(addr_wei_Conv1x1),
.req_addr_out_ifm(addr_IFM_Conv1x1),
.done_compute(done_compute),
.done_window(done_window_one_bit),
.finish_for_PE(finish_for_PE),
.addr_valid_filter(addr_valid),
.num_of_tiles_for_PE(tile)
);


reg [3:0] KERNEL_W_Conv1x1;
reg [7:0] OFM_W_Conv1x1;
reg [7:0] OFM_C_Conv1x1;
reg [7:0] IFM_C_Conv1x1;
reg [7:0] IFM_W_Conv1x1;
reg [1:0] stride_Conv1x1;


