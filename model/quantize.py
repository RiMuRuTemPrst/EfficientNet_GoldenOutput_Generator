import numpy as np

def power_of_two_quantize(x, W=2, frac_bits=6):
    M = np.max(np.abs(x))
    if M == 0:
        return np.zeros_like(x)
    
    # Scale theo SPARK
    scale_exp = np.floor(np.log2(M))
    S = (2 ** (W - 1) - 1) / (2 ** (np.log2(M)))
    
    x_scaled = S * x
    log2_vals = np.round(np.log2(np.abs(x_scaled) + 1e-6))
    xq = np.sign(x_scaled) * (2 ** log2_vals)
    
    max_val = 2 ** (W - frac_bits - 1) - 2 ** (-frac_bits)
    min_val = -2 ** (W - frac_bits - 1)
    xq_clipped = np.clip(xq, min_val, max_val)
    
    return xq_clipped

# === Nhập file weight cần lượng tử ===
input_file = 'model/layer_weights_txt/003_stem_conv_w0.txt'
output_file = 'model/quantized_weights/003_stem_conv_w0_q.txt'

# Tạo thư mục output nếu chưa có
import os
os.makedirs(os.path.dirname(output_file), exist_ok=True)

# Đọc dữ liệu từ file
with open(input_file, 'r') as f:
    weights = [float(line.strip()) for line in f if line.strip()]
weights = np.array(weights)

# Lượng tử hóa
quantized_weights = power_of_two_quantize(weights)

# Ghi ra file (mỗi giá trị 1 dòng)
with open(output_file, 'w') as f:
    for val in quantized_weights:
        f.write(f"{val}\n")

print(f"✅ Đã lượng tử xong và lưu ra: {output_file}")
