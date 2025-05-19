import numpy as np
import matplotlib.pyplot as plt

# Đường dẫn tới 2 file weight
original_path = 'model/layer_weights_txt/003_stem_conv_w0.txt'
quantized_path = 'model/quantized_weights/003_stem_conv_w0_q.txt'

# Đọc weight gốc
with open(original_path, 'r') as f:
    original_data = [float(line.strip()) for line in f if line.strip()]
original_data = np.array(original_data)

# Đọc weight đã lượng tử
with open(quantized_path, 'r') as f:
    quantized_data = [float(line.strip()) for line in f if line.strip()]
quantized_data = np.array(quantized_data)

# Vẽ histogram so sánh
plt.figure(figsize=(10, 6))
plt.hist(original_data, bins=100, alpha=0.6, label='Original', color='skyblue', edgecolor='black')
plt.hist(quantized_data, bins=100, alpha=0.6, label='Quantized', color='salmon', edgecolor='black')
plt.title('Histogram Comparison of Weights (Original vs Quantized)')
plt.xlabel('Weight Value')
plt.ylabel('Frequency')
plt.legend()
plt.grid(True)
plt.show()
