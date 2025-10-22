# File: dump_tensors.py
# Mục đích: Trích xuất Weights, Biases và Golden Outputs từ file .tflite.

import tensorflow as tf
import tensorflow_datasets as tfds
import numpy as np
import os

# ==============================
# CONFIG
# ==============================
MODEL_PATH = "./efficientnetv2b0_int8.tflite"
OUT_DIR = "./IFM_Weight_Bias_TFLite_FusedBlock"
GOLDEN_OUT_DIR = "./Golden_Output_Python"

# Xóa và tạo lại thư mục để đảm bảo dữ liệu "sạch"
import shutil
if os.path.exists(OUT_DIR): shutil.rmtree(OUT_DIR)
if os.path.exists(GOLDEN_OUT_DIR): shutil.rmtree(GOLDEN_OUT_DIR)
os.makedirs(OUT_DIR, exist_ok=True)
os.makedirs(GOLDEN_OUT_DIR, exist_ok=True)

# ==============================
# LOAD TFLITE MODEL
# ==============================
print("📦 Loading TFLite model...")
interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
interpreter.allocate_tensors()
input_details = interpreter.get_input_details()[0]
tensor_details = interpreter.get_tensor_details()
ops = interpreter._get_ops_details()

# ==============================
# LOAD ẢNH IMAGENET_V2
# ==============================
print("📸 Loading 1 sample image from ImageNet_V2...")
dataset = tfds.load("imagenet_v2", split="test", shuffle_files=True)
example = next(iter(tfds.as_numpy(dataset.take(1))))
img = example["image"]

# ==============================
# PREPROCESS & QUANTIZE IMAGE
# ==============================
print("🧮 Preprocessing and quantizing image...")
input_scale, input_zero_point = input_details["quantization"]
img = tf.image.resize(img, (224, 224))
img = tf.cast(img, tf.float32) / 255.0
img = img.numpy()
img_int8 = (img / input_scale + input_zero_point).astype(np.int8)
img_int8 = np.expand_dims(img_int8, axis=0)

# ==============================
# SAVE IFM (DATA + PARAMS)
# ==============================
print("\n💾 Saving IFM (input feature map)...")
np.savetxt(os.path.join(OUT_DIR, "ifm_input.txt"), img_int8.flatten(), fmt="%d")
with open(os.path.join(OUT_DIR, "ifm_input_params.txt"), "w") as f:
    f.write(f"Shape: {img_int8.shape}\nScale: {input_scale}\nZero Point: {input_zero_point}\n")
print(f"✅ Saved IFM data and params to: {OUT_DIR}")

# ==============================
# EXPORT WEIGHTS & BIASES
# ==============================
print("\n🔍 Extracting Weights and Biases...")
for op in ops:
    op_name = op["op_name"]
    layer_idx = op["index"]
    prefix = f"layer_{layer_idx:03d}_{op_name}"
    
    weights_tensor, bias_tensor = None, None
    weight_info, bias_info = {}, {}

    if len(op["inputs"]) > 1:
        try:
            weights_tensor = interpreter.get_tensor(op["inputs"][1])
            weight_info = tensor_details[op["inputs"][1]]
        except Exception: pass
    if len(op["inputs"]) > 2:
        try:
            bias_tensor = interpreter.get_tensor(op["inputs"][2])
            bias_info = tensor_details[op["inputs"][2]]
        except Exception: pass

    if weights_tensor is not None:
        np.savetxt(os.path.join(OUT_DIR, f"{prefix}_weights.txt"), weights_tensor.flatten(), fmt="%d")
    if bias_tensor is not None:
        np.savetxt(os.path.join(OUT_DIR, f"{prefix}_bias.txt"), bias_tensor.flatten(), fmt="%d")

    if weights_tensor is not None or bias_tensor is not None:
        with open(os.path.join(OUT_DIR, f"{prefix}_params.txt"), "w") as f:
            out_tensor_info = tensor_details[op['outputs'][0]]
            q = out_tensor_info["quantization"]
            f.write(f"Op Type: {op_name}\nOutput Tensor: {out_tensor_info['name']}\n")
            f.write(f"Output Scale: {q[0]}\nOutput Zero Point: {q[1]}\nOutput Shape: {out_tensor_info['shape']}\n\n")
            if weights_tensor is not None:
                q_w = weight_info.get("quantization_parameters", {})
                f.write(f"# --- Weights ---\nShape: {weights_tensor.shape}\n")
                f.write(f"Scale(s): {q_w.get('scales', []).tolist()}\nZero Point(s): {q_w.get('zero_points', []).tolist()}\n\n")
            if bias_tensor is not None:
                q_b = bias_info.get("quantization_parameters", {})
                f.write(f"# --- Bias ---\nShape: {bias_tensor.shape}\n")
                # ✅ SỬA LỖI NHỎ: Điều kiện `if` dùng q_b thay vì q_w
                f.write(f"Scale(s): {q_b.get('scales', []).tolist()}\n")
                f.write(f"Zero Point(s): {q_b.get('zero_points', []).tolist()}\n\n")
        print(f"✅ Exported params for {op_name} (layer {layer_idx})")

# ==============================
# GOLDEN OUTPUT DUMP
# ==============================
print("\n🚀 Running inference and dumping Golden Outputs...")
interpreter.set_tensor(input_details["index"], img_int8)
interpreter.invoke()

for op in ops:
    if not op["outputs"]: continue
    op_name, layer_idx = op["op_name"], op["index"]
    out_index = op["outputs"][0]
    out_tensor = interpreter.get_tensor(out_index)
    out_data_file = os.path.join(GOLDEN_OUT_DIR, f"layer_{layer_idx:03d}_{op_name}_output.txt")
    np.savetxt(out_data_file, out_tensor.flatten(), fmt="%d")
    print(f"✅ Saved Golden Output for {op_name} (layer {layer_idx}) → {out_data_file}")

print("\n\n🎉 Done! All data has been exported.")