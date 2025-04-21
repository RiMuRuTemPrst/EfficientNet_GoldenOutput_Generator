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
    parser.add_argument("--weight_height", type=int, required=True)
    parser.add_argument("--weight_width", type=int, required=True)
    parser.add_argument("--weight_filter", type=int, required=True)
    parser.add_argument("--weight_height_2", type=int, required=True)
    parser.add_argument("--weight_width_2", type=int, required=True)
    parser.add_argument("--weight_filter_2", type=int, required=True)
    parser.add_argument("--padding1", type=int, default=0)
    args = parser.parse_args()

    np.random.seed(42)
    IFM = np.random.randint(0, 256, size=(args.ifm_height, args.ifm_width, args.ifm_channel), dtype=np.uint8)
    Weight = np.random.randint(0, 256, size=(args.weight_filter, args.weight_height, args.weight_width, args.ifm_channel), dtype=np.uint8)
    Weight_2 = np.random.randint(0, 256, size=(1, args.weight_height_2, args.weight_width_2, args.weight_filter), dtype=np.uint8)
    Weight_4 = np.random.randint(0, 256, size=(192, 1, 1, 12), dtype=np.uint8)
    Weight_5 = np.random.randint(0, 256, size=(12, 1, 1, 192), dtype=np.uint8)
    # padded_height = args.ifm_height + 2 * args.padding
    # padded_width = args.ifm_width + 2 * args.padding

    save_to_hex_file(IFM ,"../Fused-Block-CNN/address/golden_2layers_folder/hex/Layer1/ifm.hex")
    save_to_hex_file(Weight, "../Fused-Block-CNN/address/golden_2layers_folder/hex/Layer1/weight.hex")
    save_to_hex_file(Weight_2, "../Fused-Block-CNN/address/golden_2layers_folder/hex/DW/weight_2.hex")    
    save_to_hex_file(Weight_4, "../Fused-Block-CNN/address/golden_2layers_folder/hex/Reduce/weight_4.hex")
    save_to_hex_file(Weight_5, "../Fused-Block-CNN/address/golden_2layers_folder/hex/Expand/weight_5.hex")  
    print("✅ Đã lưu IFM (padded) và Weight.")
