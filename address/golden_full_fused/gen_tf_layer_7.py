import numpy as np
import tensorflow as tf
import argparse
import math
FRAC_BITS      = 6
SCALE          = 1 << FRAC_BITS          # 64

C3_Q106        = tf.constant(3  * SCALE, dtype=tf.int32)   #  +3  -> 192
REL6_Q106      = tf.constant(6  * SCALE, dtype=tf.int32)   #   6  -> 384

INV6_Q26       = tf.constant(11, dtype=tf.int32)           # 11/64 ≈ 1/6
INV6_FRAC_BITS = 6
ROUND_BIAS     = 1 << (INV6_FRAC_BITS - 1)                 # 32

INT16_MIN, INT16_MAX = -32768, 32767
# Các tham số cho Q5.3
FRAC_BITS_53 = 3               # 3 bit phần lẻ cho Q5.3
SCALE_53     = 1 << FRAC_BITS_53  # 8

INT8_MIN, INT8_MAX = -128, 127  # Dải giá trị cho Q5.3
# =============================================================

def hswish_q53(x_q106: tf.Tensor) -> tf.Tensor:
    # ... [unchanged setup code above] ...

    x_i32  = tf.cast(x_q106, tf.int32)
    relu6  = tf.clip_by_value(x_i32 + C3_Q106, 0, REL6_Q106)

    is_zero = tf.equal(relu6, 0)
    is_sat  = tf.equal(relu6, REL6_Q106)

    # ---- NEW ORDER OF MULTIPLICATIONS -------------------------------
    # 1) Compute x * (1/6) in Q10.6: (Q10.6 * Q0.6 → Q10.12), then round & shift by 6 to Q10.6
    tmp_q1012    = x_i32 * INV6_Q26               # Q10.6 * Q0.6 → Q10.12
    tmp_q106     = tf.bitwise.right_shift(
                      tmp_q1012 + ROUND_BIAS,    # round-to-nearest
                      INV6_FRAC_BITS             # shift 6 bits → back to Q10.6
                  )

    # 2) Multiply that result by relu6: Q10.6 * Q10.6 → Q20.12
    prod_q2012   = tmp_q106 * relu6

    # 3) Round & shift back to Q10.6
    y_mid_q106   = tf.bitwise.right_shift(
                      prod_q2012 + (1 << (FRAC_BITS - 1)),  # bias = 2^(6-1)
                      FRAC_BITS                             # shift 6 bits
                  )

    # ---- REST OF THE LOGIC (unchanged) -------------------------------
    y_i32 = tf.where(is_zero,
               0,
            tf.where(is_sat,
               x_i32,
               y_mid_q106))

    y_sat = tf.clip_by_value(y_i32, INT16_MIN, INT16_MAX)
    y_q53 = tf.bitwise.right_shift(y_sat, (FRAC_BITS - FRAC_BITS_53))
    y_q53 = tf.clip_by_value(y_q53, INT8_MIN, INT8_MAX)

    return tf.cast(y_q53, tf.int8)
def read_bias_file(filename, length):
    with open(filename, "r") as file:
        hex_values = file.readlines()
    
    # Chuyển đổi từ HEX thành số nguyên 8-bit có dấu
    data = np.array([int(x.strip(), 16) for x in hex_values], dtype=np.int16)

    # Đảm bảo dữ liệu trong phạm vi số nguyên có dấu 8-bit
    for i in range(len(data)):
        if data[i] > 0x7F:  # Nếu giá trị > 127, chuyển thành số âm
            data[i] -= 0x100  # 0x100 là 256, nên ta trừ đi để có giá trị âm

    return data.reshape((length,))

def read_hex_file_weight(filename, shape):
    with open(filename, "r") as file:
        hex_values = file.readlines()
    
    # Chuyển đổi từ HEX thành số nguyên 8-bit có dấu
    data = np.array([int(x.strip(), 16) for x in hex_values], dtype=np.int16)

    # Đảm bảo dữ liệu trong phạm vi số nguyên có dấu 8-bit
    for i in range(len(data)):
        if data[i] > 0x7F:  # Nếu giá trị > 127, chuyển thành số âm
            data[i] -= 0x100  # 0x100 là 256, nên ta trừ đi để có giá trị âm

    H, W, C, F = shape
    reshaped_data = np.zeros((H, W, C, F), dtype=np.int16)
    index = 0
    for f in range(F):
        for h in range(H):
            for w in range(W):
                for c in range(C):
                    reshaped_data[h, w, c, f] = data[index]
                    index += 1
    return reshaped_data

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
    for c in range(C):
        for h in range(H):
            for w in range(W):
                reshaped_data[h, w, c] = data[index]

                index += 1

    return reshaped_data

# Hàm ghi dữ liệu ra file HEX
def write_hex_file(filename, data):
    H, W, C = data.shape
    with open(filename, "w") as file:
        for c in range(C):
            for h in range(H):
                for w in range(W):
                    int_value = int(round(data[h, w, c]))
                    hex_value = int_value & 0x00FF
                    file.write(f"{hex_value:04X}\n")


# === Main ===
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ifm_height", type=int, required=True)
    parser.add_argument("--ifm_width", type=int, required=True)
    parser.add_argument("--ifm_channel", type=int, required=True)
    parser.add_argument("--weight_filter", type=int, required=True)
    parser.add_argument("--padding1", type=int, default=1)  # Padding P
    parser.add_argument("--stride1", type=int, default=1)   # Stride S
    args = parser.parse_args()

    # Tính kích thước OFM với padding và stride
    output_feature_height = (args.ifm_height - 3 + 2 * args.padding1) // args.stride1 + 1
    output_feature_width = (args.ifm_width - 3 + 2 * args.padding1) // args.stride1 + 1
    output_feature_channel = args.weight_filter

    # File paths cố định
    input_file = "../Fused-Block-CNN/address/golden_full_fused/hex/ofm_layer6.hex"
    weight_file = "../Fused-Block-CNN/address/golden_full_fused/hex/weight_7.hex"
    output_file = "../Fused-Block-CNN/address/golden_full_fused/hex/ofm_layer7.hex"
    bias_file = "../Fused-Block-CNN/address/golden_full_fused/hex/bias_7.hex"

    # Đọc dữ liệu
    input_data = read_hex_file(input_file, (args.ifm_height, args.ifm_width, args.ifm_channel))
    weight_data_flat = read_hex_file_weight(weight_file, (3, 3, args.ifm_channel, args.weight_filter))
    weight_data = weight_data_flat.reshape(3, 3, args.ifm_channel, args.weight_filter)
    bias_data = read_bias_file(bias_file, args.weight_filter).astype(np.float32)

    # Xác định padding cho TensorFlow layer
    tf_padding = "same" if args.padding1 > 0 else "valid"

    # Tạo mô hình
    input_layer = tf.keras.layers.Input(shape=(args.ifm_height, args.ifm_width, args.ifm_channel))
    conv_layer = tf.keras.layers.Conv2D(filters=args.weight_filter,
                                        kernel_size=(3, 3),
                                        strides=(args.stride1, args.stride1),
                                        padding=tf_padding,
                                        activation=None)(input_layer)
    model = tf.keras.Model(inputs=input_layer, outputs=conv_layer)
    model.layers[1].set_weights([weight_data.astype(np.float32), bias_data])

    # Dự đoán và reshape
    output_data = model.predict(input_data.reshape(1, args.ifm_height, args.ifm_width, args.ifm_channel).astype(np.float32))
    output_data = output_data.reshape(output_feature_height, output_feature_width, output_feature_channel)
    output_data = hswish_q53(output_data).numpy()

    # Ghi kết quả
    write_hex_file(output_file, output_data)
    print(f"Kết quả đã được ghi vào {output_file}")
