# gen_weight_IWHO_format.py
# Xuất weights theo IWHO (phương án B) trực tiếp từ .tflite
# - CONV_2D:    (O, H, W, I) -> (I, W, H, O)
# - DEPTHWISE:  (1, H, W, O=I_in*M) -> (I_in, W, H, M)
# - FULLY_CONN: (O, I) -> (I, 1, 1, O)

import os
import numpy as np
import tensorflow as tf

SCRIPT_VERSION = "IWHO-B v2"

# ==============================
# CONFIG
# ==============================
MODEL_PATH   = r"./efficientnetv2b0_int8.tflite"
OUT_IWHO_DIR = r"./Weights_IWHO_B"

os.makedirs(OUT_IWHO_DIR, exist_ok=True)

# ==============================
# LOAD MODEL
# ==============================
print(f"📦 Loading TFLite model...  [{SCRIPT_VERSION}]")
interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
interpreter.allocate_tensors()
tensor_details = interpreter.get_tensor_details()
ops = interpreter._get_ops_details()

# ==============================
# UTILS
# ==============================
td_by_index = {td["index"]: td for td in tensor_details}

def get_td(idx):
    return td_by_index.get(int(idx), None)

def get_qparams(td):
    if td is None:
        return {}
    qp = td.get("quantization_parameters", {}) or {}
    return {
        "scales":    np.array(qp.get("scales", []), dtype=np.float32),
        "zero_pts":  np.array(qp.get("zero_points", []), dtype=np.int32),
        "dim":       int(qp.get("quantized_dimension", 0)) if "quantized_dimension" in qp else 0,
    }

def save_txt(path, arr):
    np.savetxt(path, arr.flatten(), fmt="%d")

def write_params(path, **kwargs):
    with open(path, "w", encoding="utf-8") as f:
        for k, v in kwargs.items():
            f.write(f"{k}: {v}\n")

def to_list_safe(x):
    if isinstance(x, np.ndarray):
        return x.tolist()
    return list(x) if isinstance(x, (list, tuple)) else ([] if x is None else [x])

# ==============================
# MAIN
# ==============================
print("🧭 Exporting weights to IWHO (phương án B)...")

num_layers = 0
for op in ops:
    op_name   = op["op_name"]
    layer_idx = op["index"]
    prefix    = f"layer_{layer_idx:03d}_{op_name}"

    # --- Inputs & Outputs (ép về list) ---
    inputs  = to_list_safe(op.get("inputs", []))
    outputs = to_list_safe(op.get("outputs", []))
    n_in, n_out = len(inputs), len(outputs)

    # Lấy weights nếu có
    weights, w_td = None, None
    if n_in > 1:
        try:
            w_idx   = int(inputs[1])
            weights = interpreter.get_tensor(w_idx)
            w_td    = get_td(w_idx)
        except Exception:
            weights = None

    if weights is None:
        continue  # op không có weights (ReLU/ADD/POOL/...); bỏ qua

    # Lấy bias nếu có
    bias, b_td = None, None
    if n_in > 2:
        try:
            b_idx = int(inputs[2])
            bias  = interpreter.get_tensor(b_idx)
            b_td  = get_td(b_idx)
        except Exception:
            bias = None

    # Output tensor info (để log)
    out_td = get_td(int(outputs[0])) if n_out > 0 else None
    out_q  = out_td["quantization"] if (out_td and "quantization" in out_td) else (0.0, 0)

    # ------------------------------
    # Xử lý từng loại op
    # ------------------------------
    if op_name == "CONV_2D":
        if weights.ndim != 4:
            print(f"⚠️  {prefix}: CONV_2D weights ndim={weights.ndim} != 4, bỏ qua.")
            continue
        O, H, W, I = weights.shape
        w_iwho = np.transpose(weights, (3, 2, 1, 0))  # (I, W, H, O)

        save_txt(os.path.join(OUT_IWHO_DIR, f"{prefix}_weights_IWHO.txt"), w_iwho)
        if bias is not None:
            save_txt(os.path.join(OUT_IWHO_DIR, f"{prefix}_bias.txt"), bias)

        w_qp = get_qparams(w_td)
        b_qp = get_qparams(b_td)
        write_params(
            os.path.join(OUT_IWHO_DIR, f"{prefix}_params.txt"),
            **{
                "Op Type": op_name,
                "Orig Weight Shape (O,H,W,I)": weights.shape,
                "IWHO Weight Shape (I,W,H,O)": w_iwho.shape,
                "Bias Shape": None if bias is None else bias.shape,
                "Output Tensor": None if out_td is None else out_td.get("name", ""),
                "Output Scale": out_q[0],
                "Output ZeroPoint": out_q[1],
                "W scales (len)": len(w_qp.get("scales", [])),
                "W zero_points (len)": len(w_qp.get("zero_pts", [])),
                "W quant_dim": w_qp.get("dim", 0),
                "B scales (len)": 0 if bias is None else len(b_qp.get("scales", [])),
                "B zero_points (len)": 0 if bias is None else len(b_qp.get("zero_pts", [])),
                "Note": "CONV_2D -> IWHO (I,W,H,O)",
            }
        )

        num_layers += 1
        print(f"✅ Saved {prefix}  CONV_2D  {weights.shape} -> {w_iwho.shape}")

    elif op_name == "DEPTHWISE_CONV_2D":
        if weights.ndim != 4 or weights.shape[0] != 1:
            print(f"⚠️  {prefix}: DEPTHWISE weights shape {weights.shape}, bỏ qua.")
            continue

        _, H, W, O = weights.shape

        if n_in == 0:
            print(f"⚠️  {prefix}: không có inputs cho DEPTHWISE, bỏ qua.")
            continue
        in0_td = get_td(int(inputs[0]))
        if in0_td is None or "shape" not in in0_td:
            print(f"⚠️  {prefix}: không lấy được input0 shape, bỏ qua.")
            continue

        I_in = int(in0_td["shape"][-1])
        if O % I_in != 0:
            print(f"⚠️  {prefix}: O={O} không chia hết cho I_in={I_in}")
            continue
        M = O // I_in

        # (1,H,W,O) -> (H,W,O) -> (H,W,I_in,M) -> transpose -> (I_in, W, H, M)
        w = np.squeeze(weights, axis=0)          # (H, W, O)
        w = w.reshape(H, W, I_in, M)             # (H, W, I, M)
        w_iwho = np.transpose(w, (2, 1, 0, 3))   # (I, W, H, M)

        save_txt(os.path.join(OUT_IWHO_DIR, f"{prefix}_weights_IWHO.txt"), w_iwho)
        if bias is not None:
            save_txt(os.path.join(OUT_IWHO_DIR, f"{prefix}_bias.txt"), bias)

        w_qp = get_qparams(w_td)
        b_qp = get_qparams(b_td)
        write_params(
            os.path.join(OUT_IWHO_DIR, f"{prefix}_params.txt"),
            **{
                "Op Type": op_name,
                "Orig Weight Shape (1,H,W,O)": weights.shape,
                "Decomposed": f"I_in={I_in}, M={M}, O=I_in*M",
                "IWHO(Depthwise) Shape (I,W,H,M)": w_iwho.shape,
                "Bias Shape": None if bias is None else bias.shape,
                "Output Tensor": None if out_td is None else out_td.get("name", ""),
                "Output Scale": out_q[0],
                "Output ZeroPoint": out_q[1],
                "W scales (len)": len(w_qp.get("scales", [])),
                "W zero_points (len)": len(w_qp.get("zero_pts", [])),
                "W quant_dim": w_qp.get("dim", 0),
                "B scales (len)": 0 if bias is None else len(b_qp.get("scales", [])),
                "B zero_points (len)": 0 if bias is None else len(b_qp.get("zero_pts", [])),
                "Note": "DEPTHWISE -> (I_in, W, H, M); dùng groups=I_in khi thực thi",
            }
        )

        num_layers += 1
        print(f"✅ Saved {prefix}  DEPTHWISE  {weights.shape} -> {w_iwho.shape} (I={I_in}, M={M})")

    elif op_name == "FULLY_CONNECTED":
        if weights.ndim != 2:
            print(f"⚠️  {prefix}: FC weights ndim={weights.ndim} != 2, bỏ qua.")
            continue
        O, I = weights.shape
        w_iwho = weights.T.reshape(I, 1, 1, O)

        save_txt(os.path.join(OUT_IWHO_DIR, f"{prefix}_weights_IWHO.txt"), w_iwho)
        if bias is not None:
            save_txt(os.path.join(OUT_IWHO_DIR, f"{prefix}_bias.txt"), bias)

        w_qp = get_qparams(w_td)
        b_qp = get_qparams(b_td)
        write_params(
            os.path.join(OUT_IWHO_DIR, f"{prefix}_params.txt"),
            **{
                "Op Type": op_name,
                "Orig Weight Shape (O,I)": weights.shape,
                "IWHO Weight Shape (I,1,1,O)": w_iwho.shape,
                "Bias Shape": None if bias is None else bias.shape,
                "Output Tensor": None if out_td is None else out_td.get("name", ""),
                "Output Scale": out_q[0],
                "Output ZeroPoint": out_q[1],
                "W scales (len)": len(w_qp.get("scales", [])),
                "W zero_points (len)": len(w_qp.get("zero_pts", [])),
                "W quant_dim": w_qp.get("dim", 0),
                "B scales (len)": 0 if bias is None else len(b_qp.get("scales", [])),
                "B zero_points (len)": 0 if bias is None else len(b_qp.get("zero_pts", [])),
                "Note": "FC -> IWHO ảo (I,1,1,O)",
            }
        )

        num_layers += 1
        print(f"✅ Saved {prefix}  FULLY_CONNECTED  {weights.shape} -> {w_iwho.shape}")

    else:
        # các op khác (ReLU, Add, Pooling...) không có weights
        continue

print(f"\n🎉 Done. Exported {num_layers} layers → {OUT_IWHO_DIR}")
