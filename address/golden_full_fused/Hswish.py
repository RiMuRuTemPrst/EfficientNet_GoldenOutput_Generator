import tensorflow as tf
import numpy as np

# =============================================================
# ĐỊNH NGHĨA LẠI CÁC HẰNG SỐ VÀ HÀM TỪ CODE CỦA BẠN
# =============================================================
# Lưu ý: FRAC_BITS = 7, không phải 6 như tên biến x_q106 gợi ý.
FRAC_BITS      = 14
SCALE          = 1 << FRAC_BITS          # 128

C3_Q106        = tf.constant(3  * SCALE, dtype=tf.int32)   #  +3  -> 3 * 128 = 384
REL6_Q106      = tf.constant(6  * SCALE, dtype=tf.int32)   #   6  -> 6 * 128 = 768

# Hằng số cho 1/6 (11/64)
INV6_Q26       = tf.constant(11, dtype=tf.int32)
INV6_FRAC_BITS = 6
ROUND_BIAS     = 1 << (INV6_FRAC_BITS - 1)                 # 32

INT16_MIN, INT16_MAX = -32768, 32767

# Lưu ý: FRAC_BITS_53 = 6, không phải 3 như tên hàm hswish_q53 gợi ý.
FRAC_BITS_53 = 6
SCALE_53     = 1 << FRAC_BITS_53  # 64

INT8_MIN, INT8_MAX = -128, 127
BIAS_FRAC_BIT = 7 # Biến này không được sử dụng trong hàm hswish_q53

def hswish_q53(x_q_input: tf.Tensor) -> tf.Tensor:
    x_i32  = tf.cast(x_q_input, tf.int32)
    relu6  = tf.clip_by_value(x_i32 + C3_Q106, 0, REL6_Q106)

    is_zero = tf.equal(relu6, 0)
    is_sat  = tf.equal(relu6, REL6_Q106)

    # 1) x * (1/6)
    tmp_q1012    = x_i32 * INV6_Q26
    tmp_q106     = tf.bitwise.right_shift(tmp_q1012 + ROUND_BIAS, INV6_FRAC_BITS)
    print(tmp_q106)
    # 2) (kết quả) * relu6
    prod_q2012   = tmp_q106 * relu6
    
    print(prod_q2012)
    # 3) Dịch bit để quay về định dạng Qx.7
    y_mid_q106   = tf.bitwise.right_shift(
                      prod_q2012 + (1 << (FRAC_BITS - 1)),
                      FRAC_BITS
                  )
    print(y_mid_q106)
    y_i32 = tf.where(is_zero, 0, tf.where(is_sat, x_i32, y_mid_q106))
    y_sat = tf.clip_by_value(y_i32, INT16_MIN, INT16_MAX)
    print(y_sat)
    # Dịch bit từ Qx.7 sang Qy.6 (dịch phải 7-6=1 bit)
    y_final_q = tf.bitwise.right_shift(y_sat + (1 << (FRAC_BITS - FRAC_BITS_53 - 1)), (FRAC_BITS - FRAC_BITS_53))
    print(y_final_q)
    y_final_q = tf.clip_by_value(y_final_q, INT8_MIN, INT8_MAX)

    return tf.cast(y_final_q, tf.int8)

# =============================================================
# HÀM HỖ TRỢ ĐỂ TEST
# =============================================================
def float_to_q(float_val, frac_bits):
    """Chuyển đổi số float sang số nguyên Q-format."""
    scale = 1 << frac_bits
    return np.round(float_val * scale).astype(np.int64)

def q_to_float(q_val, frac_bits):
    """Chuyển đổi số nguyên Q-format về lại số float."""
    scale = 1 << frac_bits
    return q_val / scale

# =============================================================
# CHƯƠNG TRÌNH TEST CHÍNH
# =============================================================
if __name__ == "__main__":
    # Các giá trị đầu vào để test (dạng float)
    test_inputs_float = np.array([-0.01458740234375000000], dtype=np.float32)
    
    # 1. Lượng tử hóa đầu vào sang định dạng Qx.7 (theo FRAC_BITS = 7)
    input_q_values = float_to_q(test_inputs_float, FRAC_BITS)
    
    # Chuyển đổi sang Tensor của TensorFlow
    input_tensor = tf.constant(input_q_values, dtype=tf.int32)
    
    # 2. Chạy hàm h-swish đã lượng tử hóa
    output_q_tensor = hswish_q53(input_tensor)
    output_q_values = output_q_tensor.numpy() # Lấy kết quả về dạng numpy array
    
    # 3. Phi lượng tử hóa kết quả đầu ra (định dạng Qy.6) để kiểm tra
    output_float_values = q_to_float(output_q_values, FRAC_BITS_53)
    
    # 4. Tính kết quả lý tưởng bằng số học float để so sánh
    ideal_results = test_inputs_float * np.clip(test_inputs_float + 3, 0, 6) / 6
    
    # 5. In kết quả để so sánh
    print("="*80)
    print("KẾT QUẢ TEST HÀM HSWISH LƯỢNG TỬ HÓA")
    print(f"Định dạng Q-format đầu vào: Qx.{FRAC_BITS} | Định dạng Q-format đầu ra: Qy.{FRAC_BITS_53}")
    print("="*80)
    print(f"{'Input (float)':>15} | {'Input (Qx.7)':>12} | {'Output (Qy.6)':>13} | {'Output (float)':>15} | {'Ideal (float)':>15}")
    print("-"*80)
    
    for i in range(len(test_inputs_float)):
        print(f"{test_inputs_float[i]:>15.4f} | "
              f"{input_q_values[i]:>12} | "
              f"{output_q_values[i]:>13} | "
              f"{output_float_values[i]:>15.4f} | "
              f"{ideal_results[i]:>15.20f}")