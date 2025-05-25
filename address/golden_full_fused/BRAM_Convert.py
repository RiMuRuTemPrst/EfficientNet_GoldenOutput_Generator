def convert_hex_to_coe(input_file, output_file):
    """
    Chuyển file input dạng mỗi dòng 2 ký tự hex (1 byte) thành file .coe
    với format Vivado: memory_initialization_radix=16; memory_initialization_vector=
    và mỗi dòng vector gồm 16 byte nối liền, phân tách dấu phẩy.
    """
    with open(input_file, 'r') as f_in:
        lines = f_in.read().splitlines()

    bytes_list = [line.strip() for line in lines if line.strip()]

    with open(output_file, 'w') as f_out:
        # Header
        f_out.write("memory_initialization_radix=16;\n")
        f_out.write("memory_initialization_vector=\n")

        # Lặp nhóm 16 byte
        num_chunks = (len(bytes_list) + 15) // 16
        for i in range(num_chunks):
            chunk = bytes_list[i*16:(i+1)*16]
            line_str = ''.join(chunk)  # Nối 16 byte thành 32 ký tự hex
            # Nếu dòng cuối cùng, không có dấu phẩy, ngược lại có dấu phẩy
            if i == num_chunks - 1:
                f_out.write(line_str + ";\n")
            else:
                f_out.write(line_str + ",\n")

if __name__ == "__main__":
    input_file = "address\golden_full_fused\hex\global_ram.hex"     # file input dạng mỗi dòng 2 ký tự hex
    output_file = "address\golden_full_fused\hex\global_ram_128.coe"   # file .coe đầu ra
    convert_hex_to_coe(input_file, output_file)
    print(f"Đã tạo file .coe {output_file} từ {input_file}")
