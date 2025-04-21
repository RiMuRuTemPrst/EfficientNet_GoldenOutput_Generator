import numpy as np
import tensorflow as tf
import argparse

# Hàm đọc dữ liệu từ file HEX: H × W × C
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

# Hàm ghi dữ liệu ra file HEX (1x1xC)
def write_hex_file(filename, data):
    _, _, C = data.shape
    with open(filename, "w") as file:
        for c in range(C):
            int_value = int(np.floor(data[0, 0, c]))  # 👈 Làm tròn xuống
            hex_value = int_value & 0xFF              # Giới hạn trong 8-bit
            file.write(f"{hex_value:02x}\n")          # Ghi dạng HEX 2 chữ số

# === Main ===
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ifm_height", type=int, required=True)
    parser.add_argument("--ifm_width", type=int, required=True)
    parser.add_argument("--ifm_channel", type=int, required=True)
    args = parser.parse_args()

    # File input/output
    input_file = "../Fused-Block-CNN/address/golden_5layers_folder/hex/DW/ofm_2_stride.hex"
    output_file = "../Fused-Block-CNN/address/golden_5layers_folder/hex/Average_Pooling/ofm_3.hex"

    # Đọc IFM
    input_data = read_hex_file(input_file, (args.ifm_height, args.ifm_width, args.ifm_channel))

    # Tạo mô hình GlobalAveragePooling2D
    input_layer = tf.keras.layers.Input(shape=(args.ifm_height, args.ifm_width, args.ifm_channel))
    gap_layer = tf.keras.layers.GlobalAveragePooling2D()(input_layer)
    model = tf.keras.Model(inputs=input_layer, outputs=gap_layer)

    # Dự đoán
    output_data = model.predict(input_data.reshape(1, args.ifm_height, args.ifm_width, args.ifm_channel).astype(np.float32))

    # Reshape lại thành (1, 1, C) để ghi đúng format hex
    output_data = output_data.reshape(1, 1, args.ifm_channel)

    # Ghi kết quả
    write_hex_file(output_file, output_data)
    print(f"Kết quả đã được ghi vào {output_file}")
