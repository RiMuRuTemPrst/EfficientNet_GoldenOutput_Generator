import struct

def read_hex_file(input_file):
    values = []
    with open(input_file, 'r') as f:
        for line in f:
            # Chuyển đổi giá trị hex dạng float thành số nguyên
            val = float(line.strip())
            # Đảm bảo giá trị nằm trong khoảng 16-bit có dấu (-32768 đến 32767)
            if -32768 <= val <= 32767:
                values.append(int(val))
            else:
                raise ValueError(f"Giá trị {val} vượt quá giới hạn 16-bit!")
    return values

def format_to_16bit_hex(values):
    # Chuyển đổi thành hex 16-bit (4 ký tự hex, bao gồm dấu)
    hex_values = []
    for val in values:
        # Chuyển thành hex, bỏ prefix '0x' và đảm bảo 4 ký tự
        hex_str = format(val & 0xFFFF, '04X')
        hex_values.append(hex_str)
    return hex_values

def group_to_256bit_rows(hex_values):
    # Nhóm thành các hàng 256-bit (16 giá trị 16-bit)
    rows = []
    for i in range(0, len(hex_values), 16):
        row = hex_values[i:i+16]
        # Đảm bảo mỗi hàng có đúng 16 giá trị, nếu không đủ thì điền 0000
        while len(row) < 16:
            row.append('0000')
        rows.append(''.join(row))
    return rows

def write_output_file(rows, output_file):
    with open(output_file, 'w') as f:
        for row in rows:
            f.write(row + '\n')

def convert_hex_file(input_file, output_file):
    try:
        # Đọc và xử lý file
        values = read_hex_file(input_file)
        hex_values = format_to_16bit_hex(values)
        rows = group_to_256bit_rows(hex_values)
        write_output_file(rows, output_file)
        print(f"Đã tạo file đầu ra thành công: {output_file}")
    except Exception as e:
        print(f"Lỗi: {str(e)}")

# Sử dụng ví dụ
if __name__ == "__main__":
    input_file = "input_hex.txt"
    output_file = "output_hex.txt"
    convert_hex_file(input_file, output_file)