import h5py
import numpy as np

# Đường dẫn đến file weight.h5
file_path = 'Sw\mnist_quantized_weights.weights.h5'

# Mở file HDF5
with h5py.File(file_path, 'r') as f:
    # Hàm đệ quy để duyệt qua tất cả các key trong file
    def print_weights(name, obj):
        if isinstance(obj, h5py.Dataset):  # Nếu là dataset (chứa weights)
            print(f'\nLayer: {name}')
            print(f'Shape: {obj.shape}')
            print(f'Weights:\n{np.array(obj)}')

    # Duyệt qua tất cả các phần tử trong file
    print("Cấu trúc file HDF5:")
    f.visititems(print_weights)

    # Nếu muốn liệt kê tất cả các key mà không in weights
    print("\nDanh sách tất cả các key trong file:")
    for key in f.keys():
        print(key)