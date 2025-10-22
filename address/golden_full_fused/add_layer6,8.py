def read_hex_values_from_file(filename):
    with open(filename, 'r') as f:
        return [int(line.strip(), 16) for line in f if line.strip()]

def write_hex_values_to_file(values, filename):
    with open(filename, 'w') as f:
        for val in values:
            f.write(f"{val:02X}\n")  # Ghi ra dạng hex, 2 chữ số, viết hoa

def add_hex_values_from_files(file1, file2, output_file):
    values1 = read_hex_values_from_file(file1)
    values2 = read_hex_values_from_file(file2)

    min_length = min(len(values1), len(values2))
    result = [(values1[i] + values2[i]) & 0xFF for i in range(min_length)]  # Giới hạn kết quả trong 1 byte nếu cần

    write_hex_values_to_file(result, output_file)
    print(f"Đã lưu kết quả vào {output_file}")

# Gọi hàm
file1 = '../Fused-Block-CNN/address/golden_full_fused/hex/ofm_layer6.hex'
file2 = '../Fused-Block-CNN/address/golden_full_fused/hex/ofm_layer8.hex'
output = '../Fused-Block-CNN/address/golden_full_fused/hex/ofm_layer8_add.hex'

add_hex_values_from_files(file1, file2, output)
