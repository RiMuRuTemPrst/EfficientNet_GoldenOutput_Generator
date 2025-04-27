import numpy as np
import argparse

def save_to_hex_file(data, filename):
    with open(filename, 'w') as f:
        for val in data.flatten():
            int_val = int(val)
            f.write(f"{int_val & 0xFF:02X}\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ifm_height", type=int, required=True)
    parser.add_argument("--ifm_width", type=int, required=True)
    parser.add_argument("--ifm_channel", type=int, required=True)
    parser.add_argument("--weight_filter_1", type=int, required=True)
    parser.add_argument("--weight_filter_2", type=int, required=True)
    parser.add_argument("--weight_filter_3", type=int, required=True)
    parser.add_argument("--weight_filter_4", type=int, required=True)
    args = parser.parse_args()

    np.random.seed(42)
    IFM = np.random.randint(0, 256, size=(args.ifm_height, args.ifm_width, args.ifm_channel), dtype=np.uint8)
    Weight_3x3_1 = np.random.randint(0, 256, size=(args.ifm_channel, 3, 3, args.weight_filter_1), dtype=np.uint8)
    Weight_1x1_1 = np.random.randint(0, 256, size=(args.weight_filter_1, 1, 1, args.weight_filter_2), dtype=np.uint8)
    Weight_3x3_2 = np.random.randint(0, 256, size=(args.weight_filter_2, 3, 3, args.weight_filter_3), dtype=np.uint8)
    Weight_1x1_2 = np.random.randint(0, 256, size=(args.weight_filter_3, 1, 1, args.weight_filter_4), dtype=np.uint8)
    # padded_height = args.ifm_height + 2 * args.padding
    # padded_width = args.ifm_width + 2 * args.padding

    save_to_hex_file(IFM ,"../Fused-Block-CNN/address/golden_2block_fused/hex/ifm.hex")
    save_to_hex_file(Weight_3x3_1, "../Fused-Block-CNN/address/golden_2block_fused/hex/weight_1.hex")
    save_to_hex_file(Weight_1x1_1, "../Fused-Block-CNN/address/golden_2block_fused/hex/weight_2.hex")    
    save_to_hex_file(Weight_3x3_2, "../Fused-Block-CNN/address/golden_2block_fused/hex/weight_3.hex")
    save_to_hex_file(Weight_1x1_2, "../Fused-Block-CNN/address/golden_2block_fused/hex/weight_4.hex")  
    print("✅ Đã lưu IFM (padded) và Weight.")
