import os
import numpy as np
import tensorflow as tf
import shutil
import tensorflow_datasets as tfds
# import json  # nếu chưa import
from PIL import Image

# ========= CONFIG =========
TFLITE_PATH = "efficientnetv2b0_int8.tflite"
assert os.path.exists(TFLITE_PATH), f"Không tìm thấy file: {TFLITE_PATH}"

LOG_DIR = "./Golden_Data/Detailed_Logs"         # Thư mục chứa log chi tiết và kiểm tra requant
DATA_DUMP_DIR = "./Golden_Data/Data_Dump"       # Thư mục chứa các file .txt dữ liệu riêng lẻ

# Xóa và tạo lại thư mục
for d in [LOG_DIR, DATA_DUMP_DIR]:
    if os.path.exists(d): shutil.rmtree(d)
    os.makedirs(d)

# Input deterministic
INPUT_SOURCE = "fixed"      # "zeros" | "fixed" | "file"
INPUT_SHAPE  = (1, 224, 224, 3)
RANDOM_SEED  = 123
FIXED_NPY    = os.path.join(LOG_DIR, "fixed_input_uint8.npy") # Lưu input gốc trong thư mục log

# Cấu hình cho việc in log chi tiết
PRINT_DEQUANT_VALUES = False
NUM_VERIFY_CHANNELS = 6
GRID_H, GRID_W = 5, 5
DEBUG_FULL_TRACE_MAX = 4
ELTWISE_MAX_TRACE = 64

# ========= HELPERS =========
def qparams_of(td):
    if td is None: return None
    qp = td.get('quantization_parameters', {}) or {}
    s  = qp.get('scales', None)
    zp = qp.get('zero_points', None)
    ax = qp.get('quantized_dimension', None)
    s  = None if s  is None else [float(x) for x in np.array(s).reshape(-1)]
    zp = None if zp is None else [int(x)   for x in np.array(zp).reshape(-1)]
    ax = None if ax is None else int(ax)
    stuple, ztuple = td.get('quantization', (None, None))
    return {
        "scales": s, "zero_points": zp, "axis": ax,
        "scale_tuple": None if stuple is None else float(stuple),
        "zp_tuple": None if ztuple is None else int(ztuple),
    }

def basic_of(td):
    if td is None: return None
    shp = td.get('shape', None)
    if shp is not None:
        shp = [int(v) for v in list(shp)]
    return {
        "name": td.get('name'),
        "index": int(td.get('index')) if td.get('index') is not None else None,
        "shape": shp,
        "dtype": str(td.get('dtype', "")),
    }

def dequantize(arr, qinfo):
    if arr is None or qinfo is None: return None
    s = qinfo.get("scale_tuple", None)
    zp = qinfo.get("zp_tuple", None)
    if s is not None and zp is not None:
        return (arr.astype(np.float32) - zp) * s
    if qinfo.get("scales") and qinfo.get("zero_points"):
        return (arr.astype(np.float32) - qinfo["zero_points"][0]) * qinfo["scales"][0]
    return arr.astype(np.float32)

def write_tensor_block(f, title, td, arr):
    f.write(f"\n=== {title} ===\n")
    if td is None:
        f.write("N/A\n"); return
    
    info = basic_of(td)
    qinf = qparams_of(td)
    f.write(f"name    : {info['name']}\n")
    f.write(f"index   : {info['index']}\n")
    f.write(f"shape   : {info['shape']}\n")
    f.write(f"dtype   : {info['dtype']}\n")
    f.write(f"quant   : {qinf}\n")
    
    if arr is None:
        f.write("values  : (N/A)\n"); return
        
    f.write("values(int):\n")
    f.write(np.array2string(arr, threshold=arr.size, max_line_width=120) + "\n")

    if PRINT_DEQUANT_VALUES:
        dq = dequantize(arr, qinf)
        if dq is not None:
            f.write("\nvalues(dequant float):\n")
            f.write(np.array2string(dq, threshold=dq.size, max_line_width=120) + "\n")

def broadcast_param(list_or_none, N, default_val):
    if list_or_none is None or len(list_or_none)==0:
        return np.full((N,), default_val)
    if len(list_or_none)==1:
        return np.full((N,), list_or_none[0])
    arr = np.array(list_or_none)
    if arr.size != N:
        arr = np.resize(arr, N)
    return arr

def quantize_multiplier_smaller_than_one(real_mult):
    rm = np.clip(real_mult, 1e-12, 1.0-1e-7)
    exp = np.zeros_like(rm, dtype=np.int32)
    s = rm.copy()
    while True:
        mask = s < 0.5
        if not np.any(mask): break
        s[mask] *= 2.0
        exp[mask] -= 1
    q = np.floor(s * (1 << 31) + 0.5).astype(np.int64)
    q = np.clip(q, 0, (1 << 31) - 1).astype(np.int32)
    rshift = -exp
    return q, rshift

def srdhm_vec(a, m):
    prod = a.astype(np.int64) * m.astype(np.int64)
    nudge = (1 << 30)
    sign = (prod < 0).astype(np.int64)
    return np.clip(((prod + nudge - sign) >> 31), -2**31, 2**31-1).astype(np.int32)

def rounding_divide_by_pot_scalar(x, shift):
    if shift == 0: return x
    mask = (1 << shift) - 1
    remainder = x & mask
    threshold = (mask >> 1) + (1 if x < 0 else 0)
    return (x >> shift) + (1 if remainder > threshold else 0)

def infer_conv_hyperparams(ifm_shape, ofm_shape):
    if ifm_shape is None or ofm_shape is None: return None
    if len(ifm_shape)!=4 or len(ofm_shape)!=4: return None
    H, W = ifm_shape[1], ifm_shape[2]
    Ho, Wo = ofm_shape[1], ofm_shape[2]
    for s in [1,2,3,4]:
        ho_same = (H + s - 1) // s
        wo_same = (W + s - 1) // s
        if ho_same == Ho and wo_same == Wo:
            return {"stride": (s,s), "padding": "SAME"}
    return {"stride": (1,1), "padding": "VALID"}

def detect_conv_layout_and_kernel(w, Cin, Cout):
    assert w.ndim == 4, f"Conv weights must be 4D, got {w.shape}"
    if w.shape[2] == Cin and w.shape[3] == Cout:
        return "HWIO", int(w.shape[0]), int(w.shape[1])
    if w.shape[0] == Cout and w.shape[3] == Cin:
        return "OHWI", int(w.shape[1]), int(w.shape[2])
    if w.shape[-1] == Cout and w.shape[2] == Cin:
        return "HWIO", int(w.shape[0]), int(w.shape[1])
    if w.shape[0] == Cout and w.shape[-1] == Cin:
        return "OHWI", int(w.shape[1]), int(w.shape[2])
    return "HWIO", int(w.shape[0]), int(w.shape[1])

# ========= BỔ SUNG: LOAD ẢNH THẬT TỪ IMAGENET =========
# ========= BỔ SUNG: LOAD ẢNH THẬT TỪ IMAGENET =========
REAL_IMAGE_PATH = os.path.join(DATA_DUMP_DIR, "imagenet_real_sample.png")
REAL_IMAGE_NORM_PATH = os.path.join(DATA_DUMP_DIR, "imagenet_real_normalized.png")

def save_real_imagenet_sample():
    """Load 1 ảnh thật từ ImageNet (TFDS), lưu vào DATA_DUMP_DIR, chuẩn hóa và phân tích."""
    try:
        import tensorflow_datasets as tfds
        ds = tfds.load("imagenet_v2", split="test", as_supervised=True)
        img, label = next(iter(ds.take(1)))                # (H,W,3), dtype=uint8 or tf.uint8-like
        img = tf.image.resize(img, (224, 224))

        # Ảnh gốc uint8 để lưu xem
        img_uint8 = tf.cast(img, tf.uint8).numpy()
        Image.fromarray(img_uint8).save(REAL_IMAGE_PATH)

        # ✅ Chuẩn hóa ảnh về [0,1] để khớp pipeline int8 TFLite
        img_norm = tf.cast(img, tf.float32) / 255.0
        img_norm_np = img_norm.numpy()                     # (224,224,3) float32 [0,1]
        Image.fromarray((img_norm_np * 255).astype(np.uint8)).save(REAL_IMAGE_NORM_PATH)

        # Log thống kê ảnh gốc
        with open(os.path.join(DATA_DUMP_DIR, "imagenet_real_info.txt"), "w") as f:
            f.write(f"Label: {int(label)}\n")
            f.write(f"Shape: {img_uint8.shape}\n")
            f.write(f"Dtype: {img_uint8.dtype}\n")
            f.write(f"Min: {img_uint8.min()}, Max: {img_uint8.max()}\n")
            f.write(f"Mean: {img_uint8.mean():.2f}, Std: {img_uint8.std():.2f}\n")

        print(f"✅ Đã lưu ảnh thật từ ImageNet tại: {REAL_IMAGE_PATH}, label={int(label)}")
        # Trả về tensor (1,224,224,3) float32 [0,1]
        return np.expand_dims(img_norm_np, 0).astype(np.float32), int(label)

    except Exception as e:
        print(f"⚠️ Không thể tải ImageNet (TFDS), fallback random. Lỗi: {e}")
        rng = np.random.RandomState(RANDOM_SEED)
        arr_uint8 = rng.randint(0, 256, size=INPUT_SHAPE, dtype=np.uint8)
        Image.fromarray(arr_uint8[0]).save(REAL_IMAGE_PATH)
        print(f"⚠️ Fallback random input, đã lưu tại: {REAL_IMAGE_PATH}")
        # Vẫn trả về [0,1] để pipeline thống nhất
        return (arr_uint8.astype(np.float32) / 255.0), None
    
def _as_list(x):
    if x is None:
        return []
    try:
        return np.array(x).reshape(-1).tolist()
    except Exception:
        return [x]

def _shape_of(arr, td):
    if arr is not None:
        return list(arr.shape)
    if td is not None and td.get("shape") is not None:
        return [int(v) for v in list(td["shape"])]
    return None

# ========= LOAD & INVOKE (INPUT DETERMINISTIC) =========
print("[*] Using model:", TFLITE_PATH)
interpreter = tf.lite.Interpreter(model_path=TFLITE_PATH, experimental_preserve_all_tensors=True)
interpreter.allocate_tensors()

in_det = interpreter.get_input_details()[0]
in_idx = in_det["index"]
in_scale, in_zp = in_det.get("quantization", (1.0, 0))

if INPUT_SOURCE == "zeros":
    real = np.zeros(INPUT_SHAPE, np.float32)
elif INPUT_SOURCE == "fixed":
    real, label = save_real_imagenet_sample()                   # real: float32 [0,1], shape (1,224,224,3)
    np.save(FIXED_NPY, (real * 255).astype(np.uint8))           # Lưu lại dạng uint8 để tái dùng
    print(f"✅ Đã lưu input ImageNet vào {FIXED_NPY}, label={label}")

elif INPUT_SOURCE == "file":
    assert os.path.exists(FIXED_NPY), f"Không thấy file: {FIXED_NPY}"
    arr = np.load(FIXED_NPY)                                    # uint8
    assert tuple(arr.shape) == INPUT_SHAPE, f"Shape {arr.shape} != {INPUT_SHAPE}"
    real = arr.astype(np.float32) / 255.0                       # ✅ chuyển về [0,1] cho đúng
else:
    raise ValueError("INPUT_SOURCE phải là 'zeros' | 'fixed' | 'file'")

np.save(os.path.join(LOG_DIR, "input_used.npy"), real.astype(np.float32))

if in_det["dtype"] == np.int8:
    # real phải là [0,1] (hoặc [-1,1] tùy pipeline). Khi đó không bị saturate 127 nữa.
    q_in = np.round(real / float(in_scale) + float(in_zp)).clip(-128,127).astype(np.int8)
    interpreter.set_tensor(in_idx, q_in)
else:
    interpreter.set_tensor(in_idx, real.astype(np.float32))


interpreter.invoke()

# ========= (Phần dump, log, verify giữ nguyên) =========
# [Giữ nguyên toàn bộ phần dump & log phía dưới của bạn]


tensor_details = interpreter.get_tensor_details()
tensor_by_idx = {t["index"]: t for t in tensor_details}
ops = interpreter._get_ops_details()

def try_get_tensor(idx):
    try: return interpreter.get_tensor(idx)
    except: return None

# ========= ✅ TÍCH HỢP DUMP DỮ LIỆU VÀ TẠO LOG CHI TIẾT =========
TENSORS_DIR = os.path.join(DATA_DUMP_DIR, "tensors")
GOLDEN_DIR = os.path.join(DATA_DUMP_DIR, "golden_outputs")
os.makedirs(TENSORS_DIR, exist_ok=True)
os.makedirs(GOLDEN_DIR, exist_ok=True)

np.savetxt(os.path.join(TENSORS_DIR, "ifm_input.txt"), q_in.flatten(), fmt="%d")
with open(os.path.join(TENSORS_DIR, "ifm_input_params.txt"), "w") as f:
    f.write(f"Shape: {q_in.shape}\nScale: {in_scale}\nZero Point: {in_zp}\n")

for op_id, op in enumerate(ops):
    op_name = op.get("op_name", "UNKNOWN")
    in_ids = list(op.get("inputs", []))
    out_ids = list(op.get("outputs", []))

    td_ifm0 = tensor_by_idx.get(int(in_ids[0])) if len(in_ids) >= 1 else None
    td_ifm1 = tensor_by_idx.get(int(in_ids[1])) if len(in_ids) >= 2 else None
    td_b    = tensor_by_idx.get(int(in_ids[2])) if len(in_ids) >= 3 else None
    td_ofm  = tensor_by_idx.get(int(out_ids[0])) if len(out_ids) >= 1 else None

    arr_ifm0 = try_get_tensor(td_ifm0["index"]) if td_ifm0 else None
    arr_ifm1 = try_get_tensor(td_ifm1["index"]) if td_ifm1 else None
    arr_b    = try_get_tensor(td_b["index"])   if td_b    else None
    arr_ofm  = try_get_tensor(td_ofm["index"])  if td_ofm  else None

    prefix = f"op_{op_id:03d}_{op_name}"
    if arr_ifm1 is not None:
        np.savetxt(os.path.join(TENSORS_DIR, f"{prefix}_weights.txt"), arr_ifm1.flatten(), fmt="%d")
    if arr_b is not None:
        np.savetxt(os.path.join(TENSORS_DIR, f"{prefix}_bias.txt"), arr_b.flatten(), fmt="%d")
    if arr_ofm is not None:
        np.savetxt(os.path.join(GOLDEN_DIR, f"{prefix}_output.txt"), arr_ofm.flatten(), fmt="%d")

        # ===== NEW: dump parameters (giống dump_tensors.py) =====
    params_path = os.path.join(TENSORS_DIR, f"{prefix}_params.txt")
    with open(params_path, "w", encoding="utf-8") as pf:
        # Thông tin output tensor
        out_info = td_ofm if td_ofm is not None else {}
        out_name = out_info.get("name")
        out_q_tuple = out_info.get("quantization", (None, None))
        out_scale, out_zp = (float(out_q_tuple[0]) if out_q_tuple[0] is not None else None,
                                int(out_q_tuple[1])   if out_q_tuple[1]   is not None else None)
        out_shape = _shape_of(arr_ofm, td_ofm)

        pf.write(f"Op Type: {op_name}\n")
        pf.write(f"Output Tensor: {out_name}\n")
        pf.write(f"Output Scale: {out_scale}\n")
        pf.write(f"Output Zero Point: {out_zp}\n")
        pf.write(f"Output Shape: {out_shape}\n\n")

        # Weights
        if td_ifm1 is not None:
            qw = qparams_of(td_ifm1)  # {'scales','zero_points','axis',...}
            w_shape = _shape_of(arr_ifm1, td_ifm1)
            pf.write("# --- Weights ---\n")
            pf.write(f"Name: {td_ifm1.get('name')}\n")
            pf.write(f"Shape: {w_shape}\n")
            pf.write(f"Scale(s): {_as_list(qw.get('scales'))}\n")
            pf.write(f"Zero Point(s): {_as_list(qw.get('zero_points'))}\n")
            pf.write(f"Axis: {qw.get('axis')}\n\n")

        # Bias
        if td_b is not None:
            qb = qparams_of(td_b)
            b_shape = _shape_of(arr_b, td_b)
            pf.write("# --- Bias ---\n")
            pf.write(f"Name: {td_b.get('name')}\n")
            pf.write(f"Shape: {b_shape}\n")
            pf.write(f"Scale(s): {_as_list(qb.get('scales'))}\n")
            pf.write(f"Zero Point(s): {_as_list(qb.get('zero_points'))}\n\n")

        # Optional: builtin_options (stride/padding/activation...) để tiện tra cứu
        bo = op.get("builtin_options", {}) or {}
        if bo:
            pf.write("# --- Builtin Options (raw) ---\n")
            pf.write(json.dumps(bo, ensure_ascii=False, indent=2))
            pf.write("\n")

        # Optional: tóm tắt shape toàn op
        pf.write("# --- Shapes summary ---\n")
        pf.write(f"IFM0 Shape: {_shape_of(arr_ifm0, td_ifm0)}\n")
        pf.write(f"IFM1/Weights Shape: {_shape_of(arr_ifm1, td_ifm1)}\n")
        pf.write(f"Bias Shape: {_shape_of(arr_b, td_b)}\n")
        pf.write(f"OFM Shape: {_shape_of(arr_ofm, td_ofm)}\n")

    fname = os.path.join(LOG_DIR, f"op{op_id:03d}_{op_name}.txt")
    with open(fname, "w", encoding="utf-8") as f:
        f.write(f"MODEL : {os.path.basename(TFLITE_PATH)}\n")
        f.write(f"OP #{op_id}: {op_name}\n")

        if op_name in ("CONV_2D", "DEPTHWISE_CONV_2D"):
            write_tensor_block(f, "IFM",     td_ifm0, arr_ifm0)
            write_tensor_block(f, "WEIGHTS", td_ifm1, arr_ifm1)
            write_tensor_block(f, "BIAS",    td_b,    arr_b)
            write_tensor_block(f, "OFM",     td_ofm,  arr_ofm)
        elif op_name in ("MUL", "ADD", "SUB"):
            write_tensor_block(f, "INPUT0", td_ifm0, arr_ifm0)
            write_tensor_block(f, "INPUT1", td_ifm1, arr_ifm1)
            write_tensor_block(f, "OFM",    td_ofm,  arr_ofm)
        else:
            write_tensor_block(f, "IFM0", td_ifm0, arr_ifm0)
            write_tensor_block(f, "IFM1", td_ifm1, arr_ifm1)
            write_tensor_block(f, "BIAS", td_b,    arr_b)
            write_tensor_block(f, "OFM",  td_ofm,  arr_ofm)

        if op_name in ("CONV_2D", "DEPTHWISE_CONV_2D", "FULLY_CONNECTED"):
            qi, qw, qo = qparams_of(td_ifm0), qparams_of(td_ifm1), qparams_of(td_ofm)
            if not all([qi, qw, qo, qi.get("scale_tuple"), qi.get("zp_tuple")]):
                f.write("\n(Verification skipped: missing quantization info)\n")
                continue
            
            # ✅ SỬA LỖI: Kiểm tra td_ofm.get("shape") với 'is not None'
            N = int(td_ofm["shape"][-1]) if td_ofm and td_ofm.get("shape") is not None else 1
            s_in  = qi["scale_tuple"]
            zp_in = qi["zp_tuple"]

            s_w  = broadcast_param(qw.get("scales"), N, 1.0).astype(np.float64)
            zp_w = broadcast_param(qw.get("zero_points"), N, 0).astype(np.int32)
            if qo.get("scale_tuple") is not None:
                s_out  = np.full((N,), float(qo["scale_tuple"]), dtype=np.float64)
                zp_out = np.full((N,), int(qo["zp_tuple"] or 0), dtype=np.int32)
            else:
                s_out  = broadcast_param(qo.get("scales"), N, 1.0).astype(np.float64)
                zp_out = broadcast_param(qo.get("zero_points"), N, 0).astype(np.int32)

            f.write("\n=== REQUANT (computed) ===\n")
            f.write(f"s_in: {s_in}, zp_in: {zp_in}\n")
            f.write(f"s_w[0:8]: {s_w[:8].tolist()}\n")
            f.write(f"zp_w[0:8]: {zp_w[:8].tolist()}\n")
            f.write(f"s_out[0:8]: {s_out[:8].tolist()}\n")
            f.write(f"zp_out[0:8]: {zp_out[:8].tolist()}\n")

            rm = (float(s_in) * s_w) / s_out
            M, rshift = quantize_multiplier_smaller_than_one(rm)
            f.write(f"M[0:8]: {M[:8].tolist()}\n")
            f.write(f"n[0:8]: {rshift[:8].tolist()}\n")

            if arr_ifm0 is not None and arr_ofm is not None and arr_ifm1 is not None:
                try:
                    hyp = infer_conv_hyperparams(list(arr_ifm0.shape), list(arr_ofm.shape))
                    sH, sW = hyp["stride"]; padding = hyp["padding"]
                    Hout, Wout = arr_ofm.shape[1], arr_ofm.shape[2]
                    b = arr_b.reshape(-1).astype(np.int32) if arr_b is not None else None
                    Cin = arr_ifm0.shape[3]
                    if op_name == "CONV_2D":
                        layout, Kh, Kw = detect_conv_layout_and_kernel(arr_ifm1, Cin=Cin, Cout=arr_ofm.shape[-1])
                    else: # DEPTHWISE_CONV_2D
                        layout, Kh, Kw = "HWIO", int(arr_ifm1.shape[0]), int(arr_ifm1.shape[1])

                    hs = np.linspace(0, Hout-1, num=min(GRID_H, Hout), dtype=int)
                    ws = np.linspace(0, Wout-1, num=min(GRID_W, Wout), dtype=int)
                    positions = [(int(h), int(w)) for h in hs for w in ws]

                    f.write("\n--- VERIFY SAMPLE OUTPUTS (CONV family, grid) ---\n")
                    f.write(f"stride={(sH,sW)}, padding={padding}, kernel=({Kh},{Kw}), grid={len(hs)}x{len(ws)} points\n")
                    f.write("pos(h,w),ch | acc | M | n | zp_out | y_calc | y_ref | match\n")

                    tested = 0
                    for idx_pos, (hh, ww) in enumerate(positions):
                        for c in range(min(arr_ofm.shape[-1], NUM_VERIFY_CHANNELS)):
                            acc_func = conv_point_acc_int32_debug if idx_pos < DEBUG_FULL_TRACE_MAX else conv_point_acc_int32_fast
                            acc = acc_func(
                                f, arr_ifm0, arr_ifm1, b, hh, ww, c,
                                (sH,sW), padding, int(zp_in), zp_w,
                                depthwise=(op_name=="DEPTHWISE_CONV_2D"),
                                layout=layout, Kh=Kh, Kw=Kw
                            )
                            mul = srdhm_vec(np.array([acc],dtype=np.int32), np.array([int(M[c])],dtype=np.int32))[0]
                            rq  = rounding_divide_by_pot_scalar(int(mul), int(rshift[c]))
                            y_calc = int(np.clip(int(zp_out[c]) + rq, -128, 127))
                            y_ref  = int(arr_ofm[0, hh, ww, c])
                            ok = "OK" if y_calc == y_ref else "DIFF"
                            f.write(f"({hh},{ww}),{c} | {int(acc)} | {int(M[c])} | {int(rshift[c])} | {int(zp_out[c])} | {y_calc} | {y_ref} | {ok}\n")
                            tested += 1
                except Exception as e:
                    f.write(f"(Verification skipped due to error: {e})\n")

        if op_name in ("MUL","ADD","SUB") and all(a is not None for a in [arr_ifm0, arr_ifm1, arr_ofm]):
            qx, qy, qz = qparams_of(td_ifm0), qparams_of(td_ifm1), qparams_of(td_ofm)
            if any(q is None or q.get("scale_tuple") is None or q.get("zp_tuple") is None for q in [qx, qy, qz]):
                f.write("\n(Skip eltwise verify: thiếu quant per-tensor)\n")
            else:
                try:
                    if op_name == "MUL":
                        eltwise_mul_debug(f, arr_ifm0, arr_ifm1, arr_ofm, qx, qy, qz)
                    else:
                        eltwise_addsub_debug(f, arr_ifm0, arr_ifm1, arr_ofm, qx, qy, qz, op_name)
                except Exception as e:
                    f.write(f"\n(Eltwise verification error: {e})\n")
        
        if op_name == "SOFTMAX" and arr_ofm is not None:
            qz = qparams_of(td_ofm)
            if qz and qz.get("scale_tuple") is not None and qz.get("zp_tuple") is not None:
                s_out, zp_out = float(qz["scale_tuple"]), int(qz["zp_tuple"])
                f.write("\n=== DEQUANT FORMULA ===\n")
                f.write(f"prob = (val_int8 - zp) * scale = (val_int8 - ({zp_out})) * {s_out}\n")
                probs = np.squeeze((arr_ofm.astype(np.int32) - zp_out) * s_out)
                f.write("\n=== OFM values (int8 → float) ===\n")
                for i, (v_int, v_float) in enumerate(zip(arr_ofm.flatten(), probs)):
                    f.write(f"class {i:4d}: int8={int(v_int):4d}  →  prob={v_float:.6f}\n")
                topk = probs.argsort()[-5:][::-1]
                f.write("\n=== TOP-5 PREDICT ===\n")
                for i in topk:
                    f.write(f"class {i}: prob={probs[i]:.6f}\n")
    
    print(f"✅ Logged & Dumped: {fname}")

print("\nHoàn tất.")
print(f"-> Log chi tiết đã được lưu tại: {os.path.abspath(LOG_DIR)}")
print(f"-> Dữ liệu tensor riêng lẻ đã được lưu tại: {os.path.abspath(DATA_DUMP_DIR)}")