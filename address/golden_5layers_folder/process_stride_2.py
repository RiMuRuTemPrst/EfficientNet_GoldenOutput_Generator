import argparse

def process_conv_with_stride(input_file, output_file, depth, height, width):
    # Đọc toàn bộ dữ liệu từ file hex vào một danh sách
    with open(input_file, 'r') as infile:
        lines = infile.readlines()
    
    # Kiểm tra xem số lượng phần tử trong file có khớp với kích thước mong muốn không
    expected_size = depth * height * width
    if len(lines) != expected_size:
        raise ValueError(f"Số phần tử trong file hex không khớp với kích thước dự kiến. "
                         f"Expected: {expected_size}, Found: {len(lines)}")
    
    # Chuyển đổi các giá trị từ file hex thành một danh sách 3D (depth, height, width)
    data = []
    idx = 0
    for d in range(depth):  # Duyệt qua chiều sâu (depth)
        channel = []
        for h in range(height):  # Duyệt qua các hàng (height)
            row = []
            for w in range(width):  # Duyệt qua các cột (width)
                # Đọc từng giá trị của phần tử tại (d, h, w)
                row.append(int(lines[idx].strip(), 16))  # Lấy giá trị từ file hex
                idx += 1  # Chuyển đến phần tử tiếp theo trong file
            channel.append(row)
        data.append(channel)

    # Đảm bảo dữ liệu có đúng kích thước
    assert len(data) == depth and len(data[0]) == height and len(data[0][0]) == width, "Kích thước dữ liệu không khớp"

    # Xử lý để lấy dữ liệu của Conv với stride = 2
    new_height = (height + 1) // 2  # Kích thước mới theo chiều cao sau khi có stride = 2
    new_width = (width + 1) // 2    # Kích thước mới theo chiều rộng sau khi có stride = 2
    
    new_data = []
    
    # Duyệt qua các channel
    for d in range(depth):
        new_channel = []
        # Duyệt qua chiều cao và chiều rộng với bước nhảy stride = 2
        for h in range(0, height, 2):  # Bỏ qua mỗi bước 2 trên chiều cao
            new_row = []
            for w in range(0, width, 2):  # Bỏ qua mỗi bước 2 trên chiều rộng
                new_row.append(data[d][h][w])  # Lấy giá trị pixel theo stride = 2
            new_channel.append(new_row)
        new_data.append(new_channel)

    # Ghi kết quả vào file hex mới
    with open(output_file, 'w') as outfile:
        for d in range(depth):  # Duyệt qua chiều cao mới
            for h in range(new_height):  # Duyệt qua chiều rộng mới
                for w in range(new_width):  # Duyệt qua chiều sâu
                    outfile.write(f"{new_data[d][h][w]:2X}\n")  # Ghi giá trị theo thứ tự depth -> height -> width


def main():
    # Thiết lập parser để nhận tham số từ dòng lệnh
    parser = argparse.ArgumentParser(description="Process a hex file to reduce the number of elements.")
    parser.add_argument("--weight_filter", type=int, required=True)
    parser.add_argument("--ofm_width", type=int, required=True)

    # Lấy các tham số từ dòng lệnh
    args = parser.parse_args()

    # Đường dẫn file input và output được chỉ định trực tiếp trong mã nguồn
    input_file = '../Fused-Block-CNN/address/golden_5layers_folder/hex/ofm_2.hex'  # Đường dẫn tới file hex đầu vào
    output_file = '../Fused-Block-CNN/address/golden_5layers_folder/hex/ofm_2_stride.hex'  # Đường dẫn tới file hex đầu ra

    # Gọi hàm xử lý file hex
    process_conv_with_stride(input_file, output_file, args.weight_filter, args.ofm_width, args.ofm_width)

# Chạy chương trình
if __name__ == '__main__':
    main()
