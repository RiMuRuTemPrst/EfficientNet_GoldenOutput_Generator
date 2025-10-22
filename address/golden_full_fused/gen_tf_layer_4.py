import numpy as np
import tensorflow as tf
import argparse
import math
def h_swish(x):
    return x * tf.nn.relu6(x + 3) / 6
# Hàm đọc dữ liệu từ file HEX với thứ tự hàng → cột → channel → filter
INT8_MIN, INT8_MAX = -128, 127  # Dải giá trị cho Q5.3
def quantize_q106_to_q53(x_q106: tf.Tensor) -> tf.Tensor:
    """
    Hàm này sẽ chuyển giá trị từ Q10.6 về Q5.3.
    
    - Q10.6 có 10 bit phần nguyên và 6 bit phần thập phân
    - Q5.3 có 5 bit phần nguyên và 3 bit phần thập phân

    Args:
        x_q106: Tensor input kiểu Q10.6.
    
    Returns:
        Tensor kiểu Q5.3.
    """
    # Chuyển đổi kiểu dữ liệu từ Q10.6 sang int32
    x_i32 = tf.cast(x_q106, tf.int32)
    
    # Chuyển từ Q10.6 về Q5.3 bằng cách chia 2^(10 - 5) = 2^5 = 32
    # Shift phải 5 bit để chuyển từ Q10.6 về Q5.3
    y_q53 = tf.bitwise.right_shift(x_i32, (10 - 7))  # Chuyển từ Q10.6 về Q5.3
    
    # Giới hạn giá trị trong phạm vi Q5.3
    y_q53 = tf.clip_by_value(y_q53, INT8_MIN, INT8_MAX)
    
    return tf.cast(y_q53, tf.int8)  # Trả về kết quả kiểu Q5.3
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
                    hex_value = int_value & 0xFFFF
                    file.write(f"{hex_value:04X}\n")

# === Main ===
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ifm_height", type=int, required=True)
    parser.add_argument("--ifm_width", type=int, required=True)
    parser.add_argument("--ifm_channel", type=int, required=True)
    parser.add_argument("--weight_filter", type=int, required=True)
    parser.add_argument("--padding1", type=int, default=0)  # Padding P
    parser.add_argument("--stride1", type=int, default=1)   # Stride S
    args = parser.parse_args()

    # Tính kích thước OFM với padding và stride
    output_feature_height = (args.ifm_height - 1 + 2 * args.padding1) // args.stride1 + 1
    output_feature_width = (args.ifm_width - 1 + 2 * args.padding1) // args.stride1 + 1
    output_feature_channel = args.weight_filter

    # File paths cố định
    input_file = "../Fused-Block-CNN/address/golden_full_fused/hex/ofm_layer3.hex"
    weight_file = "../Fused-Block-CNN/address/golden_full_fused/hex/weight_4.hex"
    output_file = "../Fused-Block-CNN/address/golden_full_fused/hex/ofm_layer4.hex"
    bias_file = "../Fused-Block-CNN/address/golden_full_fused/hex/bias_4.hex"

    # Đọc dữ liệu
    input_data = read_hex_file(input_file, (args.ifm_height, args.ifm_width, args.ifm_channel))
    weight_data_flat = read_hex_file_weight(weight_file, (1, 1, args.ifm_channel, args.weight_filter))
    weight_data = weight_data_flat.reshape(1, 1, args.ifm_channel, args.weight_filter)
    bias_data = read_bias_file(bias_file, args.weight_filter).astype(np.float32)

    # Xác định padding cho TensorFlow layer
    tf_padding = "same" if args.padding1 > 0 else "valid"

    # Tạo mô hình
    input_layer = tf.keras.layers.Input(shape=(args.ifm_height, args.ifm_width, args.ifm_channel))
    conv_layer = tf.keras.layers.Conv2D(filters=args.weight_filter,
                                        kernel_size=(1, 1),
                                        strides=(args.stride1, args.stride1),
                                        padding=tf_padding,
                                        activation=None)(input_layer)
    model = tf.keras.Model(inputs=input_layer, outputs=conv_layer)
    model.layers[1].set_weights([weight_data.astype(np.float32), bias_data])

    # Dự đoán và reshape
    output_data = model.predict(input_data.reshape(1, args.ifm_height, args.ifm_width, args.ifm_channel).astype(np.float32))
    output_data = output_data.reshape(output_feature_height, output_feature_width, output_feature_channel)
    output_data = quantize_q106_to_q53(output_data).numpy()

    # Ghi kết quả
    write_hex_file(output_file, output_data)
    print(f"Kết quả đã được ghi vào {output_file}")
