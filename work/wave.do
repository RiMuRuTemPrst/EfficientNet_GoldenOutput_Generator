onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/clk
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/reset_n
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/start
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/ready
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/IFM_C
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/IFM_W
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/wr_addr_global
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/rd_addr_global
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/we_global
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/wr_addr_fused
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/rd_addr_fused
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/we_fused
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/base_addr_IFM
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/size_IFM
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/base_addr_Weight_layer_1
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/size_Weight_layer_1
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/base_addr_Weight_layer_2
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/size_Weight_layer_2
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/valid_layer2
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/col_index_OFM
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/size_3
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/size_6
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/size_change
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/done_compute
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/curr_state
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/next_state
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/load_count
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/count_weight_addr
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/load_weight_layer_st
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/load_row_count
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/start_load
add wave -noupdate /Top_Global_Fused_tb/dut/Global_control_unit/load_6
add wave -noupdate /Top_Global_Fused_tb/dut/BRAM_IFM/clk
add wave -noupdate /Top_Global_Fused_tb/dut/BRAM_IFM/wr_rd_en
add wave -noupdate -radix decimal /Top_Global_Fused_tb/dut/BRAM_IFM/wr_addr
add wave -noupdate /Top_Global_Fused_tb/dut/BRAM_IFM/rd_addr
add wave -noupdate /Top_Global_Fused_tb/dut/BRAM_IFM/data_in
add wave -noupdate /Top_Global_Fused_tb/dut/BRAM_IFM/data_out
add wave -noupdate /Top_Global_Fused_tb/dut/BRAM_Global/clk
add wave -noupdate /Top_Global_Fused_tb/dut/BRAM_Global/wr_rd_en
add wave -noupdate /Top_Global_Fused_tb/dut/BRAM_Global/wr_addr
add wave -noupdate /Top_Global_Fused_tb/dut/BRAM_Global/rd_addr
add wave -noupdate /Top_Global_Fused_tb/dut/BRAM_Global/data_in
add wave -noupdate /Top_Global_Fused_tb/dut/BRAM_Global/data_out
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/clk
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/reset_n
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/Weight_0
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/Weight_1
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/Weight_2
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/Weight_3
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/Weight_4
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/Weight_5
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/Weight_6
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/Weight_7
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/Weight_8
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/Weight_9
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/Weight_10
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/Weight_11
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/Weight_12
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/Weight_13
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/Weight_14
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/Weight_15
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/IFM
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/PE_reset
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/done_window_for_PE_cluster
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/PE_finish
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/OFM_0
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/valid
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/OFM_1
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/OFM_2
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/OFM_3
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/OFM_4
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/OFM_5
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/OFM_6
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/OFM_7
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/OFM_8
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/OFM_9
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/OFM_10
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/OFM_11
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/OFM_12
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/OFM_13
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/OFM_14
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/OFM_15
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/OFM_16
add wave -noupdate -group PE_cluster_layer1 /Top_Global_Fused_tb/dut/PE_cluster_layer1/valid
add wave -noupdate /Top_Global_Fused_tb/dut/addr_gen/count_for_waiting_mux_data
add wave -noupdate -radix unsigned /Top_Global_Fused_tb/dut/addr_gen/count_for_a_OFM
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/clk
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/rst_n
add wave -noupdate -group Addr_gen -radix unsigned /Top_Global_Fused_tb/dut/addr_gen/KERNEL_W
add wave -noupdate -group Addr_gen -radix unsigned /Top_Global_Fused_tb/dut/addr_gen/OFM_W
add wave -noupdate -group Addr_gen -radix unsigned /Top_Global_Fused_tb/dut/addr_gen/OFM_C
add wave -noupdate -group Addr_gen -radix unsigned /Top_Global_Fused_tb/dut/addr_gen/IFM_C
add wave -noupdate -group Addr_gen -radix unsigned /Top_Global_Fused_tb/dut/addr_gen/IFM_W
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/stride
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/ready
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/addr_in
add wave -noupdate -group Addr_gen -radix hexadecimal /Top_Global_Fused_tb/dut/addr_gen/req_addr_out_ifm
add wave -noupdate -group Addr_gen -radix unsigned /Top_Global_Fused_tb/dut/addr_gen/req_addr_out_ifm
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/req_addr_out_filter
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/coef_for_multiply_addr
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/done_compute
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/done_compute_all
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/finish_for_PE
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/addr_valid_ifm
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/done_window
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/addr_valid_filter
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/num_of_tiles_for_PE
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/col_index_OFM
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/in_progress
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/count_for_a_Window
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/count_for_multiply
add wave -noupdate -group Addr_gen -radix unsigned /Top_Global_Fused_tb/dut/addr_gen/count_for_a_OFM
add wave -noupdate -group Addr_gen -radix unsigned /Top_Global_Fused_tb/dut/addr_gen/count_for_a_OFM_in_a_pipeline_tile
add wave -noupdate -group Addr_gen -radix unsigned /Top_Global_Fused_tb/dut/addr_gen/row_index_KERNEL
add wave -noupdate -group Addr_gen -radix unsigned /Top_Global_Fused_tb/dut/addr_gen/col_index_KERNEL
add wave -noupdate -group Addr_gen -radix decimal /Top_Global_Fused_tb/dut/addr_gen/row_index_OFM
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/count_for_waiting_mux_data
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/tiles_count
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/addr_fetch_ifm
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/predict_line_addr_fetch_ifm
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/predict_window_addr_fetch_ifm
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/predict_window_OFM_addr_fetch_ifm
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/addr_fetch_filter
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/window_start_addr_ifm
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/window_start_addr_filter
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/current_state_IFM
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/next_state_IFM
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/current_state_FILTER
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/next_state_FILTER
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/current_state_MULTIPLY
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/next_state_MULTIPLY
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/stride_shift
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/num_of_mul_in_PE_shift
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/num_of_KERNEL_points
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/num_of_OFM_points
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/num_of_tiles
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/num_of_tiles_shift
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/IFM_C_shift
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/OFM_C_shift
add wave -noupdate -group Addr_gen -radix unsigned /Top_Global_Fused_tb/dut/addr_gen/stride_offset_for_col
add wave -noupdate -group Addr_gen /Top_Global_Fused_tb/dut/addr_gen/skip_a_pixel
add wave -noupdate -group BRAM_Global /Top_Global_Fused_tb/dut/BRAM_Global/clk
add wave -noupdate -group BRAM_Global /Top_Global_Fused_tb/dut/BRAM_Global/wr_rd_en
add wave -noupdate -group BRAM_Global /Top_Global_Fused_tb/dut/BRAM_Global/wr_addr
add wave -noupdate -group BRAM_Global /Top_Global_Fused_tb/dut/BRAM_Global/rd_addr
add wave -noupdate -group BRAM_Global /Top_Global_Fused_tb/dut/BRAM_Global/data_in
add wave -noupdate -group BRAM_Global /Top_Global_Fused_tb/dut/BRAM_Global/data_out
add wave -noupdate -group BRAM_IFM /Top_Global_Fused_tb/dut/BRAM_IFM/clk
add wave -noupdate -group BRAM_IFM /Top_Global_Fused_tb/dut/BRAM_IFM/wr_rd_en
add wave -noupdate -group BRAM_IFM /Top_Global_Fused_tb/dut/BRAM_IFM/wr_addr
add wave -noupdate -group BRAM_IFM /Top_Global_Fused_tb/dut/BRAM_IFM/rd_addr
add wave -noupdate -group BRAM_IFM /Top_Global_Fused_tb/dut/BRAM_IFM/data_in
add wave -noupdate -group BRAM_IFM /Top_Global_Fused_tb/dut/BRAM_IFM/data_out
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/clk
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/reset_n
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/IFM1
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/IFM2
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/IFM3
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/IFM4
add wave -noupdate -expand -group PE_inst -color Brown /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/IFM5
add wave -noupdate -expand -group PE_inst -color Brown /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/IFM6
add wave -noupdate -expand -group PE_inst -color Brown /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/IFM7
add wave -noupdate -expand -group PE_inst -color Brown /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/IFM8
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/IFM9
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/IFM10
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/IFM11
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/IFM12
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/IFM13
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/IFM14
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/IFM15
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/IFM16
add wave -noupdate -expand -group PE_inst -color Coral /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/Weight1
add wave -noupdate -expand -group PE_inst -color Coral /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/Weight2
add wave -noupdate -expand -group PE_inst -color Coral /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/Weight3
add wave -noupdate -expand -group PE_inst -color Coral /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/Weight4
add wave -noupdate -expand -group PE_inst -color Brown /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/Weight5
add wave -noupdate -expand -group PE_inst -color Brown /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/Weight6
add wave -noupdate -expand -group PE_inst -color Brown /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/Weight7
add wave -noupdate -expand -group PE_inst -color Brown /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/Weight8
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/Weight9
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/Weight10
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/Weight11
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/Weight12
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/Weight13
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/Weight14
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/Weight15
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/Weight16
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/PE_reset
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/PE_finish
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/OFM
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/valid
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/mul1
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/mul2
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/mul3
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/mul4
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/mul5
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/mul6
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/mul7
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/mul8
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/mul9
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/mul10
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/mul11
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/mul12
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/mul13
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/mul14
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/mul15
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/mul16
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/add1
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/add2
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/add3
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/add4
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/add5
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/add6
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/add7
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/add8
add wave -noupdate -expand -group PE_inst -color Yellow /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/add9
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/add10
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/add11
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/add12
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/add13
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/add14
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/add15
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/sum_d
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/sum_q
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/valid_r
add wave -noupdate -expand -group PE_inst /Top_Global_Fused_tb/dut/PE_cluster_layer1/instant_0/mul_sum
add wave -noupdate -group PE_cluster_1x1 /Top_Global_Fused_tb/dut/PE_cluster_1x1/clk
add wave -noupdate -group PE_cluster_1x1 /Top_Global_Fused_tb/dut/PE_cluster_1x1/reset_n
add wave -noupdate -group PE_cluster_1x1 /Top_Global_Fused_tb/dut/PE_cluster_1x1/Weight_0
add wave -noupdate -group PE_cluster_1x1 /Top_Global_Fused_tb/dut/PE_cluster_1x1/Weight_1
add wave -noupdate -group PE_cluster_1x1 /Top_Global_Fused_tb/dut/PE_cluster_1x1/Weight_2
add wave -noupdate -group PE_cluster_1x1 /Top_Global_Fused_tb/dut/PE_cluster_1x1/Weight_3
add wave -noupdate -group PE_cluster_1x1 /Top_Global_Fused_tb/dut/PE_cluster_1x1/IFM
add wave -noupdate -group PE_cluster_1x1 /Top_Global_Fused_tb/dut/PE_cluster_1x1/PE_reset
add wave -noupdate -group PE_cluster_1x1 /Top_Global_Fused_tb/dut/PE_cluster_1x1/PE_finish
add wave -noupdate -group PE_cluster_1x1 /Top_Global_Fused_tb/dut/PE_cluster_1x1/OFM_0
add wave -noupdate -group PE_cluster_1x1 /Top_Global_Fused_tb/dut/PE_cluster_1x1/OFM_1
add wave -noupdate -group PE_cluster_1x1 /Top_Global_Fused_tb/dut/PE_cluster_1x1/OFM_2
add wave -noupdate -group PE_cluster_1x1 /Top_Global_Fused_tb/dut/PE_cluster_1x1/OFM_3
add wave -noupdate -group PE_cluster_1x1 /Top_Global_Fused_tb/dut/PE_cluster_1x1/valid
add wave -noupdate /Top_Global_Fused_tb/dut/PE_finish_PE_cluster1x1
add wave -noupdate /Top_Global_Fused_tb/dut/PE_finish_PE_cluster1x1_4
add wave -noupdate -group Controller_1x1 /Top_Global_Fused_tb/dut/CONV_1x1_controller_inst/clk
add wave -noupdate -group Controller_1x1 /Top_Global_Fused_tb/dut/CONV_1x1_controller_inst/reset_n
add wave -noupdate -group Controller_1x1 /Top_Global_Fused_tb/dut/CONV_1x1_controller_inst/valid
add wave -noupdate -group Controller_1x1 /Top_Global_Fused_tb/dut/CONV_1x1_controller_inst/weight_c
add wave -noupdate -group Controller_1x1 /Top_Global_Fused_tb/dut/CONV_1x1_controller_inst/num_filter
add wave -noupdate -group Controller_1x1 /Top_Global_Fused_tb/dut/CONV_1x1_controller_inst/cal_start
add wave -noupdate -group Controller_1x1 /Top_Global_Fused_tb/dut/CONV_1x1_controller_inst/addr_ifm
add wave -noupdate -group Controller_1x1 /Top_Global_Fused_tb/dut/CONV_1x1_controller_inst/addr_weight
add wave -noupdate -group Controller_1x1 /Top_Global_Fused_tb/dut/CONV_1x1_controller_inst/PE_reset
add wave -noupdate -group Controller_1x1 /Top_Global_Fused_tb/dut/CONV_1x1_controller_inst/PE_finish
add wave -noupdate -group Controller_1x1 /Top_Global_Fused_tb/dut/CONV_1x1_controller_inst/curr_state
add wave -noupdate -group Controller_1x1 /Top_Global_Fused_tb/dut/CONV_1x1_controller_inst/next_state
add wave -noupdate -group Controller_1x1 /Top_Global_Fused_tb/dut/CONV_1x1_controller_inst/valid_count
add wave -noupdate -group Controller_1x1 /Top_Global_Fused_tb/dut/CONV_1x1_controller_inst/count_deep_pixel
add wave -noupdate -group Controller_1x1 -radix decimal /Top_Global_Fused_tb/dut/CONV_1x1_controller_inst/count_filter
add wave -noupdate -group Controller_1x1 /Top_Global_Fused_tb/dut/CONV_1x1_controller_inst/next_filter
add wave -noupdate -group Controller_1x1 /Top_Global_Fused_tb/dut/CONV_1x1_controller_inst/revert
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/clk
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/reset_n
add wave -noupdate -group PE_1x1_inst -color Yellow /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/IFM1
add wave -noupdate -group PE_1x1_inst -color Yellow /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/IFM2
add wave -noupdate -group PE_1x1_inst -color Yellow /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/IFM3
add wave -noupdate -group PE_1x1_inst -color Yellow /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/IFM4
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/IFM5
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/IFM6
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/IFM7
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/IFM8
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/IFM9
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/IFM10
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/IFM11
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/IFM12
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/IFM13
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/IFM14
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/IFM15
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/IFM16
add wave -noupdate -group PE_1x1_inst -color Orange /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/Weight1
add wave -noupdate -group PE_1x1_inst -color Orange /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/Weight2
add wave -noupdate -group PE_1x1_inst -color Orange /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/Weight3
add wave -noupdate -group PE_1x1_inst -color Orange /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/Weight4
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/Weight5
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/Weight6
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/Weight7
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/Weight8
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/Weight9
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/Weight10
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/Weight11
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/Weight12
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/Weight13
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/Weight14
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/Weight15
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/Weight16
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/PE_reset
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/PE_finish
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/OFM
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/valid
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/mul1
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/mul2
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/mul3
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/mul4
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/mul5
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/mul6
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/mul7
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/mul8
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/mul9
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/mul10
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/mul11
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/mul12
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/mul13
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/mul14
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/mul15
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/mul16
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/add1
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/add2
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/add3
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/add4
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/add5
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/add6
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/add7
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/add8
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/add9
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/add10
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/add11
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/add12
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/add13
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/add14
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/add15
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/sum_d
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/sum_q
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/valid_r
add wave -noupdate -group PE_1x1_inst /Top_Global_Fused_tb/dut/PE_cluster_1x1/instant_0/mul_sum
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {257660 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 210
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1189945 ns}
