# Đọc từ file hex sẵn có
with open("output.hex", "r") as f:
    hex_str = f.read()

# Tách thành danh sách các byte (giả sử cách nhau bằng khoảng trắng hoặc xuống dòng)
hex_values = hex_str.strip().split()

# Lấy mỗi 4 phần tử, bắt đầu từ phần tử đầu tiên
output = []
for i in range(0, len(hex_values), 4):
    byte = hex_values[i].lower()  # lấy byte đầu tiên trong mỗi nhóm 4, chuyển về chữ thường
    output.append(f"00{byte}")

# Ghi ra file mới
with open("output_PE0.hex", "w") as f:
    for line in output:
        f.write(line + '\n')

print("Đã tạo xong file 'output.hex'")
