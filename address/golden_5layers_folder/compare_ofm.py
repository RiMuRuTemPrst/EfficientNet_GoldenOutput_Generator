def compare_files(file1, file2, pe_id=None):
    with open(file1, 'r') as f1, open(file2, 'r') as f2:
        line_num = 1
        diff_count = 0

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
    print("-" * 50)


if __name__ == "__main__":
    for pe in range(16):  # PE0 → PE15 // Điều chỉnh số PE của mỗi lớp ở đây
        file1 = f"../Fused-Block-CNN/address/golden_5layers_folder/hex/Layer1/OFM1_PE{pe}_change.hex"
        file2 = f"../Fused-Block-CNN/address/golden_5layers_folder/hex/Layer1/OFM1_PE{pe}_DUT.hex"
        compare_files(file1, file2, pe_id=pe)
    print("---------------------------------------------------------------FIRST LAYER!---------------------------------------------------------------")
    for pe in range(4):  # PE0 → PE15 // Điều chỉnh số PE của mỗi lớp ở đây
        file1 = f"../Fused-Block-CNN/address/golden_5layers_folder/hex/DW/OFM2_PE{pe}_change.hex"
        file2 = f"../Fused-Block-CNN/address/golden_5layers_folder/hex/DW/OFM2_PE{pe}_DUT_DW.hex"
        compare_files(file1, file2, pe_id=pe)
    print("---------------------------------------------------------------DEPTH WISE LAYER!---------------------------------------------------------------")
    for pe in range(1):  # PE0 → PE15 // Điều chỉnh số PE của mỗi lớp ở đây
        file1 = f"../Fused-Block-CNN/address/golden_5layers_folder/hex/Average_Pooling/ofm_3.hex"
        file2 = f"../Fused-Block-CNN/address/golden_5layers_folder/hex/Average_Pooling/ofm_3_DUT_test.hex"
        compare_files(file1, file2, pe_id=pe)
    print("---------------------------------------------------------------AVERAGE POOLING LAYER!---------------------------------------------------------------")
    for pe in range(4):  # PE0 → PE15 // Điều chỉnh số PE của mỗi lớp ở đây
        file1 = f"../Fused-Block-CNN/address/golden_5layers_folder/hex/Reduce/ofm_4.hex"
        file2 = f"../Fused-Block-CNN/address/golden_5layers_folder/hex/Reduce/OFM4_DUT_SE.hex"
        compare_files(file1, file2, pe_id=pe)
    print(" --------------------------------------------------------------- REDUCE LAYER!--------------------------------------------------------------- ")
    for pe in range(4):  # PE0 → PE15 // Điều chỉnh số PE của mỗi lớp ở đây
        file1 = f"../Fused-Block-CNN/address/golden_5layers_folder/hex/Expand/OFM5_PE{pe}_change.hex"
        file2 = f"../Fused-Block-CNN/address/golden_5layers_folder/hex/Expand/OFM5_PE{pe}_DUT_SE.hex"
        compare_files(file1, file2, pe_id=pe)
    print("---------------------------------------------------------------EXPAND LAYER!---------------------------------------------------------------")
    for pe in range(16):  # PE0 → PE15 // Điều chỉnh số PE của mỗi lớp ở đây
        file1 = f"../Fused-Block-CNN/address/golden_5layers_folder/hex/Layer6/OFM6_PE{pe}_change.hex"
        file2 = f"../Fused-Block-CNN/address/golden_5layers_folder/hex/Layer6/OFM6_PE{pe}_DUT.hex"
        compare_files(file1, file2, pe_id=pe)
    print("---------------------------------------------------------------Conv1x1(last layer) LAYER!---------------------------------------------------------------")


