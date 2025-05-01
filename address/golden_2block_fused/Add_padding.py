import numpy as np
import argparse
def read_hex_file(filename, shape):
    with open(filename, "r") as file:
        hex_values = file.readlines()
    data = np.array([int(x.strip(), 16) for x in hex_values], dtype=np.int32)

    H, W, C = shape
    reshaped_data = np.zeros((H, W, C), dtype=np.int32)
    index = 0
    for h in range(H):
        for w in range(W):
            for c in range(C):
                reshaped_data[h, w, c] = data[index]
                index += 1
    return reshaped_data

def pad_ifm(ifm, pad):
    # Pad theo thứ tự (H, W, C) → chỉ pad H và W
    return np.pad(ifm, ((pad, pad), (pad, pad), (0, 0)), mode='constant', constant_values=0)

def write_hex_file(filename, padded_ifm):
    H, W, C = padded_ifm.shape
    with open(filename, 'w') as f:
        for h in range(H):
            for w in range(W):
                for c in range(C):
                    f.write(f"{padded_ifm[h, w, c]:02x}\n")  # Ghi theo thứ tự: channel → row → col

# ======== Sử dụng ==========
input_file = "../Fused-Block-CNN/address/golden_2block_fused/hex/ifm.hex"
output_file = "../Fused-Block-CNN/address/golden_2block_fused/hex/ifm_padded.hex"
parser = argparse.ArgumentParser()
parser.add_argument("--ifm_height", type=int, required=True)
parser.add_argument("--ifm_width", type=int, required=True)
parser.add_argument("--ifm_channel", type=int, required=True)
parser.add_argument("--padding", type=int, default=0)  # Padding P
args = parser.parse_args()
C, H, W = args.ifm_channel, args.ifm_width, args.ifm_height         # IFM gốc
padding = args.padding

ifm = read_hex_file(input_file, (H, W, C))
padded_ifm = pad_ifm(ifm, padding)
write_hex_file(output_file, padded_ifm)
