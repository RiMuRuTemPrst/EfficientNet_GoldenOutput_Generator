def hex_to_coe(input_file, output_file):
    # Đọc dữ liệu từ file hex
    with open(input_file, "r") as file:
        hex_values = file.readlines()

    # Loại bỏ ký tự '\n' và không cần chuyển đổi sang int vì dữ liệu đã là chuỗi hex
    hex_values = [x.strip() for x in hex_values]

    # Chia thành các khối 16 bytes và đảo ngược từng khối
    words = []
    for i in range(0, len(hex_values), 16):
        chunk = hex_values[i:i+16]
        reversed_chunk = chunk[::-1]  # Đảo ngược thứ tự của các byte trong mỗi khối
        word = ''.join(reversed_chunk)  # Ghép chuỗi lại thành một từ 128 bit
        words.append(word)

    # Ghi ra file .coe với định dạng Vivado
    with open(output_file, "w") as f:
        f.write("memory_initialization_radix=16;\n")
        f.write("memory_initialization_vector=\n")
        for i, word in enumerate(words):
            if i == len(words) - 1:
                f.write(f"{word};\n")  # Dòng cuối cùng kết thúc bằng dấu chấm phẩy
            else:
                f.write(f"{word},\n")  # Các dòng khác ngăn cách bằng dấu phẩy

    print(f"The .coe file has been generated at {output_file}.")

# Sử dụng đường dẫn file .hex của bạn
input_file_path = '/home/manhung/Hung/CNN/Fused-Block-CNN/global_ram.hex'  # Thay bằng đường dẫn tới file hex của bạn
output_file_path = '/home/manhung/Hung/CNN/Fused-Block-CNN/global_ram_reverse.coe'  # Tên file .coe đầu ra

# Chạy hàm để chuyển đổi
hex_to_coe(input_file_path, output_file_path)
