import os
import numpy as np
from tensorflow.keras.models import load_model

# Load mô hình từ file đã lưu
model = load_model('model/efficientnetv2b0_imagenet.h5')

# Tạo thư mục chứa file txt
output_dir = 'model/layer_weights_txt'
os.makedirs(output_dir, exist_ok=True)

# Duyệt qua từng lớp
for i, layer in enumerate(model.layers):
    weights = layer.get_weights()
    if weights:
        for j, w in enumerate(weights):
            filename = f"{i:03d}_{layer.name}_w{j}.txt"
            filepath = os.path.join(output_dir, filename)
            
            # Ghi từng phần tử trên 1 dòng
            with open(filepath, 'w') as f:
                flat_w = w.flatten()
                for val in flat_w:
                    f.write(f"{val}\n")
            
            print(f"Đã lưu: {filepath} ({w.shape} -> {flat_w.shape})")
    else:
        print(f"Bỏ qua layer {i} ({layer.name}) vì không có trọng số.")
