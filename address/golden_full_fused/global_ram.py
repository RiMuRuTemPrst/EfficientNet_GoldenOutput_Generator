def merge_files_with_paths(file_paths, output_file):
    with open(output_file, 'w', encoding='utf-8') as outfile:
        for file_path in file_paths:
            try:
                with open(file_path, 'r', encoding='utf-8') as infile:
                    for line in infile:
                        if line.strip():  # Bỏ dòng trắng
                            outfile.write(line)
            except FileNotFoundError:
                print(f"⚠️ Không tìm thấy file: {file_path}")
            except Exception as e:
                print(f"❌ Lỗi khi đọc {file_path}: {e}")

    print(f"✅ Đã gộp xong các file vào '{output_file}'.")

# 📄 Danh sách file cần gộp (đường dẫn đầy đủ hoặc tương đối)
file_list = [
    "../Fused-Block-CNN/address/golden_full_fused/hex/ifm_padded.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_1_PE0.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_1_PE1.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_1_PE2.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_1_PE3.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_1_PE4.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_1_PE5.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_1_PE6.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_1_PE7.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_1_PE8.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_1_PE9.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_1_PE10.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_1_PE11.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_1_PE12.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_1_PE13.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_1_PE14.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_1_PE15.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_2_PE0.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_2_PE1.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_2_PE2.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_2_PE3.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_3_PE0.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_3_PE1.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_3_PE2.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_3_PE3.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_3_PE4.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_3_PE5.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_3_PE6.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_3_PE7.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_3_PE8.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_3_PE9.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_3_PE10.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_3_PE11.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_3_PE12.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_3_PE13.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_3_PE14.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_3_PE15.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_4_PE0.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_4_PE1.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_4_PE2.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_4_PE3.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_5_PE0.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_5_PE1.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_5_PE2.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_5_PE3.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_5_PE4.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_5_PE5.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_5_PE6.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_5_PE7.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_5_PE8.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_5_PE9.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_5_PE10.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_5_PE11.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_5_PE12.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_5_PE13.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_5_PE14.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_5_PE15.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_6_PE0.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_6_PE1.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_6_PE2.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_6_PE3.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_7_PE0.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_7_PE1.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_7_PE2.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_7_PE3.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_7_PE4.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_7_PE5.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_7_PE6.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_7_PE7.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_7_PE8.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_7_PE9.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_7_PE10.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_7_PE11.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_7_PE12.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_7_PE13.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_7_PE14.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_7_PE15.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_8_PE0.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_8_PE1.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_8_PE2.hex",
    "../Fused-Block-CNN/address/golden_full_fused/hex/weight_8_PE3.hex",
]

# 📝 File đầu ra
output_path = "../Fused-Block-CNN/address/golden_full_fused/hex/global_ram.hex"

merge_files_with_paths(file_list, output_path)
