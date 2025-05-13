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
    "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/ifm.hex",
    "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE0.hex",
    "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE1.hex",
    "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE2.hex",
    "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE3.hex",
    "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE4.hex",
    "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE5.hex",
    "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE6.hex",
    "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE7.hex",
    "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE8.hex",
    "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE9.hex",
    "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE10.hex",
    "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE11.hex",
    "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE12.hex",
    "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE13.hex",
    "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE14.hex",
    "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Layer1/weight1_PE15.hex",
]

# 📝 File đầu ra
output_path = "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/global_ram.hex"

merge_files_with_paths(file_list, output_path)
