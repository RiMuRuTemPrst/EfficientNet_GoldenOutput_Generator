import numpy as np
import tensorflow as tf
import argparse
import math

# Hàm đọc dữ liệu từ file HEX với thứ tự hàng → cột → channel → filter
def read_hex_file_weight(filename, shape):
    with open(filename, "r") as file:
        hex_values = file.readlines()
    data = np.array([int(x.strip(), 16) for x in hex_values], dtype=np.int16)

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

# Hàm đọc dữ liệu từ file HEX với thứ tự hàng → cột → channel
def read_hex_file(filename, shape):
    with open(filename, "r") as file:
        hex_values = file.readlines()
    data = np.array([int(x.strip(), 16) for x in hex_values], dtype=np.int32)

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
                    hex_value = int_value & 0xFF
                    file.write(f"{hex_value:02x}\n")

# === Main ===
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ifm_height", type=int, required=True)
    parser.add_argument("--ifm_width", type=int, required=True)
    parser.add_argument("--ifm_channel", type=int, required=True)
    parser.add_argument("--weight_height", type=int, default=1)
    parser.add_argument("--weight_width", type=int, default=1)
    parser.add_argument("--weight_filter", type=int, required=True)
    parser.add_argument("--padding1", type=int, default=0)  # Padding P
    parser.add_argument("--stride1", type=int, default=1)   # Stride S
    args = parser.parse_args()

    # Tính kích thước OFM với padding và stride
    output_feature_height = (args.ifm_height - args.weight_height + 2 * args.padding1) // args.stride1 + 1
    output_feature_width = (args.ifm_width - args.weight_width + 2 * args.padding1) // args.stride1 + 1
    output_feature_channel = args.weight_filter

    # File paths cố định
<<<<<<< HEAD
    input_file = "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Average_Pooling/ofm_3_DUT_6b.hex"
=======
    input_file = "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Average_Pooling/ofm_3.hex"
>>>>>>> 3c744f089472803f0ea1f05f1e58404e4e422e63
    weight_file = "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Reduce/weight_4.hex"
    output_file = "../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Reduce/ofm_4.hex"

    # Đọc dữ liệu
    input_data = read_hex_file(input_file, (args.ifm_height, args.ifm_width, args.ifm_channel))
    weight_data_flat = read_hex_file_weight(weight_file, (args.weight_height, args.weight_width, args.ifm_channel, args.weight_filter))
    weight_data = weight_data_flat.reshape(args.weight_height, args.weight_width, args.ifm_channel, args.weight_filter)

    # Xác định padding cho TensorFlow layer
    tf_padding = "same" if args.padding1 > 0 else "valid"

    # Tạo mô hình
    input_layer = tf.keras.layers.Input(shape=(args.ifm_height, args.ifm_width, args.ifm_channel))
    conv_layer = tf.keras.layers.Conv2D(filters=args.weight_filter,
                                        kernel_size=(args.weight_height, args.weight_width),
                                        strides=(args.stride1, args.stride1),
                                        padding=tf_padding,
                                        activation=None)(input_layer)
    model = tf.keras.Model(inputs=input_layer, outputs=conv_layer)
    model.layers[1].set_weights([weight_data.astype(np.float32), np.zeros(args.weight_filter, dtype=np.float32)])

    # Dự đoán và reshape
    output_data = model.predict(input_data.reshape(1, args.ifm_height, args.ifm_width, args.ifm_channel).astype(np.float32))
    output_data = output_data.reshape(output_feature_height, output_feature_width, output_feature_channel)

    # Ghi kết quả
    write_hex_file(output_file, output_data)
    print(f"Kết quả đã được ghi vào {output_file}")
