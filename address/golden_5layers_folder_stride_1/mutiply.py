import numpy as np
import tensorflow as tf
import argparse

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

def write_hex_file(filename, data):
    H, W, C = data.shape
    with open(filename, "w") as f:
        for h in range(H):
            for w in range(W):
                for c in range(C):
                    val = int(round(data[h, w, c]))
                    f.write(f"{val & 0xFF:02X}\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--height", type=int, required=True)
    parser.add_argument("--channel", type=int, required=True)
    parser.add_argument("--channel_1", type=int, required=True)
    args = parser.parse_args()

    # Read data
    X = read_hex_file("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/DW/ofm_2.hex", (args.height, args.height, args.channel))
    S = read_hex_file("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Expand/ofm_5.hex", (1, 1, args.channel_1))

    # Convert to tensors
    X_tensor = tf.convert_to_tensor(X[None, ...], dtype=tf.float32)  # shape: (1, H, W, C)
    S_tensor = tf.convert_to_tensor(S[None, ...], dtype=tf.float32)  # shape: (1, 1, 1, C)

    # Multiply
    output_tensor = tf.keras.layers.Multiply()([X_tensor, S_tensor])
    output_data = output_tensor.numpy().squeeze()  # shape: (H, W, C)

    # Write output
    write_hex_file("../Fused-Block-CNN/address/golden_5layers_folder_stride_1/hex/Mutiply/ofm.hex", output_data)
