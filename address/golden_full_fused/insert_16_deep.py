# -*- coding: utf-8 -*-

def pad_ifm_channels(input_file_path, output_file_path):
    """
    Chuyển đổi một tệp .hex chứa ifm từ định dạng 224x224x3 sang 224x224x16
    bằng cách chèn 13 kênh chứa giá trị '00'.

    Args:
        input_file_path (str): Đường dẫn đến tệp .hex đầu vào.
        output_file_path (str): Đường dẫn để lưu tệp .hex đầu ra.
    """
    # Kích thước của ma trận đầu vào (input feature map)
    height = 224
    width = 224
    
    # Số kênh ban đầu và số kênh mong muốn
    input_channels = 3
    output_channels = 16
    
    # Số kênh chứa giá trị 0 cần chèn vào
    padding_channels_count = output_channels - input_channels
    
    print(f"Bắt đầu xử lý tệp ifm: '{input_file_path}'...")
    
    try:
        with open(input_file_path, 'r') as infile, open(output_file_path, 'w') as outfile:
            # Lặp qua tổng số pixel (224 * 224)
            for i in range(height * width):
                original_pixel_group = []
                for _ in range(input_channels):
                    line = infile.readline()
                    if not line:
                        print(f"Cảnh báo: Tệp đầu vào kết thúc sớm ở pixel thứ {i+1}.")
                        print("Quá trình xử lý đã dừng lại.")
                        return
                    original_pixel_group.append(line.strip())
                
                for value in original_pixel_group:
                    outfile.write(f"{value}\n")
                
                for _ in range(padding_channels_count):
                    outfile.write("00\n")

        print("-" * 30)
        print(f"Hoàn tất! Dữ liệu ifm đã được chuyển đổi và lưu vào tệp: '{output_file_path}'.")
        print(f"Định dạng mới: {height}x{width}x{output_channels}")

    except FileNotFoundError:
        print(f"Lỗi: Không tìm thấy tệp '{input_file_path}'. Vui lòng kiểm tra lại tên và đường dẫn tệp.")
    except Exception as e:
        print(f"Đã có lỗi xảy ra trong quá trình xử lý: {e}")


def pad_weight_channels(input_file_path, output_file_path):
    """
    Chuyển đổi một tệp .hex chứa weight từ định dạng 3x3x3x32 sang 3x3x16x32
    bằng cách chèn 13 kênh chứa giá trị '00' sau mỗi 3 kênh đầu vào.

    Args:
        input_file_path (str): Đường dẫn đến tệp .hex đầu vào chứa weight.
        output_file_path (str): Đường dẫn để lưu tệp .hex đầu ra.
    """
    # Kích thước của kernel weight
    kernel_h = 3
    kernel_w = 3
    num_filters = 32
    
    # Số kênh đầu vào và đầu ra cho mỗi weight
    input_channels = 3
    output_channels = 16  # 3 kênh gốc + 13 kênh chèn thêm
    
    # Số kênh chứa giá trị 0 cần chèn vào
    padding_channels_count = output_channels - input_channels
    
    # Tổng số nhóm 3 kênh cần xử lý.
    # Mỗi filter (32) có 3x3 vị trí, và mỗi vị trí có 3 giá trị kênh đầu vào.
    # Vậy có 32 * (3*3) = 288 nhóm 3 kênh.
    total_groups = kernel_h * kernel_w * num_filters
    
    print(f"Bắt đầu xử lý tệp weight: '{input_file_path}'...")
    
    try:
        # Mở tệp đầu vào để đọc ('r') và tệp đầu ra để ghi ('w')
        with open(input_file_path, 'r') as infile, open(output_file_path, 'w') as outfile:
            # Lặp qua tổng số nhóm 3 kênh
            for i in range(total_groups):
                original_weight_group = []
                for _ in range(input_channels):
                    line = infile.readline()
                    # Nếu không còn dòng nào để đọc, tệp đầu vào không đủ dữ liệu
                    if not line:
                        print(f"Cảnh báo: Tệp đầu vào kết thúc sớm ở nhóm thứ {i+1}.")
                        print("Quá trình xử lý đã dừng lại.")
                        return
                    original_weight_group.append(line.strip())
                
                # Ghi 3 giá trị của kênh gốc vào tệp mới
                for value in original_weight_group:
                    outfile.write(f"{value}\n")
                
                # Ghi 13 giá trị '00' để chèn vào các kênh còn lại
                for _ in range(padding_channels_count):
                    outfile.write("00\n")

        print("-" * 30)
        print(f"Hoàn tất! Dữ liệu weight đã được chuyển đổi và lưu vào tệp: '{output_file_path}'.")
        print(f"Định dạng weight mới tương ứng với: {kernel_h}x{kernel_w}x{output_channels}x{num_filters}")

    except FileNotFoundError:
        print(f"Lỗi: Không tìm thấy tệp '{input_file_path}'. Vui lòng kiểm tra lại tên và đường dẫn tệp.")
    except Exception as e:
        print(f"Đã có lỗi xảy ra trong quá trình xử lý: {e}")


# --- Điểm bắt đầu của chương trình ---
if __name__ == '__main__':
    # --- CẤU HÌNH ---
    # Chọn tác vụ bạn muốn thực hiện bằng cách bỏ comment dòng tương ứng
    
    TASK = "PAD_IFM"  # Chọn "PAD_IFM" hoặc "PAD_WEIGHTS"

    if TASK == "PAD_IFM":
        # Tên tệp .hex đầu vào chứa dữ liệu 224x224x3
        ifm_input_file = '/home/manhung/Hung/CNN/Fused-Block-CNN/address/golden_full_fused/hex/input.hex'  
        # Tên tệp .hex đầu ra sẽ được tạo ra
        ifm_output_file = '/home/manhung/Hung/CNN/Fused-Block-CNN/address/golden_full_fused/hex/input_out.hex' 
        # Gọi hàm để xử lý ifm
        pad_ifm_channels(ifm_input_file, ifm_output_file)

    elif TASK == "PAD_WEIGHTS":
        # Tên tệp .hex đầu vào chứa dữ liệu weight 3x3x3x32
        weight_input_file = 'address/golden_full_fused/hex/weight.hex'  
        # Tên tệp .hex đầu ra sẽ được tạo ra
        weight_output_file = 'address/golden_full_fused/hex/weight_out.hex' 
        # Gọi hàm để xử lý weight
        pad_weight_channels(weight_input_file, weight_output_file)

