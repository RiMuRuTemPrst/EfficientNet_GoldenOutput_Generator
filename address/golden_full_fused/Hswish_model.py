import numpy as np

# ==============================================================================
# HÀM MÔ PHỎNG SỐ NGUYÊN CỦA BẠN (ĐÃ CUNG CẤP)
# ==============================================================================

def h_swish_integer_simulation(x_float, ifm_m_bits, weight_m_bits):
    """
    Mô phỏng hàm h-swish với logic tính toán (thứ tự, làm tròn, dịch bit)
    giống hệt với mô tả phần cứng.

    Hàm này giữ nguyên các tham số đầu vào và kiểu trả về của hàm gốc.
    """
    # =============================================================
    # 1. THIẾT LẬP CÁC THAM SỐ VÀ HẰNG SỐ
    # =============================================================

    # Xác định số bit phần lẻ (fractional bits) cho phép toán chính.
    # Logic này được lấy từ hàm gốc của bạn để đảm bảo tính tương thích.
    FRAC_BITS = ifm_m_bits + weight_m_bits
    SCALE = np.int64(1) << FRAC_BITS

    # Các hằng số cho giá trị 3 và 6, được scale theo FRAC_BITS
    C3_Q = np.int64(3) * SCALE
    REL6_Q = np.int64(6) * SCALE

    # Hằng số cho 1/6. Đây là hằng số từ thiết kế phần cứng và không thay đổi.
    # Giá trị 1/6 được xấp xỉ là 11/64 (định dạng Q0.6).
    INV6_Q = np.int64(11)
    INV6_FRAC_BITS = 6
    # Lượng bù để làm tròn cho phép nhân với INV6 (luôn là 32 vì dịch 6 bit)
    ROUND_BIAS_INV6 = np.int64(1) << (INV6_FRAC_BITS - 1)

    # Lượng bù để làm tròn cho phép nhân chính (phụ thuộc vào FRAC_BITS)
    if FRAC_BITS > 0:
        ROUND_BIAS_PROD = np.int64(1) << (FRAC_BITS - 1)
    else:
        ROUND_BIAS_PROD = np.int64(0)

    # =============================================================
    # 2. BẮT ĐẦU TÍNH TOÁN
    # =============================================================

    # Lượng tử hóa đầu vào float sang số nguyên theo SCALE đã tính
    x_q = np.round(x_float * SCALE).astype(np.int64)

    # Tính ReLU6(x + 3) trong không gian số nguyên
    relu6_q = np.clip(x_q + C3_Q, 0, REL6_Q)

    # Tính toán theo đúng thứ tự và logic dịch bit của phần cứng
    # Bước 1: Tính (x * 1/6)
    # Phép nhân: Q.(FRAC_BITS) * Q.(6) -> Q.(FRAC_BITS + 6)
    prod1_intermediate = x_q * INV6_Q
    print(prod1_intermediate)
    # Làm tròn và dịch phải 6 bit để quay về Q.(FRAC_BITS)
    tmp_q = (prod1_intermediate + ROUND_BIAS_INV6) >> INV6_FRAC_BITS
    print(tmp_q)
    # Bước 2: Tính (kết quả trên) * ReLU6(x+3)
    # Phép nhân: Q.(FRAC_BITS) * Q.(FRAC_BITS) -> Q.(2*FRAC_BITS)
    prod2_intermediate = tmp_q * relu6_q
    print(prod2_intermediate)
    # Làm tròn và dịch phải FRAC_BITS bit để quay về Q.(FRAC_BITS)
    y_mid_q = (prod2_intermediate + ROUND_BIAS_PROD) >> FRAC_BITS
    print(y_mid_q)
    # Xử lý các trường hợp đặc biệt (tương đương tf.where)
    is_zero = (relu6_q == 0)
    is_sat = (relu6_q == REL6_Q) # Bão hòa tại giá trị 6
    y_q = np.where(is_sat, x_q, y_mid_q)
    y_q = np.where(is_zero, 0, y_q)

    # =============================================================
    # 3. TRẢ VỀ KẾT QUẢ
    # =============================================================
    print(y_q)
    # Phi lượng tử hóa kết quả cuối cùng về lại float
    final_float = y_q / float(SCALE)

    return final_float


# ==============================================================================
# HÀM THAM CHIẾU (CHUẨN) SỬ DỤNG PHÉP TOÁN FLOAT
# ==============================================================================

def h_swish_float_reference(x):
    """Hàm h-swish tiêu chuẩn sử dụng toàn bộ phép toán float."""
    # Công thức: x * ReLU6(x + 3) / 6
    return x * np.maximum(0, np.minimum(6, x + 3)) / 6.0


# ==============================================================================
# KHỐI MÃ KIỂM THỬ (TESTBENCH)
# ==============================================================================

if __name__ == "__main__":
    # Các giá trị đầu vào để kiểm tra
    # Bao gồm các trường hợp: x < -3, x = -3, -3 < x < 3, x = 3, x > 3
    x_test_values = np.array([
        -0.01458740234375000000
    ], dtype=np.float64)

    # Các kịch bản về độ chính xác (số bit phần thập phân) để kiểm tra
    # Ví dụ: (ifm_m_bits, weight_m_bits)
    test_precisions = [(7, 7), (8, 8)]

    for ifm_bits, weight_bits in test_precisions:
        total_frac_bits = ifm_bits + weight_bits
        print("=" * 80)
        print(f"🚀 Bắt đầu kiểm tra với ifm_m_bits = {ifm_bits}, weight_m_bits = {weight_bits} (Tổng FRAC_BITS = {total_frac_bits})")
        print("=" * 80)

        # 1. Tính toán giá trị tham chiếu (chuẩn)
        ref_results = h_swish_float_reference(x_test_values)

        # 2. Tính toán giá trị từ hàm mô phỏng số nguyên của bạn
        sim_results = h_swish_integer_simulation(x_test_values, ifm_bits, weight_bits)

        # 3. Tính toán sai số tuyệt đối
        error = np.abs(ref_results - sim_results)

        # 4. In kết quả ra bảng để dễ so sánh
        print(f"{'Đầu vào (x)':>15} | {'Chuẩn (Float)':>15} | {'Mô phỏng (Int)':>15} | {'Sai số':>15}")
        print(f"{'-'*15:->}-+-{'-'*15:->}-+-{'-'*15:->}-+-{'-'*15:->}")

        for i in range(len(x_test_values)):
            print(f"{x_test_values[i]:>15.4f} | {ref_results[i]:>15.8f} | {sim_results[i]:>15.8f} | {error[i]:>15.8f}")

        print("\n" * 2)