import numpy as np

# Giả sử output từ CNN có shape (H, W, C)
H, W, C = 4, 4, 8
output_cnn = np.random.randn(H, W, C)  # dữ liệu giả ngẫu nhiên

# Flatten thành vector 1 chiều 128 phần tử
flattened = output_cnn.flatten()  # shape (128,)

print(f"Shape after flatten: {flattened.shape}")

# Dense layer: 10 neuron đầu ra
num_outputs = 10
input_size = flattened.shape[0]  # 128

# Khởi tạo weight và bias
# Weight shape: (num_outputs, input_size)
W = np.random.randn(num_outputs, input_size)
b = np.random.randn(num_outputs)

# Tính output lớp dense
y = W @ flattened + b  # ma trận nhân vector + bias

print(f"Output Dense shape: {y.shape}")
print(f"Output Dense vector:\n{y}")
