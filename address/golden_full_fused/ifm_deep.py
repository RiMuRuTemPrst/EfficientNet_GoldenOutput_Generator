import numpy as np

def convert_ifm_format(input_path, output_path, height, width, channels):
    """
    Chuyển đổi file hex IFM từ định dạng (Kênh, Cao, Rộng) - CHW
    sang định dạng (Cao, Rộng, Kênh) - HWC.

    Args:
        input_path (str): Đường dẫn đến file hex đầu vào.
        output_path (str): Đường dẫn đến file hex đầu ra.
        height (int): Chiều cao của feature map.
        width (int): Chiều rộng của feature map.
        channels (int): Số lượng kênh (chiều sâu).
    """
    # 1. Đọc tất cả các giá trị hex từ file đầu vào
    try:
        with open(input_path, 'r') as f:
            # Chuyển đổi mỗi dòng hex thành số nguyên
            hex_values = [int(line.strip(), 16) for line in f if line.strip()]
    except FileNotFoundError:
        print(f"Lỗi: Không tìm thấy file đầu vào tại '{input_path}'")
        return
    except ValueError as e:
        print(f"Lỗi: File đầu vào chứa giá trị không hợp lệ. {e}")
        return

    # 2. Kiểm tra xem số lượng dữ liệu có khớp với kích thước đã cho không
    expected_size = height * width * channels
    if len(hex_values) != expected_size:
        print(
            f"Lỗi: Kích thước dữ liệu không khớp! "
            f"Đọc được {len(hex_values)} giá trị, nhưng dự kiến là {expected_size} "
            f"(cao={height}, rộng={width}, kênh={channels})."
        )
        return

    # 3. Chuyển danh sách phẳng thành mảng 3D theo định dạng CHW (Channel, Height, Width)
    # Đây là định dạng ban đầu của bạn: duyệt hết chiều ngang, rồi chiều dọc, rồi đến kênh.
    ifm_chw = np.array(hex_values, dtype=np.uint8).reshape((channels, height, width))

    # 4. Chuyển vị (transpose) mảng từ CHW sang HWC (Height, Width, Channel)
    # Thao tác này sẽ đưa chiều kênh (trục 0) xuống cuối cùng.
    # Trục 1 (cao) và 2 (rộng) sẽ trở thành trục 0 và 1.
    ifm_hwc = ifm_chw.transpose((1, 2, 0))

    # 5. Làm phẳng mảng HWC trở lại danh sách 1D và ghi ra file
    # Dữ liệu bây giờ đã được sắp xếp theo thứ tự duyệt theo chiều sâu.
    with open(output_path, 'w') as f:
        for value in ifm_hwc.flatten():
            # Định dạng lại thành chuỗi hex có 2 ký tự (ví dụ: '0a' thay vì 'a')
            f.write(f"{value:02x}\n")

    print(f"Chuyển đổi thành công! Dữ liệu đã được lưu vào file '{output_path}'")


if __name__ == '__main__':
    # --- CẤU HÌNH ---
    # !!! BẠN CẦN THAY ĐỔI CÁC THÔNG SỐ NÀY CHO ĐÚNG VỚI DỮ LIỆU CỦA MÌNH !!!
    IFM_HEIGHT = 112   # Chiều cao
    IFM_WIDTH  = 112   # Chiều rộng
    IFM_CHANNELS = 32 # Chiều sâu (số kênh)

    input_file = 'address/golden_full_fused/hex/ofm_layer01_stride.hex'   # Tên file đầu vào
    output_file = 'address/golden_full_fused/hex/ofm_layer01_stride_c.hex' # Tên file đầu ra
    # --- KẾT THÚC CẤU HÌNH ---

    # Gọi hàm chuyển đổi
    convert_ifm_format(input_file, output_file, IFM_HEIGHT, IFM_WIDTH, IFM_CHANNELS)