def split_hex_file(input_file):
    with open(input_file, 'r') as f:
        lines = [line.strip().split() for line in f if line.strip()]
    
    # Kiểm tra số lượng cột
    for idx, line in enumerate(lines):
        if len(line) != 16:
            raise ValueError(f"Dòng {idx+1} không đủ 16 giá trị: {line}")

    # Tạo file .hex, thêm tiền tố '00', chuyển thành chữ hoa
    for col in range(16):
        with open(f'hex_{col+1}.hex', 'w') as fout:
            for line in lines:
                fout.write(('00' + line[col]).lower() + '\n')

if __name__ == '__main__':
    input_filename = 'output.hex'
    split_hex_file(input_filename)
    print('Đã tách xong thành 16 file hex_1.hex ... hex_16.hex (chữ hoa, 16 bit 00XX)')
