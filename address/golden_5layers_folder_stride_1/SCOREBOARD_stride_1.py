# def compare_files(file1, file2, pe_id=None):
#     with open(file1, 'r') as f1, open(file2, 'r') as f2:
#         line_num = 1
#         diff_count = 0

#         while True:
#             line1 = f1.readline()
#             line2 = f2.readline()

#             # Dừng nếu một trong hai file kết thúc
#             if not line1 or not line2:
#                 break

#             # Xử lý: xóa khoảng trắng + chuyển về chữ hoa
#             clean1 = ''.join(line1.strip().split()).upper()
#             clean2 = ''.join(line2.strip().split()).upper()

#             if clean1 != clean2:
#                 if pe_id is not None:
#                     print(f"❌ PE{pe_id} - Dòng {line_num} khác nhau:")
#                 else:
#                     print(f"❌ Dòng {line_num} khác nhau:")
#                 print(f"    File 1: {clean1}")
#                 print(f"    File 2: {clean2}")
#                 diff_count += 1

#             line_num += 1

#     if diff_count == 0:
#         if pe_id is not None:
#             print(f"✅ PE{pe_id}: Hai file giống nhau!")
#         else:
#             print("✅ Hai file giống nhau!")
#     else:
#         print(f"⚠️ PE{pe_id}: Tổng số dòng khác nhau: {diff_count}")
#     print("-" * 50)

# def compare_files_log(file1, file2, pe_id=None, log_file=None):
#     with open(file1, 'r') as f1, open(file2, 'r') as f2:
#         line_num = 1
#         diff_count = 0

#         # Nếu không truyền log_file, tạo mặc định
#         if log_file is None:
#             log_file = f"comparison_log.txt"
        
#         with open(log_file, 'w') as log:  # Mở file log để ghi kết quả
#             while True:
#                 line1 = f1.readline()
#                 line2 = f2.readline()

#                 # Dừng nếu một trong hai file kết thúc
#                 if not line1 or not line2:
#                     break

#                 # Xử lý: xóa khoảng trắng + chuyển về chữ hoa
#                 clean1 = ''.join(line1.strip().split()).upper()
#                 clean2 = ''.join(line2.strip().split()).upper()

#                 if clean1 != clean2:
#                     if pe_id is not None:
#                         log.write(f"❌ PE{pe_id} - Dòng {line_num} khác nhau:\n")
#                     else:
#                         log.write(f"❌ Dòng {line_num} khác nhau:\n")
#                     log.write(f"    File 1: {clean1}\n")
#                     log.write(f"    File 2: {clean2}\n")
#                     diff_count += 1

#                 line_num += 1

#             if diff_count == 0:
#                 if pe_id is not None:
#                     log.write(f"✅ PE{pe_id}: Hai file giống nhau!\n")
#                 else:
#                     log.write("✅ Hai file giống nhau!\n")
#             else:
#                 log.write(f"⚠️ PE{pe_id}: Tổng số dòng khác nhau: {diff_count}\n")
#             log.write("-" * 50 + "\n")
    
#     print(f"Log đã được lưu vào: {log_file}")  # In thông báo cho biết log đã lưu vào đâu
# if __name__ == "__main__":
#     for pe in range(16):  # PE0 → PE15 // Điều chỉnh số PE của mỗi lớp ở đây
#         file1 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/OFM1_PE{pe}_change.hex"
#         file2 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/OFM1_PE{pe}_DUT.hex"
#         compare_files(file1, file2, pe_id=pe)
#     print("---------------------------------------------------------------FIRST LAYER!---------------------------------------------------------------")
#     for pe in range(4):  # PE0 → PE15 // Điều chỉnh số PE của mỗi lớp ở đây
#         file1 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/DW/OFM2_PE{pe}_change.hex"
#         file2 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/DW/OFM2_PE{pe}_DUT_DW.hex"
#         compare_files_log(file1, file2, pe_id=pe)

#     # file1 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/DW/PADDING_control_IFM_golden.hex"
#     # file2 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/DW/PADDING_control_IFM.hex"
#     # compare_files_log(file1, file2)
#     print("---------------------------------------------------------------Padding LAYER!---------------------------------------------------------------")

#     # print("---------------------------------------------------------------DEPTH WISE LAYER!---------------------------------------------------------------")
#     # for pe in range(1):  # PE0 → PE15 // Điều chỉnh số PE của mỗi lớp ở đây
#     #     file1 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Average_Pooling/ofm_3.hex"
#     #     file2 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Average_Pooling/ofm_3_DUT_test.hex"
#     #     compare_files(file1, file2, pe_id=pe)
#     # print("---------------------------------------------------------------AVERAGE POOLING LAYER!---------------------------------------------------------------")
#     # for pe in range(4):  # PE0 → PE15 // Điều chỉnh số PE của mỗi lớp ở đây
#     #     file1 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Reduce/ofm_4.hex"
#     #     file2 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Reduce/OFM4_DUT_SE.hex"
#     #     compare_files(file1, file2, pe_id=pe)
#     # print(" --------------------------------------------------------------- REDUCE LAYER!--------------------------------------------------------------- ")
#     # for pe in range(4):  # PE0 → PE15 // Điều chỉnh số PE của mỗi lớp ở đây
#     #     file1 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Expand/OFM5_PE{pe}_change.hex"
#     #     file2 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Expand/OFM5_PE{pe}_DUT_SE.hex"
#     #     compare_files(file1, file2, pe_id=pe)
#     # print("---------------------------------------------------------------EXPAND LAYER!---------------------------------------------------------------")
#     # for pe in range(16):  # PE0 → PE15 // Điều chỉnh số PE của mỗi lớp ở đây
#     #     file1 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/OFM6_PE{pe}_change.hex"
#     #     file2 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/OFM6_PE{pe}_DUT.hex"
#     #     compare_files(file1, file2, pe_id=pe)
#     # print("---------------------------------------------------------------Conv1x1(last layer) LAYER!---------------------------------------------------------------")


import sys
import os

def compare_files(file1, file2, pe_id=None, log_file=None):
    with open(file1, 'r') as f1, open(file2, 'r') as f2:
        line_num = 1
        diff_count = 0

        # Nếu không truyền log_file, tạo mặc định
        if log_file is None:
            log_file = f"comparison_log.txt"
        
        
      
        # Chuyển hướng tất cả print vào file log
        with open(log_file, 'a') as log:
            sys.stdout = log  # Redirect stdout to file

            while True:
                line1 = f1.readline()
                line2 = f2.readline()

                # Dừng nếu một trong hai file kết thúc
                if not line1 or not line2:
                    break

                # Xử lý: xóa khoảng trắng + chuyển về chữ hoa
                clean1 = ''.join(line1.strip().split()).upper()
                clean2 = ''.join(line2.strip().split()).upper()

                if clean1 != clean2:
                    if pe_id is not None:
                        print(f"❌ PE{pe_id} - Dòng {line_num} khác nhau:")
                    else:
                        print(f"❌ Dòng {line_num} khác nhau:")
                    print(f"    File 1: {clean1}")
                    print(f"    File 2: {clean2}")
                    diff_count += 1

                line_num += 1

            if diff_count == 0:
                if pe_id is not None:
                    print(f"✅ PE{pe_id}: Hai file giống nhau!")
                else:
                    print("✅ Hai file giống nhau!")
            else:
                print(f"⚠️ PE{pe_id}: Tổng số dòng khác nhau: {diff_count}")
            print("-" * 50)  # In dấu phân cách vào log file

            # Khôi phục lại stdout sau khi ghi vào file log
            sys.stdout = sys.__stdout__

    print(f"Log đã được lưu vào: {log_file}")  # Thông báo về file log đã lưu

def log_to_file(log_file, message):
    with open(log_file, 'a') as log:  # 'a' để thêm vào file (append)
        log.write(message + "\n")

# Gọi hàm ghi vào file

def compare_files_in_directory():
    # Chạy cho Layer 1
    if os.path.exists("test_log_block_4b.txt"):
        os.remove("test_log_block_4b.txt")

    for pe in range(16):  # PE0 → PE15 // Điều chỉnh số PE của mỗi lớp ở đây
        file1 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/OFM1_PE{pe}_change.hex"
        file2 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/OFM1_PE{pe}_DUT.hex"
        compare_files(file1, file2, pe_id=pe, log_file="test_log_block_4b.txt")  # Lưu log vào file riêng
    log_to_file("test_log_block_4b.txt", "\n---------------------------------------------------------------Layer 1!---------------------------------------------------------------\n")

    # for pe in range(1):  # PE0 → PE15 // Điều chỉnh số PE của mỗi lớp ở đây
    #     file1 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/DW/PADDING_control_IFM_golden.hex"
    #     file2 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/DW/PADDING_control_IFM.hex"
    #     compare_files(file1, file2, pe_id=pe, log_file="test_log_block_4b.txt")  # Lưu log vào file riêng
    # log_to_file("test_log_block_4b.txt", "\n---------------------------------------------------------------PADDING_IFM!---------------------------------------------------------------\n")

# Chạy cho Depthwise Layer (DW)
    for pe in range(4):  # PE0 → PE3 // Điều chỉnh số PE của mỗi lớp ở đây
        file1 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/DW/OFM2_PE{pe}_change.hex"
        file2 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/DW/OFM2_PE{pe}_DUT_DW.hex"
        compare_files(file1, file2, pe_id=pe, log_file="test_log_block_4b.txt")  # Lưu log vào file riêng
    log_to_file("test_log_block_4b.txt", "\n---------------------------------------------------------------Depthwise Layer!---------------------------------------------------------------\n")

    for pe in range(1):  # PE0 → PE15 // Điều chỉnh số PE của mỗi lớp ở đây
        file1 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Reduce/ofm_4.hex"
        file2 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Reduce/OFM4_DUT_SE.hex"
        compare_files(file1, file2, pe_id=pe, log_file="test_log_block_4b.txt")  # Lưu log vào file riêng
    log_to_file("test_log_block_4b.txt", "\n---------------------------------------------------------------REDUCE LAYER!---------------------------------------------------------------\n")

    for pe in range(4):  # PE0 → PE15 // Điều chỉnh số PE của mỗi lớp ở đây
        file1 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Expand/OFM5_PE{pe}_change.hex"
        file2 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Expand/OFM5_PE{pe}_DUT_SE.hex"
        compare_files(file1, file2, pe_id=pe, log_file="test_log_block_4b.txt")  # Lưu log vào file riêng
    log_to_file("test_log_block_4b.txt","\n---------------------------------------------------------------EXPAND LAYER!---------------------------------------------------------------\n")

    for pe in range(16):  # PE0 → PE15 // Điều chỉnh số PE của mỗi lớp ở đây
        file1 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/OFM6_PE{pe}_change.hex"
        file2 = f"../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer6/OFM6_PE{pe}_DUT.hex"
        compare_files(file1, file2, pe_id=pe, log_file="test_log_block_4b.txt")  # Lưu log vào file riêng
    log_to_file("test_log_block_4b.txt","\n---------------------------------------------------------------Conv1x1(last layer) LAYER!---------------------------------------------------------------\n")
    print("---------------------------------------------------------------Conv1x1(last layer) LAYER!---------------------------------------------------------------")

if __name__ == "__main__":
    compare_files_in_directory()
