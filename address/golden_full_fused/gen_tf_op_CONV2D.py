import numpy as np
import re, os, math

# ======================= CONFIG =======================
LAYER_TO_SIMULATE_ID = 3
PREVIOUS_LAYER_ID    = LAYER_TO_SIMULATE_ID - 1
CURRENT_OP_NAME      = "CONV_2D"
PREVIOUS_OP_NAME     = "MUL"

BASE_DIR   = "./Golden_Data/Data_Dump/tensors/"
GOLDEN_DIR = "./Golden_Data/Data_Dump/golden_outputs"

INPUT_FILE_PATH      = os.path.join(GOLDEN_DIR, f"op_{PREVIOUS_LAYER_ID:03d}_{PREVIOUS_OP_NAME}_output.txt")
IFM_PARAM_FILE_PATH  = os.path.join(BASE_DIR,   f"op_{PREVIOUS_LAYER_ID:03d}_{PREVIOUS_OP_NAME}_params.txt")

PREFIX              = f"op_{LAYER_TO_SIMULATE_ID:03d}_{CURRENT_OP_NAME}"
PARAM_FILE_PATH     = os.path.join(BASE_DIR,   f"{PREFIX}_params.txt")
WEIGHT_FILE_PATH    = os.path.join(BASE_DIR,   f"{PREFIX}_weights.txt")
BIAS_FILE_PATH      = os.path.join(BASE_DIR,   f"{PREFIX}_bias.txt")
GOLDEN_FILE_PATH    = os.path.join(GOLDEN_DIR, f"{PREFIX}_output.txt")

SIM_LOG_FILE = f"./Golden_Data/Layer_Logs/layer_{LAYER_TO_SIMULATE_ID:03d}_{CURRENT_OP_NAME}_log.txt"
SIM_OUT_FILE = f"./Golden_Data/Layer_Logs/layer_{LAYER_TO_SIMULATE_ID:03d}_{CURRENT_OP_NAME}_sim_output.txt"

# Extra dumps (per-OFM-element)
QMUL_MAP_FILE = f"./Golden_Data/Layer_Logs/layer_{LAYER_TO_SIMULATE_ID:03d}_{CURRENT_OP_NAME}_qmul_map.txt"
EXP_MAP_FILE  = f"./Golden_Data/Layer_Logs/layer_{LAYER_TO_SIMULATE_ID:03d}_{CURRENT_OP_NAME}_exp_map.txt"
ACC_MAP_FILE  = f"./Golden_Data/Layer_Logs/layer_{LAYER_TO_SIMULATE_ID:03d}_{CURRENT_OP_NAME}_acc_map.txt"   # NEW

# Auto-detect & diagnostics
AUTO_SAMPLE_H = 16
AUTO_SAMPLE_W = 16
# =======================================================


# ======================= PARSERS & UTILS =======================
def _parse_num_list(s, ty=float):
    if not s: return []
    parts = [p for p in re.split(r"[,\s]+", s.strip()) if p]
    return [ty(p) for p in parts]

def _find_first(text, patterns):
    for pat in patterns:
        m = re.search(pat, text, flags=re.DOTALL)
        if m: return m.group(1)
    return None

def parse_params(filepath):
    params = {}
    with open(filepath, "r", encoding="utf-8") as f:
        text = f.read()

    # Weights shape
    wshape_str = _find_first(text, [
        r"# --- Weights ---.*?Shape:\s*\((.*?)\)",
        r"# --- Weights ---.*?Shape:\s*\[(.*?)\]",
        r"IFM1/Weights Shape:\s*\[(.*?)\]",
        r"IFM1/Weights Shape:\s*\((.*?)\)",
    ])
    params["wshape"] = tuple(_parse_num_list(wshape_str, int)) if wshape_str else tuple([])

    # Quantization
    params["w_scales"]  = _parse_num_list(_find_first(text, [r"Scale\(s\):\s*\[(.*?)\]"]), float)
    params["w_zps"]     = _parse_num_list(_find_first(text, [r"Zero Point\(s\):\s*\[(.*?)\]"]), int)
    params["ofm_scale"] = float(_find_first(text, [r"Output Scale:\s*([0-9eE\.\-]+)"]) or 1.0)
    params["ofm_zp"]    = int(_find_first(text, [r"Output Zero Point:\s*(-?\d+)"]) or 0)
    params["ofm_shape"] = tuple(_parse_num_list(_find_first(text, [
        r"Output Shape:\s*\[(.*?)\]",
        r"Output Shape:\s*\((.*?)\)",
        r"OFM Shape:\s*\[(.*?)\]",
        r"OFM Shape:\s*\((.*?)\)"
    ]), int)) or ()
    params["ifm0_shape"] = tuple(_parse_num_list(_find_first(text, [
        r"IFM0 Shape:\s*\[(.*?)\]",
        r"IFM0 Shape:\s*\((.*?)\)"
    ]), int)) or ()
    return params

def read_txt_robust(path, shape=None, dtype=np.int32):
    with open(path, 'r') as f:
        vals = [int(x.strip()) for x in f if x.strip()]
    arr = np.array(vals, dtype=dtype)
    if shape and np.prod(shape) == arr.size:
        return arr.reshape(shape)
    return arr

def infer_stride_padding(H, W, Ho, Wo, Kh, Kw):
    for s in [1, 2, 3, 4]:
        ho_same = (H + s - 1) // s
        wo_same = (W + s - 1) // s
        if ho_same == Ho and wo_same == Wo:
            pad_h = max((Ho - 1) * s + Kh - H, 0)
            pad_w = max((Wo - 1) * s + Kw - W, 0)
            return (s, s), ("SAME", (pad_h//2, pad_h - pad_h//2, pad_w//2, pad_w - pad_w//2))
    for s in [1, 2, 3, 4]:
        ho_valid = (H - Kh + s) // s
        wo_valid = (W - Kw + s) // s
        if ho_valid == Ho and wo_valid == Wo:
            return (s, s), ("VALID", (0,0,0,0))
    return (1,1), ("VALID", (0,0,0,0))

def ensure_parent_dir(path):
    d = os.path.dirname(path)
    if d:
        os.makedirs(d, exist_ok=True)
# =======================================================


# ============== WEIGHT DECODE: thử 3 layout nguồn & quy về OHWI ==============
def try_decode_weights_to_OHWI(w_flat, Cin, Cout, Kh, Kw):
    views = {}
    total = w_flat.size
    if total == Cout*Kh*Kw*Cin:
        views["OHWI"] = w_flat.reshape(Cout, Kh, Kw, Cin)
    if total == Cout*Cin*Kh*Kw:
        w_oihw = w_flat.reshape(Cout, Cin, Kh, Kw)
        views["OIHW"] = np.transpose(w_oihw, (0,2,3,1))
    if total == Kh*Kw*Cin*Cout:
        w_hwio = w_flat.reshape(Kh, Kw, Cin, Cout)
        views["HWIO"] = np.transpose(w_hwio, (3,0,1,2))
    return views


# ======================= TFLite quant helpers =======================
def quantize_multiplier(real_multiplier: float):
    if real_multiplier == 0.0:
        return 0, 0
    m, e = math.frexp(real_multiplier)
    q = int(round(m * (1 << 31)))
    if q == (1 << 31):
        q //= 2
        e += 1
    return q, e  # q: 31-bit-ish integer, e: signed exponent

def srdhm(a: int, b: int) -> int:
    prod = np.int64(a) * np.int64(b)
    if prod >= 0:
        prod += (1 << 30)
    else:
        prod += (1 - (1 << 30))
    return int(prod >> 31)

def rdivpot_neg_no_bias_ge(x: int, shift: int) -> int:
    if shift == 0: return x
    mask = (1 << shift) - 1
    remainder = x & mask
    if x < 0:
        threshold = (mask >> 1)
        return (x >> shift) + (1 if remainder >= threshold else 0)
    else:
        threshold = (mask >> 1)
        return (x >> shift) + (1 if remainder > threshold else 0)

def requantize_tflite_like(x: int, real_multiplier: float) -> int:
    """Requantization chuẩn: neg_no_bias_ge (chuẩn TFLite thực tế)."""
    qmul, exp = quantize_multiplier(real_multiplier)
    left_shift  = exp if exp > 0 else 0 
    right_shift = -exp if exp < 0 else 0
    x = np.int64(x) * np.int64(1 << left_shift)
    y = srdhm(x, qmul)
    return rdivpot_neg_no_bias_ge(y, right_shift)


# ======================= CONV (OHWI) =======================
def conv_run_OHWI(ifm_p, w_OHWI, bias, in_s, in_zp, out_s, out_zp, w_scales, w_zps,
                  H, W, Cin, Ho, Wo, Cout, Kh, Kw, sH, sW, pad_top, pad_left,
                  limit_ho=None, limit_ow=None,
                  qmuls=None, exps=None):
    """
    Nếu qmuls/exps != None: dùng bộ tiền tính theo kênh.
    """
    max_ho = Ho if limit_ho is None else min(Ho, limit_ho)
    max_ow = Wo if limit_ow is None else min(Wo, limit_ow)
    ofm = np.zeros((max_ho, max_ow, Cout), dtype=np.int8)

    for oh in range(max_ho):
        ih = oh * sH
        for ow in range(max_ow):
            iw = ow * sW
            patch = ifm_p[ih:ih+Kh, iw:iw+Kw, :]
            patch_mz = patch.astype(np.int64) - in_zp
            for oc in range(Cout):
                k = w_OHWI[oc, :, :, :]
                k_mz = k.astype(np.int64) - (w_zps[oc] if len(w_zps)>1 else w_zps[0])
                acc = np.sum(patch_mz * k_mz) + bias[oc]

                if qmuls is not None and exps is not None:
                    exp = int(exps[oc])
                    left_shift  = exp if exp > 0 else 0
                    right_shift = -exp if exp < 0 else 0
                    x = np.int64(acc) * np.int64(1 << left_shift)
                    y = srdhm(x, int(qmuls[oc]))
                    res2 = rdivpot_neg_no_bias_ge(int(y), right_shift)
                else:
                    eff = (in_s * (w_scales[oc] if len(w_scales)>1 else w_scales[0])) / out_s
                    res2 = requantize_tflite_like(int(acc), eff)

                res3 = res2 + out_zp
                ofm[oh, ow, oc] = np.clip(res3, -128, 127)
    return ofm

def build_acc_map_OHWI(ifm_p, w_OHWI, bias, in_zp, w_zps,
                       Ho, Wo, Cout, Kh, Kw, sH, sW):
    """
    Trả về acc_map (Ho,Wo,Cout) là tổng tích (IFM-in_zp)*(W-w_zp) + bias trước khi requantize.
    """
    acc_map = np.zeros((Ho, Wo, Cout), dtype=np.int32)
    for oh in range(Ho):
        ih = oh * sH
        for ow in range(Wo):
            iw = ow * sW
            patch = ifm_p[ih:ih+Kh, iw:iw+Kw, :]
            patch_mz = patch.astype(np.int64) - in_zp
            for oc in range(Cout):
                k = w_OHWI[oc, :, :, :]
                k_mz = k.astype(np.int64) - (w_zps[oc] if len(w_zps)>1 else w_zps[0])
                acc  = np.sum(patch_mz * k_mz) + bias[oc]
                acc_map[oh, ow, oc] = np.int32(acc)  # cast về int32 cho testbench
    return acc_map


# ======================= MAIN SIMULATION =======================
def simulate_conv_layer():
    log = []
    log.append(f"===== SIMULATION LOG: Layer {LAYER_TO_SIMULATE_ID} ({CURRENT_OP_NAME}) =====")

    prev_params = parse_params(IFM_PARAM_FILE_PATH)
    cur_params  = parse_params(PARAM_FILE_PATH)

    in_s, in_zp = prev_params["ofm_scale"], prev_params["ofm_zp"]
    ifm_shape_full = prev_params.get("ofm_shape", ())
    wshape_hint    = cur_params["wshape"]
    w_scales = cur_params["w_scales"] or [1.0]
    w_zps    = cur_params["w_zps"]    or [0]
    out_s, out_zp = cur_params["ofm_scale"], cur_params["ofm_zp"]
    ofm_shape_full = cur_params.get("ofm_shape", ())

    if not ifm_shape_full:
        raise RuntimeError("Không tìm thấy IFM shape trong params của layer trước.")
    N,H,W,Cin = ifm_shape_full
    N2,Ho,Wo,Cout = ofm_shape_full

    log.append(f"Input Scale={in_s}, ZP={in_zp}")
    log.append(f"Weight Shape hint={wshape_hint}, #scales={len(w_scales)}, #zps={len(w_zps)}")
    log.append(f"Output Scale={out_s}, ZP={out_zp}")
    log.append(f"IFM Shape: (N,H,W,C)= {ifm_shape_full} → OFM Shape: {ofm_shape_full}")

    # --- Load data ---
    ifm    = read_txt_robust(INPUT_FILE_PATH, (H, W, Cin))
    w_flat = read_txt_robust(WEIGHT_FILE_PATH, None)
    bias   = read_txt_robust(BIAS_FILE_PATH, (Cout,)) if os.path.exists(BIAS_FILE_PATH) else np.zeros((Cout,), dtype=np.int32)
    golden_flat = np.loadtxt(GOLDEN_FILE_PATH, dtype=np.int16)

    # Kernel size
    if len(wshape_hint) == 4:
        Kh, Kw = int(wshape_hint[1]), int(wshape_hint[2])
    else:
        Kh = Kw = 3

    # Stride & padding
    (sH, sW), (padtype, pads) = infer_stride_padding(H, W, Ho, Wo, Kh, Kw)
    pad_top, pad_bottom, pad_left, pad_right = pads
    ifm_p = np.pad(ifm, ((pad_top,pad_bottom),(pad_left,pad_right),(0,0)),
                   mode="constant", constant_values=in_zp)
    log.append(f"\nStride={(sH,sW)}, Padding={padtype}, pads={pads}")
    log.append(f"IFM padded shape: {ifm_p.shape}")

    # Golden reshape
    if golden_flat.size != Ho*Wo*Cout:
        log.append(f"⚠️ Golden size {golden_flat.size} != expected {Ho*Wo*Cout}. Dừng.")
        ensure_parent_dir(SIM_LOG_FILE); open(SIM_LOG_FILE,"w",encoding="utf-8").write("\n".join(log))
        print("\n".join(log)); return
    golden = golden_flat.reshape(Ho,Wo,Cout).astype(np.int8)

    # ---- Precompute (M, exp) per-channel, then broadcast to (Ho,Wo,Cout) ----
    if len(w_scales) == 1:
        wsc = np.full(Cout, w_scales[0], dtype=np.float64)
    else:
        wsc = np.array(w_scales[:Cout], dtype=np.float64)

    eff_per_oc = (in_s * wsc) / out_s  # real_multiplier per output channel
    qmuls = np.empty(Cout, dtype=np.int64)
    exps  = np.empty(Cout, dtype=np.int32)
    for oc in range(Cout):
        qmul, exp = quantize_multiplier(float(eff_per_oc[oc]))
        qmuls[oc] = qmul
        exps[oc]  = exp

    # Per-OFM-element dump (broadcast từ per-channel)
    M_map   = np.broadcast_to(qmuls.reshape(1,1,Cout), (Ho, Wo, Cout)).astype(np.int64)
    EXP_map = np.broadcast_to(exps.reshape(1,1,Cout),  (Ho, Wo, Cout)).astype(np.int32)

    ensure_parent_dir(QMUL_MAP_FILE); np.savetxt(QMUL_MAP_FILE, M_map.reshape(-1), fmt="%d")
    ensure_parent_dir(EXP_MAP_FILE);  np.savetxt(EXP_MAP_FILE,  EXP_map.reshape(-1), fmt="%d")

    log.append(f"Saved per-element M to:  {QMUL_MAP_FILE}")
    log.append(f"Saved per-element exp to:{EXP_MAP_FILE}")

    # Decode weights → OHWI
    w_views = try_decode_weights_to_OHWI(w_flat, Cin, Cout, Kh, Kw)
    if not w_views:
        log.append("❌ Không decode được weights theo layout phổ biến.")
        ensure_parent_dir(SIM_LOG_FILE); open(SIM_LOG_FILE,"w",encoding="utf-8").write("\n".join(log))
        print("\n".join(log)); return

    # Auto chọn layout (scoring)
    scores = {}
    for src, w_cand in w_views.items():
        ofm_small = conv_run_OHWI(
            ifm_p, w_cand, bias, in_s, in_zp, out_s, out_zp, w_scales, w_zps,
            H, W, Cin, Ho, Wo, Cout, Kh, Kw, sH, sW, pad_top, pad_left,
            limit_ho=AUTO_SAMPLE_H, limit_ow=AUTO_SAMPLE_W,
            qmuls=qmuls, exps=exps
        )
        gold_small = golden[:ofm_small.shape[0], :ofm_small.shape[1], :]
        mism = int(np.sum(ofm_small != gold_small))
        scores[src] = (mism, ofm_small.size, mism/ofm_small.size)
    best_src = min(scores.keys(), key=lambda k: scores[k][2])
    log.append("\n[Auto layout scoring (decode-from src → OHWI)]:")
    for src,(mism,total,ratio) in scores.items():
        log.append(f"  src={src}: mism={mism}/{total} ({ratio:.2%})")
    log.append(f"=> Chọn src layout: {best_src}")
    w_best = w_views[best_src]
    log.append("Requantization: dùng rdivpot_neg_no_bias_ge (chuẩn).")

    # ==== NEW: dump acc_map (trước requantize) ====
    acc_map = build_acc_map_OHWI(
        ifm_p, w_best, bias, in_zp, w_zps,
        Ho, Wo, Cout, Kh, Kw, sH, sW
    )
    ensure_parent_dir(ACC_MAP_FILE); np.savetxt(ACC_MAP_FILE, acc_map.reshape(-1), fmt="%d")
    log.append(f"Saved pre-requant ACC (int32) to: {ACC_MAP_FILE}")

    # Run final conv (requantized)
    ofm = conv_run_OHWI(
        ifm_p, w_best, bias, in_s, in_zp, out_s, out_zp, w_scales, w_zps,
        H, W, Cin, Ho, Wo, Cout, Kh, Kw, sH, sW, pad_top, pad_left,
        qmuls=qmuls, exps=exps
    )
    mismatches = int(np.sum(golden != ofm))

    ensure_parent_dir(SIM_OUT_FILE)
    np.savetxt(SIM_OUT_FILE, ofm.flatten(), fmt="%d")
    log.append(f"\nSimulation completed and output saved.")
    log.append(f"Total mismatches: {mismatches} / {ofm.size}")
    log.append("✅ OUTPUT KHỚP" if mismatches == 0 else "❌ OUTPUT KHÔNG KHỚP")

    ensure_parent_dir(SIM_LOG_FILE)
    with open(SIM_LOG_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join(log))
    print("\n".join(log))


if __name__ == "__main__":
    simulate_conv_layer()
