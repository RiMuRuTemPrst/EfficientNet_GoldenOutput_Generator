import numpy as np
import tensorflow as tf
import argparse

# Hàm đọc dữ liệu từ file HEX với thứ tự hàng → cột → channel → depth_multiplier
def read_hex_file_weight(filename, shape):
    with open(filename, "r") as file:
        hex_values = file.readlines()
    data = np.array([int(x.strip(), 16) for x in hex_values], dtype=np.int16)

    H, W, C, D = shape
    reshaped_data = np.zeros((H, W, C, D), dtype=np.int16)
    index = 0
    for d in range(D):
        for c in range(C):
            for h in range(H):
                for w in range(W):
                    reshaped_data[h, w, c, d] = data[index]
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
                    file.write(f"{hex_value:02X}\n")

# === Main ===
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ifm_height", type=int, required=True)
    parser.add_argument("--ifm_width", type=int, required=True)
    parser.add_argument("--ifm_channel", type=int, required=True)
    parser.add_argument("--weight_height", type=int, required=True)
    parser.add_argument("--weight_width", type=int, required=True)
    parser.add_argument("--depth_multiplier", type=int, default=1)
    parser.add_argument("--padding2", type=int, default=0)
    parser.add_argument("--stride2", type=int, default=1)
    args = parser.parse_args()

    output_feature_height = (args.ifm_height - args.weight_height + 2 * args.padding2) // args.stride2 + 1
    output_feature_width = (args.ifm_width - args.weight_width + 2 * args.padding2) // args.stride2 + 1
    output_feature_channel = args.ifm_channel * args.depth_multiplier

    input_file = "../Fused-Block-CNN/address/golden_2layers_folder/hex/Layer1/ofm_layer1.hex"
    weight_file = "../Fused-Block-CNN/address/golden_2layers_folder/hex/DW/weight_2.hex"
    output_file = "../Fused-Block-CNN/address/golden_2layers_folder/hex/DW/ofm_2.hex"

    input_data = read_hex_file(input_file, (args.ifm_height, args.ifm_width, args.ifm_channel))
    weight_data = read_hex_file_weight(weight_file, (args.weight_height, args.weight_width, args.ifm_channel, args.depth_multiplier))

# # In 10 giá trị đầu tiên của input_data ở dạng hex
# print("10 giá trị đầu tiên của input_data (hex):")
# flat_input = input_data.flatten()
# for i in range(min(10, flat_input.shape[0])):
#     hex_val = flat_input[i] & 0xFF  # chỉ lấy 8 bit thấp
#     print(f"input_data[{i}] = 0x{hex_val:02X}")

# # In 10 giá trị đầu tiên của weight_data ở dạng hex
# print("\n10 giá trị đầu tiên của weight_data (hex):")
# flat_weight = weight_data.flatten()
# for i in range(min(10, flat_weight.shape[0])):
#     hex_val = flat_weight[i] & 0xFF  # chỉ lấy 8 bit thấp
#     print(f"weight_data[{i}] = 0x{hex_val:02X}")



#      # In 10 giá trị đầu tiên của input_data
#     print("10 giá trị đầu tiên của input_data:")
#     flat_input = input_data.flatten()
#     for i in range(min(10, flat_input.shape[0])):
#         print(f"input_data[{i}] = {flat_input[i]}")

#     # In 10 giá trị đầu tiên của weight_data
#     print("\n10 giá trị đầu tiên của weight_data:")
#     flat_weight = weight_data.flatten()
#     for i in range(min(10, flat_weight.shape[0])):
#         print(f"weight_data[{i}] = {flat_weight[i]}")


    tf_padding = "same" if args.padding2 > 0 else "valid"

    input_layer = tf.keras.layers.Input(shape=(args.ifm_height, args.ifm_width, args.ifm_channel))
    depthwise_layer = tf.keras.layers.DepthwiseConv2D(kernel_size=(args.weight_height, args.weight_width),
                                                       strides=(args.stride2, args.stride2),
                                                       depth_multiplier=args.depth_multiplier,
                                                       padding=tf_padding,
                                                       activation=None)(input_layer)
    model = tf.keras.Model(inputs=input_layer, outputs=depthwise_layer)
    model.layers[1].set_weights([weight_data.astype(np.float32), np.zeros(output_feature_channel, dtype=np.float32)])

    output_data = model.predict(input_data.reshape(1, args.ifm_height, args.ifm_width, args.ifm_channel).astype(np.float32))
    output_data = output_data.reshape(output_feature_height, output_feature_width, output_feature_channel)
    write_hex_file(output_file, output_data)
    print(f"Kết quả đã được ghi vào {input_file}")
    print(f"Kết quả đã được ghi vào {output_file}")
