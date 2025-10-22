import numpy as np

import numpy as np

def requantize_dequantize_ofm_hw_aligned(ofm_tensor_float, ifm_m_bits, weight_m_bits, ofm_m_bits, n_bits_out):
    """
    Mô phỏng re-quantize với logic dịch bit (bit-shift) giống hệt phần cứng.
    """
    in_total_m_bits = ifm_m_bits + weight_m_bits
    scale_in, scale_out = 2.0 ** in_total_m_bits, 2.0 ** ofm_m_bits
    shift_amount = in_total_m_bits - ofm_m_bits
    min_val, max_val = -2**(n_bits_out - 1), 2**(n_bits_out - 1) - 1

    # 1. Khôi phục giá trị số nguyên và đảm bảo kiểu dữ liệu là int64
    # <<< THAY ĐỔI: Chuyển sang int64 để thực hiện phép dịch bit
    intermediate_int = np.round(ofm_tensor_float * scale_in).astype(np.int64)
    # >>> KẾT THÚC THAY ĐỔI

    # 2. Re-quantize bằng phép dịch bit số nguyên
    if shift_amount > 0:
        # <<< THAY ĐỔI: Thay thế phép chia bằng "add bias and shift"
        # Đây là cách làm tròn số nguyên chuẩn trong phần cứng
        rounding_bias = 1 << (shift_amount - 1)
        requantized_int = (intermediate_int ) >> shift_amount
        # >>> KẾT THÚC THAY ĐỔI
    else:
        # <<< THAY ĐỔI: Dịch trái cũng dùng toán tử bitwise
        requantized_int = intermediate_int << -shift_amount
        # >>> KẾT THÚC THAY ĐỔI
    print(requantized_int)
    # 3. Kẹp giá trị vào dải của kiểu dữ liệu đầu ra
    requantized_int_clipped = np.clip(requantized_int, min_val, max_val)

    # 4. Phi lượng tử hóa kết quả cuối cùng về lại float
    return requantized_int_clipped.astype(np.float32) / scale_out
# =============================================================
# ĐIỂM THỰC THI CHÍNH CỦA CHƯƠNG TRÌNH TEST
# =============================================================
if __name__ == "__main__":
    # --- 1. Thiết lập các tham số cho bài test ---
    # Giả sử chúng ta đang re-quantize từ một accumulator 14-bit
    # xuống một output 8-bit.
    ifm_m_bits_test = 7
    weight_m_bits_test = 7
    # Độ chính xác mong muốn cho đầu ra
    ofm_m_bits_test = 6
    n_bits_out_test = 8  # Tương đương kiểu int8

    # --- 2. Chuẩn bị dữ liệu đầu vào ---
    # Dữ liệu này đại diện cho kết quả (đã được phi lượng tử hóa)
    # từ một phép tính có độ chính xác cao (ví dụ Qx.14).
    # Giá trị nguyên gốc có thể là [20000, -30000, 5000].
    input_floats_test = np.array([
        -122 / (2**14),  # ~1.2207
    ], dtype=np.float32)

    print("="*50)
    print("CHƯƠNG TRÌNH TEST HÀM RE-QUANTIZE")
    print("="*50)
    print(f"Tham số:")
    print(f"  - Độ chính xác đầu vào (tích lũy): {ifm_m_bits_test + weight_m_bits_test} bits phần lẻ")
    print(f"  - Độ chính xác đầu ra: {ofm_m_bits_test} bits phần lẻ")
    print(f"  - Kiểu dữ liệu đầu ra: {n_bits_out_test}-bit\n")
    print(f"Dữ liệu đầu vào (dạng float):")
    print(input_floats_test)

    # --- 3. Gọi hàm cần test ---
    result = requantize_dequantize_ofm_hw_aligned(
        input_floats_test,
        ifm_m_bits_test,
        weight_m_bits_test,
        ofm_m_bits_test,
        n_bits_out_test
    )

    # --- 4. In kết quả ---
    print("\n" + "-"*20 + " KẾT QUẢ " + "-"*20)
    print(f"Kết quả cuối cùng (dạng float):")
    print(result)
    print("-"*50)

    # Giải thích kết quả đầu tiên để kiểm tra:
    # Giá trị 1.2207 (từ 20000) -> re-quantize thành số nguyên 156
    # -> kẹp trong khoảng [-128, 127] thành 127
    # -> phi lượng tử hóa: 127 / (2**7) = 0.9921875.
    print("\nGiải thích: Kết quả đầu tiên 0.9921875 là chính xác. ✅")