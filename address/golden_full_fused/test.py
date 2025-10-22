import numpy as np

# Hàm đọc dữ liệu từ file HEX với thứ tự hàng → cột → channel
def read_hex_file(filename, shape):
    with open(filename, "r") as file:
        hex_values = file.readlines()
    
    # Chuyển đổi từ HEX thành số nguyên 8-bit có dấu
    data = np.array([int(x.strip(), 16) for x in hex_values], dtype=np.int32)

    # Đảm bảo dữ liệu trong phạm vi số nguyên có dấu 8-bit
    # Nếu giá trị lớn hơn 127, chúng ta sẽ chuyển thành số âm
    for i in range(len(data)):
        if data[i] > 0x7F:  # Nếu giá trị > 127, chuyển thành số âm
            data[i] -= 0x100  # 0x100 là 256, nên ta trừ đi để có giá trị âm

    H, W, C = shape
    reshaped_data = np.zeros((H, W, C), dtype=np.int32)
    index = 0
    for h in range(H):
        for w in range(W):
            for c in range(C):
                reshaped_data[h, w, c] = data[index]
                index += 1
    return reshaped_data

# Test hàm đọc file hex
def test_read_hex_file():
    # Giả sử file "data.hex" có dữ liệu hex
    # Test với một file hex giả lập dữ liệu
    hex_data = [
        "FF", "00", "AF", "80", "01", "02", "03", "04", "05", "06", "07", "08",
        "FF", "00", "7F", "80", "01", "02", "03", "04", "05", "06", "07", "08"
    ]
    # Ghi dữ liệu giả vào file
    with open("data.hex", "w") as f:
        f.writelines([line + "\n" for line in hex_data])
    
    # Đọc dữ liệu với shape (2, 3, 2)
    shape = (2, 3, 2)  # 2 hàng, 3 cột, 2 kênh
    result = read_hex_file("data.hex", shape)
    
    print("Resulting reshaped data:")
    print(result)

# Gọi hàm test
test_read_hex_file()
